package quizzes

import (
	"context"
	"sort"
)

// enrollmentChecker reports whether a student is actively enrolled in a
// course. Satisfied by *enrollments.Service.
type enrollmentChecker interface {
	IsEnrolled(ctx context.Context, studentID, courseID int64) (bool, error)
}

// Service is the student-facing quiz flow.
type Service struct {
	repo   *Repository
	enroll enrollmentChecker
}

func NewService(repo *Repository, enroll enrollmentChecker) *Service {
	return &Service{repo: repo, enroll: enroll}
}

// requireQuizAccess resolves the assignment, confirms it is a published quiz
// and that the student is enrolled in the owning course.
func (s *Service) requireQuizAccess(ctx context.Context, studentID, assignmentID int64) (assignmentMeta, error) {
	meta, err := s.repo.AssignmentMeta(ctx, assignmentID)
	if err != nil {
		return assignmentMeta{}, err
	}
	if meta.AssignmentType != "quiz" {
		return assignmentMeta{}, ErrNotQuizAssignment
	}
	if !meta.studentVisible() {
		return assignmentMeta{}, ErrQuizNotFound
	}
	enrolled, err := s.enroll.IsEnrolled(ctx, studentID, meta.CourseID)
	if err != nil {
		return assignmentMeta{}, err
	}
	if !enrolled {
		return assignmentMeta{}, ErrNotEnrolled
	}
	return meta, nil
}

// StartAttempt opens (or resumes) an attempt and returns the quiz payload —
// options only, never the answer key (spec §20–§22).
func (s *Service) StartAttempt(ctx context.Context, studentID, assignmentID int64) (StartAttemptResponse, error) {
	meta, err := s.requireQuizAccess(ctx, studentID, assignmentID)
	if err != nil {
		return StartAttemptResponse{}, err
	}
	settings, err := s.repo.GetSettings(ctx, assignmentID)
	if err != nil {
		return StartAttemptResponse{}, err
	}
	questions, err := s.repo.ActiveQuestions(ctx, assignmentID)
	if err != nil {
		return StartAttemptResponse{}, err
	}
	if len(questions) == 0 {
		return StartAttemptResponse{}, ErrNoQuestions
	}
	for _, q := range questions {
		if !q.wellFormed() {
			return StartAttemptResponse{}, ErrQuizMisconfigured
		}
	}

	// Resume an open attempt rather than stacking a new one.
	if open, ok, err := s.repo.InProgressAttempt(ctx, studentID, assignmentID); err != nil {
		return StartAttemptResponse{}, err
	} else if ok {
		return StartAttemptResponse{
			Attempt: toAttemptBrief(open),
			Quiz:    toStudentQuiz(meta, settings, questions),
		}, nil
	}

	if settings.MaxAttempts != nil {
		used, err := s.repo.CountSubmittedAttempts(ctx, studentID, assignmentID)
		if err != nil {
			return StartAttemptResponse{}, err
		}
		if used >= *settings.MaxAttempts {
			return StartAttemptResponse{}, ErrMaxAttempts
		}
	}

	attempt, err := s.repo.CreateAttempt(ctx, studentID, assignmentID)
	if err != nil {
		return StartAttemptResponse{}, err
	}
	return StartAttemptResponse{
		Attempt: toAttemptBrief(attempt),
		Quiz:    toStudentQuiz(meta, settings, questions),
	}, nil
}

// SubmitAttempt validates the answers, scores the attempt server-side and
// finalizes it in one transaction (spec §24–§38).
func (s *Service) SubmitAttempt(ctx context.Context, studentID, attemptID int64, req SubmitRequest) (AttemptResult, error) {
	attempt, err := s.repo.GetAttempt(ctx, attemptID)
	if err != nil {
		return AttemptResult{}, err
	}
	if attempt.StudentID != studentID {
		return AttemptResult{}, ErrAttemptNotOwned
	}
	if attempt.Status != AttemptInProgress {
		return AttemptResult{}, ErrAttemptClosed
	}

	meta, err := s.repo.AssignmentMeta(ctx, attempt.AssignmentID)
	if err != nil {
		return AttemptResult{}, err
	}
	settings, err := s.repo.GetSettings(ctx, attempt.AssignmentID)
	if err != nil {
		return AttemptResult{}, err
	}
	questions, err := s.repo.ActiveQuestions(ctx, attempt.AssignmentID)
	if err != nil {
		return AttemptResult{}, err
	}
	if len(questions) == 0 {
		return AttemptResult{}, ErrNoQuestions
	}

	byQuestion := map[int64]Question{}
	for _, q := range questions {
		byQuestion[q.ID] = q
	}

	// Index the submitted answers, rejecting anything that does not belong to
	// this quiz (spec §27, §28).
	submitted := map[int64][]int64{}
	for _, ans := range req.Answers {
		q, ok := byQuestion[ans.QuestionID]
		if !ok {
			return AttemptResult{}, invalid("an answer references a question that is not in this quiz")
		}
		active := q.activeOptionIDs()
		seen := map[int64]bool{}
		clean := make([]int64, 0, len(ans.SelectedOptionIDs))
		for _, optID := range ans.SelectedOptionIDs {
			if !active[optID] {
				return AttemptResult{}, invalid("an answer references an option that is not in its question")
			}
			if !seen[optID] {
				seen[optID] = true
				clean = append(clean, optID)
			}
		}
		switch q.Type {
		case QuestionSingleChoice, QuestionTrueFalse:
			if len(clean) != 1 {
				return AttemptResult{}, invalid("this question needs exactly one answer")
			}
		case QuestionMultipleChoice:
			if len(clean) < 1 {
				return AttemptResult{}, invalid("this question needs at least one answer")
			}
		}
		submitted[ans.QuestionID] = clean
	}

	// Score every active question (unanswered → 0).
	graded := make([]gradedQuestion, 0, len(questions))
	for _, q := range questions {
		graded = append(graded, gradedQuestion{
			QuestionID:  q.ID,
			Points:      q.Points,
			Type:        q.Type,
			CorrectIDs:  q.correctOptionIDs(),
			SelectedIDs: submitted[q.ID],
		})
	}
	score := gradeQuiz(graded)
	passed := isPass(score.Percent, settings.PassPercent)

	persist := make([]persistedAnswer, 0, len(questions))
	for _, q := range questions {
		r := score.Results[q.ID]
		persist = append(persist, persistedAnswer{
			QuestionID:    q.ID,
			SelectedIDs:   submitted[q.ID],
			IsCorrect:     r.IsCorrect,
			PointsAwarded: r.PointsAwarded,
		})
	}

	finalized, err := s.repo.SubmitAttemptTx(ctx, attemptID, persist, score.Score, score.MaxScore, score.Percent, passed)
	if err != nil {
		return AttemptResult{}, err
	}

	return buildResult(finalized, meta, settings, questions, score.Results, submitted), nil
}

// GetAttempt returns a resumable quiz (in progress) or the graded result
// (submitted) — the student's own attempt only (spec §42).
func (s *Service) GetAttempt(ctx context.Context, studentID, attemptID int64) (AttemptDetail, error) {
	attempt, err := s.repo.GetAttempt(ctx, attemptID)
	if err != nil {
		return AttemptDetail{}, err
	}
	if attempt.StudentID != studentID {
		return AttemptDetail{}, ErrAttemptNotOwned
	}
	meta, err := s.repo.AssignmentMeta(ctx, attempt.AssignmentID)
	if err != nil {
		return AttemptDetail{}, err
	}
	settings, err := s.repo.GetSettings(ctx, attempt.AssignmentID)
	if err != nil {
		return AttemptDetail{}, err
	}
	questions, err := s.repo.ActiveQuestions(ctx, attempt.AssignmentID)
	if err != nil {
		return AttemptDetail{}, err
	}

	detail := AttemptDetail{Attempt: toAttemptBrief(attempt)}
	if attempt.Status == AttemptInProgress {
		q := toStudentQuiz(meta, settings, questions)
		detail.Quiz = &q
		return detail, nil
	}

	answers, selectedByQ, err := s.repo.AttemptAnswers(ctx, attemptID)
	if err != nil {
		return AttemptDetail{}, err
	}
	results := map[int64]questionResult{}
	for qid, ar := range answers {
		qr := questionResult{QuestionID: qid}
		if ar.IsCorrect != nil {
			qr.IsCorrect = *ar.IsCorrect
		}
		if ar.PointsAwarded != nil {
			qr.PointsAwarded = *ar.PointsAwarded
		}
		results[qid] = qr
	}
	res := buildResult(attempt, meta, settings, questions, results, selectedByQ)
	detail.Result = &res
	return detail, nil
}

// ListAttempts is the attempt history + roll-up (spec §41, §43).
func (s *Service) ListAttempts(ctx context.Context, studentID, assignmentID int64) (AttemptHistory, error) {
	meta, err := s.requireQuizAccess(ctx, studentID, assignmentID)
	if err != nil {
		return AttemptHistory{}, err
	}
	settings, err := s.repo.GetSettings(ctx, assignmentID)
	if err != nil {
		return AttemptHistory{}, err
	}
	attempts, err := s.repo.ListAttempts(ctx, studentID, assignmentID)
	if err != nil {
		return AttemptHistory{}, err
	}

	out := AttemptHistory{
		AssignmentID: assignmentID,
		Title:        meta.Title,
		PassPercent:  settings.PassPercent,
		MaxAttempts:  settings.MaxAttempts,
		Attempts:     []HistoryItem{},
	}

	used := 0
	for i, a := range attempts {
		item := HistoryItem{
			AttemptID:     a.ID,
			AttemptNumber: i + 1,
			Status:        a.Status,
			Score:         a.Score,
			MaxScore:      a.MaxScore,
			Percent:       a.Percent,
			Passed:        a.Passed,
			StartedAt:     a.StartedAt,
			SubmittedAt:   a.SubmittedAt,
		}
		out.Attempts = append(out.Attempts, item)

		if a.Status == AttemptSubmitted {
			used++
			if a.Passed != nil && *a.Passed {
				out.Passed = true
			}
			if a.Percent != nil && (out.BestPercent == nil || *a.Percent > *out.BestPercent) {
				out.BestPercent = a.Percent
				out.BestScore = a.Score
				out.BestMaxScore = a.MaxScore
			}
		}
		if a.Status == AttemptInProgress {
			id := a.ID
			out.InProgressID = &id
		}
	}
	out.AttemptsUsed = used
	if settings.MaxAttempts != nil {
		left := *settings.MaxAttempts - used
		if left < 0 {
			left = 0
		}
		out.AttemptsLeft = &left
	}
	out.CanStart = out.InProgressID != nil || out.AttemptsLeft == nil || *out.AttemptsLeft > 0

	// stable order (oldest first already, but be explicit)
	sort.SliceStable(out.Attempts, func(i, j int) bool { return out.Attempts[i].AttemptNumber < out.Attempts[j].AttemptNumber })
	return out, nil
}

// TeacherAttempt returns a submitted attempt's result for a teacher who shares
// a group with the student in that course (read-only, spec §70).
func (s *Service) TeacherAttempt(ctx context.Context, teacherID, attemptID int64) (AttemptResult, error) {
	attempt, err := s.repo.GetAttempt(ctx, attemptID)
	if err != nil {
		return AttemptResult{}, err
	}
	meta, err := s.repo.AssignmentMeta(ctx, attempt.AssignmentID)
	if err != nil {
		return AttemptResult{}, err
	}
	ok, err := s.repo.StudentInTeacherCourse(ctx, teacherID, attempt.StudentID, meta.CourseID)
	if err != nil {
		return AttemptResult{}, err
	}
	if !ok {
		return AttemptResult{}, ErrAttemptNotFound
	}
	if attempt.Status != AttemptSubmitted {
		return AttemptResult{}, ErrAttemptNotFound
	}
	// Teachers always see the answer key.
	settings, err := s.repo.GetSettings(ctx, attempt.AssignmentID)
	if err != nil {
		return AttemptResult{}, err
	}
	settings.ShowCorrectAnswers = true
	settings.ShowExplanations = true
	questions, err := s.repo.ActiveQuestions(ctx, attempt.AssignmentID)
	if err != nil {
		return AttemptResult{}, err
	}
	answers, selectedByQ, err := s.repo.AttemptAnswers(ctx, attemptID)
	if err != nil {
		return AttemptResult{}, err
	}
	results := map[int64]questionResult{}
	for qid, ar := range answers {
		qr := questionResult{QuestionID: qid}
		if ar.IsCorrect != nil {
			qr.IsCorrect = *ar.IsCorrect
		}
		if ar.PointsAwarded != nil {
			qr.PointsAwarded = *ar.PointsAwarded
		}
		results[qid] = qr
	}
	return buildResult(attempt, meta, settings, questions, results, selectedByQ), nil
}

/* ---- read helpers used by other packages ---- */

// QuizAssignmentIDs / CountPassedForAssignments back the progress gate.
func (s *Service) QuizAssignmentIDs(ctx context.Context, assignmentIDs []int64) ([]int64, error) {
	return s.repo.QuizAssignmentIDs(ctx, assignmentIDs)
}

func (s *Service) CountPassedForAssignments(ctx context.Context, studentID int64, assignmentIDs []int64) (int, error) {
	return s.repo.CountPassedAssignments(ctx, studentID, assignmentIDs)
}

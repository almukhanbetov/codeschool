package quizzes

import (
	"context"
	"log"
	"strconv"
	"strings"
)

// AdminService is the quiz authoring flow. Every mutation is written to the
// shared admin_audit_log (spec §63).
type AdminService struct {
	repo *Repository
}

func NewAdminService(repo *Repository) *AdminService {
	return &AdminService{repo: repo}
}

func (s *AdminService) audit(ctx context.Context, adminID int64, action, entity string, entityID int64, summary string) {
	id := entityID
	if err := s.repo.WriteAudit(ctx, adminID, action, entity, &id, summary); err != nil {
		log.Printf("quizzes: audit write failed (%s %s): %v", action, entity, err)
	}
}

// requireQuizAssignment loads the assignment and confirms it is a quiz
// (spec §5) — questions/settings only exist for assignment_type = quiz.
func (s *AdminService) requireQuizAssignment(ctx context.Context, assignmentID int64) (assignmentMeta, error) {
	meta, err := s.repo.AssignmentMeta(ctx, assignmentID)
	if err != nil {
		return assignmentMeta{}, err
	}
	if meta.AssignmentType != "quiz" {
		return assignmentMeta{}, ErrNotQuizAssignment
	}
	return meta, nil
}

/* ================= read ================= */

func (s *AdminService) GetQuiz(ctx context.Context, assignmentID int64) (AdminQuiz, error) {
	meta, err := s.repo.AssignmentMeta(ctx, assignmentID)
	if err != nil {
		return AdminQuiz{}, err
	}
	settings, err := s.repo.GetSettings(ctx, assignmentID)
	if err != nil {
		return AdminQuiz{}, err
	}
	questions, err := s.repo.AllQuestions(ctx, assignmentID)
	if err != nil {
		return AdminQuiz{}, err
	}
	return AdminQuiz{
		AssignmentID:   assignmentID,
		AssignmentType: meta.AssignmentType,
		Title:          meta.Title,
		Settings: AdminSettings{
			PassPercent:        settings.PassPercent,
			MaxAttempts:        settings.MaxAttempts,
			ShowCorrectAnswers: settings.ShowCorrectAnswers,
			ShowExplanations:   settings.ShowExplanations,
		},
		Questions: toAdminQuestions(questions),
	}, nil
}

/* ================= settings ================= */

func (s *AdminService) UpdateSettings(ctx context.Context, adminID, assignmentID int64, req UpdateSettingsRequest) (AdminSettings, error) {
	if _, err := s.requireQuizAssignment(ctx, assignmentID); err != nil {
		return AdminSettings{}, err
	}
	if req.PassPercent < 0 || req.PassPercent > 100 {
		return AdminSettings{}, invalid("passPercent must be between 0 and 100")
	}
	if req.MaxAttempts != nil && *req.MaxAttempts < 1 {
		return AdminSettings{}, invalid("maxAttempts must be at least 1 (or null for unlimited)")
	}
	settings := Settings{
		AssignmentID:       assignmentID,
		PassPercent:        req.PassPercent,
		MaxAttempts:        req.MaxAttempts,
		ShowCorrectAnswers: req.ShowCorrectAnswers,
		ShowExplanations:   req.ShowExplanations,
	}
	if err := s.repo.UpsertSettings(ctx, settings); err != nil {
		return AdminSettings{}, err
	}
	s.audit(ctx, adminID, "update", "quiz_settings", assignmentID, "pass "+strconv.Itoa(req.PassPercent)+"%")
	return AdminSettings{
		PassPercent:        settings.PassPercent,
		MaxAttempts:        settings.MaxAttempts,
		ShowCorrectAnswers: settings.ShowCorrectAnswers,
		ShowExplanations:   settings.ShowExplanations,
	}, nil
}

/* ================= questions ================= */

func (s *AdminService) CreateQuestion(ctx context.Context, adminID, assignmentID int64, req CreateQuestionRequest) (AdminQuestion, error) {
	if _, err := s.requireQuizAssignment(ctx, assignmentID); err != nil {
		return AdminQuestion{}, err
	}
	text := strings.TrimSpace(req.QuestionText)
	if text == "" {
		return AdminQuestion{}, invalid("questionText is required")
	}
	if !questionTypes[req.QuestionType] {
		return AdminQuestion{}, invalid("questionType must be single_choice, multiple_choice or true_false")
	}
	points := 1
	if req.Points != nil {
		points = *req.Points
	}
	if points < 1 {
		return AdminQuestion{}, invalid("points must be at least 1")
	}
	position := 0
	if req.Position != nil {
		position = *req.Position
	}
	isActive := true
	if req.IsActive != nil {
		isActive = *req.IsActive
	}

	// Inline option sanity for single_choice / true_false.
	if len(req.Options) > 0 {
		correct := 0
		for _, o := range req.Options {
			if o.IsCorrect {
				correct++
			}
		}
		switch req.QuestionType {
		case QuestionSingleChoice, QuestionTrueFalse:
			if correct > 1 {
				return AdminQuestion{}, invalid("a single-choice question can have only one correct option")
			}
		}
		if req.QuestionType == QuestionTrueFalse && len(req.Options) > 2 {
			return AdminQuestion{}, invalid("a true/false question has exactly two options")
		}
	}

	id, err := s.repo.CreateQuestion(ctx, assignmentID, text, req.QuestionType, points, position, normStr(req.Explanation), isActive)
	if err != nil {
		return AdminQuestion{}, err
	}
	for i, o := range req.Options {
		pos := i
		if o.Position != nil {
			pos = *o.Position
		}
		if _, err := s.repo.CreateOption(ctx, id, strings.TrimSpace(o.OptionText), o.IsCorrect, pos); err != nil {
			return AdminQuestion{}, err
		}
	}
	s.audit(ctx, adminID, "create", "quiz_question", id, text)

	q, err := s.repo.QuestionWithOptions(ctx, id)
	if err != nil {
		return AdminQuestion{}, err
	}
	return toAdminQuestion(q), nil
}

func (s *AdminService) UpdateQuestion(ctx context.Context, adminID, questionID int64, req UpdateQuestionRequest) (AdminQuestion, error) {
	cur, err := s.repo.GetQuestion(ctx, questionID)
	if err != nil {
		return AdminQuestion{}, err
	}
	fields := map[string]any{}
	if req.QuestionText != nil {
		t := strings.TrimSpace(*req.QuestionText)
		if t == "" {
			return AdminQuestion{}, invalid("questionText cannot be empty")
		}
		fields["question_text"] = t
	}
	if req.QuestionType != nil {
		if !questionTypes[*req.QuestionType] {
			return AdminQuestion{}, invalid("invalid questionType")
		}
		fields["question_type"] = *req.QuestionType
	}
	if req.Points != nil {
		if *req.Points < 1 {
			return AdminQuestion{}, invalid("points must be at least 1")
		}
		fields["points"] = *req.Points
	}
	if req.Position != nil {
		fields["position"] = *req.Position
	}
	if req.Explanation != nil {
		fields["explanation"] = normStr(req.Explanation)
	}
	if req.IsActive != nil {
		fields["is_active"] = *req.IsActive
	}
	if err := s.repo.UpdateQuestion(ctx, questionID, fields); err != nil {
		return AdminQuestion{}, err
	}
	s.audit(ctx, adminID, "update", "quiz_question", questionID, cur.Text)

	q, err := s.repo.QuestionWithOptions(ctx, questionID)
	if err != nil {
		return AdminQuestion{}, err
	}
	return toAdminQuestion(q), nil
}

// DeleteQuestion hard-deletes a question with no attempt history, or soft
// deactivates one that has been answered (spec §64, §66).
func (s *AdminService) DeleteQuestion(ctx context.Context, adminID, questionID int64) (DeleteResult, error) {
	cur, err := s.repo.GetQuestion(ctx, questionID)
	if err != nil {
		return DeleteResult{}, err
	}
	used, err := s.repo.QuestionHasHistory(ctx, questionID)
	if err != nil {
		return DeleteResult{}, err
	}
	if used {
		if err := s.repo.UpdateQuestion(ctx, questionID, map[string]any{"is_active": false}); err != nil {
			return DeleteResult{}, err
		}
		s.audit(ctx, adminID, "update", "quiz_question", questionID, "deactivated (has attempt history): "+cur.Text)
		return DeleteResult{Deactivated: true}, nil
	}
	if err := s.repo.DeleteQuestion(ctx, questionID); err != nil {
		return DeleteResult{}, err
	}
	s.audit(ctx, adminID, "delete", "quiz_question", questionID, cur.Text)
	return DeleteResult{Deleted: true}, nil
}

/* ================= options ================= */

func (s *AdminService) CreateOption(ctx context.Context, adminID, questionID int64, req CreateOptionRequest) (AdminOption, error) {
	q, err := s.repo.QuestionWithOptions(ctx, questionID)
	if err != nil {
		return AdminOption{}, err
	}
	text := strings.TrimSpace(req.OptionText)
	if text == "" {
		return AdminOption{}, invalid("optionText is required")
	}
	isCorrect := false
	if req.IsCorrect != nil {
		isCorrect = *req.IsCorrect
	}
	position := len(q.Options)
	if req.Position != nil {
		position = *req.Position
	}

	activeCount := 0
	activeCorrect := 0
	for _, o := range q.Options {
		if o.IsActive {
			activeCount++
			if o.IsCorrect {
				activeCorrect++
			}
		}
	}
	if q.Type == QuestionTrueFalse && activeCount >= 2 {
		return AdminOption{}, invalid("a true/false question already has its two options")
	}
	if isCorrect && (q.Type == QuestionSingleChoice || q.Type == QuestionTrueFalse) && activeCorrect >= 1 {
		return AdminOption{}, invalid("this question type allows only one correct option")
	}

	id, err := s.repo.CreateOption(ctx, questionID, text, isCorrect, position)
	if err != nil {
		return AdminOption{}, err
	}
	s.audit(ctx, adminID, "create", "quiz_option", id, text)
	o, err := s.repo.GetOption(ctx, id)
	if err != nil {
		return AdminOption{}, err
	}
	return toAdminOption(o), nil
}

func (s *AdminService) UpdateOption(ctx context.Context, adminID, optionID int64, req UpdateOptionRequest) (AdminOption, error) {
	cur, err := s.repo.GetOption(ctx, optionID)
	if err != nil {
		return AdminOption{}, err
	}
	q, err := s.repo.GetQuestion(ctx, cur.QuestionID)
	if err != nil {
		return AdminOption{}, err
	}

	fields := map[string]any{}
	if req.OptionText != nil {
		t := strings.TrimSpace(*req.OptionText)
		if t == "" {
			return AdminOption{}, invalid("optionText cannot be empty")
		}
		fields["option_text"] = t
	}
	if req.Position != nil {
		fields["position"] = *req.Position
	}
	if req.IsActive != nil {
		fields["is_active"] = *req.IsActive
	}
	if req.IsCorrect != nil {
		if *req.IsCorrect && (q.Type == QuestionSingleChoice || q.Type == QuestionTrueFalse) {
			others, err := s.repo.CountActiveCorrectOptions(ctx, cur.QuestionID, optionID)
			if err != nil {
				return AdminOption{}, err
			}
			if others >= 1 {
				return AdminOption{}, invalid("this question type allows only one correct option")
			}
		}
		fields["is_correct"] = *req.IsCorrect
	}
	if err := s.repo.UpdateOption(ctx, optionID, fields); err != nil {
		return AdminOption{}, err
	}
	s.audit(ctx, adminID, "update", "quiz_option", optionID, cur.Text)
	o, err := s.repo.GetOption(ctx, optionID)
	if err != nil {
		return AdminOption{}, err
	}
	return toAdminOption(o), nil
}

// DeleteOption hard-deletes an unreferenced option, or soft deactivates one
// that appears in attempt history (spec §65, §66).
func (s *AdminService) DeleteOption(ctx context.Context, adminID, optionID int64) (DeleteResult, error) {
	cur, err := s.repo.GetOption(ctx, optionID)
	if err != nil {
		return DeleteResult{}, err
	}
	used, err := s.repo.OptionHasHistory(ctx, optionID)
	if err != nil {
		return DeleteResult{}, err
	}
	if used {
		if err := s.repo.UpdateOption(ctx, optionID, map[string]any{"is_active": false}); err != nil {
			return DeleteResult{}, err
		}
		s.audit(ctx, adminID, "update", "quiz_option", optionID, "deactivated (has attempt history): "+cur.Text)
		return DeleteResult{Deactivated: true}, nil
	}
	if err := s.repo.DeleteOption(ctx, optionID); err != nil {
		return DeleteResult{}, err
	}
	s.audit(ctx, adminID, "delete", "quiz_option", optionID, cur.Text)
	return DeleteResult{Deleted: true}, nil
}

/* ================= mappers ================= */

func normStr(s *string) *string {
	if s == nil {
		return nil
	}
	t := strings.TrimSpace(*s)
	if t == "" {
		return nil
	}
	return &t
}

func toAdminOption(o Option) AdminOption {
	return AdminOption{
		ID:         o.ID,
		OptionText: o.Text,
		IsCorrect:  o.IsCorrect,
		Position:   o.Position,
		IsActive:   o.IsActive,
	}
}

func toAdminQuestion(q Question) AdminQuestion {
	out := AdminQuestion{
		ID:           q.ID,
		QuestionText: q.Text,
		QuestionType: q.Type,
		Points:       q.Points,
		Position:     q.Position,
		Explanation:  q.Explanation,
		IsActive:     q.IsActive,
		WellFormed:   q.wellFormed(),
		Options:      make([]AdminOption, 0, len(q.Options)),
	}
	for _, o := range q.Options {
		out.Options = append(out.Options, toAdminOption(o))
	}
	return out
}

func toAdminQuestions(qs []Question) []AdminQuestion {
	out := make([]AdminQuestion, 0, len(qs))
	for _, q := range qs {
		out = append(out, toAdminQuestion(q))
	}
	return out
}

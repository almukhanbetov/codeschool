package progress

import (
	"context"
	"errors"

	"codeschool/backend/internal/lessons"
)

// lessonResolver resolves a published lesson to its owning course.
// Satisfied by *lessons.Service.
type lessonResolver interface {
	CourseIDForLesson(ctx context.Context, lessonID int64) (int64, error)
}

// enrollmentChecker reports whether a student is actively enrolled.
// Satisfied by *enrollments.Service.
type enrollmentChecker interface {
	IsEnrolled(ctx context.Context, studentID, courseID int64) (bool, error)
}

// assignmentGate lists a lesson's published assignment ids.
// Satisfied by *assignments.Service.
type assignmentGate interface {
	PublishedIDsForLesson(ctx context.Context, lessonID int64) ([]int64, error)
}

// submissionGate counts a student's non-draft / passed submissions among a
// set of assignments. Satisfied by *submissions.Service.
type submissionGate interface {
	CountNonDraftForAssignments(ctx context.Context, studentID int64, assignmentIDs []int64) (int, error)
	CountPassedForAssignments(ctx context.Context, studentID int64, assignmentIDs []int64) (int, error)
}

// codeTestGate distinguishes test-graded `code` assignments (spec §7): a
// lesson with one can only be completed once the student has a *passing*
// auto-graded submission, like a quiz. Satisfied by *runs.Service.
type codeTestGate interface {
	AssignmentIDsWithTests(ctx context.Context, assignmentIDs []int64) ([]int64, error)
}

// quizGate distinguishes quiz assignments from the rest and reports how many
// of a set the student has passed. Satisfied by *quizzes.Service. Quiz
// assignments have no submissions row (spec §46), so lesson completion checks
// them via a passing attempt instead (spec §44, §45).
type quizGate interface {
	QuizAssignmentIDs(ctx context.Context, assignmentIDs []int64) ([]int64, error)
	CountPassedForAssignments(ctx context.Context, studentID int64, assignmentIDs []int64) (int, error)
}

type repository interface {
	Start(ctx context.Context, studentID, lessonID int64) (LessonProgress, error)
	CompleteLessonTx(ctx context.Context, studentID, lessonID, courseID int64) (CompleteResult, error)
	CourseCountsFor(ctx context.Context, studentID, courseID int64) (CourseCounts, error)
	SummaryForStudent(ctx context.Context, studentID int64) ([]CourseCounts, error)
	LessonProgressForCourse(ctx context.Context, studentID, courseID int64) ([]LessonProgress, error)
}

type enrollmentStatusReader interface {
	// StatusFor returns "active" / "completed" / "cancelled" / "" (none).
	StatusFor(ctx context.Context, studentID, courseID int64) (string, error)
}

type Service struct {
	repo        repository
	lessons     lessonResolver
	enroll      enrollmentChecker
	enrollState enrollmentStatusReader
	assignments assignmentGate
	submissions submissionGate
	quizzes     quizGate
	codeTests   codeTestGate
}

func NewService(
	repo repository,
	lessons lessonResolver,
	enroll enrollmentChecker,
	enrollState enrollmentStatusReader,
	assignments assignmentGate,
	submissions submissionGate,
	quizzes quizGate,
	codeTests codeTestGate,
) *Service {
	return &Service{
		repo:        repo,
		lessons:     lessons,
		enroll:      enroll,
		enrollState: enrollState,
		assignments: assignments,
		submissions: submissions,
		quizzes:     quizzes,
		codeTests:   codeTests,
	}
}

// resolveAndAuthorize resolves the lesson's course and confirms enrollment.
func (s *Service) resolveAndAuthorize(ctx context.Context, studentID, lessonID int64) (int64, error) {
	courseID, err := s.lessons.CourseIDForLesson(ctx, lessonID)
	if errors.Is(err, lessons.ErrNotFound) {
		return 0, ErrLessonNotFound
	}
	if err != nil {
		return 0, err
	}
	enrolled, err := s.enroll.IsEnrolled(ctx, studentID, courseID)
	if err != nil {
		return 0, err
	}
	if !enrolled {
		return 0, ErrNotEnrolled
	}
	return courseID, nil
}

// StartLesson marks a lesson in progress (idempotent).
func (s *Service) StartLesson(ctx context.Context, studentID, lessonID int64) (LessonProgressResponse, error) {
	if _, err := s.resolveAndAuthorize(ctx, studentID, lessonID); err != nil {
		return LessonProgressResponse{}, err
	}
	lp, err := s.repo.Start(ctx, studentID, lessonID)
	if err != nil {
		return LessonProgressResponse{}, err
	}
	return toLessonResponse(lp), nil
}

// CompleteLesson marks a lesson completed. If the lesson has published
// assignments, the student must have a non-draft submission for each one
// first (spec §21). Auto-completes the enrollment when the whole course is
// done.
func (s *Service) CompleteLesson(ctx context.Context, studentID, lessonID int64) (CompleteLessonResponse, error) {
	courseID, err := s.resolveAndAuthorize(ctx, studentID, lessonID)
	if err != nil {
		return CompleteLessonResponse{}, err
	}

	assignmentIDs, err := s.assignments.PublishedIDsForLesson(ctx, lessonID)
	if err != nil {
		return CompleteLessonResponse{}, err
	}
	if len(assignmentIDs) > 0 {
		quizIDs, err := s.quizzes.QuizAssignmentIDs(ctx, assignmentIDs)
		if err != nil {
			return CompleteLessonResponse{}, err
		}
		done := make(map[int64]bool, len(assignmentIDs))
		for _, id := range quizIDs {
			done[id] = true
		}

		// Test-graded `code` assignments behave like quizzes: a *passing*
		// auto-graded submission is required (spec §7).
		codeTestIDs, err := s.codeTests.AssignmentIDsWithTests(ctx, assignmentIDs)
		if err != nil {
			return CompleteLessonResponse{}, err
		}
		var testCodeNeeded []int64
		for _, id := range codeTestIDs {
			if !done[id] { // a quiz can't also be test-graded, but be safe
				testCodeNeeded = append(testCodeNeeded, id)
				done[id] = true
			}
		}

		var plainIDs []int64
		for _, id := range assignmentIDs {
			if !done[id] {
				plainIDs = append(plainIDs, id)
			}
		}

		// Plain assignments (text / code-without-tests / project): a non-draft
		// submission for each (unchanged, spec §21).
		if len(plainIDs) > 0 {
			n, err := s.submissions.CountNonDraftForAssignments(ctx, studentID, plainIDs)
			if err != nil {
				return CompleteLessonResponse{}, err
			}
			if n < len(plainIDs) {
				return CompleteLessonResponse{}, ErrAssignmentIncomplete
			}
		}
		// Test-graded code: a passing submission for each.
		if len(testCodeNeeded) > 0 {
			passed, err := s.submissions.CountPassedForAssignments(ctx, studentID, testCodeNeeded)
			if err != nil {
				return CompleteLessonResponse{}, err
			}
			if passed < len(testCodeNeeded) {
				return CompleteLessonResponse{}, ErrAssignmentIncomplete
			}
		}
		// Quiz assignments: at least one passing attempt for each (spec §45).
		if len(quizIDs) > 0 {
			passed, err := s.quizzes.CountPassedForAssignments(ctx, studentID, quizIDs)
			if err != nil {
				return CompleteLessonResponse{}, err
			}
			if passed < len(quizIDs) {
				return CompleteLessonResponse{}, ErrAssignmentIncomplete
			}
		}
	}

	res, err := s.repo.CompleteLessonTx(ctx, studentID, lessonID, courseID)
	if err != nil {
		return CompleteLessonResponse{}, err
	}
	return CompleteLessonResponse{
		Lesson:              toLessonResponse(res.Lesson),
		Course:              toCourseResponse(res.Course),
		EnrollmentCompleted: res.EnrollmentCompleted,
	}, nil
}

// MyProgress returns a progress row per enrolled course.
func (s *Service) MyProgress(ctx context.Context, studentID int64) ([]CourseProgressResponse, error) {
	rows, err := s.repo.SummaryForStudent(ctx, studentID)
	if err != nil {
		return nil, err
	}
	out := make([]CourseProgressResponse, 0, len(rows))
	for _, cc := range rows {
		out = append(out, toCourseResponse(cc))
	}
	return out, nil
}

// CourseProgress returns the course tally plus every published lesson's
// status — the learning page's data. Requires an enrollment (any status).
func (s *Service) CourseProgress(ctx context.Context, studentID, courseID int64) (CourseDetailResponse, error) {
	status, err := s.enrollState.StatusFor(ctx, studentID, courseID)
	if err != nil {
		return CourseDetailResponse{}, err
	}
	if status == "" {
		return CourseDetailResponse{}, ErrNotEnrolled
	}

	counts, err := s.repo.CourseCountsFor(ctx, studentID, courseID)
	if err != nil {
		return CourseDetailResponse{}, err
	}
	lessonRows, err := s.repo.LessonProgressForCourse(ctx, studentID, courseID)
	if err != nil {
		return CourseDetailResponse{}, err
	}

	lessonsOut := make([]LessonProgressResponse, 0, len(lessonRows))
	for _, lp := range lessonRows {
		lessonsOut = append(lessonsOut, toLessonResponse(lp))
	}

	return CourseDetailResponse{
		CourseProgressResponse: toCourseResponse(counts),
		EnrollmentStatus:       status,
		Lessons:                lessonsOut,
	}, nil
}

package submissions

import (
	"context"
	"errors"
	"strings"

	"codeschool/backend/internal/assignments"
)

// assignmentResolver resolves a published assignment to its owning course.
// Satisfied by *assignments.Service.
type assignmentResolver interface {
	ResolveForSubmission(ctx context.Context, assignmentID int64) (assignments.Assignment, int64, error)
}

// enrollmentChecker reports whether a student is actively enrolled.
// Satisfied by *enrollments.Service.
type enrollmentChecker interface {
	IsEnrolled(ctx context.Context, studentID, courseID int64) (bool, error)
}

// repository is the slice of *Repository the service needs.
type repository interface {
	Get(ctx context.Context, studentID, assignmentID int64) (Submission, error)
	GetByID(ctx context.Context, id int64) (Submission, error)
	Create(ctx context.Context, studentID, assignmentID int64, code, answer *string) (Submission, error)
	UpdateContent(ctx context.Context, id int64, code, answer *string) (Submission, error)
	MarkSubmitted(ctx context.Context, id int64) (Submission, error)
	StartReview(ctx context.Context, id int64) (Submission, error)
	ApplyReview(ctx context.Context, id int64, score *int, feedback *string, status string) (Submission, error)
	CountNonDraftForAssignments(ctx context.Context, studentID int64, assignmentIDs []int64) (int, error)
}

type Service struct {
	repo        repository
	assignments assignmentResolver
	enroll      enrollmentChecker
}

func NewService(repo repository, assignmentResolver assignmentResolver, enroll enrollmentChecker) *Service {
	return &Service{repo: repo, assignments: assignmentResolver, enroll: enroll}
}

// authorize resolves the assignment and confirms the caller is enrolled in
// the owning course. Every student-facing operation goes through it —
// guessing an assignment id is not enough.
func (s *Service) authorize(ctx context.Context, studentID, assignmentID int64) error {
	_, courseID, err := s.assignments.ResolveForSubmission(ctx, assignmentID)
	if errors.Is(err, assignments.ErrNotFound) {
		return ErrAssignmentNotFound
	}
	if err != nil {
		return err
	}
	enrolled, err := s.enroll.IsEnrolled(ctx, studentID, courseID)
	if err != nil {
		return err
	}
	if !enrolled {
		return ErrNotEnrolled
	}
	return nil
}

// SaveDraft creates or updates the student's submission content. Allowed
// while the submission is `draft` or `failed` (a revision); locked once it
// is `submitted` / `checking` / `passed`.
func (s *Service) SaveDraft(ctx context.Context, studentID, assignmentID int64, req UpsertRequest) (Response, error) {
	if err := s.authorize(ctx, studentID, assignmentID); err != nil {
		return Response{}, err
	}

	existing, err := s.repo.Get(ctx, studentID, assignmentID)
	if errors.Is(err, ErrNotFound) {
		created, cerr := s.repo.Create(ctx, studentID, assignmentID, req.Code, req.Answer)
		if cerr != nil {
			return Response{}, cerr
		}
		return toResponse(created), nil
	}
	if err != nil {
		return Response{}, err
	}
	if !isEditable(existing.Status) {
		return Response{}, ErrLocked
	}

	updated, err := s.repo.UpdateContent(ctx, existing.ID, req.Code, req.Answer)
	if err != nil {
		return Response{}, err
	}
	return toResponse(updated), nil
}

// Submit moves the student's submission to `submitted`: `draft → submitted`
// (first attempt) or `failed → submitted` (a resubmission, which clears the
// previous score/feedback/checked_at).
func (s *Service) Submit(ctx context.Context, studentID, assignmentID int64) (Response, error) {
	if err := s.authorize(ctx, studentID, assignmentID); err != nil {
		return Response{}, err
	}

	existing, err := s.repo.Get(ctx, studentID, assignmentID)
	if errors.Is(err, ErrNotFound) {
		return Response{}, ErrNothingToSubmit
	}
	if err != nil {
		return Response{}, err
	}
	if !isEditable(existing.Status) {
		return Response{}, ErrLocked
	}

	submitted, err := s.repo.MarkSubmitted(ctx, existing.ID)
	if err != nil {
		return Response{}, err
	}
	return toResponse(submitted), nil
}

// GetMine returns the student's own submission, or ErrNotFound.
func (s *Service) GetMine(ctx context.Context, studentID, assignmentID int64) (Response, error) {
	if err := s.authorize(ctx, studentID, assignmentID); err != nil {
		return Response{}, err
	}
	sub, err := s.repo.Get(ctx, studentID, assignmentID)
	if err != nil {
		return Response{}, err
	}
	return toResponse(sub), nil
}

// CountNonDraftForAssignments is used by the progress package's
// lesson-completion gate. No authorization — the caller already checked.
func (s *Service) CountNonDraftForAssignments(ctx context.Context, studentID int64, assignmentIDs []int64) (int, error) {
	return s.repo.CountNonDraftForAssignments(ctx, studentID, assignmentIDs)
}

/* ---- teacher review (ownership is checked by the groups package before
   these are called) ---------------------------------------------------- */

// TeacherStartReview moves a submission `submitted → checking`. It is a
// no-op (returns the row unchanged) if it is already `checking`; any other
// state → ErrNotReviewable.
func (s *Service) TeacherStartReview(ctx context.Context, submissionID int64) (Submission, error) {
	cur, err := s.repo.GetByID(ctx, submissionID)
	if err != nil {
		return Submission{}, err
	}
	switch cur.Status {
	case StatusChecking:
		return cur, nil
	case StatusSubmitted:
		return s.repo.StartReview(ctx, submissionID)
	default:
		return Submission{}, ErrNotReviewable
	}
}

// TeacherReview records the verdict. `status` must be `passed` or `failed`.
// Score must fall within the assignment's `points` (required when points > 0);
// feedback is required for `failed`.
func (s *Service) TeacherReview(ctx context.Context, submissionID int64, score *int, feedback string, status string) (Submission, error) {
	if status != StatusPassed && status != StatusFailed {
		return Submission{}, ErrInvalidReviewStatus
	}

	cur, err := s.repo.GetByID(ctx, submissionID)
	if err != nil {
		return Submission{}, err
	}
	if cur.Status != StatusSubmitted && cur.Status != StatusChecking {
		return Submission{}, ErrNotReviewable
	}

	assignment, _, err := s.assignments.ResolveForSubmission(ctx, cur.AssignmentID)
	if err != nil {
		return Submission{}, err
	}

	trimmedFeedback := strings.TrimSpace(feedback)
	if status == StatusFailed && trimmedFeedback == "" {
		return Submission{}, ErrFeedbackRequired
	}

	// Score rules: with points, a score is required and must be 0..points;
	// with points == 0, a score is optional but if given must be 0.
	if assignment.Points > 0 {
		if score == nil {
			return Submission{}, ErrScoreRequired
		}
		if *score < 0 || *score > assignment.Points {
			return Submission{}, ErrScoreOutOfRange
		}
	} else if score != nil && *score != 0 {
		return Submission{}, ErrScoreOutOfRange
	}

	var feedbackPtr *string
	if trimmedFeedback != "" {
		feedbackPtr = &trimmedFeedback
	}

	return s.repo.ApplyReview(ctx, submissionID, score, feedbackPtr, status)
}

// GetRawByID exposes a submission by id to the groups package (which has
// already verified the teacher owns it).
func (s *Service) GetRawByID(ctx context.Context, id int64) (Submission, error) {
	return s.repo.GetByID(ctx, id)
}

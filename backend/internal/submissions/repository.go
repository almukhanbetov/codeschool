package submissions

import (
	"context"
	"errors"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Repository struct {
	pool *pgxpool.Pool
}

func NewRepository(pool *pgxpool.Pool) *Repository {
	return &Repository{pool: pool}
}

const columns = `
	id, assignment_id, student_id, code, answer, status, score,
	teacher_feedback, submitted_at, checked_at, created_at, updated_at
`

// Get returns the student's submission for an assignment, or ErrNotFound.
func (r *Repository) Get(ctx context.Context, studentID, assignmentID int64) (Submission, error) {
	row := r.pool.QueryRow(ctx, `
		SELECT `+columns+`
		FROM submissions
		WHERE student_id = $1 AND assignment_id = $2
	`, studentID, assignmentID)

	s, err := scanSubmission(row)
	if errors.Is(err, pgx.ErrNoRows) {
		return Submission{}, ErrNotFound
	}
	if err != nil {
		return Submission{}, fmt.Errorf("get submission: %w", err)
	}
	return s, nil
}

// GetByID returns a submission by primary key (no ownership filter — the
// caller has already authorized). ErrNotFound if absent.
func (r *Repository) GetByID(ctx context.Context, id int64) (Submission, error) {
	row := r.pool.QueryRow(ctx, `SELECT `+columns+` FROM submissions WHERE id = $1`, id)
	s, err := scanSubmission(row)
	if errors.Is(err, pgx.ErrNoRows) {
		return Submission{}, ErrNotFound
	}
	if err != nil {
		return Submission{}, fmt.Errorf("get submission by id: %w", err)
	}
	return s, nil
}

// Create inserts a fresh draft.
func (r *Repository) Create(ctx context.Context, studentID, assignmentID int64, code, answer *string) (Submission, error) {
	row := r.pool.QueryRow(ctx, `
		INSERT INTO submissions (assignment_id, student_id, code, answer, status)
		VALUES ($1, $2, $3, $4, 'draft')
		RETURNING `+columns, assignmentID, studentID, code, answer)

	s, err := scanSubmission(row)
	if err != nil {
		return Submission{}, fmt.Errorf("insert submission: %w", err)
	}
	return s, nil
}

// UpdateContent overwrites the code/answer of an editable submission
// (`draft` or `failed`). 0 rows → ErrLocked.
func (r *Repository) UpdateContent(ctx context.Context, id int64, code, answer *string) (Submission, error) {
	row := r.pool.QueryRow(ctx, `
		UPDATE submissions
		SET code = $2, answer = $3, updated_at = NOW()
		WHERE id = $1 AND status IN ('draft', 'failed')
		RETURNING `+columns, id, code, answer)

	s, err := scanSubmission(row)
	if errors.Is(err, pgx.ErrNoRows) {
		return Submission{}, ErrLocked
	}
	if err != nil {
		return Submission{}, fmt.Errorf("update submission content: %w", err)
	}
	return s, nil
}

// MarkSubmitted moves an editable submission (`draft` or `failed`) to
// `submitted`, stamping submitted_at and **clearing any previous review**
// (score / feedback / checked_at) — a resubmission starts a clean review.
// 0 rows → ErrLocked.
func (r *Repository) MarkSubmitted(ctx context.Context, id int64) (Submission, error) {
	row := r.pool.QueryRow(ctx, `
		UPDATE submissions
		SET status = 'submitted',
		    submitted_at = NOW(),
		    score = NULL,
		    teacher_feedback = NULL,
		    checked_at = NULL,
		    updated_at = NOW()
		WHERE id = $1 AND status IN ('draft', 'failed')
		RETURNING `+columns, id)

	s, err := scanSubmission(row)
	if errors.Is(err, pgx.ErrNoRows) {
		return Submission{}, ErrLocked
	}
	if err != nil {
		return Submission{}, fmt.Errorf("mark submitted: %w", err)
	}
	return s, nil
}

// StartReview moves `submitted` → `checking`. 0 rows → ErrNotReviewable
// (unless it is already `checking`, which the service treats as a no-op).
func (r *Repository) StartReview(ctx context.Context, id int64) (Submission, error) {
	row := r.pool.QueryRow(ctx, `
		UPDATE submissions
		SET status = 'checking', updated_at = NOW()
		WHERE id = $1 AND status = 'submitted'
		RETURNING `+columns, id)

	s, err := scanSubmission(row)
	if errors.Is(err, pgx.ErrNoRows) {
		return Submission{}, ErrNotReviewable
	}
	if err != nil {
		return Submission{}, fmt.Errorf("start review: %w", err)
	}
	return s, nil
}

// ApplyReview writes the teacher's verdict. Accepts a submission that is
// `submitted` or `checking`; 0 rows → ErrNotReviewable.
func (r *Repository) ApplyReview(ctx context.Context, id int64, score *int, feedback *string, status string) (Submission, error) {
	row := r.pool.QueryRow(ctx, `
		UPDATE submissions
		SET status = $2, score = $3, teacher_feedback = $4,
		    checked_at = NOW(), updated_at = NOW()
		WHERE id = $1 AND status IN ('submitted', 'checking')
		RETURNING `+columns, id, status, score, feedback)

	s, err := scanSubmission(row)
	if errors.Is(err, pgx.ErrNoRows) {
		return Submission{}, ErrNotReviewable
	}
	if err != nil {
		return Submission{}, fmt.Errorf("apply review: %w", err)
	}
	return s, nil
}

// CountNonDraftForAssignments counts how many of the given assignments the
// student has a non-draft submission for — the lesson-completion gate. A
// `failed` submission still counts (they DID submit; spec §31 keeps the
// lesson complete).
func (r *Repository) CountNonDraftForAssignments(ctx context.Context, studentID int64, assignmentIDs []int64) (int, error) {
	if len(assignmentIDs) == 0 {
		return 0, nil
	}
	var n int
	err := r.pool.QueryRow(ctx, `
		SELECT count(*) FROM submissions
		WHERE student_id = $1 AND assignment_id = ANY($2) AND status <> 'draft'
	`, studentID, assignmentIDs).Scan(&n)
	if err != nil {
		return 0, fmt.Errorf("count non-draft submissions: %w", err)
	}
	return n, nil
}

type rowScanner interface {
	Scan(dest ...any) error
}

func scanSubmission(row rowScanner) (Submission, error) {
	var s Submission
	err := row.Scan(
		&s.ID, &s.AssignmentID, &s.StudentID, &s.Code, &s.Answer, &s.Status, &s.Score,
		&s.TeacherFeedback, &s.SubmittedAt, &s.CheckedAt, &s.CreatedAt, &s.UpdatedAt,
	)
	return s, err
}

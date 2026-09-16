package enrollments

import (
	"context"
	"errors"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Repository struct {
	pool *pgxpool.Pool
}

func NewRepository(pool *pgxpool.Pool) *Repository {
	return &Repository{pool: pool}
}

const columns = `id, student_id, course_id, status, enrolled_at, completed_at, created_at, updated_at`

// Create inserts a new active enrollment. A partial-unique-index violation
// (an existing active enrollment for the same student+course) becomes
// ErrAlreadyEnrolled.
func (r *Repository) Create(ctx context.Context, studentID, courseID int64) (Enrollment, error) {
	row := r.pool.QueryRow(ctx, `
		INSERT INTO enrollments (student_id, course_id, status)
		VALUES ($1, $2, 'active')
		RETURNING `+columns, studentID, courseID)

	e, err := scanEnrollment(row)
	if err != nil {
		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) && pgErr.Code == "23505" {
			return Enrollment{}, ErrAlreadyEnrolled
		}
		return Enrollment{}, fmt.Errorf("insert enrollment: %w", err)
	}
	return e, nil
}

// GetActive returns the student's active enrollment for a course, or
// ErrNotFound.
func (r *Repository) GetActive(ctx context.Context, studentID, courseID int64) (Enrollment, error) {
	row := r.pool.QueryRow(ctx, `
		SELECT `+columns+`
		FROM enrollments
		WHERE student_id = $1 AND course_id = $2 AND status = 'active'
	`, studentID, courseID)

	e, err := scanEnrollment(row)
	if errors.Is(err, pgx.ErrNoRows) {
		return Enrollment{}, ErrNotFound
	}
	if err != nil {
		return Enrollment{}, fmt.Errorf("get active enrollment: %w", err)
	}
	return e, nil
}

// HasActive reports whether the student currently has course access — an
// 'active' or 'completed' enrollment. A student who has finished a course
// keeps read/practice access to its lessons, quizzes and code assignments;
// only an explicitly 'cancelled' enrollment (or no enrollment at all) denies
// access. (Named HasActive for the pre-existing interface/call sites; a
// rename would touch every consumer package for no behavioral reason.)
func (r *Repository) HasActive(ctx context.Context, studentID, courseID int64) (bool, error) {
	var exists bool
	err := r.pool.QueryRow(ctx, `
		SELECT EXISTS (
			SELECT 1 FROM enrollments
			WHERE student_id = $1 AND course_id = $2 AND status <> 'cancelled'
		)
	`, studentID, courseID).Scan(&exists)
	if err != nil {
		return false, fmt.Errorf("check course access: %w", err)
	}
	return exists, nil
}

// StatusFor returns the most relevant enrollment status for a student+course
// ('active' wins, otherwise the newest), or "" if there is none.
func (r *Repository) StatusFor(ctx context.Context, studentID, courseID int64) (string, error) {
	var status string
	err := r.pool.QueryRow(ctx, `
		SELECT status FROM enrollments
		WHERE student_id = $1 AND course_id = $2
		ORDER BY (status = 'active') DESC, enrolled_at DESC
		LIMIT 1
	`, studentID, courseID).Scan(&status)
	if errors.Is(err, pgx.ErrNoRows) {
		return "", nil
	}
	if err != nil {
		return "", fmt.Errorf("enrollment status: %w", err)
	}
	return status, nil
}

// ListByStudent returns every enrollment for a student, newest first.
func (r *Repository) ListByStudent(ctx context.Context, studentID int64) ([]Enrollment, error) {
	rows, err := r.pool.Query(ctx, `
		SELECT `+columns+`
		FROM enrollments
		WHERE student_id = $1
		ORDER BY enrolled_at DESC, id DESC
	`, studentID)
	if err != nil {
		return nil, fmt.Errorf("list enrollments: %w", err)
	}
	defer rows.Close()

	var out []Enrollment
	for rows.Next() {
		e, err := scanEnrollment(rows)
		if err != nil {
			return nil, fmt.Errorf("scan enrollment: %w", err)
		}
		out = append(out, e)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate enrollments: %w", err)
	}
	return out, nil
}

type rowScanner interface {
	Scan(dest ...any) error
}

func scanEnrollment(row rowScanner) (Enrollment, error) {
	var e Enrollment
	err := row.Scan(
		&e.ID, &e.StudentID, &e.CourseID, &e.Status,
		&e.EnrolledAt, &e.CompletedAt, &e.CreatedAt, &e.UpdatedAt,
	)
	return e, err
}

package assignments

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
	id, lesson_id, title, description, assignment_type, starter_code,
	expected_output, language, points, position, is_published, created_at, updated_at
`

// ListPublishedByLesson returns the published assignments for a lesson,
// ordered by position.
func (r *Repository) ListPublishedByLesson(ctx context.Context, lessonID int64) ([]Assignment, error) {
	rows, err := r.pool.Query(ctx, `
		SELECT `+columns+`
		FROM assignments
		WHERE lesson_id = $1 AND is_published = TRUE
		ORDER BY position ASC, id ASC
	`, lessonID)
	if err != nil {
		return nil, fmt.Errorf("query assignments: %w", err)
	}
	defer rows.Close()

	var out []Assignment
	for rows.Next() {
		a, err := scanAssignment(rows)
		if err != nil {
			return nil, fmt.Errorf("scan assignment: %w", err)
		}
		out = append(out, a)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate assignments: %w", err)
	}
	return out, nil
}

// PublishedIDsByLesson returns just the ids of a lesson's published
// assignments — used by the lesson-completion gate.
func (r *Repository) PublishedIDsByLesson(ctx context.Context, lessonID int64) ([]int64, error) {
	rows, err := r.pool.Query(ctx, `
		SELECT id FROM assignments
		WHERE lesson_id = $1 AND is_published = TRUE
	`, lessonID)
	if err != nil {
		return nil, fmt.Errorf("query assignment ids: %w", err)
	}
	defer rows.Close()

	var out []int64
	for rows.Next() {
		var id int64
		if err := rows.Scan(&id); err != nil {
			return nil, fmt.Errorf("scan assignment id: %w", err)
		}
		out = append(out, id)
	}
	return out, rows.Err()
}

// GetPublishedByID returns one published assignment (whose lesson is also
// published) plus the id of the course that owns it. ErrNotFound covers
// "assignment missing", "assignment unpublished" and "lesson unpublished" —
// the caller never learns which.
func (r *Repository) GetPublishedByID(ctx context.Context, id int64) (Assignment, int64, error) {
	row := r.pool.QueryRow(ctx, `
		SELECT
			a.id, a.lesson_id, a.title, a.description, a.assignment_type, a.starter_code,
			a.expected_output, a.language, a.points, a.position, a.is_published, a.created_at, a.updated_at,
			m.course_id
		FROM assignments a
		JOIN lessons l ON l.id = a.lesson_id
		JOIN modules m ON m.id = l.module_id
		WHERE a.id = $1 AND a.is_published = TRUE AND l.is_published = TRUE
	`, id)

	var a Assignment
	var courseID int64
	err := row.Scan(
		&a.ID, &a.LessonID, &a.Title, &a.Description, &a.AssignmentType, &a.StarterCode,
		&a.ExpectedOutput, &a.Language, &a.Points, &a.Position, &a.IsPublished, &a.CreatedAt, &a.UpdatedAt,
		&courseID,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return Assignment{}, 0, ErrNotFound
	}
	if err != nil {
		return Assignment{}, 0, fmt.Errorf("get assignment: %w", err)
	}
	return a, courseID, nil
}

type rowScanner interface {
	Scan(dest ...any) error
}

func scanAssignment(row rowScanner) (Assignment, error) {
	var a Assignment
	err := row.Scan(
		&a.ID, &a.LessonID, &a.Title, &a.Description, &a.AssignmentType, &a.StarterCode,
		&a.ExpectedOutput, &a.Language, &a.Points, &a.Position, &a.IsPublished, &a.CreatedAt, &a.UpdatedAt,
	)
	return a, err
}

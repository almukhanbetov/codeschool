package lessons

import (
	"context"
	"errors"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var ErrNotFound = errors.New("lesson not found")

type Repository struct {
	pool *pgxpool.Pool
}

func NewRepository(pool *pgxpool.Pool) *Repository {
	return &Repository{pool: pool}
}

const columns = `
	id, module_id, title, slug, description, content, video_url,
	lesson_type, position, is_published, created_at, updated_at
`

// ListByModuleID returns only published lessons for a module — this is a
// public, unauthenticated endpoint.
func (r *Repository) ListByModuleID(ctx context.Context, moduleID int64) ([]Lesson, error) {
	rows, err := r.pool.Query(ctx, `
		SELECT `+columns+`
		FROM lessons
		WHERE module_id = $1 AND is_published = TRUE
		ORDER BY position ASC, id ASC
	`, moduleID)
	if err != nil {
		return nil, fmt.Errorf("query lessons: %w", err)
	}
	defer rows.Close()

	var out []Lesson
	for rows.Next() {
		l, err := scanLesson(rows)
		if err != nil {
			return nil, fmt.Errorf("scan lesson: %w", err)
		}
		out = append(out, l)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate lessons: %w", err)
	}
	return out, nil
}

func (r *Repository) GetByID(ctx context.Context, id int64) (Lesson, error) {
	row := r.pool.QueryRow(ctx, `
		SELECT `+columns+`
		FROM lessons
		WHERE id = $1 AND is_published = TRUE
	`, id)

	l, err := scanLesson(row)
	if errors.Is(err, pgx.ErrNoRows) {
		return Lesson{}, ErrNotFound
	}
	if err != nil {
		return Lesson{}, fmt.Errorf("get lesson by id: %w", err)
	}
	return l, nil
}

// ModuleCourseTeacherOnly reports whether the course that owns the given
// module targets teachers exclusively (audience = 'teacher'). A missing
// module reports false. Used to hide Teacher Academy content from the
// public GET /modules/:id/lessons endpoint.
func (r *Repository) ModuleCourseTeacherOnly(ctx context.Context, moduleID int64) (bool, error) {
	var teacherOnly bool
	err := r.pool.QueryRow(ctx, `
		SELECT COALESCE(bool_or(c.audience = 'teacher'), FALSE)
		FROM modules m
		JOIN courses c ON c.id = m.course_id
		WHERE m.id = $1
	`, moduleID).Scan(&teacherOnly)
	if err != nil {
		return false, fmt.Errorf("module course audience: %w", err)
	}
	return teacherOnly, nil
}

// LessonCourseTeacherOnly reports whether the course that owns the given
// lesson (via its module) targets teachers exclusively. A missing lesson
// reports false. Used to hide Teacher Academy content from the public
// GET /lessons/:id endpoint.
func (r *Repository) LessonCourseTeacherOnly(ctx context.Context, lessonID int64) (bool, error) {
	var teacherOnly bool
	err := r.pool.QueryRow(ctx, `
		SELECT COALESCE(bool_or(c.audience = 'teacher'), FALSE)
		FROM lessons l
		JOIN modules m ON m.id = l.module_id
		JOIN courses c ON c.id = m.course_id
		WHERE l.id = $1
	`, lessonID).Scan(&teacherOnly)
	if err != nil {
		return false, fmt.Errorf("lesson course audience: %w", err)
	}
	return teacherOnly, nil
}

// CourseIDByLessonID resolves the owning course of a published lesson (via
// its module). ErrNotFound if the lesson is missing or unpublished — used by
// the student-flow packages to authorize by enrollment without importing the
// modules package.
func (r *Repository) CourseIDByLessonID(ctx context.Context, lessonID int64) (int64, error) {
	var courseID int64
	err := r.pool.QueryRow(ctx, `
		SELECT m.course_id
		FROM lessons l
		JOIN modules m ON m.id = l.module_id
		WHERE l.id = $1 AND l.is_published = TRUE
	`, lessonID).Scan(&courseID)
	if errors.Is(err, pgx.ErrNoRows) {
		return 0, ErrNotFound
	}
	if err != nil {
		return 0, fmt.Errorf("resolve course for lesson: %w", err)
	}
	return courseID, nil
}

type rowScanner interface {
	Scan(dest ...any) error
}

func scanLesson(row rowScanner) (Lesson, error) {
	var l Lesson
	err := row.Scan(
		&l.ID, &l.ModuleID, &l.Title, &l.Slug, &l.Description, &l.Content, &l.VideoURL,
		&l.LessonType, &l.Position, &l.IsPublished, &l.CreatedAt, &l.UpdatedAt,
	)
	return l, err
}

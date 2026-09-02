package courses

import (
	"context"
	"errors"
	"fmt"
	"strings"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var ErrNotFound = errors.New("course not found")

type Repository struct {
	pool *pgxpool.Pool
}

func NewRepository(pool *pgxpool.Pool) *Repository {
	return &Repository{pool: pool}
}

const columns = `
	id, level_id, title, slug, description, short_description, image_url,
	age_from, age_to, duration_lessons, projects_count, difficulty,
	is_published, position, created_at, updated_at
`

// List returns published courses matching the optional filter, ordered by
// position. Age filtering is an overlap check: a course matches if its own
// [age_from, age_to] range overlaps the requested one.
func (r *Repository) List(ctx context.Context, filter ListFilter) ([]Course, error) {
	query := `SELECT ` + columns + ` FROM courses WHERE is_published = TRUE`
	var args []any

	if filter.LevelID != nil {
		args = append(args, *filter.LevelID)
		query += fmt.Sprintf(" AND level_id = $%d", len(args))
	}
	if filter.AgeTo != nil {
		args = append(args, *filter.AgeTo)
		query += fmt.Sprintf(" AND (age_from IS NULL OR age_from <= $%d)", len(args))
	}
	if filter.AgeFrom != nil {
		args = append(args, *filter.AgeFrom)
		query += fmt.Sprintf(" AND (age_to IS NULL OR age_to >= $%d)", len(args))
	}

	query += " ORDER BY position ASC, id ASC"

	rows, err := r.pool.Query(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("query courses: %w", err)
	}
	defer rows.Close()

	var out []Course
	for rows.Next() {
		c, err := scanCourse(rows)
		if err != nil {
			return nil, fmt.Errorf("scan course: %w", err)
		}
		out = append(out, c)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate courses: %w", err)
	}
	return out, nil
}

func (r *Repository) GetByID(ctx context.Context, id int64) (Course, error) {
	return r.getOne(ctx, "id = $1", id)
}

// ListByIDs returns the published courses among the given ids, in no
// particular order. Used to hydrate a student's "my courses" list.
func (r *Repository) ListByIDs(ctx context.Context, ids []int64) ([]Course, error) {
	if len(ids) == 0 {
		return nil, nil
	}
	rows, err := r.pool.Query(ctx, `
		SELECT `+columns+`
		FROM courses
		WHERE is_published = TRUE AND id = ANY($1)
	`, ids)
	if err != nil {
		return nil, fmt.Errorf("query courses by ids: %w", err)
	}
	defer rows.Close()

	var out []Course
	for rows.Next() {
		c, err := scanCourse(rows)
		if err != nil {
			return nil, fmt.Errorf("scan course: %w", err)
		}
		out = append(out, c)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate courses: %w", err)
	}
	return out, nil
}

func (r *Repository) GetBySlug(ctx context.Context, slug string) (Course, error) {
	return r.getOne(ctx, "slug = $1", slug)
}

func (r *Repository) getOne(ctx context.Context, predicate string, arg any) (Course, error) {
	row := r.pool.QueryRow(ctx, `
		SELECT `+columns+`
		FROM courses
		WHERE is_published = TRUE AND `+strings.TrimSpace(predicate)+`
	`, arg)

	c, err := scanCourse(row)
	if errors.Is(err, pgx.ErrNoRows) {
		return Course{}, ErrNotFound
	}
	if err != nil {
		return Course{}, fmt.Errorf("get course: %w", err)
	}
	return c, nil
}

type rowScanner interface {
	Scan(dest ...any) error
}

func scanCourse(row rowScanner) (Course, error) {
	var c Course
	err := row.Scan(
		&c.ID, &c.LevelID, &c.Title, &c.Slug, &c.Description, &c.ShortDescription, &c.ImageURL,
		&c.AgeFrom, &c.AgeTo, &c.DurationLessons, &c.ProjectsCount, &c.Difficulty,
		&c.IsPublished, &c.Position, &c.CreatedAt, &c.UpdatedAt,
	)
	return c, err
}

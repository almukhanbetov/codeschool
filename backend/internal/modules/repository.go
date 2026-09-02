package modules

import (
	"context"
	"errors"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var ErrNotFound = errors.New("module not found")

type Repository struct {
	pool *pgxpool.Pool
}

func NewRepository(pool *pgxpool.Pool) *Repository {
	return &Repository{pool: pool}
}

const columns = `id, course_id, title, description, position, created_at, updated_at`

func (r *Repository) ListByCourseID(ctx context.Context, courseID int64) ([]Module, error) {
	rows, err := r.pool.Query(ctx, `
		SELECT `+columns+`
		FROM modules
		WHERE course_id = $1
		ORDER BY position ASC, id ASC
	`, courseID)
	if err != nil {
		return nil, fmt.Errorf("query modules: %w", err)
	}
	defer rows.Close()

	var out []Module
	for rows.Next() {
		m, err := scanModule(rows)
		if err != nil {
			return nil, fmt.Errorf("scan module: %w", err)
		}
		out = append(out, m)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate modules: %w", err)
	}
	return out, nil
}

func (r *Repository) GetByID(ctx context.Context, id int64) (Module, error) {
	row := r.pool.QueryRow(ctx, `
		SELECT `+columns+`
		FROM modules
		WHERE id = $1
	`, id)

	m, err := scanModule(row)
	if errors.Is(err, pgx.ErrNoRows) {
		return Module{}, ErrNotFound
	}
	if err != nil {
		return Module{}, fmt.Errorf("get module by id: %w", err)
	}
	return m, nil
}

type rowScanner interface {
	Scan(dest ...any) error
}

func scanModule(row rowScanner) (Module, error) {
	var m Module
	err := row.Scan(&m.ID, &m.CourseID, &m.Title, &m.Description, &m.Position, &m.CreatedAt, &m.UpdatedAt)
	return m, err
}

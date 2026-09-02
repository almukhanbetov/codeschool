package programs

import (
	"context"
	"errors"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var ErrNotFound = errors.New("program not found")

type Repository struct {
	pool *pgxpool.Pool
}

func NewRepository(pool *pgxpool.Pool) *Repository {
	return &Repository{pool: pool}
}

const listColumns = `id, title, slug, description, age_from, age_to, is_active, created_at, updated_at`

func (r *Repository) List(ctx context.Context) ([]Program, error) {
	rows, err := r.pool.Query(ctx, `
		SELECT `+listColumns+`
		FROM programs
		WHERE is_active = TRUE
		ORDER BY title ASC
	`)
	if err != nil {
		return nil, fmt.Errorf("query programs: %w", err)
	}
	defer rows.Close()

	var out []Program
	for rows.Next() {
		p, err := scanProgram(rows)
		if err != nil {
			return nil, fmt.Errorf("scan program: %w", err)
		}
		out = append(out, p)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate programs: %w", err)
	}
	return out, nil
}

func (r *Repository) GetByID(ctx context.Context, id int64) (Program, error) {
	row := r.pool.QueryRow(ctx, `
		SELECT `+listColumns+`
		FROM programs
		WHERE id = $1 AND is_active = TRUE
	`, id)

	p, err := scanProgram(row)
	if errors.Is(err, pgx.ErrNoRows) {
		return Program{}, ErrNotFound
	}
	if err != nil {
		return Program{}, fmt.Errorf("get program by id: %w", err)
	}
	return p, nil
}

type rowScanner interface {
	Scan(dest ...any) error
}

func scanProgram(row rowScanner) (Program, error) {
	var p Program
	err := row.Scan(&p.ID, &p.Title, &p.Slug, &p.Description, &p.AgeFrom, &p.AgeTo, &p.IsActive, &p.CreatedAt, &p.UpdatedAt)
	return p, err
}

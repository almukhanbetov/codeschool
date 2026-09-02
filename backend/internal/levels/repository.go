package levels

import (
	"context"
	"errors"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var ErrNotFound = errors.New("level not found")

type Repository struct {
	pool *pgxpool.Pool
}

func NewRepository(pool *pgxpool.Pool) *Repository {
	return &Repository{pool: pool}
}

const columns = `id, program_id, title, description, age_from, age_to, position, created_at, updated_at`

func (r *Repository) ListByProgramID(ctx context.Context, programID int64) ([]Level, error) {
	rows, err := r.pool.Query(ctx, `
		SELECT `+columns+`
		FROM levels
		WHERE program_id = $1
		ORDER BY position ASC, id ASC
	`, programID)
	if err != nil {
		return nil, fmt.Errorf("query levels: %w", err)
	}
	defer rows.Close()

	var out []Level
	for rows.Next() {
		l, err := scanLevel(rows)
		if err != nil {
			return nil, fmt.Errorf("scan level: %w", err)
		}
		out = append(out, l)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate levels: %w", err)
	}
	return out, nil
}

func (r *Repository) GetByID(ctx context.Context, id int64) (Level, error) {
	row := r.pool.QueryRow(ctx, `
		SELECT `+columns+`
		FROM levels
		WHERE id = $1
	`, id)

	l, err := scanLevel(row)
	if errors.Is(err, pgx.ErrNoRows) {
		return Level{}, ErrNotFound
	}
	if err != nil {
		return Level{}, fmt.Errorf("get level by id: %w", err)
	}
	return l, nil
}

type rowScanner interface {
	Scan(dest ...any) error
}

func scanLevel(row rowScanner) (Level, error) {
	var l Level
	err := row.Scan(&l.ID, &l.ProgramID, &l.Title, &l.Description, &l.AgeFrom, &l.AgeTo, &l.Position, &l.CreatedAt, &l.UpdatedAt)
	return l, err
}

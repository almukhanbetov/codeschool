package users

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

const userColumns = `
	id, email, phone, password_hash, first_name, last_name, role, is_active,
	created_at, updated_at
`

// CreateUser inserts a user and returns it with its generated id. A partial
// unique index violation is translated into ErrDuplicateEmail /
// ErrDuplicatePhone by constraint name.
func (r *Repository) CreateUser(ctx context.Context, in NewUser) (User, error) {
	row := r.pool.QueryRow(ctx, `
		INSERT INTO users (email, phone, password_hash, first_name, last_name, role)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING `+userColumns, in.Email, in.Phone, in.PasswordHash, in.FirstName, in.LastName, in.Role)

	u, err := scanUser(row)
	if err != nil {
		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) && pgErr.Code == "23505" {
			switch pgErr.ConstraintName {
			case "idx_users_email_unique":
				return User{}, ErrDuplicateEmail
			case "idx_users_phone_unique":
				return User{}, ErrDuplicatePhone
			}
		}
		return User{}, fmt.Errorf("insert user: %w", err)
	}
	return u, nil
}

func (r *Repository) GetUserByID(ctx context.Context, id int64) (User, error) {
	return r.getOne(ctx, "id = $1", id)
}

// GetUserByEmail matches case-insensitively, mirroring the unique index on
// lower(email).
func (r *Repository) GetUserByEmail(ctx context.Context, email string) (User, error) {
	return r.getOne(ctx, "lower(email) = lower($1)", email)
}

func (r *Repository) GetUserByPhone(ctx context.Context, phone string) (User, error) {
	return r.getOne(ctx, "phone = $1", phone)
}

func (r *Repository) getOne(ctx context.Context, predicate string, arg any) (User, error) {
	row := r.pool.QueryRow(ctx, `SELECT `+userColumns+` FROM users WHERE `+predicate, arg)
	u, err := scanUser(row)
	if errors.Is(err, pgx.ErrNoRows) {
		return User{}, ErrNotFound
	}
	if err != nil {
		return User{}, fmt.Errorf("get user: %w", err)
	}
	return u, nil
}

type rowScanner interface {
	Scan(dest ...any) error
}

func scanUser(row rowScanner) (User, error) {
	var u User
	err := row.Scan(
		&u.ID, &u.Email, &u.Phone, &u.PasswordHash, &u.FirstName, &u.LastName,
		&u.Role, &u.IsActive, &u.CreatedAt, &u.UpdatedAt,
	)
	return u, err
}

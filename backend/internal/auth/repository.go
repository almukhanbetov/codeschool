package auth

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// ErrRefreshNotFound is returned when no refresh_tokens row matches a hash.
var ErrRefreshNotFound = errors.New("refresh token not found")

type Repository struct {
	pool *pgxpool.Pool
}

func NewRepository(pool *pgxpool.Pool) *Repository {
	return &Repository{pool: pool}
}

const refreshColumns = `id, user_id, token_hash, expires_at, revoked_at, created_at`

// CreateRefreshToken inserts a new refresh token row.
func (r *Repository) CreateRefreshToken(ctx context.Context, userID int64, tokenHash string, expiresAt time.Time) (RefreshToken, error) {
	row := r.pool.QueryRow(ctx, `
		INSERT INTO refresh_tokens (user_id, token_hash, expires_at)
		VALUES ($1, $2, $3)
		RETURNING `+refreshColumns, userID, tokenHash, expiresAt)
	rt, err := scanRefreshToken(row)
	if err != nil {
		return RefreshToken{}, fmt.Errorf("insert refresh token: %w", err)
	}
	return rt, nil
}

// GetRefreshTokenByHash looks up a token by its SHA-256 digest.
func (r *Repository) GetRefreshTokenByHash(ctx context.Context, tokenHash string) (RefreshToken, error) {
	row := r.pool.QueryRow(ctx, `SELECT `+refreshColumns+` FROM refresh_tokens WHERE token_hash = $1`, tokenHash)
	rt, err := scanRefreshToken(row)
	if errors.Is(err, pgx.ErrNoRows) {
		return RefreshToken{}, ErrRefreshNotFound
	}
	if err != nil {
		return RefreshToken{}, fmt.Errorf("get refresh token: %w", err)
	}
	return rt, nil
}

// RevokeRefreshToken sets revoked_at = NOW() for the row with this hash, if
// it is not already revoked. It is idempotent: revoking an already-revoked
// (or missing) token is not an error.
func (r *Repository) RevokeRefreshToken(ctx context.Context, tokenHash string) error {
	_, err := r.pool.Exec(ctx, `
		UPDATE refresh_tokens
		SET revoked_at = NOW()
		WHERE token_hash = $1 AND revoked_at IS NULL`, tokenHash)
	if err != nil {
		return fmt.Errorf("revoke refresh token: %w", err)
	}
	return nil
}

// RotateRefreshToken atomically revokes the old token (by hash) and inserts a
// new one for the same user. Both happen in a single transaction so a
// crash can never leave the user with zero usable tokens or two.
func (r *Repository) RotateRefreshToken(ctx context.Context, oldHash string, userID int64, newHash string, newExpiresAt time.Time) (RefreshToken, error) {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return RefreshToken{}, fmt.Errorf("begin rotate tx: %w", err)
	}
	defer tx.Rollback(ctx) //nolint:errcheck // rollback after a committed tx is a no-op

	tag, err := tx.Exec(ctx, `
		UPDATE refresh_tokens
		SET revoked_at = NOW()
		WHERE token_hash = $1 AND revoked_at IS NULL`, oldHash)
	if err != nil {
		return RefreshToken{}, fmt.Errorf("revoke during rotate: %w", err)
	}
	if tag.RowsAffected() == 0 {
		// The token was revoked or removed between the service's check and
		// now — treat as a failed rotation (possible token reuse).
		return RefreshToken{}, ErrInvalidRefreshToken
	}

	row := tx.QueryRow(ctx, `
		INSERT INTO refresh_tokens (user_id, token_hash, expires_at)
		VALUES ($1, $2, $3)
		RETURNING `+refreshColumns, userID, newHash, newExpiresAt)
	rt, err := scanRefreshToken(row)
	if err != nil {
		return RefreshToken{}, fmt.Errorf("insert during rotate: %w", err)
	}

	if err := tx.Commit(ctx); err != nil {
		return RefreshToken{}, fmt.Errorf("commit rotate tx: %w", err)
	}
	return rt, nil
}

// DeleteExpiredRefreshTokens removes tokens that are past expiry or were
// revoked more than a day ago. Provided for a future cleanup job — nothing
// calls it on a schedule yet.
func (r *Repository) DeleteExpiredRefreshTokens(ctx context.Context) (int64, error) {
	tag, err := r.pool.Exec(ctx, `
		DELETE FROM refresh_tokens
		WHERE expires_at < NOW()
		   OR (revoked_at IS NOT NULL AND revoked_at < NOW() - INTERVAL '1 day')`)
	if err != nil {
		return 0, fmt.Errorf("delete expired refresh tokens: %w", err)
	}
	return tag.RowsAffected(), nil
}

type rowScanner interface {
	Scan(dest ...any) error
}

func scanRefreshToken(row rowScanner) (RefreshToken, error) {
	var rt RefreshToken
	err := row.Scan(&rt.ID, &rt.UserID, &rt.TokenHash, &rt.ExpiresAt, &rt.RevokedAt, &rt.CreatedAt)
	return rt, err
}

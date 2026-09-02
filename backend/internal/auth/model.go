package auth

import "time"

// RefreshToken is the internal representation of a row in refresh_tokens.
// It holds only the hash of the token, never the plain value.
type RefreshToken struct {
	ID        int64
	UserID    int64
	TokenHash string
	ExpiresAt time.Time
	RevokedAt *time.Time
	CreatedAt time.Time
}

// IsUsable reports whether the token can still be exchanged: not revoked and
// not expired.
func (t RefreshToken) IsUsable(now time.Time) bool {
	return t.RevokedAt == nil && t.ExpiresAt.After(now)
}

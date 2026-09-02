package auth

import (
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"fmt"
	"strconv"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

// TokenManager signs and verifies access tokens (JWT) and mints opaque
// refresh tokens. It holds the signing secret and the two TTLs.
type TokenManager struct {
	secret     []byte
	accessTTL  time.Duration
	refreshTTL time.Duration
	now        func() time.Time // overridable in tests
}

func NewTokenManager(secret string, accessTTL, refreshTTL time.Duration) *TokenManager {
	return &TokenManager{
		secret:     []byte(secret),
		accessTTL:  accessTTL,
		refreshTTL: refreshTTL,
		now:        time.Now,
	}
}

// AccessTTL is exposed so the handler can report expiresIn.
func (m *TokenManager) AccessTTL() time.Duration  { return m.accessTTL }
func (m *TokenManager) RefreshTTL() time.Duration { return m.refreshTTL }

// AccessClaims is the payload carried by an access token. Only the id and
// role are included — never the password hash or other sensitive fields.
type AccessClaims struct {
	Role string `json:"role"`
	jwt.RegisteredClaims
}

// GenerateAccessToken signs a short-lived JWT for the given user.
func (m *TokenManager) GenerateAccessToken(userID int64, role string) (string, time.Time, error) {
	now := m.now()
	exp := now.Add(m.accessTTL)
	claims := AccessClaims{
		Role: role,
		RegisteredClaims: jwt.RegisteredClaims{
			Subject:   strconv.FormatInt(userID, 10),
			IssuedAt:  jwt.NewNumericDate(now),
			ExpiresAt: jwt.NewNumericDate(exp),
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	signed, err := token.SignedString(m.secret)
	if err != nil {
		return "", time.Time{}, err
	}
	return signed, exp, nil
}

// ParseAccessToken validates the signature and expiry and returns the user
// id and role. A malformed, expired, or wrongly-signed token yields
// ErrUnauthorized.
func (m *TokenManager) ParseAccessToken(tokenStr string) (userID int64, role string, err error) {
	var claims AccessClaims
	_, parseErr := jwt.ParseWithClaims(tokenStr, &claims, func(t *jwt.Token) (any, error) {
		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", t.Header["alg"])
		}
		return m.secret, nil
	}, jwt.WithValidMethods([]string{"HS256"}), jwt.WithTimeFunc(m.now))
	if parseErr != nil {
		return 0, "", ErrUnauthorized
	}

	id, convErr := strconv.ParseInt(claims.Subject, 10, 64)
	if convErr != nil || id <= 0 {
		return 0, "", ErrUnauthorized
	}
	return id, claims.Role, nil
}

// generateRefreshToken returns a new opaque refresh token (URL-safe, 256
// bits of entropy) together with its SHA-256 hex digest. Only the digest is
// ever persisted; the plain token is handed to the client once and cannot be
// recovered from the database.
func generateRefreshToken() (plain string, hash string, err error) {
	buf := make([]byte, 32)
	if _, err := rand.Read(buf); err != nil {
		return "", "", err
	}
	plain = base64.RawURLEncoding.EncodeToString(buf)
	return plain, hashRefreshToken(plain), nil
}

// hashRefreshToken returns the SHA-256 hex digest of a refresh token — the
// value stored in refresh_tokens.token_hash and looked up on refresh/logout.
func hashRefreshToken(plain string) string {
	sum := sha256.Sum256([]byte(plain))
	return hex.EncodeToString(sum[:])
}

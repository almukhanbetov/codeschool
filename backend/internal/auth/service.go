package auth

import (
	"context"
	"errors"
	"strings"
	"time"

	"codeschool/backend/internal/users"
)

// userService is the slice of *users.Service the auth flows need.
type userService interface {
	Create(ctx context.Context, in users.NewUser) (users.User, error)
	FindByEmail(ctx context.Context, email string) (users.User, error)
	FindByPhone(ctx context.Context, phone string) (users.User, error)
	FindByID(ctx context.Context, id int64) (users.User, error)
}

// refreshRepository is the slice of *Repository the auth flows need.
type refreshRepository interface {
	CreateRefreshToken(ctx context.Context, userID int64, tokenHash string, expiresAt time.Time) (RefreshToken, error)
	GetRefreshTokenByHash(ctx context.Context, tokenHash string) (RefreshToken, error)
	RevokeRefreshToken(ctx context.Context, tokenHash string) error
	RotateRefreshToken(ctx context.Context, oldHash string, userID int64, newHash string, newExpiresAt time.Time) (RefreshToken, error)
}

type Service struct {
	users   userService
	refresh refreshRepository
	tokens  *TokenManager
	now     func() time.Time
}

func NewService(us userService, refreshRepo refreshRepository, tm *TokenManager) *Service {
	return &Service{users: us, refresh: refreshRepo, tokens: tm, now: time.Now}
}

// Register validates the request, hashes the password, and creates the user.
// It does not log the user in — the client calls /auth/login separately.
func (s *Service) Register(ctx context.Context, req RegisterRequest) (users.User, error) {
	email := normalizeOptional(req.Email)
	phone := normalizeOptional(req.Phone)

	if email == nil && phone == nil {
		return users.User{}, validationError("Provide an email or a phone number")
	}
	if len(req.Password) < minPasswordLen {
		return users.User{}, validationError("Password must be at least 8 characters")
	}
	if strings.TrimSpace(req.FirstName) == "" {
		return users.User{}, validationError("First name is required")
	}

	role := users.Role(strings.ToLower(strings.TrimSpace(req.Role)))
	if !users.IsValidRole(role) {
		return users.User{}, validationError("Invalid role")
	}
	// Public registration may never create an admin.
	if !users.IsPublicRole(role) {
		return users.User{}, validationError("Invalid role")
	}

	hash, err := hashPassword(req.Password)
	if err != nil {
		return users.User{}, err
	}

	u, err := s.users.Create(ctx, users.NewUser{
		Email:        email,
		Phone:        phone,
		PasswordHash: hash,
		FirstName:    strings.TrimSpace(req.FirstName),
		LastName:     normalizeOptional(req.LastName),
		Role:         role,
	})
	if errors.Is(err, users.ErrDuplicateEmail) {
		return users.User{}, ErrDuplicateEmail
	}
	if errors.Is(err, users.ErrDuplicatePhone) {
		return users.User{}, ErrDuplicatePhone
	}
	if err != nil {
		return users.User{}, err
	}
	return u, nil
}

// Login authenticates by email-or-phone + password and issues an access
// token plus a fresh refresh token. Every failure mode (unknown account,
// wrong password) returns the same ErrInvalidCredentials so the response
// never reveals whether an identifier exists.
func (s *Service) Login(ctx context.Context, req LoginRequest) (LoginResult, error) {
	email := normalizeOptional(req.Email)
	phone := normalizeOptional(req.Phone)
	if email == nil && phone == nil {
		return LoginResult{}, ErrInvalidCredentials
	}

	var (
		u   users.User
		err error
	)
	if email != nil {
		u, err = s.users.FindByEmail(ctx, *email)
	} else {
		u, err = s.users.FindByPhone(ctx, *phone)
	}
	if errors.Is(err, users.ErrNotFound) {
		return LoginResult{}, ErrInvalidCredentials
	}
	if err != nil {
		return LoginResult{}, err
	}

	if !checkPassword(u.PasswordHash, req.Password) {
		return LoginResult{}, ErrInvalidCredentials
	}
	if !u.IsActive {
		return LoginResult{}, ErrUserInactive
	}

	return s.issueTokens(ctx, u)
}

// Refresh exchanges a valid, non-revoked, non-expired refresh token for a
// new access token and a new refresh token (rotation): the presented token
// is revoked in the same transaction that creates its replacement.
func (s *Service) Refresh(ctx context.Context, plainToken string) (LoginResult, error) {
	plainToken = strings.TrimSpace(plainToken)
	if plainToken == "" {
		return LoginResult{}, ErrInvalidRefreshToken
	}
	hash := hashRefreshToken(plainToken)

	rec, err := s.refresh.GetRefreshTokenByHash(ctx, hash)
	if errors.Is(err, ErrRefreshNotFound) {
		return LoginResult{}, ErrInvalidRefreshToken
	}
	if err != nil {
		return LoginResult{}, err
	}
	if !rec.IsUsable(s.now()) {
		return LoginResult{}, ErrInvalidRefreshToken
	}

	u, err := s.users.FindByID(ctx, rec.UserID)
	if errors.Is(err, users.ErrNotFound) {
		return LoginResult{}, ErrInvalidRefreshToken
	}
	if err != nil {
		return LoginResult{}, err
	}
	if !u.IsActive {
		return LoginResult{}, ErrUserInactive
	}

	newPlain, newHash, err := generateRefreshToken()
	if err != nil {
		return LoginResult{}, err
	}
	newExpiry := s.now().Add(s.tokens.RefreshTTL())
	if _, err := s.refresh.RotateRefreshToken(ctx, hash, u.ID, newHash, newExpiry); err != nil {
		return LoginResult{}, err
	}

	access, exp, err := s.tokens.GenerateAccessToken(u.ID, string(u.Role))
	if err != nil {
		return LoginResult{}, err
	}
	return LoginResult{
		AccessToken:     access,
		ExpiresInSecs:   int(time.Until(exp).Seconds()),
		RefreshToken:    newPlain,
		RefreshTokenTTL: int(s.tokens.RefreshTTL().Seconds()),
		User:            u,
	}, nil
}

// Logout revokes exactly the presented refresh token (the current session).
// It is idempotent — revoking an already-revoked or unknown token succeeds.
func (s *Service) Logout(ctx context.Context, plainToken string) error {
	plainToken = strings.TrimSpace(plainToken)
	if plainToken == "" {
		return nil
	}
	return s.refresh.RevokeRefreshToken(ctx, hashRefreshToken(plainToken))
}

// issueTokens mints a new access + refresh token pair for a user and
// persists the refresh token hash.
func (s *Service) issueTokens(ctx context.Context, u users.User) (LoginResult, error) {
	access, exp, err := s.tokens.GenerateAccessToken(u.ID, string(u.Role))
	if err != nil {
		return LoginResult{}, err
	}

	plain, hash, err := generateRefreshToken()
	if err != nil {
		return LoginResult{}, err
	}
	expiry := s.now().Add(s.tokens.RefreshTTL())
	if _, err := s.refresh.CreateRefreshToken(ctx, u.ID, hash, expiry); err != nil {
		return LoginResult{}, err
	}

	return LoginResult{
		AccessToken:     access,
		ExpiresInSecs:   int(time.Until(exp).Seconds()),
		RefreshToken:    plain,
		RefreshTokenTTL: int(s.tokens.RefreshTTL().Seconds()),
		User:            u,
	}, nil
}

// normalizeOptional trims a pointer string and collapses "" (or whitespace)
// to nil, so the DB only ever stores NULL or a real value.
func normalizeOptional(s *string) *string {
	if s == nil {
		return nil
	}
	trimmed := strings.TrimSpace(*s)
	if trimmed == "" {
		return nil
	}
	return &trimmed
}

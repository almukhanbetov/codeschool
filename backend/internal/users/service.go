package users

import (
	"context"
	"errors"
	"strings"

	"codeschool/backend/internal/httpx"
)

// repository is the subset of *Repository the service depends on — an
// interface so tests can supply a fake.
type repository interface {
	CreateUser(ctx context.Context, in NewUser) (User, error)
	GetUserByID(ctx context.Context, id int64) (User, error)
	GetUserByEmail(ctx context.Context, email string) (User, error)
	GetUserByPhone(ctx context.Context, phone string) (User, error)
}

type Service struct {
	repo repository
}

func NewService(repo repository) *Service {
	return &Service{repo: repo}
}

// GetByID loads one user, translating a missing row into a 404 httpx error.
// Used by the GET /me handler.
func (s *Service) GetByID(ctx context.Context, id int64) (User, error) {
	u, err := s.repo.GetUserByID(ctx, id)
	if errors.Is(err, ErrNotFound) {
		return User{}, httpx.NotFound("USER_NOT_FOUND", "User not found")
	}
	if err != nil {
		return User{}, httpx.Internal("failed to load user")
	}
	return u, nil
}

// The methods below return the package's raw sentinel errors (ErrNotFound,
// ErrDuplicateEmail, ErrDuplicatePhone) rather than httpx errors — the auth
// package composes them into register/login and maps failures to its own
// domain errors.

// Create inserts a new user. The password hash is supplied by the caller.
func (s *Service) Create(ctx context.Context, in NewUser) (User, error) {
	return s.repo.CreateUser(ctx, in)
}

// FindByEmail looks up a user by email (case-insensitive).
func (s *Service) FindByEmail(ctx context.Context, email string) (User, error) {
	return s.repo.GetUserByEmail(ctx, strings.TrimSpace(email))
}

// FindByPhone looks up a user by exact phone.
func (s *Service) FindByPhone(ctx context.Context, phone string) (User, error) {
	return s.repo.GetUserByPhone(ctx, strings.TrimSpace(phone))
}

// FindByID looks up a user by id, returning ErrNotFound when absent.
func (s *Service) FindByID(ctx context.Context, id int64) (User, error) {
	return s.repo.GetUserByID(ctx, id)
}

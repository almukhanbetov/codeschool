package modules

import (
	"context"
	"errors"

	"codeschool/backend/internal/httpx"
)

type Service struct {
	repo *Repository
}

func NewService(repo *Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) ListByCourseID(ctx context.Context, courseID int64) ([]Response, error) {
	items, err := s.repo.ListByCourseID(ctx, courseID)
	if err != nil {
		return nil, httpx.Internal("failed to load modules")
	}
	return toResponseList(items), nil
}

// ListModelsByCourseID returns the raw models (not the JSON DTO), for
// callers like the courses aggregate endpoint that need to combine modules
// with their lessons before shaping the final response.
func (s *Service) ListModelsByCourseID(ctx context.Context, courseID int64) ([]Module, error) {
	items, err := s.repo.ListByCourseID(ctx, courseID)
	if err != nil {
		return nil, httpx.Internal("failed to load modules")
	}
	return items, nil
}

func (s *Service) GetByID(ctx context.Context, id int64) (Response, error) {
	m, err := s.repo.GetByID(ctx, id)
	if errors.Is(err, ErrNotFound) {
		return Response{}, httpx.NotFound("MODULE_NOT_FOUND", "Module not found")
	}
	if err != nil {
		return Response{}, httpx.Internal("failed to load module")
	}
	return ToResponse(m), nil
}

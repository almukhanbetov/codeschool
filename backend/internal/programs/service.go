package programs

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

func (s *Service) List(ctx context.Context) ([]Response, error) {
	items, err := s.repo.List(ctx)
	if err != nil {
		return nil, httpx.Internal("failed to load programs")
	}
	return toResponseList(items), nil
}

func (s *Service) GetByID(ctx context.Context, id int64) (Response, error) {
	p, err := s.repo.GetByID(ctx, id)
	if errors.Is(err, ErrNotFound) {
		return Response{}, httpx.NotFound("PROGRAM_NOT_FOUND", "Program not found")
	}
	if err != nil {
		return Response{}, httpx.Internal("failed to load program")
	}
	return toResponse(p), nil
}

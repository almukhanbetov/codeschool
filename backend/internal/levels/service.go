package levels

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

func (s *Service) ListByProgramID(ctx context.Context, programID int64) ([]Response, error) {
	items, err := s.repo.ListByProgramID(ctx, programID)
	if err != nil {
		return nil, httpx.Internal("failed to load levels")
	}
	return toResponseList(items), nil
}

func (s *Service) GetByID(ctx context.Context, id int64) (Response, error) {
	l, err := s.repo.GetByID(ctx, id)
	if errors.Is(err, ErrNotFound) {
		return Response{}, httpx.NotFound("LEVEL_NOT_FOUND", "Level not found")
	}
	if err != nil {
		return Response{}, httpx.Internal("failed to load level")
	}
	return toResponse(l), nil
}

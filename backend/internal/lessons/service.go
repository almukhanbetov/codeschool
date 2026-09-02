package lessons

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

func (s *Service) ListByModuleID(ctx context.Context, moduleID int64) ([]Response, error) {
	items, err := s.repo.ListByModuleID(ctx, moduleID)
	if err != nil {
		return nil, httpx.Internal("failed to load lessons")
	}
	return toResponseList(items), nil
}

// ListModelsByModuleID mirrors ListByModuleID but returns the raw models,
// for the courses aggregate ("content") endpoint.
func (s *Service) ListModelsByModuleID(ctx context.Context, moduleID int64) ([]Lesson, error) {
	items, err := s.repo.ListByModuleID(ctx, moduleID)
	if err != nil {
		return nil, httpx.Internal("failed to load lessons")
	}
	return items, nil
}

// CourseIDForLesson resolves the owning course id of a published lesson.
// Returns ErrNotFound (the raw sentinel) if the lesson is missing or
// unpublished — callers in the student-flow packages translate it.
func (s *Service) CourseIDForLesson(ctx context.Context, lessonID int64) (int64, error) {
	return s.repo.CourseIDByLessonID(ctx, lessonID)
}

func (s *Service) GetByID(ctx context.Context, id int64) (Response, error) {
	l, err := s.repo.GetByID(ctx, id)
	if errors.Is(err, ErrNotFound) {
		return Response{}, httpx.NotFound("LESSON_NOT_FOUND", "Lesson not found")
	}
	if err != nil {
		return Response{}, httpx.Internal("failed to load lesson")
	}
	return ToResponse(l), nil
}

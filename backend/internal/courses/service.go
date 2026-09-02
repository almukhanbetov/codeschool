package courses

import (
	"context"
	"errors"

	"codeschool/backend/internal/httpx"
	"codeschool/backend/internal/lessons"
	"codeschool/backend/internal/modules"
)

// repository is the subset of *Repository the service depends on — defined
// as an interface so tests can supply a fake without a real database.
type repository interface {
	List(ctx context.Context, filter ListFilter) ([]Course, error)
	GetByID(ctx context.Context, id int64) (Course, error)
	GetBySlug(ctx context.Context, slug string) (Course, error)
}

type Service struct {
	repo           repository
	modulesService *modules.Service
	lessonsService *lessons.Service
}

func NewService(repo *Repository, modulesService *modules.Service, lessonsService *lessons.Service) *Service {
	return &Service{repo: repo, modulesService: modulesService, lessonsService: lessonsService}
}

func (s *Service) List(ctx context.Context, filter ListFilter) ([]Response, error) {
	items, err := s.repo.List(ctx, filter)
	if err != nil {
		return nil, httpx.Internal("failed to load courses")
	}
	return toResponseList(items), nil
}

func (s *Service) GetByID(ctx context.Context, id int64) (Response, error) {
	c, err := s.repo.GetByID(ctx, id)
	if errors.Is(err, ErrNotFound) {
		return Response{}, httpx.NotFound("COURSE_NOT_FOUND", "Course not found")
	}
	if err != nil {
		return Response{}, httpx.Internal("failed to load course")
	}
	return toResponse(c), nil
}

func (s *Service) GetBySlug(ctx context.Context, slug string) (Response, error) {
	c, err := s.repo.GetBySlug(ctx, slug)
	if errors.Is(err, ErrNotFound) {
		return Response{}, httpx.NotFound("COURSE_NOT_FOUND", "Course not found")
	}
	if err != nil {
		return Response{}, httpx.Internal("failed to load course")
	}
	return toResponse(c), nil
}

// GetContent builds the GET /courses/:id/content aggregate: the course plus
// every module, each with its own published lessons nested inline.
func (s *Service) GetContent(ctx context.Context, id int64) (ContentResponse, error) {
	course, err := s.repo.GetByID(ctx, id)
	if errors.Is(err, ErrNotFound) {
		return ContentResponse{}, httpx.NotFound("COURSE_NOT_FOUND", "Course not found")
	}
	if err != nil {
		return ContentResponse{}, httpx.Internal("failed to load course")
	}

	moduleModels, err := s.modulesService.ListModelsByCourseID(ctx, course.ID)
	if err != nil {
		return ContentResponse{}, err
	}

	result := ContentResponse{
		Course:  toResponse(course),
		Modules: make([]ModuleWithLessons, 0, len(moduleModels)),
	}

	for _, m := range moduleModels {
		lessonModels, err := s.lessonsService.ListModelsByModuleID(ctx, m.ID)
		if err != nil {
			return ContentResponse{}, err
		}

		lessonResponses := make([]lessons.Response, 0, len(lessonModels))
		for _, l := range lessonModels {
			lessonResponses = append(lessonResponses, lessons.ToResponse(l))
		}

		result.Modules = append(result.Modules, ModuleWithLessons{
			Response: modules.ToResponse(m),
			Lessons:  lessonResponses,
		})
	}

	return result, nil
}

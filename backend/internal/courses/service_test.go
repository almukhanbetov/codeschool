package courses

import (
	"context"
	"errors"
	"testing"

	"codeschool/backend/internal/httpx"
)

// fakeRepository is an in-memory stand-in for *Repository, so the service's
// business logic (DTO mapping, not-found translation) can be tested without
// a real Postgres connection.
type fakeRepository struct {
	courses []Course
}

func (f *fakeRepository) List(_ context.Context, filter ListFilter) ([]Course, error) {
	var out []Course
	for _, c := range f.courses {
		if filter.LevelID != nil && c.LevelID != *filter.LevelID {
			continue
		}
		out = append(out, c)
	}
	return out, nil
}

func (f *fakeRepository) GetByID(_ context.Context, id int64) (Course, error) {
	for _, c := range f.courses {
		if c.ID == id {
			return c, nil
		}
	}
	return Course{}, ErrNotFound
}

func (f *fakeRepository) GetBySlug(_ context.Context, slug string) (Course, error) {
	for _, c := range f.courses {
		if c.Slug == slug {
			return c, nil
		}
	}
	return Course{}, ErrNotFound
}

func newTestService(courses []Course) *Service {
	return &Service{repo: &fakeRepository{courses: courses}}
}

func TestService_List_ReturnsMappedCourses(t *testing.T) {
	svc := newTestService([]Course{
		{ID: 1, LevelID: 1, Title: "Python Start", Slug: "python-start"},
		{ID: 2, LevelID: 1, Title: "Scratch Junior", Slug: "scratch-junior"},
	})

	got, err := svc.List(context.Background(), ListFilter{})
	if err != nil {
		t.Fatalf("List returned unexpected error: %v", err)
	}
	if len(got) != 2 {
		t.Fatalf("expected 2 courses, got %d", len(got))
	}
	if got[0].Title != "Python Start" || got[0].Slug != "python-start" {
		t.Errorf("unexpected first course: %+v", got[0])
	}
}

func TestService_List_FiltersByLevelID(t *testing.T) {
	svc := newTestService([]Course{
		{ID: 1, LevelID: 1, Title: "Python Start", Slug: "python-start"},
		{ID: 2, LevelID: 2, Title: "AI Junior", Slug: "ai-junior"},
	})

	levelID := int64(2)
	got, err := svc.List(context.Background(), ListFilter{LevelID: &levelID})
	if err != nil {
		t.Fatalf("List returned unexpected error: %v", err)
	}
	if len(got) != 1 || got[0].Slug != "ai-junior" {
		t.Fatalf("expected only ai-junior, got %+v", got)
	}
}

func TestService_GetByID_NotFound(t *testing.T) {
	svc := newTestService(nil)

	_, err := svc.GetByID(context.Background(), 999)
	if err == nil {
		t.Fatal("expected an error for a missing course, got nil")
	}

	var apiErr *httpx.APIError
	if !errors.As(err, &apiErr) {
		t.Fatalf("expected *httpx.APIError, got %T: %v", err, err)
	}
	if apiErr.Status != 404 {
		t.Errorf("expected HTTP 404, got %d", apiErr.Status)
	}
	if apiErr.Code != "COURSE_NOT_FOUND" {
		t.Errorf("expected code COURSE_NOT_FOUND, got %s", apiErr.Code)
	}
}

func TestService_GetBySlug_NotFound(t *testing.T) {
	svc := newTestService(nil)

	_, err := svc.GetBySlug(context.Background(), "does-not-exist")
	if err == nil {
		t.Fatal("expected an error for a missing slug, got nil")
	}

	var apiErr *httpx.APIError
	if !errors.As(err, &apiErr) || apiErr.Status != 404 {
		t.Fatalf("expected a 404 *httpx.APIError, got %T: %v", err, err)
	}
}

func TestService_GetBySlug_Found(t *testing.T) {
	svc := newTestService([]Course{
		{ID: 3, LevelID: 1, Title: "Robotics Arduino", Slug: "robotics-arduino"},
	})

	got, err := svc.GetBySlug(context.Background(), "robotics-arduino")
	if err != nil {
		t.Fatalf("GetBySlug returned unexpected error: %v", err)
	}
	if got.ID != 3 || got.Title != "Robotics Arduino" {
		t.Errorf("unexpected course: %+v", got)
	}
}

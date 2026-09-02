package assignments

import (
	"context"
	"errors"
	"testing"

	"codeschool/backend/internal/lessons"
)

type fakeRepo struct {
	byLesson map[int64][]Assignment
}

func (f *fakeRepo) ListPublishedByLesson(_ context.Context, lessonID int64) ([]Assignment, error) {
	return f.byLesson[lessonID], nil
}
func (f *fakeRepo) PublishedIDsByLesson(_ context.Context, lessonID int64) ([]int64, error) {
	var ids []int64
	for _, a := range f.byLesson[lessonID] {
		ids = append(ids, a.ID)
	}
	return ids, nil
}
func (f *fakeRepo) GetPublishedByID(_ context.Context, id int64) (Assignment, int64, error) {
	for lid, as := range f.byLesson {
		for _, a := range as {
			if a.ID == id {
				return a, lid + 1000, nil // courseID convention for tests
			}
		}
	}
	return Assignment{}, 0, ErrNotFound
}

type fakeLessons struct{ courseByLesson map[int64]int64 }

func (f *fakeLessons) CourseIDForLesson(_ context.Context, lessonID int64) (int64, error) {
	c, ok := f.courseByLesson[lessonID]
	if !ok {
		return 0, lessons.ErrNotFound
	}
	return c, nil
}

type fakeEnroll struct{ enrolled map[[2]int64]bool }

func (f *fakeEnroll) IsEnrolled(_ context.Context, studentID, courseID int64) (bool, error) {
	return f.enrolled[[2]int64{studentID, courseID}], nil
}

func TestListForLesson_RequiresEnrollment(t *testing.T) {
	repo := &fakeRepo{byLesson: map[int64][]Assignment{
		7: {{ID: 1, LessonID: 7, Title: "A", AssignmentType: TypeCode, IsPublished: true}},
	}}
	ls := &fakeLessons{courseByLesson: map[int64]int64{7: 3}}
	en := &fakeEnroll{enrolled: map[[2]int64]bool{}}
	svc := NewService(repo, ls, en)

	if _, err := svc.ListForLesson(context.Background(), 5, 7); !errors.Is(err, ErrNotEnrolled) {
		t.Fatalf("want ErrNotEnrolled, got %v", err)
	}

	en.enrolled[[2]int64{5, 3}] = true
	got, err := svc.ListForLesson(context.Background(), 5, 7)
	if err != nil {
		t.Fatalf("ListForLesson: %v", err)
	}
	if len(got) != 1 || got[0].ID != 1 {
		t.Fatalf("unexpected: %+v", got)
	}
}

func TestListForLesson_UnknownLesson(t *testing.T) {
	svc := NewService(&fakeRepo{byLesson: map[int64][]Assignment{}},
		&fakeLessons{courseByLesson: map[int64]int64{}},
		&fakeEnroll{enrolled: map[[2]int64]bool{}})

	if _, err := svc.ListForLesson(context.Background(), 5, 999); !errors.Is(err, ErrLessonNotFound) {
		t.Fatalf("want ErrLessonNotFound, got %v", err)
	}
}

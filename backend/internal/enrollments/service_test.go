package enrollments

import (
	"context"
	"errors"
	"testing"

	"codeschool/backend/internal/courses"
)

type fakeCourses struct {
	published map[int64]courses.Course
}

func (f *fakeCourses) GetByID(_ context.Context, id int64) (courses.Course, error) {
	c, ok := f.published[id]
	if !ok {
		return courses.Course{}, courses.ErrNotFound
	}
	return c, nil
}

func (f *fakeCourses) ListByIDs(_ context.Context, ids []int64) ([]courses.Course, error) {
	var out []courses.Course
	for _, id := range ids {
		if c, ok := f.published[id]; ok {
			out = append(out, c)
		}
	}
	return out, nil
}

type fakeEnrollRepo struct {
	rows   []Enrollment
	nextID int64
}

func (f *fakeEnrollRepo) Create(_ context.Context, studentID, courseID int64) (Enrollment, error) {
	for _, e := range f.rows {
		if e.StudentID == studentID && e.CourseID == courseID && e.Status == StatusActive {
			return Enrollment{}, ErrAlreadyEnrolled
		}
	}
	f.nextID++
	e := Enrollment{ID: f.nextID, StudentID: studentID, CourseID: courseID, Status: StatusActive}
	f.rows = append(f.rows, e)
	return e, nil
}

func (f *fakeEnrollRepo) GetActive(_ context.Context, studentID, courseID int64) (Enrollment, error) {
	for _, e := range f.rows {
		if e.StudentID == studentID && e.CourseID == courseID && e.Status == StatusActive {
			return e, nil
		}
	}
	return Enrollment{}, ErrNotFound
}

func (f *fakeEnrollRepo) HasActive(_ context.Context, studentID, courseID int64) (bool, error) {
	_, err := f.GetActive(context.Background(), studentID, courseID)
	return err == nil, nil
}

func (f *fakeEnrollRepo) StatusFor(_ context.Context, studentID, courseID int64) (string, error) {
	for _, e := range f.rows {
		if e.StudentID == studentID && e.CourseID == courseID {
			return e.Status, nil
		}
	}
	return "", nil
}

func (f *fakeEnrollRepo) ListByStudent(_ context.Context, studentID int64) ([]Enrollment, error) {
	var out []Enrollment
	for _, e := range f.rows {
		if e.StudentID == studentID {
			out = append(out, e)
		}
	}
	return out, nil
}

func newSvc(published ...int64) (*Service, *fakeEnrollRepo) {
	pub := map[int64]courses.Course{}
	for _, id := range published {
		pub[id] = courses.Course{ID: id, Title: "Course", Slug: "course", IsPublished: true}
	}
	repo := &fakeEnrollRepo{}
	return NewService(repo, &fakeCourses{published: pub}), repo
}

func TestEnroll_Success(t *testing.T) {
	svc, _ := newSvc(3)
	res, err := svc.Enroll(context.Background(), 5, 3)
	if err != nil {
		t.Fatalf("Enroll: %v", err)
	}
	if res.StudentID != 5 || res.CourseID != 3 || res.Status != StatusActive {
		t.Fatalf("unexpected: %+v", res)
	}
}

func TestEnroll_DuplicateBlocked(t *testing.T) {
	svc, _ := newSvc(3)
	if _, err := svc.Enroll(context.Background(), 5, 3); err != nil {
		t.Fatal(err)
	}
	_, err := svc.Enroll(context.Background(), 5, 3)
	if !errors.Is(err, ErrAlreadyEnrolled) {
		t.Fatalf("want ErrAlreadyEnrolled, got %v", err)
	}
}

func TestEnroll_UnpublishedOrMissingCourseBlocked(t *testing.T) {
	svc, _ := newSvc() // nothing published
	_, err := svc.Enroll(context.Background(), 5, 99)
	if !errors.Is(err, ErrCourseNotAvailable) {
		t.Fatalf("want ErrCourseNotAvailable, got %v", err)
	}
}

func TestListMyCourses_OnlyOwnEnrollments(t *testing.T) {
	svc, repo := newSvc(3, 4)
	repo.rows = []Enrollment{
		{ID: 1, StudentID: 5, CourseID: 3, Status: StatusActive},
		{ID: 2, StudentID: 7, CourseID: 4, Status: StatusActive}, // another student
	}

	got, err := svc.ListMyCourses(context.Background(), 5)
	if err != nil {
		t.Fatal(err)
	}
	if len(got) != 1 || got[0].Course.ID != 3 {
		t.Fatalf("expected only student 5's course 3, got %+v", got)
	}
}

func TestIsEnrolled(t *testing.T) {
	svc, repo := newSvc(3)
	repo.rows = []Enrollment{{ID: 1, StudentID: 5, CourseID: 3, Status: StatusActive}}

	ok, _ := svc.IsEnrolled(context.Background(), 5, 3)
	if !ok {
		t.Error("expected student 5 enrolled in 3")
	}
	ok, _ = svc.IsEnrolled(context.Background(), 5, 4)
	if ok {
		t.Error("did not expect enrollment in 4")
	}
}

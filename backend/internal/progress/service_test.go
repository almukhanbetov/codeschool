package progress

import (
	"context"
	"errors"
	"testing"

	"codeschool/backend/internal/lessons"
)

type fakeRepo struct {
	started   map[[2]int64]bool
	completed map[[2]int64]bool
	counts    CourseCounts
	result    CompleteResult
}

func (f *fakeRepo) Start(_ context.Context, s, l int64) (LessonProgress, error) {
	f.started[[2]int64{s, l}] = true
	return LessonProgress{StudentID: s, LessonID: l, Status: StatusInProgress}, nil
}
func (f *fakeRepo) CompleteLessonTx(_ context.Context, s, l, c int64) (CompleteResult, error) {
	f.completed[[2]int64{s, l}] = true
	return f.result, nil
}
func (f *fakeRepo) CourseCountsFor(_ context.Context, s, c int64) (CourseCounts, error) {
	return f.counts, nil
}
func (f *fakeRepo) SummaryForStudent(_ context.Context, s int64) ([]CourseCounts, error) {
	return []CourseCounts{f.counts}, nil
}
func (f *fakeRepo) LessonProgressForCourse(_ context.Context, s, c int64) ([]LessonProgress, error) {
	return nil, nil
}

type fakeLessons struct{ m map[int64]int64 }

func (f *fakeLessons) CourseIDForLesson(_ context.Context, l int64) (int64, error) {
	c, ok := f.m[l]
	if !ok {
		return 0, lessons.ErrNotFound
	}
	return c, nil
}

type fakeEnroll struct {
	enrolled map[[2]int64]bool
	status   map[[2]int64]string
}

func (f *fakeEnroll) IsEnrolled(_ context.Context, s, c int64) (bool, error) {
	return f.enrolled[[2]int64{s, c}], nil
}
func (f *fakeEnroll) StatusFor(_ context.Context, s, c int64) (string, error) {
	return f.status[[2]int64{s, c}], nil
}

type fakeAssignments struct{ ids map[int64][]int64 }

func (f *fakeAssignments) PublishedIDsForLesson(_ context.Context, l int64) ([]int64, error) {
	return f.ids[l], nil
}

type fakeSubs struct{ nonDraft map[int64]int }

func (f *fakeSubs) CountNonDraftForAssignments(_ context.Context, s int64, ids []int64) (int, error) {
	n := 0
	for _, id := range ids {
		n += f.nonDraft[id]
	}
	return n, nil
}

func build() (*Service, *fakeRepo, *fakeEnroll, *fakeAssignments, *fakeSubs) {
	repo := &fakeRepo{started: map[[2]int64]bool{}, completed: map[[2]int64]bool{}}
	en := &fakeEnroll{
		enrolled: map[[2]int64]bool{{5, 3}: true},
		status:   map[[2]int64]string{{5, 3}: "active"},
	}
	as := &fakeAssignments{ids: map[int64][]int64{}}
	su := &fakeSubs{nonDraft: map[int64]int{}}
	svc := NewService(repo, &fakeLessons{m: map[int64]int64{7: 3}}, en, en, as, su)
	return svc, repo, en, as, su
}

func TestStartLesson_RequiresEnrollment(t *testing.T) {
	svc, _, en, _, _ := build()
	en.enrolled = map[[2]int64]bool{}
	if _, err := svc.StartLesson(context.Background(), 5, 7); !errors.Is(err, ErrNotEnrolled) {
		t.Fatalf("want ErrNotEnrolled, got %v", err)
	}
}

func TestStartLesson_Success(t *testing.T) {
	svc, repo, _, _, _ := build()
	if _, err := svc.StartLesson(context.Background(), 5, 7); err != nil {
		t.Fatal(err)
	}
	if !repo.started[[2]int64{5, 7}] {
		t.Fatal("expected Start to be called")
	}
}

func TestStartLesson_UnknownLesson(t *testing.T) {
	svc, _, _, _, _ := build()
	if _, err := svc.StartLesson(context.Background(), 5, 999); !errors.Is(err, ErrLessonNotFound) {
		t.Fatalf("want ErrLessonNotFound, got %v", err)
	}
}

func TestCompleteLesson_GatedByAssignmentSubmission(t *testing.T) {
	svc, repo, _, as, su := build()
	as.ids[7] = []int64{10} // lesson 7 has a published assignment
	repo.result = CompleteResult{Course: CourseCounts{CourseID: 3, TotalLessons: 2, CompletedLessons: 1}}

	// no submission yet -> blocked
	if _, err := svc.CompleteLesson(context.Background(), 5, 7); !errors.Is(err, ErrAssignmentIncomplete) {
		t.Fatalf("want ErrAssignmentIncomplete, got %v", err)
	}

	// submitted -> allowed
	su.nonDraft[10] = 1
	if _, err := svc.CompleteLesson(context.Background(), 5, 7); err != nil {
		t.Fatalf("CompleteLesson: %v", err)
	}
	if !repo.completed[[2]int64{5, 7}] {
		t.Fatal("expected CompleteLessonTx to run")
	}
}

func TestCompleteLesson_NoAssignmentCompletesImmediately(t *testing.T) {
	svc, repo, _, _, _ := build()
	repo.result = CompleteResult{Course: CourseCounts{CourseID: 3, TotalLessons: 1, CompletedLessons: 1}, EnrollmentCompleted: true}

	res, err := svc.CompleteLesson(context.Background(), 5, 7)
	if err != nil {
		t.Fatal(err)
	}
	if !res.EnrollmentCompleted {
		t.Fatal("expected enrollmentCompleted passthrough")
	}
}

func TestCourseProgress_RequiresEnrollment(t *testing.T) {
	svc, _, en, _, _ := build()
	en.status = map[[2]int64]string{}
	if _, err := svc.CourseProgress(context.Background(), 5, 3); !errors.Is(err, ErrNotEnrolled) {
		t.Fatalf("want ErrNotEnrolled, got %v", err)
	}
}

func TestCourseCounts_Percent(t *testing.T) {
	cases := []struct {
		done, total, want int
	}{
		{0, 0, 0}, // division by zero guarded
		{0, 10, 0},
		{4, 24, 16}, // matches the spec's example
		{1, 3, 33},
		{5, 5, 100},
	}
	for _, c := range cases {
		got := CourseCounts{CompletedLessons: c.done, TotalLessons: c.total}.Percent()
		if got != c.want {
			t.Errorf("Percent(%d/%d) = %d, want %d", c.done, c.total, got, c.want)
		}
	}
}

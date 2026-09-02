package parents

import (
	"context"
	"errors"
	"testing"
)

type fakeRepo struct {
	links    map[[2]int64]bool // {parentID, childID} -> linked
	children map[int64][]ChildListItem

	overviewCalls int
	courseCalls   int
	activityCalls int
}

func newFakeRepo() *fakeRepo {
	return &fakeRepo{links: map[[2]int64]bool{}, children: map[int64][]ChildListItem{}}
}

func (f *fakeRepo) IsLinked(_ context.Context, parentID, childID int64) (bool, error) {
	return f.links[[2]int64{parentID, childID}], nil
}
func (f *fakeRepo) ListChildren(_ context.Context, parentID int64) ([]ChildListItem, error) {
	return f.children[parentID], nil
}
func (f *fakeRepo) ChildOverview(_ context.Context, childID int64) (ChildOverview, error) {
	f.overviewCalls++
	return ChildOverview{Child: ChildBrief{ID: childID}}, nil
}
func (f *fakeRepo) ChildCourseDetail(_ context.Context, childID, courseID int64) (ChildCourseDetail, error) {
	f.courseCalls++
	return ChildCourseDetail{Child: ChildBrief{ID: childID}, Course: CourseBrief{ID: courseID}}, nil
}
func (f *fakeRepo) Activity(_ context.Context, childID int64) (ActivitySummary, error) {
	f.activityCalls++
	return ActivitySummary{Child: ChildBrief{ID: childID}}, nil
}

func setup() (*Service, *fakeRepo) {
	r := newFakeRepo()
	return NewService(r), r
}

func TestGetChild_LinkGate(t *testing.T) {
	svc, r := setup()
	r.links[[2]int64{10, 5}] = true // parent 10 linked to child 5

	if _, err := svc.GetChild(context.Background(), 10, 5); err != nil {
		t.Fatalf("linked child should be readable: %v", err)
	}
	if r.overviewCalls != 1 {
		t.Fatalf("repo not called for a linked child")
	}

	if _, err := svc.GetChild(context.Background(), 10, 6); !errors.Is(err, ErrChildNotFound) {
		t.Fatalf("unlinked child: want ErrChildNotFound, got %v", err)
	}
	if _, err := svc.GetChild(context.Background(), 11, 5); !errors.Is(err, ErrChildNotFound) {
		t.Fatalf("another parent: want ErrChildNotFound, got %v", err)
	}
	// the repo must NOT have been touched for the unauthorized reads
	if r.overviewCalls != 1 {
		t.Fatalf("repo called for an unlinked child: %d", r.overviewCalls)
	}
}

func TestGetChildCourse_LinkGate(t *testing.T) {
	svc, r := setup()
	r.links[[2]int64{10, 5}] = true

	if _, err := svc.GetChildCourse(context.Background(), 10, 5, 3); err != nil {
		t.Fatalf("linked: %v", err)
	}
	if _, err := svc.GetChildCourse(context.Background(), 10, 99, 3); !errors.Is(err, ErrChildNotFound) {
		t.Fatalf("unlinked: want ErrChildNotFound, got %v", err)
	}
	if r.courseCalls != 1 {
		t.Fatalf("repo called for an unlinked child")
	}
}

func TestGetChildActivity_LinkGate(t *testing.T) {
	svc, r := setup()
	r.links[[2]int64{10, 5}] = true

	if _, err := svc.GetChildActivity(context.Background(), 10, 5); err != nil {
		t.Fatalf("linked: %v", err)
	}
	if _, err := svc.GetChildActivity(context.Background(), 10, 42); !errors.Is(err, ErrChildNotFound) {
		t.Fatalf("unlinked: want ErrChildNotFound, got %v", err)
	}
	if r.activityCalls != 1 {
		t.Fatalf("repo called for an unlinked child")
	}
}

func TestListChildren_OnlyOwn(t *testing.T) {
	svc, r := setup()
	r.children[10] = []ChildListItem{{Child: ChildBrief{ID: 5}}, {Child: ChildBrief{ID: 6}}}
	r.children[11] = []ChildListItem{{Child: ChildBrief{ID: 7}}}

	got, _ := svc.ListChildren(context.Background(), 10)
	if len(got) != 2 || got[0].Child.ID != 5 {
		t.Fatalf("parent 10 got wrong children: %+v", got)
	}
	other, _ := svc.ListChildren(context.Background(), 11)
	if len(other) != 1 || other[0].Child.ID != 7 {
		t.Fatalf("parent 11 got wrong children: %+v", other)
	}
}

package groups

import (
	"context"
	"errors"
	"testing"

	"codeschool/backend/internal/submissions"
)

type fakeRepo struct {
	// ownedGroups[teacherID] = set of groupIDs the teacher owns (→ courseID 100+groupID)
	ownedGroups map[int64]map[int64]bool
	// members[groupID] = set of studentIDs
	members map[int64]map[int64]bool
	// ownedSubmissions[teacherID] = set of submissionIDs visible to that teacher
	ownedSubmissions map[int64]map[int64]bool
	subCount         int
	addStudentErr    error
	lastFilter       SubmissionFilter
}

func newFakeRepo() *fakeRepo {
	return &fakeRepo{
		ownedGroups:      map[int64]map[int64]bool{},
		members:          map[int64]map[int64]bool{},
		ownedSubmissions: map[int64]map[int64]bool{},
	}
}

func (f *fakeRepo) DashboardCounts(_ context.Context, teacherID int64) (Dashboard, error) {
	return Dashboard{GroupsCount: len(f.ownedGroups[teacherID])}, nil
}
func (f *fakeRepo) ListByTeacher(_ context.Context, teacherID int64) ([]GroupListItem, error) {
	var out []GroupListItem
	for gid := range f.ownedGroups[teacherID] {
		out = append(out, GroupListItem{ID: gid})
	}
	return out, nil
}
func (f *fakeRepo) GetDetailForTeacher(_ context.Context, teacherID, groupID int64) (GroupDetail, error) {
	if f.ownedGroups[teacherID][groupID] {
		return GroupDetail{GroupListItem: GroupListItem{ID: groupID}}, nil
	}
	return GroupDetail{}, ErrGroupNotFound
}
func (f *fakeRepo) GroupCourseID(_ context.Context, teacherID, groupID int64) (int64, error) {
	if f.ownedGroups[teacherID][groupID] {
		return 100 + groupID, nil
	}
	return 0, ErrGroupNotFound
}
func (f *fakeRepo) ListStudents(_ context.Context, groupID, _ int64) ([]GroupStudentItem, error) {
	var out []GroupStudentItem
	for sid := range f.members[groupID] {
		out = append(out, GroupStudentItem{Student: StudentBrief{ID: sid}})
	}
	return out, nil
}
func (f *fakeRepo) IsStudentInTeacherGroup(_ context.Context, teacherID, groupID, studentID int64) (bool, error) {
	return f.ownedGroups[teacherID][groupID] && f.members[groupID][studentID], nil
}
func (f *fakeRepo) StudentDetail(_ context.Context, studentID, _ int64) (StudentDetail, error) {
	return StudentDetail{Student: StudentBrief{ID: studentID}}, nil
}
func (f *fakeRepo) ListSubmissionsForTeacher(_ context.Context, _ int64, ff SubmissionFilter) ([]SubmissionListItem, int, error) {
	f.lastFilter = ff
	return []SubmissionListItem{}, f.subCount, nil
}
func (f *fakeRepo) GetSubmissionForTeacher(_ context.Context, teacherID, submissionID int64) (SubmissionDetail, error) {
	if f.ownedSubmissions[teacherID][submissionID] {
		return SubmissionDetail{ID: submissionID, Status: "submitted"}, nil
	}
	return SubmissionDetail{}, ErrSubmissionNotFound
}
func (f *fakeRepo) AddStudentTx(_ context.Context, _, _ int64) error { return f.addStudentErr }

type fakeReviewer struct {
	started  []int64
	reviewed []int64
	err      error
}

func (f *fakeReviewer) TeacherStartReview(_ context.Context, id int64) (submissions.Submission, error) {
	f.started = append(f.started, id)
	return submissions.Submission{ID: id}, f.err
}
func (f *fakeReviewer) TeacherReview(_ context.Context, id int64, _ *int, _ string, _ string) (submissions.Submission, error) {
	f.reviewed = append(f.reviewed, id)
	return submissions.Submission{ID: id}, f.err
}

func setup() (*Service, *fakeRepo, *fakeReviewer) {
	r := newFakeRepo()
	rv := &fakeReviewer{}
	return NewService(r, rv), r, rv
}

func TestGetGroup_OwnershipGate(t *testing.T) {
	svc, r, _ := setup()
	r.ownedGroups[1] = map[int64]bool{10: true}

	if _, err := svc.GetGroup(context.Background(), 1, 10); err != nil {
		t.Fatalf("owner should read own group: %v", err)
	}
	if _, err := svc.GetGroup(context.Background(), 1, 99); !errors.Is(err, ErrGroupNotFound) {
		t.Fatalf("want ErrGroupNotFound for non-owned group, got %v", err)
	}
	if _, err := svc.GetGroup(context.Background(), 2, 10); !errors.Is(err, ErrGroupNotFound) {
		t.Fatalf("another teacher must not read the group, got %v", err)
	}
}

func TestGetStudent_MembershipGate(t *testing.T) {
	svc, r, _ := setup()
	r.ownedGroups[1] = map[int64]bool{10: true}
	r.members[10] = map[int64]bool{5: true}

	if _, err := svc.GetStudent(context.Background(), 1, 10, 5); err != nil {
		t.Fatalf("teacher should read own group's student: %v", err)
	}
	if _, err := svc.GetStudent(context.Background(), 1, 10, 6); !errors.Is(err, ErrStudentNotInGroup) {
		t.Fatalf("want ErrStudentNotInGroup for a non-member, got %v", err)
	}
	if _, err := svc.GetStudent(context.Background(), 2, 10, 5); !errors.Is(err, ErrGroupNotFound) {
		t.Fatalf("another teacher must not reach the student, got %v", err)
	}
}

func TestReview_OwnershipGate(t *testing.T) {
	svc, r, rv := setup()
	r.ownedSubmissions[1] = map[int64]bool{55: true}

	if _, err := svc.Review(context.Background(), 1, 55, ReviewRequest{Status: "passed", Score: ptr(5)}); err != nil {
		t.Fatalf("owner review should proceed: %v", err)
	}
	if len(rv.reviewed) != 1 || rv.reviewed[0] != 55 {
		t.Fatalf("reviewer not invoked correctly: %+v", rv.reviewed)
	}

	if _, err := svc.Review(context.Background(), 2, 55, ReviewRequest{Status: "passed"}); !errors.Is(err, ErrSubmissionNotFound) {
		t.Fatalf("another teacher must not review, got %v", err)
	}
	// reviewer must NOT have been called for the unauthorized attempt
	if len(rv.reviewed) != 1 {
		t.Fatalf("reviewer called for unauthorized teacher: %+v", rv.reviewed)
	}
}

func TestListSubmissions_PaginationClamp(t *testing.T) {
	svc, r, _ := setup()
	r.subCount = 53

	_, meta, _ := svc.ListSubmissions(context.Background(), 1, SubmissionFilter{Page: 0, Limit: 0})
	if meta.Page != 1 || meta.Limit != defaultLimit {
		t.Fatalf("defaults wrong: %+v", meta)
	}

	_, meta, _ = svc.ListSubmissions(context.Background(), 1, SubmissionFilter{Page: 2, Limit: 9999})
	if meta.Limit != maxLimit {
		t.Fatalf("limit not clamped to %d: %+v", maxLimit, meta)
	}
	if meta.Total != 53 {
		t.Fatalf("total passthrough wrong: %+v", meta)
	}
	if r.lastFilter.Limit != maxLimit || r.lastFilter.Page != 2 {
		t.Fatalf("filter not normalized before repo: %+v", r.lastFilter)
	}
}

func ptr(i int) *int { return &i }

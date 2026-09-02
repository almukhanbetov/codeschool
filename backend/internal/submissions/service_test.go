package submissions

import (
	"context"
	"errors"
	"testing"
	"time"

	"codeschool/backend/internal/assignments"
)

type fakeRepo struct {
	rows   map[[2]int64]*Submission // key: {studentID, assignmentID}
	nextID int64
}

func newFakeRepo() *fakeRepo { return &fakeRepo{rows: map[[2]int64]*Submission{}} }

func (f *fakeRepo) find(id int64) *Submission {
	for _, s := range f.rows {
		if s.ID == id {
			return s
		}
	}
	return nil
}

func (f *fakeRepo) Get(_ context.Context, studentID, assignmentID int64) (Submission, error) {
	s, ok := f.rows[[2]int64{studentID, assignmentID}]
	if !ok {
		return Submission{}, ErrNotFound
	}
	return *s, nil
}

func (f *fakeRepo) GetByID(_ context.Context, id int64) (Submission, error) {
	if s := f.find(id); s != nil {
		return *s, nil
	}
	return Submission{}, ErrNotFound
}

func (f *fakeRepo) Create(_ context.Context, studentID, assignmentID int64, code, answer *string) (Submission, error) {
	f.nextID++
	s := &Submission{ID: f.nextID, StudentID: studentID, AssignmentID: assignmentID, Code: code, Answer: answer, Status: StatusDraft}
	f.rows[[2]int64{studentID, assignmentID}] = s
	return *s, nil
}

func (f *fakeRepo) UpdateContent(_ context.Context, id int64, code, answer *string) (Submission, error) {
	s := f.find(id)
	if s == nil {
		return Submission{}, ErrNotFound
	}
	if !isEditable(s.Status) {
		return Submission{}, ErrLocked
	}
	s.Code, s.Answer = code, answer
	return *s, nil
}

func (f *fakeRepo) MarkSubmitted(_ context.Context, id int64) (Submission, error) {
	s := f.find(id)
	if s == nil {
		return Submission{}, ErrNotFound
	}
	if !isEditable(s.Status) {
		return Submission{}, ErrLocked
	}
	now := time.Now()
	s.Status = StatusSubmitted
	s.SubmittedAt = &now
	s.Score = nil
	s.TeacherFeedback = nil
	s.CheckedAt = nil
	return *s, nil
}

func (f *fakeRepo) StartReview(_ context.Context, id int64) (Submission, error) {
	s := f.find(id)
	if s == nil || s.Status != StatusSubmitted {
		return Submission{}, ErrNotReviewable
	}
	s.Status = StatusChecking
	return *s, nil
}

func (f *fakeRepo) ApplyReview(_ context.Context, id int64, score *int, feedback *string, status string) (Submission, error) {
	s := f.find(id)
	if s == nil || (s.Status != StatusSubmitted && s.Status != StatusChecking) {
		return Submission{}, ErrNotReviewable
	}
	now := time.Now()
	s.Status = status
	s.Score = score
	s.TeacherFeedback = feedback
	s.CheckedAt = &now
	return *s, nil
}

func (f *fakeRepo) CountNonDraftForAssignments(_ context.Context, studentID int64, ids []int64) (int, error) {
	n := 0
	for _, id := range ids {
		if s, ok := f.rows[[2]int64{studentID, id}]; ok && s.Status != StatusDraft {
			n++
		}
	}
	return n, nil
}

type fakeAssignments struct {
	courseByAssignment map[int64]int64
	pointsByAssignment map[int64]int
}

func (f *fakeAssignments) ResolveForSubmission(_ context.Context, id int64) (assignments.Assignment, int64, error) {
	c, ok := f.courseByAssignment[id]
	if !ok {
		return assignments.Assignment{}, 0, assignments.ErrNotFound
	}
	return assignments.Assignment{ID: id, Points: f.pointsByAssignment[id]}, c, nil
}

type fakeEnroll struct{ enrolled map[[2]int64]bool }

func (f *fakeEnroll) IsEnrolled(_ context.Context, studentID, courseID int64) (bool, error) {
	return f.enrolled[[2]int64{studentID, courseID}], nil
}

func newSvc() (*Service, *fakeRepo, *fakeEnroll) {
	repo := newFakeRepo()
	en := &fakeEnroll{enrolled: map[[2]int64]bool{{5, 3}: true}}
	as := &fakeAssignments{
		courseByAssignment: map[int64]int64{10: 3},
		pointsByAssignment: map[int64]int{10: 10},
	}
	return NewService(repo, as, en), repo, en
}

func strptr(s string) *string { return &s }
func intptr(i int) *int       { return &i }

func mustDraftSubmit(t *testing.T, svc *Service) {
	t.Helper()
	if _, err := svc.SaveDraft(context.Background(), 5, 10, UpsertRequest{Code: strptr("v1")}); err != nil {
		t.Fatal(err)
	}
	if _, err := svc.Submit(context.Background(), 5, 10); err != nil {
		t.Fatal(err)
	}
}

func TestSaveDraft_CreateThenUpdate(t *testing.T) {
	svc, _, _ := newSvc()
	r1, err := svc.SaveDraft(context.Background(), 5, 10, UpsertRequest{Code: strptr("v1")})
	if err != nil {
		t.Fatal(err)
	}
	if *r1.Code != "v1" || r1.Status != StatusDraft {
		t.Fatalf("unexpected: %+v", r1)
	}
	r2, err := svc.SaveDraft(context.Background(), 5, 10, UpsertRequest{Code: strptr("v2")})
	if err != nil || *r2.Code != "v2" || r2.ID != r1.ID {
		t.Fatalf("update draft failed: %+v %v", r2, err)
	}
}

func TestSaveDraft_NotEnrolled(t *testing.T) {
	svc, _, en := newSvc()
	en.enrolled = map[[2]int64]bool{}
	_, err := svc.SaveDraft(context.Background(), 5, 10, UpsertRequest{Code: strptr("x")})
	if !errors.Is(err, ErrNotEnrolled) {
		t.Fatalf("want ErrNotEnrolled, got %v", err)
	}
}

func TestSaveDraft_UnknownAssignment(t *testing.T) {
	svc, _, _ := newSvc()
	_, err := svc.SaveDraft(context.Background(), 5, 999, UpsertRequest{Code: strptr("x")})
	if !errors.Is(err, ErrAssignmentNotFound) {
		t.Fatalf("want ErrAssignmentNotFound, got %v", err)
	}
}

func TestSubmit_ThenLocked(t *testing.T) {
	svc, _, _ := newSvc()
	mustDraftSubmit(t, svc)
	if _, err := svc.SaveDraft(context.Background(), 5, 10, UpsertRequest{Code: strptr("cheat")}); !errors.Is(err, ErrLocked) {
		t.Fatalf("want ErrLocked on edit after submit, got %v", err)
	}
	if _, err := svc.Submit(context.Background(), 5, 10); !errors.Is(err, ErrLocked) {
		t.Fatalf("want ErrLocked on re-submit, got %v", err)
	}
}

func TestSubmit_NothingToSubmit(t *testing.T) {
	svc, _, _ := newSvc()
	if _, err := svc.Submit(context.Background(), 5, 10); !errors.Is(err, ErrNothingToSubmit) {
		t.Fatalf("want ErrNothingToSubmit, got %v", err)
	}
}

func TestGetMine_OnlyOwn(t *testing.T) {
	svc, _, en := newSvc()
	en.enrolled[[2]int64{6, 3}] = true
	if _, err := svc.SaveDraft(context.Background(), 5, 10, UpsertRequest{Code: strptr("mine")}); err != nil {
		t.Fatal(err)
	}
	if _, err := svc.GetMine(context.Background(), 6, 10); !errors.Is(err, ErrNotFound) {
		t.Fatalf("student 6 must not see student 5's submission, got %v", err)
	}
}

/* ---- teacher review ------------------------------------------------- */

func TestReviewFlow_SubmittedToCheckingToPassed(t *testing.T) {
	svc, repo, _ := newSvc()
	mustDraftSubmit(t, svc)
	id := repo.find(1).ID

	rev, err := svc.TeacherStartReview(context.Background(), id)
	if err != nil || rev.Status != StatusChecking {
		t.Fatalf("start review: %+v %v", rev, err)
	}
	// idempotent
	if again, err := svc.TeacherStartReview(context.Background(), id); err != nil || again.Status != StatusChecking {
		t.Fatalf("start review not idempotent: %+v %v", again, err)
	}

	done, err := svc.TeacherReview(context.Background(), id, intptr(8), "nice", StatusPassed)
	if err != nil {
		t.Fatalf("review: %v", err)
	}
	if done.Status != StatusPassed || *done.Score != 8 || *done.TeacherFeedback != "nice" || done.CheckedAt == nil {
		t.Fatalf("unexpected reviewed submission: %+v", done)
	}
}

func TestReview_DirectFromSubmitted(t *testing.T) {
	svc, repo, _ := newSvc()
	mustDraftSubmit(t, svc)
	id := repo.find(1).ID
	if _, err := svc.TeacherReview(context.Background(), id, intptr(10), "", StatusPassed); err != nil {
		t.Fatalf("review from submitted (no start): %v", err)
	}
}

func TestReview_ScoreCannotExceedPoints(t *testing.T) {
	svc, repo, _ := newSvc()
	mustDraftSubmit(t, svc)
	id := repo.find(1).ID
	if _, err := svc.TeacherReview(context.Background(), id, intptr(15), "x", StatusPassed); !errors.Is(err, ErrScoreOutOfRange) {
		t.Fatalf("want ErrScoreOutOfRange, got %v", err)
	}
}

func TestReview_FailedRequiresFeedback(t *testing.T) {
	svc, repo, _ := newSvc()
	mustDraftSubmit(t, svc)
	id := repo.find(1).ID
	if _, err := svc.TeacherReview(context.Background(), id, intptr(2), "   ", StatusFailed); !errors.Is(err, ErrFeedbackRequired) {
		t.Fatalf("want ErrFeedbackRequired, got %v", err)
	}
}

func TestReview_RejectsNonTerminalStatus(t *testing.T) {
	svc, repo, _ := newSvc()
	mustDraftSubmit(t, svc)
	id := repo.find(1).ID
	for _, bad := range []string{StatusDraft, StatusSubmitted, StatusChecking, "weird"} {
		if _, err := svc.TeacherReview(context.Background(), id, intptr(1), "f", bad); !errors.Is(err, ErrInvalidReviewStatus) {
			t.Fatalf("status %q: want ErrInvalidReviewStatus, got %v", bad, err)
		}
	}
}

func TestReview_ScoreRequiredWhenPointsPositive(t *testing.T) {
	svc, repo, _ := newSvc()
	mustDraftSubmit(t, svc)
	id := repo.find(1).ID
	if _, err := svc.TeacherReview(context.Background(), id, nil, "great", StatusPassed); !errors.Is(err, ErrScoreRequired) {
		t.Fatalf("want ErrScoreRequired, got %v", err)
	}
}

func TestReview_PassedCannotBeReReviewed(t *testing.T) {
	svc, repo, _ := newSvc()
	mustDraftSubmit(t, svc)
	id := repo.find(1).ID
	if _, err := svc.TeacherReview(context.Background(), id, intptr(9), "ok", StatusPassed); err != nil {
		t.Fatal(err)
	}
	if _, err := svc.TeacherReview(context.Background(), id, intptr(1), "no", StatusFailed); !errors.Is(err, ErrNotReviewable) {
		t.Fatalf("want ErrNotReviewable on already-passed, got %v", err)
	}
}

/* ---- resubmission after failed ------------------------------------- */

func TestResubmit_FailedIsEditableAndClearsReview(t *testing.T) {
	svc, repo, _ := newSvc()
	mustDraftSubmit(t, svc)
	id := repo.find(1).ID
	if _, err := svc.TeacherReview(context.Background(), id, intptr(3), "fix the variable name", StatusFailed); err != nil {
		t.Fatal(err)
	}

	// editable again
	edited, err := svc.SaveDraft(context.Background(), 5, 10, UpsertRequest{Code: strptr("v2-fixed")})
	if err != nil {
		t.Fatalf("failed submission should be editable: %v", err)
	}
	if edited.Status != StatusFailed || *edited.Code != "v2-fixed" {
		t.Fatalf("unexpected edited submission: %+v", edited)
	}

	// resubmit -> submitted, review fields cleared
	re, err := svc.Submit(context.Background(), 5, 10)
	if err != nil {
		t.Fatalf("resubmit: %v", err)
	}
	if re.Status != StatusSubmitted || re.Score != nil || re.TeacherFeedback != nil || re.CheckedAt != nil {
		t.Fatalf("resubmit did not clear the old review: %+v", re)
	}
}

func TestResubmit_PassedAndCheckingNotEditable(t *testing.T) {
	svc, repo, _ := newSvc()
	mustDraftSubmit(t, svc)
	id := repo.find(1).ID

	// checking: not editable
	if _, err := svc.TeacherStartReview(context.Background(), id); err != nil {
		t.Fatal(err)
	}
	if _, err := svc.SaveDraft(context.Background(), 5, 10, UpsertRequest{Code: strptr("x")}); !errors.Is(err, ErrLocked) {
		t.Fatalf("checking must not be editable, got %v", err)
	}

	// passed: not editable
	if _, err := svc.TeacherReview(context.Background(), id, intptr(10), "", StatusPassed); err != nil {
		t.Fatal(err)
	}
	if _, err := svc.SaveDraft(context.Background(), 5, 10, UpsertRequest{Code: strptr("y")}); !errors.Is(err, ErrLocked) {
		t.Fatalf("passed must not be editable, got %v", err)
	}
}

package certificates

import (
	"context"
	"errors"
	"sync"
	"testing"
	"time"
)

// fakeRepo is an in-memory stand-in for *Repository.
type fakeRepo struct {
	mu       sync.Mutex
	seq      int64
	byID     map[int64]Certificate
	elig     map[[2]int64]Eligibility
	numbers  map[string]bool
	codes    map[string]bool
	failNext int // when >0, Insert reports errNumberOrCodeConflict this many times
}

func newFakeRepo() *fakeRepo {
	return &fakeRepo{
		byID:    map[int64]Certificate{},
		elig:    map[[2]int64]Eligibility{},
		numbers: map[string]bool{},
		codes:   map[string]bool{},
	}
}

func (f *fakeRepo) Eligibility(_ context.Context, userID, courseID int64) (Eligibility, error) {
	return f.elig[[2]int64{userID, courseID}], nil
}
func (f *fakeRepo) YearSeq(_ context.Context, _ int) (int, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	return len(f.numbers) + 1, nil
}
func (f *fakeRepo) Insert(_ context.Context, c Certificate) (Certificate, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	if f.failNext > 0 {
		f.failNext--
		return Certificate{}, errNumberOrCodeConflict
	}
	for _, existing := range f.byID {
		if existing.UserID == c.UserID && existing.CourseID == c.CourseID {
			return Certificate{}, errUserCourseConflict
		}
	}
	if f.numbers[c.CertificateNumber] || f.codes[c.VerificationCode] {
		return Certificate{}, errNumberOrCodeConflict
	}
	f.seq++
	c.ID = f.seq
	c.Status = StatusActive
	c.IssuedAt = time.Now()
	f.byID[c.ID] = c
	f.numbers[c.CertificateNumber] = true
	f.codes[c.VerificationCode] = true
	return c, nil
}
func (f *fakeRepo) GetByID(_ context.Context, id int64) (Certificate, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	c, ok := f.byID[id]
	if !ok {
		return Certificate{}, ErrNotFound
	}
	return c, nil
}
func (f *fakeRepo) GetByUserCourse(_ context.Context, userID, courseID int64) (Certificate, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	for _, c := range f.byID {
		if c.UserID == userID && c.CourseID == courseID {
			return c, nil
		}
	}
	return Certificate{}, ErrNotFound
}
func (f *fakeRepo) GetByCode(_ context.Context, code string) (Certificate, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	for _, c := range f.byID {
		if c.VerificationCode == normalizeCode(code) {
			return c, nil
		}
	}
	return Certificate{}, ErrNotFound
}
func (f *fakeRepo) ListByUser(_ context.Context, userID int64) ([]Certificate, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	var out []Certificate
	for _, c := range f.byID {
		if c.UserID == userID {
			out = append(out, c)
		}
	}
	return out, nil
}
func (f *fakeRepo) AdminList(_ context.Context, _ AdminListFilter) ([]AdminRow, int, error) {
	return nil, 0, nil
}
func (f *fakeRepo) AdminGet(_ context.Context, id int64) (AdminRow, error) {
	c, err := f.GetByID(context.Background(), id)
	if err != nil {
		return AdminRow{}, err
	}
	return AdminRow{Certificate: c, LearnerRole: "student"}, nil
}
func (f *fakeRepo) Revoke(_ context.Context, id, adminID int64, reason string) (Certificate, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	c, ok := f.byID[id]
	if !ok {
		return Certificate{}, ErrNotFound
	}
	if c.Status == StatusRevoked {
		return Certificate{}, ErrAlreadyRevoked
	}
	now := time.Now()
	c.Status = StatusRevoked
	c.RevokedAt = &now
	c.RevokedBy = &adminID
	c.RevokeReason = &reason
	f.byID[id] = c
	return c, nil
}

type fakeAudit struct{ calls int }

func (f *fakeAudit) WriteAudit(_ context.Context, _ int64, _, _ string, _ *int64, _ string) error {
	f.calls++
	return nil
}

func newService(t *testing.T) (*Service, *fakeRepo, *fakeAudit) {
	t.Helper()
	repo := newFakeRepo()
	audit := &fakeAudit{}
	return NewService(repo, audit, "https://codeschool.example"), repo, audit
}

func completed(name, title string) Eligibility {
	return Eligibility{Enrolled: true, Completed: true, LearnerName: name, CourseTitle: title, CompletedAt: time.Now().Add(-24 * time.Hour), TotalLessons: 5, DoneLessons: 5}
}

func TestIssue_EligibleLearnerGetsCertificate(t *testing.T) {
	svc, repo, _ := newService(t)
	repo.elig[[2]int64{3, 25}] = completed("Ayan Student", "Python Start")

	res, err := svc.Issue(context.Background(), 3, 25)
	if err != nil {
		t.Fatalf("Issue: %v", err)
	}
	if res.Status != StatusActive || res.Course.ID != 25 || res.LearnerName != "Ayan Student" {
		t.Fatalf("unexpected certificate: %+v", res)
	}
	if !reNumber.MatchString(res.CertificateNumber) || !reCode.MatchString(res.VerificationCode) {
		t.Fatalf("bad identifiers: %+v", res)
	}
	if res.VerifyURL != "https://codeschool.example/certificates/verify/"+res.VerificationCode {
		t.Fatalf("bad verify url: %s", res.VerifyURL)
	}
}

func TestIssue_TeacherAcademyLearnerUsesSameEngine(t *testing.T) {
	svc, repo, _ := newService(t)
	// a teacher (users.id=2) completing an academy course (id=202)
	repo.elig[[2]int64{2, 202}] = completed("Dana Teacher", "Методика преподавания Python")

	res, err := svc.Issue(context.Background(), 2, 202)
	if err != nil {
		t.Fatalf("Issue (academy): %v", err)
	}
	if res.Course.ID != 202 || res.LearnerName != "Dana Teacher" {
		t.Fatalf("unexpected academy certificate: %+v", res)
	}
}

func TestIssue_IncompleteCourseRejected(t *testing.T) {
	svc, repo, _ := newService(t)
	repo.elig[[2]int64{3, 25}] = Eligibility{Enrolled: true, Completed: false, TotalLessons: 5, DoneLessons: 4}

	if _, err := svc.Issue(context.Background(), 3, 25); !errors.Is(err, ErrNotEligible) {
		t.Fatalf("want ErrNotEligible, got %v", err)
	}
}

func TestIssue_NotEnrolledRejected(t *testing.T) {
	svc, _, _ := newService(t)
	if _, err := svc.Issue(context.Background(), 3, 999); !errors.Is(err, ErrNotEnrolled) {
		t.Fatalf("want ErrNotEnrolled, got %v", err)
	}
}

func TestIssue_Idempotent(t *testing.T) {
	svc, repo, _ := newService(t)
	repo.elig[[2]int64{3, 25}] = completed("Ayan Student", "Python Start")

	first, err := svc.Issue(context.Background(), 3, 25)
	if err != nil {
		t.Fatal(err)
	}
	second, err := svc.Issue(context.Background(), 3, 25)
	if err != nil {
		t.Fatal(err)
	}
	if first.ID != second.ID || first.CertificateNumber != second.CertificateNumber {
		t.Fatalf("issue not idempotent: %+v vs %+v", first, second)
	}
	if len(repo.byID) != 1 {
		t.Fatalf("duplicate row created: %d certificates", len(repo.byID))
	}
}

func TestIssue_RetriesOnNumberCollision(t *testing.T) {
	svc, repo, _ := newService(t)
	repo.elig[[2]int64{3, 25}] = completed("Ayan Student", "Python Start")
	repo.failNext = 3 // first 3 insert attempts collide

	res, err := svc.Issue(context.Background(), 3, 25)
	if err != nil {
		t.Fatalf("Issue should retry past collisions: %v", err)
	}
	if res.ID == 0 {
		t.Fatal("no certificate issued after retries")
	}
}

func TestIssue_ServerIgnoresClientCompletionClaims(t *testing.T) {
	svc, repo, _ := newService(t)
	// The learner is only 20% done. The service only ever consults
	// repo.Eligibility — there is no code path that accepts a client value.
	repo.elig[[2]int64{3, 25}] = Eligibility{Enrolled: true, Completed: false, TotalLessons: 5, DoneLessons: 1}
	if _, err := svc.Issue(context.Background(), 3, 25); !errors.Is(err, ErrNotEligible) {
		t.Fatalf("want ErrNotEligible regardless of any client claim, got %v", err)
	}
}

func TestGetMine_OwnershipEnforced(t *testing.T) {
	svc, repo, _ := newService(t)
	repo.elig[[2]int64{3, 25}] = completed("Ayan Student", "Python Start")
	issued, _ := svc.Issue(context.Background(), 3, 25)

	if _, err := svc.GetMine(context.Background(), 3, issued.ID); err != nil {
		t.Fatalf("owner must read own certificate: %v", err)
	}
	// another learner -> ErrNotFound (not ErrForbidden: ownership not leaked)
	if _, err := svc.GetMine(context.Background(), 99, issued.ID); !errors.Is(err, ErrNotFound) {
		t.Fatalf("non-owner must get ErrNotFound, got %v", err)
	}
	if _, _, err := svc.PDFForOwner(context.Background(), 99, issued.ID, "ru"); !errors.Is(err, ErrNotFound) {
		t.Fatalf("non-owner PDF must be ErrNotFound, got %v", err)
	}
}

func TestVerify_PublicFieldsOnly(t *testing.T) {
	svc, repo, _ := newService(t)
	repo.elig[[2]int64{3, 25}] = completed("Ayan Student", "Python Start")
	issued, _ := svc.Issue(context.Background(), 3, 25)

	pv, err := svc.Verify(context.Background(), issued.VerificationCode)
	if err != nil {
		t.Fatal(err)
	}
	if !pv.Valid || pv.Status != StatusActive || pv.LearnerName != "Ayan Student" || pv.CourseTitle != "Python Start" {
		t.Fatalf("unexpected verification: %+v", pv)
	}
	// lower-case / spaced code still resolves
	if _, err := svc.Verify(context.Background(), "  "+lower(issued.VerificationCode)+" "); err != nil {
		t.Fatalf("verify should be case-insensitive: %v", err)
	}
	if _, err := svc.Verify(context.Background(), "ZZZZ-ZZZZ-ZZZZ-ZZZZ"); !errors.Is(err, ErrNotFound) {
		t.Fatalf("unknown code must be ErrNotFound, got %v", err)
	}
}

func TestRevoke_RequiresReasonAndAudits(t *testing.T) {
	svc, repo, audit := newService(t)
	repo.elig[[2]int64{3, 25}] = completed("Ayan Student", "Python Start")
	issued, _ := svc.Issue(context.Background(), 3, 25)

	if _, err := svc.Revoke(context.Background(), 1, issued.ID, RevokeRequest{Reason: "   "}); !errors.Is(err, ErrReasonRequired) {
		t.Fatalf("want ErrReasonRequired, got %v", err)
	}
	row, err := svc.Revoke(context.Background(), 1, issued.ID, RevokeRequest{Reason: "Issued in error"})
	if err != nil {
		t.Fatalf("Revoke: %v", err)
	}
	if row.Status != StatusRevoked || row.RevokeReason == nil || *row.RevokeReason != "Issued in error" {
		t.Fatalf("unexpected revoked row: %+v", row)
	}
	if audit.calls != 1 {
		t.Fatalf("expected exactly one audit write, got %d", audit.calls)
	}

	// public verification of a revoked certificate: exists but invalid
	pv, _ := svc.Verify(context.Background(), issued.VerificationCode)
	if pv.Valid || pv.Status != StatusRevoked || pv.RevokedAt == nil {
		t.Fatalf("revoked verification wrong: %+v", pv)
	}
	// second revoke -> ErrAlreadyRevoked
	if _, err := svc.Revoke(context.Background(), 1, issued.ID, RevokeRequest{Reason: "again"}); !errors.Is(err, ErrAlreadyRevoked) {
		t.Fatalf("want ErrAlreadyRevoked, got %v", err)
	}
}

func lower(s string) string {
	b := []byte(s)
	for i, c := range b {
		if c >= 'A' && c <= 'Z' {
			b[i] = c + 32
		}
	}
	return string(b)
}

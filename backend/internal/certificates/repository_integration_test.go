package certificates

import (
	"bytes"
	"context"
	"errors"
	"os"
	"testing"

	"github.com/jackc/pgx/v5/pgxpool"
)

type noopAudit struct{ n int }

func (a *noopAudit) WriteAudit(context.Context, int64, string, string, *int64, string) error {
	a.n++
	return nil
}

// TestCertificates_FullFlow drives the universal certificate engine against a
// real Postgres: student issuance, Teacher Academy issuance through the same
// service, incompleteness rejection, idempotency, DB-level uniqueness,
// public verification, admin revoke + audit, ownership, and PDF output.
// Skipped unless TEST_DATABASE_URL is set; all fixtures are thrown away.
func TestCertificates_FullFlow(t *testing.T) {
	dsn := os.Getenv("TEST_DATABASE_URL")
	if dsn == "" {
		t.Skip("TEST_DATABASE_URL not set; skipping certificates integration test")
	}
	ctx := context.Background()
	pool, err := pgxpool.New(ctx, dsn)
	if err != nil {
		t.Fatalf("connect: %v", err)
	}
	defer pool.Close()

	seed := func(q string, args ...any) int64 {
		var id int64
		if err := pool.QueryRow(ctx, q, args...).Scan(&id); err != nil {
			t.Fatalf("seed %q: %v", q, err)
		}
		return id
	}
	exec := func(q string, args ...any) {
		if _, err := pool.Exec(ctx, q, args...); err != nil {
			t.Fatalf("exec %q: %v", q, err)
		}
	}

	progID := seed(`INSERT INTO programs (title, slug) VALUES ('CERT','cert-it-prog') RETURNING id`)
	defer pool.Exec(ctx, `DELETE FROM programs WHERE id=$1`, progID)
	lvlID := seed(`INSERT INTO levels (program_id, title) VALUES ($1,'L') RETURNING id`, progID)

	studentCID := seed(`INSERT INTO courses (level_id,title,slug,audience,is_published) VALUES ($1,'Cert Python','cert-it-student','student',TRUE) RETURNING id`, lvlID)
	teacherCID := seed(`INSERT INTO courses (level_id,title,slug,audience,is_published) VALUES ($1,'Cert Method','cert-it-teacher','teacher',TRUE) RETURNING id`, lvlID)
	incompleteCID := seed(`INSERT INTO courses (level_id,title,slug,audience,is_published) VALUES ($1,'Cert WIP','cert-it-wip','student',TRUE) RETURNING id`, lvlID)

	// each course: 1 module, 2 published lessons
	mkLessons := func(courseID int64) (int64, int64) {
		m := seed(`INSERT INTO modules (course_id,title,position) VALUES ($1,'M',1) RETURNING id`, courseID)
		l1 := seed(`INSERT INTO lessons (module_id,title,position,is_published) VALUES ($1,'L1',1,TRUE) RETURNING id`, m)
		l2 := seed(`INSERT INTO lessons (module_id,title,position,is_published) VALUES ($1,'L2',2,TRUE) RETURNING id`, m)
		return l1, l2
	}
	sL1, sL2 := mkLessons(studentCID)
	tL1, tL2 := mkLessons(teacherCID)
	iL1, _ := mkLessons(incompleteCID)

	studentUID := seed(`INSERT INTO users (email,password_hash,first_name,last_name,role) VALUES ('cert-student@it.local','x','Ayan','Student','student') RETURNING id`)
	teacherUID := seed(`INSERT INTO users (email,password_hash,first_name,last_name,role) VALUES ('cert-teacher@it.local','x','Dana','Teacher','teacher') RETURNING id`)
	otherUID := seed(`INSERT INTO users (email,password_hash,first_name,role) VALUES ('cert-other@it.local','x','Nur','student') RETURNING id`)
	adminUID := seed(`INSERT INTO users (email,password_hash,first_name,role) VALUES ('cert-admin@it.local','x','Adm','admin') RETURNING id`)
	defer pool.Exec(ctx, `DELETE FROM users WHERE id = ANY($1)`, []int64{studentUID, teacherUID, otherUID, adminUID})

	// student completed the student course (authoritative: enrollment completed + all lessons done)
	exec(`INSERT INTO enrollments (student_id,course_id,status,completed_at) VALUES ($1,$2,'completed',NOW())`, studentUID, studentCID)
	exec(`INSERT INTO lesson_progress (student_id,lesson_id,status,progress_percent,completed_at) VALUES ($1,$2,'completed',100,NOW()),($1,$3,'completed',100,NOW())`, studentUID, sL1, sL2)

	// teacher completed the academy course via lesson completion only (enrollment still 'active')
	exec(`INSERT INTO enrollments (student_id,course_id,status) VALUES ($1,$2,'active')`, teacherUID, teacherCID)
	exec(`INSERT INTO lesson_progress (student_id,lesson_id,status,progress_percent,completed_at) VALUES ($1,$2,'completed',100,NOW()),($1,$3,'completed',100,NOW())`, teacherUID, tL1, tL2)

	// student enrolled in incompleteCID but only 1 of 2 lessons done
	exec(`INSERT INTO enrollments (student_id,course_id,status) VALUES ($1,$2,'active')`, studentUID, incompleteCID)
	exec(`INSERT INTO lesson_progress (student_id,lesson_id,status,progress_percent,completed_at) VALUES ($1,$2,'completed',100,NOW())`, studentUID, iL1)

	repo := NewRepository(pool)
	audit := &noopAudit{}
	svc := NewService(repo, audit, "https://codeschool.example")
	defer pool.Exec(ctx, `DELETE FROM certificates WHERE user_id = ANY($1)`, []int64{studentUID, teacherUID, otherUID})

	// ---- student issuance ----
	sc, err := svc.Issue(ctx, studentUID, studentCID)
	if err != nil {
		t.Fatalf("student Issue: %v", err)
	}
	if sc.LearnerName != "Ayan Student" || sc.Course.Title != "Cert Python" || sc.Status != StatusActive {
		t.Fatalf("unexpected student certificate: %+v", sc)
	}

	// ---- Teacher Academy issuance through the SAME service ----
	tc, err := svc.Issue(ctx, teacherUID, teacherCID)
	if err != nil {
		t.Fatalf("teacher academy Issue: %v", err)
	}
	if tc.LearnerName != "Dana Teacher" || tc.Course.Title != "Cert Method" {
		t.Fatalf("unexpected academy certificate: %+v", tc)
	}

	// ---- incomplete course rejected ----
	if _, err := svc.Issue(ctx, studentUID, incompleteCID); !errors.Is(err, ErrNotEligible) {
		t.Fatalf("incomplete course: want ErrNotEligible, got %v", err)
	}
	// ---- not enrolled rejected ----
	if _, err := svc.Issue(ctx, otherUID, studentCID); !errors.Is(err, ErrNotEnrolled) {
		t.Fatalf("not enrolled: want ErrNotEnrolled, got %v", err)
	}

	// ---- idempotency: same cert, no duplicate row ----
	again, err := svc.Issue(ctx, studentUID, studentCID)
	if err != nil || again.ID != sc.ID || again.CertificateNumber != sc.CertificateNumber {
		t.Fatalf("issue not idempotent: %+v vs %+v (%v)", again, sc, err)
	}
	var count int
	pool.QueryRow(ctx, `SELECT count(*) FROM certificates WHERE user_id=$1 AND course_id=$2`, studentUID, studentCID).Scan(&count)
	if count != 1 {
		t.Fatalf("duplicate certificate rows: %d", count)
	}

	// ---- uniqueness (DB-enforced) ----
	if sc.CertificateNumber == tc.CertificateNumber || sc.VerificationCode == tc.VerificationCode {
		t.Fatal("certificate number / verification code not unique across certificates")
	}
	if _, err := pool.Exec(ctx,
		`INSERT INTO certificates (user_id,course_id,certificate_number,verification_code,learner_name,course_title,completed_at)
		 VALUES ($1,$2,$3,$4,'x','x',NOW())`,
		otherUID, teacherCID, sc.CertificateNumber, "FRESH-CODE-XXXX-0000"); err == nil {
		t.Fatal("duplicate certificate_number was accepted by the database")
	}

	// ---- public verification ----
	pv, err := svc.Verify(ctx, sc.VerificationCode)
	if err != nil || !pv.Valid || pv.LearnerName != "Ayan Student" || pv.CourseTitle != "Cert Python" {
		t.Fatalf("verify: %+v %v", pv, err)
	}
	if _, err := svc.Verify(ctx, "ZZZZ-ZZZZ-ZZZZ-ZZZZ"); !errors.Is(err, ErrNotFound) {
		t.Fatalf("unknown code: want ErrNotFound, got %v", err)
	}

	// ---- ownership ----
	if _, err := svc.GetMine(ctx, otherUID, sc.ID); !errors.Is(err, ErrNotFound) {
		t.Fatalf("non-owner GetMine: want ErrNotFound, got %v", err)
	}
	pdf, _, err := svc.PDFForOwner(ctx, studentUID, sc.ID, "ru")
	if err != nil || !bytes.HasPrefix(pdf, []byte("%PDF-")) {
		t.Fatalf("owner PDF: %d bytes err=%v", len(pdf), err)
	}
	if _, _, err := svc.PDFForOwner(ctx, otherUID, sc.ID, "ru"); !errors.Is(err, ErrNotFound) {
		t.Fatalf("non-owner PDF: want ErrNotFound, got %v", err)
	}

	// ---- admin revoke + audit + verification flips ----
	if _, err := svc.Revoke(ctx, adminUID, sc.ID, RevokeRequest{Reason: "  "}); !errors.Is(err, ErrReasonRequired) {
		t.Fatalf("revoke without reason: want ErrReasonRequired, got %v", err)
	}
	row, err := svc.Revoke(ctx, adminUID, sc.ID, RevokeRequest{Reason: "Issued in error"})
	if err != nil || row.Status != StatusRevoked {
		t.Fatalf("revoke: %+v %v", row, err)
	}
	// noopAudit stands in for *admin.Repository here, so the assertion is the
	// audit-call count; the E2E test exercises the real admin_audit_log path.
	if audit.n != 1 {
		t.Fatalf("expected 1 audit write, got %d", audit.n)
	}

	pv2, _ := svc.Verify(ctx, sc.VerificationCode)
	if pv2.Valid || pv2.Status != StatusRevoked || pv2.RevokedAt == nil {
		t.Fatalf("revoked verification: %+v", pv2)
	}
	if _, err := svc.Revoke(ctx, adminUID, sc.ID, RevokeRequest{Reason: "again"}); !errors.Is(err, ErrAlreadyRevoked) {
		t.Fatalf("double revoke: want ErrAlreadyRevoked, got %v", err)
	}

	// revoked cert PDF still downloadable by owner (spec §40)
	if pdf, _, err := svc.PDFForOwner(ctx, studentUID, sc.ID, "en"); err != nil || len(pdf) < 2000 {
		t.Fatalf("revoked cert PDF for owner: %d bytes err=%v", len(pdf), err)
	}
}

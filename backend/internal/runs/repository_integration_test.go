package runs

import (
	"context"
	"errors"
	"os"
	"strconv"
	"strings"
	"testing"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"codeschool/backend/internal/assignments"
	"codeschool/backend/internal/enrollments"
	"codeschool/backend/internal/submissions"
)

// fakeRunner interprets a tiny fake "language": a source containing "sum"
// prints the sum of the whitespace-separated integers on stdin; anything else
// prints "0". A source containing "boom" exits non-zero.
type fakeRunner struct{ calls int }

func (f *fakeRunner) Execute(_ context.Context, _, source, stdin string, _ int) (execResult, error) {
	f.calls++
	if strings.Contains(source, "boom") {
		return execResult{Stderr: "boom", ExitCode: 1}, nil
	}
	if strings.Contains(source, "sum") {
		total := 0
		for _, tok := range strings.Fields(stdin) {
			n, _ := strconv.Atoi(tok)
			total += n
		}
		return execResult{Stdout: strconv.Itoa(total) + "\n", ExitCode: 0}, nil
	}
	return execResult{Stdout: "0\n", ExitCode: 0}, nil
}

func TestRuns_FullFlow(t *testing.T) {
	dsn := os.Getenv("TEST_DATABASE_URL")
	if dsn == "" {
		t.Skip("TEST_DATABASE_URL not set; skipping runs integration test")
	}
	ctx := context.Background()
	pool, err := pgxpool.New(ctx, dsn)
	if err != nil {
		t.Fatalf("connect: %v", err)
	}
	defer pool.Close()

	repo := NewRepository(pool)

	// --- throwaway catalog: program -> ... -> code assignment (+ a text one) ---
	var progID, lvlID, courseID, modID, lessonID, codeAID, textAID, adminID, stuID, stu2ID int64
	seed := func(q string, args ...any) int64 {
		var id int64
		if err := pool.QueryRow(ctx, q, args...).Scan(&id); err != nil {
			t.Fatalf("seed: %v (%s)", err, q)
		}
		return id
	}
	adminID = seed(`INSERT INTO users (email,password_hash,first_name,role) VALUES ('run-admin@it.local','x','A','admin') RETURNING id`)
	stuID = seed(`INSERT INTO users (email,password_hash,first_name,role) VALUES ('run-stu@it.local','x','S','student') RETURNING id`)
	stu2ID = seed(`INSERT INTO users (email,password_hash,first_name,role) VALUES ('run-stu2@it.local','x','S2','student') RETURNING id`)
	progID = seed(`INSERT INTO programs (title,slug) VALUES ('R','r-it-prog') RETURNING id`)
	defer pool.Exec(ctx, `DELETE FROM programs WHERE id=$1`, progID)
	defer pool.Exec(ctx, `DELETE FROM users WHERE id = ANY($1)`, []int64{adminID, stuID, stu2ID})
	lvlID = seed(`INSERT INTO levels (program_id,title) VALUES ($1,'L') RETURNING id`, progID)
	courseID = seed(`INSERT INTO courses (level_id,title,slug,is_published) VALUES ($1,'C','r-it-course',TRUE) RETURNING id`, lvlID)
	modID = seed(`INSERT INTO modules (course_id,title) VALUES ($1,'M') RETURNING id`, courseID)
	lessonID = seed(`INSERT INTO lessons (module_id,title,is_published) VALUES ($1,'L',TRUE) RETURNING id`, modID)
	codeAID = seed(`INSERT INTO assignments (lesson_id,title,assignment_type,language,points,is_published) VALUES ($1,'Sum','code','python',10,TRUE) RETURNING id`, lessonID)
	textAID = seed(`INSERT INTO assignments (lesson_id,title,assignment_type,is_published) VALUES ($1,'Essay','text',TRUE) RETURNING id`, lessonID)

	pool.Exec(ctx, `INSERT INTO enrollments (student_id,course_id,status) VALUES ($1,$2,'active')`, stuID, courseID)

	assignSvc := assignments.NewService(assignments.NewRepository(pool), nil, nil)
	enrollSvc := enrollments.NewService(enrollments.NewRepository(pool), nil)
	subsSvc := submissions.NewService(submissions.NewRepository(pool), assignSvc, enrollSvc)

	fr := &fakeRunner{}
	svc := &Service{repo: repo, client: fr, assign: assignSvc, enroll: enrollSvc, subs: subsSvc, lastRun: map[int64]time.Time{}}
	admin := NewAdminService(repo, assignSvc)

	// --- free run ---
	res, err := svc.Run(ctx, stuID, codeAID, RunRequest{Code: "print(sum)", Stdin: "2 3 4"})
	if err != nil {
		t.Fatalf("run: %v", err)
	}
	if strings.TrimSpace(res.Stdout) != "9" || res.Status != StatusOK {
		t.Fatalf("run result: %+v", res)
	}
	// history persisted
	if hist, _ := svc.History(ctx, stuID, codeAID); len(hist) != 1 || hist[0].RunID != res.RunID {
		t.Fatalf("history: %+v", hist)
	}
	// throttle: an immediate second run is rejected
	if _, err := svc.Run(ctx, stuID, codeAID, RunRequest{Code: "print(1)"}); !errors.Is(err, ErrThrottled) {
		t.Fatalf("throttle: want ErrThrottled, got %v", err)
	}
	// non-enrolled student blocked
	if _, err := svc.Run(ctx, stu2ID, codeAID, RunRequest{Code: "print(1)"}); !errors.Is(err, ErrNotEnrolled) {
		t.Fatalf("non-enrolled: want ErrNotEnrolled, got %v", err)
	}
	// non-code assignment rejected
	if _, err := svc.Run(ctx, stuID, textAID, RunRequest{Code: "x"}); !errors.Is(err, ErrNotCodeAssignment) {
		t.Fatalf("text assignment: want ErrNotCodeAssignment, got %v", err)
	}

	// --- admin authors 3 tests: 2 visible, 1 hidden ---
	hidden := true
	visible := false
	if _, err := admin.Create(ctx, adminID, textAID, CreateTestRequest{Name: "x"}); !errors.Is(err, ErrNotCodeAssignment) {
		t.Fatalf("test on non-code: want ErrNotCodeAssignment, got %v", err)
	}
	admin.Create(ctx, adminID, codeAID, CreateTestRequest{Name: "sample 1", Stdin: "1 2", ExpectedStdout: "3", IsHidden: &visible, Position: intp(1)})
	admin.Create(ctx, adminID, codeAID, CreateTestRequest{Name: "sample 2", Stdin: "10 20 30", ExpectedStdout: "60", IsHidden: &visible, Position: intp(2)})
	admin.Create(ctx, adminID, codeAID, CreateTestRequest{Name: "hidden edge", Stdin: "-5 5", ExpectedStdout: "0", IsHidden: &hidden, Weight: intp(2), Position: intp(3)})

	// student sees only the 2 visible ones
	vis, err := svc.VisibleTests(ctx, stuID, codeAID)
	if err != nil {
		t.Fatalf("visible tests: %v", err)
	}
	if !vis.HasTests || vis.Total != 3 || len(vis.Visible) != 2 {
		t.Fatalf("visible: %+v", vis)
	}
	for _, v := range vis.Visible {
		if strings.Contains(v.Name, "hidden") {
			t.Fatal("hidden test leaked to the student payload")
		}
	}

	// --- auto-grade: wrong solution fails, hidden test details are not exposed ---
	wrong, err := svc.Submit(ctx, stuID, codeAID, GradeRequest{Code: "print(0)"})
	if err != nil {
		t.Fatalf("submit wrong: %v", err)
	}
	if wrong.Passed || wrong.Status != "failed" {
		t.Fatalf("wrong should fail: %+v", wrong)
	}
	for _, oc := range wrong.Outcomes {
		if oc.Hidden && (oc.Expected != "" || oc.Got != "" || oc.Stdin != "") {
			t.Fatalf("hidden test outcome exposed details: %+v", oc)
		}
	}

	// correct solution passes -> submission passed + full score
	right, err := svc.Submit(ctx, stuID, codeAID, GradeRequest{Code: "print(sum)"})
	if err != nil {
		t.Fatalf("submit right: %v", err)
	}
	if !right.Passed || right.Status != "passed" || right.Score == nil || *right.Score != 10 {
		t.Fatalf("right should pass 10/10: %+v", right)
	}
	if right.TestsPassed != 3 || right.TestsTotal != 3 {
		t.Fatalf("tests: %d/%d", right.TestsPassed, right.TestsTotal)
	}

	// the submission row is now 'passed'
	var status string
	pool.QueryRow(ctx, `SELECT status FROM submissions WHERE student_id=$1 AND assignment_id=$2`, stuID, codeAID).Scan(&status)
	if status != "passed" {
		t.Fatalf("submission status = %q", status)
	}

	// progress gate helper
	if ids, _ := repo.AssignmentIDsWithTests(ctx, []int64{codeAID, textAID}); len(ids) != 1 || ids[0] != codeAID {
		t.Fatalf("AssignmentIDsWithTests: %v", ids)
	}
	if n, _ := subsSvc.CountPassedForAssignments(ctx, stuID, []int64{codeAID}); n != 1 {
		t.Fatalf("expected 1 passed submission, got %d", n)
	}

	// audit rows for the test authoring
	var auditN int
	pool.QueryRow(ctx, `SELECT count(*) FROM admin_audit_log WHERE admin_id=$1 AND entity='assignment_test'`, adminID).Scan(&auditN)
	if auditN < 3 {
		t.Fatalf("expected >=3 assignment_test audit rows, got %d", auditN)
	}
}

func intp(i int) *int { return &i }

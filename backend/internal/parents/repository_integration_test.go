package parents

import (
	"context"
	"errors"
	"os"
	"testing"

	"github.com/jackc/pgx/v5/pgxpool"
)

// TestRepository_ParentFlow exercises the link gate + aggregate queries
// against a real Postgres. Skipped unless TEST_DATABASE_URL is set; all
// fixtures are thrown away.
func TestRepository_ParentFlow(t *testing.T) {
	dsn := os.Getenv("TEST_DATABASE_URL")
	if dsn == "" {
		t.Skip("TEST_DATABASE_URL not set; skipping parents integration test")
	}
	ctx := context.Background()
	pool, err := pgxpool.New(ctx, dsn)
	if err != nil {
		t.Fatalf("connect: %v", err)
	}
	defer pool.Close()

	q := func(sql string, args ...any) int64 {
		var id int64
		if err := pool.QueryRow(ctx, sql, args...).Scan(&id); err != nil {
			t.Fatalf("fixture %q: %v", sql, err)
		}
		return id
	}

	programID := q(`INSERT INTO programs (title, slug, is_active) VALUES ('P','prog-parents-it',TRUE) RETURNING id`)
	defer pool.Exec(ctx, `DELETE FROM programs WHERE id=$1`, programID)
	levelID := q(`INSERT INTO levels (program_id, title) VALUES ($1,'L') RETURNING id`, programID)
	courseID := q(`INSERT INTO courses (level_id, title, slug, is_published) VALUES ($1,'C','course-parents-it',TRUE) RETURNING id`, levelID)
	otherCourseID := q(`INSERT INTO courses (level_id, title, slug, is_published) VALUES ($1,'C2','course-parents-it-2',TRUE) RETURNING id`, levelID)
	moduleID := q(`INSERT INTO modules (course_id, title, position) VALUES ($1,'M',1) RETURNING id`, courseID)
	lesson1 := q(`INSERT INTO lessons (module_id, title, position, is_published) VALUES ($1,'L1',1,TRUE) RETURNING id`, moduleID)
	lesson2 := q(`INSERT INTO lessons (module_id, title, position, is_published) VALUES ($1,'L2',2,TRUE) RETURNING id`, moduleID)
	assignmentID := q(`INSERT INTO assignments (lesson_id, title, assignment_type, points, is_published) VALUES ($1,'A','code',10,TRUE) RETURNING id`, lesson2)

	p1 := q(`INSERT INTO users (email, password_hash, first_name, role) VALUES ('parents-it-p1@test.local','x','P1','parent') RETURNING id`)
	p2 := q(`INSERT INTO users (email, password_hash, first_name, role) VALUES ('parents-it-p2@test.local','x','P2','parent') RETURNING id`)
	c1 := q(`INSERT INTO users (email, password_hash, first_name, role) VALUES ('parents-it-c1@test.local','x','C1','student') RETURNING id`)
	unrelated := q(`INSERT INTO users (email, password_hash, first_name, role) VALUES ('parents-it-u@test.local','x','U','student') RETURNING id`)
	for _, uid := range []int64{p1, p2, c1, unrelated} {
		defer pool.Exec(ctx, `DELETE FROM users WHERE id=$1`, uid)
	}

	mustExec := func(sql string, args ...any) {
		if _, err := pool.Exec(ctx, sql, args...); err != nil {
			t.Fatalf("exec %q: %v", sql, err)
		}
	}
	mustExec(`INSERT INTO parent_children (parent_id, child_id) VALUES ($1,$2)`, p1, c1)
	mustExec(`INSERT INTO enrollments (student_id, course_id, status) VALUES ($1,$2,'active')`, c1, courseID)
	mustExec(`INSERT INTO lesson_progress (student_id, lesson_id, status, progress_percent, completed_at) VALUES ($1,$2,'completed',100,NOW())`, c1, lesson1)
	// a failed, reviewed submission with feedback
	mustExec(`INSERT INTO submissions (assignment_id, student_id, code, status, score, teacher_feedback, submitted_at, checked_at)
	          VALUES ($1,$2,'print(1)','failed',3,'fix the output',NOW(),NOW())`, assignmentID, c1)

	repo := NewRepository(pool)

	// --- link gate ---
	if ok, _ := repo.IsLinked(ctx, p1, c1); !ok {
		t.Fatal("P1 should be linked to C1")
	}
	if ok, _ := repo.IsLinked(ctx, p1, unrelated); ok {
		t.Fatal("P1 must NOT be linked to an unrelated student")
	}
	if ok, _ := repo.IsLinked(ctx, p2, c1); ok {
		t.Fatal("P2 must NOT be linked to C1")
	}

	// --- ListChildren aggregates ---
	kids, err := repo.ListChildren(ctx, p1)
	if err != nil {
		t.Fatalf("ListChildren: %v", err)
	}
	if len(kids) != 1 || kids[0].Child.ID != c1 {
		t.Fatalf("expected exactly C1, got %+v", kids)
	}
	k := kids[0]
	if k.CoursesCount != 1 || k.OverallProgressPercent != 50 || k.NeedsWork != 1 || k.PendingReview != 0 {
		t.Fatalf("bad summary: %+v (want courses=1 progress=50 needsWork=1 pending=0)", k)
	}
	if p2kids, _ := repo.ListChildren(ctx, p2); len(p2kids) != 0 {
		t.Fatalf("P2 should have no children, got %+v", p2kids)
	}

	// --- ChildOverview ---
	ov, err := repo.ChildOverview(ctx, c1)
	if err != nil {
		t.Fatalf("ChildOverview: %v", err)
	}
	if len(ov.Courses) != 1 || ov.Courses[0].Progress.ProgressPercent != 50 {
		t.Fatalf("bad overview: %+v", ov)
	}

	// --- ChildCourseDetail carries the teacher feedback ---
	d, err := repo.ChildCourseDetail(ctx, c1, courseID)
	if err != nil {
		t.Fatalf("ChildCourseDetail: %v", err)
	}
	if len(d.Assignments) != 1 {
		t.Fatalf("want 1 assignment, got %d", len(d.Assignments))
	}
	a := d.Assignments[0]
	if a.Status != "failed" || a.Score == nil || *a.Score != 3 || a.TeacherFeedback == nil || *a.TeacherFeedback != "fix the output" {
		t.Fatalf("teacher feedback not surfaced: %+v", a)
	}
	if _, err := repo.ChildCourseDetail(ctx, c1, otherCourseID); !errors.Is(err, ErrCourseNotFound) {
		t.Fatalf("course the child is not enrolled in: want ErrCourseNotFound, got %v", err)
	}

	// --- Activity timeline (newest first): the review, then the lesson ---
	act, err := repo.Activity(ctx, c1)
	if err != nil {
		t.Fatalf("Activity: %v", err)
	}
	if len(act.Items) != 2 {
		t.Fatalf("want 2 activity items, got %d: %+v", len(act.Items), act.Items)
	}
	if act.Items[0].Type != ActivityAssignmentFailed || act.Items[1].Type != ActivityLessonCompleted {
		t.Fatalf("activity order wrong: %s then %s", act.Items[0].Type, act.Items[1].Type)
	}
	if act.Items[0].At.Before(act.Items[1].At) {
		t.Fatal("activity is not newest-first")
	}

	// --- a non-existent / unrelated child is not readable ---
	if _, err := repo.ChildOverview(ctx, 999999999); !errors.Is(err, ErrChildNotFound) {
		t.Fatalf("missing child: want ErrChildNotFound, got %v", err)
	}
}

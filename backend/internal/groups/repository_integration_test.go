package groups

import (
	"context"
	"errors"
	"os"
	"testing"

	"github.com/jackc/pgx/v5/pgxpool"
)

// TestRepository_TeacherFlow exercises the ownership joins and the
// add-student transaction against a real Postgres. Skipped unless
// TEST_DATABASE_URL is set. All fixtures are thrown away.
func TestRepository_TeacherFlow(t *testing.T) {
	dsn := os.Getenv("TEST_DATABASE_URL")
	if dsn == "" {
		t.Skip("TEST_DATABASE_URL not set; skipping groups integration test")
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

	programID := q(`INSERT INTO programs (title, slug, is_active) VALUES ('P','prog-groups-it',TRUE) RETURNING id`)
	defer pool.Exec(ctx, `DELETE FROM programs WHERE id=$1`, programID)
	levelID := q(`INSERT INTO levels (program_id, title) VALUES ($1,'L') RETURNING id`, programID)
	courseID := q(`INSERT INTO courses (level_id, title, slug, is_published) VALUES ($1,'C','course-groups-it',TRUE) RETURNING id`, levelID)
	moduleID := q(`INSERT INTO modules (course_id, title, position) VALUES ($1,'M',1) RETURNING id`, courseID)
	lessonID := q(`INSERT INTO lessons (module_id, title, position, is_published) VALUES ($1,'L1',1,TRUE) RETURNING id`, moduleID)
	assignmentID := q(`INSERT INTO assignments (lesson_id, title, assignment_type, points, is_published) VALUES ($1,'A','text',10,TRUE) RETURNING id`, lessonID)

	teacherA := q(`INSERT INTO users (email, password_hash, first_name, role) VALUES ('groups-it-ta@test.local','x','TA','teacher') RETURNING id`)
	teacherB := q(`INSERT INTO users (email, password_hash, first_name, role) VALUES ('groups-it-tb@test.local','x','TB','teacher') RETURNING id`)
	student1 := q(`INSERT INTO users (email, password_hash, first_name, role) VALUES ('groups-it-s1@test.local','x','S1','student') RETURNING id`)
	student2 := q(`INSERT INTO users (email, password_hash, first_name, role) VALUES ('groups-it-s2@test.local','x','S2','student') RETURNING id`)
	notStudent := q(`INSERT INTO users (email, password_hash, first_name, role) VALUES ('groups-it-p@test.local','x','P','parent') RETURNING id`)
	for _, uid := range []int64{teacherA, teacherB, student1, student2, notStudent} {
		defer pool.Exec(ctx, `DELETE FROM users WHERE id=$1`, uid)
	}

	groupA := q(`INSERT INTO groups (course_id, teacher_id, title, status, max_students) VALUES ($1,$2,'GA','active',1) RETURNING id`, courseID, teacherA)
	groupB := q(`INSERT INTO groups (course_id, teacher_id, title, status) VALUES ($1,$2,'GB','active') RETURNING id`, courseID, teacherB)

	repo := NewRepository(pool)

	// --- AddStudentTx: creates membership + enrollment ---
	if err := repo.AddStudentTx(ctx, groupA, student1); err != nil {
		t.Fatalf("AddStudentTx(s1): %v", err)
	}
	var enrolled bool
	pool.QueryRow(ctx, `SELECT EXISTS(SELECT 1 FROM enrollments WHERE student_id=$1 AND course_id=$2 AND status='active')`, student1, courseID).Scan(&enrolled)
	if !enrolled {
		t.Fatal("AddStudentTx did not create the active enrollment")
	}

	// --- duplicate blocked ---
	if err := repo.AddStudentTx(ctx, groupA, student1); !errors.Is(err, ErrAlreadyInGroup) {
		t.Fatalf("want ErrAlreadyInGroup, got %v", err)
	}

	// --- max_students enforced (groupA cap = 1) ---
	if err := repo.AddStudentTx(ctx, groupA, student2); !errors.Is(err, ErrGroupFull) {
		t.Fatalf("want ErrGroupFull, got %v", err)
	}

	// --- non-student rejected ---
	if err := repo.AddStudentTx(ctx, groupB, notStudent); !errors.Is(err, ErrNotAStudent) {
		t.Fatalf("want ErrNotAStudent, got %v", err)
	}

	// --- ownership: teacher A owns groupA, not groupB ---
	if _, err := repo.GetDetailForTeacher(ctx, teacherA, groupA); err != nil {
		t.Fatalf("teacher A should read groupA: %v", err)
	}
	if _, err := repo.GetDetailForTeacher(ctx, teacherA, groupB); !errors.Is(err, ErrGroupNotFound) {
		t.Fatalf("teacher A must not read groupB, got %v", err)
	}

	// --- student membership visibility ---
	inA, _ := repo.IsStudentInTeacherGroup(ctx, teacherA, groupA, student1)
	if !inA {
		t.Fatal("student1 should be visible to teacher A in groupA")
	}
	inB, _ := repo.IsStudentInTeacherGroup(ctx, teacherB, groupA, student1)
	if inB {
		t.Fatal("teacher B must not see student1 via groupA")
	}

	// --- submission ownership: student1 submits, only teacher A sees it ---
	subID := q(`INSERT INTO submissions (assignment_id, student_id, answer, status, submitted_at) VALUES ($1,$2,'ans','submitted',NOW()) RETURNING id`, assignmentID, student1)

	if _, err := repo.GetSubmissionForTeacher(ctx, teacherA, subID); err != nil {
		t.Fatalf("teacher A should see student1's submission: %v", err)
	}
	if _, err := repo.GetSubmissionForTeacher(ctx, teacherB, subID); !errors.Is(err, ErrSubmissionNotFound) {
		t.Fatalf("teacher B must NOT see student1's submission, got %v", err)
	}

	// --- list + pagination ---
	items, total, err := repo.ListSubmissionsForTeacher(ctx, teacherA, SubmissionFilter{Status: "submitted", Page: 1, Limit: 20})
	if err != nil {
		t.Fatalf("list: %v", err)
	}
	if total != 1 || len(items) != 1 || items[0].ID != subID {
		t.Fatalf("expected exactly student1's submission, got total=%d items=%+v", total, items)
	}
	// teacher B's queue is empty
	_, totalB, _ := repo.ListSubmissionsForTeacher(ctx, teacherB, SubmissionFilter{Status: "submitted", Page: 1, Limit: 20})
	if totalB != 0 {
		t.Fatalf("teacher B queue should be empty, got %d", totalB)
	}
}

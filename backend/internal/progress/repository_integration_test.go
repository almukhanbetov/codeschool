package progress

import (
	"context"
	"os"
	"testing"

	"github.com/jackc/pgx/v5/pgxpool"
)

// TestRepository_CompleteFlow is a real-Postgres integration test for the
// completion transaction: recount + enrollment auto-complete + the
// (student_id, lesson_id) uniqueness of lesson_progress. Skipped unless
// TEST_DATABASE_URL is set, so `go test ./...` still passes with no DB.
func TestRepository_CompleteFlow(t *testing.T) {
	dsn := os.Getenv("TEST_DATABASE_URL")
	if dsn == "" {
		t.Skip("TEST_DATABASE_URL not set; skipping progress integration test")
	}

	ctx := context.Background()
	pool, err := pgxpool.New(ctx, dsn)
	if err != nil {
		t.Fatalf("connect: %v", err)
	}
	defer pool.Close()

	// --- throwaway fixtures ---
	var programID, levelID, courseID, moduleID, studentID int64
	var lesson1, lesson2 int64

	mustQuery := func(q string, args ...any) int64 {
		var id int64
		if err := pool.QueryRow(ctx, q, args...).Scan(&id); err != nil {
			t.Fatalf("fixture %q: %v", q, err)
		}
		return id
	}

	programID = mustQuery(`INSERT INTO programs (title, slug, is_active) VALUES ('P','prog-progress-it', TRUE) RETURNING id`)
	defer pool.Exec(ctx, `DELETE FROM programs WHERE id=$1`, programID)

	levelID = mustQuery(`INSERT INTO levels (program_id, title) VALUES ($1,'L') RETURNING id`, programID)
	courseID = mustQuery(`INSERT INTO courses (level_id, title, slug, is_published) VALUES ($1,'C','course-progress-it', TRUE) RETURNING id`, levelID)
	moduleID = mustQuery(`INSERT INTO modules (course_id, title, position) VALUES ($1,'M',1) RETURNING id`, courseID)
	lesson1 = mustQuery(`INSERT INTO lessons (module_id, title, position, is_published) VALUES ($1,'L1',1, TRUE) RETURNING id`, moduleID)
	lesson2 = mustQuery(`INSERT INTO lessons (module_id, title, position, is_published) VALUES ($1,'L2',2, TRUE) RETURNING id`, moduleID)
	// an unpublished lesson must NOT count toward the total
	_ = mustQuery(`INSERT INTO lessons (module_id, title, position, is_published) VALUES ($1,'L3-draft',3, FALSE) RETURNING id`, moduleID)

	studentID = mustQuery(`INSERT INTO users (email, password_hash, first_name, role) VALUES ('progress-it@test.local','x','S','student') RETURNING id`)
	defer pool.Exec(ctx, `DELETE FROM users WHERE id=$1`, studentID)

	if _, err := pool.Exec(ctx, `INSERT INTO enrollments (student_id, course_id, status) VALUES ($1,$2,'active')`, studentID, courseID); err != nil {
		t.Fatalf("enrol: %v", err)
	}

	repo := NewRepository(pool)

	// --- complete lesson 1: 1/2 done, enrollment stays active ---
	res1, err := repo.CompleteLessonTx(ctx, studentID, lesson1, courseID)
	if err != nil {
		t.Fatalf("CompleteLessonTx(1): %v", err)
	}
	if res1.Course.TotalLessons != 2 || res1.Course.CompletedLessons != 1 {
		t.Fatalf("counts after L1 = %d/%d, want 1/2", res1.Course.CompletedLessons, res1.Course.TotalLessons)
	}
	if res1.Course.Percent() != 50 {
		t.Errorf("percent after L1 = %d, want 50", res1.Course.Percent())
	}
	if res1.EnrollmentCompleted {
		t.Error("enrollment should not be complete after 1/2 lessons")
	}

	// idempotent: completing L1 again does not create a second row or error
	if _, err := repo.CompleteLessonTx(ctx, studentID, lesson1, courseID); err != nil {
		t.Fatalf("CompleteLessonTx(1) again: %v", err)
	}
	var rows int
	if err := pool.QueryRow(ctx, `SELECT count(*) FROM lesson_progress WHERE student_id=$1 AND lesson_id=$2`, studentID, lesson1).Scan(&rows); err != nil {
		t.Fatal(err)
	}
	if rows != 1 {
		t.Fatalf("expected exactly 1 lesson_progress row for (student,lesson1), got %d", rows)
	}

	// --- complete lesson 2: 2/2 done, enrollment auto-completes ---
	res2, err := repo.CompleteLessonTx(ctx, studentID, lesson2, courseID)
	if err != nil {
		t.Fatalf("CompleteLessonTx(2): %v", err)
	}
	if res2.Course.CompletedLessons != 2 || res2.Course.Percent() != 100 {
		t.Fatalf("counts after L2 = %d/%d (%d%%), want 2/2 (100%%)", res2.Course.CompletedLessons, res2.Course.TotalLessons, res2.Course.Percent())
	}
	if !res2.EnrollmentCompleted {
		t.Fatal("enrollment should auto-complete after all published lessons")
	}

	var status string
	var completedAtSet bool
	if err := pool.QueryRow(ctx, `SELECT status, completed_at IS NOT NULL FROM enrollments WHERE student_id=$1 AND course_id=$2`, studentID, courseID).Scan(&status, &completedAtSet); err != nil {
		t.Fatal(err)
	}
	if status != "completed" || !completedAtSet {
		t.Fatalf("enrollment row = (%s, completed_at set=%v), want (completed, true)", status, completedAtSet)
	}
}

package academy

import (
	"context"
	"errors"
	"os"
	"testing"

	"github.com/jackc/pgx/v5/pgxpool"

	"codeschool/backend/internal/assignments"
	"codeschool/backend/internal/courses"
	"codeschool/backend/internal/enrollments"
	"codeschool/backend/internal/lessons"
	"codeschool/backend/internal/modules"
	"codeschool/backend/internal/submissions"
)

// TestAcademy_FullFlow drives the Teacher Academy against a real Postgres:
// audience isolation, teacher enrolment, progress reuse, admin review.
// Skipped unless TEST_DATABASE_URL is set.
func TestAcademy_FullFlow(t *testing.T) {
	dsn := os.Getenv("TEST_DATABASE_URL")
	if dsn == "" {
		t.Skip("TEST_DATABASE_URL not set; skipping academy integration test")
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
			t.Fatalf("seed: %v (%s)", err, q)
		}
		return id
	}

	// throwaway catalog: a teacher-audience course + a student-audience one
	var progID, lvlID, teacherCID, studentCID, modID, lessonID, projAID, teacherID, adminID int64
	teacherID = seed(`INSERT INTO users (email,password_hash,first_name,role) VALUES ('acad-teacher@it.local','x','T','teacher') RETURNING id`)
	adminID = seed(`INSERT INTO users (email,password_hash,first_name,role) VALUES ('acad-admin@it.local','x','A','admin') RETURNING id`)
	progID = seed(`INSERT INTO programs (title,slug) VALUES ('AC','ac-it-prog') RETURNING id`)
	defer pool.Exec(ctx, `DELETE FROM programs WHERE id=$1`, progID)
	defer pool.Exec(ctx, `DELETE FROM users WHERE id = ANY($1)`, []int64{teacherID, adminID})
	lvlID = seed(`INSERT INTO levels (program_id,title) VALUES ($1,'L') RETURNING id`, progID)
	teacherCID = seed(`INSERT INTO courses (level_id,title,slug,audience,is_published) VALUES ($1,'Method','ac-it-teacher','teacher',TRUE) RETURNING id`, lvlID)
	studentCID = seed(`INSERT INTO courses (level_id,title,slug,audience,is_published) VALUES ($1,'Kids','ac-it-student','student',TRUE) RETURNING id`, lvlID)
	modID = seed(`INSERT INTO modules (course_id,title) VALUES ($1,'M') RETURNING id`, teacherCID)
	lessonID = seed(`INSERT INTO lessons (module_id,title,is_published) VALUES ($1,'Plan',TRUE) RETURNING id`, modID)
	projAID = seed(`INSERT INTO assignments (lesson_id,title,assignment_type,points,is_published) VALUES ($1,'Lesson plan','project',20,TRUE) RETURNING id`, lessonID)

	repo := NewRepository(pool)
	coursesSvc := courses.NewService(courses.NewRepository(pool), modules.NewService(modules.NewRepository(pool)), lessons.NewService(lessons.NewRepository(pool)))
	enrollRepo := enrollments.NewRepository(pool)
	assignSvc := assignments.NewService(assignments.NewRepository(pool), nil, nil)
	subsSvc := submissions.NewService(submissions.NewRepository(pool), assignSvc, &fakeEnroll{})
	svc := NewService(repo, coursesSvc, enrollRepo, subsSvc)

	// ---- catalog: only the teacher course, not the student one ----
	cards, err := svc.ListCourses(ctx, teacherID)
	if err != nil {
		t.Fatalf("list courses: %v", err)
	}
	var sawTeacher, sawStudent bool
	for _, c := range cards {
		if c.ID == teacherCID {
			sawTeacher = true
		}
		if c.ID == studentCID {
			sawStudent = true
		}
	}
	if !sawTeacher || sawStudent {
		t.Fatalf("academy catalog must include the teacher course only (teacher=%v student=%v)", sawTeacher, sawStudent)
	}

	// ---- enrol: student course rejected, teacher course ok, duplicate blocked ----
	if _, err := svc.Enroll(ctx, teacherID, studentCID); !errors.Is(err, ErrNotTeacherCourse) {
		t.Fatalf("enrol in student course: want ErrNotTeacherCourse, got %v", err)
	}
	if _, err := svc.Enroll(ctx, teacherID, teacherCID); err != nil {
		t.Fatalf("enrol in academy course: %v", err)
	}
	if _, err := svc.Enroll(ctx, teacherID, teacherCID); !errors.Is(err, ErrAlreadyEnrolled) {
		t.Fatalf("duplicate enrol: want ErrAlreadyEnrolled, got %v", err)
	}

	// ---- content served (teacher-audience) ----
	content, err := svc.CourseContent(ctx, teacherCID)
	if err != nil || content.Course.ID != teacherCID {
		t.Fatalf("course content: %+v %v", content.Course, err)
	}

	// ---- reuse the submissions engine for a project assignment ----
	if _, err := subsSvc.SaveDraft(ctx, teacherID, projAID, submissions.UpsertRequest{Answer: strptr("Цель / объяснение / упражнение / ДЗ")}); err != nil {
		t.Fatalf("save draft: %v", err)
	}
	if _, err := subsSvc.Submit(ctx, teacherID, projAID); err != nil {
		t.Fatalf("submit: %v", err)
	}

	// ---- admin sees it pending, reviews it ----
	subs, err := svc.Submissions(ctx, "")
	if err != nil {
		t.Fatalf("admin submissions: %v", err)
	}
	var mine *AcademySubmissionRow
	for i := range subs {
		if subs[i].AssignmentID == projAID {
			mine = &subs[i]
		}
	}
	if mine == nil || mine.Status != "submitted" {
		t.Fatalf("expected a pending academy submission for the project, got %+v", subs)
	}
	if n, _ := svc.PendingReviewCount(ctx); n < 1 {
		t.Fatalf("pending review count = %d", n)
	}
	// a non-academy submission id is rejected
	if _, err := svc.Review(ctx, adminID, 999999999, ReviewRequest{Status: "passed"}); !errors.Is(err, ErrSubmissionNotFound) {
		t.Fatalf("review of a missing submission: want ErrSubmissionNotFound, got %v", err)
	}
	detail, err := svc.Review(ctx, adminID, mine.ID, ReviewRequest{Score: iptr(18), Feedback: "ok", Status: "passed"})
	if err != nil {
		t.Fatalf("review: %v", err)
	}
	if detail.Status != "passed" || detail.Score == nil || *detail.Score != 18 {
		t.Fatalf("reviewed detail: %+v", detail)
	}

	// audit row written
	var auditN int
	pool.QueryRow(ctx, `SELECT count(*) FROM admin_audit_log WHERE admin_id=$1 AND entity='academy_submission'`, adminID).Scan(&auditN)
	if auditN < 1 {
		t.Fatalf("expected an academy_submission audit row, got %d", auditN)
	}

	// ---- my courses / dashboard ----
	my, _ := svc.MyCourses(ctx, teacherID)
	if len(my) != 1 || my[0].CourseID != teacherCID {
		t.Fatalf("my courses: %+v", my)
	}
	dash, _ := svc.Dashboard(ctx, teacherID)
	if dash.TotalCourses != 1 {
		t.Fatalf("dashboard: %+v", dash)
	}
}

/* ---- test doubles ---- */

type fakeEnroll struct{}

func (fakeEnroll) IsEnrolled(_ context.Context, _, _ int64) (bool, error) { return true, nil }

func strptr(s string) *string { return &s }
func iptr(i int) *int         { return &i }

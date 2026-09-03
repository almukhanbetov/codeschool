package courses_test

import (
	"context"
	"os"
	"testing"

	"github.com/jackc/pgx/v5/pgxpool"

	"codeschool/backend/internal/admin"
	"codeschool/backend/internal/assignments"
	"codeschool/backend/internal/courses"
	"codeschool/backend/internal/enrollments"
	"codeschool/backend/internal/lessons"
	"codeschool/backend/internal/modules"
)

// TestAudienceHardening_FullFlow proves that Teacher Academy content
// (courses.audience = 'teacher') cannot be reached through the public /
// student catalog + content endpoints — not by course id, module id,
// lesson id or assignment listing — while it stays reachable for an
// enrolled teacher (the /teacher-academy re-mount) and for admin CRUD.
//
// Skipped unless TEST_DATABASE_URL is set; all fixtures are thrown away.
func TestAudienceHardening_FullFlow(t *testing.T) {
	dsn := os.Getenv("TEST_DATABASE_URL")
	if dsn == "" {
		t.Skip("TEST_DATABASE_URL not set; skipping audience hardening integration test")
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

	progID := seed(`INSERT INTO programs (title, slug) VALUES ('AH','ah-it-prog') RETURNING id`)
	defer pool.Exec(ctx, `DELETE FROM programs WHERE id=$1`, progID)
	lvlID := seed(`INSERT INTO levels (program_id, title) VALUES ($1,'L') RETURNING id`, progID)

	studentCID := seed(`INSERT INTO courses (level_id,title,slug,audience,is_published) VALUES ($1,'Kids','ah-student','student',TRUE) RETURNING id`, lvlID)
	bothCID := seed(`INSERT INTO courses (level_id,title,slug,audience,is_published) VALUES ($1,'Everyone','ah-both','both',TRUE) RETURNING id`, lvlID)
	teacherCID := seed(`INSERT INTO courses (level_id,title,slug,audience,is_published) VALUES ($1,'Method','ah-teacher','teacher',TRUE) RETURNING id`, lvlID)

	studentModID := seed(`INSERT INTO modules (course_id,title,position) VALUES ($1,'SM',1) RETURNING id`, studentCID)
	seed(`INSERT INTO modules (course_id,title,position) VALUES ($1,'BM',1) RETURNING id`, bothCID)
	teacherModID := seed(`INSERT INTO modules (course_id,title,position) VALUES ($1,'TM',1) RETURNING id`, teacherCID)

	seed(`INSERT INTO lessons (module_id,title,position,is_published) VALUES ($1,'SL',1,TRUE) RETURNING id`, studentModID)
	teacherLessonID := seed(`INSERT INTO lessons (module_id,title,position,is_published) VALUES ($1,'TL',1,TRUE) RETURNING id`, teacherModID)
	teacherAssignmentID := seed(`INSERT INTO assignments (lesson_id,title,assignment_type,points,is_published) VALUES ($1,'TA','project',20,TRUE) RETURNING id`, teacherLessonID)

	teacherUID := seed(`INSERT INTO users (email,password_hash,first_name,role) VALUES ('ah-teacher@it.local','x','T','teacher') RETURNING id`)
	studentUID := seed(`INSERT INTO users (email,password_hash,first_name,role) VALUES ('ah-student@it.local','x','S','student') RETURNING id`)
	defer pool.Exec(ctx, `DELETE FROM users WHERE id = ANY($1)`, []int64{teacherUID, studentUID})

	coursesRepo := courses.NewRepository(pool)
	modulesSvc := modules.NewService(modules.NewRepository(pool))
	lessonsSvc := lessons.NewService(lessons.NewRepository(pool))
	coursesSvc := courses.NewService(coursesRepo, modulesSvc, lessonsSvc)
	enrollSvc := enrollments.NewService(enrollments.NewRepository(pool), coursesRepo)
	assignmentsSvc := assignments.NewService(assignments.NewRepository(pool), lessonsSvc, enrollSvc)
	adminRepo := admin.NewRepository(pool)

	// ---- 1 & 3: student-audience course is reachable ---------------------
	if _, err := coursesSvc.GetByID(ctx, studentCID); err != nil {
		t.Fatalf("student course must be visible: %v", err)
	}
	if mods, err := modulesSvc.ListByCourseID(ctx, studentCID); err != nil || len(mods) != 1 {
		t.Fatalf("student course modules must be visible: %+v %v", mods, err)
	}

	// ---- 4: audience='both' course is reachable -------------------------
	if _, err := coursesSvc.GetByID(ctx, bothCID); err != nil {
		t.Fatalf("both-audience course must be visible: %v", err)
	}
	if mods, err := modulesSvc.ListByCourseID(ctx, bothCID); err != nil || len(mods) != 1 {
		t.Fatalf("both-audience course modules must be visible: %+v %v", mods, err)
	}

	// ---- 2 & 5: teacher-audience course is hidden -----------------------
	if _, err := coursesSvc.GetByID(ctx, teacherCID); err == nil {
		t.Fatal("teacher course must be hidden from GET /courses/:id")
	}
	if _, err := coursesSvc.GetBySlug(ctx, "ah-teacher"); err == nil {
		t.Fatal("teacher course must be hidden from GET /courses/slug/:slug")
	}
	if _, err := coursesSvc.GetContent(ctx, teacherCID); err == nil {
		t.Fatal("teacher course must be hidden from GET /courses/:id/content")
	}

	// ---- 6: guessing the teacher course's module id ---------------------
	if _, err := modulesSvc.ListByCourseID(ctx, teacherCID); err == nil {
		t.Fatal("teacher course modules must 404")
	}
	if _, err := lessonsSvc.ListByModuleID(ctx, teacherModID); err == nil {
		t.Fatal("teacher module lessons must 404")
	}

	// ---- 7: guessing the teacher course's lesson id -------------------
	if _, err := lessonsSvc.GetByID(ctx, teacherLessonID); err == nil {
		t.Fatal("teacher lesson must 404")
	}

	// ---- 8: guessing the teacher course's assignment listing ----------
	if _, err := assignmentsSvc.ListForLesson(ctx, studentUID, teacherLessonID); err == nil {
		t.Fatal("teacher lesson assignments must be hidden from a student")
	}

	// ---- 10: an enrolled teacher (the /teacher-academy re-mount) still
	//          reaches the same content -------------------------------------
	if _, err := pool.Exec(ctx, `INSERT INTO enrollments (student_id, course_id, status) VALUES ($1,$2,'active')`, teacherUID, teacherCID); err != nil {
		t.Fatalf("enrol teacher: %v", err)
	}
	if content, err := coursesSvc.GetContentAny(ctx, teacherCID); err != nil || content.Course.ID != teacherCID {
		t.Fatalf("academy content path must serve the teacher course: %+v %v", content.Course, err)
	}
	if as, err := assignmentsSvc.ListForLesson(ctx, teacherUID, teacherLessonID); err != nil || len(as) != 1 {
		t.Fatalf("enrolled teacher must see the assignment: %+v %v", as, err)
	}

	// ---- 11: admin CRUD repositories see the teacher content ------------
	if _, err := adminRepo.GetCourse(ctx, teacherCID); err != nil {
		t.Fatalf("admin must see the teacher course: %v", err)
	}
	if ms, err := adminRepo.ListModules(ctx, &teacherCID); err != nil || len(ms) != 1 {
		t.Fatalf("admin must see the teacher modules: %+v %v", ms, err)
	}
	if _, err := adminRepo.GetLesson(ctx, teacherLessonID); err != nil {
		t.Fatalf("admin must see the teacher lesson: %v", err)
	}
	if _, err := adminRepo.GetAssignment(ctx, teacherAssignmentID); err != nil {
		t.Fatalf("admin must see the teacher assignment: %v", err)
	}
}

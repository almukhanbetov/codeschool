package admin

import (
	"context"
	"errors"
	"os"
	"testing"

	"github.com/jackc/pgx/v5/pgxpool"

	"codeschool/backend/internal/groups"
)

// TestAdmin_FullFlow drives the whole catalog → group chain plus the user
// guards against a real Postgres. Skipped unless TEST_DATABASE_URL is set.
func TestAdmin_FullFlow(t *testing.T) {
	dsn := os.Getenv("TEST_DATABASE_URL")
	if dsn == "" {
		t.Skip("TEST_DATABASE_URL not set; skipping admin integration test")
	}
	ctx := context.Background()
	pool, err := pgxpool.New(ctx, dsn)
	if err != nil {
		t.Fatalf("connect: %v", err)
	}
	defer pool.Close()

	repo := NewRepository(pool)
	svc := NewService(repo, groups.NewRepository(pool))

	// a throwaway admin to attribute the audit rows to
	var adminID int64
	if err := pool.QueryRow(ctx,
		`INSERT INTO users (email, password_hash, first_name, role) VALUES ('admin-it@test.local','x','Root','admin') RETURNING id`).
		Scan(&adminID); err != nil {
		t.Fatalf("seed admin: %v", err)
	}
	defer pool.Exec(ctx, `DELETE FROM users WHERE id = $1`, adminID)

	// ---- catalog chain: program → level → course → module → lesson → assignment ----
	prog, err := svc.CreateProgram(ctx, adminID, CreateProgramRequest{Title: "IT Kids", Slug: "it-kids-admin-it"})
	if err != nil {
		t.Fatalf("create program: %v", err)
	}
	defer pool.Exec(ctx, `DELETE FROM programs WHERE id = $1`, prog.ID)

	// duplicate slug -> conflict
	if _, err := svc.CreateProgram(ctx, adminID, CreateProgramRequest{Title: "Dup", Slug: "it-kids-admin-it"}); !errors.Is(err, ErrConflict) {
		t.Fatalf("dup slug: want ErrConflict, got %v", err)
	}

	lvl, err := svc.CreateLevel(ctx, adminID, CreateLevelRequest{ProgramID: prog.ID, Title: "L1"})
	if err != nil {
		t.Fatalf("create level: %v", err)
	}
	// bad FK -> validation
	if _, err := svc.CreateLevel(ctx, adminID, CreateLevelRequest{ProgramID: 999999999, Title: "x"}); !errors.Is(err, ErrValidation) {
		t.Fatalf("bad program FK: want ErrValidation, got %v", err)
	}

	crs, err := svc.CreateCourse(ctx, adminID, CreateCourseRequest{LevelID: lvl.ID, Title: "Python", Slug: "py-admin-it"})
	if err != nil {
		t.Fatalf("create course: %v", err)
	}
	if crs.IsPublished {
		t.Fatal("new course should default to unpublished")
	}
	pub := true
	crs, err = svc.UpdateCourse(ctx, adminID, crs.ID, UpdateCourseRequest{IsPublished: &pub, Title: strptr("Python Start")})
	if err != nil || !crs.IsPublished || crs.Title != "Python Start" {
		t.Fatalf("update course: %+v %v", crs, err)
	}
	// invalid difficulty rejected
	if _, err := svc.UpdateCourse(ctx, adminID, crs.ID, UpdateCourseRequest{Difficulty: strptr("wizard")}); !errors.Is(errAsValidation(err), ErrValidation) {
		if _, isVE := err.(*ValidationError); !isVE {
			t.Fatalf("bad difficulty: want validation error, got %v", err)
		}
	}

	mod, err := svc.CreateModule(ctx, adminID, CreateModuleRequest{CourseID: crs.ID, Title: "Basics"})
	if err != nil {
		t.Fatalf("create module: %v", err)
	}
	les, err := svc.CreateLesson(ctx, adminID, CreateLessonRequest{ModuleID: mod.ID, Title: "Hello"})
	if err != nil {
		t.Fatalf("create lesson: %v", err)
	}
	if _, err := svc.CreateLesson(ctx, adminID, CreateLessonRequest{ModuleID: mod.ID, Title: "x", LessonType: strptr("bogus")}); err == nil {
		t.Fatal("bad lessonType should be rejected")
	}
	asg, err := svc.CreateAssignment(ctx, adminID, CreateAssignmentRequest{LessonID: les.ID, Title: "Task", AssignmentType: "code", Language: strptr("python")})
	if err != nil {
		t.Fatalf("create assignment: %v", err)
	}
	if asg.Language == nil || *asg.Language != "python" {
		t.Fatalf("assignment language not stored: %+v", asg.Language)
	}
	if _, err := svc.CreateAssignment(ctx, adminID, CreateAssignmentRequest{LessonID: les.ID, Title: "x", AssignmentType: "nope"}); err == nil {
		t.Fatal("bad assignmentType should be rejected")
	}
	if _, err := svc.UpdateAssignment(ctx, adminID, asg.ID, UpdateAssignmentRequest{Language: strptr("rust")}); err == nil {
		t.Fatal("bad language should be rejected")
	}
	_ = asg

	// ---- users + roles ----
	teacher, err := svc.CreateUser(ctx, adminID, CreateUserRequest{Email: strptr("t-admin-it@test.local"), Password: "password123", FirstName: "Tea", Role: "teacher"})
	if err != nil {
		t.Fatalf("create teacher: %v", err)
	}
	student, err := svc.CreateUser(ctx, adminID, CreateUserRequest{Email: strptr("s-admin-it@test.local"), Password: "password123", FirstName: "Stu", Role: "student"})
	if err != nil {
		t.Fatalf("create student: %v", err)
	}
	parent, err := svc.CreateUser(ctx, adminID, CreateUserRequest{Email: strptr("p-admin-it@test.local"), Password: "password123", FirstName: "Par", Role: "parent"})
	if err != nil {
		t.Fatalf("create parent: %v", err)
	}
	for _, id := range []int64{teacher.ID, student.ID, parent.ID} {
		defer pool.Exec(ctx, `DELETE FROM users WHERE id = $1`, id)
	}

	// duplicate email
	if _, err := svc.CreateUser(ctx, adminID, CreateUserRequest{Email: strptr("t-admin-it@test.local"), Password: "password123", FirstName: "X", Role: "student"}); !errors.Is(err, ErrDuplicateEmail) {
		t.Fatalf("dup email: want ErrDuplicateEmail, got %v", err)
	}

	// ---- parent link + role guard ----
	if err := svc.CreateParentLink(ctx, adminID, CreateParentLinkRequest{ParentID: parent.ID, ChildID: student.ID}); err != nil {
		t.Fatalf("create parent link: %v", err)
	}
	if err := svc.CreateParentLink(ctx, adminID, CreateParentLinkRequest{ParentID: parent.ID, ChildID: student.ID}); !errors.Is(err, ErrConflict) {
		t.Fatalf("dup link: want ErrConflict, got %v", err)
	}
	if err := svc.CreateParentLink(ctx, adminID, CreateParentLinkRequest{ParentID: teacher.ID, ChildID: student.ID}); !errors.Is(err, ErrRoleMismatch) {
		t.Fatalf("teacher-as-parent: want ErrRoleMismatch, got %v", err)
	}
	links, _ := svc.ListParentLinks(ctx, &parent.ID, nil)
	if len(links) != 1 || links[0].ChildID != student.ID {
		t.Fatalf("list links: %+v", links)
	}

	// ---- group: teacher assignment + membership (+ auto enrollment) ----
	if _, err := svc.CreateGroup(ctx, adminID, CreateGroupRequest{CourseID: crs.ID, TeacherID: student.ID, Title: "G"}); !errors.Is(err, ErrRoleMismatch) {
		t.Fatalf("student-as-teacher: want ErrRoleMismatch, got %v", err)
	}
	maxOne := 1
	grp, err := svc.CreateGroup(ctx, adminID, CreateGroupRequest{CourseID: crs.ID, TeacherID: teacher.ID, Title: "G1", MaxStudents: &maxOne, Status: strptr("active")})
	if err != nil {
		t.Fatalf("create group: %v", err)
	}
	if grp.TeacherName == "" || grp.CourseTitle == "" {
		t.Fatalf("group row missing joins: %+v", grp)
	}
	if err := svc.AddGroupStudent(ctx, adminID, grp.ID, student.ID); err != nil {
		t.Fatalf("add student: %v", err)
	}
	var enrolled bool
	pool.QueryRow(ctx, `SELECT EXISTS(SELECT 1 FROM enrollments WHERE student_id=$1 AND course_id=$2 AND status='active')`, student.ID, crs.ID).Scan(&enrolled)
	if !enrolled {
		t.Fatal("adding a student to a group must guarantee an active enrollment")
	}
	if err := svc.AddGroupStudent(ctx, adminID, grp.ID, student.ID); !errors.Is(err, ErrConflict) {
		t.Fatalf("dup member: want ErrConflict, got %v", err)
	}
	if err := svc.AddGroupStudent(ctx, adminID, grp.ID, parent.ID); !errors.Is(err, ErrRoleMismatch) {
		t.Fatalf("parent-as-student: want ErrRoleMismatch, got %v", err)
	}
	// max_students = 1 is full now
	stu2, _ := svc.CreateUser(ctx, adminID, CreateUserRequest{Email: strptr("s2-admin-it@test.local"), Password: "password123", FirstName: "Stu2", Role: "student"})
	defer pool.Exec(ctx, `DELETE FROM users WHERE id = $1`, stu2.ID)
	var ve *ValidationError
	if err := svc.AddGroupStudent(ctx, adminID, grp.ID, stu2.ID); !errors.As(err, &ve) {
		t.Fatalf("full group: want a validation error, got %v", err)
	}
	if err := svc.RemoveGroupStudent(ctx, adminID, grp.ID, student.ID); err != nil {
		t.Fatalf("remove student: %v", err)
	}

	// ---- user guards: last admin + self ----
	others, _ := repo.CountActiveAdminsExcluding(ctx, adminID)
	if others == 0 {
		// this is the only fresh admin, but seed admin(s) exist → guard shouldn't trip unless truly last
		t.Log("no other admins besides the fixture; relying on seed admins")
	}
	if err := svc.DeleteUser(ctx, adminID, adminID); !errors.Is(err, ErrSelfMutation) {
		t.Fatalf("self delete: want ErrSelfMutation, got %v", err)
	}
	off := false
	if _, err := svc.UpdateUser(ctx, adminID, adminID, UpdateUserRequest{IsActive: &off}); !errors.Is(err, ErrSelfMutation) {
		t.Fatalf("self deactivate: want ErrSelfMutation, got %v", err)
	}

	// ---- audit rows were written ----
	auditRows, _, err := repo.ListAudit(ctx, 1, 100)
	if err != nil {
		t.Fatalf("list audit: %v", err)
	}
	var mine int
	for _, r := range auditRows {
		if r.AdminID == adminID {
			mine++
		}
	}
	if mine < 10 {
		t.Fatalf("expected many audit rows for the fixture admin, got %d", mine)
	}

	// ---- cascade delete: dropping the program removes its whole subtree ----
	if err := svc.DeleteProgram(ctx, adminID, prog.ID); err != nil {
		t.Fatalf("delete program: %v", err)
	}
	if _, err := svc.GetCourse(ctx, crs.ID); !errors.Is(err, ErrNotFound) {
		t.Fatalf("course should have cascaded away, got %v", err)
	}
	if _, err := svc.GetProgram(ctx, prog.ID); !errors.Is(err, ErrNotFound) {
		t.Fatalf("deleting a missing program again: want ErrNotFound, got %v", err)
	}
	if err := svc.DeleteProgram(ctx, adminID, prog.ID); !errors.Is(err, ErrNotFound) {
		t.Fatalf("re-delete: want ErrNotFound, got %v", err)
	}
}

func strptr(s string) *string { return &s }

// errAsValidation is a tiny shim so the difficulty check reads cleanly.
func errAsValidation(err error) error {
	var ve *ValidationError
	if errors.As(err, &ve) {
		return ErrValidation
	}
	return err
}

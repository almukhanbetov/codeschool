package support

import (
	"context"
	"errors"
	"os"
	"strings"
	"testing"

	"github.com/jackc/pgx/v5/pgxpool"
)

type fakeAudit struct{ n int }

func (f *fakeAudit) WriteAudit(context.Context, int64, string, string, *int64, string) error {
	f.n++
	return nil
}

// TestSupport_FullFlow drives the learning-aware support chat against a real
// Postgres: thread creation + context validation, per-role visibility,
// internal notes, unread tracking, assignment, status lifecycle, spoof
// resistance and message validation. Skipped unless TEST_DATABASE_URL is set.
func TestSupport_FullFlow(t *testing.T) {
	dsn := os.Getenv("TEST_DATABASE_URL")
	if dsn == "" {
		t.Skip("TEST_DATABASE_URL not set; skipping support integration test")
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

	prog := seed(`INSERT INTO programs (title, slug) VALUES ('SUP','sup-it-prog') RETURNING id`)
	defer pool.Exec(ctx, `DELETE FROM programs WHERE id=$1`, prog)
	lvl := seed(`INSERT INTO levels (program_id, title) VALUES ($1,'L') RETURNING id`, prog)
	courseA := seed(`INSERT INTO courses (level_id,title,slug,audience,is_published) VALUES ($1,'Sup Course A','sup-it-a','student',TRUE) RETURNING id`, lvl)
	courseB := seed(`INSERT INTO courses (level_id,title,slug,audience,is_published) VALUES ($1,'Sup Course B','sup-it-b','student',TRUE) RETURNING id`, lvl)
	modA := seed(`INSERT INTO modules (course_id,title,position) VALUES ($1,'M',1) RETURNING id`, courseA)
	lesA := seed(`INSERT INTO lessons (module_id,title,position,is_published) VALUES ($1,'Lesson A1',1,TRUE) RETURNING id`, modA)
	asgA := seed(`INSERT INTO assignments (lesson_id,title,assignment_type,points,is_published) VALUES ($1,'Code A','code',10,TRUE) RETURNING id`, lesA)
	modB := seed(`INSERT INTO modules (course_id,title,position) VALUES ($1,'MB',1) RETURNING id`, courseB)
	lesB := seed(`INSERT INTO lessons (module_id,title,position,is_published) VALUES ($1,'Lesson B1',1,TRUE) RETURNING id`, modB)

	stu1 := seed(`INSERT INTO users (email,password_hash,first_name,last_name,role) VALUES ('sup-s1@it.local','x','Ayan','One','student') RETURNING id`)
	stu2 := seed(`INSERT INTO users (email,password_hash,first_name,last_name,role) VALUES ('sup-s2@it.local','x','Bek','Two','student') RETURNING id`)
	par := seed(`INSERT INTO users (email,password_hash,first_name,role) VALUES ('sup-p@it.local','x','Mukhtar','parent') RETURNING id`)
	adm := seed(`INSERT INTO users (email,password_hash,first_name,role) VALUES ('sup-a@it.local','x','Adm','admin') RETURNING id`)
	teach := seed(`INSERT INTO users (email,password_hash,first_name,role) VALUES ('sup-t@it.local','x','Tea','teacher') RETURNING id`)
	defer pool.Exec(ctx, `DELETE FROM users WHERE id = ANY($1)`, []int64{stu1, stu2, par, adm, teach})

	// stu1 enrolled in course A; par linked to stu1; stu2 enrolled in course B
	exec(`INSERT INTO enrollments (student_id,course_id,status) VALUES ($1,$2,'active')`, stu1, courseA)
	exec(`INSERT INTO enrollments (student_id,course_id,status) VALUES ($1,$2,'active')`, stu2, courseB)
	exec(`INSERT INTO parent_children (parent_id,child_id) VALUES ($1,$2)`, par, stu1)

	repo := NewRepository(pool)
	svc := NewService(repo)
	audit := &fakeAudit{}
	adminSvc := NewAdminService(repo, audit)
	defer pool.Exec(ctx, `DELETE FROM support_threads WHERE user_id = ANY($1)`, []int64{stu1, stu2, par})

	// 1 — student creates a thread with lesson context
	th, err := svc.CreateThread(ctx, stu1, "student", CreateThreadRequest{
		Subject: "Не проходит тест", Category: "lesson", LessonID: &lesA,
		Message: "Не понимаю, почему код не проходит тест",
	})
	if err != nil {
		t.Fatalf("student create: %v", err)
	}
	if th.About.CourseTitle == nil || *th.About.CourseTitle != "Sup Course A" || th.Status != StatusWaitingStaff {
		t.Fatalf("thread context wrong: %+v", th)
	}

	// 2 — student sees own thread
	mine, _ := svc.ListThreads(ctx, stu1)
	if len(mine) != 1 || mine[0].ID != th.ID {
		t.Fatalf("student should see 1 own thread, got %+v", mine)
	}

	// 3 — student cannot see another student's thread
	if _, err := svc.GetThread(ctx, stu2, th.ID); !errors.Is(err, ErrThreadNotFound) {
		t.Fatalf("cross-student read: want ErrThreadNotFound, got %v", err)
	}
	if _, err := svc.ListMessages(ctx, stu2, th.ID, 0, 50); !errors.Is(err, ErrThreadNotFound) {
		t.Fatalf("cross-student messages: want ErrThreadNotFound, got %v", err)
	}

	// 12/13 — course + assignment context ownership validated
	if _, err := svc.CreateThread(ctx, stu1, "student", CreateThreadRequest{
		Subject: "x", Category: "course", CourseID: &courseB, Message: "hi",
	}); !errors.Is(err, ErrCourseAccess) {
		t.Fatalf("student not enrolled in B: want ErrCourseAccess, got %v", err)
	}

	// 4 — parent creates a thread for the linked child (about course A)
	pth, err := svc.CreateThread(ctx, par, "parent", CreateThreadRequest{
		Subject: "Вопрос по прогрессу", Category: "progress", StudentID: &stu1, CourseID: &courseA,
		Message: "Почему прогресс остановился?",
	})
	if err != nil {
		t.Fatalf("parent create: %v", err)
	}
	if !pth.IsParentThread || pth.About.StudentName != "Ayan One" {
		t.Fatalf("parent thread wrong: %+v", pth)
	}

	// 5 — parent cannot reference an unrelated child
	if _, err := svc.CreateThread(ctx, par, "parent", CreateThreadRequest{
		Subject: "x", Category: "general", StudentID: &stu2, Message: "hi",
	}); !errors.Is(err, ErrForbiddenChild) {
		t.Fatalf("parent unrelated child: want ErrForbiddenChild, got %v", err)
	}
	// parent cannot reference a course the *child* is not enrolled in
	if _, err := svc.CreateThread(ctx, par, "parent", CreateThreadRequest{
		Subject: "x", Category: "course", StudentID: &stu1, CourseID: &courseB, Message: "hi",
	}); !errors.Is(err, ErrCourseAccess) {
		t.Fatalf("parent child-not-enrolled: want ErrCourseAccess, got %v", err)
	}

	// 6 — admin lists threads
	items, meta, err := adminSvc.List(ctx, adm, AdminFilter{})
	if err != nil || meta.Total < 2 {
		t.Fatalf("admin list: %+v %v (total=%d)", items, err, meta.Total)
	}
	// filter by kind
	sOnly, _, _ := adminSvc.List(ctx, adm, AdminFilter{Kind: "student"})
	for _, it := range sOnly {
		if it.Kind != "student" {
			t.Fatalf("kind filter leaked a %s thread", it.Kind)
		}
	}

	// 8 — after the student's message the student has NO unread (their own msg),
	//     but the thread is waiting_staff. Admin has unread.
	uc, _ := svc.UnreadCount(ctx, stu1)
	if uc.Messages != 0 {
		t.Fatalf("student unread after own message: %+v", uc)
	}
	auc, _ := adminSvc.UnreadCount(ctx, adm)
	if auc.Threads < 2 {
		t.Fatalf("admin unread threads: %+v", auc)
	}

	// 7 — admin replies -> thread waiting_user, student gets unread
	if _, err := adminSvc.PostMessage(ctx, adm, th.ID, "Давайте посмотрим вместе. Пришлите текст ошибки.", false); err != nil {
		t.Fatalf("admin reply: %v", err)
	}
	after, _ := repo.ThreadByID(ctx, th.ID)
	if after.Status != StatusWaitingUser {
		t.Fatalf("after staff reply want waiting_user, got %s", after.Status)
	}
	uc, _ = svc.UnreadCount(ctx, stu1)
	if uc.Messages != 1 || uc.Threads != 1 {
		t.Fatalf("student unread after staff reply: %+v", uc)
	}

	// 10 — internal note hidden from the student
	if _, err := adminSvc.PostMessage(ctx, adm, th.ID, "Возможно, стоит передать преподавателю Python", true); err != nil {
		t.Fatalf("internal note: %v", err)
	}
	umsgs, _ := svc.ListMessages(ctx, stu1, th.ID, 0, 50)
	for _, m := range umsgs {
		if m.IsInternal || strings.Contains(m.Body, "передать преподавателю") {
			t.Fatalf("internal note leaked to student: %+v", m)
		}
	}
	amsgs, _ := adminSvc.ListMessages(ctx, adm, th.ID, 0, 50)
	var sawInternal bool
	for _, m := range amsgs {
		if m.IsInternal {
			sawInternal = true
		}
	}
	if !sawInternal {
		t.Fatal("admin should see the internal note")
	}
	// the internal note must not have re-set the student-facing status
	after, _ = repo.ThreadByID(ctx, th.ID)
	if after.Status != StatusWaitingUser {
		t.Fatalf("internal note changed status to %s", after.Status)
	}
	// ...and must not count as student unread
	uc, _ = svc.UnreadCount(ctx, stu1)
	if uc.Messages != 1 {
		t.Fatalf("internal note counted as student unread: %+v", uc)
	}

	// 9 — student replies -> waiting_staff, admin unread grows
	if _, err := svc.PostMessage(ctx, stu1, "student", th.ID, "Вот ошибка: NameError"); err != nil {
		t.Fatalf("student reply: %v", err)
	}
	after, _ = repo.ThreadByID(ctx, th.ID)
	if after.Status != StatusWaitingStaff {
		t.Fatalf("after student reply want waiting_staff, got %s", after.Status)
	}

	// 19 — student marks read -> unread clears
	if err := svc.MarkRead(ctx, stu1, th.ID); err != nil {
		t.Fatalf("mark read: %v", err)
	}
	uc, _ = svc.UnreadCount(ctx, stu1)
	if uc.Messages != 0 {
		t.Fatalf("student unread after read: %+v", uc)
	}

	// 11 — spoofed sender role is ignored (server always uses the passed role)
	m, _ := svc.PostMessage(ctx, stu1, "student", th.ID, "spoof check")
	if m.SenderRole != "student" {
		t.Fatalf("sender role not derived from caller: %s", m.SenderRole)
	}
	// a student cannot post an internal note (Internal flag is ignored for users)
	var lastInternal bool
	rows, _ := repo.Messages(ctx, th.ID, 0, 5, true)
	for _, r := range rows {
		if r.SenderUserID == stu1 && r.IsInternal {
			lastInternal = true
		}
	}
	if lastInternal {
		t.Fatal("student managed to create an internal note")
	}

	// 16 — message length validation
	if _, err := svc.PostMessage(ctx, stu1, "student", th.ID, ""); !errors.Is(err, ErrEmptyMessage) {
		t.Fatalf("empty message: want ErrEmptyMessage, got %v", err)
	}
	if _, err := svc.PostMessage(ctx, stu1, "student", th.ID, strings.Repeat("x", MaxMessageLen+1)); !errors.Is(err, ErrMessageTooLong) {
		t.Fatalf("long message: want ErrMessageTooLong, got %v", err)
	}

	// 15 — message pagination
	page1, _ := svc.ListMessages(ctx, stu1, th.ID, 0, 2)
	if len(page1) != 2 {
		t.Fatalf("page size: want 2, got %d", len(page1))
	}
	oldest := page1[0].ID
	page2, _ := svc.ListMessages(ctx, stu1, th.ID, oldest, 2)
	for _, mm := range page2 {
		if mm.ID >= oldest {
			t.Fatalf("pagination: message %d not before %d", mm.ID, oldest)
		}
	}

	// 17 — admin assigns the thread (to self); non-admin target rejected
	if _, err := adminSvc.Assign(ctx, adm, th.ID, &stu1); !errors.Is(err, ErrNotAnAdmin) {
		t.Fatalf("assign to student: want ErrNotAnAdmin, got %v", err)
	}
	if _, err := adminSvc.Assign(ctx, adm, th.ID, &adm); err != nil {
		t.Fatalf("assign to admin: %v", err)
	}
	if audit.n == 0 {
		t.Fatal("assign should write an audit row")
	}
	assignedOnly, _, _ := adminSvc.List(ctx, adm, AdminFilter{Assigned: "me"})
	var found bool
	for _, it := range assignedOnly {
		if it.ID == th.ID {
			found = true
		}
	}
	if !found {
		t.Fatal("assigned-to-me filter did not return the assigned thread")
	}

	// 18 — close then reopen; a user posting to a closed thread auto-reopens it
	if _, err := adminSvc.SetStatus(ctx, adm, th.ID, StatusClosed); err != nil {
		t.Fatalf("close: %v", err)
	}
	closed, _ := repo.ThreadByID(ctx, th.ID)
	if closed.Status != StatusClosed || closed.ClosedAt == nil {
		t.Fatalf("close did not stick: %+v", closed)
	}
	if _, err := svc.PostMessage(ctx, stu1, "student", th.ID, "ещё вопрос"); err != nil {
		t.Fatalf("post to closed thread: %v", err)
	}
	reopened, _ := repo.ThreadByID(ctx, th.ID)
	if reopened.Status != StatusWaitingStaff {
		t.Fatalf("closed thread did not auto-reopen: %s", reopened.Status)
	}

	// 14 — admin context panel reads live LMS state
	detail, err := adminSvc.Get(ctx, adm, pth.ID)
	if err != nil {
		t.Fatalf("admin get parent thread: %v", err)
	}
	if detail.Context.Student.Name != "Ayan One" || detail.Context.Parent == nil || detail.Context.ParentLinked == nil || !*detail.Context.ParentLinked {
		t.Fatalf("parent-thread context wrong: %+v", detail.Context)
	}
	if len(detail.Context.Courses) == 0 || detail.Context.FocusCourse == nil || detail.Context.FocusCourse.ID != courseA {
		t.Fatalf("focus course wrong: %+v", detail.Context)
	}

	// invalid category / status rejected
	if _, err := svc.CreateThread(ctx, stu1, "student", CreateThreadRequest{Subject: "x", Category: "banana", Message: "hi"}); !errors.Is(err, ErrInvalidCategory) {
		t.Fatalf("bad category: want ErrInvalidCategory, got %v", err)
	}
	if _, err := adminSvc.SetStatus(ctx, adm, th.ID, "frozen"); !errors.Is(err, ErrInvalidStatus) {
		t.Fatalf("bad status: want ErrInvalidStatus, got %v", err)
	}

	_ = lesB
	_ = asgA
	_ = teach
}

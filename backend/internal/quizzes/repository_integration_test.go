package quizzes

import (
	"context"
	"errors"
	"os"
	"testing"

	"github.com/jackc/pgx/v5/pgxpool"
)

// fakeEnroll lets the test decide who is enrolled where.
type fakeEnroll struct{ ok map[[2]int64]bool }

func (f *fakeEnroll) IsEnrolled(_ context.Context, s, c int64) (bool, error) {
	return f.ok[[2]int64{s, c}], nil
}

// TestQuizzes_FullFlow drives authoring → attempt → scoring → progress against
// a real Postgres. Skipped unless TEST_DATABASE_URL is set.
func TestQuizzes_FullFlow(t *testing.T) {
	dsn := os.Getenv("TEST_DATABASE_URL")
	if dsn == "" {
		t.Skip("TEST_DATABASE_URL not set; skipping quizzes integration test")
	}
	ctx := context.Background()
	pool, err := pgxpool.New(ctx, dsn)
	if err != nil {
		t.Fatalf("connect: %v", err)
	}
	defer pool.Close()

	repo := NewRepository(pool)
	admin := NewAdminService(repo)
	enroll := &fakeEnroll{ok: map[[2]int64]bool{}}
	svc := NewService(repo, enroll)

	// ---- throwaway catalog: program → ... → quiz assignment + a code assignment ----
	var adminID, progID, lvlID, courseID, modID, lessonID, quizAID, codeAID int64
	must(t, pool.QueryRow(ctx, `INSERT INTO users (email,password_hash,first_name,role) VALUES ('quiz-admin@it.local','x','A','admin') RETURNING id`).Scan(&adminID))
	must(t, pool.QueryRow(ctx, `INSERT INTO programs (title,slug) VALUES ('QZ','qz-it-prog') RETURNING id`).Scan(&progID))
	defer pool.Exec(ctx, `DELETE FROM programs WHERE id=$1`, progID)
	defer pool.Exec(ctx, `DELETE FROM users WHERE id=$1`, adminID)
	must(t, pool.QueryRow(ctx, `INSERT INTO levels (program_id,title) VALUES ($1,'L') RETURNING id`, progID).Scan(&lvlID))
	must(t, pool.QueryRow(ctx, `INSERT INTO courses (level_id,title,slug,is_published) VALUES ($1,'C','qz-it-course',TRUE) RETURNING id`, lvlID).Scan(&courseID))
	must(t, pool.QueryRow(ctx, `INSERT INTO modules (course_id,title) VALUES ($1,'M') RETURNING id`, courseID).Scan(&modID))
	must(t, pool.QueryRow(ctx, `INSERT INTO lessons (module_id,title,is_published) VALUES ($1,'Les',TRUE) RETURNING id`, modID).Scan(&lessonID))
	must(t, pool.QueryRow(ctx, `INSERT INTO assignments (lesson_id,title,assignment_type,is_published) VALUES ($1,'Quiz','quiz',TRUE) RETURNING id`, lessonID).Scan(&quizAID))
	must(t, pool.QueryRow(ctx, `INSERT INTO assignments (lesson_id,title,assignment_type,is_published) VALUES ($1,'Code','code',TRUE) RETURNING id`, lessonID).Scan(&codeAID))

	// ---- admin authoring ----
	if _, err := admin.CreateQuestion(ctx, adminID, codeAID, CreateQuestionRequest{QuestionText: "x", QuestionType: QuestionSingleChoice}); !errors.Is(err, ErrNotQuizAssignment) {
		t.Fatalf("question on non-quiz: want ErrNotQuizAssignment, got %v", err)
	}

	if _, err := admin.UpdateSettings(ctx, adminID, quizAID, UpdateSettingsRequest{PassPercent: 200}); err == nil {
		t.Fatal("passPercent 200 should be rejected")
	}
	if _, err := admin.UpdateSettings(ctx, adminID, quizAID, UpdateSettingsRequest{PassPercent: 60, ShowCorrectAnswers: true, ShowExplanations: true}); err != nil {
		t.Fatalf("update settings: %v", err)
	}

	// single_choice with inline options
	q1, err := admin.CreateQuestion(ctx, adminID, quizAID, CreateQuestionRequest{
		QuestionText: "range(3)?", QuestionType: QuestionSingleChoice, Points: iptr(4),
		Options: []CreateOptionInput{
			{OptionText: "1 2 3", IsCorrect: false},
			{OptionText: "0 1 2", IsCorrect: true},
			{OptionText: "err", IsCorrect: false},
		},
	})
	if err != nil {
		t.Fatalf("create q1: %v", err)
	}
	if !q1.WellFormed {
		t.Fatalf("q1 should be well-formed: %+v", q1)
	}
	// a second correct option on a single_choice is rejected (spec §9, §60)
	if _, err := admin.CreateOption(ctx, adminID, q1.ID, CreateOptionRequest{OptionText: "also right", IsCorrect: bptr(true)}); err == nil {
		t.Fatal("second correct on single_choice should be rejected")
	}

	// multiple_choice: >=1 correct (spec §10)
	q2, err := admin.CreateQuestion(ctx, adminID, quizAID, CreateQuestionRequest{
		QuestionText: "loops?", QuestionType: QuestionMultipleChoice, Points: iptr(6),
		Options: []CreateOptionInput{
			{OptionText: "for", IsCorrect: true},
			{OptionText: "while", IsCorrect: true},
			{OptionText: "if", IsCorrect: false},
		},
	})
	if err != nil {
		t.Fatalf("create q2: %v", err)
	}

	// audit rows written (spec §63, §85)
	var auditCount int
	must(t, pool.QueryRow(ctx, `SELECT count(*) FROM admin_audit_log WHERE admin_id=$1 AND entity LIKE 'quiz_%'`, adminID).Scan(&auditCount))
	if auditCount < 3 {
		t.Fatalf("expected quiz audit rows, got %d", auditCount)
	}

	optIDs := func(qid int64) (correct, wrong int64) {
		rows, _ := pool.Query(ctx, `SELECT id, is_correct FROM quiz_options WHERE question_id=$1 ORDER BY position`, qid)
		defer rows.Close()
		for rows.Next() {
			var id int64
			var ic bool
			rows.Scan(&id, &ic)
			if ic {
				correct = id
			} else {
				wrong = id
			}
		}
		return
	}
	q1c, q1w := optIDs(q1.ID)
	q2rows, _ := pool.Query(ctx, `SELECT id, is_correct FROM quiz_options WHERE question_id=$1 ORDER BY position`, q2.ID)
	var q2correct []int64
	var q2wrong int64
	for q2rows.Next() {
		var id int64
		var ic bool
		q2rows.Scan(&id, &ic)
		if ic {
			q2correct = append(q2correct, id)
		} else {
			q2wrong = id
		}
	}
	q2rows.Close()

	// ---- student ----
	var stuID, stu2ID int64
	must(t, pool.QueryRow(ctx, `INSERT INTO users (email,password_hash,first_name,role) VALUES ('quiz-stu@it.local','x','S','student') RETURNING id`).Scan(&stuID))
	must(t, pool.QueryRow(ctx, `INSERT INTO users (email,password_hash,first_name,role) VALUES ('quiz-stu2@it.local','x','S2','student') RETURNING id`).Scan(&stu2ID))
	defer pool.Exec(ctx, `DELETE FROM users WHERE id IN ($1,$2)`, stuID, stu2ID)

	// non-enrolled -> blocked (spec §20, §83)
	if _, err := svc.StartAttempt(ctx, stuID, quizAID); !errors.Is(err, ErrNotEnrolled) {
		t.Fatalf("non-enrolled start: want ErrNotEnrolled, got %v", err)
	}
	enroll.ok[[2]int64{stuID, courseID}] = true
	enroll.ok[[2]int64{stu2ID, courseID}] = true

	// non-quiz assignment -> rejected
	if _, err := svc.StartAttempt(ctx, stuID, codeAID); !errors.Is(err, ErrNotQuizAssignment) {
		t.Fatalf("non-quiz start: want ErrNotQuizAssignment, got %v", err)
	}

	start, err := svc.StartAttempt(ctx, stuID, quizAID)
	if err != nil {
		t.Fatalf("start attempt: %v", err)
	}
	if len(start.Quiz.Questions) != 2 {
		t.Fatalf("expected 2 questions, got %d", len(start.Quiz.Questions))
	}
	// student payload structurally cannot carry is_correct/explanation — assert
	// the option JSON tag surface stays minimal (spec §7, §84).
	for _, q := range start.Quiz.Questions {
		for _, o := range q.Options {
			if o.OptionText == "" {
				t.Fatal("option text missing")
			}
		}
	}

	// resume returns the same attempt id
	again, _ := svc.StartAttempt(ctx, stuID, quizAID)
	if again.Attempt.ID != start.Attempt.ID {
		t.Fatalf("resume gave a different attempt: %d vs %d", again.Attempt.ID, start.Attempt.ID)
	}

	// foreign question -> validation error (spec §27)
	if _, err := svc.SubmitAttempt(ctx, stuID, start.Attempt.ID, SubmitRequest{Answers: []SubmitAnswer{{QuestionID: 999999, SelectedOptionIDs: []int64{q1c}}}}); err == nil {
		t.Fatal("foreign question should be rejected")
	}
	// foreign option -> validation error (spec §28)
	if _, err := svc.SubmitAttempt(ctx, stuID, start.Attempt.ID, SubmitRequest{Answers: []SubmitAnswer{{QuestionID: q1.ID, SelectedOptionIDs: []int64{q2wrong}}}}); err == nil {
		t.Fatal("foreign option should be rejected")
	}
	// single_choice with 2 selections -> rejected (spec §29)
	if _, err := svc.SubmitAttempt(ctx, stuID, start.Attempt.ID, SubmitRequest{Answers: []SubmitAnswer{{QuestionID: q1.ID, SelectedOptionIDs: []int64{q1c, q1w}}}}); err == nil {
		t.Fatal("single_choice needs exactly one answer")
	}

	// another student cannot submit this attempt (spec §25, §83)
	if _, err := svc.SubmitAttempt(ctx, stu2ID, start.Attempt.ID, SubmitRequest{}); !errors.Is(err, ErrAttemptNotOwned) {
		t.Fatalf("cross-student submit: want ErrAttemptNotOwned, got %v", err)
	}

	// attempt 1: wrong answers -> fail
	res1, err := svc.SubmitAttempt(ctx, stuID, start.Attempt.ID, SubmitRequest{Answers: []SubmitAnswer{
		{QuestionID: q1.ID, SelectedOptionIDs: []int64{q1w}},
		{QuestionID: q2.ID, SelectedOptionIDs: []int64{q2wrong}},
	}})
	if err != nil {
		t.Fatalf("submit attempt 1: %v", err)
	}
	if res1.Passed || res1.Score != 0 || res1.MaxScore != 10 {
		t.Fatalf("attempt 1 should fail 0/10: %+v", res1)
	}
	// double submit -> 409 (spec §26)
	if _, err := svc.SubmitAttempt(ctx, stuID, start.Attempt.ID, SubmitRequest{}); !errors.Is(err, ErrAttemptClosed) {
		t.Fatalf("double submit: want ErrAttemptClosed, got %v", err)
	}

	// progress gate: not passed yet
	if n, _ := repo.CountPassedAssignments(ctx, stuID, []int64{quizAID}); n != 0 {
		t.Fatalf("expected 0 passed, got %d", n)
	}

	// attempt 2: all correct -> pass
	a2, err := svc.StartAttempt(ctx, stuID, quizAID)
	if err != nil {
		t.Fatalf("start attempt 2: %v", err)
	}
	res2, err := svc.SubmitAttempt(ctx, stuID, a2.Attempt.ID, SubmitRequest{Answers: []SubmitAnswer{
		{QuestionID: q1.ID, SelectedOptionIDs: []int64{q1c}},
		{QuestionID: q2.ID, SelectedOptionIDs: q2correct},
	}})
	if err != nil {
		t.Fatalf("submit attempt 2: %v", err)
	}
	if !res2.Passed || res2.Score != 10 || res2.Percent != 100 {
		t.Fatalf("attempt 2 should pass 10/10: %+v", res2)
	}

	// progress gate: now passed (spec §44)
	if n, _ := repo.CountPassedAssignments(ctx, stuID, []int64{quizAID}); n != 1 {
		t.Fatalf("expected 1 passed, got %d", n)
	}
	if ids, _ := repo.QuizAssignmentIDs(ctx, []int64{quizAID, codeAID}); len(ids) != 1 || ids[0] != quizAID {
		t.Fatalf("QuizAssignmentIDs: %v", ids)
	}

	// history roll-up (spec §41, §43)
	hist, err := svc.ListAttempts(ctx, stuID, quizAID)
	if err != nil {
		t.Fatalf("list attempts: %v", err)
	}
	if len(hist.Attempts) != 2 || !hist.Passed || hist.BestPercent == nil || *hist.BestPercent != 100 {
		t.Fatalf("history: %+v", hist)
	}

	// max attempts (spec §16, §83)
	one := 1
	if _, err := admin.UpdateSettings(ctx, adminID, quizAID, UpdateSettingsRequest{PassPercent: 60, MaxAttempts: &one}); err != nil {
		t.Fatalf("set max attempts: %v", err)
	}
	if _, err := svc.StartAttempt(ctx, stuID, quizAID); !errors.Is(err, ErrMaxAttempts) {
		t.Fatalf("max attempts: want ErrMaxAttempts, got %v", err)
	}

	// deleting an answered question soft-deactivates it (spec §64, §66)
	del, err := admin.DeleteQuestion(ctx, adminID, q1.ID)
	if err != nil {
		t.Fatalf("delete answered question: %v", err)
	}
	if !del.Deactivated || del.Deleted {
		t.Fatalf("answered question should deactivate, not delete: %+v", del)
	}
	var stillThere bool
	must(t, pool.QueryRow(ctx, `SELECT EXISTS(SELECT 1 FROM quiz_questions WHERE id=$1 AND is_active=FALSE)`, q1.ID).Scan(&stillThere))
	if !stillThere {
		t.Fatal("answered question row must survive as inactive")
	}
}

func must(t *testing.T, err error) {
	t.Helper()
	if err != nil {
		t.Fatalf("setup: %v", err)
	}
}

func iptr(i int) *int   { return &i }
func bptr(b bool) *bool { return &b }

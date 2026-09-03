package quizzes

import (
	"context"
	"errors"
	"fmt"
	"strings"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Repository struct {
	pool *pgxpool.Pool
}

func NewRepository(pool *pgxpool.Pool) *Repository {
	return &Repository{pool: pool}
}

// classify maps a raw pgx error to a quizzes sentinel.
func classify(err error) error {
	if err == nil {
		return nil
	}
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrQuizNotFound
	}
	var pgErr *pgconn.PgError
	if errors.As(err, &pgErr) {
		switch pgErr.Code {
		case "23503": // foreign_key_violation
			return invalid("referenced record does not exist")
		case "23514": // check_violation
			return invalid("a value is out of its allowed range")
		}
	}
	return err
}

/* ===================================================================
   assignment context
   =================================================================== */

// AssignmentMeta returns the joined assignment context. ErrQuizNotFound if the
// assignment does not exist.
func (r *Repository) AssignmentMeta(ctx context.Context, assignmentID int64) (assignmentMeta, error) {
	var m assignmentMeta
	m.AssignmentID = assignmentID
	err := r.pool.QueryRow(ctx, `
		SELECT a.title, a.assignment_type, a.is_published, l.is_published, m.course_id
		FROM assignments a
		JOIN lessons l ON l.id = a.lesson_id
		JOIN modules m ON m.id = l.module_id
		WHERE a.id = $1
	`, assignmentID).Scan(&m.Title, &m.AssignmentType, &m.IsPublished, &m.LessonPublished, &m.CourseID)
	if errors.Is(err, pgx.ErrNoRows) {
		return assignmentMeta{}, ErrQuizNotFound
	}
	if err != nil {
		return assignmentMeta{}, fmt.Errorf("assignment meta: %w", err)
	}
	return m, nil
}

/* ===================================================================
   settings
   =================================================================== */

// GetSettings returns the quiz_settings row, or the defaults if none exists.
func (r *Repository) GetSettings(ctx context.Context, assignmentID int64) (Settings, error) {
	s := defaultSettings(assignmentID)
	err := r.pool.QueryRow(ctx, `
		SELECT pass_percent, max_attempts, show_correct_answers, show_explanations
		FROM quiz_settings WHERE assignment_id = $1
	`, assignmentID).Scan(&s.PassPercent, &s.MaxAttempts, &s.ShowCorrectAnswers, &s.ShowExplanations)
	if errors.Is(err, pgx.ErrNoRows) {
		return defaultSettings(assignmentID), nil
	}
	if err != nil {
		return Settings{}, fmt.Errorf("get quiz settings: %w", err)
	}
	return s, nil
}

// UpsertSettings writes the settings row (full replace).
func (r *Repository) UpsertSettings(ctx context.Context, s Settings) error {
	_, err := r.pool.Exec(ctx, `
		INSERT INTO quiz_settings (assignment_id, pass_percent, max_attempts, show_correct_answers, show_explanations)
		VALUES ($1, $2, $3, $4, $5)
		ON CONFLICT (assignment_id) DO UPDATE SET
			pass_percent = EXCLUDED.pass_percent,
			max_attempts = EXCLUDED.max_attempts,
			show_correct_answers = EXCLUDED.show_correct_answers,
			show_explanations = EXCLUDED.show_explanations,
			updated_at = NOW()
	`, s.AssignmentID, s.PassPercent, s.MaxAttempts, s.ShowCorrectAnswers, s.ShowExplanations)
	return classify(err)
}

/* ===================================================================
   questions + options (loaded together)
   =================================================================== */

// questionsWithOptions loads questions for an assignment plus their options.
// activeOnly restricts to is_active questions AND is_active options (the
// student view); otherwise every row is returned (the admin view).
func (r *Repository) questionsWithOptions(ctx context.Context, assignmentID int64, activeOnly bool) ([]Question, error) {
	qCond, oCond := "", ""
	if activeOnly {
		qCond = " AND is_active = TRUE"
		oCond = " AND o.is_active = TRUE"
	}

	qRows, err := r.pool.Query(ctx, `
		SELECT id, assignment_id, question_text, question_type, points, position, explanation, is_active
		FROM quiz_questions
		WHERE assignment_id = $1`+qCond+`
		ORDER BY position ASC, id ASC
	`, assignmentID)
	if err != nil {
		return nil, fmt.Errorf("list quiz questions: %w", err)
	}
	defer qRows.Close()

	var questions []Question
	byID := map[int64]int{} // question id -> index in questions
	for qRows.Next() {
		var q Question
		if err := qRows.Scan(&q.ID, &q.AssignmentID, &q.Text, &q.Type, &q.Points, &q.Position, &q.Explanation, &q.IsActive); err != nil {
			return nil, fmt.Errorf("scan quiz question: %w", err)
		}
		q.Options = []Option{}
		byID[q.ID] = len(questions)
		questions = append(questions, q)
	}
	if err := qRows.Err(); err != nil {
		return nil, err
	}
	if len(questions) == 0 {
		return []Question{}, nil
	}

	oRows, err := r.pool.Query(ctx, `
		SELECT o.id, o.question_id, o.option_text, o.is_correct, o.position, o.is_active
		FROM quiz_options o
		JOIN quiz_questions q ON q.id = o.question_id
		WHERE q.assignment_id = $1`+oCond+`
		ORDER BY o.position ASC, o.id ASC
	`, assignmentID)
	if err != nil {
		return nil, fmt.Errorf("list quiz options: %w", err)
	}
	defer oRows.Close()
	for oRows.Next() {
		var o Option
		if err := oRows.Scan(&o.ID, &o.QuestionID, &o.Text, &o.IsCorrect, &o.Position, &o.IsActive); err != nil {
			return nil, fmt.Errorf("scan quiz option: %w", err)
		}
		if idx, ok := byID[o.QuestionID]; ok {
			questions[idx].Options = append(questions[idx].Options, o)
		}
	}
	return questions, oRows.Err()
}

// ActiveQuestions is the student / scoring view.
func (r *Repository) ActiveQuestions(ctx context.Context, assignmentID int64) ([]Question, error) {
	return r.questionsWithOptions(ctx, assignmentID, true)
}

// AllQuestions is the admin authoring view.
func (r *Repository) AllQuestions(ctx context.Context, assignmentID int64) ([]Question, error) {
	return r.questionsWithOptions(ctx, assignmentID, false)
}

// GetQuestion returns one question (no options) plus its assignment id.
func (r *Repository) GetQuestion(ctx context.Context, id int64) (Question, error) {
	var q Question
	err := r.pool.QueryRow(ctx, `
		SELECT id, assignment_id, question_text, question_type, points, position, explanation, is_active
		FROM quiz_questions WHERE id = $1
	`, id).Scan(&q.ID, &q.AssignmentID, &q.Text, &q.Type, &q.Points, &q.Position, &q.Explanation, &q.IsActive)
	if errors.Is(err, pgx.ErrNoRows) {
		return Question{}, ErrQuestionNotFound
	}
	return q, err
}

// QuestionWithOptions returns one question and its options (all activity states).
func (r *Repository) QuestionWithOptions(ctx context.Context, id int64) (Question, error) {
	q, err := r.GetQuestion(ctx, id)
	if err != nil {
		return Question{}, err
	}
	rows, err := r.pool.Query(ctx, `
		SELECT id, question_id, option_text, is_correct, position, is_active
		FROM quiz_options WHERE question_id = $1 ORDER BY position, id
	`, id)
	if err != nil {
		return Question{}, fmt.Errorf("question options: %w", err)
	}
	defer rows.Close()
	for rows.Next() {
		var o Option
		if err := rows.Scan(&o.ID, &o.QuestionID, &o.Text, &o.IsCorrect, &o.Position, &o.IsActive); err != nil {
			return Question{}, err
		}
		q.Options = append(q.Options, o)
	}
	return q, rows.Err()
}

func (r *Repository) CreateQuestion(ctx context.Context, assignmentID int64, text, qType string, points, position int, explanation *string, isActive bool) (int64, error) {
	var id int64
	err := r.pool.QueryRow(ctx, `
		INSERT INTO quiz_questions (assignment_id, question_text, question_type, points, position, explanation, is_active)
		VALUES ($1,$2,$3,$4,$5,$6,$7) RETURNING id
	`, assignmentID, text, qType, points, position, explanation, isActive).Scan(&id)
	return id, classify(err)
}

func (r *Repository) UpdateQuestion(ctx context.Context, id int64, fields map[string]any) error {
	if len(fields) == 0 {
		return nil
	}
	set := make([]string, 0, len(fields)+1)
	args := make([]any, 0, len(fields)+1)
	for col, val := range fields {
		args = append(args, val)
		set = append(set, fmt.Sprintf("%s = $%d", col, len(args)))
	}
	set = append(set, "updated_at = NOW()")
	args = append(args, id)
	tag, err := r.pool.Exec(ctx, fmt.Sprintf(
		"UPDATE quiz_questions SET %s WHERE id = $%d", strings.Join(set, ", "), len(args)), args...)
	if err != nil {
		return classify(err)
	}
	if tag.RowsAffected() == 0 {
		return ErrQuestionNotFound
	}
	return nil
}

func (r *Repository) DeleteQuestion(ctx context.Context, id int64) error {
	tag, err := r.pool.Exec(ctx, `DELETE FROM quiz_questions WHERE id = $1`, id)
	if err != nil {
		return classify(err)
	}
	if tag.RowsAffected() == 0 {
		return ErrQuestionNotFound
	}
	return nil
}

func (r *Repository) QuestionHasHistory(ctx context.Context, id int64) (bool, error) {
	var ok bool
	err := r.pool.QueryRow(ctx,
		`SELECT EXISTS (SELECT 1 FROM quiz_attempt_answers WHERE question_id = $1)`, id).Scan(&ok)
	return ok, err
}

/* ---- options ---- */

func (r *Repository) GetOption(ctx context.Context, id int64) (Option, error) {
	var o Option
	err := r.pool.QueryRow(ctx, `
		SELECT id, question_id, option_text, is_correct, position, is_active
		FROM quiz_options WHERE id = $1
	`, id).Scan(&o.ID, &o.QuestionID, &o.Text, &o.IsCorrect, &o.Position, &o.IsActive)
	if errors.Is(err, pgx.ErrNoRows) {
		return Option{}, ErrOptionNotFound
	}
	return o, err
}

func (r *Repository) CreateOption(ctx context.Context, questionID int64, text string, isCorrect bool, position int) (int64, error) {
	var id int64
	err := r.pool.QueryRow(ctx, `
		INSERT INTO quiz_options (question_id, option_text, is_correct, position)
		VALUES ($1,$2,$3,$4) RETURNING id
	`, questionID, text, isCorrect, position).Scan(&id)
	return id, classify(err)
}

func (r *Repository) UpdateOption(ctx context.Context, id int64, fields map[string]any) error {
	if len(fields) == 0 {
		return nil
	}
	set := make([]string, 0, len(fields)+1)
	args := make([]any, 0, len(fields)+1)
	for col, val := range fields {
		args = append(args, val)
		set = append(set, fmt.Sprintf("%s = $%d", col, len(args)))
	}
	set = append(set, "updated_at = NOW()")
	args = append(args, id)
	tag, err := r.pool.Exec(ctx, fmt.Sprintf(
		"UPDATE quiz_options SET %s WHERE id = $%d", strings.Join(set, ", "), len(args)), args...)
	if err != nil {
		return classify(err)
	}
	if tag.RowsAffected() == 0 {
		return ErrOptionNotFound
	}
	return nil
}

func (r *Repository) DeleteOption(ctx context.Context, id int64) error {
	tag, err := r.pool.Exec(ctx, `DELETE FROM quiz_options WHERE id = $1`, id)
	if err != nil {
		return classify(err)
	}
	if tag.RowsAffected() == 0 {
		return ErrOptionNotFound
	}
	return nil
}

func (r *Repository) OptionHasHistory(ctx context.Context, id int64) (bool, error) {
	var ok bool
	err := r.pool.QueryRow(ctx,
		`SELECT EXISTS (SELECT 1 FROM quiz_attempt_answer_options WHERE option_id = $1)`, id).Scan(&ok)
	return ok, err
}

// CountActiveCorrectOptions counts a question's active correct options,
// optionally excluding one id (used when validating an update).
func (r *Repository) CountActiveCorrectOptions(ctx context.Context, questionID, excludeID int64) (int, error) {
	var n int
	err := r.pool.QueryRow(ctx, `
		SELECT count(*) FROM quiz_options
		WHERE question_id = $1 AND is_active = TRUE AND is_correct = TRUE AND id <> $2
	`, questionID, excludeID).Scan(&n)
	return n, err
}

// CountActiveOptions counts a question's active options, excluding one id.
func (r *Repository) CountActiveOptions(ctx context.Context, questionID, excludeID int64) (int, error) {
	var n int
	err := r.pool.QueryRow(ctx, `
		SELECT count(*) FROM quiz_options
		WHERE question_id = $1 AND is_active = TRUE AND id <> $2
	`, questionID, excludeID).Scan(&n)
	return n, err
}

/* ===================================================================
   attempts
   =================================================================== */

const attemptCols = `id, assignment_id, student_id, status, score, max_score, percent, passed, started_at, submitted_at`

func scanAttempt(row interface{ Scan(...any) error }) (Attempt, error) {
	var a Attempt
	err := row.Scan(&a.ID, &a.AssignmentID, &a.StudentID, &a.Status, &a.Score, &a.MaxScore, &a.Percent, &a.Passed, &a.StartedAt, &a.SubmittedAt)
	return a, err
}

func (r *Repository) GetAttempt(ctx context.Context, id int64) (Attempt, error) {
	a, err := scanAttempt(r.pool.QueryRow(ctx, `SELECT `+attemptCols+` FROM quiz_attempts WHERE id = $1`, id))
	if errors.Is(err, pgx.ErrNoRows) {
		return Attempt{}, ErrAttemptNotFound
	}
	return a, err
}

// InProgressAttempt returns the student's open attempt for an assignment, if any.
func (r *Repository) InProgressAttempt(ctx context.Context, studentID, assignmentID int64) (Attempt, bool, error) {
	a, err := scanAttempt(r.pool.QueryRow(ctx, `
		SELECT `+attemptCols+` FROM quiz_attempts
		WHERE student_id = $1 AND assignment_id = $2 AND status = 'in_progress'
		ORDER BY started_at DESC, id DESC LIMIT 1
	`, studentID, assignmentID))
	if errors.Is(err, pgx.ErrNoRows) {
		return Attempt{}, false, nil
	}
	if err != nil {
		return Attempt{}, false, err
	}
	return a, true, nil
}

// CountSubmittedAttempts counts a student's submitted attempts for an assignment.
func (r *Repository) CountSubmittedAttempts(ctx context.Context, studentID, assignmentID int64) (int, error) {
	var n int
	err := r.pool.QueryRow(ctx, `
		SELECT count(*) FROM quiz_attempts
		WHERE student_id = $1 AND assignment_id = $2 AND status = 'submitted'
	`, studentID, assignmentID).Scan(&n)
	return n, err
}

func (r *Repository) CreateAttempt(ctx context.Context, studentID, assignmentID int64) (Attempt, error) {
	a, err := scanAttempt(r.pool.QueryRow(ctx, `
		INSERT INTO quiz_attempts (assignment_id, student_id, status)
		VALUES ($1, $2, 'in_progress')
		RETURNING `+attemptCols, assignmentID, studentID))
	return a, classify(err)
}

// ListAttempts returns every attempt for a student + assignment, oldest first.
func (r *Repository) ListAttempts(ctx context.Context, studentID, assignmentID int64) ([]Attempt, error) {
	rows, err := r.pool.Query(ctx, `
		SELECT `+attemptCols+` FROM quiz_attempts
		WHERE student_id = $1 AND assignment_id = $2
		ORDER BY started_at ASC, id ASC
	`, studentID, assignmentID)
	if err != nil {
		return nil, fmt.Errorf("list attempts: %w", err)
	}
	defer rows.Close()
	out := []Attempt{}
	for rows.Next() {
		a, err := scanAttempt(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, a)
	}
	return out, rows.Err()
}

// answerRow is the persisted grading of one question in an attempt.
type answerRow struct {
	QuestionID    int64
	IsCorrect     *bool
	PointsAwarded *int
}

// AttemptAnswers returns the per-question grading and the selected option ids
// for a (submitted) attempt.
func (r *Repository) AttemptAnswers(ctx context.Context, attemptID int64) (map[int64]answerRow, map[int64][]int64, error) {
	aRows, err := r.pool.Query(ctx, `
		SELECT id, question_id, is_correct, points_awarded
		FROM quiz_attempt_answers WHERE attempt_id = $1
	`, attemptID)
	if err != nil {
		return nil, nil, fmt.Errorf("attempt answers: %w", err)
	}
	defer aRows.Close()
	answers := map[int64]answerRow{}
	answerIDToQuestion := map[int64]int64{}
	for aRows.Next() {
		var id int64
		var ar answerRow
		if err := aRows.Scan(&id, &ar.QuestionID, &ar.IsCorrect, &ar.PointsAwarded); err != nil {
			return nil, nil, err
		}
		answers[ar.QuestionID] = ar
		answerIDToQuestion[id] = ar.QuestionID
	}
	if err := aRows.Err(); err != nil {
		return nil, nil, err
	}

	oRows, err := r.pool.Query(ctx, `
		SELECT ao.attempt_answer_id, ao.option_id
		FROM quiz_attempt_answer_options ao
		JOIN quiz_attempt_answers a ON a.id = ao.attempt_answer_id
		WHERE a.attempt_id = $1
	`, attemptID)
	if err != nil {
		return nil, nil, fmt.Errorf("attempt selected options: %w", err)
	}
	defer oRows.Close()
	selected := map[int64][]int64{}
	for oRows.Next() {
		var answerID, optionID int64
		if err := oRows.Scan(&answerID, &optionID); err != nil {
			return nil, nil, err
		}
		qid := answerIDToQuestion[answerID]
		selected[qid] = append(selected[qid], optionID)
	}
	return answers, selected, oRows.Err()
}

// persistedAnswer is one graded answer to write in SubmitAttemptTx.
type persistedAnswer struct {
	QuestionID    int64
	SelectedIDs   []int64
	IsCorrect     bool
	PointsAwarded int
}

// SubmitAttemptTx writes the answers + selected options and finalizes the
// attempt — all or nothing (spec §37). It re-checks the attempt is still
// in_progress inside the transaction (double-submit guard, spec §26).
func (r *Repository) SubmitAttemptTx(ctx context.Context, attemptID int64, answers []persistedAnswer, score, maxScore, percent int, passed bool) (Attempt, error) {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return Attempt{}, fmt.Errorf("begin submit tx: %w", err)
	}
	defer tx.Rollback(ctx) //nolint:errcheck // no-op after commit

	var status string
	if err := tx.QueryRow(ctx,
		`SELECT status FROM quiz_attempts WHERE id = $1 FOR UPDATE`, attemptID).Scan(&status); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return Attempt{}, ErrAttemptNotFound
		}
		return Attempt{}, fmt.Errorf("lock attempt: %w", err)
	}
	if status != AttemptInProgress {
		return Attempt{}, ErrAttemptClosed
	}

	for _, ans := range answers {
		var answerID int64
		if err := tx.QueryRow(ctx, `
			INSERT INTO quiz_attempt_answers (attempt_id, question_id, is_correct, points_awarded)
			VALUES ($1,$2,$3,$4) RETURNING id
		`, attemptID, ans.QuestionID, ans.IsCorrect, ans.PointsAwarded).Scan(&answerID); err != nil {
			return Attempt{}, fmt.Errorf("insert answer: %w", err)
		}
		for _, optID := range ans.SelectedIDs {
			if _, err := tx.Exec(ctx, `
				INSERT INTO quiz_attempt_answer_options (attempt_answer_id, option_id)
				VALUES ($1,$2)
			`, answerID, optID); err != nil {
				return Attempt{}, fmt.Errorf("insert selected option: %w", err)
			}
		}
	}

	a, err := scanAttempt(tx.QueryRow(ctx, `
		UPDATE quiz_attempts
		SET status = 'submitted', score = $2, max_score = $3, percent = $4, passed = $5,
		    submitted_at = NOW(), updated_at = NOW()
		WHERE id = $1
		RETURNING `+attemptCols, attemptID, score, maxScore, percent, passed))
	if err != nil {
		return Attempt{}, fmt.Errorf("finalize attempt: %w", err)
	}

	if err := tx.Commit(ctx); err != nil {
		return Attempt{}, fmt.Errorf("commit submit tx: %w", err)
	}
	return a, nil
}

/* ===================================================================
   progress + read-view helpers
   =================================================================== */

// QuizAssignmentIDs returns which of the given assignment ids are quizzes.
func (r *Repository) QuizAssignmentIDs(ctx context.Context, assignmentIDs []int64) ([]int64, error) {
	if len(assignmentIDs) == 0 {
		return nil, nil
	}
	rows, err := r.pool.Query(ctx,
		`SELECT id FROM assignments WHERE id = ANY($1) AND assignment_type = 'quiz'`, assignmentIDs)
	if err != nil {
		return nil, fmt.Errorf("quiz assignment ids: %w", err)
	}
	defer rows.Close()
	var out []int64
	for rows.Next() {
		var id int64
		if err := rows.Scan(&id); err != nil {
			return nil, err
		}
		out = append(out, id)
	}
	return out, rows.Err()
}

// CountPassedAssignments counts how many of the given assignments the student
// has at least one passing attempt for (spec §44, §45).
func (r *Repository) CountPassedAssignments(ctx context.Context, studentID int64, assignmentIDs []int64) (int, error) {
	if len(assignmentIDs) == 0 {
		return 0, nil
	}
	var n int
	err := r.pool.QueryRow(ctx, `
		SELECT count(DISTINCT assignment_id) FROM quiz_attempts
		WHERE student_id = $1 AND assignment_id = ANY($2) AND status = 'submitted' AND passed = TRUE
	`, studentID, assignmentIDs).Scan(&n)
	return n, err
}

// StudentInTeacherCourse reports whether the student shares a group with the
// teacher for that course (teacher read-authorization, spec §70).
func (r *Repository) StudentInTeacherCourse(ctx context.Context, teacherID, studentID, courseID int64) (bool, error) {
	var ok bool
	err := r.pool.QueryRow(ctx, `
		SELECT EXISTS (
			SELECT 1 FROM group_students gs
			JOIN groups g ON g.id = gs.group_id
			WHERE gs.student_id = $1 AND g.teacher_id = $2 AND g.course_id = $3
		)
	`, studentID, teacherID, courseID).Scan(&ok)
	return ok, err
}

// QuizResultsForStudentCourse returns the per-quiz roll-up for one student in
// one course (teacher / parent read views, spec §69, §71).
func (r *Repository) QuizResultsForStudentCourse(ctx context.Context, studentID, courseID int64) ([]QuizResultBrief, error) {
	rows, err := r.pool.Query(ctx, `
		SELECT a.id, a.title, l.title,
		       count(qa.id) FILTER (WHERE qa.status = 'submitted') AS attempts,
		       max(qa.percent) FILTER (WHERE qa.status = 'submitted') AS best_percent,
		       COALESCE(bool_or(qa.passed), FALSE) AS passed
		FROM assignments a
		JOIN lessons l ON l.id = a.lesson_id
		JOIN modules m ON m.id = l.module_id
		LEFT JOIN quiz_attempts qa ON qa.assignment_id = a.id AND qa.student_id = $1
		WHERE m.course_id = $2 AND a.is_published = TRUE AND a.assignment_type = 'quiz'
		GROUP BY a.id, a.title, l.title, m.position, l.position, a.position
		ORDER BY m.position, l.position, a.position, a.id
	`, studentID, courseID)
	if err != nil {
		return nil, fmt.Errorf("student quiz results: %w", err)
	}
	defer rows.Close()
	out := []QuizResultBrief{}
	for rows.Next() {
		var it QuizResultBrief
		if err := rows.Scan(&it.AssignmentID, &it.Title, &it.LessonTitle, &it.Attempts, &it.BestPercent, &it.Passed); err != nil {
			return nil, err
		}
		out = append(out, it)
	}
	return out, rows.Err()
}

/* ===================================================================
   audit (writes straight to admin_audit_log — reused, spec §63)
   =================================================================== */

func (r *Repository) WriteAudit(ctx context.Context, adminID int64, action, entity string, entityID *int64, summary string) error {
	_, err := r.pool.Exec(ctx, `
		INSERT INTO admin_audit_log (admin_id, action, entity, entity_id, summary)
		VALUES ($1,$2,$3,$4,$5)
	`, adminID, action, entity, entityID, summary)
	return err
}

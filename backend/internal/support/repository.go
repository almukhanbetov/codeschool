package support

import (
	"context"
	"errors"
	"fmt"
	"strconv"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Repository struct {
	pool *pgxpool.Pool
}

func NewRepository(pool *pgxpool.Pool) *Repository {
	return &Repository{pool: pool}
}

type rowScanner interface{ Scan(dest ...any) error }

const threadCols = `
	id, user_id, student_id, course_id, lesson_id, assignment_id,
	subject, category, status, priority, assigned_admin_id,
	created_at, updated_at, last_message_at, closed_at`

func scanThread(row rowScanner) (Thread, error) {
	var t Thread
	err := row.Scan(
		&t.ID, &t.UserID, &t.StudentID, &t.CourseID, &t.LessonID, &t.AssignmentID,
		&t.Subject, &t.Category, &t.Status, &t.Priority, &t.AssignedAdminID,
		&t.CreatedAt, &t.UpdatedAt, &t.LastMessageAt, &t.ClosedAt,
	)
	return t, err
}

const messageCols = `
	id, thread_id, sender_user_id, sender_role, body, message_type,
	is_internal, created_at, edited_at, deleted_at`

func scanMessage(row rowScanner) (Message, error) {
	var m Message
	err := row.Scan(
		&m.ID, &m.ThreadID, &m.SenderUserID, &m.SenderRole, &m.Body, &m.MessageType,
		&m.IsInternal, &m.CreatedAt, &m.EditedAt, &m.DeletedAt,
	)
	return m, err
}

/* ================= reference resolution / access ================= */

func (r *Repository) IsAdmin(ctx context.Context, userID int64) (bool, error) {
	var ok bool
	err := r.pool.QueryRow(ctx, `SELECT role = 'admin' FROM users WHERE id = $1`, userID).Scan(&ok)
	if errors.Is(err, pgx.ErrNoRows) {
		return false, nil
	}
	return ok, err
}

func (r *Repository) IsLinkedChild(ctx context.Context, parentID, childID int64) (bool, error) {
	var ok bool
	err := r.pool.QueryRow(ctx, `
		SELECT EXISTS (
			SELECT 1 FROM parent_children pc
			JOIN users c ON c.id = pc.child_id AND c.role = 'student'
			WHERE pc.parent_id = $1 AND pc.child_id = $2
		)`, parentID, childID).Scan(&ok)
	return ok, err
}

// CourseIDOfLesson resolves lesson → module → course; 0 if the lesson is missing.
func (r *Repository) CourseIDOfLesson(ctx context.Context, lessonID int64) (int64, error) {
	var cid int64
	err := r.pool.QueryRow(ctx, `
		SELECT m.course_id FROM lessons l JOIN modules m ON m.id = l.module_id WHERE l.id = $1
	`, lessonID).Scan(&cid)
	if errors.Is(err, pgx.ErrNoRows) {
		return 0, nil
	}
	return cid, err
}

// CourseIDOfAssignment resolves assignment → lesson → module → course.
func (r *Repository) CourseIDOfAssignment(ctx context.Context, assignmentID int64) (int64, error) {
	var cid int64
	err := r.pool.QueryRow(ctx, `
		SELECT m.course_id
		FROM assignments a
		JOIN lessons l ON l.id = a.lesson_id
		JOIN modules m ON m.id = l.module_id
		WHERE a.id = $1
	`, assignmentID).Scan(&cid)
	if errors.Is(err, pgx.ErrNoRows) {
		return 0, nil
	}
	return cid, err
}

// StudentHasCourseAccess is true when the student has any enrollment
// (active/completed) for the course.
func (r *Repository) StudentHasCourseAccess(ctx context.Context, studentID, courseID int64) (bool, error) {
	var ok bool
	err := r.pool.QueryRow(ctx, `
		SELECT EXISTS (
			SELECT 1 FROM enrollments
			WHERE student_id = $1 AND course_id = $2 AND status IN ('active','completed')
		)`, studentID, courseID).Scan(&ok)
	return ok, err
}

/* ================= threads ================= */

// CreateThread inserts the thread, its opening system message and the user's
// first message in one transaction, and seeds the owner's read cursor.
func (r *Repository) CreateThread(ctx context.Context, in NewThreadInput, senderRole, systemBody string) (Thread, error) {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return Thread{}, fmt.Errorf("begin create thread: %w", err)
	}
	defer tx.Rollback(ctx) //nolint:errcheck

	row := tx.QueryRow(ctx, `
		INSERT INTO support_threads
			(user_id, student_id, course_id, lesson_id, assignment_id, subject, category, status)
		VALUES ($1,$2,$3,$4,$5,$6,$7,'waiting_staff')
		RETURNING `+threadCols,
		in.UserID, in.StudentID, in.CourseID, in.LessonID, in.AssignmentID,
		in.Subject, in.Category)
	t, err := scanThread(row)
	if err != nil {
		return Thread{}, fmt.Errorf("insert thread: %w", err)
	}

	if systemBody != "" {
		if _, err := tx.Exec(ctx, `
			INSERT INTO support_messages (thread_id, sender_user_id, sender_role, body, message_type)
			VALUES ($1, $2, $3, $4, 'system')`, t.ID, in.UserID, senderRole, systemBody); err != nil {
			return Thread{}, fmt.Errorf("insert system message: %w", err)
		}
	}

	var firstID int64
	if err := tx.QueryRow(ctx, `
		INSERT INTO support_messages (thread_id, sender_user_id, sender_role, body, message_type)
		VALUES ($1, $2, $3, $4, 'text') RETURNING id`,
		t.ID, in.UserID, senderRole, in.FirstMessage).Scan(&firstID); err != nil {
		return Thread{}, fmt.Errorf("insert first message: %w", err)
	}

	if _, err := tx.Exec(ctx, `
		INSERT INTO support_thread_reads (thread_id, user_id, last_read_message_id)
		VALUES ($1, $2, $3)`, t.ID, in.UserID, firstID); err != nil {
		return Thread{}, fmt.Errorf("seed read cursor: %w", err)
	}

	if err := tx.Commit(ctx); err != nil {
		return Thread{}, fmt.Errorf("commit create thread: %w", err)
	}
	return t, nil
}

func (r *Repository) ThreadByID(ctx context.Context, id int64) (Thread, error) {
	row := r.pool.QueryRow(ctx, `SELECT `+threadCols+` FROM support_threads WHERE id = $1`, id)
	t, err := scanThread(row)
	if errors.Is(err, pgx.ErrNoRows) {
		return Thread{}, ErrThreadNotFound
	}
	if err != nil {
		return Thread{}, fmt.Errorf("get thread: %w", err)
	}
	return t, nil
}

// threadRow is a thread joined with the display fields the list needs.
type threadRow struct {
	Thread
	StudentName    string
	OwnerName      string
	OwnerEmail     *string
	OwnerRole      string
	CourseTitle    *string
	LessonTitle    *string
	AssignmentName *string
	AssignedName   *string
	LastBody       string
	LastType       string
	Unread         int
}

const threadJoins = `
	FROM support_threads t
	JOIN users owner ON owner.id = t.user_id
	LEFT JOIN users stu ON stu.id = t.student_id
	LEFT JOIN courses c ON c.id = t.course_id
	LEFT JOIN lessons l ON l.id = t.lesson_id
	LEFT JOIN assignments a ON a.id = t.assignment_id
	LEFT JOIN users adm ON adm.id = t.assigned_admin_id`

// listSelect builds the SELECT list. viewerID (a trusted int64 from the JWT,
// injected as a literal) scopes the unread count; adminView keeps internal
// messages visible in the preview + unread count.
func listSelect(viewerID int64, adminView bool) string {
	internalFilter := "AND m.is_internal = FALSE"
	if adminView {
		internalFilter = ""
	}
	v := strconv.FormatInt(viewerID, 10)
	return fmt.Sprintf(`
		SELECT %s,
			trim(coalesce(stu.first_name,'') || ' ' || coalesce(stu.last_name,'')) AS student_name,
			trim(owner.first_name || ' ' || coalesce(owner.last_name,'')) AS owner_name,
			owner.email, owner.role,
			c.title, l.title, a.title,
			CASE WHEN adm.id IS NULL THEN NULL
			     ELSE trim(adm.first_name || ' ' || coalesce(adm.last_name,'')) END AS assigned_name,
			coalesce((SELECT m.body FROM support_messages m
			          WHERE m.thread_id = t.id %s ORDER BY m.id DESC LIMIT 1), '') AS last_body,
			coalesce((SELECT m.message_type FROM support_messages m
			          WHERE m.thread_id = t.id %s ORDER BY m.id DESC LIMIT 1), 'text') AS last_type,
			(SELECT count(*) FROM support_messages m
			 LEFT JOIN support_thread_reads rr ON rr.thread_id = t.id AND rr.user_id = %s
			 WHERE m.thread_id = t.id
			   AND m.id > coalesce(rr.last_read_message_id, 0)
			   AND m.sender_user_id <> %s %s) AS unread
	`, threadColsQualified(), internalFilter, internalFilter, v, v, internalFilter)
}

func threadColsQualified() string {
	parts := strings.Split(strings.ReplaceAll(threadCols, "\n", " "), ",")
	for i, p := range parts {
		parts[i] = "t." + strings.TrimSpace(p)
	}
	return strings.Join(parts, ", ")
}

func scanThreadRow(row rowScanner) (threadRow, error) {
	var tr threadRow
	err := row.Scan(
		&tr.ID, &tr.UserID, &tr.StudentID, &tr.CourseID, &tr.LessonID, &tr.AssignmentID,
		&tr.Subject, &tr.Category, &tr.Status, &tr.Priority, &tr.AssignedAdminID,
		&tr.CreatedAt, &tr.UpdatedAt, &tr.LastMessageAt, &tr.ClosedAt,
		&tr.StudentName, &tr.OwnerName, &tr.OwnerEmail, &tr.OwnerRole,
		&tr.CourseTitle, &tr.LessonTitle, &tr.AssignmentName, &tr.AssignedName,
		&tr.LastBody, &tr.LastType, &tr.Unread,
	)
	return tr, err
}

func (r *Repository) ListThreadsForUser(ctx context.Context, userID int64) ([]threadRow, error) {
	sql := listSelect(userID, false) + threadJoins + `
		WHERE t.user_id = $1
		ORDER BY t.last_message_at DESC, t.id DESC`
	rows, err := r.pool.Query(ctx, sql, userID)
	if err != nil {
		return nil, fmt.Errorf("list threads: %w", err)
	}
	defer rows.Close()
	out := []threadRow{}
	for rows.Next() {
		tr, err := scanThreadRow(rows)
		if err != nil {
			return nil, fmt.Errorf("scan thread row: %w", err)
		}
		out = append(out, tr)
	}
	return out, rows.Err()
}

// ThreadRowForViewer returns one thread with the display join, unread scoped
// to viewerID (adminView controls internal-message visibility).
func (r *Repository) ThreadRowForViewer(ctx context.Context, threadID, viewerID int64, adminView bool) (threadRow, error) {
	sql := listSelect(viewerID, adminView) + threadJoins + ` WHERE t.id = $1`
	tr, err := scanThreadRow(r.pool.QueryRow(ctx, sql, threadID))
	if errors.Is(err, pgx.ErrNoRows) {
		return threadRow{}, ErrThreadNotFound
	}
	if err != nil {
		return threadRow{}, fmt.Errorf("thread row: %w", err)
	}
	return tr, nil
}

/* ---- admin list with filters + pagination ---- */

type AdminFilter struct {
	Status   string
	Category string
	Kind     string // "student" | "parent"
	Assigned string // "me" | "unassigned"
	Query    string
	ViewerID int64
	Page     int
	Limit    int
}

func (r *Repository) AdminList(ctx context.Context, f AdminFilter) ([]threadRow, int, error) {
	where := []string{"1 = 1"}
	args := []any{}
	add := func(clause string, val any) {
		args = append(args, val)
		where = append(where, fmt.Sprintf(clause, len(args)))
	}
	if f.Status != "" {
		add("t.status = $%d", f.Status)
	}
	if f.Category != "" {
		add("t.category = $%d", f.Category)
	}
	switch f.Kind {
	case "student":
		where = append(where, "owner.role = 'student'")
	case "parent":
		where = append(where, "owner.role = 'parent'")
	}
	switch f.Assigned {
	case "me":
		add("t.assigned_admin_id = $%d", f.ViewerID)
	case "unassigned":
		where = append(where, "t.assigned_admin_id IS NULL")
	}
	if q := strings.TrimSpace(f.Query); q != "" {
		args = append(args, "%"+q+"%")
		n := len(args)
		where = append(where, fmt.Sprintf(
			`(owner.first_name ILIKE $%d OR owner.last_name ILIKE $%d OR owner.email ILIKE $%d
			  OR stu.first_name ILIKE $%d OR stu.last_name ILIKE $%d
			  OR c.title ILIKE $%d OR t.subject ILIKE $%d)`, n, n, n, n, n, n, n))
	}
	whereSQL := strings.Join(where, " AND ")

	var total int
	if err := r.pool.QueryRow(ctx,
		`SELECT count(*) `+threadJoins+` WHERE `+whereSQL, args...).Scan(&total); err != nil {
		return nil, 0, fmt.Errorf("count admin threads: %w", err)
	}

	limit := f.Limit
	if limit <= 0 || limit > 100 {
		limit = 20
	}
	page := f.Page
	if page < 1 {
		page = 1
	}
	args = append(args, limit, (page-1)*limit)

	sql := listSelect(f.ViewerID, true) + threadJoins + " WHERE " + whereSQL +
		fmt.Sprintf(" ORDER BY t.last_message_at DESC, t.id DESC LIMIT $%d OFFSET $%d", len(args)-1, len(args))
	rows, err := r.pool.Query(ctx, sql, args...)
	if err != nil {
		return nil, 0, fmt.Errorf("list admin threads: %w", err)
	}
	defer rows.Close()
	out := []threadRow{}
	for rows.Next() {
		tr, err := scanThreadRow(rows)
		if err != nil {
			return nil, 0, fmt.Errorf("scan admin thread row: %w", err)
		}
		out = append(out, tr)
	}
	return out, total, rows.Err()
}

/* ================= messages ================= */

// AddMessage appends a message and bumps the thread's last_message_at /
// updated_at (and status, done by the service via SetStatus).
func (r *Repository) AddMessage(ctx context.Context, threadID, senderID int64, senderRole, body, msgType string, internal bool) (Message, error) {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return Message{}, fmt.Errorf("begin add message: %w", err)
	}
	defer tx.Rollback(ctx) //nolint:errcheck

	row := tx.QueryRow(ctx, `
		INSERT INTO support_messages (thread_id, sender_user_id, sender_role, body, message_type, is_internal)
		VALUES ($1,$2,$3,$4,$5,$6)
		RETURNING `+messageCols,
		threadID, senderID, senderRole, body, msgType, internal)
	m, err := scanMessage(row)
	if err != nil {
		return Message{}, fmt.Errorf("insert message: %w", err)
	}

	// internal notes don't move the conversation clock for the user, but do
	// keep the thread fresh in the admin inbox.
	if _, err := tx.Exec(ctx, `
		UPDATE support_threads SET updated_at = NOW(), last_message_at = NOW() WHERE id = $1
	`, threadID); err != nil {
		return Message{}, fmt.Errorf("bump thread: %w", err)
	}

	// the sender has, by definition, read up to their own message
	if _, err := tx.Exec(ctx, `
		INSERT INTO support_thread_reads (thread_id, user_id, last_read_message_id)
		VALUES ($1,$2,$3)
		ON CONFLICT (thread_id, user_id) DO UPDATE SET last_read_message_id = GREATEST(support_thread_reads.last_read_message_id, $3), updated_at = NOW()
	`, threadID, senderID, m.ID); err != nil {
		return Message{}, fmt.Errorf("advance sender read cursor: %w", err)
	}

	if err := tx.Commit(ctx); err != nil {
		return Message{}, fmt.Errorf("commit add message: %w", err)
	}
	return m, nil
}

type messageRow struct {
	Message
	SenderName string
}

// Messages returns a page of a thread's messages, newest-first, id < before
// (0 = latest). includeInternal must be false for student/parent callers.
func (r *Repository) Messages(ctx context.Context, threadID, before int64, limit int, includeInternal bool) ([]messageRow, error) {
	if limit <= 0 || limit > 100 {
		limit = 50
	}
	args := []any{threadID, limit}
	cond := "m.thread_id = $1 AND m.deleted_at IS NULL"
	if !includeInternal {
		cond += " AND m.is_internal = FALSE"
	}
	if before > 0 {
		args = append(args, before)
		cond += fmt.Sprintf(" AND m.id < $%d", len(args))
	}
	rows, err := r.pool.Query(ctx, `
		SELECT `+messageColsQualified()+`,
		       trim(u.first_name || ' ' || coalesce(u.last_name,'')) AS sender_name
		FROM support_messages m
		JOIN users u ON u.id = m.sender_user_id
		WHERE `+cond+`
		ORDER BY m.id DESC
		LIMIT $2`, args...)
	if err != nil {
		return nil, fmt.Errorf("list messages: %w", err)
	}
	defer rows.Close()
	out := []messageRow{}
	for rows.Next() {
		var mr messageRow
		if err := rows.Scan(
			&mr.ID, &mr.ThreadID, &mr.SenderUserID, &mr.SenderRole, &mr.Body, &mr.MessageType,
			&mr.IsInternal, &mr.CreatedAt, &mr.EditedAt, &mr.DeletedAt, &mr.SenderName,
		); err != nil {
			return nil, fmt.Errorf("scan message: %w", err)
		}
		out = append(out, mr)
	}
	return out, rows.Err()
}

func messageColsQualified() string {
	parts := strings.Split(strings.ReplaceAll(messageCols, "\n", " "), ",")
	for i, p := range parts {
		parts[i] = "m." + strings.TrimSpace(p)
	}
	return strings.Join(parts, ", ")
}

/* ================= status / assign / read ================= */

func (r *Repository) SetStatus(ctx context.Context, threadID int64, status string) error {
	var closedAt any
	if status == StatusClosed {
		closedAt = time.Now()
	}
	_, err := r.pool.Exec(ctx, `
		UPDATE support_threads
		SET status = $2, closed_at = $3, updated_at = NOW()
		WHERE id = $1`, threadID, status, closedAt)
	return err
}

func (r *Repository) Assign(ctx context.Context, threadID int64, adminID *int64) error {
	_, err := r.pool.Exec(ctx, `
		UPDATE support_threads SET assigned_admin_id = $2, updated_at = NOW() WHERE id = $1
	`, threadID, adminID)
	return err
}

// MarkRead advances the caller's read cursor to the thread's latest message
// (internal notes count only for admins).
func (r *Repository) MarkRead(ctx context.Context, threadID, userID int64, includeInternal bool) error {
	cond := ""
	if !includeInternal {
		cond = "AND is_internal = FALSE"
	}
	_, err := r.pool.Exec(ctx, fmt.Sprintf(`
		INSERT INTO support_thread_reads (thread_id, user_id, last_read_message_id)
		VALUES ($1, $2, coalesce((SELECT max(id) FROM support_messages WHERE thread_id = $1 %s), 0))
		ON CONFLICT (thread_id, user_id) DO UPDATE
		SET last_read_message_id = coalesce((SELECT max(id) FROM support_messages WHERE thread_id = $1 %s), 0),
		    updated_at = NOW()
	`, cond, cond), threadID, userID)
	return err
}

// UnreadForUser: threads with ≥1 unread, and total unread messages, for a
// student/parent (their own threads). Internal notes are excluded.
func (r *Repository) UnreadForUser(ctx context.Context, userID int64) (threads, messages int, err error) {
	err = r.pool.QueryRow(ctx, `
		WITH per AS (
			SELECT t.id,
			       (SELECT count(*) FROM support_messages m
			        LEFT JOIN support_thread_reads rr ON rr.thread_id = t.id AND rr.user_id = $1
			        WHERE m.thread_id = t.id
			          AND m.id > coalesce(rr.last_read_message_id, 0)
			          AND m.sender_user_id <> $1
			          AND m.is_internal = FALSE) AS n
			FROM support_threads t
			WHERE t.user_id = $1
		)
		SELECT count(*) FILTER (WHERE n > 0), coalesce(sum(n), 0) FROM per
	`, userID).Scan(&threads, &messages)
	return
}

// UnreadForAdmin: across all threads, unread for this admin (internal notes
// included).
func (r *Repository) UnreadForAdmin(ctx context.Context, adminID int64) (threads, messages int, err error) {
	err = r.pool.QueryRow(ctx, `
		WITH per AS (
			SELECT t.id,
			       (SELECT count(*) FROM support_messages m
			        LEFT JOIN support_thread_reads rr ON rr.thread_id = t.id AND rr.user_id = $1
			        WHERE m.thread_id = t.id
			          AND m.id > coalesce(rr.last_read_message_id, 0)
			          AND m.sender_user_id <> $1) AS n
			FROM support_threads t
		)
		SELECT count(*) FILTER (WHERE n > 0), coalesce(sum(n), 0) FROM per
	`, adminID).Scan(&threads, &messages)
	return
}

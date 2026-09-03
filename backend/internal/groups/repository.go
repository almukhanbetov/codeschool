package groups

import (
	"context"
	"errors"
	"fmt"
	"strings"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Repository struct {
	pool *pgxpool.Pool
}

func NewRepository(pool *pgxpool.Pool) *Repository {
	return &Repository{pool: pool}
}

// progressCTE computes the published-lesson tally for one student in one
// course. Written as a LATERAL-friendly SELECT — `$stu` / `$course` are the
// student id and course id references supplied by the surrounding query.
const progressSubquery = `
	SELECT
		count(*) FILTER (WHERE l.is_published) AS total,
		count(*) FILTER (WHERE l.is_published AND lp.status = 'completed') AS completed
	FROM lessons l
	JOIN modules m ON m.id = l.module_id
	LEFT JOIN lesson_progress lp ON lp.lesson_id = l.id AND lp.student_id = %s
	WHERE m.course_id = %s
`

func percent(completed, total int) int {
	if total <= 0 {
		return 0
	}
	return completed * 100 / total
}

// DashboardCounts returns the four teacher-dashboard tallies in one round trip.
func (r *Repository) DashboardCounts(ctx context.Context, teacherID int64) (Dashboard, error) {
	var d Dashboard
	err := r.pool.QueryRow(ctx, `
		SELECT
			(SELECT count(*) FROM groups WHERE teacher_id = $1),
			(SELECT count(DISTINCT gs.student_id)
			 FROM group_students gs JOIN groups g ON g.id = gs.group_id
			 WHERE g.teacher_id = $1),
			(SELECT count(DISTINCT s.id)
			 FROM submissions s
			 JOIN assignments a ON a.id = s.assignment_id
			 JOIN lessons l ON l.id = a.lesson_id
			 JOIN modules m ON m.id = l.module_id
			 WHERE s.status = 'submitted' AND EXISTS (
			   SELECT 1 FROM group_students gs JOIN groups g ON g.id = gs.group_id
			   WHERE gs.student_id = s.student_id AND g.course_id = m.course_id AND g.teacher_id = $1
			 )),
			(SELECT count(DISTINCT s.id)
			 FROM submissions s
			 JOIN assignments a ON a.id = s.assignment_id
			 JOIN lessons l ON l.id = a.lesson_id
			 JOIN modules m ON m.id = l.module_id
			 WHERE s.status IN ('passed','failed') AND EXISTS (
			   SELECT 1 FROM group_students gs JOIN groups g ON g.id = gs.group_id
			   WHERE gs.student_id = s.student_id AND g.course_id = m.course_id AND g.teacher_id = $1
			 ))
	`, teacherID).Scan(&d.GroupsCount, &d.StudentsCount, &d.PendingSubmissions, &d.ReviewedSubmissions)
	if err != nil {
		return Dashboard{}, fmt.Errorf("dashboard counts: %w", err)
	}
	return d, nil
}

// ListByTeacher returns the teacher's groups, each with a student count and
// the group's average course-progress.
func (r *Repository) ListByTeacher(ctx context.Context, teacherID int64) ([]GroupListItem, error) {
	rows, err := r.pool.Query(ctx, `
		SELECT
			g.id, g.title, g.status, g.start_date,
			c.id, c.title, c.slug,
			(SELECT count(*) FROM group_students gs WHERE gs.group_id = g.id) AS student_count,
			COALESCE((
				SELECT round(avg(CASE WHEN cnt.total = 0 THEN 0
				                      ELSE cnt.completed::numeric * 100 / cnt.total END))
				FROM group_students gs
				CROSS JOIN LATERAL (`+fmt.Sprintf(progressSubquery, "gs.student_id", "g.course_id")+`) cnt
				WHERE gs.group_id = g.id
			), 0)::int AS avg_progress
		FROM groups g
		JOIN courses c ON c.id = g.course_id
		WHERE g.teacher_id = $1
		ORDER BY g.created_at DESC, g.id DESC
	`, teacherID)
	if err != nil {
		return nil, fmt.Errorf("list teacher groups: %w", err)
	}
	defer rows.Close()

	var out []GroupListItem
	for rows.Next() {
		var g GroupListItem
		if err := rows.Scan(
			&g.ID, &g.Title, &g.Status, &g.StartDate,
			&g.Course.ID, &g.Course.Title, &g.Course.Slug,
			&g.StudentCount, &g.AvgProgressPct,
		); err != nil {
			return nil, fmt.Errorf("scan group: %w", err)
		}
		out = append(out, g)
	}
	return out, rows.Err()
}

// GetDetailForTeacher returns one group the teacher owns, or ErrGroupNotFound
// (also for groups owned by another teacher — no existence leak).
func (r *Repository) GetDetailForTeacher(ctx context.Context, teacherID, groupID int64) (GroupDetail, error) {
	var g GroupDetail
	err := r.pool.QueryRow(ctx, `
		SELECT
			g.id, g.title, g.status, g.start_date,
			c.id, c.title, c.slug,
			(SELECT count(*) FROM group_students gs WHERE gs.group_id = g.id),
			COALESCE((
				SELECT round(avg(CASE WHEN cnt.total = 0 THEN 0
				                      ELSE cnt.completed::numeric * 100 / cnt.total END))
				FROM group_students gs
				CROSS JOIN LATERAL (`+fmt.Sprintf(progressSubquery, "gs.student_id", "g.course_id")+`) cnt
				WHERE gs.group_id = g.id
			), 0)::int,
			g.description, g.end_date, g.max_students
		FROM groups g
		JOIN courses c ON c.id = g.course_id
		WHERE g.id = $1 AND g.teacher_id = $2
	`, groupID, teacherID).Scan(
		&g.ID, &g.Title, &g.Status, &g.StartDate,
		&g.Course.ID, &g.Course.Title, &g.Course.Slug,
		&g.StudentCount, &g.AvgProgressPct,
		&g.Description, &g.EndDate, &g.MaxStudents,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return GroupDetail{}, ErrGroupNotFound
	}
	if err != nil {
		return GroupDetail{}, fmt.Errorf("get group: %w", err)
	}
	return g, nil
}

// GroupCourseID returns the course id of a group the teacher owns, or
// ErrGroupNotFound. Used to authorize the nested student/submission routes.
func (r *Repository) GroupCourseID(ctx context.Context, teacherID, groupID int64) (int64, error) {
	var courseID int64
	err := r.pool.QueryRow(ctx,
		`SELECT course_id FROM groups WHERE id = $1 AND teacher_id = $2`,
		groupID, teacherID).Scan(&courseID)
	if errors.Is(err, pgx.ErrNoRows) {
		return 0, ErrGroupNotFound
	}
	if err != nil {
		return 0, fmt.Errorf("group course id: %w", err)
	}
	return courseID, nil
}

// ListStudents returns the group's members with per-student progress and a
// pending-submission count. One query, no N+1 (LATERAL subqueries).
func (r *Repository) ListStudents(ctx context.Context, groupID, courseID int64) ([]GroupStudentItem, error) {
	rows, err := r.pool.Query(ctx, `
		SELECT
			u.id, u.first_name, u.last_name, gs.joined_at,
			prog.total, prog.completed,
			COALESCE(pend.cnt, 0)
		FROM group_students gs
		JOIN users u ON u.id = gs.student_id
		CROSS JOIN LATERAL (`+fmt.Sprintf(progressSubquery, "u.id", "$2")+`) prog
		LEFT JOIN LATERAL (
			SELECT count(*) AS cnt
			FROM submissions s
			JOIN assignments a ON a.id = s.assignment_id
			JOIN lessons l2 ON l2.id = a.lesson_id
			JOIN modules m2 ON m2.id = l2.module_id
			WHERE s.student_id = u.id AND m2.course_id = $2 AND s.status = 'submitted'
		) pend ON true
		WHERE gs.group_id = $1
		ORDER BY u.first_name, u.id
	`, groupID, courseID)
	if err != nil {
		return nil, fmt.Errorf("list group students: %w", err)
	}
	defer rows.Close()

	var out []GroupStudentItem
	for rows.Next() {
		var it GroupStudentItem
		var completed, total int
		if err := rows.Scan(
			&it.Student.ID, &it.Student.FirstName, &it.Student.LastName, &it.JoinedAt,
			&total, &completed, &it.PendingSubmissions,
		); err != nil {
			return nil, fmt.Errorf("scan group student: %w", err)
		}
		it.Progress = ProgressBrief{CompletedLessons: completed, TotalLessons: total, ProgressPercent: percent(completed, total)}
		out = append(out, it)
	}
	return out, rows.Err()
}

// IsStudentInTeacherGroup reports whether the student is a member of the
// given group AND that group belongs to the teacher.
func (r *Repository) IsStudentInTeacherGroup(ctx context.Context, teacherID, groupID, studentID int64) (bool, error) {
	var ok bool
	err := r.pool.QueryRow(ctx, `
		SELECT EXISTS (
			SELECT 1 FROM group_students gs
			JOIN groups g ON g.id = gs.group_id
			WHERE gs.group_id = $1 AND gs.student_id = $2 AND g.teacher_id = $3
		)
	`, groupID, studentID, teacherID).Scan(&ok)
	if err != nil {
		return false, fmt.Errorf("student-in-group check: %w", err)
	}
	return ok, nil
}

// StudentDetail assembles the teacher's view of one student in a course.
func (r *Repository) StudentDetail(ctx context.Context, studentID, courseID int64) (StudentDetail, error) {
	var d StudentDetail

	if err := r.pool.QueryRow(ctx,
		`SELECT id, first_name, last_name FROM users WHERE id = $1`, studentID).
		Scan(&d.Student.ID, &d.Student.FirstName, &d.Student.LastName); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return StudentDetail{}, ErrStudentNotInGroup
		}
		return StudentDetail{}, fmt.Errorf("student profile: %w", err)
	}

	if err := r.pool.QueryRow(ctx,
		`SELECT id, title, slug FROM courses WHERE id = $1`, courseID).
		Scan(&d.Course.ID, &d.Course.Title, &d.Course.Slug); err != nil {
		return StudentDetail{}, fmt.Errorf("student course: %w", err)
	}

	var completed, total int
	if err := r.pool.QueryRow(ctx,
		fmt.Sprintf(progressSubquery, "$1", "$2"), studentID, courseID).
		Scan(&total, &completed); err != nil {
		return StudentDetail{}, fmt.Errorf("student progress: %w", err)
	}
	d.Progress = ProgressBrief{CompletedLessons: completed, TotalLessons: total, ProgressPercent: percent(completed, total)}

	lessonRows, err := r.pool.Query(ctx, `
		SELECT l.id, l.title, COALESCE(lp.status, 'not_started'), lp.completed_at
		FROM lessons l
		JOIN modules m ON m.id = l.module_id
		LEFT JOIN lesson_progress lp ON lp.lesson_id = l.id AND lp.student_id = $1
		WHERE m.course_id = $2 AND l.is_published = TRUE
		ORDER BY m.position, m.id, l.position, l.id
	`, studentID, courseID)
	if err != nil {
		return StudentDetail{}, fmt.Errorf("student lessons: %w", err)
	}
	defer lessonRows.Close()
	d.Lessons = []LessonProgressItem{}
	for lessonRows.Next() {
		var li LessonProgressItem
		if err := lessonRows.Scan(&li.LessonID, &li.Title, &li.Status, &li.CompletedAt); err != nil {
			return StudentDetail{}, fmt.Errorf("scan student lesson: %w", err)
		}
		d.Lessons = append(d.Lessons, li)
	}
	if err := lessonRows.Err(); err != nil {
		return StudentDetail{}, err
	}

	subRows, err := r.pool.Query(ctx, `
		SELECT a.id, a.title, l.title, a.points,
		       s.id, s.status, s.score, s.submitted_at
		FROM assignments a
		JOIN lessons l ON l.id = a.lesson_id
		JOIN modules m ON m.id = l.module_id
		LEFT JOIN submissions s ON s.assignment_id = a.id AND s.student_id = $1
		WHERE m.course_id = $2 AND a.is_published = TRUE
		ORDER BY m.position, l.position, a.position, a.id
	`, studentID, courseID)
	if err != nil {
		return StudentDetail{}, fmt.Errorf("student submissions: %w", err)
	}
	defer subRows.Close()
	d.Submissions = []SubmissionSummaryItem{}
	for subRows.Next() {
		var si SubmissionSummaryItem
		var status *string
		if err := subRows.Scan(
			&si.AssignmentID, &si.AssignmentTitle, &si.LessonTitle, &si.Points,
			&si.SubmissionID, &status, &si.Score, &si.SubmittedAt,
		); err != nil {
			return StudentDetail{}, fmt.Errorf("scan student submission: %w", err)
		}
		if status != nil {
			si.Status = *status
		}
		d.Submissions = append(d.Submissions, si)
	}
	if err := subRows.Err(); err != nil {
		return StudentDetail{}, err
	}

	// Published quizzes in the course + this student's attempt roll-up
	// (read-only; quizzes never enter the manual review queue, spec §69, §87).
	quizRows, err := r.pool.Query(ctx, `
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
		return StudentDetail{}, fmt.Errorf("student quiz results: %w", err)
	}
	defer quizRows.Close()
	d.QuizResults = []QuizResultItem{}
	for quizRows.Next() {
		var qi QuizResultItem
		if err := quizRows.Scan(&qi.AssignmentID, &qi.Title, &qi.LessonTitle, &qi.Attempts, &qi.BestPercent, &qi.Passed); err != nil {
			return StudentDetail{}, fmt.Errorf("scan student quiz result: %w", err)
		}
		d.QuizResults = append(d.QuizResults, qi)
	}
	return d, quizRows.Err()
}

// ListSubmissionsForTeacher returns a page of submissions belonging to the
// teacher's group students (course-matched), plus the total for pagination.
func (r *Repository) ListSubmissionsForTeacher(ctx context.Context, teacherID int64, f SubmissionFilter) ([]SubmissionListItem, int, error) {
	var conds []string
	args := []any{teacherID}
	add := func(expr string, val any) {
		args = append(args, val)
		conds = append(conds, fmt.Sprintf(expr, len(args)))
	}

	ownership := `EXISTS (
		SELECT 1 FROM group_students gs
		JOIN groups g ON g.id = gs.group_id
		WHERE gs.student_id = s.student_id AND g.course_id = co.id AND g.teacher_id = $1`
	if f.GroupID != nil {
		args = append(args, *f.GroupID)
		ownership += fmt.Sprintf(" AND g.id = $%d", len(args))
	}
	ownership += ")"
	conds = append(conds, ownership)

	if f.Status != "" {
		add("s.status = $%d", f.Status)
	}
	if f.CourseID != nil {
		add("co.id = $%d", *f.CourseID)
	}

	base := `
		FROM submissions s
		JOIN users stu ON stu.id = s.student_id
		JOIN assignments a ON a.id = s.assignment_id
		JOIN lessons l ON l.id = a.lesson_id
		JOIN modules m ON m.id = l.module_id
		JOIN courses co ON co.id = m.course_id
		WHERE ` + strings.Join(conds, " AND ")

	var total int
	if err := r.pool.QueryRow(ctx, `SELECT count(*) `+base, args...).Scan(&total); err != nil {
		return nil, 0, fmt.Errorf("count teacher submissions: %w", err)
	}

	args = append(args, f.Limit, (f.Page-1)*f.Limit)
	query := `
		SELECT
			s.id, s.status, s.submitted_at,
			stu.id, stu.first_name, stu.last_name,
			co.id, co.title, co.slug,
			l.id, l.title,
			a.id, a.title, a.points
	` + base + fmt.Sprintf(`
		ORDER BY s.submitted_at ASC NULLS LAST, s.id ASC
		LIMIT $%d OFFSET $%d`, len(args)-1, len(args))

	rows, err := r.pool.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, fmt.Errorf("list teacher submissions: %w", err)
	}
	defer rows.Close()

	out := []SubmissionListItem{}
	for rows.Next() {
		var it SubmissionListItem
		if err := rows.Scan(
			&it.ID, &it.Status, &it.SubmittedAt,
			&it.Student.ID, &it.Student.FirstName, &it.Student.LastName,
			&it.Course.ID, &it.Course.Title, &it.Course.Slug,
			&it.Lesson.ID, &it.Lesson.Title,
			&it.Assignment.ID, &it.Assignment.Title, &it.Assignment.Points,
		); err != nil {
			return nil, 0, fmt.Errorf("scan teacher submission: %w", err)
		}
		out = append(out, it)
	}
	return out, total, rows.Err()
}

// GetSubmissionForTeacher returns the full review view of a submission the
// teacher owns (via a group of the submission's course containing the
// student). ErrSubmissionNotFound otherwise.
func (r *Repository) GetSubmissionForTeacher(ctx context.Context, teacherID, submissionID int64) (SubmissionDetail, error) {
	var d SubmissionDetail
	err := r.pool.QueryRow(ctx, `
		SELECT
			s.id, s.status, s.code, s.answer, s.score, s.teacher_feedback, s.submitted_at, s.checked_at,
			stu.id, stu.first_name, stu.last_name,
			g.id, g.title,
			co.id, co.title, co.slug,
			m.id, m.title,
			l.id, l.title,
			a.id, a.title, a.description, a.assignment_type, a.starter_code, a.expected_output, a.language, a.points
		FROM submissions s
		JOIN users stu ON stu.id = s.student_id
		JOIN assignments a ON a.id = s.assignment_id
		JOIN lessons l ON l.id = a.lesson_id
		JOIN modules m ON m.id = l.module_id
		JOIN courses co ON co.id = m.course_id
		JOIN group_students gs ON gs.student_id = s.student_id
		JOIN groups g ON g.id = gs.group_id AND g.course_id = co.id AND g.teacher_id = $2
		WHERE s.id = $1
		ORDER BY g.id
		LIMIT 1
	`, submissionID, teacherID).Scan(
		&d.ID, &d.Status, &d.Code, &d.Answer, &d.Score, &d.TeacherFeedback, &d.SubmittedAt, &d.CheckedAt,
		&d.Student.ID, &d.Student.FirstName, &d.Student.LastName,
		&d.Group.ID, &d.Group.Title,
		&d.Course.ID, &d.Course.Title, &d.Course.Slug,
		&d.Module.ID, &d.Module.Title,
		&d.Lesson.ID, &d.Lesson.Title,
		&d.Assignment.ID, &d.Assignment.Title, &d.Assignment.Description, &d.Assignment.AssignmentType,
		&d.Assignment.StarterCode, &d.Assignment.ExpectedOutput, &d.Assignment.Language, &d.Assignment.Points,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return SubmissionDetail{}, ErrSubmissionNotFound
	}
	if err != nil {
		return SubmissionDetail{}, fmt.Errorf("get teacher submission: %w", err)
	}
	return d, nil
}

// AddStudentTx adds a student to a group and guarantees they have an active
// enrollment in the group's course — atomically. Used by the dev seed / a
// future admin action (there is no teacher-facing endpoint yet).
func (r *Repository) AddStudentTx(ctx context.Context, groupID, studentID int64) error {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return fmt.Errorf("begin add-student tx: %w", err)
	}
	defer tx.Rollback(ctx) //nolint:errcheck // no-op after commit

	var courseID int64
	var maxStudents *int
	var count int
	err = tx.QueryRow(ctx, `
		SELECT g.course_id, g.max_students,
		       (SELECT count(*) FROM group_students WHERE group_id = g.id)
		FROM groups g WHERE g.id = $1 FOR UPDATE
	`, groupID).Scan(&courseID, &maxStudents, &count)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrGroupNotFound
	}
	if err != nil {
		return fmt.Errorf("lock group: %w", err)
	}

	var role string
	if err := tx.QueryRow(ctx, `SELECT role FROM users WHERE id = $1`, studentID).Scan(&role); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return ErrNotAStudent
		}
		return fmt.Errorf("student role: %w", err)
	}
	if role != "student" {
		return ErrNotAStudent
	}

	var already bool
	if err := tx.QueryRow(ctx,
		`SELECT EXISTS (SELECT 1 FROM group_students WHERE group_id = $1 AND student_id = $2)`,
		groupID, studentID).Scan(&already); err != nil {
		return fmt.Errorf("dup check: %w", err)
	}
	if already {
		return ErrAlreadyInGroup
	}

	if maxStudents != nil && count >= *maxStudents {
		return ErrGroupFull
	}

	if _, err := tx.Exec(ctx,
		`INSERT INTO group_students (group_id, student_id) VALUES ($1, $2)`,
		groupID, studentID); err != nil {
		return fmt.Errorf("insert group student: %w", err)
	}

	if _, err := tx.Exec(ctx, `
		INSERT INTO enrollments (student_id, course_id, status)
		VALUES ($1, $2, 'active')
		ON CONFLICT (student_id, course_id) WHERE status = 'active' DO NOTHING
	`, studentID, courseID); err != nil {
		return fmt.Errorf("ensure enrollment: %w", err)
	}

	return tx.Commit(ctx)
}

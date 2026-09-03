package parents

import (
	"context"
	"errors"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Repository struct {
	pool *pgxpool.Pool
}

func NewRepository(pool *pgxpool.Pool) *Repository {
	return &Repository{pool: pool}
}

func percent(completed, total int) int {
	if total <= 0 {
		return 0
	}
	return completed * 100 / total
}

// IsLinked reports whether child_id is one of parent_id's linked children.
func (r *Repository) IsLinked(ctx context.Context, parentID, childID int64) (bool, error) {
	var ok bool
	err := r.pool.QueryRow(ctx, `
		SELECT EXISTS (
			SELECT 1 FROM parent_children WHERE parent_id = $1 AND child_id = $2
		)
	`, parentID, childID).Scan(&ok)
	if err != nil {
		return false, fmt.Errorf("parent-child link check: %w", err)
	}
	return ok, nil
}

// childBrief loads the safe fields of a child, or ErrChildNotFound.
func (r *Repository) childBrief(ctx context.Context, childID int64) (ChildBrief, error) {
	var c ChildBrief
	err := r.pool.QueryRow(ctx,
		`SELECT id, first_name, last_name FROM users WHERE id = $1`, childID).
		Scan(&c.ID, &c.FirstName, &c.LastName)
	if errors.Is(err, pgx.ErrNoRows) {
		return ChildBrief{}, ErrChildNotFound
	}
	if err != nil {
		return ChildBrief{}, fmt.Errorf("child profile: %w", err)
	}
	return c, nil
}

// ListChildren returns the parent's linked children, each with a rolled-up
// summary (courses, overall progress, pending-review / needs-work counts).
// One query, no N+1 (nested LATERAL subqueries).
func (r *Repository) ListChildren(ctx context.Context, parentID int64) ([]ChildListItem, error) {
	rows, err := r.pool.Query(ctx, `
		SELECT
			u.id, u.first_name, u.last_name,
			prog.courses_count, prog.done_total, prog.total_total,
			subs.pending, subs.needs_work
		FROM parent_children pc
		JOIN users u ON u.id = pc.child_id
		CROSS JOIN LATERAL (
			SELECT
				count(*)                                   AS courses_count,
				COALESCE(sum(cc.done), 0)                   AS done_total,
				COALESCE(sum(cc.total), 0)                  AS total_total
			FROM (
				SELECT DISTINCT course_id
				FROM enrollments
				WHERE student_id = u.id AND status IN ('active', 'completed')
				  AND course_id IN (SELECT id FROM courses WHERE audience <> 'teacher')
			) ec
			CROSS JOIN LATERAL (
				SELECT
					count(*) FILTER (WHERE l.is_published AND lp.status = 'completed') AS done,
					count(*) FILTER (WHERE l.is_published)                             AS total
				FROM lessons l
				JOIN modules m ON m.id = l.module_id
				LEFT JOIN lesson_progress lp ON lp.lesson_id = l.id AND lp.student_id = u.id
				WHERE m.course_id = ec.course_id
			) cc
		) prog
		CROSS JOIN LATERAL (
			SELECT
				count(*) FILTER (WHERE s.status IN ('submitted', 'checking')) AS pending,
				count(*) FILTER (WHERE s.status = 'failed')                   AS needs_work
			FROM submissions s
			WHERE s.student_id = u.id
		) subs
		WHERE pc.parent_id = $1
		ORDER BY u.first_name, u.id
	`, parentID)
	if err != nil {
		return nil, fmt.Errorf("list children: %w", err)
	}
	defer rows.Close()

	out := []ChildListItem{}
	for rows.Next() {
		var it ChildListItem
		var done, total int
		if err := rows.Scan(
			&it.Child.ID, &it.Child.FirstName, &it.Child.LastName,
			&it.CoursesCount, &done, &total,
			&it.PendingReview, &it.NeedsWork,
		); err != nil {
			return nil, fmt.Errorf("scan child: %w", err)
		}
		it.OverallProgressPercent = percent(done, total)
		out = append(out, it)
	}
	return out, rows.Err()
}

// ChildOverview returns the child's profile + one row per enrolled course
// with the child's progress in it.
func (r *Repository) ChildOverview(ctx context.Context, childID int64) (ChildOverview, error) {
	child, err := r.childBrief(ctx, childID)
	if err != nil {
		return ChildOverview{}, err
	}

	rows, err := r.pool.Query(ctx, `
		SELECT
			c.id, c.title, c.slug,
			CASE WHEN bool_or(e.status = 'active') THEN 'active' ELSE 'completed' END AS enr_status,
			cc.total, cc.completed
		FROM enrollments e
		JOIN courses c ON c.id = e.course_id AND c.audience <> 'teacher'
		CROSS JOIN LATERAL (
			SELECT
				count(*) FILTER (WHERE l.is_published)                             AS total,
				count(*) FILTER (WHERE l.is_published AND lp.status = 'completed') AS completed
			FROM lessons l
			JOIN modules m ON m.id = l.module_id
			LEFT JOIN lesson_progress lp ON lp.lesson_id = l.id AND lp.student_id = $1
			WHERE m.course_id = c.id
		) cc
		WHERE e.student_id = $1 AND e.status IN ('active', 'completed')
		GROUP BY c.id, c.title, c.slug, cc.total, cc.completed
		ORDER BY c.title, c.id
	`, childID)
	if err != nil {
		return ChildOverview{}, fmt.Errorf("child courses: %w", err)
	}
	defer rows.Close()

	overview := ChildOverview{Child: child, Courses: []ChildCourseProgress{}}
	for rows.Next() {
		var cp ChildCourseProgress
		var total, completed int
		if err := rows.Scan(
			&cp.Course.ID, &cp.Course.Title, &cp.Course.Slug,
			&cp.EnrollmentStatus, &total, &completed,
		); err != nil {
			return ChildOverview{}, fmt.Errorf("scan child course: %w", err)
		}
		cp.Progress = ProgressBrief{CompletedLessons: completed, TotalLessons: total, ProgressPercent: percent(completed, total)}
		overview.Courses = append(overview.Courses, cp)
	}
	return overview, rows.Err()
}

// ChildCourseDetail returns lesson progress + every published assignment with
// the child's submission state and the teacher's feedback. ErrCourseNotFound
// if the child is not enrolled in that course.
func (r *Repository) ChildCourseDetail(ctx context.Context, childID, courseID int64) (ChildCourseDetail, error) {
	child, err := r.childBrief(ctx, childID)
	if err != nil {
		return ChildCourseDetail{}, err
	}

	var d ChildCourseDetail
	d.Child = child

	err = r.pool.QueryRow(ctx, `
		SELECT c.id, c.title, c.slug
		FROM courses c
		WHERE c.id = $2 AND c.audience <> 'teacher' AND EXISTS (
			SELECT 1 FROM enrollments e
			WHERE e.student_id = $1 AND e.course_id = c.id AND e.status IN ('active', 'completed')
		)
	`, childID, courseID).Scan(&d.Course.ID, &d.Course.Title, &d.Course.Slug)
	if errors.Is(err, pgx.ErrNoRows) {
		return ChildCourseDetail{}, ErrCourseNotFound
	}
	if err != nil {
		return ChildCourseDetail{}, fmt.Errorf("child course: %w", err)
	}

	var total, completed int
	if err := r.pool.QueryRow(ctx, `
		SELECT
			count(*) FILTER (WHERE l.is_published)                             AS total,
			count(*) FILTER (WHERE l.is_published AND lp.status = 'completed') AS completed
		FROM lessons l
		JOIN modules m ON m.id = l.module_id
		LEFT JOIN lesson_progress lp ON lp.lesson_id = l.id AND lp.student_id = $1
		WHERE m.course_id = $2
	`, childID, courseID).Scan(&total, &completed); err != nil {
		return ChildCourseDetail{}, fmt.Errorf("child course progress: %w", err)
	}
	d.Progress = ProgressBrief{CompletedLessons: completed, TotalLessons: total, ProgressPercent: percent(completed, total)}

	lessonRows, err := r.pool.Query(ctx, `
		SELECT l.id, l.title, COALESCE(lp.status, 'not_started'), lp.completed_at
		FROM lessons l
		JOIN modules m ON m.id = l.module_id
		LEFT JOIN lesson_progress lp ON lp.lesson_id = l.id AND lp.student_id = $1
		WHERE m.course_id = $2 AND l.is_published = TRUE
		ORDER BY m.position, m.id, l.position, l.id
	`, childID, courseID)
	if err != nil {
		return ChildCourseDetail{}, fmt.Errorf("child lessons: %w", err)
	}
	defer lessonRows.Close()
	d.Lessons = []LessonProgressItem{}
	for lessonRows.Next() {
		var li LessonProgressItem
		if err := lessonRows.Scan(&li.LessonID, &li.Title, &li.Status, &li.CompletedAt); err != nil {
			return ChildCourseDetail{}, fmt.Errorf("scan child lesson: %w", err)
		}
		d.Lessons = append(d.Lessons, li)
	}
	if err := lessonRows.Err(); err != nil {
		return ChildCourseDetail{}, err
	}

	subRows, err := r.pool.Query(ctx, `
		SELECT
			a.id, a.title, l.title, a.assignment_type, a.points,
			s.status, s.score, s.teacher_feedback, s.submitted_at, s.checked_at,
			q.attempts, q.best_percent, q.passed
		FROM assignments a
		JOIN lessons l ON l.id = a.lesson_id
		JOIN modules m ON m.id = l.module_id
		LEFT JOIN submissions s ON s.assignment_id = a.id AND s.student_id = $1
		LEFT JOIN LATERAL (
			SELECT
				count(*) FILTER (WHERE qa.status = 'submitted')          AS attempts,
				max(qa.percent) FILTER (WHERE qa.status = 'submitted')   AS best_percent,
				bool_or(qa.passed)                                       AS passed
			FROM quiz_attempts qa
			WHERE qa.assignment_id = a.id AND qa.student_id = $1
		) q ON a.assignment_type = 'quiz'
		WHERE m.course_id = $2 AND a.is_published = TRUE
		ORDER BY m.position, l.position, a.position, a.id
	`, childID, courseID)
	if err != nil {
		return ChildCourseDetail{}, fmt.Errorf("child assignments: %w", err)
	}
	defer subRows.Close()
	d.Assignments = []AssignmentFeedbackItem{}
	for subRows.Next() {
		var it AssignmentFeedbackItem
		var status *string
		if err := subRows.Scan(
			&it.AssignmentID, &it.Title, &it.LessonTitle, &it.AssignmentType, &it.Points,
			&status, &it.Score, &it.TeacherFeedback, &it.SubmittedAt, &it.CheckedAt,
			&it.QuizAttempts, &it.QuizBestPercent, &it.QuizPassed,
		); err != nil {
			return ChildCourseDetail{}, fmt.Errorf("scan child assignment: %w", err)
		}
		if status != nil {
			it.Status = *status
		}
		d.Assignments = append(d.Assignments, it)
	}
	return d, subRows.Err()
}

// Activity returns the child's recent activity — completed lessons and
// non-draft submissions merged into one timeline, newest first.
func (r *Repository) Activity(ctx context.Context, childID int64) (ActivitySummary, error) {
	child, err := r.childBrief(ctx, childID)
	if err != nil {
		return ActivitySummary{}, err
	}

	rows, err := r.pool.Query(ctx, `
		(
			SELECT 'lesson_completed' AS type, lp.completed_at AS at,
			       c.title AS course_title, l.title AS lesson_title,
			       NULL::text AS assignment_title, NULL::int AS score, NULL::int AS points
			FROM lesson_progress lp
			JOIN lessons l ON l.id = lp.lesson_id
			JOIN modules m ON m.id = l.module_id
			JOIN courses c ON c.id = m.course_id AND c.audience <> 'teacher'
			WHERE lp.student_id = $1 AND lp.status = 'completed' AND lp.completed_at IS NOT NULL
		)
		UNION ALL
		(
			SELECT
				CASE s.status
					WHEN 'passed' THEN 'assignment_passed'
					WHEN 'failed' THEN 'assignment_failed'
					ELSE 'assignment_submitted'
				END AS type,
				COALESCE(s.checked_at, s.submitted_at) AS at,
				c.title, l.title, a.title, s.score, a.points
			FROM submissions s
			JOIN assignments a ON a.id = s.assignment_id
			JOIN lessons l ON l.id = a.lesson_id
			JOIN modules m ON m.id = l.module_id
			JOIN courses c ON c.id = m.course_id AND c.audience <> 'teacher'
			WHERE s.student_id = $1 AND s.status <> 'draft'
			  AND COALESCE(s.checked_at, s.submitted_at) IS NOT NULL
		)
		ORDER BY at DESC
		LIMIT $2
	`, childID, activityLimit)
	if err != nil {
		return ActivitySummary{}, fmt.Errorf("child activity: %w", err)
	}
	defer rows.Close()

	summary := ActivitySummary{Child: child, Items: []ActivityItem{}}
	for rows.Next() {
		var a ActivityItem
		if err := rows.Scan(
			&a.Type, &a.At, &a.CourseTitle, &a.LessonTitle,
			&a.AssignmentTitle, &a.Score, &a.Points,
		); err != nil {
			return ActivitySummary{}, fmt.Errorf("scan activity: %w", err)
		}
		summary.Items = append(summary.Items, a)
	}
	return summary, rows.Err()
}

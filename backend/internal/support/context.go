package support

import (
	"context"
	"errors"
	"fmt"

	"github.com/jackc/pgx/v5"
)

// LearningContext reads the manager's context panel straight from current LMS
// tables (enrollments / lesson_progress / quiz_attempts / submissions /
// code_runs / certificates). Nothing here is stored in the chat. It is
// strictly read-only.
func (r *Repository) LearningContext(ctx context.Context, studentID int64, focusCourseID, parentID *int64) (LearningContext, error) {
	var lc LearningContext

	// ---- student ----
	if err := r.pool.QueryRow(ctx, `
		SELECT id, trim(first_name || ' ' || coalesce(last_name,'')), email
		FROM users WHERE id = $1
	`, studentID).Scan(&lc.Student.ID, &lc.Student.Name, &lc.Student.Email); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return LearningContext{}, ErrThreadNotFound
		}
		return LearningContext{}, fmt.Errorf("context student: %w", err)
	}

	// ---- parent (for a parent thread) ----
	if parentID != nil {
		var p PersonRef
		if err := r.pool.QueryRow(ctx, `
			SELECT id, trim(first_name || ' ' || coalesce(last_name,'')), email
			FROM users WHERE id = $1
		`, *parentID).Scan(&p.ID, &p.Name, &p.Email); err == nil {
			lc.Parent = &p
			linked, _ := r.IsLinkedChild(ctx, *parentID, studentID)
			lc.ParentLinked = &linked
		}
	}

	// ---- courses + progress ----
	rows, err := r.pool.Query(ctx, `
		SELECT c.id, c.title, c.slug,
		       CASE WHEN bool_or(e.status = 'completed') AND NOT bool_or(e.status = 'active')
		            THEN 'completed' ELSE 'active' END AS enr_status,
		       count(DISTINCT l.id) FILTER (WHERE l.is_published)                                AS total,
		       count(DISTINCT l.id) FILTER (WHERE l.is_published AND lp.status = 'completed')     AS done
		FROM enrollments e
		JOIN courses c ON c.id = e.course_id
		LEFT JOIN modules m ON m.course_id = c.id
		LEFT JOIN lessons l ON l.module_id = m.id
		LEFT JOIN lesson_progress lp ON lp.lesson_id = l.id AND lp.student_id = $1
		WHERE e.student_id = $1 AND e.status IN ('active','completed')
		GROUP BY c.id, c.title, c.slug
		ORDER BY c.title, c.id
	`, studentID)
	if err != nil {
		return LearningContext{}, fmt.Errorf("context courses: %w", err)
	}
	defer rows.Close()
	lc.Courses = []ContextCourse{}
	for rows.Next() {
		var cc ContextCourse
		if err := rows.Scan(&cc.ID, &cc.Title, &cc.Slug, &cc.EnrollmentStatus, &cc.TotalLessons, &cc.CompletedLessons); err != nil {
			return LearningContext{}, fmt.Errorf("scan context course: %w", err)
		}
		cc.ProgressPercent = pct(cc.CompletedLessons, cc.TotalLessons)
		if focusCourseID != nil && cc.ID == *focusCourseID {
			cc.IsFocus = true
		}
		lc.Courses = append(lc.Courses, cc)
	}
	if err := rows.Err(); err != nil {
		return LearningContext{}, err
	}

	// pick the focus course (explicit, else the single active one, else none)
	var focus *ContextCourse
	for i := range lc.Courses {
		if lc.Courses[i].IsFocus {
			focus = &lc.Courses[i]
		}
	}
	if focus == nil && focusCourseID == nil && len(lc.Courses) == 1 {
		focus = &lc.Courses[0]
	}
	if focus == nil {
		return lc, nil
	}
	lc.FocusCourse = focus
	fc := focus.ID

	// ---- current / last lesson ----
	var curLesson *string
	_ = r.pool.QueryRow(ctx, `
		SELECT l.title
		FROM lessons l
		JOIN modules m ON m.id = l.module_id
		LEFT JOIN lesson_progress lp ON lp.lesson_id = l.id AND lp.student_id = $1
		WHERE m.course_id = $2 AND l.is_published
		ORDER BY (coalesce(lp.status,'not_started') = 'completed'),
		         m.position, m.id, l.position, l.id
		LIMIT 1
	`, studentID, fc).Scan(&curLesson)
	lc.CurrentLesson = curLesson

	// ---- latest quiz attempt in the focus course ----
	var quiz ContextQuiz
	err = r.pool.QueryRow(ctx, `
		WITH latest AS (
			SELECT qa.assignment_id, qa.percent
			FROM quiz_attempts qa
			JOIN assignments a ON a.id = qa.assignment_id
			JOIN lessons l ON l.id = a.lesson_id
			JOIN modules m ON m.id = l.module_id
			WHERE qa.student_id = $1 AND m.course_id = $2 AND qa.status = 'submitted'
			ORDER BY qa.id DESC
			LIMIT 1
		)
		SELECT a.title,
		       (SELECT count(*) FROM quiz_attempts x WHERE x.assignment_id = latest.assignment_id AND x.student_id = $1 AND x.status = 'submitted'),
		       latest.percent,
		       coalesce(qs.pass_percent, 70),
		       coalesce((SELECT bool_or(x.passed) FROM quiz_attempts x WHERE x.assignment_id = latest.assignment_id AND x.student_id = $1), FALSE)
		FROM latest
		JOIN assignments a ON a.id = latest.assignment_id
		LEFT JOIN quiz_settings qs ON qs.assignment_id = a.id
	`, studentID, fc).Scan(&quiz.AssignmentTitle, &quiz.Attempts, &quiz.LatestPercent, &quiz.PassPercent, &quiz.Passed)
	if err == nil {
		lc.LatestQuiz = &quiz
	} else if !errors.Is(err, pgx.ErrNoRows) {
		return LearningContext{}, fmt.Errorf("context quiz: %w", err)
	}

	// ---- latest submission in the focus course ----
	var sub ContextSubmission
	err = r.pool.QueryRow(ctx, `
		SELECT s.id, a.title, a.assignment_type, s.status, s.score
		FROM submissions s
		JOIN assignments a ON a.id = s.assignment_id
		JOIN lessons l ON l.id = a.lesson_id
		JOIN modules m ON m.id = l.module_id
		WHERE s.student_id = $1 AND m.course_id = $2
		ORDER BY s.updated_at DESC, s.id DESC
		LIMIT 1
	`, studentID, fc).Scan(&sub.SubmissionID, &sub.AssignmentTitle, &sub.AssignmentType, &sub.Status, &sub.Score)
	if err == nil {
		lc.LatestSubmission = &sub
	} else if !errors.Is(err, pgx.ErrNoRows) {
		return LearningContext{}, fmt.Errorf("context submission: %w", err)
	}

	// ---- latest code run in the focus course ----
	var run ContextCodeRun
	err = r.pool.QueryRow(ctx, `
		SELECT a.title, cr.language, cr.status, cr.kind, cr.created_at
		FROM code_runs cr
		JOIN assignments a ON a.id = cr.assignment_id
		JOIN lessons l ON l.id = a.lesson_id
		JOIN modules m ON m.id = l.module_id
		WHERE cr.student_id = $1 AND m.course_id = $2
		ORDER BY cr.id DESC
		LIMIT 1
	`, studentID, fc).Scan(&run.AssignmentTitle, &run.Language, &run.Status, &run.Kind, &run.At)
	if err == nil {
		lc.LatestCodeRun = &run
	} else if !errors.Is(err, pgx.ErrNoRows) {
		return LearningContext{}, fmt.Errorf("context code run: %w", err)
	}

	// ---- certificate ----
	cert := ContextCertificate{}
	// issued?
	var certNum, certStatus *string
	_ = r.pool.QueryRow(ctx, `
		SELECT certificate_number, status FROM certificates WHERE user_id = $1 AND course_id = $2
	`, studentID, fc).Scan(&certNum, &certStatus)
	if certNum != nil {
		cert.Issued = true
		cert.CertificateNumber = certNum
		cert.Status = certStatus
	}
	// eligible? (enrollment completed OR every published lesson completed)
	var everComplete bool
	var total, done int
	_ = r.pool.QueryRow(ctx, `
		SELECT bool_or(e.status = 'completed'),
		       count(DISTINCT l.id) FILTER (WHERE l.is_published),
		       count(DISTINCT l.id) FILTER (WHERE l.is_published AND lp.status = 'completed')
		FROM enrollments e
		LEFT JOIN modules m ON m.course_id = e.course_id
		LEFT JOIN lessons l ON l.module_id = m.id
		LEFT JOIN lesson_progress lp ON lp.lesson_id = l.id AND lp.student_id = $1
		WHERE e.student_id = $1 AND e.course_id = $2 AND e.status IN ('active','completed')
	`, studentID, fc).Scan(&everComplete, &total, &done)
	cert.Eligible = everComplete || (total > 0 && done >= total)
	lc.Certificate = &cert

	return lc, nil
}

func pct(done, total int) int {
	if total <= 0 {
		return 0
	}
	return done * 100 / total
}

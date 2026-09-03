package academy

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

// teacherAudience is the audience predicate shared by every academy query:
// a course belongs to the academy iff audience IN ('teacher', 'both').
const teacherAudience = `audience IN ('teacher', 'both')`

/* ================= catalog + enrolment ================= */

// PublishedCourses returns every published academy course with its published
// lesson count.
func (r *Repository) PublishedCourses(ctx context.Context) ([]CourseCard, error) {
	rows, err := r.pool.Query(ctx, `
		SELECT c.id, c.title, c.slug, c.short_description, c.description, c.image_url, c.difficulty, c.audience,
		       COALESCE((
		           SELECT count(*) FROM lessons l
		           JOIN modules m ON m.id = l.module_id
		           WHERE m.course_id = c.id AND l.is_published
		       ), 0) AS total_lessons
		FROM courses c
		WHERE c.is_published = TRUE AND c.`+teacherAudience+`
		ORDER BY c.position ASC, c.id ASC
	`)
	if err != nil {
		return nil, fmt.Errorf("academy courses: %w", err)
	}
	defer rows.Close()
	out := []CourseCard{}
	for rows.Next() {
		var c CourseCard
		if err := rows.Scan(&c.ID, &c.Title, &c.Slug, &c.ShortDescription, &c.Description, &c.ImageURL,
			&c.Difficulty, &c.Audience, &c.TotalLessons); err != nil {
			return nil, fmt.Errorf("scan academy course: %w", err)
		}
		out = append(out, c)
	}
	return out, rows.Err()
}

// CourseAudience returns a course's audience + published flag, or
// ErrCourseNotFound.
func (r *Repository) CourseAudience(ctx context.Context, courseID int64) (audience string, published bool, err error) {
	err = r.pool.QueryRow(ctx,
		`SELECT audience, is_published FROM courses WHERE id = $1`, courseID).Scan(&audience, &published)
	if errors.Is(err, pgx.ErrNoRows) {
		return "", false, ErrCourseNotFound
	}
	return audience, published, err
}

// EnrolledCourseIDs returns the ids of academy courses the teacher currently
// has an active or completed enrolment in.
func (r *Repository) EnrolledCourseIDs(ctx context.Context, teacherID int64) (map[int64]bool, error) {
	rows, err := r.pool.Query(ctx, `
		SELECT e.course_id
		FROM enrollments e
		JOIN courses c ON c.id = e.course_id AND c.`+teacherAudience+`
		WHERE e.student_id = $1 AND e.status IN ('active', 'completed')
	`, teacherID)
	if err != nil {
		return nil, fmt.Errorf("enrolled course ids: %w", err)
	}
	defer rows.Close()
	out := map[int64]bool{}
	for rows.Next() {
		var id int64
		if err := rows.Scan(&id); err != nil {
			return nil, err
		}
		out[id] = true
	}
	return out, rows.Err()
}

// MyCourses returns the teacher's academy enrolments with a progress tally.
func (r *Repository) MyCourses(ctx context.Context, teacherID int64) ([]MyCourse, error) {
	rows, err := r.pool.Query(ctx, `
		SELECT c.id, c.title, c.slug, c.short_description, c.image_url, c.difficulty,
		       e.status, e.enrolled_at, e.completed_at,
		       count(*) FILTER (WHERE l.id IS NOT NULL AND l.is_published)                                AS total,
		       count(*) FILTER (WHERE l.id IS NOT NULL AND l.is_published AND lp.status = 'completed')     AS completed
		FROM enrollments e
		JOIN courses c ON c.id = e.course_id AND c.`+teacherAudience+`
		LEFT JOIN modules m ON m.course_id = c.id
		LEFT JOIN lessons l ON l.module_id = m.id
		LEFT JOIN lesson_progress lp ON lp.lesson_id = l.id AND lp.student_id = e.student_id
		WHERE e.student_id = $1 AND e.status IN ('active', 'completed')
		GROUP BY c.id, c.title, c.slug, c.short_description, c.image_url, c.difficulty,
		         e.status, e.enrolled_at, e.completed_at, c.position
		ORDER BY c.position ASC, c.id ASC
	`, teacherID)
	if err != nil {
		return nil, fmt.Errorf("academy my courses: %w", err)
	}
	defer rows.Close()
	out := []MyCourse{}
	for rows.Next() {
		var m MyCourse
		if err := rows.Scan(&m.CourseID, &m.Title, &m.Slug, &m.ShortDescription, &m.ImageURL, &m.Difficulty,
			&m.EnrollmentStatus, &m.EnrolledAt, &m.CompletedAt, &m.TotalLessons, &m.CompletedLessons); err != nil {
			return nil, fmt.Errorf("scan academy my course: %w", err)
		}
		if m.TotalLessons > 0 {
			m.ProgressPercent = m.CompletedLessons * 100 / m.TotalLessons
		}
		m.CourseCompleted = m.EnrollmentStatus == "completed" ||
			(m.TotalLessons > 0 && m.CompletedLessons >= m.TotalLessons)
		m.CertificateEligible = m.CourseCompleted
		out = append(out, m)
	}
	return out, rows.Err()
}

/* ================= admin ================= */

// Learners returns every teacher enrolled in at least one academy course.
func (r *Repository) Learners(ctx context.Context) ([]LearnerRow, error) {
	rows, err := r.pool.Query(ctx, `
		SELECT u.id, trim(u.first_name || ' ' || coalesce(u.last_name, '')), u.email,
		       count(DISTINCT e.course_id),
		       count(DISTINCT e.course_id) FILTER (WHERE e.status = 'completed')
		FROM enrollments e
		JOIN users u ON u.id = e.student_id AND u.role = 'teacher'
		JOIN courses c ON c.id = e.course_id AND c.`+teacherAudience+`
		WHERE e.status IN ('active', 'completed')
		GROUP BY u.id, u.first_name, u.last_name, u.email
		ORDER BY u.first_name, u.id
	`)
	if err != nil {
		return nil, fmt.Errorf("academy learners: %w", err)
	}
	defer rows.Close()
	out := []LearnerRow{}
	for rows.Next() {
		var it LearnerRow
		if err := rows.Scan(&it.TeacherID, &it.Name, &it.Email, &it.CoursesEnrolled, &it.CoursesCompleted); err != nil {
			return nil, err
		}
		out = append(out, it)
	}
	return out, rows.Err()
}

const academySubmissionCols = `
	s.id, s.status, s.score, s.submitted_at, s.checked_at,
	u.id, trim(u.first_name || ' ' || coalesce(u.last_name, '')),
	a.id, a.assignment_type, a.title, a.points,
	l.title, c.id, c.title`

const academySubmissionFrom = `
	FROM submissions s
	JOIN assignments a ON a.id = s.assignment_id
	JOIN lessons l ON l.id = a.lesson_id
	JOIN modules m ON m.id = l.module_id
	JOIN courses c ON c.id = m.course_id AND c.` + teacherAudience + `
	JOIN users u ON u.id = s.student_id`

func scanAcademySubmissionRow(row interface{ Scan(...any) error }) (AcademySubmissionRow, error) {
	var it AcademySubmissionRow
	err := row.Scan(&it.ID, &it.Status, &it.Score, &it.SubmittedAt, &it.CheckedAt,
		&it.TeacherID, &it.TeacherName,
		&it.AssignmentID, &it.AssignmentType, &it.AssignmentName, &it.Points,
		&it.LessonTitle, &it.CourseID, &it.CourseTitle)
	return it, err
}

// Submissions lists academy submissions. status: "" → pending
// (submitted/checking), "all", or an exact status.
func (r *Repository) Submissions(ctx context.Context, status string) ([]AcademySubmissionRow, error) {
	where := ""
	args := []any{}
	switch status {
	case "", "pending":
		where = " WHERE s.status IN ('submitted', 'checking')"
	case "all":
		where = ""
	default:
		args = append(args, status)
		where = " WHERE s.status = $1"
	}
	rows, err := r.pool.Query(ctx,
		`SELECT `+academySubmissionCols+academySubmissionFrom+where+` ORDER BY s.submitted_at ASC NULLS LAST, s.id ASC`, args...)
	if err != nil {
		return nil, fmt.Errorf("academy submissions: %w", err)
	}
	defer rows.Close()
	out := []AcademySubmissionRow{}
	for rows.Next() {
		it, err := scanAcademySubmissionRow(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, it)
	}
	return out, rows.Err()
}

// SubmissionDetail returns one academy submission, or ErrSubmissionNotFound.
func (r *Repository) SubmissionDetail(ctx context.Context, id int64) (AcademySubmissionDetail, error) {
	var d AcademySubmissionDetail
	err := r.pool.QueryRow(ctx, `
		SELECT `+academySubmissionCols+`,
		       s.answer, s.code, s.teacher_feedback, a.description, a.language
		`+academySubmissionFrom+`
		WHERE s.id = $1
	`, id).Scan(&d.ID, &d.Status, &d.Score, &d.SubmittedAt, &d.CheckedAt,
		&d.TeacherID, &d.TeacherName,
		&d.AssignmentID, &d.AssignmentType, &d.AssignmentName, &d.Points,
		&d.LessonTitle, &d.CourseID, &d.CourseTitle,
		&d.Answer, &d.Code, &d.TeacherFeedback, &d.AssignmentDescription, &d.AssignmentLanguage)
	if errors.Is(err, pgx.ErrNoRows) {
		return AcademySubmissionDetail{}, ErrSubmissionNotFound
	}
	if err != nil {
		return AcademySubmissionDetail{}, fmt.Errorf("academy submission detail: %w", err)
	}
	return d, nil
}

// PendingReviewCount is the number of academy methodology/project submissions
// awaiting an admin verdict.
func (r *Repository) PendingReviewCount(ctx context.Context) (int, error) {
	var n int
	err := r.pool.QueryRow(ctx, `
		SELECT count(*)
		FROM submissions s
		JOIN assignments a ON a.id = s.assignment_id
		JOIN lessons l ON l.id = a.lesson_id
		JOIN modules m ON m.id = l.module_id
		JOIN courses c ON c.id = m.course_id AND c.`+teacherAudience+`
		WHERE s.status IN ('submitted', 'checking')
	`).Scan(&n)
	return n, err
}

// IsAcademySubmission reports whether a submission belongs to an academy
// (teacher-audience) course.
func (r *Repository) IsAcademySubmission(ctx context.Context, id int64) (bool, error) {
	var ok bool
	err := r.pool.QueryRow(ctx, `
		SELECT EXISTS (
			SELECT 1 FROM submissions s
			JOIN assignments a ON a.id = s.assignment_id
			JOIN lessons l ON l.id = a.lesson_id
			JOIN modules m ON m.id = l.module_id
			JOIN courses c ON c.id = m.course_id AND c.`+teacherAudience+`
			WHERE s.id = $1
		)
	`, id).Scan(&ok)
	return ok, err
}

// WriteAudit records an admin academy action in the shared admin_audit_log.
func (r *Repository) WriteAudit(ctx context.Context, adminID int64, action, entity string, entityID *int64, summary string) error {
	_, err := r.pool.Exec(ctx, `
		INSERT INTO admin_audit_log (admin_id, action, entity, entity_id, summary)
		VALUES ($1,$2,$3,$4,$5)`, adminID, action, entity, entityID, summary)
	return err
}

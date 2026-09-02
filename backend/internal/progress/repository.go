package progress

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

const lpColumns = `
	id, student_id, lesson_id, status, progress_percent,
	started_at, completed_at, created_at, updated_at
`

// Start records that a student has begun a lesson. Idempotent: a second call
// (or a call after the lesson is already in progress / completed) never
// creates a duplicate row and never downgrades the status.
func (r *Repository) Start(ctx context.Context, studentID, lessonID int64) (LessonProgress, error) {
	row := r.pool.QueryRow(ctx, `
		INSERT INTO lesson_progress (student_id, lesson_id, status, progress_percent, started_at)
		VALUES ($1, $2, 'in_progress', 0, NOW())
		ON CONFLICT (student_id, lesson_id) DO UPDATE SET
			status = CASE WHEN lesson_progress.status = 'not_started'
			              THEN 'in_progress' ELSE lesson_progress.status END,
			started_at = COALESCE(lesson_progress.started_at, NOW()),
			updated_at = NOW()
		RETURNING `+lpColumns, studentID, lessonID)

	p, err := scanLessonProgress(row)
	if err != nil {
		return LessonProgress{}, fmt.Errorf("start lesson: %w", err)
	}
	return p, nil
}

// CompleteLessonTx marks a lesson completed and, in the same transaction,
// recalculates the course tally and auto-completes the enrollment if every
// published lesson is now done.
//
// The enrollments UPDATE lives here (rather than in the enrollments package)
// so the whole "complete lesson → recount → maybe complete course" chain is
// one atomic unit, as the spec requires.
func (r *Repository) CompleteLessonTx(ctx context.Context, studentID, lessonID, courseID int64) (CompleteResult, error) {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return CompleteResult{}, fmt.Errorf("begin complete tx: %w", err)
	}
	defer tx.Rollback(ctx) //nolint:errcheck // no-op after commit

	row := tx.QueryRow(ctx, `
		INSERT INTO lesson_progress (student_id, lesson_id, status, progress_percent, started_at, completed_at)
		VALUES ($1, $2, 'completed', 100, NOW(), NOW())
		ON CONFLICT (student_id, lesson_id) DO UPDATE SET
			status = 'completed',
			progress_percent = 100,
			started_at = COALESCE(lesson_progress.started_at, NOW()),
			completed_at = COALESCE(lesson_progress.completed_at, NOW()),
			updated_at = NOW()
		RETURNING `+lpColumns, studentID, lessonID)

	lp, err := scanLessonProgress(row)
	if err != nil {
		return CompleteResult{}, fmt.Errorf("complete lesson: %w", err)
	}

	counts, err := courseCounts(ctx, tx, studentID, courseID)
	if err != nil {
		return CompleteResult{}, err
	}

	enrollmentCompleted := false
	if counts.TotalLessons > 0 && counts.CompletedLessons >= counts.TotalLessons {
		tag, err := tx.Exec(ctx, `
			UPDATE enrollments
			SET status = 'completed', completed_at = NOW(), updated_at = NOW()
			WHERE student_id = $1 AND course_id = $2 AND status = 'active'
		`, studentID, courseID)
		if err != nil {
			return CompleteResult{}, fmt.Errorf("auto-complete enrollment: %w", err)
		}
		enrollmentCompleted = tag.RowsAffected() > 0
	}

	if err := tx.Commit(ctx); err != nil {
		return CompleteResult{}, fmt.Errorf("commit complete tx: %w", err)
	}
	return CompleteResult{Lesson: lp, Course: counts, EnrollmentCompleted: enrollmentCompleted}, nil
}

// CourseCountsFor returns the completed/total published-lesson tally for one
// course and student.
func (r *Repository) CourseCountsFor(ctx context.Context, studentID, courseID int64) (CourseCounts, error) {
	return courseCounts(ctx, r.pool, studentID, courseID)
}

// SummaryForStudent returns the tally for every course the student is
// enrolled in (active or completed), ordered by course id.
func (r *Repository) SummaryForStudent(ctx context.Context, studentID int64) ([]CourseCounts, error) {
	rows, err := r.pool.Query(ctx, `
		SELECT
			c.id,
			c.title,
			count(*) FILTER (WHERE l.id IS NOT NULL AND l.is_published) AS total,
			count(*) FILTER (WHERE l.id IS NOT NULL AND l.is_published AND lp.status = 'completed') AS completed
		FROM enrollments e
		JOIN courses c ON c.id = e.course_id
		LEFT JOIN modules m ON m.course_id = c.id
		LEFT JOIN lessons l ON l.module_id = m.id
		LEFT JOIN lesson_progress lp ON lp.lesson_id = l.id AND lp.student_id = e.student_id
		WHERE e.student_id = $1 AND e.status IN ('active', 'completed')
		GROUP BY c.id, c.title
		ORDER BY c.id
	`, studentID)
	if err != nil {
		return nil, fmt.Errorf("progress summary: %w", err)
	}
	defer rows.Close()

	var out []CourseCounts
	for rows.Next() {
		var cc CourseCounts
		if err := rows.Scan(&cc.CourseID, &cc.Title, &cc.TotalLessons, &cc.CompletedLessons); err != nil {
			return nil, fmt.Errorf("scan progress summary: %w", err)
		}
		out = append(out, cc)
	}
	return out, rows.Err()
}

// LessonProgressForCourse returns one row per published lesson in the course,
// with the student's status (synthesizing 'not_started' where no row exists),
// ordered by module then lesson position.
func (r *Repository) LessonProgressForCourse(ctx context.Context, studentID, courseID int64) ([]LessonProgress, error) {
	rows, err := r.pool.Query(ctx, `
		SELECT
			l.id,
			COALESCE(lp.status, 'not_started'),
			COALESCE(lp.progress_percent, 0),
			lp.started_at,
			lp.completed_at
		FROM lessons l
		JOIN modules m ON m.id = l.module_id
		LEFT JOIN lesson_progress lp ON lp.lesson_id = l.id AND lp.student_id = $1
		WHERE m.course_id = $2 AND l.is_published = TRUE
		ORDER BY m.position ASC, m.id ASC, l.position ASC, l.id ASC
	`, studentID, courseID)
	if err != nil {
		return nil, fmt.Errorf("lesson progress for course: %w", err)
	}
	defer rows.Close()

	var out []LessonProgress
	for rows.Next() {
		var p LessonProgress
		p.StudentID = studentID
		if err := rows.Scan(&p.LessonID, &p.Status, &p.ProgressPercent, &p.StartedAt, &p.CompletedAt); err != nil {
			return nil, fmt.Errorf("scan lesson progress: %w", err)
		}
		out = append(out, p)
	}
	return out, rows.Err()
}

// courseCounts runs the tally query against either the pool or a transaction.
func courseCounts(ctx context.Context, q querier, studentID, courseID int64) (CourseCounts, error) {
	cc := CourseCounts{CourseID: courseID}
	err := q.QueryRow(ctx, `
		SELECT
			c.title,
			count(*) FILTER (WHERE l.id IS NOT NULL AND l.is_published) AS total,
			count(*) FILTER (WHERE l.id IS NOT NULL AND l.is_published AND lp.status = 'completed') AS completed
		FROM courses c
		LEFT JOIN modules m ON m.course_id = c.id
		LEFT JOIN lessons l ON l.module_id = m.id
		LEFT JOIN lesson_progress lp ON lp.lesson_id = l.id AND lp.student_id = $1
		WHERE c.id = $2
		GROUP BY c.title
	`, studentID, courseID).Scan(&cc.Title, &cc.TotalLessons, &cc.CompletedLessons)
	if errors.Is(err, pgx.ErrNoRows) {
		return CourseCounts{CourseID: courseID}, nil
	}
	if err != nil {
		return CourseCounts{}, fmt.Errorf("course counts: %w", err)
	}
	return cc, nil
}

// querier is the read surface shared by *pgxpool.Pool and pgx.Tx.
type querier interface {
	QueryRow(ctx context.Context, sql string, args ...any) pgx.Row
}

type rowScanner interface {
	Scan(dest ...any) error
}

func scanLessonProgress(row rowScanner) (LessonProgress, error) {
	var p LessonProgress
	err := row.Scan(
		&p.ID, &p.StudentID, &p.LessonID, &p.Status, &p.ProgressPercent,
		&p.StartedAt, &p.CompletedAt, &p.CreatedAt, &p.UpdatedAt,
	)
	return p, err
}

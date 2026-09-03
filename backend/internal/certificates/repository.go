package certificates

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"time"

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

const columns = `
	id, user_id, course_id, certificate_number, verification_code,
	learner_name, course_title, issued_at, completed_at, status,
	revoked_at, revoked_by, revoke_reason, created_at, updated_at
`

func scanCertificate(row rowScanner) (Certificate, error) {
	var c Certificate
	err := row.Scan(
		&c.ID, &c.UserID, &c.CourseID, &c.CertificateNumber, &c.VerificationCode,
		&c.LearnerName, &c.CourseTitle, &c.IssuedAt, &c.CompletedAt, &c.Status,
		&c.RevokedAt, &c.RevokedBy, &c.RevokeReason, &c.CreatedAt, &c.UpdatedAt,
	)
	return c, err
}

type rowScanner interface{ Scan(dest ...any) error }

// Eligibility derives the authoritative completion state for (user, course)
// from existing LMS tables only. A learner is "completed" when their
// enrollment is already marked completed (the authoritative rule, set
// atomically by the progress package) OR every published lesson in the
// course is completed. Works identically for a student course and a Teacher
// Academy course because both use the same enrollments / lesson_progress
// tables (enrollments.student_id = the learner's users.id).
func (r *Repository) Eligibility(ctx context.Context, userID, courseID int64) (Eligibility, error) {
	var (
		e            Eligibility
		everComplete bool
		enrCompleted *time.Time
		lastLessonAt *time.Time
	)
	err := r.pool.QueryRow(ctx, `
		SELECT
			bool_or(e.status = 'completed')                                                       AS ever_completed,
			max(e.completed_at)                                                                   AS enr_completed_at,
			c.title,
			trim(u.first_name || ' ' || coalesce(u.last_name, ''))                                AS learner_name,
			count(DISTINCT l.id) FILTER (WHERE l.is_published)                                     AS total_lessons,
			count(DISTINCT l.id) FILTER (WHERE l.is_published AND lp.status = 'completed')          AS done_lessons,
			max(lp.completed_at) FILTER (WHERE lp.status = 'completed')                            AS last_lesson_at
		FROM enrollments e
		JOIN courses c ON c.id = e.course_id
		JOIN users u ON u.id = e.student_id
		LEFT JOIN modules m ON m.course_id = c.id
		LEFT JOIN lessons l ON l.module_id = m.id
		LEFT JOIN lesson_progress lp ON lp.lesson_id = l.id AND lp.student_id = e.student_id
		WHERE e.student_id = $1 AND e.course_id = $2 AND e.status IN ('active', 'completed')
		GROUP BY c.title, u.first_name, u.last_name
	`, userID, courseID).Scan(
		&everComplete, &enrCompleted, &e.CourseTitle, &e.LearnerName,
		&e.TotalLessons, &e.DoneLessons, &lastLessonAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return Eligibility{Enrolled: false}, nil
	}
	if err != nil {
		return Eligibility{}, fmt.Errorf("certificate eligibility: %w", err)
	}

	e.Enrolled = true
	e.Completed = everComplete || (e.TotalLessons > 0 && e.DoneLessons >= e.TotalLessons)
	switch {
	case enrCompleted != nil:
		e.CompletedAt = *enrCompleted
	case lastLessonAt != nil:
		e.CompletedAt = *lastLessonAt
	default:
		e.CompletedAt = time.Now().UTC()
	}
	return e, nil
}

// YearSeq returns the next per-year sequence number for a certificate.
func (r *Repository) YearSeq(ctx context.Context, year int) (int, error) {
	var n int
	prefix := fmt.Sprintf("CS-%d-%%", year)
	if err := r.pool.QueryRow(ctx,
		`SELECT count(*) + 1 FROM certificates WHERE certificate_number LIKE $1`, prefix,
	).Scan(&n); err != nil {
		return 0, fmt.Errorf("certificate year seq: %w", err)
	}
	return n, nil
}

// Insert creates a certificate. It returns errUserCourseConflict if the
// learner already has one for this course (idempotency race) and
// errNumberOrCodeConflict if the generated number/code collided.
func (r *Repository) Insert(ctx context.Context, c Certificate) (Certificate, error) {
	row := r.pool.QueryRow(ctx, `
		INSERT INTO certificates
			(user_id, course_id, certificate_number, verification_code, learner_name, course_title, completed_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		RETURNING `+columns,
		c.UserID, c.CourseID, c.CertificateNumber, c.VerificationCode,
		c.LearnerName, c.CourseTitle, c.CompletedAt,
	)
	created, err := scanCertificate(row)
	if err == nil {
		return created, nil
	}
	var pgErr *pgconn.PgError
	if errors.As(err, &pgErr) && pgErr.Code == "23505" {
		switch pgErr.ConstraintName {
		case "idx_certificates_user_course":
			return Certificate{}, errUserCourseConflict
		case "idx_certificates_number", "idx_certificates_verification_code":
			return Certificate{}, errNumberOrCodeConflict
		}
	}
	return Certificate{}, fmt.Errorf("insert certificate: %w", err)
}

func (r *Repository) GetByID(ctx context.Context, id int64) (Certificate, error) {
	row := r.pool.QueryRow(ctx, `SELECT `+columns+` FROM certificates WHERE id = $1`, id)
	c, err := scanCertificate(row)
	if errors.Is(err, pgx.ErrNoRows) {
		return Certificate{}, ErrNotFound
	}
	if err != nil {
		return Certificate{}, fmt.Errorf("get certificate: %w", err)
	}
	return c, nil
}

func (r *Repository) GetByUserCourse(ctx context.Context, userID, courseID int64) (Certificate, error) {
	row := r.pool.QueryRow(ctx,
		`SELECT `+columns+` FROM certificates WHERE user_id = $1 AND course_id = $2`, userID, courseID)
	c, err := scanCertificate(row)
	if errors.Is(err, pgx.ErrNoRows) {
		return Certificate{}, ErrNotFound
	}
	if err != nil {
		return Certificate{}, fmt.Errorf("get certificate by user+course: %w", err)
	}
	return c, nil
}

func (r *Repository) GetByCode(ctx context.Context, code string) (Certificate, error) {
	row := r.pool.QueryRow(ctx,
		`SELECT `+columns+` FROM certificates WHERE verification_code = $1`, normalizeCode(code))
	c, err := scanCertificate(row)
	if errors.Is(err, pgx.ErrNoRows) {
		return Certificate{}, ErrNotFound
	}
	if err != nil {
		return Certificate{}, fmt.Errorf("get certificate by code: %w", err)
	}
	return c, nil
}

func (r *Repository) ListByUser(ctx context.Context, userID int64) ([]Certificate, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT `+columns+` FROM certificates WHERE user_id = $1 ORDER BY issued_at DESC, id DESC`, userID)
	if err != nil {
		return nil, fmt.Errorf("list certificates: %w", err)
	}
	defer rows.Close()
	out := []Certificate{}
	for rows.Next() {
		c, err := scanCertificate(rows)
		if err != nil {
			return nil, fmt.Errorf("scan certificate: %w", err)
		}
		out = append(out, c)
	}
	return out, rows.Err()
}

// AdminRow is a certificate plus joined display fields for the admin views.
type AdminRow struct {
	Certificate
	LearnerRole string
}

func (r *Repository) AdminList(ctx context.Context, f AdminListFilter) ([]AdminRow, int, error) {
	where := []string{"1 = 1"}
	args := []any{}
	if f.Status != "" {
		args = append(args, f.Status)
		where = append(where, fmt.Sprintf("cert.status = $%d", len(args)))
	}
	if f.CourseID != nil {
		args = append(args, *f.CourseID)
		where = append(where, fmt.Sprintf("cert.course_id = $%d", len(args)))
	}
	if q := strings.TrimSpace(f.Query); q != "" {
		args = append(args, "%"+q+"%")
		where = append(where, fmt.Sprintf(
			"(cert.certificate_number ILIKE $%d OR cert.learner_name ILIKE $%d)", len(args), len(args)))
	}
	whereSQL := strings.Join(where, " AND ")

	var total int
	if err := r.pool.QueryRow(ctx,
		`SELECT count(*) FROM certificates cert WHERE `+whereSQL, args...).Scan(&total); err != nil {
		return nil, 0, fmt.Errorf("count certificates: %w", err)
	}

	limit := f.Limit
	if limit <= 0 || limit > 100 {
		limit = 20
	}
	page := f.Page
	if page <= 0 {
		page = 1
	}
	args = append(args, limit)
	limitParam := len(args)
	args = append(args, (page-1)*limit)
	offsetParam := len(args)

	rows, err := r.pool.Query(ctx, fmt.Sprintf(`
		SELECT %s, u.role
		FROM certificates cert
		JOIN users u ON u.id = cert.user_id
		WHERE %s
		ORDER BY cert.issued_at DESC, cert.id DESC
		LIMIT $%d OFFSET $%d`, prefixed("cert"), whereSQL, limitParam, offsetParam), args...)
	if err != nil {
		return nil, 0, fmt.Errorf("list certificates: %w", err)
	}
	defer rows.Close()
	out := []AdminRow{}
	for rows.Next() {
		var ar AdminRow
		if err := scanAdminRow(rows, &ar); err != nil {
			return nil, 0, fmt.Errorf("scan certificate row: %w", err)
		}
		out = append(out, ar)
	}
	return out, total, rows.Err()
}

func (r *Repository) AdminGet(ctx context.Context, id int64) (AdminRow, error) {
	row := r.pool.QueryRow(ctx, `
		SELECT `+prefixed("cert")+`, u.role
		FROM certificates cert
		JOIN users u ON u.id = cert.user_id
		WHERE cert.id = $1`, id)
	var ar AdminRow
	if err := scanAdminRow(row, &ar); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return AdminRow{}, ErrNotFound
		}
		return AdminRow{}, fmt.Errorf("get certificate row: %w", err)
	}
	return ar, nil
}

// Revoke flips an active certificate to revoked. Returns ErrNotFound if it
// does not exist and ErrAlreadyRevoked if it was already revoked.
func (r *Repository) Revoke(ctx context.Context, id, adminID int64, reason string) (Certificate, error) {
	row := r.pool.QueryRow(ctx, `
		UPDATE certificates
		SET status = 'revoked', revoked_at = NOW(), revoked_by = $2, revoke_reason = $3, updated_at = NOW()
		WHERE id = $1 AND status = 'active'
		RETURNING `+columns, id, adminID, reason)
	c, err := scanCertificate(row)
	if errors.Is(err, pgx.ErrNoRows) {
		// distinguish "missing" from "already revoked"
		if _, gErr := r.GetByID(ctx, id); errors.Is(gErr, ErrNotFound) {
			return Certificate{}, ErrNotFound
		}
		return Certificate{}, ErrAlreadyRevoked
	}
	if err != nil {
		return Certificate{}, fmt.Errorf("revoke certificate: %w", err)
	}
	return c, nil
}

// prefixed returns the column list qualified with a table alias.
func prefixed(alias string) string {
	parts := strings.Split(strings.ReplaceAll(columns, "\n", " "), ",")
	for i, p := range parts {
		parts[i] = alias + "." + strings.TrimSpace(p)
	}
	return strings.Join(parts, ", ")
}

func scanAdminRow(row rowScanner, ar *AdminRow) error {
	return row.Scan(
		&ar.ID, &ar.UserID, &ar.CourseID, &ar.CertificateNumber, &ar.VerificationCode,
		&ar.LearnerName, &ar.CourseTitle, &ar.IssuedAt, &ar.CompletedAt, &ar.Status,
		&ar.RevokedAt, &ar.RevokedBy, &ar.RevokeReason, &ar.CreatedAt, &ar.UpdatedAt,
		&ar.LearnerRole,
	)
}

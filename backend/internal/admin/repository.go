package admin

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

type rowScanner interface {
	Scan(dest ...any) error
}

// classify maps a raw pgx error to an admin sentinel.
func classify(err error) error {
	if err == nil {
		return nil
	}
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	var pgErr *pgconn.PgError
	if errors.As(err, &pgErr) {
		switch pgErr.Code {
		case "23505": // unique_violation
			return ErrConflict
		case "23503": // foreign_key_violation
			return ErrValidation
		case "23514": // check_violation
			return ErrValidation
		}
	}
	return err
}

// updateRow builds `UPDATE <table> SET <fields>, updated_at = NOW()
// WHERE id = $N RETURNING <returning>`. Column names come only from trusted
// internal callers — never from request bodies.
func (r *Repository) updateRow(ctx context.Context, table string, id int64, fields map[string]any, returning string) pgx.Row {
	set := make([]string, 0, len(fields)+1)
	args := make([]any, 0, len(fields)+1)
	for col, val := range fields {
		args = append(args, val)
		set = append(set, fmt.Sprintf("%s = $%d", col, len(args)))
	}
	set = append(set, "updated_at = NOW()")
	args = append(args, id)
	q := fmt.Sprintf("UPDATE %s SET %s WHERE id = $%d RETURNING %s",
		table, strings.Join(set, ", "), len(args), returning)
	return r.pool.QueryRow(ctx, q, args...)
}

func (r *Repository) deleteByID(ctx context.Context, table string, id int64) error {
	tag, err := r.pool.Exec(ctx, fmt.Sprintf("DELETE FROM %s WHERE id = $1", table), id)
	if err != nil {
		return classify(err)
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

/* ===================================================================
   overview
   =================================================================== */

func (r *Repository) Overview(ctx context.Context) (Overview, error) {
	o := Overview{Users: map[string]int{}}

	rows, err := r.pool.Query(ctx, `SELECT role, count(*) FROM users GROUP BY role`)
	if err != nil {
		return Overview{}, fmt.Errorf("overview users: %w", err)
	}
	for rows.Next() {
		var role string
		var n int
		if err := rows.Scan(&role, &n); err != nil {
			rows.Close()
			return Overview{}, err
		}
		o.Users[role] = n
	}
	rows.Close()
	if err := rows.Err(); err != nil {
		return Overview{}, err
	}

	err = r.pool.QueryRow(ctx, `
		SELECT
			(SELECT count(*) FROM users WHERE is_active),
			(SELECT count(*) FROM programs),
			(SELECT count(*) FROM courses),
			(SELECT count(*) FROM courses WHERE is_published),
			(SELECT count(*) FROM groups),
			(SELECT count(*) FROM submissions WHERE status = 'submitted'),
			(SELECT count(*) FROM parent_children)
	`).Scan(&o.ActiveUsers, &o.Programs, &o.Courses, &o.PublishedCourses, &o.Groups, &o.PendingSubmissions, &o.ParentLinks)
	if err != nil {
		return Overview{}, fmt.Errorf("overview counts: %w", err)
	}
	return o, nil
}

/* ===================================================================
   users
   =================================================================== */

const userCols = `id, email, phone, first_name, last_name, role, is_active, created_at, updated_at`

func scanUser(row rowScanner) (UserRow, error) {
	var u UserRow
	err := row.Scan(&u.ID, &u.Email, &u.Phone, &u.FirstName, &u.LastName, &u.Role, &u.IsActive, &u.CreatedAt, &u.UpdatedAt)
	return u, err
}

func (r *Repository) ListUsers(ctx context.Context, f UserFilter) ([]UserRow, int, error) {
	conds := []string{"1=1"}
	args := []any{}
	if f.Role != "" {
		args = append(args, f.Role)
		conds = append(conds, fmt.Sprintf("role = $%d", len(args)))
	}
	if f.Active != nil {
		args = append(args, *f.Active)
		conds = append(conds, fmt.Sprintf("is_active = $%d", len(args)))
	}
	if f.Search != "" {
		args = append(args, "%"+strings.ToLower(f.Search)+"%")
		conds = append(conds, fmt.Sprintf(
			"(lower(first_name) LIKE $%d OR lower(coalesce(last_name,'')) LIKE $%d OR lower(coalesce(email,'')) LIKE $%d OR coalesce(phone,'') LIKE $%d)",
			len(args), len(args), len(args), len(args)))
	}
	where := strings.Join(conds, " AND ")

	var total int
	if err := r.pool.QueryRow(ctx, `SELECT count(*) FROM users WHERE `+where, args...).Scan(&total); err != nil {
		return nil, 0, fmt.Errorf("count users: %w", err)
	}

	args = append(args, f.Limit, (f.Page-1)*f.Limit)
	rows, err := r.pool.Query(ctx, fmt.Sprintf(
		`SELECT %s FROM users WHERE %s ORDER BY created_at DESC, id DESC LIMIT $%d OFFSET $%d`,
		userCols, where, len(args)-1, len(args)), args...)
	if err != nil {
		return nil, 0, fmt.Errorf("list users: %w", err)
	}
	defer rows.Close()

	out := []UserRow{}
	for rows.Next() {
		u, err := scanUser(rows)
		if err != nil {
			return nil, 0, err
		}
		out = append(out, u)
	}
	return out, total, rows.Err()
}

func (r *Repository) GetUser(ctx context.Context, id int64) (UserRow, error) {
	u, err := scanUser(r.pool.QueryRow(ctx, `SELECT `+userCols+` FROM users WHERE id = $1`, id))
	return u, classify(err)
}

func (r *Repository) CreateUser(ctx context.Context, email, phone *string, passwordHash, firstName string, lastName *string, role string) (UserRow, error) {
	u, err := scanUser(r.pool.QueryRow(ctx, `
		INSERT INTO users (email, phone, password_hash, first_name, last_name, role)
		VALUES ($1,$2,$3,$4,$5,$6)
		RETURNING `+userCols, email, phone, passwordHash, firstName, lastName, role))
	if err != nil {
		return UserRow{}, mapUserErr(err)
	}
	return u, nil
}

func (r *Repository) UpdateUser(ctx context.Context, id int64, fields map[string]any) (UserRow, error) {
	if len(fields) == 0 {
		return r.GetUser(ctx, id)
	}
	u, err := scanUser(r.updateRow(ctx, "users", id, fields, userCols))
	if err != nil {
		return UserRow{}, mapUserErr(err)
	}
	return u, nil
}

func (r *Repository) SetUserPassword(ctx context.Context, id int64, passwordHash string) error {
	tag, err := r.pool.Exec(ctx, `UPDATE users SET password_hash = $2, updated_at = NOW() WHERE id = $1`, id, passwordHash)
	if err != nil {
		return classify(err)
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

func (r *Repository) DeleteUser(ctx context.Context, id int64) error {
	return r.deleteByID(ctx, "users", id)
}

// CountActiveAdminsExcluding is used to protect the last admin.
func (r *Repository) CountActiveAdminsExcluding(ctx context.Context, excludeID int64) (int, error) {
	var n int
	err := r.pool.QueryRow(ctx,
		`SELECT count(*) FROM users WHERE role = 'admin' AND is_active = TRUE AND id <> $1`, excludeID).Scan(&n)
	return n, err
}

// RoleOf returns a user's role, or ErrNotFound.
func (r *Repository) RoleOf(ctx context.Context, id int64) (string, error) {
	var role string
	err := r.pool.QueryRow(ctx, `SELECT role FROM users WHERE id = $1`, id).Scan(&role)
	if errors.Is(err, pgx.ErrNoRows) {
		return "", ErrNotFound
	}
	return role, err
}

func mapUserErr(err error) error {
	var pgErr *pgconn.PgError
	if errors.As(err, &pgErr) && pgErr.Code == "23505" {
		switch pgErr.ConstraintName {
		case "idx_users_email_unique":
			return ErrDuplicateEmail
		case "idx_users_phone_unique":
			return ErrDuplicatePhone
		}
	}
	return classify(err)
}

/* ===================================================================
   parent-child links
   =================================================================== */

func (r *Repository) ListParentLinks(ctx context.Context, parentID, childID *int64) ([]ParentLinkRow, error) {
	conds := []string{"1=1"}
	args := []any{}
	if parentID != nil {
		args = append(args, *parentID)
		conds = append(conds, fmt.Sprintf("pc.parent_id = $%d", len(args)))
	}
	if childID != nil {
		args = append(args, *childID)
		conds = append(conds, fmt.Sprintf("pc.child_id = $%d", len(args)))
	}
	rows, err := r.pool.Query(ctx, fmt.Sprintf(`
		SELECT pc.parent_id, trim(p.first_name || ' ' || coalesce(p.last_name,'')),
		       pc.child_id, trim(c.first_name || ' ' || coalesce(c.last_name,'')),
		       pc.linked_at
		FROM parent_children pc
		JOIN users p ON p.id = pc.parent_id
		JOIN users c ON c.id = pc.child_id
		WHERE %s
		ORDER BY pc.linked_at DESC`, strings.Join(conds, " AND ")), args...)
	if err != nil {
		return nil, fmt.Errorf("list parent links: %w", err)
	}
	defer rows.Close()
	out := []ParentLinkRow{}
	for rows.Next() {
		var it ParentLinkRow
		if err := rows.Scan(&it.ParentID, &it.ParentName, &it.ChildID, &it.ChildName, &it.LinkedAt); err != nil {
			return nil, err
		}
		out = append(out, it)
	}
	return out, rows.Err()
}

func (r *Repository) CreateParentLink(ctx context.Context, parentID, childID int64) error {
	_, err := r.pool.Exec(ctx,
		`INSERT INTO parent_children (parent_id, child_id) VALUES ($1, $2)`, parentID, childID)
	return classify(err)
}

func (r *Repository) DeleteParentLink(ctx context.Context, parentID, childID int64) error {
	tag, err := r.pool.Exec(ctx,
		`DELETE FROM parent_children WHERE parent_id = $1 AND child_id = $2`, parentID, childID)
	if err != nil {
		return classify(err)
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

/* ===================================================================
   programs
   =================================================================== */

const programCols = `id, title, slug, description, age_from, age_to, is_active, created_at, updated_at`

func scanProgram(row rowScanner) (ProgramRow, error) {
	var p ProgramRow
	err := row.Scan(&p.ID, &p.Title, &p.Slug, &p.Description, &p.AgeFrom, &p.AgeTo, &p.IsActive, &p.CreatedAt, &p.UpdatedAt)
	return p, err
}

func (r *Repository) ListPrograms(ctx context.Context) ([]ProgramRow, error) {
	rows, err := r.pool.Query(ctx, `SELECT `+programCols+` FROM programs ORDER BY title, id`)
	if err != nil {
		return nil, fmt.Errorf("list programs: %w", err)
	}
	defer rows.Close()
	out := []ProgramRow{}
	for rows.Next() {
		p, err := scanProgram(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, p)
	}
	return out, rows.Err()
}

func (r *Repository) GetProgram(ctx context.Context, id int64) (ProgramRow, error) {
	p, err := scanProgram(r.pool.QueryRow(ctx, `SELECT `+programCols+` FROM programs WHERE id = $1`, id))
	return p, classify(err)
}

func (r *Repository) CreateProgram(ctx context.Context, req CreateProgramRequest) (ProgramRow, error) {
	p, err := scanProgram(r.pool.QueryRow(ctx, `
		INSERT INTO programs (title, slug, description, age_from, age_to, is_active)
		VALUES ($1,$2,$3,$4,$5, COALESCE($6, TRUE))
		RETURNING `+programCols,
		req.Title, req.Slug, req.Description, req.AgeFrom, req.AgeTo, req.IsActive))
	return p, classify(err)
}

func (r *Repository) UpdateProgram(ctx context.Context, id int64, fields map[string]any) (ProgramRow, error) {
	if len(fields) == 0 {
		return r.GetProgram(ctx, id)
	}
	p, err := scanProgram(r.updateRow(ctx, "programs", id, fields, programCols))
	return p, classify(err)
}

func (r *Repository) DeleteProgram(ctx context.Context, id int64) error {
	return r.deleteByID(ctx, "programs", id)
}

/* ===================================================================
   levels
   =================================================================== */

const levelCols = `id, program_id, title, description, age_from, age_to, position, created_at, updated_at`

func scanLevel(row rowScanner) (LevelRow, error) {
	var l LevelRow
	err := row.Scan(&l.ID, &l.ProgramID, &l.Title, &l.Description, &l.AgeFrom, &l.AgeTo, &l.Position, &l.CreatedAt, &l.UpdatedAt)
	return l, err
}

func (r *Repository) ListLevels(ctx context.Context, programID *int64) ([]LevelRow, error) {
	q := `SELECT ` + levelCols + ` FROM levels`
	args := []any{}
	if programID != nil {
		args = append(args, *programID)
		q += ` WHERE program_id = $1`
	}
	q += ` ORDER BY program_id, position, id`
	rows, err := r.pool.Query(ctx, q, args...)
	if err != nil {
		return nil, fmt.Errorf("list levels: %w", err)
	}
	defer rows.Close()
	out := []LevelRow{}
	for rows.Next() {
		l, err := scanLevel(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, l)
	}
	return out, rows.Err()
}

func (r *Repository) GetLevel(ctx context.Context, id int64) (LevelRow, error) {
	l, err := scanLevel(r.pool.QueryRow(ctx, `SELECT `+levelCols+` FROM levels WHERE id = $1`, id))
	return l, classify(err)
}

func (r *Repository) CreateLevel(ctx context.Context, req CreateLevelRequest) (LevelRow, error) {
	l, err := scanLevel(r.pool.QueryRow(ctx, `
		INSERT INTO levels (program_id, title, description, age_from, age_to, position)
		VALUES ($1,$2,$3,$4,$5, COALESCE($6, 0))
		RETURNING `+levelCols,
		req.ProgramID, req.Title, req.Description, req.AgeFrom, req.AgeTo, req.Position))
	return l, classify(err)
}

func (r *Repository) UpdateLevel(ctx context.Context, id int64, fields map[string]any) (LevelRow, error) {
	if len(fields) == 0 {
		return r.GetLevel(ctx, id)
	}
	l, err := scanLevel(r.updateRow(ctx, "levels", id, fields, levelCols))
	return l, classify(err)
}

func (r *Repository) DeleteLevel(ctx context.Context, id int64) error {
	return r.deleteByID(ctx, "levels", id)
}

/* ===================================================================
   courses
   =================================================================== */

const courseCols = `id, level_id, title, slug, description, short_description, image_url,
	age_from, age_to, duration_lessons, projects_count, difficulty, is_published, position,
	created_at, updated_at`

func scanCourse(row rowScanner) (CourseRow, error) {
	var c CourseRow
	err := row.Scan(&c.ID, &c.LevelID, &c.Title, &c.Slug, &c.Description, &c.ShortDescription, &c.ImageURL,
		&c.AgeFrom, &c.AgeTo, &c.DurationLessons, &c.ProjectsCount, &c.Difficulty, &c.IsPublished, &c.Position,
		&c.CreatedAt, &c.UpdatedAt)
	return c, err
}

func (r *Repository) ListCourses(ctx context.Context, levelID *int64, published *bool) ([]CourseRow, error) {
	conds := []string{"1=1"}
	args := []any{}
	if levelID != nil {
		args = append(args, *levelID)
		conds = append(conds, fmt.Sprintf("level_id = $%d", len(args)))
	}
	if published != nil {
		args = append(args, *published)
		conds = append(conds, fmt.Sprintf("is_published = $%d", len(args)))
	}
	rows, err := r.pool.Query(ctx, fmt.Sprintf(
		`SELECT %s FROM courses WHERE %s ORDER BY level_id, position, id`, courseCols, strings.Join(conds, " AND ")), args...)
	if err != nil {
		return nil, fmt.Errorf("list courses: %w", err)
	}
	defer rows.Close()
	out := []CourseRow{}
	for rows.Next() {
		c, err := scanCourse(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, c)
	}
	return out, rows.Err()
}

func (r *Repository) GetCourse(ctx context.Context, id int64) (CourseRow, error) {
	c, err := scanCourse(r.pool.QueryRow(ctx, `SELECT `+courseCols+` FROM courses WHERE id = $1`, id))
	return c, classify(err)
}

func (r *Repository) CreateCourse(ctx context.Context, req CreateCourseRequest) (CourseRow, error) {
	c, err := scanCourse(r.pool.QueryRow(ctx, `
		INSERT INTO courses (level_id, title, slug, description, short_description, image_url,
			age_from, age_to, duration_lessons, projects_count, difficulty, is_published, position)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11, COALESCE($12, FALSE), COALESCE($13, 0))
		RETURNING `+courseCols,
		req.LevelID, req.Title, req.Slug, req.Description, req.ShortDescription, req.ImageURL,
		req.AgeFrom, req.AgeTo, req.DurationLessons, req.ProjectsCount, req.Difficulty, req.IsPublished, req.Position))
	return c, classify(err)
}

func (r *Repository) UpdateCourse(ctx context.Context, id int64, fields map[string]any) (CourseRow, error) {
	if len(fields) == 0 {
		return r.GetCourse(ctx, id)
	}
	c, err := scanCourse(r.updateRow(ctx, "courses", id, fields, courseCols))
	return c, classify(err)
}

func (r *Repository) DeleteCourse(ctx context.Context, id int64) error {
	return r.deleteByID(ctx, "courses", id)
}

/* ===================================================================
   modules
   =================================================================== */

const moduleCols = `id, course_id, title, description, position, created_at, updated_at`

func scanModule(row rowScanner) (ModuleRow, error) {
	var m ModuleRow
	err := row.Scan(&m.ID, &m.CourseID, &m.Title, &m.Description, &m.Position, &m.CreatedAt, &m.UpdatedAt)
	return m, err
}

func (r *Repository) ListModules(ctx context.Context, courseID *int64) ([]ModuleRow, error) {
	q := `SELECT ` + moduleCols + ` FROM modules`
	args := []any{}
	if courseID != nil {
		args = append(args, *courseID)
		q += ` WHERE course_id = $1`
	}
	q += ` ORDER BY course_id, position, id`
	rows, err := r.pool.Query(ctx, q, args...)
	if err != nil {
		return nil, fmt.Errorf("list modules: %w", err)
	}
	defer rows.Close()
	out := []ModuleRow{}
	for rows.Next() {
		m, err := scanModule(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, m)
	}
	return out, rows.Err()
}

func (r *Repository) GetModule(ctx context.Context, id int64) (ModuleRow, error) {
	m, err := scanModule(r.pool.QueryRow(ctx, `SELECT `+moduleCols+` FROM modules WHERE id = $1`, id))
	return m, classify(err)
}

func (r *Repository) CreateModule(ctx context.Context, req CreateModuleRequest) (ModuleRow, error) {
	m, err := scanModule(r.pool.QueryRow(ctx, `
		INSERT INTO modules (course_id, title, description, position)
		VALUES ($1,$2,$3, COALESCE($4,0))
		RETURNING `+moduleCols, req.CourseID, req.Title, req.Description, req.Position))
	return m, classify(err)
}

func (r *Repository) UpdateModule(ctx context.Context, id int64, fields map[string]any) (ModuleRow, error) {
	if len(fields) == 0 {
		return r.GetModule(ctx, id)
	}
	m, err := scanModule(r.updateRow(ctx, "modules", id, fields, moduleCols))
	return m, classify(err)
}

func (r *Repository) DeleteModule(ctx context.Context, id int64) error {
	return r.deleteByID(ctx, "modules", id)
}

/* ===================================================================
   lessons
   =================================================================== */

const lessonCols = `id, module_id, title, slug, description, content, video_url,
	lesson_type, position, is_published, created_at, updated_at`

func scanLesson(row rowScanner) (LessonRow, error) {
	var l LessonRow
	err := row.Scan(&l.ID, &l.ModuleID, &l.Title, &l.Slug, &l.Description, &l.Content, &l.VideoURL,
		&l.LessonType, &l.Position, &l.IsPublished, &l.CreatedAt, &l.UpdatedAt)
	return l, err
}

func (r *Repository) ListLessons(ctx context.Context, moduleID *int64) ([]LessonRow, error) {
	q := `SELECT ` + lessonCols + ` FROM lessons`
	args := []any{}
	if moduleID != nil {
		args = append(args, *moduleID)
		q += ` WHERE module_id = $1`
	}
	q += ` ORDER BY module_id, position, id`
	rows, err := r.pool.Query(ctx, q, args...)
	if err != nil {
		return nil, fmt.Errorf("list lessons: %w", err)
	}
	defer rows.Close()
	out := []LessonRow{}
	for rows.Next() {
		l, err := scanLesson(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, l)
	}
	return out, rows.Err()
}

func (r *Repository) GetLesson(ctx context.Context, id int64) (LessonRow, error) {
	l, err := scanLesson(r.pool.QueryRow(ctx, `SELECT `+lessonCols+` FROM lessons WHERE id = $1`, id))
	return l, classify(err)
}

func (r *Repository) CreateLesson(ctx context.Context, req CreateLessonRequest) (LessonRow, error) {
	l, err := scanLesson(r.pool.QueryRow(ctx, `
		INSERT INTO lessons (module_id, title, slug, description, content, video_url, lesson_type, position, is_published)
		VALUES ($1,$2,$3,$4,$5,$6, COALESCE($7,'text'), COALESCE($8,0), COALESCE($9, FALSE))
		RETURNING `+lessonCols,
		req.ModuleID, req.Title, req.Slug, req.Description, req.Content, req.VideoURL, req.LessonType, req.Position, req.IsPublished))
	return l, classify(err)
}

func (r *Repository) UpdateLesson(ctx context.Context, id int64, fields map[string]any) (LessonRow, error) {
	if len(fields) == 0 {
		return r.GetLesson(ctx, id)
	}
	l, err := scanLesson(r.updateRow(ctx, "lessons", id, fields, lessonCols))
	return l, classify(err)
}

func (r *Repository) DeleteLesson(ctx context.Context, id int64) error {
	return r.deleteByID(ctx, "lessons", id)
}

/* ===================================================================
   assignments
   =================================================================== */

const assignmentCols = `id, lesson_id, title, description, assignment_type, starter_code,
	expected_output, points, position, is_published, created_at, updated_at`

func scanAssignment(row rowScanner) (AssignmentRow, error) {
	var a AssignmentRow
	err := row.Scan(&a.ID, &a.LessonID, &a.Title, &a.Description, &a.AssignmentType, &a.StarterCode,
		&a.ExpectedOutput, &a.Points, &a.Position, &a.IsPublished, &a.CreatedAt, &a.UpdatedAt)
	return a, err
}

func (r *Repository) ListAssignments(ctx context.Context, lessonID *int64) ([]AssignmentRow, error) {
	q := `SELECT ` + assignmentCols + ` FROM assignments`
	args := []any{}
	if lessonID != nil {
		args = append(args, *lessonID)
		q += ` WHERE lesson_id = $1`
	}
	q += ` ORDER BY lesson_id, position, id`
	rows, err := r.pool.Query(ctx, q, args...)
	if err != nil {
		return nil, fmt.Errorf("list assignments: %w", err)
	}
	defer rows.Close()
	out := []AssignmentRow{}
	for rows.Next() {
		a, err := scanAssignment(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, a)
	}
	return out, rows.Err()
}

func (r *Repository) GetAssignment(ctx context.Context, id int64) (AssignmentRow, error) {
	a, err := scanAssignment(r.pool.QueryRow(ctx, `SELECT `+assignmentCols+` FROM assignments WHERE id = $1`, id))
	return a, classify(err)
}

func (r *Repository) CreateAssignment(ctx context.Context, req CreateAssignmentRequest) (AssignmentRow, error) {
	a, err := scanAssignment(r.pool.QueryRow(ctx, `
		INSERT INTO assignments (lesson_id, title, description, assignment_type, starter_code, expected_output, points, position, is_published)
		VALUES ($1,$2,$3,$4,$5,$6, COALESCE($7,0), COALESCE($8,0), COALESCE($9, TRUE))
		RETURNING `+assignmentCols,
		req.LessonID, req.Title, req.Description, req.AssignmentType, req.StarterCode, req.ExpectedOutput, req.Points, req.Position, req.IsPublished))
	return a, classify(err)
}

func (r *Repository) UpdateAssignment(ctx context.Context, id int64, fields map[string]any) (AssignmentRow, error) {
	if len(fields) == 0 {
		return r.GetAssignment(ctx, id)
	}
	a, err := scanAssignment(r.updateRow(ctx, "assignments", id, fields, assignmentCols))
	return a, classify(err)
}

func (r *Repository) DeleteAssignment(ctx context.Context, id int64) error {
	return r.deleteByID(ctx, "assignments", id)
}

/* ===================================================================
   groups (+ membership)
   =================================================================== */

const groupSelect = `
	g.id, g.course_id, c.title, g.teacher_id,
	trim(t.first_name || ' ' || coalesce(t.last_name,'')),
	g.title, g.description, g.start_date, g.end_date, g.max_students, g.status,
	(SELECT count(*) FROM group_students gs WHERE gs.group_id = g.id),
	g.created_at, g.updated_at
	FROM groups g
	JOIN courses c ON c.id = g.course_id
	JOIN users t ON t.id = g.teacher_id`

func scanGroup(row rowScanner) (GroupRow, error) {
	var g GroupRow
	err := row.Scan(&g.ID, &g.CourseID, &g.CourseTitle, &g.TeacherID, &g.TeacherName,
		&g.Title, &g.Description, &g.StartDate, &g.EndDate, &g.MaxStudents, &g.Status,
		&g.StudentCount, &g.CreatedAt, &g.UpdatedAt)
	return g, err
}

func (r *Repository) ListGroups(ctx context.Context, teacherID, courseID *int64, status string) ([]GroupRow, error) {
	conds := []string{"1=1"}
	args := []any{}
	if teacherID != nil {
		args = append(args, *teacherID)
		conds = append(conds, fmt.Sprintf("g.teacher_id = $%d", len(args)))
	}
	if courseID != nil {
		args = append(args, *courseID)
		conds = append(conds, fmt.Sprintf("g.course_id = $%d", len(args)))
	}
	if status != "" {
		args = append(args, status)
		conds = append(conds, fmt.Sprintf("g.status = $%d", len(args)))
	}
	rows, err := r.pool.Query(ctx,
		`SELECT `+groupSelect+` WHERE `+strings.Join(conds, " AND ")+` ORDER BY g.created_at DESC, g.id DESC`, args...)
	if err != nil {
		return nil, fmt.Errorf("list groups: %w", err)
	}
	defer rows.Close()
	out := []GroupRow{}
	for rows.Next() {
		g, err := scanGroup(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, g)
	}
	return out, rows.Err()
}

func (r *Repository) GetGroup(ctx context.Context, id int64) (GroupRow, error) {
	g, err := scanGroup(r.pool.QueryRow(ctx, `SELECT `+groupSelect+` WHERE g.id = $1`, id))
	return g, classify(err)
}

func (r *Repository) CreateGroup(ctx context.Context, req CreateGroupRequest) (int64, error) {
	var id int64
	err := r.pool.QueryRow(ctx, `
		INSERT INTO groups (course_id, teacher_id, title, description, start_date, end_date, max_students, status)
		VALUES ($1,$2,$3,$4,$5,$6,$7, COALESCE($8,'draft'))
		RETURNING id`,
		req.CourseID, req.TeacherID, req.Title, req.Description, req.StartDate, req.EndDate, req.MaxStudents, req.Status).Scan(&id)
	return id, classify(err)
}

func (r *Repository) UpdateGroup(ctx context.Context, id int64, fields map[string]any) error {
	if len(fields) == 0 {
		return nil
	}
	var got int64
	err := r.updateRow(ctx, "groups", id, fields, "id").Scan(&got)
	return classify(err)
}

func (r *Repository) DeleteGroup(ctx context.Context, id int64) error {
	return r.deleteByID(ctx, "groups", id)
}

func (r *Repository) ListGroupStudents(ctx context.Context, groupID int64) ([]GroupStudentRow, error) {
	rows, err := r.pool.Query(ctx, `
		SELECT u.id, u.first_name, u.last_name, u.email, gs.joined_at
		FROM group_students gs
		JOIN users u ON u.id = gs.student_id
		WHERE gs.group_id = $1
		ORDER BY u.first_name, u.id`, groupID)
	if err != nil {
		return nil, fmt.Errorf("list group students: %w", err)
	}
	defer rows.Close()
	out := []GroupStudentRow{}
	for rows.Next() {
		var s GroupStudentRow
		if err := rows.Scan(&s.StudentID, &s.FirstName, &s.LastName, &s.Email, &s.JoinedAt); err != nil {
			return nil, err
		}
		out = append(out, s)
	}
	return out, rows.Err()
}

func (r *Repository) RemoveGroupStudent(ctx context.Context, groupID, studentID int64) error {
	tag, err := r.pool.Exec(ctx,
		`DELETE FROM group_students WHERE group_id = $1 AND student_id = $2`, groupID, studentID)
	if err != nil {
		return classify(err)
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

func (r *Repository) GroupExists(ctx context.Context, id int64) (bool, error) {
	var ok bool
	err := r.pool.QueryRow(ctx, `SELECT EXISTS (SELECT 1 FROM groups WHERE id = $1)`, id).Scan(&ok)
	return ok, err
}

/* ===================================================================
   audit log
   =================================================================== */

func (r *Repository) WriteAudit(ctx context.Context, adminID int64, action, entity string, entityID *int64, summary string) error {
	_, err := r.pool.Exec(ctx, `
		INSERT INTO admin_audit_log (admin_id, action, entity, entity_id, summary)
		VALUES ($1,$2,$3,$4,$5)`, adminID, action, entity, entityID, summary)
	return err
}

func (r *Repository) ListAudit(ctx context.Context, page, limit int) ([]AuditRow, int, error) {
	var total int
	if err := r.pool.QueryRow(ctx, `SELECT count(*) FROM admin_audit_log`).Scan(&total); err != nil {
		return nil, 0, err
	}
	rows, err := r.pool.Query(ctx, `
		SELECT a.id, a.admin_id, trim(u.first_name || ' ' || coalesce(u.last_name,'')),
		       a.action, a.entity, a.entity_id, a.summary, a.created_at
		FROM admin_audit_log a
		JOIN users u ON u.id = a.admin_id
		ORDER BY a.created_at DESC, a.id DESC
		LIMIT $1 OFFSET $2`, limit, (page-1)*limit)
	if err != nil {
		return nil, 0, fmt.Errorf("list audit: %w", err)
	}
	defer rows.Close()
	out := []AuditRow{}
	for rows.Next() {
		var it AuditRow
		if err := rows.Scan(&it.ID, &it.AdminID, &it.AdminName, &it.Action, &it.Entity, &it.EntityID, &it.Summary, &it.CreatedAt); err != nil {
			return nil, 0, err
		}
		out = append(out, it)
	}
	return out, total, rows.Err()
}

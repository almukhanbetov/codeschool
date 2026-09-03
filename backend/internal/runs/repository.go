package runs

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

func classify(err error) error {
	if err == nil {
		return nil
	}
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrTestNotFound
	}
	var pgErr *pgconn.PgError
	if errors.As(err, &pgErr) {
		switch pgErr.Code {
		case "23503":
			return invalid("referenced record does not exist")
		case "23514":
			return invalid("a value is out of its allowed range")
		}
	}
	return err
}

/* ================= code_runs ================= */

// InsertRun persists one execution and returns its id + timestamp.
func (r *Repository) InsertRun(ctx context.Context, run Run) (Run, error) {
	err := r.pool.QueryRow(ctx, `
		INSERT INTO code_runs
			(assignment_id, student_id, language, source_code, stdin, stdout, stderr, exit_code, status, duration_ms, truncated, kind)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)
		RETURNING id, created_at
	`, run.AssignmentID, run.StudentID, run.Language, run.SourceCode, run.Stdin,
		run.Stdout, run.Stderr, run.ExitCode, run.Status, run.DurationMS, run.Truncated, run.Kind).
		Scan(&run.ID, &run.CreatedAt)
	if err != nil {
		return Run{}, fmt.Errorf("insert code run: %w", err)
	}
	return run, nil
}

// ListRuns returns a student's recent runs for an assignment, newest first.
func (r *Repository) ListRuns(ctx context.Context, studentID, assignmentID int64, limit int) ([]Run, error) {
	rows, err := r.pool.Query(ctx, `
		SELECT id, assignment_id, student_id, language, stdin, stdout, stderr,
		       exit_code, status, duration_ms, truncated, kind, created_at
		FROM code_runs
		WHERE student_id = $1 AND assignment_id = $2
		ORDER BY created_at DESC, id DESC
		LIMIT $3
	`, studentID, assignmentID, limit)
	if err != nil {
		return nil, fmt.Errorf("list code runs: %w", err)
	}
	defer rows.Close()
	out := []Run{}
	for rows.Next() {
		var it Run
		if err := rows.Scan(&it.ID, &it.AssignmentID, &it.StudentID, &it.Language, &it.Stdin, &it.Stdout, &it.Stderr,
			&it.ExitCode, &it.Status, &it.DurationMS, &it.Truncated, &it.Kind, &it.CreatedAt); err != nil {
			return nil, fmt.Errorf("scan code run: %w", err)
		}
		out = append(out, it)
	}
	return out, rows.Err()
}

/* ================= assignment_tests ================= */

const testCols = `id, assignment_id, name, stdin, expected_stdout, is_hidden, weight, position, created_at, updated_at`

func scanAdminTest(row interface{ Scan(...any) error }) (AdminTest, error) {
	var t AdminTest
	err := row.Scan(&t.ID, &t.AssignmentID, &t.Name, &t.Stdin, &t.ExpectedStdout, &t.IsHidden, &t.Weight, &t.Position, &t.CreatedAt, &t.UpdatedAt)
	return t, err
}

// TestsForAssignment returns every test case for an assignment, ordered.
func (r *Repository) TestsForAssignment(ctx context.Context, assignmentID int64) ([]TestCase, error) {
	rows, err := r.pool.Query(ctx, `
		SELECT id, assignment_id, name, stdin, expected_stdout, is_hidden, weight, position
		FROM assignment_tests WHERE assignment_id = $1
		ORDER BY position ASC, id ASC
	`, assignmentID)
	if err != nil {
		return nil, fmt.Errorf("assignment tests: %w", err)
	}
	defer rows.Close()
	out := []TestCase{}
	for rows.Next() {
		var t TestCase
		if err := rows.Scan(&t.ID, &t.AssignmentID, &t.Name, &t.Stdin, &t.ExpectedStdout, &t.IsHidden, &t.Weight, &t.Position); err != nil {
			return nil, fmt.Errorf("scan test: %w", err)
		}
		out = append(out, t)
	}
	return out, rows.Err()
}

// AdminTestsForAssignment is the full-detail admin listing.
func (r *Repository) AdminTestsForAssignment(ctx context.Context, assignmentID int64) ([]AdminTest, error) {
	rows, err := r.pool.Query(ctx, `SELECT `+testCols+` FROM assignment_tests WHERE assignment_id = $1 ORDER BY position, id`, assignmentID)
	if err != nil {
		return nil, fmt.Errorf("admin tests: %w", err)
	}
	defer rows.Close()
	out := []AdminTest{}
	for rows.Next() {
		t, err := scanAdminTest(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, t)
	}
	return out, rows.Err()
}

func (r *Repository) GetTest(ctx context.Context, id int64) (AdminTest, error) {
	t, err := scanAdminTest(r.pool.QueryRow(ctx, `SELECT `+testCols+` FROM assignment_tests WHERE id = $1`, id))
	if errors.Is(err, pgx.ErrNoRows) {
		return AdminTest{}, ErrTestNotFound
	}
	return t, err
}

func (r *Repository) CreateTest(ctx context.Context, assignmentID int64, name, stdin, expected string, hidden bool, weight, position int) (AdminTest, error) {
	t, err := scanAdminTest(r.pool.QueryRow(ctx, `
		INSERT INTO assignment_tests (assignment_id, name, stdin, expected_stdout, is_hidden, weight, position)
		VALUES ($1,$2,$3,$4,$5,$6,$7)
		RETURNING `+testCols, assignmentID, name, stdin, expected, hidden, weight, position))
	return t, classify(err)
}

func (r *Repository) UpdateTest(ctx context.Context, id int64, fields map[string]any) (AdminTest, error) {
	if len(fields) == 0 {
		return r.GetTest(ctx, id)
	}
	set := make([]string, 0, len(fields)+1)
	args := make([]any, 0, len(fields)+1)
	for col, val := range fields {
		args = append(args, val)
		set = append(set, fmt.Sprintf("%s = $%d", col, len(args)))
	}
	set = append(set, "updated_at = NOW()")
	args = append(args, id)
	t, err := scanAdminTest(r.pool.QueryRow(ctx, fmt.Sprintf(
		"UPDATE assignment_tests SET %s WHERE id = $%d RETURNING %s", strings.Join(set, ", "), len(args), testCols), args...))
	if errors.Is(err, pgx.ErrNoRows) {
		return AdminTest{}, ErrTestNotFound
	}
	return t, classify(err)
}

func (r *Repository) DeleteTest(ctx context.Context, id int64) error {
	tag, err := r.pool.Exec(ctx, `DELETE FROM assignment_tests WHERE id = $1`, id)
	if err != nil {
		return classify(err)
	}
	if tag.RowsAffected() == 0 {
		return ErrTestNotFound
	}
	return nil
}

// AssignmentIDsWithTests returns which of the given assignment ids have at
// least one test case (used by the progress gate / the frontend).
func (r *Repository) AssignmentIDsWithTests(ctx context.Context, assignmentIDs []int64) ([]int64, error) {
	if len(assignmentIDs) == 0 {
		return nil, nil
	}
	rows, err := r.pool.Query(ctx,
		`SELECT DISTINCT assignment_id FROM assignment_tests WHERE assignment_id = ANY($1)`, assignmentIDs)
	if err != nil {
		return nil, fmt.Errorf("assignments with tests: %w", err)
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

/* ================= audit (reuses admin_audit_log) ================= */

func (r *Repository) WriteAudit(ctx context.Context, adminID int64, action, entity string, entityID *int64, summary string) error {
	_, err := r.pool.Exec(ctx, `
		INSERT INTO admin_audit_log (admin_id, action, entity, entity_id, summary)
		VALUES ($1,$2,$3,$4,$5)`, adminID, action, entity, entityID, summary)
	return err
}

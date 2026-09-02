package courses

import (
	"context"
	"os"
	"testing"

	"github.com/jackc/pgx/v5/pgxpool"
)

// TestRepository_List_OnlyReturnsPublishedCourses is a real-Postgres
// integration test. It is skipped unless TEST_DATABASE_URL is set, so
// `go test ./...` still passes with no database available — see
// backend/README.md for how to run it locally.
func TestRepository_List_OnlyReturnsPublishedCourses(t *testing.T) {
	dsn := os.Getenv("TEST_DATABASE_URL")
	if dsn == "" {
		t.Skip("TEST_DATABASE_URL not set; skipping repository integration test")
	}

	ctx := context.Background()
	pool, err := pgxpool.New(ctx, dsn)
	if err != nil {
		t.Fatalf("connect to test database: %v", err)
	}
	defer pool.Close()

	// Isolated fixtures: a published and an unpublished course under the
	// same throwaway program/level, cleaned up regardless of outcome.
	var programID, levelID, publishedID, unpublishedID int64

	err = pool.QueryRow(ctx, `
		INSERT INTO programs (title, slug, is_active) VALUES ('Test Program', 'test-program-repo-it', TRUE)
		RETURNING id
	`).Scan(&programID)
	if err != nil {
		t.Fatalf("insert test program: %v", err)
	}
	defer pool.Exec(ctx, `DELETE FROM programs WHERE id = $1`, programID)

	err = pool.QueryRow(ctx, `
		INSERT INTO levels (program_id, title) VALUES ($1, 'Test Level') RETURNING id
	`, programID).Scan(&levelID)
	if err != nil {
		t.Fatalf("insert test level: %v", err)
	}

	err = pool.QueryRow(ctx, `
		INSERT INTO courses (level_id, title, slug, is_published)
		VALUES ($1, 'Published Course', 'test-published-course-it', TRUE)
		RETURNING id
	`, levelID).Scan(&publishedID)
	if err != nil {
		t.Fatalf("insert published course: %v", err)
	}

	err = pool.QueryRow(ctx, `
		INSERT INTO courses (level_id, title, slug, is_published)
		VALUES ($1, 'Draft Course', 'test-draft-course-it', FALSE)
		RETURNING id
	`, levelID).Scan(&unpublishedID)
	if err != nil {
		t.Fatalf("insert draft course: %v", err)
	}

	repo := NewRepository(pool)
	got, err := repo.List(ctx, ListFilter{LevelID: &levelID})
	if err != nil {
		t.Fatalf("List returned an error: %v", err)
	}

	foundPublished := false
	for _, c := range got {
		if c.ID == unpublishedID {
			t.Errorf("unpublished course %d ('Draft Course') must not be returned by List", unpublishedID)
		}
		if c.ID == publishedID {
			foundPublished = true
		}
	}
	if !foundPublished {
		t.Errorf("expected published course %d to be returned by List", publishedID)
	}

	// GetByID must also refuse to return an unpublished course.
	if _, err := repo.GetByID(ctx, unpublishedID); err != ErrNotFound {
		t.Errorf("GetByID on an unpublished course: expected ErrNotFound, got %v", err)
	}
}

-- +goose Up
-- The teacher's default screen is the pending-review queue:
--   ... WHERE s.status = 'submitted' ORDER BY s.submitted_at ASC
-- This composite index serves both the filter and the sort directly.
CREATE INDEX idx_submissions_status_submitted_at ON submissions (status, submitted_at);

-- +goose Down
DROP INDEX idx_submissions_status_submitted_at;

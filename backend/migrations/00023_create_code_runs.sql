-- +goose Up
-- One row per code execution a student triggers (a free "Run", or one test
-- case during auto-grading). This is the code attempts / history (spec §5).
CREATE TABLE code_runs (
    id BIGSERIAL PRIMARY KEY,
    assignment_id BIGINT NOT NULL REFERENCES assignments(id) ON DELETE CASCADE,
    student_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    language VARCHAR(20) NOT NULL,
    source_code TEXT NOT NULL,
    stdin TEXT NOT NULL DEFAULT '',
    stdout TEXT NOT NULL DEFAULT '',
    stderr TEXT NOT NULL DEFAULT '',
    exit_code INTEGER,
    status VARCHAR(20) NOT NULL,       -- ok | error | timeout | runner_error
    duration_ms INTEGER,
    truncated BOOLEAN NOT NULL DEFAULT FALSE,
    kind VARCHAR(10) NOT NULL DEFAULT 'run',   -- run | grade
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT code_runs_status_allowed CHECK (status IN ('ok', 'error', 'timeout', 'runner_error')),
    CONSTRAINT code_runs_kind_allowed CHECK (kind IN ('run', 'grade'))
);

CREATE INDEX idx_code_runs_student_assignment
    ON code_runs (student_id, assignment_id, created_at DESC, id DESC);

-- +goose Down
DROP TABLE code_runs;

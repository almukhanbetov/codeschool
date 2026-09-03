-- +goose Up
-- Admin-authored I/O test cases for a `code` assignment. `is_hidden` cases
-- are never revealed to the student — only used for grading (spec §6, §7).
CREATE TABLE assignment_tests (
    id BIGSERIAL PRIMARY KEY,
    assignment_id BIGINT NOT NULL REFERENCES assignments(id) ON DELETE CASCADE,
    name VARCHAR(120) NOT NULL,
    stdin TEXT NOT NULL DEFAULT '',
    expected_stdout TEXT NOT NULL DEFAULT '',
    is_hidden BOOLEAN NOT NULL DEFAULT FALSE,
    weight INTEGER NOT NULL DEFAULT 1,
    position INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT assignment_tests_weight_positive CHECK (weight >= 1)
);

CREATE INDEX idx_assignment_tests_assignment ON assignment_tests (assignment_id, position, id);

-- +goose Down
DROP TABLE assignment_tests;

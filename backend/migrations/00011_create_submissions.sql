-- +goose Up
CREATE TABLE submissions (
    id BIGSERIAL PRIMARY KEY,
    assignment_id BIGINT NOT NULL REFERENCES assignments(id) ON DELETE CASCADE,
    student_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    code TEXT,
    answer TEXT,
    status VARCHAR(30) NOT NULL DEFAULT 'draft',
    score INTEGER,
    teacher_feedback TEXT,
    submitted_at TIMESTAMPTZ,
    checked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT submissions_status_allowed
        CHECK (status IN ('draft', 'submitted', 'checking', 'passed', 'failed')),
    CONSTRAINT submissions_score_range
        CHECK (score IS NULL OR (score >= 0 AND score <= 100)),
    -- One current submission per (student, assignment); attempt history, if
    -- ever needed, goes in a separate table.
    CONSTRAINT submissions_student_assignment_unique UNIQUE (student_id, assignment_id)
);

CREATE INDEX idx_submissions_assignment_id ON submissions (assignment_id);
CREATE INDEX idx_submissions_student_id ON submissions (student_id);

-- +goose Down
DROP TABLE submissions;

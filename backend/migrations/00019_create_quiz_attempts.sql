-- +goose Up
-- Quiz attempts are deliberately NOT modelled on the submissions uniqueness
-- rule (spec §13): a student keeps a full history of attempts per assignment.
CREATE TABLE quiz_attempts (
    id BIGSERIAL PRIMARY KEY,
    assignment_id BIGINT NOT NULL REFERENCES assignments(id) ON DELETE CASCADE,
    student_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(30) NOT NULL DEFAULT 'in_progress',
    score INTEGER,
    max_score INTEGER,
    percent INTEGER,
    passed BOOLEAN,
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    submitted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT quiz_attempts_status_allowed
        CHECK (status IN ('in_progress', 'submitted')),
    CONSTRAINT quiz_attempts_percent_range
        CHECK (percent IS NULL OR (percent >= 0 AND percent <= 100))
);

CREATE INDEX idx_quiz_attempts_student_id ON quiz_attempts (student_id);
CREATE INDEX idx_quiz_attempts_assignment_id ON quiz_attempts (assignment_id);
CREATE INDEX idx_quiz_attempts_student_assignment ON quiz_attempts (student_id, assignment_id);

-- +goose Down
DROP TABLE quiz_attempts;

-- +goose Up
CREATE TABLE quiz_questions (
    id BIGSERIAL PRIMARY KEY,
    assignment_id BIGINT NOT NULL REFERENCES assignments(id) ON DELETE CASCADE,
    question_text TEXT NOT NULL,
    question_type VARCHAR(30) NOT NULL,
    points INTEGER NOT NULL DEFAULT 1,
    position INTEGER NOT NULL DEFAULT 0,
    explanation TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT quiz_questions_type_allowed
        CHECK (question_type IN ('single_choice', 'multiple_choice', 'true_false')),
    CONSTRAINT quiz_questions_points_positive CHECK (points >= 1)
);

CREATE INDEX idx_quiz_questions_assignment_id ON quiz_questions (assignment_id);
CREATE INDEX idx_quiz_questions_assignment_position ON quiz_questions (assignment_id, position);

-- +goose Down
DROP TABLE quiz_questions;

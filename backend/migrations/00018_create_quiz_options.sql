-- +goose Up
CREATE TABLE quiz_options (
    id BIGSERIAL PRIMARY KEY,
    question_id BIGINT NOT NULL REFERENCES quiz_questions(id) ON DELETE CASCADE,
    option_text TEXT NOT NULL,
    is_correct BOOLEAN NOT NULL DEFAULT FALSE,
    position INTEGER NOT NULL DEFAULT 0,
    -- Soft-hide an option that is already referenced by attempt history
    -- instead of hard-deleting it (history immutability, spec §65/§66).
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_quiz_options_question_id ON quiz_options (question_id);
CREATE INDEX idx_quiz_options_question_position ON quiz_options (question_id, position);

-- +goose Down
DROP TABLE quiz_options;

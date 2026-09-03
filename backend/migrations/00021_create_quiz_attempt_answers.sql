-- +goose Up
CREATE TABLE quiz_attempt_answers (
    id BIGSERIAL PRIMARY KEY,
    attempt_id BIGINT NOT NULL REFERENCES quiz_attempts(id) ON DELETE CASCADE,
    question_id BIGINT NOT NULL REFERENCES quiz_questions(id) ON DELETE CASCADE,
    is_correct BOOLEAN,
    points_awarded INTEGER,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT quiz_attempt_answers_unique UNIQUE (attempt_id, question_id)
);

CREATE INDEX idx_quiz_attempt_answers_attempt_id ON quiz_attempt_answers (attempt_id);

-- multiple_choice needs more than one selected option, so the chosen options
-- live in a join table rather than a single column on the answer row.
CREATE TABLE quiz_attempt_answer_options (
    attempt_answer_id BIGINT NOT NULL REFERENCES quiz_attempt_answers(id) ON DELETE CASCADE,
    option_id BIGINT NOT NULL REFERENCES quiz_options(id) ON DELETE CASCADE,
    PRIMARY KEY (attempt_answer_id, option_id)
);

CREATE INDEX idx_quiz_attempt_answer_options_option_id ON quiz_attempt_answer_options (option_id);

-- +goose Down
DROP TABLE quiz_attempt_answer_options;
DROP TABLE quiz_attempt_answers;

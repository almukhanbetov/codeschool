-- +goose Up
-- One settings row per quiz assignment. Shuffle options were intentionally
-- left out of this first Quiz stage (spec §67/§68) — they are future work.
CREATE TABLE quiz_settings (
    assignment_id BIGINT PRIMARY KEY REFERENCES assignments(id) ON DELETE CASCADE,
    pass_percent INTEGER NOT NULL DEFAULT 70,
    max_attempts INTEGER,
    show_correct_answers BOOLEAN NOT NULL DEFAULT TRUE,
    show_explanations BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT quiz_settings_pass_percent_range
        CHECK (pass_percent >= 0 AND pass_percent <= 100),
    CONSTRAINT quiz_settings_max_attempts_positive
        CHECK (max_attempts IS NULL OR max_attempts >= 1)
);

-- +goose Down
DROP TABLE quiz_settings;

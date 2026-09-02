-- +goose Up
CREATE TABLE lesson_progress (
    id BIGSERIAL PRIMARY KEY,
    student_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    lesson_id BIGINT NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    status VARCHAR(30) NOT NULL DEFAULT 'not_started',
    progress_percent INTEGER NOT NULL DEFAULT 0,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT lesson_progress_status_allowed
        CHECK (status IN ('not_started', 'in_progress', 'completed')),
    CONSTRAINT lesson_progress_percent_range
        CHECK (progress_percent >= 0 AND progress_percent <= 100),
    CONSTRAINT lesson_progress_student_lesson_unique UNIQUE (student_id, lesson_id)
);

CREATE INDEX idx_lesson_progress_student_id ON lesson_progress (student_id);
CREATE INDEX idx_lesson_progress_lesson_id ON lesson_progress (lesson_id);

-- +goose Down
DROP TABLE lesson_progress;

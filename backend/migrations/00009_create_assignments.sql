-- +goose Up
CREATE TABLE assignments (
    id BIGSERIAL PRIMARY KEY,
    lesson_id BIGINT NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    assignment_type VARCHAR(30) NOT NULL,
    starter_code TEXT,
    expected_output TEXT,
    points INTEGER NOT NULL DEFAULT 0,
    position INTEGER NOT NULL DEFAULT 0,
    is_published BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT assignments_type_allowed
        CHECK (assignment_type IN ('text', 'code', 'quiz', 'project')),
    CONSTRAINT assignments_points_non_negative CHECK (points >= 0)
);

CREATE INDEX idx_assignments_lesson_id ON assignments (lesson_id);

-- +goose Down
DROP TABLE assignments;

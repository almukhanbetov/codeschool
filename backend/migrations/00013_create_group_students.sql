-- +goose Up
CREATE TABLE group_students (
    group_id BIGINT NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    student_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Composite PK doubles as the (group_id, student_id) uniqueness rule.
    PRIMARY KEY (group_id, student_id)
);

CREATE INDEX idx_group_students_student_id ON group_students (student_id);
-- (group_id is already the leading column of the primary-key index.)

-- +goose Down
DROP TABLE group_students;

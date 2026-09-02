-- +goose Up
CREATE TABLE enrollments (
    id BIGSERIAL PRIMARY KEY,
    student_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    course_id BIGINT NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    status VARCHAR(30) NOT NULL DEFAULT 'active',
    enrolled_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT enrollments_status_allowed
        CHECK (status IN ('active', 'completed', 'cancelled'))
);

CREATE INDEX idx_enrollments_student_id ON enrollments (student_id);
CREATE INDEX idx_enrollments_course_id ON enrollments (course_id);

-- A student may have at most one *active* enrollment per course (they can
-- re-enrol after cancelling, and keep a historical 'completed' row).
CREATE UNIQUE INDEX idx_enrollments_active_unique
    ON enrollments (student_id, course_id)
    WHERE status = 'active';

-- +goose Down
DROP TABLE enrollments;

-- +goose Up
CREATE TABLE groups (
    id BIGSERIAL PRIMARY KEY,
    course_id BIGINT NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    teacher_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    start_date DATE,
    end_date DATE,
    max_students INTEGER,
    status VARCHAR(30) NOT NULL DEFAULT 'draft',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT groups_status_allowed
        CHECK (status IN ('draft', 'active', 'completed', 'cancelled')),
    CONSTRAINT groups_max_students_positive
        CHECK (max_students IS NULL OR max_students > 0)
);

-- teacher_id must reference a user with role = 'teacher'. Postgres can't
-- express that as a column CHECK, and this stage has no group-creation
-- endpoint (groups come from the dev seed / a future admin action), so it is
-- enforced there and documented — not by a trigger.

CREATE INDEX idx_groups_course_id ON groups (course_id);
CREATE INDEX idx_groups_teacher_id ON groups (teacher_id);
CREATE INDEX idx_groups_status ON groups (status);
CREATE INDEX idx_groups_teacher_status ON groups (teacher_id, status);

-- +goose Down
DROP TABLE groups;

-- +goose Up
-- Distinguishes ordinary student courses from Teacher Academy courses. The
-- whole LMS engine (modules / lessons / assignments / quiz / code runner /
-- enrollments / progress / submissions) is reused as-is; `audience` is the
-- only new bit of metadata. Existing rows stay 'student' via the default.
ALTER TABLE courses
    ADD COLUMN audience VARCHAR(30) NOT NULL DEFAULT 'student';

ALTER TABLE courses
    ADD CONSTRAINT courses_audience_allowed
    CHECK (audience IN ('student', 'teacher', 'both'));

CREATE INDEX idx_courses_audience ON courses (audience);

-- +goose Down
DROP INDEX idx_courses_audience;
ALTER TABLE courses DROP CONSTRAINT courses_audience_allowed;
ALTER TABLE courses DROP COLUMN audience;

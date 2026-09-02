-- +goose Up
CREATE TABLE courses (
    id BIGSERIAL PRIMARY KEY,
    level_id BIGINT NOT NULL REFERENCES levels(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    short_description TEXT,
    image_url TEXT,
    age_from INTEGER,
    age_to INTEGER,
    duration_lessons INTEGER,
    projects_count INTEGER,
    difficulty VARCHAR(50),
    is_published BOOLEAN NOT NULL DEFAULT FALSE,
    position INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_courses_level_id ON courses(level_id);
CREATE INDEX idx_courses_is_published ON courses(is_published);

-- +goose Down
DROP TABLE courses;

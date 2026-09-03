-- +goose Up
-- The code editor (Monaco) needs a language mode per code assignment. NULL is
-- allowed (older rows / non-code assignments); the frontend falls back to a
-- plain editor when it is NULL or 'plaintext'.
ALTER TABLE assignments
    ADD COLUMN language VARCHAR(20);

ALTER TABLE assignments
    ADD CONSTRAINT assignments_language_allowed
    CHECK (language IS NULL OR language IN ('python', 'javascript', 'go', 'plaintext'));

-- +goose Down
ALTER TABLE assignments DROP CONSTRAINT assignments_language_allowed;
ALTER TABLE assignments DROP COLUMN language;

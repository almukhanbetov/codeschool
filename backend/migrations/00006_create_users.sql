-- +goose Up
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255),
    phone VARCHAR(50),
    password_hash TEXT NOT NULL,
    first_name VARCHAR(120) NOT NULL,
    last_name VARCHAR(120),
    role VARCHAR(30) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- A user must be reachable by at least one identifier. Empty strings are
    -- not a stand-in for NULL — the app always stores NULL for "not given".
    CONSTRAINT users_email_or_phone_present CHECK (email IS NOT NULL OR phone IS NOT NULL),
    CONSTRAINT users_email_not_blank CHECK (email IS NULL OR length(btrim(email)) > 0),
    CONSTRAINT users_phone_not_blank CHECK (phone IS NULL OR length(btrim(phone)) > 0),
    CONSTRAINT users_role_allowed CHECK (role IN ('student', 'teacher', 'parent', 'admin'))
);

-- Partial unique indexes: uniqueness only applies to rows that actually have
-- the identifier, so many users can have a NULL email (or NULL phone).
CREATE UNIQUE INDEX idx_users_email_unique ON users (lower(email)) WHERE email IS NOT NULL;
CREATE UNIQUE INDEX idx_users_phone_unique ON users (phone) WHERE phone IS NOT NULL;

-- +goose Down
DROP TABLE users;

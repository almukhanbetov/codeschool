-- +goose Up

-- One universal certificate record per (learner, completed course). The
-- learner is always an existing users.id regardless of role (student or
-- teacher academy learner) — there is no separate student/teacher table.
CREATE TABLE certificates (
    id                 BIGSERIAL PRIMARY KEY,
    user_id            BIGINT NOT NULL REFERENCES users(id),
    course_id          BIGINT NOT NULL REFERENCES courses(id),
    certificate_number VARCHAR(100) NOT NULL,
    verification_code  VARCHAR(100) NOT NULL,
    -- issuance-time snapshots: a later course rename / profile edit must not
    -- retroactively change what an already-issued certificate says.
    learner_name       TEXT NOT NULL,
    course_title       TEXT NOT NULL,
    issued_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at       TIMESTAMPTZ NOT NULL,
    status             VARCHAR(30) NOT NULL DEFAULT 'active',
    revoked_at         TIMESTAMPTZ,
    revoked_by         BIGINT REFERENCES users(id),
    revoke_reason      TEXT,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT certificates_status_allowed CHECK (status IN ('active', 'revoked'))
);

-- A learner never receives a duplicate certificate for the same course.
CREATE UNIQUE INDEX idx_certificates_user_course      ON certificates (user_id, course_id);
-- Both public identifiers are globally unique.
CREATE UNIQUE INDEX idx_certificates_number           ON certificates (certificate_number);
CREATE UNIQUE INDEX idx_certificates_verification_code ON certificates (verification_code);

CREATE INDEX idx_certificates_course_id ON certificates (course_id);
CREATE INDEX idx_certificates_status    ON certificates (status);

-- +goose Down
DROP TABLE certificates;

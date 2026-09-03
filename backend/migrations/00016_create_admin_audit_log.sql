-- +goose Up
CREATE TABLE admin_audit_log (
    id BIGSERIAL PRIMARY KEY,
    admin_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    action VARCHAR(20) NOT NULL,   -- create | update | delete
    entity VARCHAR(40) NOT NULL,   -- user | parent_link | program | level | course | module | lesson | assignment | group | group_student
    entity_id BIGINT,
    summary TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT admin_audit_action_allowed CHECK (action IN ('create', 'update', 'delete'))
);

CREATE INDEX idx_admin_audit_log_created_at ON admin_audit_log (created_at DESC, id DESC);
CREATE INDEX idx_admin_audit_log_admin_id ON admin_audit_log (admin_id);

-- +goose Down
DROP TABLE admin_audit_log;

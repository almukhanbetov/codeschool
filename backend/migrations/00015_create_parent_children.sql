-- +goose Up
CREATE TABLE parent_children (
    parent_id  BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    child_id   BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    linked_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Composite PK doubles as the (parent, child) uniqueness rule.
    PRIMARY KEY (parent_id, child_id),
    CONSTRAINT parent_children_distinct CHECK (parent_id <> child_id)
);

-- parent_id must reference a 'parent' user and child_id a 'student' — Postgres
-- can't express that as a column CHECK and this stage has no parent-linking
-- endpoint (links come from the dev seed / a future admin action), so it is
-- enforced there and documented, not by a trigger.

CREATE INDEX idx_parent_children_child_id ON parent_children (child_id);
-- (parent_id is the leading column of the primary-key index.)

-- +goose Down
DROP TABLE parent_children;

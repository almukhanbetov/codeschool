-- Development seed users — NOT run automatically, NOT for production.
-- Run manually after migrations:
--   psql "$DATABASE_URL" -f seeds/dev_seed_users.sql
--
-- Development credentials only. Do not use in production.
--
--   admin@codeschool.local     / Password123!   (role: admin)
--   teacher@codeschool.local   / Password123!   (role: teacher)
--   student@codeschool.local   / Password123!   (role: student)
--   student2@codeschool.local  / Password123!   (role: student)
--   parent@codeschool.local    / Password123!   (role: parent)
--
-- The password_hash values below are pre-computed bcrypt hashes of
-- "Password123!" (cost 10). The plain password is never stored here. Public
-- registration cannot create an admin — the admin account only exists via
-- this seed. Safe to re-run: rows upsert by email.

BEGIN;

INSERT INTO users (email, phone, password_hash, first_name, last_name, role, is_active)
VALUES
    ('admin@codeschool.local',   NULL, '$2a$10$HApT9tNcZxp4eZi2Kb80DezkY/lUR1gebPu.U23PkRlrhp1fQP3k.', 'Admin',   'CodeSchool', 'admin',   TRUE),
    ('teacher@codeschool.local', NULL, '$2a$10$LB/pO0VFIRn26d9SYDmuI.pu192UIsFPt3guqbjrSnD1aj8q.3gda', 'Aigerim', 'Teacher',    'teacher', TRUE),
    ('student@codeschool.local',  NULL, '$2a$10$fNc1hIYLN6yYviheQfB7BOvYIkq94yHT/sgEl0zIeY.ncxnURDbku', 'Ayan',   'Student',    'student', TRUE),
    ('student2@codeschool.local', NULL, '$2a$10$fNc1hIYLN6yYviheQfB7BOvYIkq94yHT/sgEl0zIeY.ncxnURDbku', 'Dana',   'Student',    'student', TRUE),
    ('parent@codeschool.local',   NULL, '$2a$10$tePigWpIhxxdaxcpa07OLeYWiBVVGfMFJKiGidptFB.W/jLDatQt6', 'Bekzat', 'Parent',     'parent',  TRUE)
ON CONFLICT (lower(email)) WHERE email IS NOT NULL DO UPDATE SET
    password_hash = EXCLUDED.password_hash,
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    role = EXCLUDED.role,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

COMMIT;

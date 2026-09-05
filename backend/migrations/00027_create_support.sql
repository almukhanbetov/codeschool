-- +goose Up

-- Learning-aware support chat: persistent threads between a student or parent
-- and CODESCHOOL staff (currently role = admin). Threads reference real
-- course / lesson / assignment rows rather than copying learning metrics —
-- the manager's context panel reads current LMS state on demand.

CREATE TABLE support_threads (
    id                BIGSERIAL PRIMARY KEY,
    -- who owns the thread (the person chatting): a student or a parent
    user_id           BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    -- the student the thread is *about* (= user_id for a student thread,
    -- = the linked child for a parent thread)
    student_id        BIGINT REFERENCES users(id) ON DELETE SET NULL,
    course_id         BIGINT REFERENCES courses(id) ON DELETE SET NULL,
    lesson_id         BIGINT REFERENCES lessons(id) ON DELETE SET NULL,
    assignment_id     BIGINT REFERENCES assignments(id) ON DELETE SET NULL,
    subject           VARCHAR(200) NOT NULL,
    category          VARCHAR(30)  NOT NULL DEFAULT 'general',
    status            VARCHAR(20)  NOT NULL DEFAULT 'open',
    priority          VARCHAR(10)  NOT NULL DEFAULT 'normal',
    assigned_admin_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_message_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    closed_at         TIMESTAMPTZ,

    CONSTRAINT support_threads_category_allowed CHECK (category IN (
        'general','course','lesson','assignment','quiz','code_runner',
        'progress','certificate','account','parent_question','technical')),
    CONSTRAINT support_threads_status_allowed CHECK (status IN (
        'open','waiting_staff','waiting_user','closed')),
    CONSTRAINT support_threads_priority_allowed CHECK (priority IN ('normal','high'))
);

CREATE TABLE support_messages (
    id             BIGSERIAL PRIMARY KEY,
    thread_id      BIGINT NOT NULL REFERENCES support_threads(id) ON DELETE CASCADE,
    sender_user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    -- snapshot of the sender's role at send time (never trusted from the client)
    sender_role    VARCHAR(20) NOT NULL,
    body           TEXT NOT NULL,
    message_type   VARCHAR(20) NOT NULL DEFAULT 'text',
    -- internal notes are stripped from every student / parent response, server-side
    is_internal    BOOLEAN NOT NULL DEFAULT FALSE,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    edited_at      TIMESTAMPTZ,
    deleted_at     TIMESTAMPTZ,

    CONSTRAINT support_messages_type_allowed CHECK (message_type IN (
        'text','system','staff_note_visible','internal_note','learning_context')),
    CONSTRAINT support_messages_role_allowed CHECK (sender_role IN (
        'student','parent','teacher','admin'))
);

-- per-participant read state (the owner, plus any staff who opened the thread)
CREATE TABLE support_thread_reads (
    thread_id            BIGINT NOT NULL REFERENCES support_threads(id) ON DELETE CASCADE,
    user_id              BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    last_read_message_id BIGINT NOT NULL DEFAULT 0,
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (thread_id, user_id)
);

CREATE INDEX idx_support_threads_user     ON support_threads (user_id, last_message_at DESC);
CREATE INDEX idx_support_threads_student  ON support_threads (student_id);
CREATE INDEX idx_support_threads_status   ON support_threads (status, last_message_at DESC);
CREATE INDEX idx_support_threads_assigned ON support_threads (assigned_admin_id, last_message_at DESC);
CREATE INDEX idx_support_messages_thread  ON support_messages (thread_id, id);

-- +goose Down
DROP TABLE support_thread_reads;
DROP TABLE support_messages;
DROP TABLE support_threads;

# CODESCHOOL Backend

Go + Gin + pgx/v5 (`pgxpool`) REST API over PostgreSQL 17. No ORM — plain, parameterized SQL. Modular monolith: one API binary, one domain package per resource (`programs`, `levels`, `courses`, `modules`, `lessons`, `users`, `auth`, `enrollments`, `assignments`, `progress`, `submissions`, `groups`, `parents`, `admin`, `quizzes`, `runs`), plus a second small binary `cmd/runner` (the sandboxed code executor, using `internal/sandbox`).

This stage adds the **code runner**. A dedicated, sandboxed `runner` service (`cmd/runner` + `internal/sandbox`, its own image `Dockerfile.runner`) executes student Python / JavaScript / Go in isolation; the backend `internal/runs` package authorizes the student, forwards the code, records every execution (attempt history, `code_runs`), serves the visible sample tests, and runs the hidden tests to **auto-grade** a code submission (`assignment_tests`, migrations `00023`–`00024`). A test-graded `code` assignment is finalized `passed` / `failed` with no teacher, like a quiz. The earlier `assignments.language` (migration `00022`) drives both the frontend Monaco editor and the runner's language mode.

The **quiz engine** (`internal/quizzes`) covers admin authoring of quiz settings / questions / options, student attempts with server-side automatic scoring, attempt history, and read-only teacher / parent views; quiz assignments never touch `submissions`, and a lesson with a quiz can only be completed once the student passes it. The **admin panel API** (`internal/admin`, all routes `role = admin`) covers full CRUD over users, parent-child links, the catalog, and groups, plus a read-only **audit log**. See the root README.

## Architecture

```
HTTP Request → Gin Handler → Service → Repository → PostgreSQL
```

- **Repository**: SQL only, no business logic.
- **Service**: business logic, validation, DTO mapping, turns repo errors into typed `httpx.APIError`s.
- **Handler**: HTTP concerns only (params, status codes, JSON) — never touches SQL.

Each domain follows `model.go`, `dto.go`, `repository.go`, `service.go`, `handler.go`, `routes.go`. A resource nested under another URL (e.g. `GET /courses/:id/modules`) is still owned and routed by the domain that returns it (`modules`, in that example) — the URL prefix is just where it's mounted.

## Requirements

- Go 1.26+ (or let `go build`/`go test` auto-fetch the pinned toolchain)
- PostgreSQL 17
- [goose](https://github.com/pressly/goose) — `go install github.com/pressly/goose/v3/cmd/goose@latest`

## Environment

```bash
cp .env.example .env
```

```
APP_ENV=development
PORT=8080
DATABASE_URL=postgres://codeschool:codeschool@localhost:5432/codeschool?sslmode=disable
CORS_ALLOWED_ORIGINS=http://localhost:3000
JWT_SECRET=change-me
JWT_ACCESS_TTL=15m
JWT_REFRESH_TTL=720h
```

`DATABASE_URL` and `JWT_SECRET` are required — the process fails fast at startup if either is missing (and `DATABASE_URL` must be reachable). `CORS_ALLOWED_ORIGINS` is a comma-separated allowlist (no `*` wildcard); the API sends `Access-Control-Allow-Credentials: true` so the browser can carry the refresh-token cookie. `JWT_ACCESS_TTL` / `JWT_REFRESH_TTL` are Go durations (default 15m / 720h ≈ 30 days).

## Migrations (Goose)

```bash
export DATABASE_URL=postgres://codeschool:codeschool@localhost:5432/codeschool?sslmode=disable

goose -dir migrations postgres "$DATABASE_URL" up      # apply all pending migrations
goose -dir migrations postgres "$DATABASE_URL" status   # show applied/pending
goose -dir migrations postgres "$DATABASE_URL" down     # roll back one migration
```

Schema: `programs → levels → courses → modules → lessons` (each a `BIGINT` FK to its parent, `ON DELETE CASCADE`). Plus `users` (`00006`) and `refresh_tokens` (`00007`, FK → `users`, `ON DELETE CASCADE`).

`users` allows a NULL email **or** a NULL phone but not both (a `CHECK` constraint), and each identifier is unique only where present (partial unique indexes on `lower(email)` / `phone`) — empty strings are never stored in place of NULL.

Student-flow tables (`00008`–`00011`), all FK'd `ON DELETE CASCADE` to `users` / `courses` / `lessons` / `assignments`:

| Table | Key rules |
| --- | --- |
| `enrollments` (`00008`) | `status ∈ (active, completed, cancelled)`; **partial unique index** on `(student_id, course_id) WHERE status = 'active'` — at most one active enrollment per course |
| `assignments` (`00009`, `00022`) | `assignment_type ∈ (text, code, quiz, project)`; `points >= 0`; `is_published`; `language` (`00022`) NULL or `∈ (python, javascript, go, plaintext)` — the Monaco editor mode for a `code` assignment |
| `lesson_progress` (`00010`) | `status ∈ (not_started, in_progress, completed)`; `progress_percent` 0–100; `UNIQUE (student_id, lesson_id)` |
| `submissions` (`00011`) | `status ∈ (draft, submitted, checking, passed, failed)`; `score` 0–100 or NULL; `UNIQUE (student_id, assignment_id)` — one current submission, no attempt history yet |

Teacher-flow tables (`00012`–`00013`) + one index (`00014`):

| Table | Key rules |
| --- | --- |
| `groups` (`00012`) | `status ∈ (draft, active, completed, cancelled)`; `max_students` NULL or `> 0`; FK `course_id → courses`, `teacher_id → users`. **`teacher_id` must be a `teacher`** — no group-creation endpoint this stage, so enforced by the seed / a future admin action, not a trigger |
| `group_students` (`00013`) | composite `PRIMARY KEY (group_id, student_id)` (= the uniqueness rule); adding a member also guarantees an active enrollment in the group's course (one transaction) |
| `00014` | `idx_submissions_status_submitted_at` — serves the teacher's default queue (`status='submitted' ORDER BY submitted_at`) |

**Resubmission (change vs the student stage):** a submission is now editable while `draft` **or** `failed`. Resubmitting (`failed → submitted`) clears the previous `score` / `teacher_feedback` / `checked_at`. Still **one current submission per (student, assignment)** — no attempt history yet.

Parent-flow table (`00015`):

| Table | Key rules |
| --- | --- |
| `parent_children` (`00015`) | composite `PRIMARY KEY (parent_id, child_id)`; `CHECK (parent_id <> child_id)`; both FK `→ users ON DELETE CASCADE`. **`parent_id` must be a `parent` and `child_id` a `student`** — enforced by the admin service (`POST /admin/parent-links` checks both roles) or the seed, not a trigger |

Admin-flow table (`00016`):

| Table | Key rules |
| --- | --- |
| `admin_audit_log` (`00016`) | `admin_id → users`, `action ∈ (create, update, delete)`, `entity`, `entity_id`, `summary`. One row per admin mutation, written best-effort (a failed audit write never fails the operation it describes). Read-only via `GET /admin/audit`. Quiz authoring mutations write here too (`entity` = `quiz_settings` / `quiz_question` / `quiz_option`). |

Code-runner tables (`00023`–`00024`, `internal/runs`):

| Table | Key rules |
| --- | --- |
| `code_runs` (`00023`) | one row per execution a student triggers — `kind ∈ (run, grade)`, `status ∈ (ok, error, timeout, runner_error)`, captured `stdout`/`stderr` (capped) + `exit_code` + `duration_ms` + `truncated`. Attempt history (spec §5). `assignment_id → assignments`, `student_id → users`, both `ON DELETE CASCADE`. |
| `assignment_tests` (`00024`) | admin-authored I/O test case for a `code` assignment — `name`, `stdin`, `expected_stdout`, `is_hidden` (never revealed to the student), `weight ≥ 1`, `position`. Hidden tests are used only for grading (spec §6, §7). |

Quiz-engine tables (`00017`–`00021`, `internal/quizzes`):

| Table | Key rules |
| --- | --- |
| `quiz_questions` (`00017`) | `assignment_id → assignments ON DELETE CASCADE`; `question_type ∈ (single_choice, multiple_choice, true_false)`; `points ≥ 1`; `is_active` (soft-hide). Questions only make sense for an `assignment_type = quiz` — the service rejects creating one on a `text`/`code`/`project` assignment (spec §5). |
| `quiz_options` (`00018`) | `question_id → quiz_questions ON DELETE CASCADE`; `is_correct`; `is_active`. Student-facing API **never** returns `is_correct` before an attempt is submitted (spec §7). |
| `quiz_attempts` (`00019`) | `assignment_id → assignments`, `student_id → users`; `status ∈ (in_progress, submitted)`; `score`/`max_score`/`percent`/`passed` filled on submit. **No uniqueness on (student, assignment)** — a student keeps a full attempt history (spec §13). Quiz assignments never create a `submissions` row (spec §46). |
| `quiz_settings` (`00020`) | `assignment_id` PK `→ assignments ON DELETE CASCADE`; `pass_percent` 0–100 (default 70); `max_attempts` NULL = unlimited; `show_correct_answers`, `show_explanations`. `PUT` replaces the whole row. |
| `quiz_attempt_answers` (`00021`) | `UNIQUE (attempt_id, question_id)`; per-question `is_correct` + `points_awarded` (server-computed). Selected options live in `quiz_attempt_answer_options` (composite PK) so `multiple_choice` works. |

## Seed data (development only)

Seeds are plain SQL, kept separate from migrations, and are **not** run automatically:

```bash
psql "$DATABASE_URL" -f seeds/dev_seed.sql        # catalog: programs/levels/courses/modules/lessons
psql "$DATABASE_URL" -f seeds/dev_seed_users.sql  # dev users (see below)
```

`dev_seed.sql` inserts one program ("Computer Science Kids"), one level, and 6 courses, plus 4 modules and 5 lessons under "Python Start". Safe to re-run — it upserts by slug.

`dev_seed.sql` also seeds **3 assignments** (`code`, `code`, `text`) on the first three "Python Start" lessons, and — if `dev_seed_users.sql` has already run — **auto-enrols `student@codeschool.local` in "Python Start"**, creates the group **"Python Kids — Group 01"** (course Python Start, teacher `teacher@codeschool.local`, both dev students as members with guaranteed enrollment), leaves **one `submitted` submission** (from `student2`) in the review queue, and **links `parent@codeschool.local` to both dev students**. All idempotent. Re-running re-creates the module/lesson/assignment rows for that course (cascading away progress/submissions on them); it does **not** touch enrollments, groups, parent links, or other courses.

`dev_seed_users.sql` inserts five accounts, all with the password **`Password123!`** stored as a pre-computed bcrypt hash (the plain password is never in the SQL). **Development credentials only — do not use in production.**

| Email | Role |
| --- | --- |
| `admin@codeschool.local` | admin |
| `teacher@codeschool.local` | teacher |
| `student@codeschool.local` | student |
| `student2@codeschool.local` | student |
| `parent@codeschool.local` | parent |

Public registration cannot create an `admin` — that account only exists via this seed.

## Run locally

```bash
go run ./cmd/api
```

## Run with Docker

From the repo root (see the root README for the full picture):

```bash
docker compose up -d postgres
docker compose run --rm migrate   # or: goose -dir migrations postgres "$DATABASE_URL" up
docker compose up --build backend runner
```

The `runner` service (image `Dockerfile.runner`, ~1 min first build — it carries python3 / nodejs / go) executes student code in isolation. The backend finds it via `RUNNER_URL` (`docker-compose` sets `http://runner:8090`); leave `RUNNER_URL` unset to disable the code runner. It is on an internal-only Docker network and is not published on a host port.

## API

Base path: `/api/v1`. Every success response is `{"data": ...}`; every error is `{"error": {"code", "message"}}` with a matching HTTP status — raw SQL errors, stack traces, and connection strings are never returned to the client.

| Method | Path | Notes |
| --- | --- | --- |
| GET | `/health` | always `{"status":"ok"}` |
| GET | `/health/ready` | runs `SELECT 1`; `503` if the database is unreachable |
| GET | `/api/v1/programs` | active programs |
| GET | `/api/v1/programs/:id` | |
| GET | `/api/v1/programs/:id/levels` | levels for one program |
| GET | `/api/v1/levels/:id` | |
| GET | `/api/v1/courses` | published courses; optional `?age_from=&age_to=&level_id=` |
| GET | `/api/v1/courses/:id` | |
| GET | `/api/v1/courses/slug/:slug` | |
| GET | `/api/v1/courses/:id/modules` | ordered by `position` |
| GET | `/api/v1/courses/:id/content` | aggregate: course + modules + each module's lessons, in one response |
| GET | `/api/v1/modules/:id/lessons` | published lessons for a module |
| GET | `/api/v1/lessons/:id` | |
| POST | `/api/v1/auth/register` | `{email?|phone?, password, firstName, lastName?, role}` → the created user (no auto-login). `409` on a duplicate email/phone, `400` on a bad role (incl. `admin`) or a password under 8 chars |
| POST | `/api/v1/auth/login` | `{email?|phone?, password}` → `{accessToken, expiresIn, user}` + sets the `refresh_token` HttpOnly cookie. `401 "Invalid credentials"` for every failure (no user enumeration); `403` if the account is inactive |
| POST | `/api/v1/auth/refresh` | reads the `refresh_token` cookie (or `{refreshToken}` body), rotates it, → `{accessToken, expiresIn}` + a new cookie. `401` if revoked/expired/unknown |
| POST | `/api/v1/auth/logout` | revokes the current refresh token (idempotent) and clears the cookie |
| GET | `/api/v1/me` | **auth required** — the caller's own profile from the access token |
| GET | `/api/v1/{student,teacher,parent,admin}/ping` | **auth + exact role** — tiny role-authorization probes |

### Student flow (all require **auth + role `student`**)

| Method | Path | Notes |
| --- | --- | --- |
| POST | `/api/v1/courses/:id/enroll` | student id from the token, never the body. `404` if the course is missing/unpublished, `409` if already actively enrolled |
| GET | `/api/v1/me/courses` | the caller's enrollments + a trimmed course payload |
| GET | `/api/v1/me/progress` | one `{courseId,title,completedLessons,totalLessons,progressPercent}` per enrolled course |
| GET | `/api/v1/me/courses/:id/progress` | course tally + per-published-lesson status; `403` if not enrolled |
| GET | `/api/v1/lessons/:id/assignments` | a lesson's published assignments (incl. `language` for `code` assignments) — `403` unless enrolled in the owning course |
| POST | `/api/v1/lessons/:id/start` | idempotent → `lesson_progress` set `in_progress` |
| POST | `/api/v1/lessons/:id/complete` | `409` unless every published assignment is done: a non-draft submission for plain ones, a **passing** attempt for a quiz, a **passing** auto-graded submission for a test-graded `code` one. Otherwise sets `completed`/100%, recounts the course and auto-completes the enrollment (one transaction). |
| PUT | `/api/v1/assignments/:id/submission` | create/replace the caller's submission content — allowed while `draft` **or** `failed`; `409` when `submitted`/`checking`/`passed` |
| GET | `/api/v1/assignments/:id/submission` | the caller's own submission, or `{"data": null}` if none |
| POST | `/api/v1/assignments/:id/submit` | `draft → submitted` **or** `failed → submitted` (a resubmission, which clears the prior score/feedback/checked_at); `400` if there is no submission, `409` if it is locked |

**Authorization rules.** Every student-flow operation re-derives the owning course from the lesson/assignment id and checks the caller's active enrollment server-side — guessing an id is never enough (`403`). A student only ever sees or edits their **own** rows (the student id comes from the JWT). `score` / `teacher_feedback` / `checking` / `passed` / `failed` are set only by the teacher flow.

### Teacher flow (all require **auth + role `teacher`**)

| Method | Path | Notes |
| --- | --- | --- |
| GET | `/api/v1/teacher/dashboard` | `{groupsCount, studentsCount, pendingSubmissions, reviewedSubmissions}` — read model, one round trip |
| GET | `/api/v1/teacher/groups` | the caller's groups + `studentCount` + `avgProgressPercent` |
| GET | `/api/v1/teacher/groups/:id` | one owned group (`404` for a missing **or** another teacher's group — no existence leak) |
| GET | `/api/v1/teacher/groups/:id/students` | members + per-student progress + pending-submission count (one query, no N+1) |
| GET | `/api/v1/teacher/groups/:id/students/:studentId` | student profile (safe fields only), lesson progress, submission summary; `403` if not a member of this owned group |
| GET | `/api/v1/teacher/submissions` | `?status=&group_id=&course_id=&page=&limit=` (limit ≤ 100); default sort `submitted_at ASC`. `{"data": [...], "meta": {page,limit,total}}` |
| GET | `/api/v1/teacher/submissions/:id` | full review view — only if the student is in one of this teacher's groups **for that course** |
| POST | `/api/v1/teacher/submissions/:id/start-review` | `submitted → checking` (idempotent if already `checking`); keeps `GET` side-effect-free |
| POST | `/api/v1/teacher/submissions/:id/review` | `{score?, feedback?, status}` — `status ∈ {passed, failed}`; `score` `0..points` (required when `points > 0`); `feedback` required for `failed`; sets `checked_at`. `409` if the submission is not `submitted`/`checking` |

**Ownership.** Every teacher operation joins `submission → student → group_students → groups(course-matched) → teacher_id` (or the group equivalent) in SQL — teacher A can never read or review a submission of teacher B's group student, even with the id. Student profiles returned to teachers carry **no** password hash, tokens, phone, or email.

### Parent flow (all require **auth + role `parent`**, all **read-only** GETs)

| Method | Path | Notes |
| --- | --- | --- |
| GET | `/api/v1/parent/children` | linked children + a rolled-up summary each: `{coursesCount, overallProgressPercent, pendingReview, needsWork}` (one query, nested LATERAL — no N+1) |
| GET | `/api/v1/parent/children/:id` | one child: profile (safe fields) + per-enrolled-course progress. `404` for a missing child **or** one not linked to this parent — no existence leak |
| GET | `/api/v1/parent/children/:id/courses/:courseId` | lesson progress + every published assignment with the child's submission state **and the teacher's feedback** (`score`, `teacherFeedback`, `submittedAt`, `checkedAt`). `404` if the child is not enrolled in that course |
| GET | `/api/v1/parent/children/:id/activity` | recent-activity timeline (≤25) — completed lessons + non-draft submissions merged, newest first |

**Ownership.** Every parent operation first checks `parent_children(parent_id = <token>, child_id = :id)`; an unlinked child yields `404` before any child data is touched. A different parent sees an empty `/children` list and `404` on someone else's child. Child payloads carry **no** password hash, tokens, phone, or email. There are **no** `POST` / `PUT` / `DELETE` routes under `/parent`.

### Admin panel (all require **auth + role `admin`**)

| Area | Routes |
| --- | --- |
| overview / audit | `GET /admin/overview`, `GET /admin/audit?page=&limit=` |
| users | `GET /admin/users?role=&active=&search=&page=&limit=` · `POST /admin/users` (any role, incl. `admin`) · `GET|PATCH|DELETE /admin/users/:id` · `POST /admin/users/:id/password` |
| parent-child links | `GET /admin/parent-links?parentId=&childId=` · `POST /admin/parent-links` `{parentId, childId}` (role-checked) · `DELETE /admin/parent-links?parentId=&childId=` |
| catalog | `GET|POST /admin/{programs,levels,courses,modules,lessons,assignments}` + `GET|PATCH|DELETE .../:id`. List filters: `?programId=` (levels), `?levelId=&published=` (courses), `?courseId=` (modules), `?moduleId=` (lessons), `?lessonId=` (assignments) |
| groups | `GET /admin/groups?teacherId=&courseId=&status=` · `POST /admin/groups` `{courseId, teacherId, ...}` (teacher role-checked) · `GET|PATCH|DELETE /admin/groups/:id` · `GET|POST /admin/groups/:id/students` · `DELETE /admin/groups/:id/students/:studentId` |

**Semantics.** `PATCH` bodies are sparse — only the fields present are changed (an empty string clears a nullable text column). Deletes rely on the schema's `ON DELETE CASCADE` (dropping a program removes its whole subtree; dropping a user removes their enrollments / submissions / memberships / links / owned groups). Guards: an admin cannot delete or deactivate **their own** account, and the **last active admin** cannot be removed or demoted. Adding a student to a group reuses the teacher-stage transaction (membership + guaranteed active enrollment, `max_students` enforced). Duplicate slug / email / phone → `409`; a bad foreign key or enum → `400`. Every successful mutation writes one `admin_audit_log` row.

### Code runner (`internal/runs` + `cmd/runner` + `internal/sandbox`)

**Isolation.** The `runner` service is a separate container that runs student code. `docker-compose` puts it on an **internal-only network** (no internet egress — verified: an outbound `connect()` fails), **non-root** (uid 10001), **`read_only` rootfs** with tmpfs scratch (`/work` exec-capable, `/tmp` noexec), **`cap_drop: ALL`**, **`no-new-privileges`**, and hard **`pids_limit` / `mem_limit` / `cpus`** caps. It is **not published on a host port**. Per execution the sandbox adds: a wall-clock timeout that SIGKILLs the process group, a CPU-seconds + file-size `ulimit` (and an address-space cap for interpreters), bounded stdin, bounded stdout/stderr capture (rest discarded → `truncated`), a fresh wiped scratch dir, and a stripped environment. The runner is **optional** — with `RUNNER_URL` unset the endpoints return `503`.

**Student** (auth + role `student`, enrolled, assignment is a published `code` assignment with a language):

| Method | Path | Notes |
| --- | --- | --- |
| POST | `/api/v1/assignments/:id/run` | `{code, stdin?}` — execute once, record it, return `{stdout, stderr, exitCode, timedOut, truncated, durationMs}`. Per-student throttle → `409`; `503` if the runner is down. |
| GET | `/api/v1/assignments/:id/runs` | the student's recent runs for the assignment (history). |
| GET | `/api/v1/assignments/:id/tests` | `{hasTests, total, visible:[…]}` — **visible sample tests only**; hidden ones are never in the payload. |
| POST | `/api/v1/assignments/:id/code/submit` | `{code}` — run **every** test (visible + hidden), weighted-score it, and finalize the submission `passed` / `failed` with an auto-feedback summary (spec §7). Requires ≥ 1 test. A failed **visible** test returns its expected/got; a failed **hidden** test returns only pass/fail. |

**Admin** (auth + role `admin`, all audited): `GET`/`POST /api/v1/admin/assignments/:id/tests`, `PATCH`/`DELETE /api/v1/admin/tests/:id`.

Grading: `stdout` is compared after trimming trailing whitespace per line + trailing blank lines. Score `= Σ passed weight / Σ weight` as a percent, scaled to `assignment.points`. `passed` only if **every** test passes. An auto-graded submission never enters the teacher review queue (like a quiz), and a lesson with a test-graded `code` assignment needs a **passing** submission to complete.

### Quiz engine (`internal/quizzes`)

**Student** (auth + role `student`, enrolled in the course):

| Method | Path | Notes |
| --- | --- | --- |
| POST | `/api/v1/assignments/:id/quiz/attempts` | Start (or resume an open) attempt. Returns `{attempt, quiz:{questions:[{options}]}}` — **no `isCorrect`, no `explanation`**. `409` if `max_attempts` reached / quiz has no questions / quiz misconfigured. |
| GET | `/api/v1/assignments/:id/quiz/attempts` | Attempt history + roll-up (`bestPercent`, `attemptsUsed`, `attemptsLeft`, `passed`, `canStart`). |
| POST | `/api/v1/quiz/attempts/:id/submit` | `{answers:[{questionId, selectedOptionIds}]}`. Own attempt only (`403`); double-submit → `409`; a foreign question/option → `400`. Scored **server-side** in one transaction; strict match for `multiple_choice` (no partial credit). Returns the graded result (correct options + explanations only if the settings allow). |
| GET | `/api/v1/quiz/attempts/:id` | Own attempt — resumable quiz while `in_progress`, graded result once `submitted`. |

**Teacher** (auth + role `teacher`): `GET /api/v1/teacher/quiz/attempts/:id` — read-only, only for a student who shares one of the teacher's groups for that course. Teacher student-detail (`/teacher/groups/:id/students/:studentId`) also carries a `quizResults[]` roll-up.

**Admin** (auth + role `admin`, all audited):

| Method | Path |
| --- | --- |
| GET | `/api/v1/admin/assignments/:id/quiz` |
| PUT | `/api/v1/admin/assignments/:id/quiz/settings` |
| POST | `/api/v1/admin/assignments/:id/quiz/questions` (optional inline `options[]`) |
| PATCH / DELETE | `/api/v1/admin/quiz/questions/:id` |
| POST | `/api/v1/admin/quiz/questions/:id/options` |
| PATCH / DELETE | `/api/v1/admin/quiz/options/:id` |

Authoring guards: questions only on `assignment_type = quiz`; `single_choice` / `true_false` reject a second correct option; `true_false` capped at two options; `pass_percent` 0–100. **History safety** — deleting a question/option that already appears in a submitted attempt *deactivates* it (`is_active = false`) instead of hard-deleting; unreferenced rows are hard-deleted. Progress: a lesson with a quiz assignment can only be completed once the student has a **passing** attempt (spec §45).

### Auth model

- **Access token** — signed JWT (HS256), `sub` = user id, `role`, `iat`, `exp`; 15-min TTL. Sent as `Authorization: Bearer <token>`. Never carries the password hash.
- **Refresh token** — opaque 256-bit random string. Only its SHA-256 hex digest is stored (`refresh_tokens.token_hash`); the plain value is delivered **only** as a `Set-Cookie: refresh_token=…; HttpOnly; SameSite=Lax; Path=/api/v1/auth` (plus `Secure` when `APP_ENV=production`) — never in a response body. Each refresh **rotates**: the presented token is revoked in the same transaction that mints its replacement. One user may hold many refresh tokens (one per device); logout revokes only the current one.
- **Authorization** is always derived from the validated token / server-side user state, never from the request body. Inactive users cannot log in, refresh, or reach protected endpoints.

Age filtering on `/courses` is an overlap check: a course matches if its own `[age_from, age_to]` range overlaps the requested one — not an exact bucket match.

### Auth curl walkthrough

```bash
BASE=http://localhost:8080/api/v1

# 1. Register (returns the user; does not log in)
curl -X POST $BASE/auth/register -H 'Content-Type: application/json' \
  -d '{"email":"ayan@example.com","password":"password123","firstName":"Ayan","role":"student"}'

# 2. Log in — saves the HttpOnly refresh cookie to cookies.txt, prints the access token
curl -c cookies.txt -X POST $BASE/auth/login -H 'Content-Type: application/json' \
  -d '{"email":"ayan@example.com","password":"password123"}'
ACCESS=<accessToken from the response>

# 3. Call a protected endpoint
curl $BASE/me -H "Authorization: Bearer $ACCESS"

# 4. Refresh (uses the cookie) — rotates the refresh token, returns a new access token
curl -b cookies.txt -c cookies.txt -X POST $BASE/auth/refresh

# 5. Log out (uses the cookie) — revokes it
curl -b cookies.txt -c cookies.txt -X POST $BASE/auth/logout
```

## Tests

```bash
go fmt ./...
go vet ./...
go test ./...
go build ./cmd/api
```

`go test ./...` runs without a database. The `courses`, `auth`, `enrollments`, `assignments`, `submissions`, `progress`, `groups` and `parents` service tests use in-memory fake repositories — they cover enrollment (success / duplicate / unpublished / only-own-courses), the lesson-completion gate, the progress `Percent()` calc (incl. divide-by-zero), the review flow (`submitted → checking → passed/failed`, `start-review` idempotency, score ≤ points, score required when points > 0, feedback required for `failed`, `passed` cannot be re-reviewed), the resubmission rules (`failed` editable + clears review on resubmit, `checking`/`passed` locked), teacher ownership gates (own group / not another teacher's, own group's student / not an unrelated student, own group's submissions only, cannot review an unrelated submission, pagination clamp), the **parent link gate** (a linked child is readable; an unlinked or non-existent child yields `ErrChildNotFound` and the repo is never touched; a different parent sees only their own children), and — for this stage — the **admin** pure guards (`canRemoveAdminPrivilege`: self / last-admin), user-request validation, `normStr`, and the sparse `PATCH` field-map builders (only-provided fields land; `""` clears a nullable column).

The `auth` suite additionally covers password hashing, JWT sign/verify/expiry, register validation (duplicate email/phone, `admin` rejected, short password), login (wrong password, no user enumeration, inactive rejected), refresh rotation + reuse/revoked/expired rejection, logout idempotency, and the JWT/role middleware (expired token, inactive user, student → `/admin/ping` = 403).

The `quizzes` package adds pure **scoring** tests; the `runs` package adds pure **grading** tests (line-trailing-whitespace-tolerant output comparison, weighted percent, timeout/runner-error fail a test, percent → points scaling with rounding); the `sandbox` package really executes Python (hello / stdin / non-zero exit / **wall-clock timeout** / **output truncation** / network probe) and — when the toolchains are reachable — JavaScript and Go; and `progress` tests that a failed quiz **or** a failed test-graded code assignment blocks lesson completion while a passing one allows it.

Seven integration tests run against a real Postgres — skipped unless `TEST_DATABASE_URL` is set. Each inserts and cleans up its own throwaway fixtures and does not touch seed data:

```bash
TEST_DATABASE_URL=postgres://codeschool:codeschool@localhost:5432/codeschool?sslmode=disable \
  go test ./internal/courses/... ./internal/progress/... ./internal/groups/... ./internal/parents/... ./internal/admin/... ./internal/quizzes/... ./internal/runs/... -run "Repository|FullFlow" -v
```

- `courses` — the *published-only* filter on `GET /courses`.
- `progress` — the lesson-completion transaction (recount + enrollment auto-complete + `lesson_progress` uniqueness).
- `groups` — `AddStudentTx` (creates the enrollment, enforces `max_students`, blocks duplicates, rejects non-students) and the ownership joins (teacher A ≠ teacher B for groups, students, and submissions).
- `parents` — `IsLinked` gate (parent A ≠ parent B), the `ListChildren` roll-up aggregates, `ChildCourseDetail` surfacing the teacher's `score`/`feedback`, `ErrCourseNotFound` for an un-enrolled course, and the newest-first activity timeline.
- `admin` — the full program → assignment CRUD chain, duplicate-slug / bad-FK / bad-enum rejection, the assignment `language` round-trip + invalid-language rejection, role-checked parent links + group teacher assignment, group membership (+ auto-enrollment, `max_students`), the self / last-admin guards, audit rows written, and `ON DELETE CASCADE` on a program drop.
- `quizzes` — authoring (question on a non-quiz rejected, bad `pass_percent`, second correct option on `single_choice` rejected, audit rows), the attempt flow (non-enrolled / non-quiz blocked, resume returns the same attempt, foreign question/option rejected, `single_choice` needs exactly one selection, another student's attempt / double-submit rejected), fail-then-pass scoring across two attempts, the progress `CountPassedAssignments` gate, and question-with-history deactivating instead of deleting.
- `runs` — a fake runner drives: free run + persisted history, per-student throttle, non-enrolled / non-code / text-assignment rejection, visible-only test payload (hidden not leaked), wrong-solution auto-grade `failed` (hidden test I/O not exposed) then correct-solution `passed` with a full points score, the submission row ends `passed`, the `AssignmentIDsWithTests` / `CountPassedForAssignments` progress gate, and audit rows for test authoring.

## Logging & shutdown

Startup logs `database connected` and `server listening on :PORT` — never secrets, the full `DATABASE_URL`, `JWT_SECRET`, or any password / access token / refresh token. `SIGINT`/`SIGTERM` trigger a graceful shutdown: the HTTP server stops accepting new requests (10s deadline) and the connection pool closes.

## Not in this stage

AI review, certificates, payments, notifications, analytics — see the root README. Written submissions keep **one current row** per (student, assignment); quizzes and code runs keep history. If a lesson was completed and the teacher later marks its assignment `failed`, the lesson progress is **not** rolled back. The parent flow is read-only. The admin panel has no bulk import, no soft-delete / undo for catalog/user rows, and no per-field audit diff.

**Quiz limitations.** No question snapshots, no shuffle, no partial credit, no timed quizzes, no question bank, no random quiz generation.

**Code-runner limitations.** Three languages, single file, stdin/stdout only — no arguments, no packages / imports beyond each language's standard library (network is off), no interactive input, no multi-file projects. Isolation is container + `ulimit` + wall-clock timeout + output caps + non-root + no-network + `cap_drop ALL` + `read_only` rootfs — good for a trusted classroom, **not** a gVisor / seccomp / VM jail for anonymous public submissions. `go run` is compile-then-run (~250 ms warm; shared tmpfs build cache). Output comparison is exact after trailing-whitespace trimming — no regex / float tolerance / custom checkers. The per-student run throttle is in-memory per API instance. Refresh-token cleanup and login rate limiting remain future hardening.

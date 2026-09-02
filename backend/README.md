# CODESCHOOL Backend

Go + Gin + pgx/v5 (`pgxpool`) REST API over PostgreSQL 17. No ORM — plain, parameterized SQL. Modular monolith: one binary, one domain package per resource (`programs`, `levels`, `courses`, `modules`, `lessons`, `users`, `auth`, `enrollments`, `assignments`, `progress`, `submissions`, `groups`).

On top of the catalog + auth + student flow, this stage adds the **teacher flow**: a teacher's groups, the students in each group with their progress, a paginated submission-review queue, and the review verdict (`score` + `feedback` + `passed`/`failed`). A `failed` verdict makes the submission editable again so the student can revise and **resubmit**. No group/teacher CRUD (groups come from the dev seed), no quiz engine, no code execution, no AI review — see the root README.

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
| `assignments` (`00009`) | `assignment_type ∈ (text, code, quiz, project)`; `points >= 0`; `is_published` |
| `lesson_progress` (`00010`) | `status ∈ (not_started, in_progress, completed)`; `progress_percent` 0–100; `UNIQUE (student_id, lesson_id)` |
| `submissions` (`00011`) | `status ∈ (draft, submitted, checking, passed, failed)`; `score` 0–100 or NULL; `UNIQUE (student_id, assignment_id)` — one current submission, no attempt history yet |

Teacher-flow tables (`00012`–`00013`) + one index (`00014`):

| Table | Key rules |
| --- | --- |
| `groups` (`00012`) | `status ∈ (draft, active, completed, cancelled)`; `max_students` NULL or `> 0`; FK `course_id → courses`, `teacher_id → users`. **`teacher_id` must be a `teacher`** — no group-creation endpoint this stage, so enforced by the seed / a future admin action, not a trigger |
| `group_students` (`00013`) | composite `PRIMARY KEY (group_id, student_id)` (= the uniqueness rule); adding a member also guarantees an active enrollment in the group's course (one transaction) |
| `00014` | `idx_submissions_status_submitted_at` — serves the teacher's default queue (`status='submitted' ORDER BY submitted_at`) |

**Resubmission (change vs the student stage):** a submission is now editable while `draft` **or** `failed`. Resubmitting (`failed → submitted`) clears the previous `score` / `teacher_feedback` / `checked_at`. Still **one current submission per (student, assignment)** — no attempt history yet.

## Seed data (development only)

Seeds are plain SQL, kept separate from migrations, and are **not** run automatically:

```bash
psql "$DATABASE_URL" -f seeds/dev_seed.sql        # catalog: programs/levels/courses/modules/lessons
psql "$DATABASE_URL" -f seeds/dev_seed_users.sql  # dev users (see below)
```

`dev_seed.sql` inserts one program ("Computer Science Kids"), one level, and 6 courses, plus 4 modules and 5 lessons under "Python Start". Safe to re-run — it upserts by slug.

`dev_seed.sql` also seeds **3 assignments** (`code`, `code`, `text`) on the first three "Python Start" lessons, and — if `dev_seed_users.sql` has already run — **auto-enrols `student@codeschool.local` in "Python Start"**, creates the group **"Python Kids — Group 01"** (course Python Start, teacher `teacher@codeschool.local`, both dev students as members with guaranteed enrollment), and leaves **one `submitted` submission** (from `student2`) in the review queue. All idempotent. Re-running re-creates the module/lesson/assignment rows for that course (cascading away progress/submissions on them); it does **not** touch enrollments, groups, or other courses.

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
docker compose up --build backend
```

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
| GET | `/api/v1/lessons/:id/assignments` | a lesson's published assignments — `403` unless enrolled in the owning course |
| POST | `/api/v1/lessons/:id/start` | idempotent → `lesson_progress` set `in_progress` |
| POST | `/api/v1/lessons/:id/complete` | `409` if the lesson has a published assignment with no non-draft submission; otherwise sets `completed`/100%, recounts the course and auto-completes the enrollment (one transaction) |
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

`go test ./...` runs without a database. The `courses`, `auth`, `enrollments`, `assignments`, `submissions`, `progress` and `groups` service tests use in-memory fake repositories — they cover enrollment (success / duplicate / unpublished / only-own-courses), the lesson-completion gate, the progress `Percent()` calc (incl. divide-by-zero), and — for this stage — the review flow (`submitted → checking → passed/failed`, `start-review` idempotency, score ≤ points, score required when points > 0, feedback required for `failed`, `passed` cannot be re-reviewed), the resubmission rules (`failed` editable + clears review on resubmit, `checking`/`passed` locked), and teacher ownership gates (own group / not another teacher's, own group's student / not an unrelated student, own group's submissions only, cannot review an unrelated submission, pagination clamp).

The `auth` suite additionally covers password hashing, JWT sign/verify/expiry, register validation (duplicate email/phone, `admin` rejected, short password), login (wrong password, no user enumeration, inactive rejected), refresh rotation + reuse/revoked/expired rejection, logout idempotency, and the JWT/role middleware (expired token, inactive user, student → `/admin/ping` = 403).

Three integration tests run against a real Postgres — skipped unless `TEST_DATABASE_URL` is set. Each inserts and cleans up its own throwaway fixtures and does not touch seed data:

```bash
TEST_DATABASE_URL=postgres://codeschool:codeschool@localhost:5432/codeschool?sslmode=disable \
  go test ./internal/courses/... ./internal/progress/... ./internal/groups/... -run Repository -v
```

- `courses` — the *published-only* filter on `GET /courses`.
- `progress` — the lesson-completion transaction (recount + enrollment auto-complete + `lesson_progress` uniqueness).
- `groups` — `AddStudentTx` (creates the enrollment, enforces `max_students`, blocks duplicates, rejects non-students) and the ownership joins (teacher A ≠ teacher B for groups, students, and submissions).

## Logging & shutdown

Startup logs `database connected` and `server listening on :PORT` — never secrets, the full `DATABASE_URL`, `JWT_SECRET`, or any password / access token / refresh token. `SIGINT`/`SIGTERM` trigger a graceful shutdown: the HTTP server stops accepting new requests (10s deadline) and the connection pool closes.

## Not in this stage

Group / teacher / course CRUD (groups come from the dev seed; a teacher works only their existing groups), parent–child links, quiz engine, code execution / sandboxing, AI review, certificates, payments, notifications — see the root README. Student code is **stored only**, never executed. Submissions keep **one current row** per (student, assignment) — a resubmission overwrites it and clears the prior review; per-attempt history is future work. If a lesson was completed and the teacher later marks its assignment `failed`, the lesson progress is **not** rolled back (the UI shows "needs revision" instead) — a stricter mastery workflow is future work. Refresh-token cleanup and login rate limiting remain noted as future hardening.

# CODESCHOOL

An educational IT platform for Kazakhstan — programming, robotics, AI, web/mobile development for kids, teens, teachers and parents. RU / KZ / EN, dark/light theme, fully responsive.

## Architecture

```
Browser
   │
   ▼
Next.js :3000  (App Router, TypeScript)
   │
   │ REST (fetch, no caching — always live)
   ▼
Go Gin :8080  (modular monolith, no ORM)
   │
   │ pgxpool
   ▼
PostgreSQL 17 :5432 (container) / :5433 (host-mapped, see below)
```

The catalog (`programs → levels → courses → modules → lessons`) is read-only. Auth and the **student learning flow** are in place: enrol → "My courses" → open lesson (starts progress) → do + submit the assignment → complete lesson → course progress recalculated in PostgreSQL, auto-completing the enrollment when every published lesson is done.

This stage adds the **teacher flow**: a teacher opens their dashboard → sees their groups → opens a group → sees each student's progress → works the pending-review queue → opens a submission → reads the answer/code → sets a score + feedback → marks it **passed** or **failed**. A `failed` submission becomes editable again: the student revises it, **resubmits**, and it returns to the teacher's queue. No group/teacher CRUD, quiz engine, code execution or AI review — see [What's not in this stage](#whats-not-in-this-stage).

## Project structure

```
CODESCHOOL/
├── backend/              Go + Gin + pgx/v5 REST API — see backend/README.md
├── frontend/              Next.js (App Router, TypeScript) — see frontend/README.md
├── frontend-prototype/    The original approved HTML/CSS/JS design reference
├── docker-compose.yml
├── .env.example
└── README.md
```

## Requirements

- Docker + Docker Compose, **or** locally: Go 1.26+, Node 22+, PostgreSQL 17, [goose](https://github.com/pressly/goose)

## Environment

```bash
cp .env.example .env          # root — used by docker-compose.yml
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env.local
```

## Run everything with Docker

```bash
docker compose up -d postgres
docker compose run --rm migrate     # applies all Goose migrations
docker compose up --build backend frontend
```

- Postgres is mapped to host port **5433**, not 5432 — chosen to avoid clashing with a Postgres that might already be running on the host. Containers talk to each other over the internal Docker network on the normal 5432 regardless.
- Seed data is intentionally **not** part of `docker compose up` (see [Seeds](#seeds) below) — migrations create the schema, seeds are a separate, explicit, development-only step.

```bash
# development seed (password: Password123! — dev only). Users first: the
# catalog seed also wires up a teacher group + a pending submission.
docker compose exec -T postgres psql -U codeschool -d codeschool < backend/seeds/dev_seed_users.sql
docker compose exec -T postgres psql -U codeschool -d codeschool < backend/seeds/dev_seed.sql
```

## Run locally (no Docker)

```bash
# 1. Postgres running locally on 5432 (or point DATABASE_URL elsewhere)
export DATABASE_URL=postgres://codeschool:codeschool@localhost:5432/codeschool?sslmode=disable

# 2. Migrations
cd backend
goose -dir migrations postgres "$DATABASE_URL" up

# 3. Seed data (development only)
psql "$DATABASE_URL" -f seeds/dev_seed_users.sql   # dev users, password: Password123!
psql "$DATABASE_URL" -f seeds/dev_seed.sql         # catalog + a group + a pending submission

# 4. Backend
go run ./cmd/api

# 5. Frontend (separate shell)
cd ../frontend
npm install
npm run dev
```

Open http://localhost:3000.

## Seeds

`backend/seeds/dev_seed.sql` is plain SQL, run manually, never automatically — see `backend/README.md`. It creates one program ("Computer Science Kids"), one level, and 6 courses reusing the names/ages already present in `frontend/data/*.ts` where they overlapped (Scratch Junior, Python Start, Robotics Arduino, AI Junior — plus "Основы алгоритмов" and "Web Development" per this stage's spec), with 4 modules and 5 lessons under "Python Start".

## API

Full endpoint list, request/response shapes, and the error format are documented in `backend/README.md`. Quick reference:

```
GET /health
GET /health/ready
GET /api/v1/programs
GET /api/v1/programs/:id
GET /api/v1/programs/:id/levels
GET /api/v1/courses               ?age_from=&age_to=&level_id=
GET /api/v1/courses/:id
GET /api/v1/courses/slug/:slug
GET /api/v1/courses/:id/modules
GET /api/v1/courses/:id/content   (aggregate: course + modules + lessons)
GET /api/v1/modules/:id/lessons
GET /api/v1/lessons/:id

POST /api/v1/auth/register
POST /api/v1/auth/login              → access token (JSON) + refresh token (HttpOnly cookie)
POST /api/v1/auth/refresh            → rotates the refresh token
POST /api/v1/auth/logout
GET  /api/v1/me                      (auth required)
GET  /api/v1/{student|teacher|parent|admin}/ping   (auth + exact role)

# student flow (auth + role=student)
POST /api/v1/courses/:id/enroll
GET  /api/v1/me/courses
GET  /api/v1/me/progress
GET  /api/v1/me/courses/:id/progress
GET  /api/v1/lessons/:id/assignments
POST /api/v1/lessons/:id/start
POST /api/v1/lessons/:id/complete
PUT  /api/v1/assignments/:id/submission     edit content (draft OR failed)
GET  /api/v1/assignments/:id/submission     own submission (or null)
POST /api/v1/assignments/:id/submit         draft/failed → submitted

# teacher flow (auth + role=teacher)
GET  /api/v1/teacher/dashboard
GET  /api/v1/teacher/groups
GET  /api/v1/teacher/groups/:id
GET  /api/v1/teacher/groups/:id/students
GET  /api/v1/teacher/groups/:id/students/:studentId
GET  /api/v1/teacher/submissions            ?status=&group_id=&course_id=&page=&limit=  → {data, meta}
GET  /api/v1/teacher/submissions/:id
POST /api/v1/teacher/submissions/:id/start-review    submitted → checking
POST /api/v1/teacher/submissions/:id/review          {score?, feedback?, status: passed|failed}
```

## Frontend ↔ backend integration

- `frontend/lib/api.ts` — typed `apiFetch<T>()` client, unwraps `{"data": ...}` / `{"error": {...}}`, throws a normalized `ApiError`. All requests use `cache: "no-store"` — this is a live catalog, not static content, so a change in Postgres shows up on the next request instead of being frozen into a build.
- `app/page.tsx` and `app/courses/page.tsx` fetch courses **server-side** (`getCourses()` in an async Server Component) and pass the array into `CoursesSection`, which stays a Client Component only for the age-filter's interactive state — not for data loading.
- `app/courses/[slug]/page.tsx` — a new course detail route, fetching by slug and rendering its modules, in the same design system.
- If the backend is unreachable, the courses section shows an inline, translated error message (`t.courses.loadError`) — it never falls back to silently substituting fake data, and never breaks the rest of the page's layout.
- `CourseCard` and `CourseDetail` render the **same visual design** as before — only the data source changed (a `data/courses.ts` static array → a live API call). Per-course badge colors/labels aren't stored in the database (that's presentation, not content) — they're looked up by the course's stable `slug` in `frontend/lib/courseVisuals.ts`.

## Auth on the frontend

- `hooks/useAuth.tsx` — `AuthProvider` / `useAuth()`. The **access token lives only in memory** (React state); on page load it calls `/auth/refresh` (using the HttpOnly cookie) then `/me` to restore the session, and proactively re-refreshes shortly before expiry.
- `lib/api.ts` — extended with `login`, `register`, `refresh`, `logout`, `getMe`. These run **in the browser** (`credentials: "include"`) against `NEXT_PUBLIC_BROWSER_API_URL` (the server-side `NEXT_PUBLIC_API_URL` is a Docker-internal hostname the browser can't reach).
- `/login` and `/register` are the **same approved design** — the placeholder forms are now wired to the API, with inline (never `alert()`) errors, a disabled submit while pending, and RU/KZ/EN role labels (API values stay `student`/`teacher`/`parent`).
- After login the user is redirected by role: `student → /student`, `teacher → /teacher`, `parent → /parent`, `admin → /admin`. `/student`, `/parent`, `/admin` are new protected placeholder dashboards (`components/auth/RequireAuth.tsx`); `/teacher` stays the public Teacher Academy page and shows a personal-cabinet card when a teacher is signed in.
- The Header/MobileMenu are visually unchanged — the "Log in" button becomes the user's first name + a "Log out" action when authenticated.
- A protected call that gets a `401` (expired access token) transparently refreshes via the cookie and retries once — the same auth flow, no second mechanism.

## Student flow on the frontend

- `lib/api.ts` gains typed `enrollCourse`, `getMyCourses`, `getMyProgress`, `getCourseProgress`, `startLesson`, `completeLesson`, `getLessonAssignments`, `getMySubmission`, `saveSubmissionDraft`, `submitAssignment`.
- **`/student`** — real dashboard: greeting, overall progress bar, "My courses" cards (each with its own progress bar + "Continue"), empty state with a "Browse courses" CTA.
- **`/student/courses`** — the full my-courses grid.
- **`/learn/[courseId]`** — course overview: progress + a module/lesson list showing each lesson's status, and a "Continue" jump to the first unfinished lesson.
- **`/learn/[courseId]/lesson/[lessonId]`** — the learning page: a sticky lesson sidebar (status per lesson), the lesson content, an assignment panel per assignment (textarea for `text`/`project`, monospace textarea for `code` — **no Monaco**), Save-draft / Send-to-teacher, and a "Complete lesson" button that's disabled until every assignment is submitted. Opening the lesson fires exactly one `POST /lessons/:id/start`.
- **`/courses/[slug]`** — same design, plus one auth-aware CTA: "Log in to start" (guest) / "Start learning" → enrol → `/learn/:id` (student, not enrolled) / "Continue learning" (student, enrolled).
- Submission status badges (`Draft` / `Submitted` / `In review` / `Passed` / `Needs work`) are translated RU/KZ/EN; API values stay `draft`/`submitted`/`checking`/`passed`/`failed`. Every student/teacher page has loading / empty / error states and no `alert()`.
- After a teacher review the `AssignmentPanel` shows the verdict: **passed** → `✓ Passed, 8 / 10` + feedback (locked); **failed** → feedback + the fields become editable again with "Save draft" / "Send to teacher" (a resubmission).

## Teacher flow on the frontend

- `lib/api.ts` gains typed `getTeacherDashboard`, `getTeacherGroups`, `getTeacherGroup`, `getTeacherGroupStudents`, `getTeacherStudent`, `getTeacherSubmissions` (paginated), `getTeacherSubmission`, `startSubmissionReview`, `reviewSubmission` — same browser client + 401-refresh-retry.
- **`/teacher`** — no longer a placeholder: the public Teacher Academy page for visitors, and the **real dashboard** for a signed-in teacher (4 stat cards from `/teacher/dashboard` + group cards).
- **`/teacher/groups`**, **`/teacher/groups/[id]`**, **`/teacher/groups/[id]/students/[studentId]`** — group list, group roster (progress + pending count per student), and the per-student detail (lesson progress + submission summary). Tables collapse to stacked cards below 720px.
- **`/teacher/submissions`** — the review queue with tabs (`Awaiting review` / `In review` / `Passed` / `Needs work` / `All`) and simple pagination; oldest-submitted first.
- **`/teacher/submissions/[id]`** — the review screen: assignment (description / starter code / max points) beside the student's answer or code (monospace, **never executed**), then a score input + feedback textarea + **Pass** / **Needs work** buttons. Opening the page fires one `start-review` (`submitted → checking`); marking `failed` requires feedback (inline error, no `alert()`).
- All `/teacher/*` app routes are wrapped in `RequireAuth roles={["teacher"]}`.

Frontend route guards are a **UX** boundary; the backend authorization on every protected API call is the real security boundary.

**Security trade-off note:** the refresh token is an HttpOnly, `SameSite=Lax` cookie scoped to `/api/v1/auth` (never in `localStorage`, never in a response body), and the access token is memory-only — so neither is readable by page JavaScript (XSS can't exfiltrate them). `Secure` is off in local development (plain HTTP) and on in production. Because the cookie lives on the API origin, Next.js middleware/`proxy` can't read it, so route protection is client-side only (see above).

## What's not in this stage

Group / teacher / course CRUD (an admin stage — groups come from the dev seed), parent–child relations & the parent dashboard, quiz engine, code execution / sandboxing, AI review, certificates, payments, notifications, file storage (MinIO). Student code is stored, never run. **One current submission** per assignment: a resubmission overwrites it and clears the prior review — no per-attempt history. A `failed` verdict does not roll back a completed lesson (the UI flags "needs revision"). Refresh-token cleanup scheduling and login rate limiting remain future hardening. Deferred to later stages — see `backend/README.md`'s own scope note.

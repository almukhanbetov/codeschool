# CODESCHOOL — Next.js Frontend

Next.js (App Router + TypeScript) port of the approved `frontend-prototype/` (plain HTML/CSS/JS) design. Visual fidelity was the primary goal — this is the same landing page, componentized, typed, and ready for the next stage: a Go (Gin) + PostgreSQL backend.

## Installation

```bash
npm install
```

## Scripts

```bash
npm run dev     # start the dev server at http://localhost:3000
npm run build   # production build (also runs the TypeScript check)
npm run start   # serve the production build
npm run lint    # ESLint (react-hooks, Next.js rules)
```

## Environment

Copy `.env.example` to `.env.local` if you want to point at a running backend later:

```bash
cp .env.example .env.local
```

```
NEXT_PUBLIC_API_URL=http://localhost:8080/api/v1          # server-side fetches (courses, ...)
NEXT_PUBLIC_BROWSER_API_URL=http://localhost:8080/api/v1  # browser-side fetches (auth)
```

Catalog data is fetched **server-side**, so under Docker `NEXT_PUBLIC_API_URL` is the internal `http://backend:8080/api/v1`. Auth calls run **in the browser** (so the HttpOnly refresh cookie works), so `NEXT_PUBLIC_BROWSER_API_URL` must be reachable from the user's machine (`http://localhost:8080/api/v1`). For a local `npm run dev` the two are the same and `NEXT_PUBLIC_BROWSER_API_URL` can be omitted (it falls back to `NEXT_PUBLIC_API_URL`).

## Project structure

```
frontend/
├── app/
│   ├── layout.tsx        # <html>/<body>, fonts, theme-flash script, Header/Footer
│   ├── page.tsx           # Home page — composes the section components in order
│   ├── globals.css        # Full design system, ported from styles.css
│   ├── login/page.tsx      # Placeholder routes (visual only, no backend)
│   ├── register/page.tsx
│   ├── courses/page.tsx
│   └── teacher/page.tsx
│
├── components/
│   ├── layout/            # Header, Footer, MobileMenu, Providers
│   ├── sections/           # One component per landing-page section
│   └── ui/                 # Button, cards, SectionHeading, LanguageSwitcher, ThemeToggle, ...
│
├── data/                   # Static content as typed arrays/objects (courses, directions,
│                            # projects, learning path, translations, ...) — the shape a
│                            # future `GET /api/v1/courses` etc. would fill in.
│
├── hooks/                  # useLanguage, useTheme, useReveal, useHeaderScroll
├── lib/                    # icons.tsx (lucide-react registry), api.ts (fetch placeholder)
├── types/                  # Language, Theme, Translations, and all data-item types
└── public/
```

## Language switching (KZ / RU / EN)

- `data/translations.ts` holds the full `Translations` object per `Language` (`"ru" | "kz" | "en"`), typed against `types/index.ts` — no `any`.
- `hooks/useLanguage.tsx` is a small React Context provider. `useLanguage()` returns `{ lang, t, setLang }`; `t` is the whole translation tree for the current language.
- The default render is always Russian (matching the server-rendered HTML); the saved `localStorage` preference (key `codeschool-lang`) is applied in a `useEffect` right after mount, so hydration never mismatches. Switching languages does not reload the page.

## Theme (Dark / Light)

- Same token system as the prototype: CSS variables on `:root` (dark, default) and `:root[data-theme="light"]` in `globals.css`.
- Flash-of-wrong-theme is prevented the way [Next.js's own guide](https://nextjs.org/docs/app/guides/preventing-flash-before-hydration) recommends: a tiny inline `<script>` in `app/layout.tsx`'s `<head>` reads `localStorage` and sets `data-theme` on `<html>` before first paint — before React or hydration are even involved. `hooks/useTheme.tsx` then syncs React state to match (via `useLayoutEffect`, so it also survives React Strict Mode's dev-only remount) purely for the toggle button's `aria-pressed`.

## Component architecture

- **Server Components by default**: `app/layout.tsx` and `app/page.tsx` do no client-side work themselves — they just assemble Client Components.
- **`"use client"` where it's earned**: `LanguageSwitcher`, `ThemeToggle`, `MobileMenu`, `CourseFilter`, `AnimatedCounter` are the components the spec called out, and they are Client Components for concrete browser-API reasons (localStorage, IntersectionObserver, click state).
- One honest deviation from "server components everywhere": because language switching has to update visible text instantly with no page reload and no per-locale routing (`/ru`, `/en`, ...), the section components that render translated copy (`HeroSection`, `CoursesSection`, etc.) are Client Components too — there's no way to keep them server-only and still have `useLanguage()` update their text without a reload. Each section is still its own small, focused component (never one giant page-sized Client Component), and cross-cutting browser behavior (scroll-reveal, header shadow) lives in dedicated hooks (`useReveal`, `useHeaderScroll`) rather than being duplicated inline. The public site is route-based — navigation links to real pages (`/courses`, `/programming`, …), not homepage hash anchors.

## Data-driven sections

Repeated card UIs are driven by typed arrays in `data/`, not hand-copied markup:

- `data/directions.ts` → `DirectionCard` (6 cards)
- `data/courses.ts` → `CourseCard`, filtered client-side by `CoursesSection`'s `activeFilter` state
- `data/projects.ts` → `ProjectCard`
- `data/learningPath.ts` → the 6-stage timeline
- `data/teacherSteps.ts`, `data/whyUs.ts`, `data/childrenExamples.ts`, `data/stats.ts`, `data/nav.ts`

These are exactly the shapes a future `GET /api/v1/courses`, `/api/v1/projects`, etc. would replace.

## Icons

Migrated from the prototype's Lucide CDN build to `lucide-react`, resolved through a small name→component registry in `lib/icons.tsx` (so data files can reference an icon by string, e.g. `"rocket"`, without importing React components into plain data).

One necessary substitution: `lucide-react` no longer ships branded logo icons (Instagram/YouTube/LinkedIn were removed from the library for trademark reasons). The footer's social links use the closest generic equivalents (`Camera`, `PlayCircle`, `Link2`) — noted in `lib/icons.tsx`.

## Authentication

- **`hooks/useAuth.tsx`** — `AuthProvider` (mounted in `components/layout/Providers.tsx`) + `useAuth()` → `{ user, accessToken, loading, login, register, logout, refreshSession }`.
- **Token storage**: the access token is held in React state only (never persisted). The refresh token is an HttpOnly cookie the backend sets — page JS never sees it, and it is never put in `localStorage`.
- **Session restore**: on load, `AuthProvider` calls `/auth/refresh` (cookie) then `/me`; a timer re-refreshes ~45s before the access token expires.
- **`lib/api.ts`** gained `login`, `register`, `refresh`, `logout`, `getMe` — browser-side (`credentials: "include"`), plus `setAccessToken()` which `AuthProvider` keeps in sync so `getMe()` sends `Authorization: Bearer …`.
- **`/login`, `/register`** — the approved `.placeholder-*` design, now wired to the API: inline errors (no `alert()`), submit disabled while pending, a translated role `<select>` (Student/Teacher/Parent — API values stay lowercase; no Admin option). Register does **not** auto-login; it redirects to `/login`.
- **Role redirect** after login: `student → /student`, `teacher → /teacher`, `parent → /parent`, `admin → /admin` (`types/index.ts` → `ROLE_HOME`).
- **`components/auth/RequireAuth.tsx`** guards `/student`, `/parent`, `/admin` (client-side, UX only — the backend is the real boundary). `/teacher` stays public and adds a personal-cabinet card for signed-in teachers.
- **Header / MobileMenu** — unchanged visually; the "Log in" button becomes the user's first name + a "Log out" action when authenticated.

## Student learning flow

- **`lib/api.ts`** — typed `enrollCourse`, `getMyCourses`, `getMyProgress`, `getCourseProgress`, `startLesson`, `completeLesson`, `getLessonAssignments`, `getMySubmission`, `saveSubmissionDraft`, `submitAssignment`. A protected call that `401`s refreshes the access token via the cookie and retries once (`setTokenRefresher`, registered by `AuthProvider`).
- **`/student`** (`components/student/StudentDashboard.tsx`) — greeting, overall progress bar, "My courses" cards each with a progress bar + "Continue", empty state → "Browse courses".
- **`/student/courses`** — the full grid.
- **`/learn/[courseId]`** (`components/learn/CourseLearnView.tsx`) — progress + module/lesson list with per-lesson status, "Continue" to the first unfinished lesson.
- **`/learn/[courseId]/lesson/[lessonId]`** (`components/learn/LessonLearnView.tsx`) — sticky lesson sidebar, lesson content, one `AssignmentPanel` per assignment (textarea; monospace for `code` — no Monaco), Save-draft / Send-to-teacher, "Complete lesson" (disabled until every assignment is submitted). One controlled `POST /lessons/:id/start` on open.
- **`/courses/[slug]`** — unchanged design + one auth-aware CTA (Log in to start / Start learning → enrol / Continue learning).
- After a review, `AssignmentPanel` shows the teacher's verdict: `passed` → `✓ Passed 8 / 10` + feedback (locked); `failed` → feedback + editable fields again ("Save draft" / "Send to teacher" — a resubmission).
- All `/student*` and `/learn/*` app routes are wrapped in `RequireAuth roles={["student"]}` — a UX guard; the backend is the real boundary.

## Teacher flow

- **`lib/api.ts`** — typed `getTeacherDashboard`, `getTeacherGroups`, `getTeacherGroup`, `getTeacherGroupStudents`, `getTeacherStudent`, `getTeacherSubmissions` (paginated — `browserFetchRaw` keeps the `{data, meta}` envelope), `getTeacherSubmission`, `startSubmissionReview`, `reviewSubmission`. Same 401-refresh-retry.
- **`/teacher`** (`components/sections/TeacherView.tsx`) — public Teacher Academy page for visitors; **real dashboard** (`components/teacher/TeacherDashboard.tsx`) for a signed-in teacher: 4 stat cards + group cards.
- **`/teacher/groups`**, **`/teacher/groups/[id]`**, **`/teacher/groups/[id]/students/[studentId]`** — `TeacherGroups`, `TeacherGroupDetail`, `TeacherStudentDetail`. Tables collapse to stacked cards below 720px (`data-label` + CSS).
- **`/teacher/submissions`** (`TeacherSubmissions`) — status tabs + pagination; the `?status=` from the dashboard's "pending" card is the initial tab.
- **`/teacher/submissions/[id]`** (`TeacherReview`) — two-column assignment/answer view (monospace for `code`), score + feedback + Pass / Needs-work. One `start-review` on open; `failed` requires feedback (inline error).
- All `/teacher/*` routes wrapped in `RequireAuth roles={["teacher"]}`.

## Parent flow (read-only)

- **`lib/api.ts`** — typed `getParentChildren`, `getParentChild`, `getParentChildCourse`, `getParentChildActivity`. All `GET`; same 401-refresh-retry.
- **`/parent`** (`components/parent/ParentDashboard.tsx`) — no longer a placeholder: a read-only-view note + a card per linked child (progress bar + `in review` / `needs work` badges).
- **`/parent/children/[id]`** (`ParentChildDetail`) — course cards (→ course detail) + a colour-coded recent-activity timeline (`ParentActivityItem`).
- **`/parent/children/[id]/courses/[courseId]`** (`ParentChildCourse`) — lesson progress list + an assignment panel each, showing the submission badge and the teacher's feedback in a pass/fail-coloured `review-result` callout.
- All `/parent/*` routes wrapped in `RequireAuth roles={["parent"]}`.

## Admin panel

- **`lib/api.ts`** — `adminApi`: `overview`, `audit`, `users` (+`setPassword`), `parentLinks`, `groups` + `groupStudents`, and `programs`/`levels`/`courses`/`modules`/`lessons`/`assignments` built from an `adminCrud<Row>` factory (`list` / `get` / `create` / `update` / `remove`).
- **`components/admin/`** — `AdminShell` (section nav), `AdminOverview`, `AdminUsers`, `AdminCatalog` (breadcrumb hierarchy), `AdminGroups` (+ student-manager dialog), `AdminLinks`, `AdminAudit`, and the reusable **`EntityManager<Row>`** (field-def-driven table + inline create/edit form + delete-with-confirm; `select` fields can be `numeric` for id references, `createOnly` for passwords, `extraAction` for drill-down).
- **`/admin`**, **`/admin/users`**, **`/admin/catalog`**, **`/admin/groups`**, **`/admin/links`**, **`/admin/audit`** — each `RequireAuth roles={["admin"]}` + `AdminShell`.
- New strings live under `data/translations.ts` → `admin`, RU + KZ + EN. Only a `.admin-*` block was appended to `globals.css`; existing `.teacher-table` / `.btn` / form tokens are reused. No existing page or component was restyled.

## Quiz engine

- **`lib/api.ts`** — student calls `startQuizAttempt` / `getQuizAttempts` / `submitQuizAttempt` / `getQuizAttempt` (+ `getTeacherQuizAttempt`), and `adminApi.quiz` (`get`, `updateSettings`, `create/update/deleteQuestion`, `create/update/deleteOption`). Same browser client + 401-refresh-retry — no second fetch layer.
- **`components/learn/QuizRunner.tsx`** + route **`/learn/[courseId]/lesson/[lessonId]/quiz/[assignmentId]`** — one question per screen (radio for single-choice / true-false, checkboxes for multiple-choice), Back / Next / Finish, then a pass/fail banner + a per-question review (your answer vs. correct answer + explanation, both gated by the quiz settings) and a **Try again** CTA while attempts remain. Answers live in React state, sent only on submit.
- **`components/learn/AssignmentPanel.tsx`** — a `quiz` assignment now renders a summary card (best %, attempts, pass threshold, "passed" badge) with a **Start / Continue / Retake** link instead of a textarea; it reports the pass state up so the lesson-completion gate reflects it.
- **`components/admin/AdminQuizEditor.tsx`** — a dialog opened from the catalog's assignment table (**Configure quiz** on `quiz` rows, via `EntityManager`'s new `rowExtra` prop): settings form + questions list with inline option toggles, a per-question "misconfigured" warning, and single-choice / true-false correct-option limits enforced client-side too.
- **Teacher** `TeacherStudentDetail` gains a read-only **Quiz results** table; **Parent** `ParentChildCourse` shows the same roll-up for quiz assignments.
- New strings: `data/translations.ts` → `quiz` (learner-facing) and additions to `admin` / `teach`, RU + KZ + EN. Only a `.quiz-*` block was appended to `globals.css`. Dark/Light and the design system are untouched.

## Code editor (Monaco)

- **`@monaco-editor/react`** (added this stage) — `components/learn/CodeEditor.tsx` wraps it: a controlled `value`/`onChange` string editor with `language` (`python` / `javascript` / `go` / `plaintext`, from `assignments.language`), `readOnly`, and theme synced to `useTheme()` (`vs-dark` / `light`). Monaco itself is loaded from a CDN by `@monaco-editor/loader` at runtime.
- **Two graceful degradations** (spec: mobile fallback, no execution): on a coarse pointer / viewport `< 720px`, or if `loader.init()` rejects (offline, CDN blocked), it renders the existing `.assignment-code` `<textarea>` instead — same value, same submit flow.
- **`components/learn/AssignmentPanel.tsx`** — a `code` assignment now uses `CodeEditor` instead of the textarea, plus a **Reset to starter** link (visible only while editable, when the assignment has `starterCode`). `text` / `project` keep the plain textarea. Read-only kicks in exactly as before (`submitted` / `checking` / `passed`), editable again on `failed`.
- **`components/teacher/TeacherReview.tsx`** — the student's code is shown in a read-only `CodeEditor` with the assignment's language; the student's text answer stays a `<pre>`.
- **`components/admin/AdminCatalog.tsx`** — the assignment form/table gain a `language` select + column (empty = cleared to NULL).
- New strings under `learn` (`resetToStarter`, `editorLoading`, `editorMobileNote`, `editorLanguage`, `editorReadOnly`) and `admin.fLanguage`, RU + KZ + EN. Only a `.code-editor-*` block was appended to `globals.css`.
- **`next.config.ts` is unchanged** — `@monaco-editor/react` is a normal client dependency and works with `output: "standalone"`.

## Code runner

No new dependency this stage. Execution happens in a backend-side sandboxed service; the browser only ever calls the backend.

- **`lib/api.ts`** — `runCode`, `getCodeRuns`, `getAssignmentTests`, `submitCodeForGrading`, and `adminApi.tests` (I/O test-case CRUD). Same browser client + 401-refresh-retry.
- **`components/learn/CodeAssignmentPanel.tsx`** — `AssignmentPanel` now delegates `code` assignments here (quiz → `QuizAssignmentPanel`, text/project → `TextAssignmentPanel`). It has the Monaco editor + **▶ Run** + an **output pane** (`stdout` / `stderr` / `exit code` / `duration` with *timed out* / *truncated* badges), a collapsible **stdin** box, a **sample tests** `<details>` list (each row has its own ▶ Run that pre-fills stdin), and a **run history** `<details>` list. **Submit** auto-routes: `hasTests` → `submitCodeForGrading` + a per-test result panel (hidden tests show only ✓/✗; failed visible tests show expected vs. got + stderr); otherwise the normal teacher-review submit. `503` → a "runner unavailable" message; `409` → "too fast".
- **`components/admin/AdminTestsEditor.tsx`** — opened from the catalog's **Tests** action on `code` assignment rows (`EntityManager` `rowExtra`): a flat list of test cases with name / stdin / expected / hidden / weight / position, add / edit / delete.
- New strings: `data/translations.ts` → `learn` (run / output / tests / grading) and `admin` (test editor), RU + KZ + EN. Only a `.runner-*` block was appended to `globals.css`.

## Teacher Academy

No new dependency. The academy reuses the LMS learning UI rather than forking it.

- **Generalised (not copied) learning components** — `CourseLearnView`, `LessonLearnView`, `AssignmentPanel` (+ `QuizAssignmentPanel` / `CodeAssignmentPanel` / `TextAssignmentPanel`) and `QuizRunner` gained optional `apiPrefix` / `basePath` props (defaults `""` / `/learn` = unchanged student behaviour). `lib/api.ts` — the ~15 learn functions gained an optional trailing `prefix`; new `getTeacherAcademyCourses`, `enrollTeacherAcademyCourse`, `getMyAcademyCourses`, `getAcademyDashboard`, `getAcademyCourseContent`, and `adminAcademyApi` (learners / submissions / review).
- **`components/academy/`** — `AcademyLanding` (public hero + 7 track cards + benefits), `AcademyDashboard` ("Моё обучение": in-progress / completed / overall %, per-course progress + continue), `AcademyCourses` (catalog + enroll).
- **`components/admin/AdminAcademy.tsx`** — new `AdminShell` section (`/admin/academy`): learner-teacher table + methodology/project review queue with an inline pass/fail + score + feedback dialog. The catalog course form gains an **audience** `<select>` (`student` / `teacher` / `both`).
- **Routes** — `app/teacher-academy/{page, dashboard, courses}` + `app/teacher-academy/learn/[courseId]/…` (mirrors `app/learn/…`, passing `apiPrefix="/teacher-academy"`) + `app/admin/academy`. The Footer's "Teacher Academy" link now points to `/teacher-academy`; `/teacher` (operational dashboard) is unchanged apart from a cross-link.
- New `academy` translation block (RU + KZ + EN) + `admin.navAcademy`. Only an `.academy-*` block was appended to `globals.css`; Dark/Light and the design system are untouched.

## Placeholder routes

`/courses` uses the same `.placeholder-*` visual language as the rest of the site.

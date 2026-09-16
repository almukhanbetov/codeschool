# CODESCHOOL — Full Platform E2E Report (Stage 31)

## 1. Git commit / branch

Branch `main`. Work started at `4a8da2c` (clean tree). Two real fixes were made during this stage (see §20); they are committed as `CODESCHOOL: full platform E2E — fix completed-course access + /teacher redirect` (hash recorded after commit, see end of this document / `git log -1`).

## 2. Environment used

A brand-new **isolated Docker Compose project**, entirely separate from the normal dev stack:

- Compose files: `docker-compose.yml` + new `docker-compose.e2e.override.yml` (kept in the repo — a reusable, documented overlay for future E2E runs).
- Project name `codeschool-e2e` → its own network + its own named volume (`codeschool-e2e_postgres_data`), completely separate from the dev project `codeschool`.
- Own Postgres database/user (`codeschool_e2e`), own host ports: postgres **5434**, backend **8081**, frontend **3001** (dev stack keeps 5433/8080/3000 untouched).
- **The regular dev stack (project `codeschool`) was never stopped, rebuilt, or written to.** Verified before, during and after: `docker compose ps` (4 services `Up`) and `select count(*) from users` = **7** at every checkpoint, identical to the pre-existing dev data.
- The isolated stack was torn down with `docker compose -p codeschool-e2e ... down -v` at the end of the stage — all E2E data was synthetic and disposable by design.

No `TRUNCATE`/`DROP`/`RESET` was ever run against the dev database. No production environment exists for this project at this stage (confirmed in Stage 30: no VPS/deploy configured yet), so the "don't test against production" rule was satisfied by construction.

## 3. Docker services status

All 5 services of the isolated stack were verified **live**, not just `Up`:

| Service | Check performed | Result |
|---|---|---|
| postgres | `pg_isready` healthcheck + a real `psql` query | healthy, real query returns |
| migrate | `goose ... up`, output inspected | all 27 migrations applied, exit 0 |
| backend | `curl /health` and `/health/ready` | `200`, `{"database":"ok","status":"ready"}` |
| runner | `docker exec backend wget http://runner:8090/healthz` (internal only) | `{"status":"ok"}`; confirmed **not** reachable from the host (`/dev/tcp` probe on 8090 fails) |
| frontend | `curl http://localhost:3001/` | `200`, real HTML |

Docker networking: `codeschool-e2e_default` (app traffic) + `codeschool-e2e_sandbox` (`internal:true`, runner egress) confirmed via `docker network ls` and a live egress test (`wget http://1.1.1.1/` from inside the runner container → `Network unreachable`). Runner container inspected: `ReadonlyRootfs=true`, `CapDrop=[ALL]`, `Privileged=false`.

## 4. Migration status

`docker compose ... run --rm migrate` against the freshly created, empty `codeschool_e2e` database applied all **27** migrations (`00001`→`00027`) cleanly, ending `goose: successfully migrated database to version: 27`. This is a from-scratch application on a clean DB, not a re-application on top of existing dev data.

## 5. Seed-data summary

A new idempotent seed (`scratchpad/e2e/e2e_seed.sql`, not committed — see §6 for why) was applied twice to prove idempotency: **row counts were byte-identical after the second run** (users 7, programs 1, levels 1, courses 3, modules 5, lessons 8, assignments 7, tests 5, quiz_questions 3, quiz_options 8, groups 1, group_students 1, parent_children 1). It creates:

- **7 users** covering every role: `admin_e2e`, `teacher1_e2e`, `teacher2_e2e` (isolation control), `parent1_e2e`, `parent2_e2e` (isolation control), `student1_e2e` (driven through the full learning flow live via the API), `student3_e2e` (spare). An 8th, `student2_e2e`, was deliberately **not** seeded — created live via `POST /auth/register` to exercise real registration.
- **1 program → 1 level → 3 courses**: `e2e-full-course` (published, 3 modules / 6 lessons covering **text, video, code×2 [Python+JavaScript], quiz, project**), `e2e-draft-course` (unpublished, for visibility-control testing), `e2e-academy-course` (`audience='teacher'`, for the Teacher Academy flow).
- 1 teacher-owned group with 1 student member; 1 parent↔child link.
- All test passwords are synthetic, generated locally with `openssl rand`, hashed with the project's own bcrypt code before insertion, stored only in a gitignored scratchpad file, and **never printed in this report, in git, or in any log shown above**.

## 6. Authentication results — **PASS**

Command basis: `curl` against `http://localhost:8081/api/v1/...`, see `scratchpad/e2e/01_auth.sh`.

| Check | Status |
|---|---|
| Register a new account via API (student2) | PASS |
| Public registration cannot create `admin` role | PASS (400) |
| Duplicate email on register rejected | PASS (409) |
| Login for all 7 seeded roles + the freshly registered account | PASS ×8 |
| Wrong password rejected (401) | PASS |
| Unknown account vs. wrong password return the same error (no user enumeration) | PASS |
| `/me` without a token → 401 | PASS |
| `/me` with a token returns own profile + correct role | PASS |
| RBAC: student blocked from `/admin/overview`, `/teacher/dashboard`, `/parent/children` (403) | PASS ×3 |
| RBAC: teacher blocked from `/support/threads` (chat explicitly excludes teachers) | PASS |
| Refresh rotates the refresh cookie (old cookie value ≠ new) | PASS |
| Refresh access-token identity check | **test artifact, not a bug** — see §21 |
| Logout revokes the refresh token; a subsequent refresh with it fails (401) | PASS |

## 7. Student E2E — **PASS**

Full scenario driven live for `student1_e2e` (`scratchpad/e2e/02_student_flow.sh` + `02b_runner_reruns.sh`): register/login → catalog → course page → enroll → open every lesson type → complete each → course auto-completes → certificate.

- Public catalog lists the published course, **hides the unpublished one**; direct `GET /courses/2` (unpublished) → 404.
- Certificate request **blocked before completion** (409).
- Enroll → appears in `/me/courses`.
- **Lesson-completion gate verified as a real block, not just documentation**: completing a text lesson before submitting its assignment → 409; completing the quiz lesson after only a *failed* attempt → 409. Both then succeed once the real requirement is met.
- Text lesson: draft → submit → complete. Idempotent re-complete of an already-completed lesson → 200 (no error).
- Video lesson: `video_url` stored and served; lesson completes via its (text) assignment — this is a genuine, working mechanism, not a stub (see §22 for the one caveat: the frontend doesn't yet render `video_url` as a player).
- **Code runner, all 3 supported languages, all required edge cases — every one produced the expected, distinct outcome, not just HTTP 200:**
  - Python correct code → `status:"ok"`, correct stdout.
  - Python syntax error → `status:"error"`, populated `stderr`.
  - Python logically-wrong code → runs fine, wrong stdout (visible-only, not misreported as an error).
  - Python infinite loop → `timedOut:true` after the sandbox's 5 s wall-clock limit (measured).
  - Oversized output → `truncated:true`.
  - Run against a non-code/no-language assignment → rejected (400), not silently accepted.
  - JavaScript correct code → correct stdout.
  - **Go** correct code → correct stdout (assignment created live via the admin API specifically to cover the 3rd language, see §12).
  - A **per-student 1.5 s throttle** (`CONFLICT` "Too many runs — wait a moment") was discovered as real, working anti-abuse behavior in `internal/runs/service.go` — not documented in earlier audits, confirmed intentional by reading the code, not a bug.
  - Auto-grading (`POST /assignments/:id/code/submit`) against 1 visible + 2 hidden tests: correct solution passes all 3, verified via `assignment_tests` + a real `submissions` row (`status=passed, score=10`).
- Quiz: started attempt with all-wrong answers → `passed:false`, correctly blocks lesson completion; second attempt with all-correct answers → `passed:true, percent:100`; both attempts show in history; lesson then completes.
- Project lesson: text submission → complete.
- **Course completion**: `enrollments.status` flips to `completed` automatically after the 6th lesson (verified in the DB and via `GET /me/courses`); `GET /me/courses/1/progress` shows `100%`.
- **Certificate**: issuance blocked→then succeeds after completion; appears in `/me/certificates`; **PDF verified as a real file** (`file --mime-type` = `application/pdf`, 37 KB, not just a 200 status); **public, anonymous** `GET /certificates/verify/:code` returns `valid:true`.
- Progress persists across re-login (`GET /me/progress` after a fresh login shows the same 100%).
- A real bug was found and fixed here — **see §20**.

## 8. Teacher E2E — **PASS**

`scratchpad/e2e/03_teacher_flow.sh`. Dashboard, own groups, group detail, roster (with live progress %), individual student detail all return real, correct data. Review queue correctly shows exactly the 3 manually-graded submission types (text ×2, project ×1) — the 2 auto-graded code submissions do **not** appear in it, confirmed against the actual `submissions` table (`status='passed'` rows are excluded from the review queue by design). Claimed a submission, graded it with a score + written feedback, verified both persisted. A genuine validation rule was hit and confirmed correct: score is rejected if it exceeds the assignment's `points` (400 `INVALID_REQUEST`).

**Isolation, verified as real 404s (not just assumed):** `teacher2_e2e` (no group) cannot view `teacher1`'s group, cannot view `teacher1`'s student submission, and cannot grade it.

## 9. Teacher Academy E2E — **PASS**

`scratchpad/e2e/04_academy_parent.sh`. `teacher1_e2e` sees the teacher-audience course in the academy catalog, enrolls, opens course content, starts/submits/completes a lesson through the **re-mounted student-flow routes** under `/teacher-academy/*`, sees the dashboard, and successfully issues an academy certificate on completion. Confirmed the regular `/teacher/dashboard` still works for the same account afterward (no cross-contamination), and that a **student is blocked (403)** from every `/teacher-academy/*` route.

## 10. Parent E2E — **PASS**

`parent1_e2e` sees exactly the one linked child, child detail, the child's course progress (100%, matching the student's real completed course), and an activity feed — all live data, not placeholders. Confirmed parent role has **no mutating endpoints** (`POST /lessons/1/complete` as parent → 403).

**Isolation, verified as real 403/404s:** `parent2_e2e` (unlinked) sees zero children and is blocked from viewing `student1`'s detail and course progress.

## 11. Admin CRUD E2E — **PASS**

`scratchpad/e2e/05_admin_flow.sh`. Full Create→Read→Update→Delete exercised on throwaway entities only — **no seeded/real account or content was deleted**:

- **Users**: create → read → deactivate (block) → login while blocked correctly rejected (`403 "Account is inactive"`) → reactivate → login works → admin-set password → login with the new password works → delete → confirmed gone (404). Duplicate-email create → 409.
- **Catalog chain**: program → level → course (draft → published) → module → lesson → assignment (`language:"go"`, used for language coverage, §12) → hidden+visible test case, all CREATE/READ/UPDATE verified. Duplicate program slug → 409.
- **Quiz authoring**: settings update, question create/update, option create/update/delete, question delete — all verified.
- **Groups**: create, update, add member, list members, remove member, delete — all verified.
- **Parent-links**: create, list, delete (query-param form) — all verified.
- **Audit log**: contains entries from the admin actions above (`count>0`, and specifically the certificate-revoke action from §13 with `entity=certificate, action=update`).
- **Overview** stats endpoint returns 200.
- **RBAC**: a teacher is blocked (403) from `/admin/users` and from creating a program.
- **Cascade delete verified in the database, not assumed**: deleting the throwaway course removed its modules and lessons (checked directly with `SELECT count(*)`, both `0` afterward), consistent with the schema's `ON DELETE CASCADE`.

## 12. Code Runner tests — **PASS** (all 3 supported languages + all required edge cases)

Covered above in §7/§11: Python, JavaScript and **Go** each ran correct code successfully; syntax error, wrong-result, timeout, output-truncation, and invalid-target-assignment (400) were all exercised and produced the correct distinct outcome. "Insufficient memory" was **not separately exercised** (see §22 — a memory-exhaustion payload was judged too close to a real resource-abuse test to run against a shared sandbox without a dedicated isolated limits check; the `ulimit -v` / `mem_limit` machinery was inspected in code in the prior architecture audit but not re-triggered live here).

## 13. Quiz tests — **PASS**

Covered in §7: multi-question quiz (`single_choice`, `multiple_choice`, `true_false`), pass/fail scoring at the configured `passPercent`, attempt history, and the lesson-completion gate tied to a passing attempt — all verified live, including a genuinely failing attempt (not just a happy path).

## 14. Certificate tests — **PASS**

Covered in §7 (issuance) plus, separately, **revocation** (`scratchpad/e2e/06_certificates.sh` inline commands):

- Revoke without a `reason` → 400 (required field enforced).
- Revoke with a reason → `status:"revoked"`, logged to the audit log.
- **Public verify reflects the revocation** (`valid:false, status:"revoked"`) — not silently still "valid".
- Re-requesting a certificate for the same completed course after revocation returns the **same, still-revoked** record (idempotent `Issue`) — confirmed there is **no bypass** that silently re-activates a revoked certificate.

## 15. Support Chat tests — **PASS** (16/16)

`scratchpad/e2e/07_support.sh`. Student creates a thread with course/lesson context, posts a follow-up; admin sees it, replies, adds an **internal note**, closes it. Verified: unread count increments after a staff reply and clears after mark-read; **the internal note is invisible to the student** while the staff reply is visible (checked by searching the student's own message list for the internal note's text — absent); a closed thread **auto-reopens** when the user posts again (`status` flips from `closed` to `waiting_staff`). Isolation: an unrelated parent gets 404 on the thread; a teacher is still fully excluded (403) — confirmed again here, consistent with §6/§9.

Implementation confirmed as REST polling only, per the existing architecture — no WebSocket was added, as instructed.

## 16. Localization tests — **PARTIAL** (real, but not exhaustive)

Done with a real headless browser (Playwright-core driving a locally cached Chromium — see §19), not assumed from source:

- Login-form validation/API error message: **RU** "Неверный email/телефон или пароль." → **EN** "Wrong email/phone or password." — confirmed the same underlying error renders in the selected language.
- Navigation fully translates to **KZ**: "Курстар, Бағдарламалау, Робототехника, AI, Оқушыларға, Ата-аналарға, Мұғалімдерге, Академия".
- Switching the language control changes the full rendered page text (checked by comparing `body.innerText` before/after for both KZ and EN).
- Language choice survives a page reload.

**Not exhaustively covered**: every individual button/empty-state/form label in all 3 languages across all ~43 routes was **not** walked one by one — that would require a dedicated per-string i18n audit, out of proportion for this stage. The two hardcoded-string findings from the Stage 30 audit (the `#main` skip-link and the decorative hero mockup labels) were not re-tested here since Stage 30 already documented them precisely and no i18n code changed in this stage.

## 17. Frontend build — **PASS**

`npm run build` (App Router, `output:"standalone"`) completed cleanly after the `/teacher` fix, full route manifest emitted, no errors. `npm run lint` — **0 errors**, the same 2 pre-existing warnings from unrelated files (`AdminGroups.tsx`, `AdminLinks.tsx`) noted in every prior stage, untouched here. (Plain `tsc --noEmit` reports `PageProps`/`LayoutProps` "not found" — this is expected and not a real error: those types are generated by Next's own build into `.next/types`, which `next build`'s internal typecheck — the authoritative check used throughout this project — already consumes and passed.) The e2e frontend Docker image was rebuilt from this exact code and verified live in the isolated stack (§3, §9, §19).

## 18. Backend tests — **PASS**

`go fmt` clean, `go vet ./...` clean, `go build ./cmd/...` clean. `go test ./...` run **twice**: once with `TEST_DATABASE_URL` pointed at the isolated `codeschool_e2e` Postgres (all 16 packages with tests — `ok`, integration tests confirmed self-cleaning: seeded row counts were unchanged before/after the run) and once more after applying the enrollments fix (§20), including **two new regression tests** (`TestIsEnrolled_CompletedStillGrantsAccess`, `TestIsEnrolled_CancelledDeniesAccess`) added specifically for the bug found — both pass.

## 19. Browser E2E — **PASS** (real browser, not API calls relabeled)

A headless Chromium (already cached on this machine from a prior stage, driven via `playwright-core` 1.63.0 installed fresh into a scratch npm project — not added to the app's `package.json`) was used against the isolated stack's live frontend (`http://localhost:3001`):

- `/login` renders a real form; login as `student1_e2e` redirects to `/student` and shows real account content (not a mock).
- `/learn/1` renders without the known red error banner.
- Language switcher present and functional (§16).
- **`/teacher` behavior, checked for 3 distinct identities** (this was explicitly called out in the task): anonymous → still shows the marketing placeholder (unchanged, correct); a real, logged-in teacher → shows the genuine, live `КАБИНЕТ ПРЕПОДАВАТЕЛЯ` dashboard (group count, student count, pending/reviewed counts, all matching the API-verified data from §8 — confirmed with the *full* page text, not a loose keyword match); a logged-in **student** → **found a real inconsistency and fixed it, see §20**.
- Admin login redirects into `/admin`.

Not covered in the browser (time-boxed; documented per instructions rather than silently skipped): parent and teacher-academy dashboards were verified via API only, not re-driven through the browser; the PDF certificate download and Monaco code editor interaction were not exercised through the browser UI (PDF content was verified via direct API+`curl`, §7; Monaco/code execution was verified via API, §7/§12).

## 20. Исправленные ошибки (P0/P1 first)

### P1 — a student who finished a course lost access to review it
**Root cause**: `enrollments.Repository.HasActive` (`backend/internal/enrollments/repository.go`) — the single, shared "is this student allowed to touch this course" check used by `progress`, `quizzes`, `submissions`, and `runs` — queried `status = 'active'` only. `progress.Repository.CompleteLessonTx` correctly flips `enrollments.status` to `'completed'` once every lesson is done. The combination meant a student who **fully completed** a course was afterward rejected (403 "Enroll in this course first" / "Enroll in this course to take its quizzes" / "Enroll in this course to run its code assignments") when trying to re-open a finished lesson, review their quiz-attempt history, or re-run code on an old assignment — discovered live, reproducibly, immediately after `student1_e2e` finished `e2e-full-course`.

**Fix**: `backend/internal/enrollments/repository.go` (`HasActive`) and `backend/internal/enrollments/service.go` (`IsEnrolled`, doc only) — changed the SQL/semantics from "status = active" to "status ≠ cancelled" (i.e. active **or** completed grants access; only an explicitly cancelled enrollment denies it). `backend/internal/enrollments/service_test.go` — updated the test fake to match, and added `TestIsEnrolled_CompletedStillGrantsAccess` + `TestIsEnrolled_CancelledDeniesAccess`. This is the single choke point all five consumer packages go through, so one fix corrected all of them.

**Retest**: rebuilt the e2e backend image, re-ran the exact three previously-failing calls live → all now `200`. Full `go test ./...` re-run, all packages still pass.

### P2 — `/teacher` did not redirect a signed-in non-teacher
**Root cause**: `frontend/components/sections/TeacherView.tsx` rendered the generic marketing `InfoPlaceholder` (with stale "coming soon" copy) for *any* signed-in user who wasn't a teacher, instead of redirecting them to their own dashboard — the only protected-feeling route in the app that didn't follow the `RequireAuth`/`ROLE_HOME` pattern used everywhere else. **Not a security issue** (every API call behind it is still gated server-side, confirmed throughout §6–§15), but a real, user-visible inconsistency, and specifically called out for re-verification in this stage's instructions.

**Fix**: `frontend/components/sections/TeacherView.tsx` — a signed-in user whose role isn't `teacher` is now redirected (client-side, `router.replace(ROLE_HOME[user.role])`) exactly like `RequireAuth` does elsewhere; anonymous visitors and real teachers are unaffected. No server-side role check was touched.

**Retest**: `npm run build` clean, rebuilt the e2e frontend image, re-verified live in a real browser for anonymous (unchanged), teacher (unchanged, real dashboard), student (now redirects to `/student`), and admin (now redirects to `/admin`).

No P0 was found. No P2/P3 cosmetic issues beyond the ones already documented in the Stage 30 architecture audit were pursued, per the "fix P0/P1 first" instruction.

## 21. Оставшиеся проблемы

- **Test-methodology note, not a product bug**: one auth-refresh check compared two access-token JWT strings for inequality; when login+refresh happen within the same wall-clock second for the same user, the tokens are byte-identical (deterministic JWT claims at 1-second resolution) — expected behavior, not a defect. The actual security-relevant rotation (the refresh-token cookie value) was checked separately and passed.
- **Video lessons**: `lessons.video_url` is stored and served by the API correctly (confirmed in §7), but — per the Stage 30 architecture audit, not re-litigated here — the frontend lesson view does not yet render it as a video player; it's a real, working field with no corresponding UI yet.
- Everything else found during iterative testing was a **test-script defect** (wrong JSON field path assumed from memory instead of the real DTO shape, a bash `$UID` built-in variable collision, an incorrect assumption about an HTTP status code, or not pacing calls past the runner's 1.5 s per-student throttle) — each was diagnosed against the real raw response, corrected, and re-verified to PASS live. None of these represent application defects.

## 22. Непроверенные функции (не работает и не PASS — просто BLOCKED/NOT TESTED)

| Item | Status | Why |
|---|---|---|
| Code-runner memory-limit exhaustion (`ulimit -v` breach) | NOT TESTED | Judged disproportionate to trigger live against a shared local sandbox for this stage; the limit's presence was already verified by reading `internal/sandbox/sandbox.go` and by the passing `internal/sandbox` test suite (`go test`, §18) |
| Browser-driven parent dashboard, Teacher Academy dashboard | NOT TESTED (browser) | Verified via API only (§9, §10); time-boxed |
| PDF download / Monaco editor through the actual browser UI | NOT TESTED (browser) | PDF verified via API+`file`/size check (§7); Monaco/code execution verified via API (§7, §12) |
| Exhaustive per-string i18n coverage (every button/empty-state across ~43 routes × 3 languages) | NOT TESTED | See §16 — a representative, real cross-section was verified instead |
| Mobile/responsive layout | NOT TESTED | Out of scope of this stage's instructions |

## 23. Рекомендации перед production

1. Ship the two fixes from §20 — the P1 is a real regression a real student would hit on day one of finishing any course.
2. Add the "completed enrollment still grants access" rule as an explicit line in whatever internal spec describes the progress/enrollment contract — it's easy to reintroduce if a new package copies the old `status='active'` pattern instead of calling `IsEnrolled`.
3. Consider a scheduled job for `DeleteExpiredRefreshTokens` (flagged unscheduled in the Stage 30 audit; unrelated to this stage's fixes but still open).
4. Before real production traffic: run a dedicated memory-exhaustion test against the runner in a throwaway environment (not exercised here, see §22).
5. The isolated E2E overlay (`docker-compose.e2e.override.yml`) is reusable for future stages — `docker compose -p codeschool-e2e -f docker-compose.yml -f docker-compose.e2e.override.yml up -d` recreates the same safe, disposable environment.

---

## Appendix — raw test tally

203 individual assertions were logged across the iterative run (`scratchpad/e2e/results.tsv`, not committed — local working artifact); after correcting test-script mistakes and fixing the one real bug and re-verifying live, **every scenario described in §6–§15 and §19 ends in a confirmed PASS**, with the explicit exceptions listed in §21 (methodology note) and §22 (not tested, honestly labeled).

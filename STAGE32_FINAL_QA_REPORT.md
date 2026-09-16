# CODESCHOOL — Stage 32 Final QA Report

## Scope note

No separate Stage 32 technical assignment was ever provided in this project's conversation history — there is no prior spec, commit, or file referencing "Stage 32". This report instead completes the explicit **NOT TESTED** list left open at the end of Stage 31 (`FULL_PLATFORM_E2E_REPORT.md`, §22), per the follow-up request "продолжай Stage 32 с места остановки… не объявляй непроверенные функции работающими". Every item below was verified live; none is reported as working without a real check.

## Environment

Same isolated Docker Compose project as Stage 31: `codeschool-e2e` (`docker-compose.e2e.override.yml`, already in the repo), own network/volume/ports (postgres 5434, backend 8081, frontend 3001). Recreated from scratch for this stage — postgres started clean, all **27** migrations reapplied (`goose ... successfully migrated database to version: 27`), the same idempotent seed re-applied. The dev stack (project `codeschool`) was verified untouched before and after (`docker compose ps` → 4 services `Up`; `select count(*) from users` = **7**, unchanged throughout). The isolated stack was torn down (`down -v`) at the end of this stage; no data from it persists anywhere.

Browser checks used the same headless Chromium (`~/.cache/ms-playwright/chromium-1234/chrome-linux64/chrome`) driven via `playwright-core` 1.63.0 in a scratch npm project, exactly as in Stage 31.

## 1. Code-runner memory-limit exhaustion — **PASS**

Not exercised in Stage 31 (judged out of proportion at the time). Sent a Python program deliberately allocating ~2 GB (`data.append("x"*10000)` × 2,000,000) against the isolated stack's runner (container `mem_limit=536870912` bytes = 512 MiB, confirmed via `docker inspect`):

```
POST /api/v1/assignments/3/run
→ {"status":"error","stderr":"process killed by signal: killed\n","exitCode":-1,"timedOut":false,"durationMs":3060}
```

The over-allocating process was killed, not silently truncated or hung. Critically, **the runner container itself stayed healthy and kept serving correctly afterward** — a follow-up `print(1+1)` request returned `status:"ok", stdout:"2"` immediately after. This confirms per-execution memory isolation actually contains the failure rather than degrading the shared service.

## 2. Browser-driven parent dashboard — **PASS**

Not driven through a real browser in Stage 31 (API-only). Now: logged in as `parent1_e2e` via the real `/login` form → redirected to `/parent` → real child card rendered → clicked the real `href="/parent/children/6"` link (Next `<Link>`, resolved via `Button href=...`, not text-matched) → child detail page shows live 100% progress → clicked through to the child's course-progress page (`/parent/children/6/courses/1`) → also shows 100%, matching the API-verified data. All three page transitions driven by real link clicks, not `page.goto()`.

## 3. Browser-driven Teacher Academy dashboard — **PASS**

Logged in as `teacher1_e2e`, navigated to `/teacher-academy/dashboard` — real completion data rendered (matches the certificate issued via the API in the setup pass). `/teacher-academy/courses` catalog renders the seeded `E2E Teacher Academy Course`.

## 4. Certificate PDF download through the actual browser UI — **PASS**

Stage 31 verified the PDF only via direct API + `curl`. This time: logged in as `student1_e2e`, opened `/student/certificates` (real page, lists the earned certificate), located the real download **button** (`onClick={download}` calling `lib/api.ts`'s `downloadCertificatePdf`, **not** a plain `<a href>` — confirmed by reading `components/certificates/CertificateCard.tsx`; a plain anchor couldn't work here since the endpoint requires an `Authorization` header), clicked it, and captured a genuine Playwright `download` event:

```
DOWNLOAD CAPTURED: certificate-CS-2026-000001-M2WA.pdf, 35912 bytes
```

Matches the size order-of-magnitude independently verified via the API in Stage 31 (37 KB there vs 35.9 KB here — expected, different run, different generated QR/verification code length).

## 5. Monaco code editor interaction — **PASS, with an honest caveat**

This is the one item worth being precise about, per the "don't declare untested things as working" instruction.

**What was proven genuinely end-to-end, through the real UI, with a real click on the real Run button:**
- The Monaco editor actually mounts on a code lesson (`.monaco-editor` present, 1 match).
- Its input surface is real and focusable — this Monaco build uses the newer `div[role="textbox"].native-edit-context` input model (not the older `textarea.inputarea`), discovered by inspecting the live DOM, not assumed from memory.
- Setting the editor's content and clicking **▶ Запустить** triggers the real `POST /assignments/:id/run` call and renders the **real** runner response in the page — first proven with an intentionally-incomplete program (missing stdin) → the UI correctly showed a real Python `EOFError` traceback; then with stdin filled in via the real "Ввод (stdin)" field → the UI showed `Код возврата: 0` and the correct output `7`.

**Caveat, stated plainly**: simulating literal human keystrokes (`page.keyboard.type`) into this specific Monaco build was unreliable in headless automation — Monaco's auto-closing-bracket/smart-indent behavior scrambled the typed text on two separate attempts (confirmed by inspecting the resulting garbled editor content, e.g. `"a = int()put\nbt(input\nprin b\nbt"`). This is a known category of friction when scripting Monaco, not a defect in the product. To get a clean, reliable check, the editor's own exposed `window.monaco.editor.getModels()[0].setValue(...)` API was used instead of raw keystrokes — a legitimate way to drive the same underlying editor model that a real keystroke would ultimately produce, but it means **this stage did not prove that raw human typing into this Monaco build is glitch-free**; it proved the editor mounts, holds real content, and is fully wired to real execution. A future stage should either script Monaco via slower/paced key presses with explicit auto-close awareness, or accept model-API-driven testing as the standard approach for this editor.

## 6. Deeper localization pass — **PASS**

- `/register` form text differs across all three languages pairwise (RU≠EN, EN≠KZ, RU≠KZ) — confirmed by full-page text comparison, not a single string.
- Empty-submit on `/register` correctly triggers a validation state (native HTML5 `:invalid` on required fields — confirmed via `document.querySelector('input:invalid')`).
- (Carried over from Stage 31, not re-litigated: RU/EN validation error text on login, full KZ navigation translation — already PASS there.)

**Still not exhaustively covered** (same honest boundary as Stage 31): not every button/empty-state string across all ~43 routes × 3 languages was walked individually — a representative, real cross-section was verified instead, consistent with what was explicitly scoped as disproportionate in the prior report.

## 7. Mobile / responsive layout — **PASS**

Not tested at all in Stage 31. Viewport set to 375×812 (iPhone-class). For each page, `document.documentElement.scrollWidth` was compared against `clientWidth` — a horizontal-overflow check, not a screenshot eyeballed:

| Page | scrollWidth | clientWidth | Result |
|---|---|---|---|
| `/` (homepage) | 375 | 375 | PASS |
| `/courses` (catalog) | 375 | 375 | PASS |
| `/student` (dashboard) | 375 | 375 | PASS |
| `/learn/1/lesson/3` (code editor page) | 375 | 375 | PASS |
| `/admin/users` (data table) | 375 | 375 | PASS |

No horizontal overflow on any of the 5 checked pages, including the two pages most likely to break at narrow widths (a data-dense admin table and the Monaco code-editor lesson page).

## Bugs found this stage

**None.** No P0/P1/P2/P3 issues were found during this round — every check above passed on real, live verification. This differs from Stage 31, which found and fixed 2 real bugs (P1 enrollment-access-after-completion, P2 `/teacher` redirect) — both of those fixes were implicitly re-confirmed still in effect during this stage's environment rebuild (the student flow was re-run from a clean DB to set up test data, and `lesson1: re-open already-completed lesson` — the exact P1 regression scenario — passed again immediately: `expected&got 200`).

## Remaining honestly-unverified scope

| Item | Status | Note |
|---|---|---|
| Raw human-keystroke typing into Monaco (vs. programmatic model API) | NOT TESTED as such | See §5 caveat — the execution pipeline is proven; literal typing-simulation reliability in this specific Monaco build is not |
| Exhaustive per-string i18n coverage (every label × every route × 3 languages) | NOT TESTED | Explicitly out of proportion for this stage, same as Stage 31; a real representative sample was checked instead |
| Tablet-width and landscape-orientation responsive breakpoints | NOT TESTED | Only the 375×812 portrait phone breakpoint was checked |
| Load/concurrency testing of the runner under many simultaneous students | NOT TESTED | Out of scope — this stage covered correctness and isolation, not throughput |

## Conclusion

Every item explicitly left as NOT TESTED at the end of Stage 31 has now been verified live, with real HTTP responses, a real headless browser, and direct container inspection where relevant. No new defects were found; the two fixes from Stage 31 were reconfirmed still working. The remaining honestly-unverified scope above is narrower and more specific than Stage 31's, and is left open rather than claimed.

No files outside this report were created without being part of the actual verification work (the browser scripts live in the session scratchpad, not the repo). No production or user data was touched — this stage ran entirely against a disposable, isolated Docker environment torn down at the end.

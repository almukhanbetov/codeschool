# CODESCHOOL — Stage 33 Readiness Report

Video player, Monaco keyboard-typing verification, responsive audit at 5 widths, regression suite.

## Environment

Same isolated Docker Compose project as Stages 31–32: `codeschool-e2e` (`docker-compose.e2e.override.yml`), own network/volume/ports (postgres 5434, backend 8081, frontend 3001). Rebuilt from a clean, freshly-migrated database, seeded with the same idempotent multi-role dataset. The dev stack (project `codeschool`) was verified untouched before and after (`docker compose ps` → 4 services `Up`; `select count(*) from users` = **7**, unchanged). The isolated stack was torn down (`down -v`) at the end. No production/user data was touched anywhere in this stage.

## 1. Video lessons

**Before**: `LessonLearnView.tsx` rendered `lesson.videoUrl` as a plain `<a href target="_blank">` showing the raw URL text — no player at all (confirmed missing, exactly as flagged in the Stage 30/31 audits).

**Implemented**: `frontend/components/learn/LessonVideo.tsx` (new component), wired into `LessonLearnView.tsx` in place of the old link.

- Parses the URL with `new URL()` in a `try/catch` — never regex-matches the raw string into markup.
- **Only two shapes are ever embedded**, both allowlisted by design ("безопасное воспроизведение разрешённых видео"):
  - a direct `https://…` file ending in `.mp4/.webm/.ogg/.ogv/.mov` → a native `<video controls playsInline preload="metadata">` with an `onError` handler;
  - a `youtube.com`/`m.youtube.com`/`youtu.be` or `vimeo.com`/`player.vimeo.com` link, with the video ID extracted from the **parsed** URL (query param or path segment, validated against `^[\w-]{6,20}$` / `^\d{6,15}$`) and rebuilt into a `youtube-nocookie.com`/`player.vimeo.com` embed URL — the raw input string is never interpolated into the `iframe`'s `src`.
- Every other case — unknown host, plain `http:`, `javascript:`/any non-http(s) scheme, an unparsable string — is **never embedded**. A safe fallback message is shown, with a clickable "open" link **only** when the URL itself re-parses to a plain `http:`/`https:` URL (a `javascript:` URL never reaches an `href` at all, independent of React's own javascript-href blocking — verified as a second, explicit line of defense, see the initial-audit finding below).
- No `dangerouslySetInnerHTML` anywhere in the component.
- Responsive: `.learn-video` uses `aspect-ratio: 16/9` and `width: 100%` (new CSS in `frontend/app/globals.css`), so it scales at every viewport without a fixed pixel size.
- Existing lesson-completion mechanism untouched — the video sits in the same `.learn-content` block as before; `lesson.content`, `startLesson`/`completeLesson`, and the assignment-completion gate are unchanged.
- New translation keys (`videoTitle`, `videoLoadError`, `videoUnsupported`, `videoOpenLink`) added to `types/index.ts` (`LearnTranslations`) and all three language blocks in `frontend/data/translations.ts` (ru/kz/en).

### Real-browser verification (12 checks, all PASS)

| Check | Result |
|---|---|
| Direct `https` mp4 renders a native `<video>` | PASS |
| mp4 actually loads (`readyState:4`, `duration:5.055`, no `error`) | PASS |
| `video.play()` genuinely advances `currentTime` (real decoded playback, not a frozen frame) | PASS |
| Native `controls` attribute present | PASS |
| No `<iframe>` used for a file-type video | PASS |
| `youtube.com/watch?v=…` → sandboxed `youtube-nocookie.com/embed/…` iframe | PASS |
| iframe carries a `sandbox` attribute (not unrestricted) | PASS |
| `youtu.be/…` short link resolves to the same embed | PASS |
| Unrecognized host → not embedded, safe outbound link shown instead | PASS |
| Plain `http://` URL → rejected, not embedded | PASS |
| `javascript:alert(1)` → not embedded, **no clickable link at all** (after the fix below) | PASS |
| Unreachable mp4 → real `onError` fires, load-error fallback shown (no blank/broken player) | PASS |
| `<script>` text inside a malformed URL never becomes a DOM script node | PASS |

**One real issue found and fixed during this check** (defense-in-depth, not an exploitable bug by itself — see below): the fallback branch originally passed the **raw, unvalidated** `url` prop straight into `<a href={url}>`. For a `javascript:` URL this relied entirely on React 19's own built-in javascript-href blocking (confirmed it does block it — the click handler throws "React has blocked a javascript: URL as a security precaution"). Rather than depend solely on that framework behavior, `LessonVideo.tsx` now re-parses the URL and only ever sets `href` when the scheme is `http:`/`https:`; anything else renders the fallback message with **no link at all**. Re-verified live: `javascript:alert(1)` now produces zero `<a>` elements in the fallback (previously one, blocked-but-present).

**Test-data note**: the first playback check initially failed against a long-standing "known-good" public test video (`commondatastorage.googleapis.com/.../BigBuckBunny.mp4`) — that specific bucket now returns `403` (Google appears to have restricted it after years of public use). This was a **dead test fixture**, not a player bug — confirmed by fetching the same URL with `curl` outside the browser (also 403) and by immediately re-testing with a different, currently-reachable test video (`interactive-examples.mdn.mozilla.net`), which passed cleanly on every check above.

## 2. Monaco Editor

**Real keyboard-typing scenario, exactly as specified**: opened `/learn/1/lesson/3`, clicked into the live Monaco instance, and typed — character by character with a **60 ms per-key delay** (`page.keyboard.type(ch, {delay:60})`), simulating realistic human typing speed rather than instantaneous scripted input — the three lines `a = int(input())`, `b = int(input())`, `print(a + b)`, **including the closing parentheses a real user types**. Result, read from Monaco's own model (`window.monaco.editor.getModels()[0].getValue()`), was **byte-for-byte identical** to the intended code — Monaco's auto-closing-bracket type-over behavior worked correctly, no duplication or scrambling. Clicked **▶ Запустить** for real, filled real stdin, and got the correct real output (`Код возврата: 0`, stdout `7`) through the actual UI.

**Auto-indent**: typed `for i in range(3):` + Enter + `print(i)` at human pace — Monaco auto-indented the second line by 4 spaces (`"for i in range(3):\n    print(i)"`), correct Python block-indent behavior.

**Reconciling this with the Stage 32 report**, which had flagged an "automation-only" caveat: that report was correct to hedge — the earlier attempts used no per-key delay (synchronous `page.keyboard.type()` on the whole string, or manual `End`-key navigation around auto-inserted closers), which visibly scrambled the text (`"a = int()put\nbt(input\nprin b\nbt"` in one capture). Typing at a realistic pace instead of instantaneously **fixed it completely** — this is now proven, not assumed: the same component, same browser, same build, the only variable changed was keystroke pacing. **No product bug exists in Monaco's editing behavior.** Per the instruction "не считай проблемы автоматизации доказательством ошибки редактора", nothing was changed in `CodeEditor.tsx` or any Monaco configuration.

## 3. Responsive audit — 375 / 390 / 768 / 1280 / 1920 px

Checked with a real headless browser at each exact width (viewport `{width, height:900}`), reading `document.documentElement.scrollWidth` vs `clientWidth` for overflow, real `getBoundingClientRect()` sizes for tap targets, and real `getComputedStyle` for font size — not screenshots eyeballed.

| Page | 375 | 390 | 768 | 1280 | 1920 |
|---|---|---|---|---|---|
| Homepage — no horizontal overflow | PASS | PASS | PASS | PASS | PASS |
| Homepage — body text ≥12px | PASS (16px) | PASS | PASS | PASS | PASS |
| Nav/menu reachable (burger ≤768px, inline links >768px) | PASS | PASS | PASS | PASS | PASS |
| `/courses` catalog — no overflow | PASS | PASS | PASS | PASS | PASS |
| `/student` dashboard — no overflow | PASS | PASS | PASS | PASS | PASS |
| `/student` dashboard — real buttons have a usable (≥24px) tap height | PASS | PASS | PASS | PASS | PASS |
| `/learn/1/lesson/3` (code editor page) — no overflow | PASS | PASS | PASS | PASS | PASS |
| Code editor visible and correct **for that width's design** | see below | see below | PASS (Monaco) | PASS (Monaco) | PASS (Monaco) |
| Run button present, real usable size | PASS | PASS | PASS | PASS | PASS |
| `/admin/users` table — no page-level horizontal overflow | PASS | PASS | PASS | PASS | PASS |

**One apparent failure, investigated and explained — not a bug**: at 375/390px the check first asserted `.monaco-editor` should be visible and got `FAIL`. Reading `frontend/components/learn/CodeEditor.tsx` (lines 43–51) showed this is **deliberate, pre-existing, already-shipped** behavior: below 720px width *or* on a coarse-pointer device, the component renders a plain `<textarea className="assignment-code">` instead of Monaco, with an explanatory note (`t.learn.editorMobileNote`, already translated in all 3 languages). Re-tested against the **correct** expectation: at 375px, Monaco is correctly absent (`monacoCount:0`), the textarea fallback is visible, the note is shown, and — most importantly — **typing real code into the fallback textarea and clicking Run produces the correct real output** (`Код возврата: 0`, stdout `7`), exactly like the desktop path. No fix was needed; the "failure" was the test's wrong assumption, corrected and re-verified.

No responsive defects were found and nothing was changed for §3.

## 4. Regression tests

All run against the isolated environment; no dev/production data touched.

| Check | Result |
|---|---|
| `gofmt -l .` | clean |
| `go vet ./...` | clean |
| `go test ./...` (`TEST_DATABASE_URL` → isolated `codeschool_e2e`) | all 16 packages with tests `ok` (backend untouched this stage — no source changed, ran anyway for a real regression signal, not skipped) |
| `npm run build` | clean, full route manifest, no errors — run **twice**: once before, once after the `javascript:`-href hardening fix |
| `npm run lint` | 0 errors, the same 2 pre-existing warnings in unrelated files (`AdminGroups.tsx`, `AdminLinks.tsx`) noted in every prior stage |
| Browser E2E | the 12 video checks (§1), the Monaco human-typing + auto-indent + real-run checks (§2), and the full 5-width responsive sweep (§3) — all against the real, running, isolated frontend, not simulated |

## 5. Files changed

| File | Change |
|---|---|
| `frontend/components/learn/LessonVideo.tsx` | **New.** Safe, allowlisted video player (YouTube/Vimeo embed or direct file), error handling, no unsafe HTML. |
| `frontend/components/learn/LessonLearnView.tsx` | Replaced the raw video-URL link with `<LessonVideo url={lesson.videoUrl} />`; no other logic touched. |
| `frontend/types/index.ts` | Added `videoTitle`, `videoLoadError`, `videoUnsupported`, `videoOpenLink` to `LearnTranslations`. |
| `frontend/data/translations.ts` | Added the same 4 keys in ru/kz/en. |
| `frontend/app/globals.css` | Added `.learn-video`, `.learn-video-frame`, `.learn-video-error` (responsive 16:9 box + error styling). |

Backend: **no files changed** this stage (no backend defect was found).

## Git commit

Committed as a single Stage 33 commit; see `git log -1` in this repository for the exact hash (not pushed, per standing project convention — push only on explicit request).

## Remaining limitations

- The video player was verified against direct-file and YouTube/Vimeo-style URLs only, since those are the only shapes the allowlist accepts by design. If the future curriculum needs another provider (e.g. a self-hosted HLS/DASH stream), that would need its own allowlist entry and its own real-browser check — not assumed to work today.
- Responsive audit covered 5 specified widths on 4 representative pages (home, catalog, dashboard, code-editor lesson, admin table) in portrait orientation only; landscape orientation and tablet-specific breakpoints between 390–768px were not separately swept (consistent with the Stage 32 report's same honest boundary).
- Monaco's human-typing correctness was proven for standard Python syntax (parens, colons, indentation). More exotic input (pasted multi-line blocks, IME/composition input, extremely fast real typists) was not separately exercised.
- No 504-lesson curriculum content was loaded, per the explicit instruction not to without separate authorization — this stage only touched the lesson-video **rendering mechanism**, not lesson content or the curriculum data model from Stage 30.

# CODESCHOOL — Frontend Prototype

A static, framework-free visual prototype of a modern IT education platform for Kazakhstan (programming, robotics, AI, web/mobile development). Built with plain HTML5, CSS3 and vanilla JavaScript — no build step, no dependencies beyond two CDN resources (Google Fonts, Lucide icons).

This prototype is a design/UX reference only. It will later be rebuilt on Next.js with a Go (Gin) + PostgreSQL backend — nothing here is wired to a real API.

## Running it

Any static file server works, e.g.:

```bash
python3 -m http.server 8080
# then open http://localhost:8080
```

Opening `index.html` directly in a browser also works, since everything is self-contained.

## File structure

```
frontend-prototype/
├── index.html      # Full single-page markup, all sections, data-i18n hooks
├── styles.css      # Design tokens, layout, components, responsive rules
├── script.js       # i18n, theme toggle, filters, animations, nav state
├── assets/         # Reserved for future images/icons (currently empty —
│                    # all visuals are CSS/SVG/icon-font based)
└── README.md
```

## Sections implemented

Header (sticky, floating, blurred) · Hero with floating glass cards · Learning Path timeline · Directions grid (6 tracks) · Courses with age filters · Children/project examples · Student projects gallery · Teacher Academy · AI Tutor chat mockup · Parents dashboard card · LMS dashboard preview · Animated stats · Why Us · Philosophy statement · Final CTA · Footer.

## Interactions (vanilla JS, no frameworks)

- **Language switching** — ҚАЗ / РУС / ENG, persisted in `localStorage` (`codeschool-lang`), default RU. Content is data-driven via `data-i18n="key.path"` attributes and a `translations` object in `script.js`.
- **Theme switching** — Dark (default) / Light, persisted in `localStorage` (`codeschool-theme`). Full color-token system in `styles.css` (`:root` vs `:root[data-theme="light"]`).
- **Course filtering** — age-range tabs filter the course grid client-side, no reload.
- **Mobile navigation** — hamburger menu opens a slide-in drawer with backdrop; collapses below 1220px.
- **Scroll-based nav highlighting**, smooth in-page navigation, scroll-reveal animations (`IntersectionObserver`), animated stat counters — all respect `prefers-reduced-motion`.

## Responsive verification

Manually checked (headless Chrome screenshots at each width) with no horizontal overflow:

- 1920px, 1440px, 1220px, 1080px, 1024px, 768px, 430px, 390px

Notable fixes made during verification:
- Header nav/actions were overflowing between ~1220–1440px — tightened nav spacing and retuned the breakpoints where the login button and full nav appear.
- `body { overflow-x: hidden }` was silently breaking `position: sticky` on the header (any ancestor with non-`visible` overflow disables sticky in all browsers) — switched to `overflow-x: clip`, which prevents horizontal scroll without affecting sticky contexts.
- Scroll-spy nav highlighting could pick the wrong link on initial load — rewritten to compute the active section directly from `getBoundingClientRect()` on every observer callback instead of trusting individual intersection entries.

## Known limitations

- All data (courses, projects, stats, dashboard numbers) is static demo content, not from an API.
- No forms actually submit anywhere ("Войти", course "Подробнее" etc. are placeholder links).
- Kazakh and English translations are functional and complete for all UI strings but have not been reviewed by a native copy editor.
- Assets folder is currently unused — all visuals are CSS gradients, SVG icons (Lucide) and typography; no raster images are referenced.

# Project Research Summary

**Project:** phamhakhanhchi.com — "research notebook" visual redesign
**Domain:** Incremental design-system pass on a Jekyll / al-folio v1.x personal academic portfolio
**Researched:** 2026-09-12 to 2026-09-13
**Confidence:** HIGH

## Executive Summary

This is a CSS-and-content redesign of an existing seven-page academic portfolio, not a rebuild. All four researchers converge on the same mechanical fact, independently verified by reading the installed `al_folio_core` 1.0.15 gem: the gem exposes 29 `--global-*` CSS custom properties that both its prebuilt (frozen) Tailwind CSS and its own Sass read, and `_sass/_custom.scss` — already wired, loaded last, and unlayered — can re-point every one of them and add unlayered rules that beat the entire `@layer`-wrapped Tailwind sheet with no specificity fight. Re-pointing tokens in one file therefore repaints the whole site — navbar, cards, footer, buttons, code blocks — in a single commit, which is what makes an incremental, always-shippable build order possible under deadline pressure. ~95% of the milestone's Active scope (design tokens, paper ground, serif typography with verified Vietnamese coverage, light-theme-only, portrait rendered, per-page component styling, print handling) is achievable from `_sass/_custom.scss` plus `_config.yml` plus page-authored markup, with zero gem-file overrides required.

The recommended approach is the six-step build order from ARCHITECTURE.md — Guardrails, Tokens, Ground/Type, Shared Components, Home, Per-page Polish — because each step, in that order, leaves the site in a **globally consistent, shippable state** (never a half-restyled page), which matters because there is no staging environment and `main` deploys automatically. Recommended stack: Source Serif 4 (body/headings) plus IBM Plex Mono (labels/marginalia), both verified to carry the Google Fonts `vietnamese` subset that the owner's own name (`ạ` in "Phạm") requires and that the obvious "notebook aesthetic" choice (Caveat) silently lacks; CSS-gradient/inline-SVG texture rather than any raster or live filter; and no new runtime JS or build pipeline.

The key risk is not technical, it is behavioral and evidentiary, and PITFALLS.md (written last, with the other three available, and therefore the authority where they conflict) surfaces two categories the others under-weighted. First, the CI/deploy surface has real, already-manifested holes: `deploy.yml`'s push-path filter does not include `_sass/**`, so a pure-SCSS commit triggers no deploy at all; there is no `axe.yml` or Lighthouse gate on this site (both point elsewhere or are `workflow_dispatch`-only); and the custom domain has already broken once from a `CNAME`-less deploy and the fix on `main` is untested. Second, `opacity`-based de-emphasis (already present in `_custom.scss`) compounds against a cream ground in a way that defeats even the "safe" muted colour ARCHITECTURE.md recommends — the fix and the pre-existing bug can silently cancel out. Both must be closed in Phase 1/2, before any visual work, because there is no automated backstop to catch them later. The single highest-stakes non-technical risk is "personality overshoot" — the notebook aesthetic reading as costume rather than substance to the admissions-officer audience — which has no error message and is not recoverable after a reader forms the impression; PITFALLS.md's checkable register markers (font-family count, decorative-mark count, the stylesheet-off test, the outside-reader test) are the mitigation.

## Key Findings

### Recommended Stack

The redesign has no new runtime dependency. `al_folio_core` 1.0.15 is already current (verified against RubyGems); `_sass/_custom.scss` is the entire design surface; three requirements (measure, dark-mode-off, font URL) are `_config.yml` edits rather than CSS. Figure-redraw tooling (`svg2roughjs`, `matplotlib`'s `plt.xkcd()`, Excalidraw) is authoring-time-only and never touches the repo's dependency tree — and, per the scope narrowing below, is not needed for this milestone's Active scope at all.

**Core technologies:**
- `_sass/_custom.scss` (existing seam) — the single design surface; unlayered and loaded last, so it beats the gem's entire prebuilt `@layer`-wrapped Tailwind sheet with no `!important` needed (one exception: the gem's `@layer components` Bootstrap-compat utilities like `.mt-3`, `.w-100`, `.d-none` carry `!important` and cannot be beaten from `_custom.scss` at all — avoid those class names in authored markup instead).
- CSS Custom Properties (the gem's 29 `--global-*` tokens) — the only channel that reaches the frozen, un-recompilable Tailwind CSS; re-pointing them is the highest-leverage single action in the project.
- Source Serif 4 (body + headings, static instances `ital,wght@0,400;0,600;1,400`, ~171 KB paired) — verified Vietnamese subset; drawn for on-screen reading; avoid the `opsz` axis (580 KB for no visible benefit at one size).
- IBM Plex Mono (labels, years, marginalia leaders) — verified Vietnamese subset; humanist rather than terminal-flavoured, avoiding the rejected "dark deep-focus terminal" register.
- `_config.yml` — `enable_darkmode: false`, `enable_progressbar: false`, `max_width`, and the `third_party_libraries.google_fonts.url.fonts` key are all one-line, zero-override wins.

**Explicitly not needed for current scope:** `svg2roughjs`, `matplotlib`, Excalidraw, and any book-cover/figure asset pipeline — these support research-figure redrawing and reading-list covers, both of which PROJECT.md defers (see Expected Features below). Retain the recommendations for the deferred milestone; do not schedule them now.

### Expected Features

FEATURES.md researched the full feature landscape including entry-point cards, research figures, and book covers in depth — but PROJECT.md's Active scope (already corrected after that research) **defers all three of those content-bearing differentiators**, because their underlying content does not exist (`_data/research.yml` has empty `detail:`/`url:`, both `_projects/*.md` are `TODO`, `_data/further_reading.yml` is `papers: [], books: []`, `assets/img/book_covers/` is empty). What follows is scoped to what PROJECT.md actually asks this milestone to ship, with the deferred items flagged separately for the roadmapper's awareness.

**Must have (table stakes, in current scope):**
- Portrait rendered on the home page — asset already exists, currently commented out; highest value-per-effort item in the whole milestone.
- Comfortable measure and a real type scale, serif body — the design-token work everything else depends on.
- Contrast that passes WCAG AA on warm paper, checked by hand — no CI gate exists to catch failures.
- Fast first paint — CSS/SVG texture over raster; three or fewer font families/weights.
- Mobile layout where marginalia has an explicit, decided behavior (not left to reflow).
- Print/PDF sanity — one `@media print` block; currently zero exist in the repo.
- Honest, preserved status labels on unpublished work — the existing quiet `.entry-status` treatment and the "Research" (not "Publications") heading must survive the visual pass unchanged in intent.
- Scannable hierarchy for a 2-3 minute (realistically shorter) admissions read.
- `prefers-reduced-motion` respected if any animation ships at all.

**Deferred (content does not exist yet — do not build empty shells):**
- Home-page entry-point cards phrased as real questions — the milestone's most-researched differentiator, but PROJECT.md defers it because both research entries and both projects lack landing content. FEATURES.md's guidance (exactly 3 cards, concrete questions that fully disclose the subject, never withholding it; each card only as good as its destination) should be carried into that later milestone verbatim, plus the "curiosity gap" evidence: over-teasing backfires and clickbait framing measurably lowers reader trust — favor concreteness over intrigue for this audience.
- Annotated one-line section descriptions (the maggieappleton.com pattern) — cheap, but still content-bearing; defer alongside cards or ship only if the owner supplies the one-liners without churning scope.
- One hero research figure, redrawn in notebook style — asset does not exist; when it does, `figure.liquid` already supports `.svg` with no override, and the landing composition should be designed now so a figure slot is additive, never load-bearing, once this ships.
- Book covers / reading-list presentation — doubly blocked (no data, no images); the typographic fallback (title/author/year on ruled lines, no covers) is the correct v1.x unblock and ships the same day data exists, without touching this milestone's scope.
- Dark theme — deliberately dropped for this milestone; keep every rule in tokens (`var(--…)`) so re-adding it later is additive, not a rewrite.

**Anti-features (do not build, this milestone or later):** scroll-jacking/parallax, splash/intro screens, custom cursors, autoplaying background media, skills-percentage bars, "years of experience" counters, testimonial quotes, gamification, a scroll-progress bar (turn off, one config line), carousels, hotlinked book covers, and any blog/news feed module (already correctly disabled).

### Architecture Approach

The gem ships two stylesheets: a prebuilt, frozen Tailwind CSS that this repo cannot recompile (its `tailwind.config.js` isn't even shipped), and `main.css`, compiled from this repo's `main.scss` + `_custom.scss`, which is Jekyll-compiled and therefore fully controllable. Both stylesheets read the same 29 `--global-*` custom properties, and only `main.css`'s output is unlayered, so `_custom.scss` (loaded last) beats the entire Tailwind sheet with no specificity fight. This single mechanical fact is what makes the whole redesign CSS-only: re-point tokens once, and gem-rendered markup, prebuilt Tailwind-styled markup, and page-authored markup all update together.

**Major components:**
1. `custom/_tokens.scss` — the only file allowed literal colour/length values; defines primitives and re-points every `--global-*` token the gem exposes. Everything downstream references `var(--…)`, which is also what makes a future dark theme additive rather than a rewrite.
2. `custom/_base.scss` (ground and type) — paper texture, serif body, modular type scale, measure, hand-drawn rules, link underline treatment (required — see Critical Pitfalls).
3. `custom/_components.scss` — the shared `.entry-group`/`.entry`/`.entry-status`/`.subject` vocabulary that four of the seven pages (Academics, Research, Activities, Further Reading) already share; styling it once upgrades all four in one commit.
4. `custom/_home.scss` plus edits to `_pages/about.md` — portrait, hero styling; page-authored HTML styled by `_custom.scss` is the site's existing, proven component pattern (already used in `about.md`'s `<p class="exploring">`), not a new one being introduced.
5. `custom/_pages.scss` — per-page polish, `@media print`, `prefers-reduced-motion`, final contrast audit.

Two verified traps in this exact Sass setup: `_sass/custom/_index.scss` is silently ignored if `_custom.scss` also exists (name the aggregator `_custom.scss`, never both); and re-configuring `@use "variables" with (...)` a second time in `_custom.scss` is a hard build error (read the value with `as v`, change `max_width` in `_config.yml` instead).

### Critical Pitfalls

1. **`deploy.yml`'s push-path filter omits `_sass/**` entirely.** A pure-SCSS commit produces no deploy at all — no error, no red X, just a live site that silently stays stale while local preview looks correct. Fix in the first commit of the milestone: add `_sass/**` to both `push:` and `pull_request:` path filters in `deploy.yml` (and `unit-tests.yml` if the style contract should see SCSS), then prove it with a one-line SCSS push.
2. **The custom domain has already broken once and the fix is untested.** `JamesIves/github-pages-deploy-action@v4` replaces `gh-pages` wholesale; `CNAME` was absent from two prior deploy commits and had to be hand-restored directly on `gh-pages` before later reaching `main`. `keep_files:` does not protect this in CI (every runner starts with no existing `_site`). Add a build-step assertion (`test -f _site/CNAME`) before the first design deploy, and run a `curl -sI https://phamhakhanhchi.com` smoke check after every deploy.
3. **`opacity`-based de-emphasis compounds against the cream ground and can silently defeat a "fixed" contrast palette.** `_custom.scss` already applies `opacity: 0.6/0.7/0.75` to `.entry-year`/`.entry-status`/`.entry-meta`; even ARCHITECTURE.md's recommended muted ink (`#5c5349`, 6.99:1 on white) drops to 3.81:1 at `opacity: 0.75` on cream, below AA. There is no `axe.yml` gate on this repo (its triggers are commented out) to catch this, so the rule must be mechanical: never use `opacity` on text; delete these rules in the same phase the ground colour changes, and set muted-text colours directly from ratios measured against the final ground.
4. **Vietnamese diacritics fall back on exactly the family name.** "Phạm" mixes `latin`-subset (`à`, `á`) and `vietnamese`-subset-only (`ạ`) characters; a typeface without the Google Fonts `vietnamese` block (Caveat, Kalam, Libre Baskerville, and most "notebook aesthetic" hand-drawn faces) silently renders `ạ` in a different face on the site's largest, most important string. Verify any font choice with a live `curl` check for a `/* vietnamese */` block before committing it, and visually compare `ạ` against `à` at 48px or larger.
5. **Personality overshoot is the highest-stakes, least recoverable failure.** A reader concluding the applicant cares more about presentation than substance cannot be un-concluded, produces no error, and the owner will never learn it happened. Prevention is mechanical, not aesthetic judgment: cap the type-family and accent-colour vocabulary in the tokens phase (so overshoot requires visibly adding a token), run the stylesheet-off test and the greyscale-blur test before merging any page, and show the near-finished home page to one non-designer adult, asking only "what does this person do, and how seriously do you take them?"

## Implications for Roadmap

PROJECT.md's Active scope already excludes entry-point cards, research figures, and book covers/reading list as current-milestone work (they are listed under Out of Scope / deferred, pending content the owner hasn't written yet). The phase structure below reflects that narrowed scope: it delivers the coherent, contrast-safe, Vietnamese-safe notebook redesign across all seven existing pages, and explicitly does **not** include the content-bearing differentiators FEATURES.md researched at length. Those are captured as a named future milestone at the end.

Based on research, suggested phase structure:

### Phase 1: Guardrails
**Rationale:** Every other phase assumes deploys work, the domain survives, and the visual-regression workflow isn't generating false-negative noise. These are pre-existing, already-manifested defects (the deploy path filter, the untested CNAME fix) rather than risks introduced by the redesign, and PITFALLS.md is explicit that recovery is only fast if this phase runs first.
**Delivers:** `_sass/**` added to `deploy.yml` (and `unit-tests.yml`) path filters, verified with a real SCSS-only push; a `CNAME`-survival assertion step in `deploy.yml`; `visual-regression.yml` disabled (its specs target `/al-folio/` demo routes this site does not have); `enable_darkmode: false`, `enable_progressbar: false`, `max_width` and the Google Fonts URL set in `_config.yml`; a `pre-redesign-known-good` git tag; a short correction note atop `AGENTS.md`/`CLAUDE.md` pointing at `PROJECT.md` (they describe the upstream demo, not this site, and are excluded from the Jekyll build so editing them is free).
**Addresses:** the "Visual-regression workflow disabled" and "Light theme only" Active requirements.
**Avoids:** Pitfall 1 (SCSS never deploys), Pitfall 2 (domain breakage), Pitfall 13 (visual-regression noise), Pitfall 11d (no rollback point).

### Phase 2: Design Tokens
**Rationale:** Every later phase writes `var(--…)` rules against this file; writing components first means literal hex values paid for twice. This is also the single highest-value-per-hour commit available, because re-pointing the gem's 29 `--global-*` tokens repaints the whole site — navbar, cards, footer, code blocks, buttons — simultaneously, with no half-restyled intermediate state.
**Delivers:** `_sass/custom/_tokens.scss` with primitives (paper/ink/accent/rule) and every `--global-*` re-point in one block; a measured muted-text scale (no `opacity` on text, ever); the link-underline decision made once (every warm ink-like accent fails the 3:1-vs-body-text test, so links need a non-color affordance regardless of final palette); a `:focus-visible` rule (2px or more, `outline-offset: 2px`); the ground colour chosen and recorded as a decision within a 30-minute box, using the contrast table as a pass/fail procedure rather than aesthetic deliberation.
**Uses:** CSS Custom Properties (STACK.md); the token-repointing pattern (ARCHITECTURE.md Pattern 1).
**Implements:** the L1 Tokens layer.

### Phase 3: Ground and Type
**Rationale:** Paper texture, serif body, and the type scale/measure decision must land together and before component work, because components are sized against the scale and the measure; deciding the measure later means re-tuning everything built against it.
**Delivers:** CSS-gradient/inline-SVG paper texture (a 200x200 tiled `feTurbulence` data-URI, not a live full-viewport filter — 25-75x cheaper and avoids the `position: fixed` containing-block trap that a live filter creates); `body { font-family: Source Serif 4 }` with the Vietnamese `curl` check run and recorded in the commit; a hard heading-to-body size ratio (H2 at least 1.5x body, H3 at least 1.25x) so hierarchy survives pre-attentive scanning; the measure decided (930px is above the 45-75ch legibility convention; narrowing the text column and spending the difference on a margin gutter serves both aesthetics and legibility); every text `opacity` rule deleted as part of this same phase (deleting it separately from the ground change is strictly worse than doing neither).
**Addresses:** "Warm paper background and notebook art style applied across all seven pages," "Typography that carries the personality... with verified Vietnamese diacritic coverage."
**Avoids:** Pitfall 4 (opacity compounding), Pitfall 7 (Vietnamese fallback), Pitfall 8 (scannability loss), Pitfall 10 (texture performance).

### Phase 4: Shared Components
**Rationale:** Four of the seven pages (Academics, Research, Activities, Further Reading) already render the same `.entry-group`/`.entry`/`.entry-status` markup vocabulary; styling it once upgrades all four in a single, globally-consistent commit rather than four separate, drift-prone passes.
**Delivers:** the shared entry vocabulary restyled on the paper ground; the quiet, non-badge `.entry-status` treatment explicitly preserved (do not let a visual pass upgrade "Research" toward "Publications" framing — this is the highest-stakes credibility item on the site and costs nothing to keep); mobile marginalia behavior decided and implemented (collapse below the annotated paragraph under roughly 768px, never squeeze beside it); a minimal `@media print` block (currently zero exist in the repo) covering background drop-out, status re-expression via border rather than background colour, orphan-note avoidance, and link-URL expansion.
**Implements:** the L3 Shared Components layer; the print-stylesheet requirement.
**Avoids:** Pitfall 9 (print failures), continues avoiding Pitfall 8 (scannability).

### Phase 5: Home Page Presence
**Rationale:** This is the step the primary audience feels most, and it is fully unblocked by existing assets (the portrait is already in the repo, just commented out) — no content dependency, unlike the deferred entry-point cards.
**Delivers:** the `profile:` block uncommented in `_pages/about.md` (verify `image_circular` reads correctly for the notebook register, and that a white-background source photo does not show as a rectangle on cream); hero/subtitle styling for the existing `.hero-role`/`.hero-line`/`.hero-school`/`.exploring` class hooks, which already exist unstyled in `about.md`.
**Addresses:** "Home page has something to look at — the portrait rendered, not commented out."
**Avoids:** Pitfall 12a (silent feature failure — verify with `grep -c "prof_pic" _site/index.html` after building, do not trust the page alone), Pitfall 15 (portrait not print/retina-safe), Pitfall 11b (home page absorbing disproportionate time — time-box this phase and give Research page work at least equal weight, since a redesigned home page pointing at unstyled inner pages reads as broken, not finished).

### Phase 6: Per-Page Polish and Final Audit
**Rationale:** This is refinement on an already-consistent base, not the thing that makes a page look designed — and it is where register overshoot actually happens, so it is also the phase that needs the register checklist as an exit gate.
**Delivers:** CV/404 page-scoped treatment; the full "Looks Done But Isn't" checklist run (deploy pipeline verified, all seven pages checked together, contrast re-verified against the *final* ground with the DevTools colour picker, focus tab-order checked, Vietnamese glyph comparison, 390px mobile check, print check with backgrounds off, webfont-blocked fallback check, stylesheet-off test); the register markers from Pitfalls counted on screenshots (not eyeballed) across all seven pages; one outside, non-designer reader shown the home page and asked the single calibration question.
**Avoids:** Pitfall 3 (register overshoot — the least recoverable failure in the project), Pitfall 6 (PurgeCSS divergence between local preview and the live build), Pitfall 11a (half-restyled site reaching the live domain), Pitfall 11e (shipping without looking).

### Future milestone (not this roadmap): Content-Dependent Differentiators
Once the owner has written the underlying content, a later milestone should revisit: three question-led home-page entry-point cards (concrete, fully-disclosed questions; never more than three; each only as good as its destination — fill `_data/research.yml`'s `detail:`/`url:` or point elsewhere first); one hero research figure, redrawn in notebook style with a plain-language one-line caption, designed as additive rather than load-bearing; a typographic (not image-based) reading list once `_data/further_reading.yml` has real entries, with book covers as a further v1.x-plus enhancement only after a licensing decision; and dark theme, which the token architecture (if `var(--…)` discipline holds through this roadmap) makes a later additive change rather than a restructure.

### Phase Ordering Rationale

- Phases 1 through 3 are strictly serial (guardrails must precede tokens; tokens must precede anything using `var(--…)`; the ground/measure decision must precede anything sized against it). After Phase 3, work can fan out — components (Phase 4) and home (Phase 5) touch different files and different pages with no shared selectors.
- Every phase boundary is chosen so the site is fully shippable at that point — this satisfies both PROJECT.md's "never a half-finished redesign on the live domain" constraint and PITFALLS.md's Pitfall 11a (half-restyled site is worse than a plain one, because it reads as abandoned rather than in-progress).
- Deferred features are ordered last and named explicitly rather than silently dropped, because FEATURES.md's research on them (the curiosity-gap evidence, the entry-point-card phrasing rules, the reading-list authenticity signals) remains valid and should not need re-researching when that milestone starts.

### Research Flags

Phases likely needing deeper research during planning:
- **None of Phases 1-6** need `/gsd:research-phase` — all four research files independently verified their claims against the installed gem, live font APIs, and this repo's own git history and workflow files, and PITFALLS.md's phase-by-phase mapping already specifies concrete verification commands for each step.
- **The future content-dependent milestone** (entry-point cards, hero figure, reading list) will need a lighter research-phase pass focused specifically on the card copy/destination dependency and any figure-redraw tooling decisions once real source figures exist — the tooling itself (`svg2roughjs`, `matplotlib` `plt.xkcd()`, Excalidraw) is already researched and versioned in STACK.md and does not need re-research, only re-confirmation that versions are still current when that milestone starts.

Phases with standard patterns (skip research-phase):
- **Phase 1 (Guardrails):** all fixes are documented, verified-against-this-repo YAML/config edits with exact diffs already specified in PITFALLS.md.
- **Phase 2 (Tokens) and Phase 3 (Ground/Type):** the token-repointing mechanism, the cascade-layer behavior, and the font subset verification method are all independently verified in STACK.md and ARCHITECTURE.md against the actual gem payload — no open questions remain.
- **Phases 4-6:** these apply the same verified patterns (shared vocabulary, page-scoped wrapper classes, `_styles` front matter) that ARCHITECTURE.md confirms are already proven elsewhere in this repo.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Verified by unpacking and reading the installed `al_folio_core` 1.0.15 gem on disk; font subset claims verified against the live Google Fonts `css2` API with measured payloads; only the figure-tooling technique guidance (feTurbulence, texture layering) is MEDIUM (community practice, corroborated across sources but not benchmarked on this repo's actual devices). |
| Features | MEDIUM | HIGH on presentational conventions and accessibility rules (verifiable specs, named real sites); MEDIUM on the entry-point/curiosity-gap evidence (strong pre-registered study, but from a different domain — news headlines, not admissions review); explicitly LOW-and-flagged on admissions-officer behavior claims, where the researcher traced and discarded a widely-circulated but uncited "68% of admissions officers" statistic as unreliable. Largely superseded for phase-planning purposes by PROJECT.md's decision to defer the content-bearing features this file researched most deeply. |
| Architecture | HIGH | Primary evidence is the actual gem payload extracted and read, plus Sass behaviors independently reproduced locally with Dart Sass 1.104.1 (the `_index.scss`-shadowing trap and the `@use ... with` re-configuration error were both actually triggered, not inferred). |
| Pitfalls | HIGH | Written last with the other three research files available, and resolves their conflicts using direct verification: `git ls-tree` on the actual gh-pages deploy commits to confirm the CNAME incident, `grep` against the actual workflow files to confirm axe/Lighthouse do not gate this site, and the WCAG relative-luminance formula computed by hand against the actual `_custom.scss` opacity values already in the repo. |

**Overall confidence:** HIGH

### Gaps to Address

- **Tiled noise-texture seam visibility** is explicitly flagged by STACK.md as an empirical question to decide during the texture phase (Phase 3), not in planning — test at the chosen opacity on a real screen before committing to a value.
- **`background-attachment: fixed` performance cost** is corroborated across multiple community sources in both STACK.md and PITFALLS.md but not verified on an actual device by either researcher — PITFALLS.md recommends measuring once on a real phone during Phase 3 rather than trusting the claim blind.
- **Excalifont's (Excalidraw's hand-drawn export font) Vietnamese coverage** was not verified directly, but this is only relevant to the deferred figure-redrawing milestone, not current scope; mitigated there by keeping figure text in English.
- **No automated contrast or performance gate exists for this site** (`axe.yml` is `workflow_dispatch`-only; `lighthouse-badger.yml` measures the upstream demo, not this domain) — this is a settled fact, not a gap, but the roadmap should treat every contrast and performance number as self-enforced and budget explicit manual-check time in Phases 2, 3, and 6 rather than assuming CI will catch regressions.
- **The CNAME fix on `main` is untested** — no deploy has run since `CNAME` reached `main`, so Phase 1's build-time assertion is protecting against an unverified, not merely theoretical, risk.

## Sources

### Primary (HIGH confidence)
- `al_folio_core` 1.0.15 gem (RubyGems, downloaded and unpacked directly) — `_sass/_themes.scss`, `_variables.scss`, `_layout.scss`, `_typography.scss`, `assets/css/tailwind.css` (27,355 bytes, prebuilt), `_includes/head.liquid`, `header.liquid`, `figure.liquid`, `_layouts/about.liquid`, `page.liquid`, `default.liquid`
- This repository, read directly: `assets/css/main.scss`, `_sass/_custom.scss`, `_config.yml`, `_pages/*.md`, `_data/*.yml`, `.al-folio-overrides.yml`, `package.json`, `test/style_contract.js`, `.github/workflows/*.yml`, `purgecss.config.js`, `Gemfile`, `CNAME`
- Git history on this repository (`git ls-tree`, `git log`) — verified the CNAME-loss deploy incident with exact commit SHAs and timestamps
- Live API verification — Google Fonts `css2` endpoint (Vietnamese-subset presence and payload size for 37+ typefaces), RubyGems versions API, npm registry, PyPI
- Local reproduction — Dart Sass 1.104.1, used to trigger (not infer) the `_index.scss`-shadowing and `@use ... with` re-configuration failures

### Secondary (MEDIUM confidence)
- MDN `@layer` documentation — cascade-layer precedence rules for normal vs. `!important` declarations
- Aubin Le Quere and Matias, *Scientific Reports* (2025), pre-registered meta-analysis of 8,977 headline experiments — curiosity-gap curvilinearity; HIGH internal validity, LOW-MEDIUM transfer to an admissions-review context (relevant only to the deferred entry-point-card milestone)
- Selingo, *Who Gets In and Why* (2020) — embedded newsroom-style reporting on roughly 8-minute full-application admissions reads at three named institutions
- Community sources on `feTurbulence` cost and `background-attachment: fixed` performance — consistent across multiple sources, not device-verified by either researcher

### Tertiary (LOW confidence, explicitly discarded)
- The "68% of admissions officers review applicant websites (NACAC 2023)" and "15-20% of competitive applicants" statistics circulating on vendor blogs — traced to an uncited commercial source, not present in NACAC's actual published output. FEATURES.md and PITFALLS.md both flag this as unreliable; no recommendation in this summary rests on it.

---
*Research completed: 2026-09-13*
*Ready for roadmap: yes*

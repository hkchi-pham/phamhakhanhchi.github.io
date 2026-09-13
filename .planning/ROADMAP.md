# Roadmap: phamhakhanhchi.com — Portfolio Design Language

## Overview

This milestone is a single design pass over an existing seven-page academic site, not a rebuild. The journey runs in one direction: make the pipeline able to carry a stylesheet change at all, then re-point the gem's 30 `--global-*` custom properties so the whole site repaints at once, then layer typography, then art style, then page-level presentation, then verify by hand the things no CI gate on this repo checks. The token architecture is what makes this safe under a deadline — because the gem's prebuilt Tailwind and its own Sass both read the same custom properties, there is no state where the navbar is cream and the cards are still white. Every phase boundary below is chosen so the live domain is left in a coherent, shippable state, and each phase states what the site looks like if work stops right there.

Deviations from the researched six-phase shape, stated up front:

- `enable_darkmode: false` moves **out** of Phase 1 and **into** Phase 2, because `html[data-theme="dark"]` (0,1,1) outranks `:root` (0,1,0) and the gem's dark block stays in `main.css` — turning the toggle off is part of the token change, not a guardrail.
- "Ground and Type" splits into **Phase 3 (Typography)** and **Phase 4 (Notebook Art Style)**. Typography is low-risk and fully verified; the notebook marks are the highest register risk in the project (PITFALLS Pitfall 3, partly unrecoverable). Splitting them buys a real deadline fallback: a finished typographic paper site that can ship without the marks.
- The paper *colour* is delivered by the token re-point in Phase 2 (GROUND-01); the *texture* is Phase 4 (GROUND-02).
- Cross-page hardening (mobile, print, scannability) and the manual QA audits are separate phases, so the QA work is a named gate with its own time rather than a checklist appended to a polish phase.

## Phases

**Phase Numbering:**

- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: Deployment Guardrails** - Make a stylesheet change able to reach the live site, and the domain able to survive it
- [ ] **Phase 2: Palette and Design Tokens** - Re-point every `--global-*` token so all seven pages land on warm paper in one commit
- [ ] **Phase 3: Typography** - Serif body, companion face, real hierarchy, and a name that renders in one typeface
- [ ] **Phase 4: Notebook Art Style** - Paper texture and a small, defended vocabulary of notebook marks
- [ ] **Phase 5: Shared Page Components** - Style the one entry vocabulary the four list pages already share
- [ ] **Phase 6: Home Page Presence** - Put the portrait and the voice on the landing page
- [ ] **Phase 7: Mobile, Print and Scannability** - Make every page hold at phone width, on paper, and in five seconds
- [ ] **Phase 8: Contrast, Register and Deployed-Site Verification** - Check by hand the four things no CI gate on this repo checks

## Phase Details

### Phase 1: Deployment Guardrails

**Goal**: A stylesheet-only change reaches the live site, the custom domain survives the deploy that carries it, design PRs run green, and there is a written way back.
**Depends on**: Nothing (first phase)
**Requirements**: SAFE-01, SAFE-02, SAFE-03, SAFE-04
**Success Criteria** (what must be TRUE):

1. A commit touching only `_sass/_custom.scss` produces a GitHub Actions run and advances `origin/gh-pages` — demonstrated with a real push, not by reading the YAML.
2. `curl -sI https://phamhakhanhchi.com` returns 200 after that deploy, and a build missing `_site/CNAME` fails loudly instead of shipping.
3. A PR touching `_sass/**`, `_pages/**` or `assets/**` shows no `visual-regression` check in its status list.
4. A known-good commit is tagged and the rollback procedure is written down, including the fact that a revert touching only `_sass/**` now redeploys because of criterion 1.

**If work stops here**: The site is pixel-identical to today. Everything that changed is invisible and entirely in this phase's favour — SCSS commits now deploy, a CNAME-less deploy can no longer take the domain down silently, and there is a tag to fall back to. Strictly safer than today.
**Notes**: Research corrected three premises carried in REQUIREMENTS.md and CONTEXT.md. (1) The locked "invert the path filter" decision must be implemented as `on.push.paths-ignore:` — GitHub rejects a `paths:` list made only of `!` patterns, and `paths`/`paths-ignore` are mutually exclusive. (2) CNAME is currently healthy (`origin/gh-pages:CNAME` is byte-identical to `main:CNAME`; three deploys ran on 2026-09-11 after it landed), so the guard is regression insurance, not a repair — the real uncovered hazard is a present-but-wrong `_site/CNAME`. (3) `unit-tests.yml` passes today (`81e55bd` disabled its forbidden-path check); it is still deleted, for irrelevance rather than failure. Ordering constraints: `.prettierignore` must gain `.planning/**` and `update-tocs.yml` must be deleted before the first push and before `docs/DEPLOYMENT.md` is created.
**Plans**: 5 plans

Plans:
- [x] 01-01-PLAN.md — Prune 19 inherited workflows to 3; add `.planning/**` to `.prettierignore` (SAFE-03)
- [x] 01-02-PLAN.md — `deploy.yml`: `paths-ignore` denylist, `bin/verify-cname.sh` gate, live-domain check, concurrency (SAFE-01, SAFE-02)
- [x] 01-03-PLAN.md — Phase `verify.sh` harness; push the guardrails to `origin/main` (SAFE-01, SAFE-02, SAFE-03)
- [x] 01-04-PLAN.md — `_sass`-only proof commit; prove `gh-pages` advanced and the marker reached the served CSS (SAFE-01, SAFE-02)
- [x] 01-05-PLAN.md — Tag `design-00-baseline`; Pages/branch-rule snapshot; write `docs/DEPLOYMENT.md` (SAFE-03, SAFE-04)

### Phase 2: Palette and Design Tokens

**Goal**: One token file repaints the entire site onto warm paper — every page, the navbar, dropdowns, footer, cards, code blocks, buttons and tables — with no gem file shadowed, no dark theme left reachable, and no text faded by `opacity`.
**Depends on**: Phase 1
**Requirements**: TOKEN-01, TOKEN-02, TOKEN-03, TOKEN-04, TOKEN-05, TOKEN-06, GROUND-01, GROUND-04
**Success Criteria** (what must be TRUE):

1. All seven pages show warm paper behind navbar, body, cards, code blocks and footer — no leftover white panel and no dark-grey bar pinned to the bottom.
2. No theme toggle appears anywhere, and forcing `data-theme="dark"` in DevTools changes no colour on the page.
3. Every link in body copy is underlined and still identifiable as a link in a greyscale screenshot.
4. `grep -rn "opacity" _sass/` returns no text selector, and `.entry-year`, `.entry-meta` and `.entry-status` each measure at least 4.5:1 against the new ground with the DevTools colour picker.
5. Every colour and length literal in the design lives in one token file, each colour token carrying its measured contrast ratio in a comment, and the cap on type families and accent colours written down in that same file.

**If work stops here**: The whole site reads as a deliberate, tasteful recolour on warm paper. Type is still the gem default at gem sizes, so it looks plain rather than designed — but it is globally consistent, light-only and contrast-safe. This is the single best value-per-hour state in the project.
**Notes**: GROUND-04 (links underlined) lands here rather than with the art style, because re-pointing `--global-theme-color` to a warm ink accent is what creates the hazard — every warm ink-like accent fails the 3:1-against-body-text test, so the underline must ship in the same commit as the accent. `enable_progressbar: false` and the `footer_fixed` / footer-token decision are supporting work in this phase. TOKEN-04 is here, not in Phase 1, by hard constraint.

Research corrected three premises. (1) There are **30** `--global-*` tokens, not 29 — this document, `STACK.md` and CONTEXT were all wrong; the dark block has 29 because it omits `--global-highlight-color`. (2) `enable_darkmode: false` alone does **not** satisfy criterion 2 — the flag is a Liquid gate that drops the toggle and `theme.js`, but the gem's `html[data-theme="dark"]` CSS block is compiled into `main.css` unconditionally; the fix is to emit the semantic map under the selector list `:root, html[data-theme="dark"]`, which ties (0,1,1) and wins on source order, and which is also the TOKEN-05 hook. (3) Six things tokens cannot reach need hand-written rules: `pre`/`code` colour, `.card`'s hardcoded box-shadow literal, `.navbar { opacity: .95 }`, heading ink, the body-copy underline, and `:focus-visible`. Verification is a shell harness plus a Node contrast calculator; **the Playwright visual suite must not be run or updated** (deleted workflow, `/al-folio` baseurl, no baseline for this site).
**Plans**: 4 plans

Plans:
- [ ] 02-01-PLAN.md — Wave 0 tooling: `contrast.js`, the phase `verify.sh` with the 30 token names read off the live CSS, and the `CLAUDE.md` fork note (TOKEN-01, TOKEN-03, TOKEN-06)
- [ ] 02-02-PLAN.md — `_sass/_tokens.scss`: primitives + written cap + all 30 `--global-*` under `:root, html[data-theme="dark"]`; wire into `main.scss` (TOKEN-01, TOKEN-02, TOKEN-05, TOKEN-06, GROUND-01)
- [ ] 02-03-PLAN.md — `_sass/_custom.scss`: strip all `opacity` and literals; the six gem overrides; body-copy underline (TOKEN-01, TOKEN-02, TOKEN-03, GROUND-04)
- [ ] 02-04-PLAN.md — Three `_config.yml` flags; one push; live-CDN proof; human seven-page sweep (TOKEN-04, TOKEN-05, GROUND-01, GROUND-04)

### Phase 3: Typography

**Goal**: The site's voice comes from its type — a serif body with verified Vietnamese coverage, a companion face for labels and code, a hierarchy that survives a five-second scan, and a measure chosen rather than inherited.
**Depends on**: Phase 2
**Requirements**: TYPE-01, TYPE-02, TYPE-03, TYPE-04, TYPE-05
**Success Criteria** (what must be TRUE):

1. "Phạm Hà Khánh Chi" renders entirely in one typeface — `ạ` (U+1EA1) and `à` compared side by side at 48px or larger and visually identical in weight and shape.
2. The Google Fonts CSS actually served for the chosen families contains a `/* vietnamese */` block, verified by `curl` and recorded in the commit.
3. Body copy is the serif, and labels, years, metadata and code are the companion face — with no third type family present anywhere in `_sass/custom/`.
4. H2 is at least 1.5x body size and H3 at least 1.25x, and a body paragraph measures between 45 and 75 characters per line.
5. Total webfont bytes on first load are under the budget stated in this phase, measured in DevTools against the deployed site.

**If work stops here**: A calm, well-set academic site on warm paper. No texture, no marginalia, no hand-drawn marks — it reads as editorial rather than as a notebook. This is the deliberate deadline fallback: if the art style has to be cut, this state ships without looking unfinished.
**Notes**: `max_width` (the measure) and the `third_party_libraries.google_fonts.url.fonts` key are `_config.yml` edits in this phase. Typeface selection and the Vietnamese `curl` check can be done during Phase 1 or 2 — see Dependencies and Parallelism.
**Plans**: TBD

### Phase 4: Notebook Art Style

**Goal**: The site reads as a research notebook rather than an editorial page, through cheap texture and a small vocabulary of marks, each defensible by naming the content it serves.
**Depends on**: Phase 3
**Requirements**: GROUND-02, GROUND-03, GROUND-05
**Success Criteria** (what must be TRUE):

1. Paper texture is visible at normal reading distance on desktop and on a 390px phone, costs zero extra network requests and under 2 KB, and scrolling on a real device shows no paint jank.
2. The mark vocabulary exists as a written, named list — rules, marginalia, annotation — each entry carrying a one-sentence defence that names the content it serves, and no mark appears on any page that is not on that list.
3. Turning the stylesheet off loses no information: every mark is decorative only, and a reader using a screen reader encounters no orphaned or unexplained symbol.
4. No first viewport on any of the seven pages contains more than two purely decorative marks, counted on a screenshot rather than eyeballed.
5. Nothing from the notebook-cliché blocklist ships — no coffee rings, tape, paperclips, torn edges, spiral binding, ruled lines behind body text, or rotated text blocks.

**If work stops here**: The site reads as a research notebook at the level of ground, rhythm and voice. The four data-driven list pages still use flat entry styling, but they inherit the ground, type and colour, so they look plain rather than broken.
**Plans**: TBD

### Phase 5: Shared Page Components

**Goal**: The one entry vocabulary that Academics, Research, Activities and Further Reading already share is styled once, so all four pages upgrade together and every page on the site visibly carries the design.
**Depends on**: Phase 4
**Requirements**: PAGE-01, PAGE-06
**Success Criteria** (what must be TRUE):

1. Academics, Research, Activities and Further Reading render the same entry treatment — opening them in four tabs shows one design, not four.
2. Opening all seven pages in seven tabs in a row reveals no unstyled outlier; the inner pages received the design, not just the home page.
3. The heading still reads "Research", and "In progress" is still a quiet honest label rather than a badge, stamp or decorative status pill.
4. Marginalia is visibly subordinate to body text — smaller, muted, offset — and collapses below the paragraph it annotates rather than beside it under roughly 768px.

**If work stops here**: Every inner page is done. The home page is still gem-default structure sitting on the notebook ground, which reads as plain, not broken.
**Plans**: TBD

### Phase 6: Home Page Presence

**Goal**: The landing page has a face and a voice — the portrait already sitting in the repo is actually rendered, and the hero hooks already sitting in `about.md` are actually styled.
**Depends on**: Phase 3 (can run in parallel with Phases 4 and 5)
**Requirements**: PAGE-02
**Success Criteria** (what must be TRUE):

1. `grep -c "prof_pic" _site/index.html` returns more than zero, and the portrait is visible on the deployed home page — verified in the built output, not by trusting the page.
2. The portrait sits on the paper ground with no white rectangle, hard box edge or mismatched background behind it, and holds up on a retina screen and in print.
3. The `.hero-role`, `.hero-line`, `.hero-school` and `.exploring` hooks already present in `_pages/about.md` are styled rather than falling through to defaults.
4. The landing composition leaves an obvious slot where a research figure could later be added without moving anything else — additive, never load-bearing.

**If work stops here**: The landing page has presence. Combined with Phase 5 the whole site is done; on its own, the home page is designed while the inner pages carry ground, type and marks but not yet the entry treatment.
**Notes**: Deliberately small and deliberately time-boxed. PITFALLS 11b: the home page absorbs disproportionate time, and a redesigned home page pointing at unstyled inner pages reads as broken, not finished — Phase 5 gets at least equal weight. If this phase runs before Phase 4, it may use only marks that already exist.
**Plans**: TBD

### Phase 7: Mobile, Print and Scannability

**Goal**: The design holds under the three conditions an admissions reader will actually meet it in — on a phone, on paper, and in the first five seconds.
**Depends on**: Phases 5 and 6
**Requirements**: PAGE-03, PAGE-04, PAGE-05
**Success Criteria** (what must be TRUE):

1. All seven pages at a 390px viewport show no horizontal scroll, no squeezed marginalia and no texture jank on scroll.
2. Print-to-PDF with background graphics **off** on About, Research and CV produces a legible page — nothing important vanished, no note clipped at a page break, status conveyed by border rather than background, link URLs readable.
3. The five-second test passes on each of the seven pages: after looking for five seconds and closing the tab, a reader can state what the page is about and its three most important items.
4. Greyscale plus 8px blur on each page leaves headings as the strongest shapes, with no ornament outweighing an H1 or a section heading.

**If work stops here**: The site is complete and holds up in the conditions that matter. Only the deliberate hand audits of Phase 8 remain.
**Notes**: The repo currently contains zero `@media print` blocks. `prefers-reduced-motion` is handled here if any transition shipped in Phase 4.
**Plans**: TBD

### Phase 8: Contrast, Register and Deployed-Site Verification

**Goal**: The four things no CI gate on this repo covers are checked deliberately, by hand, against the deployed site — contrast on the final composited ground, register, the PurgeCSS'd production CSS, and Vietnamese rendering.
**Depends on**: Phase 7
**Requirements**: QA-01, QA-02, QA-03, QA-04
**Success Criteria** (what must be TRUE):

1. Every text-on-ground pair in the final palette has a recorded WCAG AA ratio, measured with the DevTools colour picker on the deployed site and including composited values — text over texture, not text over the flat token.
2. A written register check exists — the marker list counted from full-page screenshots of all seven pages, not eyeballed — and one non-designer adult, unbriefed, has answered "what does this person do, and how seriously do you take them?"
3. The CSS actually served from `phamhakhanhchi.com` after PurgeCSS has been inspected, and no rule the design depends on was stripped.
4. `ạ` in "Phạm" renders in the body serif on the live domain in a browser — checked against `https://phamhakhanhchi.com`, not against `jekyll serve`.

**If work stops here**: This phase is the end. It changes nothing visually except what the audit finds; anything it finds is a token-file fix or a PurgeCSS safelist entry, both cheap.
**Notes**: `axe.yml` is `workflow_dispatch`-only and `lighthouse-badger.yml` measures the upstream demo, so none of this is automatable on this repo as it stands. Budget real time; this is not a checklist appended to a polish phase.
**Plans**: TBD

## Dependencies and Parallelism

**Strictly serial:** 1 → 2 → 3.

- Phase 1 before everything: nothing visual is deployable, let alone recoverable, until the pipeline carries `_sass/**` and the domain is protected.
- Phase 2 before everything visual: every later rule is written as `var(--…)`. Writing components first means literal hexes paid for twice, and loses the deferred dark theme for free.
- Phase 3 before Phases 4-6: the type scale and the measure re-flow everything sized against them. Deciding the measure later means re-tuning every component.

**Fan-out after Phase 3:**

- Phase 4 → Phase 5 (components consume the mark vocabulary, including the marginalia treatment).
- Phase 6 depends only on Phase 3. It touches a different file (`custom/_home.scss` plus `_pages/about.md`) and different class names from Phase 5, with no shared selectors. **Phases 4+5 and Phase 6 can run in parallel.**

**Converge:** Phase 7 needs both branches done. Phase 8 follows Phase 7.

**Tracks that can start early and run beside the phases:**

| Track                                                   | Can start at | Blocks            |
| ------------------------------------------------------- | ------------ | ----------------- |
| Typeface selection + Vietnamese `curl` subset check     | Phase 1      | Phase 3           |
| Contrast-checking candidate ground/ink/accent palettes  | Phase 1      | Phase 2 sign-off  |
| Writing the one-sentence defence for each candidate mark | Phase 2      | Phase 4           |
| Arranging the outside non-designer reader               | Phase 5      | Phase 8           |

**Bikeshedding guard:** the ground hex is recorded as a decision within a 30-minute box in Phase 2, using the contrast table as a pass/fail procedure rather than aesthetic deliberation (PITFALLS 11c).

## Out of This Roadmap

Deferred to a later, content-dependent milestone and deliberately not scheduled as phases: home-page entry-point cards (CARD-01), research figures (FIG-01), reading-list presentation and book covers (READ-01, READ-02), annotated section headings (SECT-01), dark theme (THEME-01), and retargeted visual-regression specs (TEST-01). Each is blocked on content or a decision that does not exist yet. Phase 2 keeps every rule in `var(--…)` so THEME-01 is later additive; Phase 6 leaves an additive slot so FIG-01 needs no redesign.

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8
(Phase 6 may run concurrently with 4 and 5.)

| Phase                                                | Plans Complete | Status      | Completed |
| ---------------------------------------------------- | -------------- | ----------- | --------- |
| 1. Deployment Guardrails                             | 5/5            | Complete    | 2026-09-13 |
| 2. Palette and Design Tokens                         | 0/4            | Planned     | -         |
| 3. Typography                                        | 0/TBD          | Not started | -         |
| 4. Notebook Art Style                                | 0/TBD          | Not started | -         |
| 5. Shared Page Components                            | 0/TBD          | Not started | -         |
| 6. Home Page Presence                                | 0/TBD          | Not started | -         |
| 7. Mobile, Print and Scannability                    | 0/TBD          | Not started | -         |
| 8. Contrast, Register and Deployed-Site Verification | 0/TBD          | Not started | -         |

## Coverage

All 30 v1 requirements are mapped to exactly one phase. See `.planning/REQUIREMENTS.md` Traceability.

| Phase | Requirements                                                                               | Count  |
| ----- | ------------------------------------------------------------------------------------------ | ------ |
| 1     | SAFE-01, SAFE-02, SAFE-03, SAFE-04                                                         | 4      |
| 2     | TOKEN-01, TOKEN-02, TOKEN-03, TOKEN-04, TOKEN-05, TOKEN-06, GROUND-01, GROUND-04           | 8      |
| 3     | TYPE-01, TYPE-02, TYPE-03, TYPE-04, TYPE-05                                                | 5      |
| 4     | GROUND-02, GROUND-03, GROUND-05                                                            | 3      |
| 5     | PAGE-01, PAGE-06                                                                           | 2      |
| 6     | PAGE-02                                                                                    | 1      |
| 7     | PAGE-03, PAGE-04, PAGE-05                                                                  | 3      |
| 8     | QA-01, QA-02, QA-03, QA-04                                                                 | 4      |
|       | **Total**                                                                                  | **30** |

---

_Roadmap created: 2026-09-13_

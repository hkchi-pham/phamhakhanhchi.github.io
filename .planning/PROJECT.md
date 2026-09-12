# phamhakhanhchi.com — Portfolio Design Language

## What This Is

The personal academic portfolio of Phạm Hà Khánh Chi, a Computer Science student at BVIS Hanoi working on AI, mathematics and mechanistic interpretability. The site already holds real content — two in-progress research papers, projects, activities, academics and a reading list — but it currently presents that content as a CV placed on a webpage. This project is a deliberate design pass over the whole visual language: background, typography, art style and presentation, redone together rather than element by element.

## Core Value

A reader should open the site and feel curious about the person behind it — curious enough to click into the research, projects and reading rather than skim a list of achievements.

## Audience

Ranked, because the ranking resolves tradeoffs:

1. **University admissions officers** (most important) — may give the site 2-3 minutes. The design must be distinctive enough to be remembered, but must never obstruct the academic substance.
2. **Research mentors, professors, teachers** — people the owner may approach for lab work, supervision or recommendation letters. They judge by quality of thought; reading depth beats visual attention-grabbing.
3. **Curious peers** — students who land on the site because a topic interests them.

## Design Direction

**Chosen visual language: "research notebook."** Warm paper ground, serif body text, margin notes, hand-drawn rules and annotation marks. The intent is that the site reads like looking into someone's thinking notebook, not like reading their résumé.

Chosen over three alternatives that were considered and rejected:

- _Grid and plot_ (fine grid lines, mono labels, node diagrams) — communicates intelligence, but cooler and less personal than wanted.
- _Dark deep-focus terminal_ — strong personality, but risks reading as "tech bro" and works against the mature-academic requirement of the primary audience.
- _Academic editorial magazine_ — cleanest and most mature, but personality would live almost entirely in the writing rather than the visuals.

The design must hold a balance the owner named explicitly: serious about the work, and genuinely curious, creative and enthusiastic about learning. Curiosity, exploration and intelligence are the feelings the visual language serves — not "academic" as a look.

## Visual Material

All four sources are in scope, and they play different roles:

| Source                                                                                                           | Role                                                             | Status                                                                                                                                     |
| ---------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------- |
| Figures from the owner's own research (attention maps, echo-chamber network graphs, result plots), redrawn in notebook style | Credibility — proves the work is real, not decoration | To be produced |
| Portrait photograph | Presence — puts a face on the home page | **Already in repo** at `assets/img/prof_pic.jpg` and `prof_pic_color.png`; the `profile:` block in `_pages/about.md` is commented out, so it never renders |
| Book covers from the reading list | Colour and an immediate signal of intellectual curiosity | **Already in repo** at `assets/img/book_covers/` |
| Paper texture, ruled lines, hand-drawn arrows and marginalia | The connective tissue that makes the rest read as one language | Pure CSS/SVG, no assets needed |

## Requirements

### Validated

<!-- Inferred from the existing codebase — already built and working. -->

- ✓ Site builds and deploys to `phamhakhanhchi.com` via GitHub Pages — existing
- ✓ Seven content pages: About (landing), Academics, Activities, Projects, Research, Further Reading, CV — existing
- ✓ Data-driven content collections rendering from `_data/*.yml` (academics, activities, research, further_reading, socials) — existing
- ✓ A local style seam that survives gem upgrades: `_sass/_custom.scss` imported last via `assets/css/main.scss` — existing
- ✓ CV page degrades gracefully when the PDF is absent — existing (commit `778f68b`)

### Active

<!-- This milestone. Hypotheses until shipped. -->

- [ ] A coherent design system — colour, typography scale, spacing, texture — expressed as tokens rather than scattered rules
- [ ] Warm paper background and notebook art style applied across all seven pages
- [ ] Typography that carries the personality: serif body, considered hierarchy, marginalia treatment
- [ ] Home page has something to look at — the portrait rendered, not commented out
- [ ] Home page "entry point" cards that invite a click with real questions (e.g. "Why do attention sinks appear?") rather than category labels
- [ ] Research figures redrawn in notebook style and placed where they earn attention
- [ ] Book covers surfaced as a visual, curiosity-signalling element
- [ ] Light theme only — dark mode toggle removed
- [ ] Visual-regression workflow disabled so design PRs are not blocked by template-demo tests
- [ ] Every page remains readable and scannable in 2-3 minutes for a rushed admissions reader

### Out of Scope

- **Dark theme** — deliberately dropped to commit fully to one look under deadline pressure. Recorded as deferred, not rejected: night readers will find the site bright, and some readers need dark mode. Revisit after the light design is settled.
- **Navbar restructuring / renaming tabs** — creative labels risk leaving a rushed admissions reader unsure where to click. Invitation is added on the home page instead.
- **Full information-architecture rework** (merging or dropping pages) — too much churn with an application deadline approaching.
- **Rewriting the visual-regression specs for this site's real routes** — useful eventually, but not while the design is still moving. The workflow is disabled rather than repaired or deleted.
- **New content** — this milestone changes how existing content looks and is entered, not what it says.
- **A starter-local CSS/Tailwind build pipeline** — forbidden by the al-folio thin-starter contract (`npm run lint:style-contract`) and unnecessary; the gem ships built CSS.

## Context

**Technical environment.** This repo is a personal site built from **al-folio v1.x**, a thin Jekyll starter rather than a theme. Layouts, includes, Sass partials, Liquid tags and feature JS all live in versioned `al-*` gems (chiefly `al_folio_core` v1.0.15). See `.planning/codebase/` for the full map.

**Two facts that override the repo's own documentation.** `AGENTS.md` and `CLAUDE.md` are inherited template files that describe the upstream al-folio demo, not this site:

1. The effective baseurl here is **empty**, not `/al-folio`. `_config.yml` sets `url: https://phamhakhanhchi.com` with a blank `baseurl:`, and `CNAME` holds the domain. Passing `--baseurl /al-folio` would break the build.
2. The seven `test/integration_*.sh` scripts they describe **no longer exist** — dropped in commit `81e55bd`. `unit-tests.yml` now runs only the style contract.

**The style seam already exists.** `assets/css/main.scss` is a verbatim copy of the gem's file plus a trailing `@use "custom";`, and `_sass/_custom.scss` holds all site-specific rules. That file's own comment reads: _"Deliberately plain — the real design pass replaces this wholesale."_ This project is that pass.

**Known blocker.** `test/visual/*.spec.js` hardcodes `/al-folio/` paths and navigates to demo content this site does not have (blog, teaching, repositories, distill). `visual-regression.yml` fires on PRs touching `_config.yml`, `_pages/**`, `_data/**`, `assets/**` — exactly the files this project changes.

## Constraints

- **Timeline**: A university application deadline is approaching. Every phase must leave the site in a better, shippable state. Never a half-finished redesign on the live domain.
- **Tech stack**: Jekyll + al-folio gems. All runtime comes from gems; this repo owns wiring and content.
- **Override policy**: Try CSS first. Copy a gem-owned layout or include into this repo only when CSS genuinely cannot achieve the result — and say so explicitly each time, recording it in `.al-folio-overrides.yml`. Every override makes future gem upgrades harder.
- **Style contract**: `npm run lint:style-contract` must keep passing. `_sass/` is legal here as a local override for a personal site; `assets/tailwind/`, `tailwind.config.js` and `build:css` scripts are not.
- **Formatting**: Prettier with `@shopify/prettier-plugin-liquid`, `printWidth: 150`, gated by `prettier.yml`.
- **Accessibility**: `axe.yml` runs in CI. A warm-paper palette must still meet contrast requirements — low-contrast "aesthetic" greys on cream are the obvious failure mode here.

## Key Decisions

| Decision                                                         | Rationale                                                                                                     | Outcome                  |
| ------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------- | -------------------------- |
| Research-notebook visual language                                | Most personal of the four directions considered; carries curiosity without sacrificing academic maturity      | — Pending                |
| Admissions officers as primary audience                          | Forces the design to stay legible and fast to scan under a 2-3 minute read                                    | — Pending                |
| Light theme only; drop the dark toggle                           | One look done well beats two done adequately under deadline pressure                                          | ⚠️ Revisit after launch |
| Keep the navbar; add entry points on the home page instead       | Creative tab labels would disorient a rushed reader; invitation belongs on the landing page                   | — Pending                |
| CSS-first, override gem files only when forced                   | Keeps gem upgrades cheap; the existing `_custom.scss` seam already proves the pattern works                    | — Pending                |
| Disable rather than repair or delete `visual-regression.yml`     | Defers a decision that costs nothing to defer, and unblocks design PRs immediately                            | — Pending                |
| Use the portrait already sitting unused in the repo              | Fastest possible fix for "nothing to look at" — the asset exists, it is simply commented out                  | — Pending                |

---

_Last updated: 2026-09-12 after initialization_

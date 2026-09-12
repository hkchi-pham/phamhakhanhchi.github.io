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
| Portrait photograph | Presence — puts a face on the home page | **Available now.** `assets/img/prof_pic.jpg` and `prof_pic_color.png` are in the repo; the `profile:` block in `_pages/about.md` is commented out, so it never renders. |
| Paper texture, ruled lines, hand-drawn arrows and marginalia | The connective tissue that makes the rest read as one language | **Available now.** Pure CSS/SVG, no assets needed. |
| Figures from the owner's own research (attention maps, echo-chamber network graphs, result plots), redrawn in notebook style | Credibility — proves the work is real, not decoration | **Deferred — no source figures exist yet.** Design the landing composition so a figure slot is additive, never load-bearing. |
| Book covers from the reading list | Colour and an immediate signal of intellectual curiosity | **Deferred — `assets/img/book_covers/` is empty and `_data/further_reading.yml` has `papers: []`, `books: []`.** There is no reading list to design. |

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

- [ ] A coherent design system — colour, typography scale, spacing, texture — expressed as CSS custom properties rather than scattered rules
- [ ] Warm paper background and notebook art style applied across all seven pages
- [ ] Typography that carries the personality: serif body, considered hierarchy, marginalia treatment — with verified Vietnamese diacritic coverage
- [ ] Home page has something to look at — the portrait rendered, not commented out
- [ ] Light theme only — dark mode toggle removed
- [ ] Contrast verified by hand on the final palette, since no CI gate checks it
- [ ] Visual-regression workflow disabled so design PRs are not blocked by template-demo tests
- [ ] Every page remains readable and scannable in 2-3 minutes for a rushed admissions reader

### Out of Scope

- **Home-page "entry point" cards** — deferred, not rejected. The pattern is the right one, but a card asking "Why do attention sinks appear?" must land somewhere that answers it. `_data/research.yml` has an empty `detail:` and no `url:` on both papers, and both `_projects/*.md` files read `TODO — details to come.` Cards over empty destinations are a bait-and-switch with exactly the audience that matters most. Revisit once the destinations have content.
- **Research figures on the site** — deferred. No source figures exist yet. The landing composition must be designed so a figure slot is additive rather than load-bearing, so this can be added later without a redesign.
- **Book covers and reading-list presentation** — deferred. `assets/img/book_covers/` is empty and `_data/further_reading.yml` is `papers: []`, `books: []`.
- **Dark theme** — deliberately dropped to commit fully to one look under deadline pressure. Recorded as deferred, not rejected: night readers will find the site bright, and some readers need dark mode. Revisit after the light design is settled.
- **Navbar restructuring / renaming tabs** — creative labels risk leaving a rushed admissions reader unsure where to click.
- **Full information-architecture rework** (merging or dropping pages) — too much churn with an application deadline approaching.
- **Rewriting the visual-regression specs for this site's real routes** — useful eventually, but not while the design is still moving. The workflow is disabled rather than repaired or deleted.
- **New content** — this milestone changes how existing content looks and is entered, not what it says.
- **A starter-local CSS/Tailwind build pipeline** — forbidden by the al-folio thin-starter contract (`npm run lint:style-contract`) and unnecessary; the gem ships built CSS.

## Context

**Technical environment.** This repo is a personal site built from **al-folio v1.x**, a thin Jekyll starter rather than a theme. Layouts, includes, Sass partials, Liquid tags and feature JS all live in versioned `al-*` gems (chiefly `al_folio_core` v1.0.15). See `.planning/codebase/` for the full map.

**Two facts that override the repo's own documentation.** `AGENTS.md` and `CLAUDE.md` are inherited template files that describe the upstream al-folio demo, not this site:

1. The effective baseurl here is **empty**, not `/al-folio`. `_config.yml` sets `url: https://phamhakhanhchi.com` with a blank `baseurl:`, and `CNAME` holds the domain. Passing `--baseurl /al-folio` would break the build.
2. The seven `test/integration_*.sh` scripts they describe **no longer exist** — dropped in commit `81e55bd`. `unit-tests.yml` now runs only the style contract.
3. The paths they call forbidden (`_layouts/`, `_includes/`, `_sass/`) are **not** forbidden here. `test/style_contract.js` has that block commented out with an explicit rationale: the thin-starter boundary governs contributions to `alshedivat/al-folio`, not a personal site built from it. Still enforced: the `build:css`/`build:tailwind` script ban, the `theme:` pin, the plugin list, icon SRI pins, and the `al_math` version pin.

**The styling levers, verified against the installed gem.** `al_folio_core` v1.0.15 defines **29 `--global-*` CSS custom properties** on `:root`, and every colour in its SCSS reads from them — redeclaring them in `_custom.scss` re-skins the site with no file shadowing. The gem's prebuilt `tailwind.css` lives entirely inside `@layer`, while `main.css` (which carries `_custom.scss`) is unlayered and loads second, so local rules win without specificity fights or `!important`. Two consequences follow: Sass variables cannot reach gem-rendered markup but custom properties can, and the gem's `@layer components` `!important` utilities (`.mt-3`, `.mt-5`, `.w-100`, `.d-none`) cannot be overridden from `_custom.scss` at all.

**Vietnamese diacritics are a hard typeface constraint.** `ạ` (U+1EA1) in "Phạm" exists only in a font's `vietnamese` unicode-range subset. Caveat — the most commonly recommended typeface for notebook aesthetics — has no Vietnamese subset, as do Kalam, Architects Daughter, Gloria Hallelujah, Reenie Beanie, Courier Prime, DM Mono and Libre Baskerville. Source Serif 4 + IBM Plex Mono are verified to cover it, at 171 KB for latin+vietnamese.

**The style seam already exists.** `assets/css/main.scss` is a verbatim copy of the gem's file plus a trailing `@use "custom";`, and `_sass/_custom.scss` holds all site-specific rules. That file's own comment reads: _"Deliberately plain — the real design pass replaces this wholesale."_ This project is that pass.

**Known blocker.** `test/visual/*.spec.js` hardcodes `/al-folio/` paths and navigates to demo content this site does not have (blog, teaching, repositories, distill). `visual-regression.yml` fires on PRs touching `_config.yml`, `_pages/**`, `_data/**`, `assets/**` — exactly the files this project changes.

## Constraints

- **Timeline**: A university application deadline is approaching. Every phase must leave the site in a better, shippable state. Never a half-finished redesign on the live domain.
- **Tech stack**: Jekyll + al-folio gems. All runtime comes from gems; this repo owns wiring and content.
- **Override policy**: Try CSS first. Copy a gem-owned layout or include into this repo only when CSS genuinely cannot achieve the result — and say so explicitly each time, recording it in `.al-folio-overrides.yml`. Every override makes future gem upgrades harder.
- **Style contract**: `npm run lint:style-contract` must keep passing. It no longer polices `_sass/`, `_layouts/` or `_includes/` on this site, but `assets/tailwind/`, `tailwind.config.js` and `build:css`/`build:tailwind` scripts remain banned.
- **Formatting**: Prettier with `@shopify/prettier-plugin-liquid`, `printWidth: 150`, gated by `prettier.yml`.
- **Accessibility — no automated backstop.** `axe.yml` is `workflow_dispatch`-only and does not gate PRs. `lighthouse-badger.yml` measures `https://alshedivat.github.io/al-folio/` — the upstream demo, not this site. Contrast and performance must therefore be checked deliberately by hand. A warm-paper palette fails contrast easily, and `_sass/_custom.scss` already de-emphasises `.entry-year`, `.entry-meta` and `.entry-status` with `opacity: 0.6/0.7/0.75`, which compounds against a cream ground. Tokens must carry explicit contrast-checked colours rather than relying on opacity.

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
| Defer entry-point cards, research figures and book covers        | Their content does not exist. Designing empty shells before a deadline risks shipping visible blanks to the one reader who matters most | — Pending |
| Tokens as CSS custom properties, not Sass variables              | Verified against the gem: its prebuilt Tailwind consumes `var(--global-*)` and can never see downstream Sass  | — Pending                |
| Typeface must have a verified Vietnamese subset                  | The owner's own name breaks otherwise — silent per-glyph font fallback on `ạ` in "Phạm"                        | — Pending                |

---

_Last updated: 2026-09-13 after research corrected four factual assumptions and narrowed scope_

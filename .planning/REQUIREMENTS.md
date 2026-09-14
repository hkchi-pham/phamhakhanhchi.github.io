# Requirements: phamhakhanhchi.com — Portfolio Design Language

**Defined:** 2026-09-13
**Core Value:** A reader should open the site and feel curious about the person behind it — curious enough to click into the research, projects and reading rather than skim a list of achievements.

## v1 Requirements

Requirements for this milestone. Each maps to a roadmap phase.

### Deployment Safety

Nothing else in this milestone is safely recoverable without these. They come first.

- [x] **SAFE-01**: A commit that changes only `_sass/**` triggers a production deploy. Today `deploy.yml`'s push path filter watches `assets/**, **.bib, **.html, **.js, **.liquid, **/*.md, **.yml, Gemfile*` — `_sass/_custom.scss` matches none of them, so the entire design pass would silently never reach the live site, with no failed workflow to signal it.
- [x] **SAFE-02**: A production deploy leaves `phamhakhanhchi.com` resolving. `CNAME` must appear in `_site/` and survive `JamesIves/github-pages-deploy-action@v4` replacing the `gh-pages` branch. Verified, not assumed — the two deploys on 2026-09-10 both shipped without it and the domain was rescued by a manual commit onto `gh-pages`; `CNAME` reached `main` only afterwards and no deploy has exercised it since.
- [x] **SAFE-03**: Design PRs are not blocked by `visual-regression.yml`, whose specs target `/al-folio/` routes and demo content this site does not have.
- [x] **SAFE-04**: A known-good commit is identified and the rollback procedure is written down, including the fact that a revert touching only `_sass/**` will not redeploy either.
  - _Annotation added 2026-09-13 at phase close; the requirement text above is preserved verbatim._ The clause "will not redeploy either" described the world as it was when this requirement was written, and **it is no longer true** — SAFE-01's fix means a revert whose diff sits entirely in the `_sass` directory now deploys automatically, demonstrated on a real push (`b07bc86`, `gh-pages` `931970f` -> `9d0d929`). The requirement was asking for that behaviour to be *written down*, and it is: `docs/DEPLOYMENT.md` §4 states the corrected behaviour and the history of the old one. Read the clause as a dated statement of the problem, not as a live claim — the same way SAFE-01's "Today `deploy.yml`'s push path filter watches..." reads.

### Design Tokens

- [x] **TOKEN-01**: The full palette is defined by redeclaring the gem's `--global-*` CSS custom properties, so one change repaints every page, the navbar, the footer and code blocks together — no gem file is shadowed.
- [x] **TOKEN-02**: A type scale and spacing rhythm exist as named tokens rather than values repeated across rules.
- [x] **TOKEN-03**: No text element is de-emphasised with `opacity`. `_sass/_custom.scss` currently does this on `.entry-year`, `.entry-meta` and `.entry-status`, which compounds against a light ground and fails contrast even with dark ink.
- [x] **TOKEN-04**: The dark-mode toggle is gone — `enable_darkmode: false`, in the same change as the token work, because `html[data-theme="dark"]` outranks `:root` and would otherwise win.
- [x] **TOKEN-05**: Tokens are structured so a dark theme can be reintroduced later without restructuring. Dark mode is deferred, not rejected.
- [x] **TOKEN-06**: The token vocabulary is deliberately capped, so adding ornament later is a visible, reviewable act rather than a drift.

### Typography

- [ ] **TYPE-01**: The body serif has a verified Vietnamese unicode-range subset.
- [ ] **TYPE-02**: A companion face carries labels, metadata and code.
- [ ] **TYPE-03**: "Phạm Hà Khánh Chi" renders entirely in one typeface. `ạ` (U+1EA1) lives only in the `vietnamese` subset while `à` and `á` are latin, so a font without Vietnamese coverage breaks exactly one glyph in the family name, in the largest heading on the site.
- [ ] **TYPE-04**: Heading hierarchy is distinguishable at a glance, and the measure is set deliberately rather than inherited.
- [ ] **TYPE-05**: Total webfont payload stays within a stated budget.

### Ground and Art Style

- [x] **GROUND-01**: A warm paper ground applies across all seven pages.
- [ ] **GROUND-02**: Texture is achieved by a technique that is cheap to render on mobile.
- [ ] **GROUND-03**: A small, named vocabulary of notebook marks exists — rules, marginalia, annotation — each with a written one-sentence justification.
- [x] **GROUND-04**: Links are underlined. Every warm ink-like accent colour fails the 3:1 contrast-against-body-text test, so colour alone cannot distinguish a link.
- [ ] **GROUND-05**: Decorative marks carry no meaning that is unavailable to a reader who cannot see them.

### Page Presentation

- [ ] **PAGE-01**: The four data-driven list pages (Academics, Research, Activities, Further Reading) share one component vocabulary, styled once.
- [ ] **PAGE-02**: The home page shows the portrait. The asset exists at `assets/img/prof_pic.jpg`; the `profile:` block in `_pages/about.md` is commented out.
- [ ] **PAGE-03**: Every page remains readable and scannable in 2-3 minutes.
- [ ] **PAGE-04**: Every page holds up at phone width.
- [ ] **PAGE-05**: Pages print legibly without burning ink — admissions readers sometimes print or save.
- [ ] **PAGE-06**: Inner pages receive the design, not just the home page.

### Verification

No CI gate covers any of this. `axe.yml` is `workflow_dispatch`-only and `lighthouse-badger.yml` measures the upstream demo site, so each of these is a deliberate manual check with time budgeted for it.

- [ ] **QA-01**: Every text-on-ground pair in the final palette is contrast-checked against WCAG AA, including composited values.
- [ ] **QA-02**: The design passes a register check — a written list of markers separating "memorable and curious" from "not serious enough for an admissions file".
- [ ] **QA-03**: The deployed CSS is verified after PurgeCSS runs. PurgeCSS runs on production deploys but never locally, so `jekyll serve` output is not what ships.
- [ ] **QA-04**: Vietnamese rendering is checked visually on the deployed site, not only locally.

## v2 Requirements

Deferred. Tracked but not in this roadmap.

### Content-Dependent Presentation

Blocked on content that does not exist yet, not on design effort.

- **CARD-01**: Home-page entry-point cards that invite a click with a real question rather than a category label. Blocked on `_data/research.yml` gaining `detail:` and `url:` values, and both `_projects/*.md` files gaining content — both currently read `TODO — details to come.`
- **FIG-01**: A figure from the owner's own research, redrawn in notebook style, placed where it earns attention. Blocked on source figures existing. The landing composition must leave an additive slot for this.
- **READ-01**: Reading-list presentation with per-entry notes. Blocked on `_data/further_reading.yml`, currently `papers: []` and `books: []`.
- **READ-02**: Book covers as a visual element. Blocked on `assets/img/book_covers/`, currently empty.
- **SECT-01**: Annotated section descriptions — one sentence per group heading saying what the group is and why it is there.

### Theming

- **THEME-01**: A dark counterpart to the paper design, as a considered "night notebook" rather than an inverted light theme.

### Testing

- **TEST-01**: Visual-regression specs retargeted at this site's real routes, with fresh baselines taken after the design settles.

## Out of Scope

| Feature | Reason |
| --- | --- |
| Navbar restructuring or renaming tabs | Creative labels risk leaving a rushed admissions reader unsure where to click |
| Full information-architecture rework | Too much churn with an application deadline approaching |
| Writing new page content | This milestone changes how existing content looks, not what it says |
| A starter-local CSS or Tailwind build pipeline | Banned by `npm run lint:style-contract`, and unnecessary — the gem ships built CSS |
| Scroll-jacking, parallax, splash screens, custom cursors, autoplaying media | Each costs the 2-3 minute read and signals unseriousness to the primary audience |
| Skill-percentage bars, experience counters, testimonials | A self-assigned proficiency score is an overclaim shown to a reader trained to detect overclaiming |
| Tidying the duplicated `exclude:` / `keep_files:` keys in `_config.yml` | It works — last key wins — and that file holds both the CNAME mechanism and the style-contract assertions. Do not touch it during this milestone |
| Turning "In progress" status labels into decorative stamps | Converts an honest disclosure into ornament, with exactly the audience that checks |

## Traceability

Populated during roadmap creation (2026-09-13). Phase definitions live in `.planning/ROADMAP.md`.

| Requirement | Phase | Status |
| --- | --- | --- |
| SAFE-01 | Phase 1 | Complete |
| SAFE-02 | Phase 1 | Complete |
| SAFE-03 | Phase 1 | Complete |
| SAFE-04 | Phase 1 | Complete |
| TOKEN-01 | Phase 2 | Complete |
| TOKEN-02 | Phase 2 | Complete |
| TOKEN-03 | Phase 2 | Complete |
| TOKEN-04 | Phase 2 | Complete |
| TOKEN-05 | Phase 2 | Complete |
| TOKEN-06 | Phase 2 | Complete |
| TYPE-01 | Phase 3 | Pending |
| TYPE-02 | Phase 3 | Pending |
| TYPE-03 | Phase 3 | Pending |
| TYPE-04 | Phase 3 | Pending |
| TYPE-05 | Phase 3 | Pending |
| GROUND-01 | Phase 2 | Complete |
| GROUND-02 | Phase 4 | Pending |
| GROUND-03 | Phase 4 | Pending |
| GROUND-04 | Phase 2 | Complete |
| GROUND-05 | Phase 4 | Pending |
| PAGE-01 | Phase 5 | Pending |
| PAGE-02 | Phase 6 | Pending |
| PAGE-03 | Phase 7 | Pending |
| PAGE-04 | Phase 7 | Pending |
| PAGE-05 | Phase 7 | Pending |
| PAGE-06 | Phase 5 | Pending |
| QA-01 | Phase 8 | Pending |
| QA-02 | Phase 8 | Pending |
| QA-03 | Phase 8 | Pending |
| QA-04 | Phase 8 | Pending |

**Coverage:**

- v1 requirements: 30 total
- Mapped to phases: 30
- Unmapped: 0 ✓
- Duplicates (a requirement in more than one phase): 0 ✓

**Per-phase totals:**

| Phase | Name | Requirements |
| --- | --- | --- |
| 1 | Deployment Guardrails | 4 |
| 2 | Palette and Design Tokens | 8 |
| 3 | Typography | 5 |
| 4 | Notebook Art Style | 3 |
| 5 | Shared Page Components | 2 |
| 6 | Home Page Presence | 1 |
| 7 | Mobile, Print and Scannability | 3 |
| 8 | Contrast, Register and Deployed-Site Verification | 4 |
| | **Total** | **30** |

---

_Requirements defined: 2026-09-13_
_Last updated: 2026-09-13 — traceability populated from ROADMAP.md (8 phases, 30/30 mapped)_

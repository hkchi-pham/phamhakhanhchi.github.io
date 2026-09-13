# Phase 2: Palette and Design Tokens - Context

**Gathered:** 2026-09-14
**Status:** Ready for planning

<domain>
## Phase Boundary

Re-point every `--global-*` CSS custom property so all seven pages land on warm paper in one commit — navbar, body, cards, code blocks, footer, buttons and tables together. No gem file shadowed, no dark theme left reachable, no text faded by `opacity`. Supporting config work (`enable_darkmode: false`, `enable_progressbar: false`, `footer_fixed: false`) lands here because the cascade forces it, not because it is convenient.

Typography values, texture, marks and per-page components are later phases. This phase establishes the token vocabulary they consume.

</domain>

<decisions>
## Implementation Decisions

### Paper and ink values

All values are taken from the pre-measured contrast table in `.planning/research/PITFALLS.md`, so no re-measurement is required and the ROADMAP's 30-minute bikeshedding box holds.

- **Ground: `#faf6ee` cream.** Chosen specifically because every ratio in the research table was measured against it. Warm at a glance, still reads as paper rather than a tinted panel.
- **Two paper steps only** — `--paper-100` `#faf6ee` (ground: body, navbar, cards) and `--paper-200` `#f2ebdd` (recess: code blocks, footer).
- **`--paper-50` is deliberately NOT declared.** It was considered and dropped once cards were decided as flush — a token with no consumer is exactly the drift TOKEN-06 exists to prevent. Re-adding it later is one line and must be a visible edit to the cap.
- **Body ink: `#2b2621`** (13.90:1 on cream). Warm-toned, reads as ink rather than `#000`. Large headroom so it survives Phase 4 texture compositing.
- **Headings take a darker ink: `#1f1b16`** (15.88:1). Hierarchy is carried by size, weight *and* ink depth. This second lever exists specifically to help Phase 7's greyscale-plus-blur test, where headings must remain the strongest shapes.
- **One muted ink step: `#5c5349`** (6.99:1), used by `.entry-year`, `.entry-meta`, `.entry-status` and `.subject-grade` alike. A second, fainter step (`#6b6259`, 5.54:1) was considered and rejected — 5.54 is the research's stated floor and leaves no headroom once Phase 4 texture composites underneath.

### Accent colour

- **Iron-gall blue `#1d4ed8`** replaces the gem's purple `#b509ac`. 6.22:1 on cream. Chosen as the literal notebook move — blue pen ink on cream paper — where the cool/warm tension reads as handwriting rather than as a colour scheme. Oxblood `#9a3412` was the runner-up and is the agreed fallback if blue proves too loud on the final composited ground.
- **Exactly one accent colour is permitted.** Research marker #5 allows up to two; one is stricter and chosen deliberately for deadline safety. A second accent requires editing both the token file and its written cap.
- **Code block text is body ink, not the accent.** The gem ships `pre { color: var(--global-theme-color) }`, which on a warm palette renders whole blocks in link colour — visibly a bug, and it breaks the Phase 7 blur test by making code outweigh headings. Override it. The accent must mean exactly one thing: this is interactive.
- **Hover thickens the underline; the colour holds.** No second accent value, nothing extra to keep in contrast, and it sets up Phase 4's hand-drawn rule directly.

### Surfaces and footer

- **`footer_fixed: false`** in `_config.yml` (currently `true` at L99), switching to the gem's `footer.sticky-bottom` — a bordered, background-free footer. The footer stops being a bar and becomes the bottom of the page.
- **Re-point the three footer tokens anyway**, belt-and-braces: `--global-footer-bg-color` → `--paper-200`, `--global-footer-text-color` → `--ink-700`, `--global-footer-link-color` → `--ink-900`. If any background leaks through, it must be paper. This directly serves success criterion 1 ("no dark-grey bar pinned to the bottom") — the gem default is `#1c1c1d`.
- **Cards sit flush** — `--global-card-bg-color` → `--paper-100`, identical to the body. A card is not a physical object sitting on a notebook page.
- **Structure is carried by hairline rules, not tone.** `--global-divider-color` → `--rule-200` `#d9cfba`. The navbar takes a bottom rule rather than a tonal band. Tone steps are reserved for surfaces that genuinely contain content (code blocks, footer). Rationale: at these low-contrast paper values, tone steps alone go near-invisible on a phone at low brightness and structure would disappear in Phase 7's mobile check.
- **All 29 `--global-*` tokens are re-pointed**, not just the ~13 that drive visible surfaces. The unused ones (tip/warning/danger blocks, newsletter, distill, back-to-top) are derived from the paper/ink primitives. Leaving 16 gem hexes live means a future page using a callout box silently renders purple-and-grey on cream. Success criterion 5 requires one token file with no literals outside it.

### Links and quiet text

- **Underline style: hairline, offset below the baseline.** `text-decoration-thickness: 1px` with `text-underline-offset` pushing it clear of descenders. This matters concretely for Vietnamese — `ạ` and `ợ` carry marks below the baseline, and a default underline crowds them in the site owner's own name.
- **Body copy links only.** Navbar and footer links are exempt: position already signals clickability in navigational furniture, and an underlined nav row reads as a 1997 page. This matches success criterion 3's wording exactly ("every link in body copy").
- **`opacity` is removed from all four classes** currently using it in `_sass/_custom.scss` — `.entry-year` (0.6), `.entry-meta` (0.75), `.entry-status` (0.7), `.subject-grade` (0.75) — each replaced by the single muted ink token. Note `.subject-grade` is a fourth case not named in TOKEN-03 or criterion 4; it has the same defect and is in scope.
- **Type scale and spacing tokens get names AND provisional values now.** `--step-0..3` and `--space-1..4`, derived from the gem's current sizes. Phase 3 re-tunes the *values* against the real typeface without rewriting a single rule. This satisfies TOKEN-02 and criterion 5 now while avoiding designing a scale against a typeface that is about to be replaced.

### The written cap (TOKEN-06)

Written into the token file itself, so overshoot requires editing a stated limit:

```
paper tones ........ 2
ink steps .......... 4  (heading, body, muted, footer-text)
accent colours ..... 1
type families ...... 2  (value set in Phase 3)
```

### Claude's Discretion

- **Active nav marker.** Once nav links are un-underlined, the active tab cannot rely on the accent alone. Needs a non-colour marker — weight, or a rule under the tab. Constraint: it must survive greyscale.
- **Focus ring treatment.** Research is explicit: use `>= 2px` with `outline-offset: 2px` so the ring sits on clean ground, never `outline: none`, and never `box-shadow` alone (it vanishes in Windows High Contrast Mode). Colour is open — every sensible ink clears 3:1 on cream.
- **TOKEN-05 structure for later dark mode.** The shape is understood (primitives → semantic re-point, so a later `[data-theme="dark"]` block re-points primitives only). Exact file organisation is open.
- **Exact `#f2ebdd` recess value** — may be nudged once code blocks are seen against the final ground.
- **`.entry-status` italic treatment** — keep or drop; criterion 4 only requires it clears 4.5:1.
- Which heading levels specifically take the darker heading ink.

</decisions>

<specifics>
## Specific Ideas

- "Blue pen ink on cream paper" is the governing image for the accent. If the blue reads as too loud once the full palette is composited, oxblood `#9a3412` is the agreed fallback — not a re-opened decision.
- The underline is treated as the design's signature affordance, not a compromise. It is forced by contrast (every warm accent fails the 3:1-vs-body test) but was chosen as something to make good rather than something to tolerate — hence hover thickening it rather than changing colour.
- Honesty over decoration in the token file: everything declared must be used. `--paper-50` was cut mid-discussion the moment it lost its consumer.

</specifics>

<code_context>
## Existing Code Insights

### Reusable Assets

- **`_sass/_custom.scss`** — the only local SCSS partial, and the entire seam for this phase. Already contains the `:root { --deploy-proof }` canary proving `:root` custom properties survive PurgeCSS and reach the live domain.
- **`assets/css/main.scss:36`** — `@use "custom";` sits last, after `@use "themes";`. Tokens redeclared in `_custom.scss` are emitted later and win on source order. Confirmed against the repo's actual file.
- **`.planning/research/PITFALLS.md` lines 295–330** — the pre-measured contrast tables (ink-on-cream, link-colour trap). Every value in this document came from there; the planner should not re-derive them.
- **`.planning/research/ARCHITECTURE.md` lines 260–280** — the proposed token file shape (primitives → semantic re-point). Adopt the structure; the hexes there were explicitly illustrative placeholders and are superseded by this document.

### Established Patterns

- **Unlayered beats layered.** The gem's `tailwind.css` is entirely inside `@layer`; `main.css` is unlayered and loads second, so `_custom.scss` wins with no `!important` and no specificity fights.
- **The one exception:** `!important` inside a layer still beats unlayered normal declarations. The gem's `@layer components` Bootstrap-compat utilities (`.mt-5`, `.mt-3`, `.w-100`, `.d-none`, …) cannot be overridden from `_custom.scss` at all. `_layouts/default.liquid` wraps content in `.container.mt-5`, so page top spacing needs `!important`.
- **Token re-pointing is the core pattern** — never restyle a gem-rendered element directly; change the token it already reads. Reaches prebuilt CSS that cannot be recompiled.
- The repo's `AGENTS.md`/`CLAUDE.md` describe the upstream demo, not this site. `_sass/` is **not** forbidden here (`test/style_contract.js` has that block commented out), and the effective baseurl is **empty**, not `/al-folio`.

### Integration Points

- `_config.yml:474` `enable_darkmode: true` → `false`. **Hard ordering constraint:** `html[data-theme="dark"]` has specificity (0,1,1) and outranks `:root` (0,1,0), and the gem's dark block stays in `main.css`. This must land in the same commit as the tokens or a dark-mode visitor gets a genuinely broken half-repainted page.
- `_config.yml:478` `enable_progressbar: true` → `false`. The progress bar reads `--global-theme-color`.
- `_config.yml:99` `footer_fixed: true` → `false`.
- `_config.yml:106` `max_width: 930px` — **leave alone.** The measure is Phase 3's decision (TYPE-04).
- Deploy verification: re-date the `--deploy-proof` canary in `_sass/_custom.scss` and confirm it reaches the served CSS. Procedure in `docs/DEPLOYMENT.md` from Phase 1.
- PurgeCSS does not set `variables: true`, so the custom-property layer is safe. Verified empirically — the live CSS today already begins `:root{color-scheme:light;--global-bg-color: #ffffff;…}`.

</code_context>

<deferred>
## Deferred Ideas

- **Dark theme** — out of milestone entirely (THEME-01). TOKEN-05 keeps the structure additive so it needs no restructuring later.
- **Hand-drawn / textured underline stroke** — Phase 4, once the mark vocabulary exists. Phase 2 ships the plain hairline.
- **Highlighter-wash link hover** — considered and set aside. Strong notebook fit, but it composites over Phase 4 texture and needs its own text-over-tint ratio. Revisit in Phase 4 if the mark vocabulary wants it.
- **Lifted card surfaces (`--paper-50`)** — cut this phase. If a later phase genuinely needs a lift tone, it is one line plus a cap edit.
- **Per-page or per-section accent variation** — never raised, and explicitly excluded by the one-accent cap.

</deferred>

---

*Phase: 02-palette-and-design-tokens*
*Context gathered: 2026-09-14*

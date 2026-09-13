# Phase 2: Palette and Design Tokens - Research

**Researched:** 2026-09-14
**Domain:** CSS custom-property token architecture over a prebuilt Jekyll gem theme (al_folio_core 1.0.15); WCAG contrast; cascade/specificity/layer interaction
**Confidence:** HIGH (every load-bearing claim below was verified against the unpacked gem, the live served CSS, or a computation run here — not from training data)

<user_constraints>

## User Constraints (from CONTEXT.md)

### Locked Decisions

#### Paper and ink values

All values are taken from the pre-measured contrast table in `.planning/research/PITFALLS.md`, so no re-measurement is required and the ROADMAP's 30-minute bikeshedding box holds.

- **Ground: `#faf6ee` cream.** Chosen specifically because every ratio in the research table was measured against it. Warm at a glance, still reads as paper rather than a tinted panel.
- **Two paper steps only** — `--paper-100` `#faf6ee` (ground: body, navbar, cards) and `--paper-200` `#f2ebdd` (recess: code blocks, footer).
- **`--paper-50` is deliberately NOT declared.** It was considered and dropped once cards were decided as flush — a token with no consumer is exactly the drift TOKEN-06 exists to prevent. Re-adding it later is one line and must be a visible edit to the cap.
- **Body ink: `#2b2621`** (13.90:1 on cream). Warm-toned, reads as ink rather than `#000`. Large headroom so it survives Phase 4 texture compositing.
- **Headings take a darker ink: `#1f1b16`** (15.88:1). Hierarchy is carried by size, weight *and* ink depth. This second lever exists specifically to help Phase 7's greyscale-plus-blur test, where headings must remain the strongest shapes.
- **One muted ink step: `#5c5349`** (6.99:1), used by `.entry-year`, `.entry-meta`, `.entry-status` and `.subject-grade` alike. A second, fainter step (`#6b6259`, 5.54:1) was considered and rejected — 5.54 is the research's stated floor and leaves no headroom once Phase 4 texture composites underneath.

#### Accent colour

- **Iron-gall blue `#1d4ed8`** replaces the gem's purple `#b509ac`. 6.22:1 on cream. Chosen as the literal notebook move — blue pen ink on cream paper — where the cool/warm tension reads as handwriting rather than as a colour scheme. Oxblood `#9a3412` was the runner-up and is the agreed fallback if blue proves too loud on the final composited ground.
- **Exactly one accent colour is permitted.** Research marker #5 allows up to two; one is stricter and chosen deliberately for deadline safety. A second accent requires editing both the token file and its written cap.
- **Code block text is body ink, not the accent.** The gem ships `pre { color: var(--global-theme-color) }`, which on a warm palette renders whole blocks in link colour — visibly a bug, and it breaks the Phase 7 blur test by making code outweigh headings. Override it. The accent must mean exactly one thing: this is interactive.
- **Hover thickens the underline; the colour holds.** No second accent value, nothing extra to keep in contrast, and it sets up Phase 4's hand-drawn rule directly.

#### Surfaces and footer

- **`footer_fixed: false`** in `_config.yml` (currently `true` at L99), switching to the gem's `footer.sticky-bottom` — a bordered, background-free footer. The footer stops being a bar and becomes the bottom of the page.
- **Re-point the three footer tokens anyway**, belt-and-braces: `--global-footer-bg-color` → `--paper-200`, `--global-footer-text-color` → `--ink-700`, `--global-footer-link-color` → `--ink-900`. If any background leaks through, it must be paper. This directly serves success criterion 1 ("no dark-grey bar pinned to the bottom") — the gem default is `#1c1c1d`.
- **Cards sit flush** — `--global-card-bg-color` → `--paper-100`, identical to the body. A card is not a physical object sitting on a notebook page.
- **Structure is carried by hairline rules, not tone.** `--global-divider-color` → `--rule-200` `#d9cfba`. The navbar takes a bottom rule rather than a tonal band. Tone steps are reserved for surfaces that genuinely contain content (code blocks, footer). Rationale: at these low-contrast paper values, tone steps alone go near-invisible on a phone at low brightness and structure would disappear in Phase 7's mobile check.
- **All 29 `--global-*` tokens are re-pointed**, not just the ~13 that drive visible surfaces. The unused ones (tip/warning/danger blocks, newsletter, distill, back-to-top) are derived from the paper/ink primitives. Leaving 16 gem hexes live means a future page using a callout box silently renders purple-and-grey on cream. Success criterion 5 requires one token file with no literals outside it.

#### Links and quiet text

- **Underline style: hairline, offset below the baseline.** `text-decoration-thickness: 1px` with `text-underline-offset` pushing it clear of descenders. This matters concretely for Vietnamese — `ạ` and `ợ` carry marks below the baseline, and a default underline crowds them in the site owner's own name.
- **Body copy links only.** Navbar and footer links are exempt: position already signals clickability in navigational furniture, and an underlined nav row reads as a 1997 page. This matches success criterion 3's wording exactly ("every link in body copy").
- **`opacity` is removed from all four classes** currently using it in `_sass/_custom.scss` — `.entry-year` (0.6), `.entry-meta` (0.75), `.entry-status` (0.7), `.subject-grade` (0.75) — each replaced by the single muted ink token. Note `.subject-grade` is a fourth case not named in TOKEN-03 or criterion 4; it has the same defect and is in scope.
- **Type scale and spacing tokens get names AND provisional values now.** `--step-0..3` and `--space-1..4`, derived from the gem's current sizes. Phase 3 re-tunes the *values* against the real typeface without rewriting a single rule. This satisfies TOKEN-02 and criterion 5 now while avoiding designing a scale against a typeface that is about to be replaced.

#### The written cap (TOKEN-06)

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

### Deferred Ideas (OUT OF SCOPE)

- **Dark theme** — out of milestone entirely (THEME-01). TOKEN-05 keeps the structure additive so it needs no restructuring later.
- **Hand-drawn / textured underline stroke** — Phase 4, once the mark vocabulary exists. Phase 2 ships the plain hairline.
- **Highlighter-wash link hover** — considered and set aside. Strong notebook fit, but it composites over Phase 4 texture and needs its own text-over-tint ratio. Revisit in Phase 4 if the mark vocabulary wants it.
- **Lifted card surfaces (`--paper-50`)** — cut this phase. If a later phase genuinely needs a lift tone, it is one line plus a cap edit.
- **Per-page or per-section accent variation** — never raised, and explicitly excluded by the one-accent cap.

</user_constraints>

<phase_requirements>

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| TOKEN-01 | Full palette by redeclaring the gem's `--global-*` custom properties; one change repaints every page, navbar, footer and code blocks; no gem file shadowed | §"The seam", §"Complete token inventory" (all 30 tokens with gem default, consumer count and consuming file), §"Pattern 1". The seam is `_sass/_custom.scss`, already `@use`d last from the site's `assets/css/main.scss` (the one acknowledged override, already in `.al-folio-overrides.yml`). Verified: the gem's `--global-*` set is defined *only* in `_sass/_themes.scss`, compiled into `main.css`, which is the last unlayered stylesheet in `<head>`. |
| TOKEN-02 | Type scale and spacing exist as named tokens, not repeated values | §"Provisional scale values measured off the gem" — real gem sizes extracted so `--step-*` / `--space-*` start at today's rendering and Phase 3 re-tunes values only |
| TOKEN-03 | No text de-emphasised with `opacity` | §"Pitfall 3". Exactly 4 hits, all in `_sass/_custom.scss` (lines 39, 48, 65, 74); gem `opacity` uses are non-text except `.navbar{opacity:.95}` (§"Pitfall 8"). Replacement colour `#5c5349` verified at 6.99:1 |
| TOKEN-04 | Dark-mode toggle gone; `enable_darkmode: false` in the same change | §"Pitfall 1" — the **critical correction**: turning the flag off does NOT satisfy criterion 2. The gem's `html[data-theme="dark"]` block stays in `main.css` regardless of the flag. Solution verified: selector-list `:root, html[data-theme="dark"] { … }` |
| TOKEN-05 | Tokens structured so dark can return without restructuring | §"Pattern 2" — two-tier primitives → semantic, with the `html[data-theme="dark"]` selector already present in the list as the future hook |
| TOKEN-06 | Token vocabulary deliberately capped, in writing | §"Pattern 3" — the cap block lives in the same file; §"Validation Architecture" gives a grep that counts declared primitives against the stated cap |
| GROUND-01 | Warm paper ground across all seven pages | §"The seven pages" (real URLs), §"Complete token inventory" — `--global-bg-color` reaches `body` from BOTH the prebuilt `tailwind.css` and the gem's `_layout.scss`, so one token covers every page at once |
| GROUND-04 | Links underlined | §"Pattern 4" — scope `.post article a`; verified that both `page.liquid` and `about.liquid` wrap content in `.post > article`. The gem/tailwind `text-decoration:none` is inside `@layer base`, so an unlayered rule beats it with no `!important` |

</phase_requirements>

## Summary

**The stop sign in `AGENTS.md`/`CLAUDE.md` does not apply to this repo, and this is verified, not assumed.** `test/style_contract.js` lines 72–86 carry the forbidden-path loop **commented out**, with an in-file comment saying so ("DISABLED FOR THIS SITE… This site owns its design, so `_layouts`, `_includes` and `_sass` are expected to exist here"). `unit-tests.yml` — the only workflow that ever ran that check — was deleted in Phase 1; the three surviving workflows are `deploy.yml`, `prettier.yml` and `broken-links-site.yml`. `node test/style_contract.js` was run here and passes today with `_sass/` present. `_sass/_custom.scss` already exists and already ships to production (the `--deploy-proof` canary is in the live CSS at byte ~25942). **Criterion 4's `grep -rn "opacity" _sass/` is the correct, working command for this repo**; it currently returns exactly four hits, all in `_sass/_custom.scss`.

The mechanism for the repaint is token re-pointing in `_sass/_custom.scss`, and it works because of a cascade fact verified against the real artifacts: the gem's prebuilt `assets/css/tailwind.css` is **entirely inside `@layer`** (theme/base/components/utilities/properties) and *consumes* `var(--global-*)` without ever defining any of them, while `main.css` — which contains the gem's `_themes.scss` (the sole definition site) followed by `_custom.scss` — is **unlayered and loads last** in `<head>`. Unlayered normal declarations beat every layered normal declaration, so `_custom.scss` wins with no `!important` and no specificity fight. The single exception is the 24 `!important` declarations inside tailwind's `@layer components` (e.g. `.mt-5{margin-top:3rem!important}`), which an unlayered normal declaration cannot beat.

Two corrections to inherited numbers, and one structural surprise. **(1) There are 30 `--global-*` tokens on `:root`, not 29** — `ROADMAP.md` and `STACK.md` both say 29 while `STACK.md`'s own list enumerates 30; the gem's `_sass/_themes.scss` and the live served CSS both contain 30. The dark block has 29 (it omits `--global-highlight-color`). **(2) `--rule-200` `#d9cfba` measures 1.43:1 on cream** — computed here — which is decorative-only under WCAG 1.4.11, so any rule doing genuine structural work (the `.subject` separator, already flagged in PITFALLS at 1.26:1) needs a second, stronger rule token around `#9c8b6e` (3.08:1). **(3) `enable_darkmode: false` alone does not satisfy success criterion 2** — the flag removes the toggle button, `theme.js` and the dark Pygments sheet, but `html[data-theme="dark"]{ --global-bg-color:#1c1c1d; … }` remains compiled into `main.css` and will still repaint the page if someone forces the attribute in DevTools, exactly as the criterion tests. The fix is to write the semantic map under a **selector list** `:root, html[data-theme="dark"]`, which ties the gem's (0,1,1) specificity and wins on source order.

**Primary recommendation:** Create `_sass/custom/_tokens.scss` (or a single clearly-delimited block at the top of `_custom.scss`) holding every literal in the design, emit the semantic `--global-*` map under the selector list `:root, html[data-theme="dark"]`, flip the three `_config.yml` flags in the same commit, and add the six gem-behaviour overrides listed in §"Don't Hand-Roll" — `pre`/`code` colour, `.card` box-shadow, `.navbar` opacity, headings ink, body-copy underline, `:focus-visible`. Verify with `node .planning/tools/contrast.js` locally and the live-site grep from `docs/DEPLOYMENT.md`; **do not run `npm run test:visual`** (see §"Pitfall 9").

## Standard Stack

### Core

| Component | Version | Purpose | Why standard |
|---|---|---|---|
| CSS custom properties on `:root` | native | The token layer | The gem already consumes 30 of them; both the gem's Sass *and* the un-recompilable prebuilt `tailwind.css` read the same names. Nothing else reaches both. |
| `_sass/_custom.scss` | site-owned | The only write surface | Already exists, already `@use`d last from `assets/css/main.scss:36`, already proven to ship (deploy canary in live CSS) |
| `assets/css/main.scss` | site-owned (acknowledged override) | Loads `custom` last | Already recorded in `.al-folio-overrides.yml` with `upstream_sha256` / `local_sha256` / `acknowledged_at: 2026-09-10`. No new override debt is created by this phase. |
| `_config.yml` | site-owned | Three visual levers | `enable_darkmode` (L474), `enable_progressbar` (L478), `footer_fixed` (L99) are Liquid gates, not CSS |
| Node (Volta) | present | Contrast arithmetic, token audits | No dependency needed — a 10-line WCAG function, written and validated below |

### Supporting

| Tool | State on this machine | When to use |
|---|---|---|
| `node test/style_contract.js` | passes today | Sanity check after `_config.yml` edits (asserts `theme:`, plugin list, SRI pins — none of which this phase touches). Not run by any CI workflow any more. |
| `npx prettier _sass --write` | devDependency present | **Required before push.** `prettier.yml` runs `prettier . --check` on every push with no path filter; `.prettierignore` does not exclude `_sass/`. A malformed SCSS file fails the gate. |
| `curl` + live-site grep | proven in Phase 1 | The real verification path (see §"Verification reality"). |
| Docker (`docker compose`) | `C:\Program Files\Docker\...\docker.exe` present | The **only** local build route — see §"Pitfall 10" |

### Alternatives Considered

| Instead of | Could use | Tradeoff |
|---|---|---|
| Re-pointing `--global-*` | Shadowing the gem's `_sass/_themes.scss` / `_variables.scss` locally | Works, but adds a permanent `.al-folio-overrides.yml` entry per file and drifts on every gem bump. TOKEN-01 explicitly forbids it ("no gem file is shadowed"). |
| `:root, html[data-theme="dark"]` selector list | `html:root { … }` (0,1,1) or `!important` | Both work mechanically, but the selector list *is* the TOKEN-05 hook — the future dark theme edits nothing but the primitives inside a new block. `!important` would have to be removed later. |
| `_sass/custom/_tokens.scss` (subdirectory) | one file `_sass/_custom.scss` | Either is fine. Criterion 5 says "one token file" — a subdirectory is cleaner if `_custom.scss` grows, but requires adding `@use "custom/tokens";` and Sass partial resolution from `_sass/custom/_tokens.scss`. Flat is lower risk this phase. |

**Installation:** none. No new dependency is needed or wanted.

## Architecture Patterns

### The seam (verified end to end)

```
<head> load order — measured from the live served HTML of https://phamhakhanhchi.com/
 1  /assets/css/tailwind.css          @layer theme/base/components/utilities/properties   CONSUMES --global-*
 2  fontawesome / academicons / scholar-icons  (CDN)
 3  fonts.googleapis.com  Roboto | Roboto+Slab | Material+Icons
 4  /assets/css/jekyll-pygments-themes-github.css   id=highlight_theme_light, media=""   unlayered
 5  /assets/css/main.css              unlayered  <-- gem _themes.scss DEFINES --global-*, then _custom.scss
 6  /assets/css/jekyll-pygments-themes-native.css   media="none"  (dark only; disappears with enable_darkmode:false)
    inline <style> :root{--max-content-width:930px}   (from site.max_width)
```

Inside `main.css` the order is `_themes.scss` → layout → typography → navbar → footer → blog → publications → components → utilities → tabs → teachings → typograms → **`_custom.scss` last** (`assets/css/main.scss:36`). So `_custom.scss` wins every same-specificity tie by source order, and beats all of `tailwind.css` by being unlayered.

### Pattern 1 — Token re-pointing (the core pattern)

**What:** Never restyle a gem-rendered element directly; change the token it already reads.
**Why it covers everything in criterion 1 at once:** `body{background-color:var(--global-bg-color)}` appears in *both* `tailwind.css` (`@layer base`) and the gem's `_layout.scss`. `.card`, `.dropdown-menu`, `.btn`, `.table`, `a`, `pre`, `code`, the navbar and the footer all read tokens. One `:root` block repaints all of them simultaneously — there is no intermediate state where the navbar is cream and the cards are white.

### Pattern 2 — Two tiers, one selector list (TOKEN-05 + criterion 2 together)

```scss
// _sass/_custom.scss  — Tier 1: primitives. The ONLY colour literals in the design.
:root {
  /* paper — cap: 2 tones */
  --paper-100: #faf6ee; /* ground */
  --paper-200: #f2ebdd; /* recess: code, footer */

  /* ink — cap: 4 steps.  ratios measured against --paper-100 */
  --ink-900: #1f1b16; /* 15.88:1  headings */
  --ink-800: #2b2621; /* 13.90:1  body */
  --ink-700: #3d3630; /* 11.01:1  footer text */
  --ink-500: #5c5349; /*  6.99:1  muted meta */

  /* accent — cap: 1 colour */
  --accent-600: #1d4ed8; /* 6.22:1 on paper-100; 2.24:1 vs --ink-800 -> MUST be underlined */

  /* rules */
  --rule-200: #d9cfba; /* 1.43:1 — DECORATIVE ONLY, never load-bearing */
  --rule-500: #9c8b6e; /* 3.08:1 — structural separators (WCAG 1.4.11) */
}

// Tier 2: the gem's semantic contract.  The selector list is load-bearing:
// html[data-theme="dark"] is (0,1,1) and ties the gem's dark block, winning on
// source order — so forcing data-theme="dark" repaints nothing (criterion 2),
// and a future dark theme re-points ONLY the primitives inside its own block.
:root,
html[data-theme="dark"] {
  color-scheme: light;
  --global-bg-color: var(--paper-100);
  /* …all 30, see inventory… */
}
```

**Verified mechanics:** CSS specificity is computed **per selector in a list**, not for the list as a whole. For an element matching `html[data-theme="dark"]`, our rule's winning selector is (0,1,1) — identical to the gem's — and ours is emitted later in the same stylesheet, so it wins. Confidence HIGH (CSS Selectors L3/L4 specificity rules; behaviour is not browser-variant).

### Pattern 3 — The cap lives in the file (TOKEN-06)

Put the cap block as a comment immediately above the primitives, so adding a fifth ink or a second accent requires editing a number that is three lines from the declaration. §"Validation Architecture" gives a grep that counts declarations against it.

### Pattern 4 — Body-copy-only link underline (GROUND-04, criterion 3)

Both `page.liquid` and `about.liquid` (the only two layouts this site uses) wrap page content identically:

```liquid
<div class="post">
  <header class="post-header"> … </header>
  <article>{{ content }}</article>
</div>
```

So `.post article a` is a precise, verified scope that excludes the navbar (`header.liquid`, outside `.post`), the footer (`footer.liquid`, outside `.post`) and the site's own `.cv-actions .btn`. Exempt buttons explicitly: `.post article a.btn { text-decoration: none; }`.

The base `a{text-decoration:none}` lives in tailwind's `@layer base`; the gem's `a:hover{text-decoration:underline}` is unlayered in `main.css`. An unlayered `_custom.scss` rule beats both.

### Pattern 5 — Configuration as a design lever (three flags, one commit)

| Key | Line | Now | Target | What it actually gates (verified in gem Liquid) |
|---|---|---|---|---|
| `footer_fixed` | `_config.yml:99` | `true` | `false` | `footer.liquid:14` — swaps `<footer class="fixed-bottom">` for `<footer class="sticky-bottom mt-5">`; `default.liquid:36` adds `body.sticky-bottom-footer`, and the gem's `_layout.scss:27` already zeroes `body{padding-bottom:70px}` for it. No dead space to clean up. |
| `enable_darkmode` | `_config.yml:474` | `true` | `false` | `head.liquid:128` — drops `theme.js` **and** the dark Pygments sheet **and** the `initTheme()` call; `header.liquid:127` — drops the `#light-toggle` button. Does **not** remove the CSS dark block (see Pitfall 1). |
| `enable_progressbar` | `_config.yml:478` | `true` | `false` | `header.liquid:141` (the `<span class="progress-bar">` markup) and `scripts.liquid:107` (`progress-bar.js`). The bar reads `--global-theme-color`. |

`_config.yml` is **not** in `deploy.yml`'s `paths-ignore` denylist, so these edits deploy normally.

### Anti-Patterns to Avoid

- **Setting `--global-*` only on `:root`.** Leaves criterion 2 failing. Use the selector list.
- **Re-pointing `--global-card-bg-color` and calling cards done.** `.card`'s drop shadow is a hardcoded literal in tailwind (see Pitfall 4).
- **Putting the design's literals anywhere but the token block.** Criterion 5 is enforceable by grep; scatter one hex into a component rule and it fails.
- **Deleting or folding in `--deploy-proof`.** STATE.md records it as deliberately retained. A "token audit removes unused properties" pass would delete it. Leave it in its own block with its comment.

## Don't Hand-Roll

| Problem | Don't build | Use instead | Why |
|---|---|---|---|
| Repainting navbar / dropdowns / cards / buttons / tables / footer | Per-component colour rules | Re-point `--global-*` | They already read the tokens — `.dropdown-menu`, `.dropdown-item`, `.card`, `.btn`, `.btn-outline-primary`, `.table th/td`, `.table-hover tbody tr:hover` all resolve through `var(--global-…)` in the prebuilt tailwind |
| Active-nav marker that survives greyscale | A new bespoke rule | The gem already ships one | `_navbar.scss:120-127`: `.navbar-nav .nav-item.active > .nav-link { background-color: inherit; font-weight: bolder; color: var(--global-theme-color) }`. **`font-weight: bolder` is already a non-colour marker.** Optionally add a 2px bottom rule; do not invent a mechanism. |
| Footer with no dark bar | Custom footer CSS | `footer_fixed: false` + the three footer tokens | `footer.sticky-bottom` is background-free with `border-top: 1px solid var(--global-divider-color)` |
| Contrast measurement | Manual DevTools picking | The 10-line script in §"Code Examples" | Reproduces every ratio in `PITFALLS.md` exactly (validated below); scriptable, so criterion 4 and QA-01 become repeatable |
| Body padding under a sticky footer | A `padding-bottom: 0` override | Nothing — gem handles it | `_layout.scss:27` `body.sticky-bottom-footer { padding-bottom: 0 }` |

**But these six DO need hand-written rules** — no token exists for them:

| # | Rule needed | Why (verified source) |
|---|---|---|
| 1 | `pre, code { color: var(--ink-800); }` | `gem _sass/_utilities.scss:26` `pre{color:var(--global-theme-color)}` and `:47` `code{color:var(--global-theme-color)}`. Both would render in link colour. |
| 2 | `.card { box-shadow: none; }` (and consider `.hoverable:hover`) | `tailwind.css` hardcodes `.card{…box-shadow:0 2px 5px #00000029,0 2px 10px #0000001f}` — a literal, not a token. Flush cards need this removed or the card floats above the paper. `_components.scss:56-67` `.hoverable:hover` adds `translateY(-4px)` + two more black shadows. |
| 3 | `.navbar { opacity: 1; }` | `gem _sass/_navbar.scss:11` `opacity: 0.95` on the whole fixed bar — it fades navbar text by 5% and lets scrolled content smear through. Not caught by criterion 4's grep (it is in the gem, not `_sass/`), but it is text faded by opacity. |
| 4 | `h1,h2,h3,… { color: var(--ink-900); }` | `gem _sass/_typography.scss:7-19` paints `p,h1..h6,em,div,li,span,strong` with a single `--global-text-color`. A separate heading ink is impossible through tokens alone. Specificity (0,0,1) vs (0,0,1) — `_custom.scss` wins on source order. |
| 5 | `.post article a { text-decoration: underline; text-decoration-thickness: 1px; text-underline-offset: …; }` + `:hover` thickening | GROUND-04. See Pattern 4. |
| 6 | `:focus-visible { outline: 2px solid var(--ink-900); outline-offset: 2px; }` | Nothing in the gem defines one. PITFALLS is explicit: ≥2px, `outline-offset: 2px`, never `box-shadow` alone. |

## Common Pitfalls

### Pitfall 1: `enable_darkmode: false` does not satisfy criterion 2 — HIGH severity, easy to miss

**What goes wrong:** The flag is flipped, the toggle disappears, the page looks right, and criterion 2's second clause ("forcing `data-theme="dark"` in DevTools changes no colour") still fails.
**Why:** `enable_darkmode` is a Liquid gate in `head.liquid:128` / `header.liquid:127`. It controls which *scripts and links* are emitted. The CSS block `html[data-theme="dark"]{ color-scheme:dark; --global-bg-color:#1c1c1d; --global-theme-color:#2698ba; … }` is compiled from the gem's `_sass/_themes.scss:76` into `main.css` unconditionally — confirmed present in the **live served CSS today**.
**How to avoid:** the selector list in Pattern 2. Also re-declare `color-scheme: light` there (the gem's dark block sets `color-scheme: dark`, which changes scrollbars and form-control rendering), and neutralise `.only-light{display:none}` / `.only-dark{display:block}` if any page ever uses those classes (none does today).
**Warning sign:** DevTools shows `--global-bg-color` resolving to `#1c1c1d` with the attribute forced.

### Pitfall 2: 30 tokens, not 29

`ROADMAP.md`, `STACK.md:17` and CONTEXT all say 29. The gem's `_sass/_themes.scss` `:root` block and the live `main.css` both contain **30**; `STACK.md`'s own enumeration (lines 22–30) lists 30 when counted. The `html[data-theme="dark"]` block has **29** — it omits `--global-highlight-color`. Plan for 30; a missed token is a live gem hex.

### Pitfall 3: the `opacity` grep is narrower than it looks — and there is a fourth class

`grep -rn "opacity" _sass/` today returns exactly four hits, all in `_sass/_custom.scss`: `.entry-year` (L39, 0.6), `.entry-meta` (L48, 0.75), `.subject-grade` (L65, 0.75), `.entry-status` (L74, 0.7). **`.subject-grade` is not named in TOKEN-03 or criterion 4** but has the same defect and is in scope per CONTEXT. Also in `_custom.scss`: `.subject { border-color: color-mix(in srgb, currentColor 12%, transparent) }` — PITFALLS measured that at **1.26:1**, and it separates a subject from its grade, so it is structural. Re-point it to `--rule-500` (3.08:1) rather than leaving a `color-mix` literal, which would also violate criterion 5.

### Pitfall 4: flush cards still float

`.card` in the prebuilt tailwind carries `box-shadow: 0 2px 5px #00000029, 0 2px 10px #0000001f` as literals. Re-pointing `--global-card-bg-color` to `--paper-100` makes the card the same colour as the page **and leaves the shadow**, so a flush card reads as an invisible box with a grey halo. The projects page renders `.card`.

### Pitfall 5: `--rule-200` is decorative-only

Computed here: `#d9cfba` on `#faf6ee` = **1.43:1**. WCAG 1.4.11 wants 3:1 for a graphical object needed to understand content. The gem's own default (`rgba(0,0,0,0.1)` over white) is similarly weak, so this is not a regression — but CONTEXT says "structure is carried by hairline rules, not tone", which puts weight on the rules. Two tokens resolve it cleanly:

| Candidate | on `#faf6ee` | Use |
|---|---|---|
| `#d9cfba` | 1.43:1 | decorative hairlines (navbar underline, `<hr>` flourish) |
| `#bfb39a` | 1.92:1 | still decorative |
| `#9c8b6e` | **3.08:1** | structural separators — `.subject`, `.entry-group` boundaries |
| `#8c8577` | 3.40:1 | structural, cooler |

### Pitfall 6: PurgeCSS runs only in production — but the token layer is safe

`purgecss.config.js` sets neither `variables: true` nor `fontFace`/`keyframes`, so custom properties survive (PurgeCSS defaults). **Empirically confirmed**: `--deploy-proof`, an entirely unreferenced custom property, is present in the live served CSS. What *is* at risk is any new **class** that appears only in an SVG or is injected by JS. This phase adds no such class, but note one live observation: `sticky-bottom` is **absent** from today's served `main.css` — PurgeCSS removed the `footer.sticky-bottom` rules because no HTML uses that class while `footer_fixed: true`. Flipping the flag puts the class into `_site/**/*.html` before PurgeCSS scans, so the rules return. Nothing to safelist; just do not flip the flag and the footer CSS in separate deploys.

### Pitfall 7: `!important` inside `@layer components` cannot be beaten from `_custom.scss`

Verified: tailwind's `@layer components` contains **24** `!important` declarations, including `.mt-5{margin-top:3rem!important}` and `.mt-3{margin-top:1rem!important}`. `default.liquid:36` wraps all content in `<div class="container mt-5">`. Any page-top spacing change in a later phase needs `!important`. Nothing in Phase 2 requires it — but do not be surprised.

### Pitfall 8: gem-side `opacity` that criterion 4's grep will not catch

`grep -rn "opacity" _sass/` only sees this repo. The gem has `_navbar.scss:11 opacity: 0.95` (the whole fixed navbar) and `_utilities.scss:277 opacity: 0.45` (`.af-table-pagination button:disabled` — no consumer on this site). The navbar one is real and visible; override it.

### Pitfall 9: do NOT run or update the Playwright visual tests

`visual-regression.yml` was **deleted in Phase 1**; `test/visual/` and the two npm scripts were deliberately kept for a future TEST-01 (v2). The config is unusable here as written: `webServer` runs `jekyll serve --baseurl /al-folio`, `baseURL` is `http://127.0.0.1:4000/al-folio`, and the specs target upstream demo routes and content this site deleted. **This site's baseurl is empty.** There is also no committed snapshot baseline for this site. Running `npm run test:visual:update` would write snapshots of a site that does not exist at those URLs. **Correct workflow for this phase: leave the visual suite entirely alone.** Regression checking is the seven-page manual sweep in §"Verification reality". Note this explicitly in the plan so nobody "fixes" a red suite.

### Pitfall 10: there is no local Jekyll build on this machine

`ruby`, `gem` and `bundle` are absent from PATH and no Ruby install was found under `C:\`. `_site/` does not exist. **Docker is installed** (`C:\Program Files\Docker\...\docker.exe`) and `docker-compose.yml` is present, so `docker compose up -d` is the only local preview route — and per `CLAUDE.md` it serves from container-local `/tmp/_site` on `:8080`, and the upstream compose file expects the `/al-folio` baseurl (this site's is empty, so check `http://127.0.0.1:8080/`). Budget for this: if Docker preview is not wanted, the phase is verified against the deployed site, which Phase 1 made safe and fast (~2–3 min from push; poll, and always bust the cache with `?cb=$(date +%s)`).

### Pitfall 11: Prettier will gate the push

`prettier.yml` runs `prettier . --check` on every push with **no path filter**, and `.prettierignore` does not exclude `_sass/`. Run `npx prettier _sass _config.yml --write` before committing. Prettier normalises hex-colour case in SCSS — write the ratio comments as end-of-line `/* … */` and re-read them after formatting (STATE.md records Prettier mangling a load-bearing sentence in Phase 1).

### Pitfall 12 (latent, not this phase): Pygments comment colour

`jekyll-pygments-themes-github.css` is loaded on every page (`head.liquid:62`) and hardcodes `.highlight .c{color:#999988}` — **2.44:1 on `#f2ebdd`**. It has no `.highlight` background rule, so the code-block ground comes purely from `--global-code-bg-color` (good). **No page on this site renders a code block or inline code today** (zero fenced blocks; the only backticks in `_pages/` are inside a YAML comment in `projects.md`). So criterion 1's "code blocks" clause cannot be verified on a real page — verify it by reading the computed value of `--global-code-bg-color`, or by adding a throwaway local page. Re-pointing the token is still required by TOKEN-01.

## Code Examples

### The contrast tool (validated here against PITFALLS.md)

Write this to `.planning/tools/contrast.js` (or `bin/contrast.js`) — zero dependencies, Node only.

```js
// WCAG 2.x relative luminance + contrast ratio.
// usage: node contrast.js "#fg" "#bg" ["#fg2" "#bg2" ...]
function lum(hex) {
  const h = hex.replace("#", "");
  const v = h.length === 3 ? h.split("").map((c) => c + c).join("") : h;
  const c = [0, 2, 4]
    .map((i) => parseInt(v.substr(i, 2), 16) / 255)
    .map((x) => (x <= 0.03928 ? x / 12.92 : Math.pow((x + 0.055) / 1.055, 2.4)));
  return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2];
}
function ratio(a, b) {
  const L1 = lum(a), L2 = lum(b);
  const hi = Math.max(L1, L2), lo = Math.min(L1, L2);
  return (hi + 0.05) / (lo + 0.05);
}
const args = process.argv.slice(2);
for (let i = 0; i < args.length; i += 2) {
  const r = ratio(args[i], args[i + 1]);
  console.log(`${args[i]} on ${args[i + 1]} = ${r.toFixed(2)}:1  ${r >= 4.5 ? "AA-text" : r >= 3 ? "AA-large/non-text" : "FAIL"}`);
}
```

**Validation run (actual output from this research session):**

```
#2b2621 on #faf6ee = 13.90:1  AA-text      <- matches PITFALLS 13.90
#1f1b16 on #faf6ee = 15.88:1  AA-text      <- matches PITFALLS 15.88
#5c5349 on #faf6ee =  6.99:1  AA-text      <- matches PITFALLS 6.99
#6b6259 on #faf6ee =  5.54:1  AA-text      <- matches PITFALLS 5.54
#1d4ed8 on #faf6ee =  6.22:1  AA-text      <- matches PITFALLS 6.22
#9a3412 on #faf6ee =  6.78:1  AA-text      <- matches PITFALLS 6.78 (oxblood fallback)
#1d4ed8 on #2b2621 =  2.24:1  FAIL         <- matches PITFALLS 2.24 -> underline mandatory
#828282 on #faf6ee =  3.57:1  AA-large     <- matches PITFALLS 3.57 (gem default, must be re-pointed)
```

Every published figure reproduces exactly. **The palette needs no re-measurement.** New figures computed here for the `--paper-200` recess (`#f2ebdd`), which PITFALLS did not cover:

```
#2b2621 on #f2ebdd = 12.63:1   body ink in code blocks / footer
#1f1b16 on #f2ebdd = 14.43:1   headings over recess
#3d3630 on #f2ebdd = 11.01:1*  (*on paper-100; on paper-200 ≈ 10.0)
#5c5349 on #f2ebdd =  6.35:1   muted meta over recess
#6b6259 on #f2ebdd =  5.03:1
#1d4ed8 on #f2ebdd =  5.65:1   accent over recess — still clears 4.5
#d9cfba on #faf6ee =  1.43:1   FAIL — rule-200 is decorative only
#9c8b6e on #faf6ee =  3.08:1   rule-500, structural
```

### Complete token inventory (all 30, from the gem's `_sass/_themes.scss` + live CSS)

Consumer counts are `grep -c "var(--global-X)"` across the gem's `_sass/**` plus `assets/css/tailwind.css`.

| # | Token | Gem `:root` default | Gem dark default | Uses | Where it lands | Suggested target |
|---|---|---|---|---|---|---|
| 1 | `--global-bg-color` | `#ffffff` | `#1c1c1d` | 22 | `body`, `.navbar`, `.dropdown-menu`, nav hover | `var(--paper-100)` |
| 2 | `--global-code-bg-color` | `rgba(181,9,172,.05)` | `#2c3237` | 2 | `pre`, `code` | `var(--paper-200)` |
| 3 | `--global-text-color` | `#000000` | `#e8e8e8` | 53 | `p,h1..h6,em,div,li,span,strong`, `.btn`, `.dropdown-item`, `.navbar-brand`, nav links, `.card-title` | `var(--ink-800)` |
| 4 | `--global-text-color-light` | `#828282` (3.57:1 ✗) | `#828282` | 13 | `_blog.scss` ×9, `_publications.scss` ×2, `_tabs.scss`, `_teachings.scss` — **none renders on this site today** | `var(--ink-500)` |
| 5 | `--global-theme-color` | `#b509ac` | `#2698ba` | 62 | `a`, `pre`, `code`, active nav, `.btn-outline-primary`, `.table-hover` row, progress bar, `.dropdown-item:hover` | `var(--accent-600)` |
| 6 | `--global-hover-color` | `#b509ac` | `#2698ba` | 17 | `a:hover`, nav link hover, dropdown hover/active bg | `var(--accent-600)` |
| 7 | `--global-hover-text-color` | `#ffffff` | `#ffffff` | 7 | text on an accent-filled surface (`.dropdown-item.active`, `.btn-outline-primary:hover`) — carries `!important` at `_navbar.scss:93` | `var(--paper-100)` (verify ≥4.5:1 on accent: `#faf6ee` on `#1d4ed8` = 6.22:1 ✓) |
| 8 | `--global-footer-bg-color` | `#1c1c1d` | `#e8e8e8` | 1 | `footer.fixed-bottom` only | `var(--paper-200)` |
| 9 | `--global-footer-text-color` | `#e8e8e8` | `#1c1c1d` | 1 | `footer.fixed-bottom .container` | `var(--ink-700)` |
| 10 | `--global-footer-link-color` | `#ffffff` | `#000000` | 1 | `footer.fixed-bottom a` | `var(--ink-900)` |
| 11 | `--global-distill-app-color` | `#828282` | `#e8e8e8` | 0 | nothing in core (al_folio_distill) | `var(--ink-500)` |
| 12 | `--global-divider-color` | `rgba(0,0,0,.1)` | `#424246` | 31 | `hr`, `table td/th` borders, `.navbar` bottom border, `footer.sticky-bottom` top border, `.dropdown-menu` border, `.cv .card` border | `var(--rule-200)` — but see Pitfall 5 |
| 13 | `--global-card-bg-color` | `#ffffff` | `#212529` | 6 | `.card` (+ `.cv .card`) | `var(--paper-100)` |
| 14 | `--global-highlight-color` | `#b71c1c` | *(absent from dark)* | 2 | search-term highlight | derive from accent or a warm wash |
| 15 | `--global-back-to-top-bg-color` | `rgba(0,0,0,.4)` | `rgba(255,255,255,.5)` | 2 | `#back-to-top` (`back_to_top: true` at `_config.yml:26`) | ink-derived |
| 16 | `--global-back-to-top-text-color` | `#ffffff` | `#000000` | 2 | `#back-to-top` | `var(--paper-100)` |
| 17 | `--global-newsletter-bg-color` | `#ffffff` | `#e8e8e8` | 1 | newsletter form (disabled here) | `var(--paper-200)` |
| 18 | `--global-newsletter-text-color` | `#000000` | `#1c1c1d` | 2 | newsletter form | `var(--ink-800)` |
| 19–22 | `--global-tip-block{,-bg,-text,-title}` | `#42b983` / `#e2f5ec` / `#215d42` / `#359469` | dark variants | 0 in core Sass | callout blocks | derive from ink + a paper wash |
| 23–26 | `--global-warning-block{,-bg,-text,-title}` | `#e7c000` / `#fff8d8` / `#6b5900` / `#b29400` | dark variants | 0 | callout blocks | derive |
| 27–30 | `--global-danger-block{,-bg,-text,-title}` | `#c00` / `#ffe0e0` / `#600` / `#c00` | dark variants | 0 | callout blocks | derive |

Tokens **not** defined by the gem but consumed by prebuilt tailwind: none — every `--global-*` name that appears in `tailwind.css` (7 distinct) is defined in `_themes.scss`. Verified by set difference.

Separately, `--max-content-width` is injected as an inline `<style>` in `<head>` from `site.max_width` (930px). Leave alone (TYPE-04, Phase 3).

### Provisional scale values measured off the gem (TOKEN-02)

Real values in the shipped CSS today, so `--step-*` / `--space-*` can be introduced with zero visual change and re-tuned in Phase 3:

- `body` — `font-size: 1rem`, `line-height: 1.5`, `font-weight: 300`, `font-family: Roboto, sans-serif` (tailwind `@layer base`)
- `.entry-title` (site-owned) — `1.1rem`; `.entry-status` — `0.85em`
- `:not(pre) > code` — `0.82em`
- `footer.fixed-bottom` — `0.75rem`; `footer.sticky-bottom` — `0.9rem`
- `.container` gutters — `15px`; `.row` margins — `-15px`
- `.mt-5` — `3rem !important`; `.mt-3` — `1rem !important`
- `body` padding: `70px` bottom (zeroed by `sticky-bottom-footer`), `57px` top when `fixed-top-nav`; `scroll-margin-top: 66px` on headings

### The seven pages (real URLs — baseurl is EMPTY on this site)

| Page | File | URL | Notable surfaces |
|---|---|---|---|
| Home / About | `_pages/about.md` (`layout: about`) | `https://phamhakhanhchi.com/` | `.post-title` + `.font-weight-bold`, `.desc`, `.hero-*`, `.exploring` |
| Academics | `_pages/academics.md` | `/academics/` | `.entry-list`, `.entry-year`, `.entry-meta`, `.subject`, `.subject-grade` |
| Research & Learning | `_pages/research.md` | `/research/` | `.entry-*`, `.entry-status` |
| Further Reading | `_pages/further-reading.md` | `/further-reading/` | `.entry-*` |
| Projects | `_pages/projects.md` | `/projects/` | **`.card`** (shadow — Pitfall 4) |
| Activities | `_pages/activities.md` | `/activities/` | `.entry-*`, icon in `.entry-group-title` |
| CV | `_pages/cv.md` | `/cv/` | **`.btn btn-sm z-depth-0`**, `<object class="cv-embed">` |

(`_pages/404.md` → `/404.html` is an eighth page, not one of the seven; worth a glance anyway.)

## State of the Art

| Old belief (in repo docs) | Verified reality | Evidence |
|---|---|---|
| `_sass/` is forbidden here; `npm run lint:style-contract` fails if it exists | **False for this repo.** The forbidden-path loop in `test/style_contract.js` is commented out with an explanatory block; `unit-tests.yml` (its only runner) was deleted in Phase 1 | Ran `node test/style_contract.js` → "check passed" with `_sass/` present |
| Effective baseurl is `/al-folio` | **Empty.** `CLAUDE.md`/`AGENTS.md` describe the upstream demo | Live URLs resolve at `https://phamhakhanhchi.com/academics/`; STATE.md records the same correction |
| 29 `--global-*` tokens | **30** on `:root`; 29 in the dark block | Gem `_sass/_themes.scss`; live `main.css` parsed here |
| `enable_darkmode: false` removes dark mode | Removes the toggle, `theme.js` and the dark Pygments sheet. **Leaves the CSS dark block** | `head.liquid:128`, `header.liquid:127`, gem `_themes.scss:76`, live `main.css` |
| Visual-regression protects design changes | Deleted in Phase 1; suite is upstream-targeted and baseline-less for this site | `.github/workflows/` has 3 files; `test/visual/playwright.config.js` still hardcodes `/al-folio` |
| `AGENTS.md` / `CLAUDE.md` are authoritative | `docs/DEPLOYMENT.md` and `PROJECT.md` / `.planning/` are authoritative for this site | `docs/DEPLOYMENT.md` opening paragraph says so explicitly |

**Deprecated/outdated:** `unit-tests.yml`, `visual-regression.yml`, `axe.yml`, `lighthouse-badger.yml`, `update-tocs.yml`, `render-cv.yml` — all deleted. Do not write plan steps that invoke them.

## Verification reality

There is no local Ruby and no `_site/`. The verification ladder, cheapest first:

1. **Static greps (instant, no build).** `grep -rn "opacity" _sass/` → must return no text selector. `grep -rnE "#[0-9a-fA-F]{3,8}" _sass/ | grep -v _tokens` → must be empty (criterion 5). Count declared primitives against the written cap.
2. **`node contrast.js`** on every token pair — criterion 4 and 5's "each colour token carrying its measured contrast ratio in a comment" become mechanical.
3. **`npx prettier _sass _config.yml --check`** — the only CI gate this phase can trip besides deploy.
4. **Optional local preview**: `docker compose up -d` → `curl -fsS http://127.0.0.1:8080/` (note: empty baseurl here, not `/al-folio`).
5. **Deployed verification (the real one).** Push; poll `https://api.github.com/repos/hkchi-pham/phamhakhanhchi.github.io/actions/runs?head_sha=<FULL-40-char-sha>` (unauthenticated, 60/hr; a short SHA returns `total_count: 0` — a false negative). Expect ~71s to green, ~97s for `gh-pages`, ~124s until the CDN serves the new CSS. Then `curl -s "https://phamhakhanhchi.com/assets/css/main.css?cb=$(date +%s)"` and grep — the `_custom.scss` output sits near the **end** of the file (~97.6% down), not the top. Re-date `--deploy-proof` in the same commit so its value identifies this deploy.
6. **The seven-page sweep** (manual, criterion 1/2/3): open the seven URLs; in DevTools force `document.documentElement.setAttribute('data-theme','dark')` and confirm nothing changes; screenshot one page in greyscale for criterion 3.

## Open Questions

1. **Should `--global-divider-color` point at the decorative or the structural rule token?**
   - Known: it has 31 consumers spanning `hr`, table borders, navbar border, footer border, dropdown border. Decorative at 1.43:1; structural needs ~3:1.
   - Unclear: whether table cell borders on this site are structural (there are no tables in current content).
   - Recommendation: point `--global-divider-color` at `--rule-200` (matches CONTEXT verbatim), and give the *site-owned* structural separators (`.subject`, `.entry-group`) an explicit `var(--rule-500)`. Revisit in Phase 7's mobile/low-brightness check.

2. **`--global-hover-text-color` on an accent fill.** `#faf6ee` on `#1d4ed8` computes 6.22:1 ✓, so paper-on-accent is safe. But the only consumer that fires today is `.dropdown-item.active` (this site has no dropdowns in the nav) — verify before spending time on it.

3. **Where to put the token block.** Criterion 5 says "one token file". `_sass/custom/_tokens.scss` + `@use "custom/tokens";` is cleaner long-term; a delimited block at the top of `_custom.scss` is lower-risk this phase and still greppable. Recommendation: **separate file** `_sass/_tokens.scss` with `@use "tokens";` added to `assets/css/main.scss` **before** `@use "custom";` — this keeps `main.scss`'s already-acknowledged override to a two-line delta and makes criterion 5's "one token file" literally true. Note it changes `local_sha256` in `.al-folio-overrides.yml`; re-run `bundle exec al-folio upgrade overrides accept assets/css/main.scss` is **not** possible locally (no Ruby) — edit the recorded `local_sha256` by hand, or accept the drift (nothing runs the audit in CI here).

4. **Whether to also neutralise the gem's dark Pygments sheet.** With `enable_darkmode: false` it is not emitted at all (`head.liquid:128`), so no action needed — but confirm on the deployed HTML after the flag flip.

## Validation Architecture

> `workflow.nyquist_validation` is `true` in `.planning/config.json`.

### Test Framework

| Property | Value |
|---|---|
| Framework | **None, and none should be added.** Phase 1 established the convention: `.planning/phases/NN-*/verify.sh`, a flat `check <label> <expr>` list with a tally, `set -uo pipefail` (never `-e`), no test framework and no npm script |
| Config file | none — see `.planning/phases/01-deployment-guardrails/verify.sh` for the exact shape to copy |
| Quick run command | `bash .planning/phases/02-palette-and-design-tokens/verify.sh` |
| Full suite command | `bash .planning/phases/02-palette-and-design-tokens/verify.sh --live` (adds the deployed-CSS greps) |

### Phase Requirements → Test Map

| Req | Behaviour | Type | Automated command | Exists? |
|---|---|---|---|---|
| TOKEN-01 | All 30 `--global-*` re-pointed, none left at a gem literal | static grep | `for t in <30 names>; do grep -q -- "$t:" _sass/_tokens.scss \|\| echo MISSING $t; done` | ❌ Wave 0 |
| TOKEN-01 | Change reaches the served CSS | live | `curl -s "https://phamhakhanhchi.com/assets/css/main.css?cb=$(date +%s)" \| grep -c -- "--paper-100"` | ❌ Wave 0 |
| TOKEN-02 | `--step-*` / `--space-*` declared and used | static grep | `grep -c -- "--step-" _sass/_tokens.scss` and `grep -c "var(--space-" _sass/_custom.scss` | ❌ Wave 0 |
| TOKEN-03 | No `opacity` on a text selector | static grep | `grep -rn "opacity" _sass/ ; test "$(grep -rc opacity _sass/ \| ...)" -eq 0` | ✅ (criterion 4's own command) |
| TOKEN-03 | Muted ink clears 4.5:1 | computation | `node .planning/tools/contrast.js "#5c5349" "#faf6ee"` → 6.99 | ❌ Wave 0 (tool) |
| TOKEN-04 | `enable_darkmode: false` | static grep | `grep -qE "^enable_darkmode:\s*false" _config.yml` | ❌ Wave 0 |
| TOKEN-04 | Dark attribute is inert | static grep + manual | `grep -q 'html\[data-theme="dark"\]' _sass/_tokens.scss` (the override exists) + DevTools force | partly manual |
| TOKEN-04 | No toggle in the built HTML | live | `curl -s https://phamhakhanhchi.com/ \| grep -c "light-toggle"` → `0` | ❌ Wave 0 |
| TOKEN-05 | Semantic map sits under the selector list | static grep | `grep -A1 "^:root,$" _sass/_tokens.scss \| grep -q 'data-theme="dark"'` | ❌ Wave 0 |
| TOKEN-06 | Cap written down and not exceeded | static grep | `grep -c -- "--paper-" ` ≤ 2, `--ink-` ≤ 4, `--accent-` ≤ 1, and the cap comment present | ❌ Wave 0 |
| GROUND-01 | Seven pages on paper | live + manual | `for p in "" academics research further-reading projects activities cv; do curl -so /dev/null -w "%{http_code} /$p\n" "https://phamhakhanhchi.com/$p"; done` then a visual sweep | ❌ Wave 0 |
| GROUND-04 | Body-copy links underlined | static grep | `grep -q "\.post article a" _sass/_custom.scss` + greyscale screenshot (manual) | partly manual |
| Criterion 5 | No colour/length literal outside the token file | static grep | `grep -rnE "#[0-9a-fA-F]{3,8}\|[0-9.]+(rem\|px)" _sass/_custom.scss` → only inside the token file | ❌ Wave 0 |
| Supporting | `enable_progressbar: false`, `footer_fixed: false` | static grep + live | `grep -qE "^enable_progressbar:\s*false" _config.yml`; `curl -s https://phamhakhanhchi.com/ \| grep -c "fixed-bottom"` → `0` | ❌ Wave 0 |
| Regression | Prettier and style contract still pass | command | `npx prettier _sass _config.yml --check && node test/style_contract.js` | ✅ |

Genuinely manual-only (justified): the greyscale link check (criterion 3), the DevTools `data-theme` force (criterion 2's second clause), and the "no leftover white panel" visual sweep (criterion 1). No headless tooling exists on this machine for them, and PITFALLS already establishes that no CI gate covers contrast or accessibility on this repo.

### Wave 0 Gaps

- [ ] `.planning/tools/contrast.js` — the WCAG script above (covers TOKEN-03, criterion 4, criterion 5's "measured ratio in a comment", and forward to QA-01)
- [ ] `.planning/phases/02-palette-and-design-tokens/verify.sh` — copy the Phase 1 harness shape; include `--live` rows that stay red until the deploy lands
- [ ] A written list of the 30 token names in the verify script, so a missed token fails loudly rather than silently staying purple
- [ ] No framework install. No npm script. (01-VALIDATION forbids a starter-local test pipeline.)

## Sources

### Primary (HIGH confidence — inspected directly in this session)

- `al_folio_core` **1.0.15**, downloaded from `https://rubygems.org/downloads/al_folio_core-1.0.15.gem` and unpacked: `_sass/_themes.scss`, `_variables.scss`, `_layout.scss`, `_typography.scss`, `_navbar.scss`, `_footer.scss`, `_components.scss`, `_utilities.scss`, `assets/css/tailwind.css` (27,355 B, fully `@layer`ed), `assets/css/jekyll-pygments-themes-github.css`, `assets/css/main.scss`, `_includes/head.liquid`, `header.liquid`, `footer.liquid`, `_layouts/default.liquid`, `page.liquid`, `about.liquid`, `assets/js/theme.js`, `common.js`, `no_defer.js`
- Live production artifacts: `https://phamhakhanhchi.com/assets/css/main.css` (26,581 B, HTTP 200) and `https://phamhakhanhchi.com/` — parsed here for the `:root` / `html[data-theme=dark]` blocks, stylesheet load order, and the `sticky-bottom` purge observation
- Repo files: `test/style_contract.js` (forbidden-path block lines 72–86, commented out), `package.json`, `purgecss.config.js`, `.prettierrc`, `.prettierignore`, `.al-folio-overrides.yml`, `_sass/_custom.scss`, `assets/css/main.scss`, `_config.yml`, `_pages/*.md`, `test/visual/playwright.config.js`, `.github/workflows/` (3 files)
- Commands run: `node test/style_contract.js` (pass), `grep -rn "opacity" _sass/` (4 hits), `node contrast.js` (16 pairs)

### Secondary (HIGH confidence — this project's own prior research, spot-checked)

- `.planning/research/PITFALLS.md` lines 270–400 — every contrast figure independently reproduced here
- `.planning/research/ARCHITECTURE.md` lines 200–280, 370–400 — token shape adopted; its "~13 tokens" and illustrative hexes superseded
- `.planning/research/STACK.md` lines 17–30 — token list correct, the count "29" is off by one
- `docs/DEPLOYMENT.md` §1–§5, `.planning/STATE.md` — deploy timings, API polling, `--deploy-proof` policy, tooling gotchas

### Tertiary (MEDIUM — reasoning, not run)

- CSS specificity of a selector list is per-selector (Selectors L3/L4). Universally implemented; not separately tested in a browser here.

## Metadata

**Confidence breakdown:**

- Stop-sign resolution & the write seam: **HIGH** — contract source read and executed
- Token inventory & consumers: **HIGH** — gem source + live CSS parsed; counts are `grep -c` output
- Dark-mode kill mechanism: **HIGH** for the diagnosis (dark block confirmed in live CSS); **MEDIUM-HIGH** for the selector-list fix (standard CSS, not browser-tested here)
- Contrast figures: **HIGH** — computed, and they reproduce PITFALLS exactly
- PurgeCSS behaviour: **HIGH** for custom properties (empirically proven by `--deploy-proof` in live CSS); **HIGH** for the `sticky-bottom` purge (observed absent)
- Verification path: **HIGH** — no Ruby confirmed by two searches; Docker path **MEDIUM** (present, not exercised)

**Research date:** 2026-09-14
**Valid until:** ~30 days, or until `al_folio_core` is bumped off 1.0.15 (re-read `_sass/_themes.scss` if so)

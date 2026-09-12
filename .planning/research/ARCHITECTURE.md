# Architecture Research

**Domain:** Incremental design system for a Jekyll / al-folio v1.x personal academic site ("research notebook" visual language)
**Researched:** 2026-09-12
**Confidence:** HIGH (primary evidence: the actual `al_folio_core` 1.0.15 gem payload, extracted and read; Sass behaviours verified by running Dart Sass 1.104.1 locally)

---

## Verdict up front

**Use CSS custom properties as the token layer. Not Sass variables. This is settled by evidence, not preference.**

The gem ships **two** stylesheets and this site can only recompile **one** of them:

| Stylesheet | Where it comes from | Can this site change it? |
|---|---|---|
| `assets/css/tailwind.css` (27 KB, Tailwind v4.1.18, **prebuilt**) | shipped compiled inside the gem; `tailwind.config.js` is not even in the gem payload | **No.** No local Tailwind pipeline is allowed (`build:css` / `build:tailwind` are hard-failed by `test/style_contract.js`), and the source `@config` file isn't shipped. |
| `assets/css/main.css` (compiled from `assets/css/main.scss` → gem `_sass/*` → `_sass/_custom.scss`) | compiled by Jekyll at build time | **Yes**, through the existing one-line seam. |

The decisive fact: **the prebuilt, un-recompilable `tailwind.css` reads `var(--global-*)` and never defines them.** Verified by extraction:

```
$ grep -o -- "--global-[a-z-]*"  assets/css/tailwind.css | sort | uniq -c
      8 --global-theme-color      2 --global-bg-color
      4 --global-text-color       1 --global-hover-text-color
      2 --global-divider-color    1 --global-hover-color
                                  1 --global-card-bg-color
$ grep -o -- "--global-[a-z-]*:"  assets/css/tailwind.css   # definitions
  (no matches)
```

Compiled examples from that file: `body{background-color:var(--global-bg-color);color:var(--global-text-color)}`, `a{color:var(--global-theme-color)}`, `.card{background-color:var(--global-card-bg-color)}`, `.btn-outline-primary{border-color:var(--global-theme-color)}`, `.progress-bar{background-color:var(--global-theme-color)}`.

The `--global-*` properties are defined in exactly one place: the gem's `_sass/_themes.scss`, in a `:root` block, interpolating Sass variables (`--global-bg-color: #{v.$white-color};`). That file is compiled **into `main.css`**, which this site controls, and `_sass/_custom.scss` is `@use`d **after** it.

Therefore:

- Redefining `--global-bg-color` in `_sass/_custom.scss` **reaches markup styled by the prebuilt Tailwind CSS**, the gem's Sass, and page-authored markup — everything, in one edit.
- Redefining the gem's **Sass** variables cannot do that. Sass variables are resolved at compile time inside `main.css` only; the prebuilt `tailwind.css` was compiled elsewhere, long ago, and can never see them. Worse, `@use "variables" with (...)` a second time is a **hard build error** (verified below), so the Sass-variable route is not even fully open.

Sass variables retain exactly one legitimate job here: `$max-content-width`, which `main.scss` already configures from `site.max_width` and which `_layout.scss` applies as `.container { max-width: v.$max-content-width; }`. Change it through `_config.yml`, not through Sass.

---

## Standard Architecture

### System Overview — the cascade, as actually loaded

`_includes/head.liquid` emits stylesheets in this order (verified by reading the gem's `head.liquid`):

```
┌──────────────────────────────────────────────────────────────────────────┐
│  1. inline <style> in <head>        :root { --max-content-width: 930px }  │  ← from site.max_width
├──────────────────────────────────────────────────────────────────────────┤
│  2. assets/css/tailwind.css         PREBUILT, IMMUTABLE, ALL IN @layer    │
│       @layer properties → theme → utilities → base → components          │
│       consumes  var(--global-*)  ·  defines  --spacing, --color-*, …      │
├──────────────────────────────────────────────────────────────────────────┤
│  3. icons / google fonts / pygments   ← google-fonts URL is a CONFIG key  │
├──────────────────────────────────────────────────────────────────────────┤
│  4. assets/css/main.css   (UNLAYERED — therefore beats every @layer)      │
│     ┌────────────────────────────────────────────────────────────────┐   │
│     │ gem _sass/_themes.scss      DEFINES  :root { --global-*: … }   │   │
│     │ gem _sass/_layout,_typography,_navbar,_footer,_blog,_utilities │   │
│     │                             CONSUME  var(--global-*)           │   │
│     ├────────────────────────────────────────────────────────────────┤   │
│     │ _sass/_custom.scss   ← THE ONLY SEAM. LOADED LAST.             │   │
│     │   · re-point  :root { --global-*: var(--our-token) }           │   │
│     │   · define    :root { --paper-*, --ink-*, --rule-*, --step-* } │   │
│     │   · style     page-authored classes (.entry, .entry-point, …)  │   │
│     └────────────────────────────────────────────────────────────────┘   │
├──────────────────────────────────────────────────────────────────────────┤
│  5. page front-matter `_styles` → inline <style> in <body> (escape hatch) │
└──────────────────────────────────────────────────────────────────────────┘
```

Two cascade consequences worth knowing precisely (MDN-verified):

1. **Everything in `tailwind.css` is inside `@layer`. Everything in `main.css` is unlayered.** For *normal* declarations, "styles that are not defined in a layer always override styles declared in named and anonymous layers." So `_custom.scss` wins over the entire prebuilt Tailwind sheet **without any specificity fight and without `!important`**. Changing `body { font-family }` from Roboto to a serif is a one-line unlayered rule.
2. **The reverse is true for `!important`.** "All important declarations within CSS layers take precedence over any important declarations declared outside of a layer." The gem's Bootstrap-compat block in `@layer components` ships `.mt-3{margin-top:1rem!important}`, `.w-100{width:100%!important}`, `.d-none{display:none!important}`. **You cannot beat those from `_custom.scss`, even with `!important`.** Do not try. Either avoid those class names in page-authored markup, or change the token/structure instead.

### Component Responsibilities

| Component | Responsibility | Where it lives | Owner |
|---|---|---|---|
| Prebuilt Tailwind CSS | Bootstrap-compat grid, utilities, base reset, `body`/`a`/`h1-h6` defaults | `al_folio_core` gem, compiled | Gem — untouchable |
| `--global-*` token contract | The semantic colour interface both stylesheets agree on | gem `_sass/_themes.scss`, compiled into `main.css` | Gem defines, **site re-points** |
| `assets/css/main.scss` | Sass entry point; verbatim gem copy + `@use "custom";` | this repo (tracked override) | Site — keep at exactly one added line |
| `_sass/_custom.scss` + `_sass/custom/*` | The entire design system | this repo | Site — **not** a gem override (the gem ships no `_custom.scss`), so zero upgrade debt |
| Layouts / includes | Page skeleton, `{{ content }}` slot, `figure.liquid` | gem `_layouts/`, `_includes/` | Gem — copy only when forced |
| Page-authored markup | Section structure, class hooks, the new entry-point cards | `_pages/*.md` (+ `_data/*.yml`) | Site — the real component seam |
| Config levers | Measure, fonts, dark mode, footer style, images | `_config.yml` | Site |

---

## Recommended Project Structure

```
_sass/
├── _custom.scss              # AGGREGATOR ONLY: ~6 @use lines, no rules of its own
└── custom/                   # (no _index.scss in here — see trap below)
    ├── _tokens.scss          # L1  primitives + semantic map + gem --global-* re-point
    ├── _base.scss            # L2  ground, texture, body type, scale, measure, rules, links
    ├── _components.scss      # L3  .entry-group/.entry/.subject/.topic-list, cards, badges
    ├── _home.scss            # L4  hero, portrait, entry-point cards, "currently exploring"
    ├── _figures.scss         # L5  figure frames, captions, book-cover grid, zoom targets
    └── _pages.scss           # L6  page-scoped adjustments (.page-research, .page-cv, print)
```

`assets/css/main.scss` **does not change again** — it keeps its single trailing `@use "custom";`. That matters: it is the only true gem override in the repo (recorded in `.al-folio-overrides.yml` with a SHA), so every additional file you keep out of it is upgrade debt you never take on.

### Structure rationale

- **One file per build phase, in build order.** The file list *is* the roadmap. A reviewer can see what shipped by which files exist.
- **`_tokens.scss` first and alone.** It is the only file that may contain literal colour/length values. Every other file references `var(--…)`. That single rule is what makes dark mode a later additive change rather than a restructure.
- **Not one file per page.** Four of the seven pages (`academics`, `research`, `activities`, `further-reading`) already render the *same* markup vocabulary — `.entry-group` / `.entry` / `.entry-year` / `.entry-title` / `.entry-meta`. Styling that vocabulary once in `_components.scss` upgrades four pages in one commit. Per-page files would have you write the same rules four times and drift.
- **`_pages.scss` last and thin.** Per-page work is genuinely a *last* layer: if it grows large, the shared vocabulary was wrong.

### Two verified Sass traps in this exact setup

Both were reproduced locally with Dart Sass 1.104.1:

**Trap 1 — `_sass/custom/_index.scss` is silently ignored.** With both `_sass/_custom.scss` and `_sass/custom/_index.scss` present, `@use "custom";` resolves to `_custom.scss` and the index file is dropped. No warning, no error, exit code 0 — the third silent-failure mode, in CSS form. So: keep the aggregator named `_custom.scss` and **never** create `custom/_index.scss`. (If you ever prefer the index-file style, delete `_custom.scss` in the same commit.)

**Trap 2 — never re-configure `variables` in `_custom.scss`.**

```scss
// _sass/_custom.scss
@use "variables" as v;                                   // ✅ reads the configured value
@use "variables" as v with ($max-content-width: 1200px); // ❌ hard build failure
//  Error: This module was already loaded, so it can't be configured using "with".
```

`main.scss` already loaded and configured it. Reading is fine and returns the value `main.scss` set (verified: `1080px` in, `1080px` out). To change the measure, change `max_width` in `_config.yml` — one key that feeds **both** the Sass `$max-content-width` *and* the inline `--max-content-width`.

Verified-working sub-partial shape:

```scss
// _sass/_custom.scss  — the whole file
@use "custom/tokens";
@use "custom/base";
@use "custom/components";
@use "custom/home";
@use "custom/figures";
@use "custom/pages";
```

Emitted CSS follows `@use` order, after all gem partials. Confirmed by compiling a faithful miniature of this repo's arrangement.

---

## The layer model

| # | Layer | Owns | Consumes | Blocked by |
|---|---|---|---|---|
| **L0** | Guardrails (config/CI) | `visual-regression.yml` disabled, `enable_darkmode: false`, `max_width`, Google-Fonts URL | — | nothing |
| **L1** | Tokens | `:root` primitives; semantic map; **re-point of every `--global-*`** | L0 (dark mode must already be off) | L0 |
| **L2** | Ground & type | paper texture, `body` serif, modular scale, measure/margin column, `hr` rules, links, blockquote | L1 tokens | L1 |
| **L3** | Shared components | `.entry-group`, `.entry`, `.subject`, `.topic-list`, `.entry-status`, card idiom | L1 + L2 | L2 |
| **L4** | Home entry points | portrait, hero/subtitle, entry-point cards, "currently exploring" | L1 + L2 (not L3) | L2 |
| **L5** | Figures & imagery | figure frame, caption, book-cover grid, research figures | L1 + L2 | L2 + asset production |
| **L6** | Per-page & polish | page-scoped classes, CV/404, print, reduced-motion, final contrast audit | all | L3, L4 |

### Dependency graph

```
        L0 Guardrails ──────────────────────────────────────────────┐
             │  (dark mode OFF must precede or accompany L1)        │
             ▼                                                      │
        L1 Tokens ──────────────────────────────────────────────┐   │
             │                                                  │   │
             ▼                                                  │   │
        L2 Ground + Type ──┬──────────────┬──────────────┐      │   │
             │             │              │              │      │   │
             ▼             ▼              ▼              │      │   │
        L3 Components   L4 Home       L5 Figures ◄── figure assets   │
             │             │              │        (fully parallel)  │
             └─────────────┴──────────────┴──────────────────────────┤
                                    ▼                                │
                              L6 Per-page + polish ◄─────────────────┘
```

**Real edges, and why each is real:**

| Edge | Why it is a genuine dependency (not sequencing preference) |
|---|---|
| `dark mode off → L1` | The gem still ships `html[data-theme="dark"]{ --global-*: … }` in `main.css`. That selector's specificity (0,1,1) **beats** any `:root` re-point (0,1,0). If dark mode is still reachable when the paper tokens land, a dark-mode visitor gets the gem's grey/cyan for gem-defined tokens *plus* your new cream-derived tokens for everything else — a genuinely broken page. Turn the toggle off first, or in the same commit. |
| `L1 → L2/L3/L4/L5` | Every later rule is written as `var(--…)`. Writing components before tokens means literal hexes you must then rewrite — you pay twice and you lose dark-mode-later for free. |
| `L2 → L3` | Components are sized against the type scale and the measure. The measure decision (keep 930px vs widen to ~1080–1140px to buy a margin-note gutter) re-flows every card, list and figure. Making it after components exist means re-tuning all of them. |
| `L5 ← figure assets` | The CSS frame is cheap; *redrawing research figures in notebook style* is the long pole and involves no code. Start it at L0 and let it run beside everything. |
| `L3 ∦ L4` | **Not** an edge. The home page's entry-point cards are new markup with new class names; the list pages use the existing `.entry*` vocabulary. Different files, different pages, no shared selectors. |

---

## Build order, with the shippability of each step stated

The rule this ordering satisfies: **every step is a coherent whole-site change, not a partial repaint.** That is achievable at all only because of the token architecture — since gem CSS *and* prebuilt Tailwind both read `--global-*`, a token change lands on every page and every component simultaneously. There is no state where the navbar is cream and the cards are still white.

### Step 0 — Guardrails
**Do:** disable `visual-regression.yml`; set `enable_darkmode: false`; decide and set `max_width`; point `third_party_libraries.google_fonts.url.fonts` at the chosen serif + accent families; confirm `npm run lint:style-contract`, `npm run lint:prettier` and `axe.yml` still pass.
**If we stop here:** the site is pixel-identical except the theme toggle is gone and (if the font URL changed) text may render in a serif at gem-default sizes — acceptable but slightly loose; safest to change the font URL *with* Step 2 instead. **Shippable: yes.**
**Note:** the style contract's forbidden-path block is already commented out in this repo, so `_sass/` is legal here. The checks that *do* still run — `theme: al_folio_core`, the plugin list, the FontAwesome/academicons/scholar-icons SRI pins, `tikzjax`/`tocbot` presence, the exact `al_math` pin — must survive every config edit. `google_fonts` is unconstrained.

### Step 1 — Tokens *(highest leverage step in the whole project)*
**Do:** create `custom/_tokens.scss`. Define primitives (`--paper-*`, `--ink-*`, `--accent-*`, `--rule-*`) then re-point **all** of these in one block: `--global-bg-color`, `--global-text-color`, `--global-text-color-light`, `--global-theme-color`, `--global-hover-color`, `--global-hover-text-color`, `--global-divider-color`, `--global-card-bg-color`, `--global-code-bg-color`, `--global-highlight-color`, `--global-footer-bg-color`, `--global-footer-text-color`, `--global-footer-link-color`.
**If we stop here:** the entire site — all seven pages, navbar, dropdowns, footer, project cards, code blocks, the scroll progress bar, buttons, tables — is on warm paper with the new ink and accent. Typography is still Roboto at gem sizes. This reads as "a tasteful recolour", which is a strictly better site than today. **Shippable: yes, and it is the single best value-per-hour commit available.**
**Split warning — these must be in the same commit or the site *is* half-painted:**
- `--global-footer-bg-color` is `#1c1c1d` and `footer_fixed: true` is set, so a cream body leaves a dark-grey bar pinned to the bottom. Either re-point the footer tokens or set `footer_fixed: false` (the gem's `footer.sticky-bottom` is a bordered, background-free footer — much closer to notebook).
- `--global-code-bg-color` is `rgba($purple-color, 0.05)` and `pre { color: var(--global-theme-color) }` — leave them and code blocks are a lilac wash with coloured text on cream.
- `--global-theme-color` is `#b509ac` (purple) and drives links, active nav, buttons, progress bar and table hover. It is the single most visible token.

### Step 2 — Ground and type
**Do:** `custom/_base.scss`. Paper texture (CSS gradients / inline SVG on `body`), `body { font-family: <serif> }`, a `--step-*` modular scale applied to `h1-h6`/`p`/`small`, the measure and (if adopted) the margin-note gutter, `hr` as a hand-drawn rule, link underline treatment, blockquote as a notebook aside. Move the Google-Fonts URL change here if it wasn't done in Step 0.
**If we stop here:** the site reads as a research notebook at the level of ground, voice and rhythm. The data-driven list pages still use flat placeholder list styling but inherit the new type and colour, so they look plain, not broken. **Shippable: yes.**
**Blocking decision inside this step:** the measure. 930px is tight for prose + marginalia. Decide here, because L3/L4/L5 are all sized against it.

### Step 3 — Shared components
**Do:** `custom/_components.scss`. Replace the placeholder rules for `.entry-group`, `.entry-group-title`, `.entry`, `.entry-year`, `.entry-title`, `.entry-meta`, `.entry-detail`, `.entry-status`, `.subject`, `.topic-list`, `.entry-notes`. Establish the reusable card/aside idiom the home page will reuse.
**If we stop here:** Academics, Research & Learning, Activities and Further Reading all get the notebook treatment **at once** — they share one vocabulary, so there is no page-by-page drift. Home is still gem-default structure on paper ground. **Shippable: yes.**

### Step 4 — Home entry points
**Do:** `custom/_home.scss` + edits to `_pages/about.md`. Uncomment the `profile:` block (`prof_pic.jpg` is already in the repo). Style `.hero-role` / `.hero-line` / `.hero-school` / `.exploring` — **these class hooks already exist in `about.md` and are currently unstyled.** Add the entry-point cards (see next section).
**If we stop here:** the landing page has a face, a voice and three real questions to click. Every inner page is already done. **Shippable: yes — and this is the step the primary audience feels most.**
**Parallel with Step 3:** different file, different page, no shared selectors.

### Step 5 — Figures and imagery
**Do:** `custom/_figures.scss` — figure frame, `.caption`, book-cover grid for Further Reading, portrait treatment. Place redrawn research figures via the gem's `{% include figure.liquid path=… class=… caption=… zoomable=true %}` (callable straight from a page; no override needed).
**If we stop here:** not reached — but the preceding state (text-only notebook) is coherent, which is exactly why this step is safe to have outstanding when the deadline arrives. **Shippable: yes, and *partially* shippable — one figure at a time, each its own commit.**

### Step 6 — Per-page polish
**Do:** `custom/_pages.scss` — page-scoped wrapper classes, CV page treatment, 404, `@media print`, `prefers-reduced-motion`, and the final axe/contrast sweep.
**If we stop here / never:** nothing looks unfinished; this layer is refinement only. **Shippable: yes.**

### Parallelisation

| Track | Runs beside | Blocks |
|---|---|---|
| Redrawing research figures (asset work, no code) | everything from Step 0 | Step 5's content, not its CSS |
| Writing the entry-point card copy (the *questions*) | Steps 0–3 | Step 4 |
| Font family selection + `google_fonts` URL | Steps 0–1 | Step 2 |
| **Step 3 (components) ∥ Step 4 (home)** | each other | Step 6 |
| Contrast-checking candidate palettes | Steps 0–1 | Step 1 sign-off |

Steps 0→1→2 are strictly serial. After Step 2 the work fans out.

---

## Architectural Patterns

### Pattern 1 — Token re-pointing (the core pattern)

**What:** Never restyle a gem-rendered element directly. Change the token it already reads.
**When:** Any colour, and any length the gem exposes as a variable.
**Trade-offs:** One edit reaches prebuilt CSS you cannot recompile; survives gem upgrades untouched; costs nothing in specificity. The limit is that only ~13 colour concepts are exposed — anything outside that set needs a real rule.

```scss
// _sass/custom/_tokens.scss
:root {
  /* --- Tier 1: primitives. The ONLY literals in the whole design system. --- */
  --paper-50:  #fdfaf4;   --paper-100: #faf6ee;   --paper-200: #f2ebdd;
  --ink-900:   #1f1b16;   --ink-700:   #3d372f;   --ink-500:   #5c5349;
  --accent-700:#7a3b2e;                           --rule-200:  #d9cfba;

  /* --- Tier 2: semantic. Re-points the gem's own contract. --- */
  --global-bg-color:          var(--paper-100);
  --global-text-color:        var(--ink-900);
  --global-text-color-light:  var(--ink-500);   /* NOT the gem's #828282 — see contrast note */
  --global-theme-color:       var(--accent-700);
  --global-hover-color:       var(--accent-700);
  --global-divider-color:     var(--rule-200);
  --global-card-bg-color:     var(--paper-50);
  --global-code-bg-color:     var(--paper-200);
  --global-footer-bg-color:   var(--paper-200);
  --global-footer-text-color: var(--ink-700);
  --global-footer-link-color: var(--ink-900);

  /* --- Tier 2b: concepts the gem has no token for. --- */
  --rule-hand: var(--rule-200);
  --margin-note-color: var(--ink-500);
  --paper-texture-opacity: 0.35;

  /* --- Type scale + spacing: ours, not Tailwind's. --- */
  --step-0: 1.0625rem;  --step-1: 1.3rem;  --step-2: 1.6rem;  --step-3: 2.05rem;
  --space-1: .5rem;  --space-2: 1rem;  --space-3: 1.75rem;  --space-4: 3rem;
}
```

*(Hex values above are illustrative placeholders — the palette itself is design work, not architecture. The **shape** is the recommendation.)*

### Pattern 2 — Components live in page content, styled by `_custom.scss`

**What:** New components are authored as HTML (optionally driven by a Liquid loop over `_data/`) inside `_pages/*.md`, exposing class hooks that `_sass/custom/*` styles.
**When:** Always, unless the component must appear on pages you don't author — which, on this site, never happens.
**Trade-offs:** Zero override debt, zero gem-upgrade risk. Costs: no reuse across pages without copy-paste, and kramdown will not parse Markdown inside a block-level HTML element unless you add `markdown="1"`.
**Already proven in this repo:** `_pages/academics.md`, `research.md`, `activities.md` and `further-reading.md` all do exactly this today, and `about.md` already ships raw `<p class="exploring">` markup. This is not a new pattern to introduce; it is the site's existing one.

### Pattern 3 — Page-scoped styling without a layout override

**What:** You need per-page treatment but `body` carries no page class (the gem's `default.liquid` sets only `fixed-top-nav` / `sticky-bottom-footer`). Wrap the page's own content in a class, in the page file.

```markdown
---
layout: page
title: Research & Learning
---
<div class="page-research" markdown="1">
{% for … %}
</div>
```

```scss
.page-research .entry-group + .entry-group { border-top: 1px solid var(--rule-hand); }
```

**Trade-offs:** Free, reversible, invisible to gem upgrades. Alternative hooks that also need no override: the `id` attributes pages already emit (`#papers`, `#books`, `#courses`), and `page._styles` front matter, which `page.liquid` renders into an inline `<style>`.
**Use `_styles` only for genuine one-offs.** It duplicates tokens, isn't shared, and turns the design system into per-page snowflakes.

### Pattern 4 — Configuration as a design lever

Four visual decisions are `_config.yml` edits, not CSS:

| Key | Effect | Verified in |
|---|---|---|
| `max_width` | feeds **both** `$max-content-width` (via `main.scss`) and the inline `:root{--max-content-width}` (via `head.liquid`) → the measure | `main.scss` line 14; `head.liquid` inline `<style>` |
| `third_party_libraries.google_fonts.url.fonts` | the **only** webfont loader in the whole theme; currently `Roboto|Roboto+Slab|Material+Icons` | `head.liquid` |
| `enable_darkmode` | gates `theme.js`, the dark pygments sheet, **and** the navbar toggle button | `head.liquid` L128; `header.liquid` L127 |
| `footer_fixed` | `true` → dark `footer.fixed-bottom` bar; `false` → bordered `footer.sticky-bottom` | `_sass/_footer.scss` |

### Pattern 5 — Figures through the gem's include

`{% include figure.liquid path="assets/img/attn.png" class="fig-notebook" caption="…" zoomable=true %}` works from any page, emits `<figure><picture>…<figcaption class="caption">`, and with `imagemagick.enabled: true` generates 480/800/1400 WebP srcsets automatically. The `class=` parameter is the styling hook. No override.

---

## Component boundaries: the home-page entry-point cards

Three options, evaluated against the real constraints.

| Option | Works? | Override debt | Cost |
|---|---|---|---|
| **A. HTML (+ Liquid) directly in `_pages/about.md`, styled by `_custom.scss`** | Yes — `about.liquid` renders `{{ content }}` inside `<div class="clearfix">`, before news/papers/social | **None** | Copy and structure interleaved; no reuse on other pages |
| **B. `_data/entry_points.yml` + Liquid loop in `about.md`** | Yes — identical mechanism, proven by the four list pages | **None** | Indirection: editing a question means opening a second file; more Liquid to get wrong |
| **C. Override `_layouts/about.liquid` (or a gem include)** | Yes | **Real** — a gem-owned file to re-diff at every upgrade; must be recorded in `.al-folio-overrides.yml` | Buys nothing here: the layout already gives you a content slot exactly where the cards belong |

**Recommendation: Option A, with Option B held in reserve.**

Reasons, in order:
1. `about.liquid` already renders page content in the right position. Option C would be an override taken to obtain something already available — a direct violation of the stated CSS-first / override-only-when-forced policy.
2. The value of these cards is the *questions* ("Why do attention sinks appear?"). That copy will be rewritten many times before the deadline and wants to sit where it is read, next to the rest of the page's prose — not in a YAML file one directory away.
3. There are three or four cards on one page. `_data/` earns its indirection at ~8+ repeating records, or when the same records must render in two places. Neither holds.

**Cost of Option A, stated honestly:** if the same cards later need to appear on another page, you copy the markup once and then migrate to `_data/`. That migration is ~20 minutes and touches no gem file. **Migration trigger to write down: more than four cards, or a second page needs them.**

**Implementation notes:**
- Use new class names (`.entry-point`, `.entry-point-q`), **not** Bootstrap's `.card` / `.row` / `.col-md-4` — those come from `@layer components` with `!important` on the spacing helpers and will fight you. Use CSS Grid in `_home.scss` instead; unlayered, so it wins cleanly.
- Wrap in `<div class="entry-points" markdown="1">` if any card body contains Markdown links.
- Each card should be a real `<a>` wrapping the whole surface, for target size and keyboard focus (`axe.yml` runs in CI).

---

## Light-only theming, and keeping the door open for dark

**How the toggle disappears.** `enable_darkmode: false` in `_config.yml` gates three things at once (verified in the gem): `theme.js` and its `initTheme()` call, the dark pygments stylesheet, and the `#light-toggle` button in `header.liquid`. Nothing else in the gem references `data-theme` — `theme.js` is the only JS file that mentions it. With the flag off, no code ever sets the `data-theme` attribute, so `html[data-theme="dark"]` is unreachable and `:root`'s light values apply unconditionally.

**What stays behind.** The gem's `_sass/_themes.scss` still compiles its dark block into `main.css` (~1 KB of dead CSS) and still sets `color-scheme: light` at `:root`. That is fine — leave it. Forking `_themes.scss` to delete it would convert a zero-override project into an override project to save a kilobyte.

**System dark mode does not leak.** The gem's dark styles are attribute-driven; there is no `@media (prefers-color-scheme: dark)` anywhere in the gem's Sass. A visitor with a dark OS sees the light site. Light-only is genuinely stable, not merely default.

**Reintroducing dark later requires no restructuring — if and only if two rules hold from Step 1 onward:**

1. **Every rule outside `_tokens.scss` uses `var(--…)`. No literals.** Then a dark theme is one additional block, not a sweep of the codebase.
2. **Primitives and semantic mappings stay separate blocks in `_tokens.scss`.** Dark mode re-maps the semantic tier only.

Then the future change is additive and lands entirely in `_tokens.scss`:

```scss
html[data-theme="dark"] {
  --global-bg-color:   var(--ink-900);
  --global-text-color: var(--paper-100);
  /* …re-map the same semantic names… */
}
```

**One specificity fact to record now, because it will bite whoever re-enables dark mode:** `html[data-theme="dark"]` has specificity (0,1,1) and beats `:root` (0,1,0). The gem's dark block therefore overrides your `:root` re-points whenever the attribute is present. Practical consequences: (a) turning dark mode back on *without* adding your own `html[data-theme="dark"]` block gives a broken hybrid — precisely why dark mode must be switched off **before or with** Step 1, never after; (b) when you do add it, your block must come from `_custom.scss` (loaded after `_themes.scss`) so it wins the tie at equal specificity.

---

## Data Flow

### How a visual decision reaches a pixel

```
_config.yml  ──(max_width, fonts, flags)──────────────────────┐
                                                              ▼
_sass/custom/_tokens.scss  ──►  :root { --global-*: … }  ──►  main.css (unlayered)
                                       │                         │
                      ┌────────────────┴──────────────┐          │ wins over
                      ▼                               ▼          ▼ every @layer
            gem _sass/*.scss                  PREBUILT tailwind.css
            (var(--global-*))                 (var(--global-*), immutable)
                      │                               │
                      └───────────────┬───────────────┘
                                      ▼
                    HTML from gem layouts + page-authored markup
                      (_pages/*.md, optionally looping _data/*.yml)
                                      ▼
                    _sass/custom/_components|_home|_figures.scss
                      (styles the class hooks the pages emit)
```

### Key flows

1. **Colour change:** edit one primitive in `_tokens.scss` → every gem component, every Tailwind-styled element and every page-authored class updates together. This is why Step 1 cannot produce a half-repainted site.
2. **New component:** author markup + class hook in `_pages/*.md` → add rules to `_sass/custom/_*.scss` → done. No gem file touched, no `.al-folio-overrides.yml` entry, no re-diff at upgrade time.
3. **Gem upgrade:** only `assets/css/main.scss` needs re-diffing (`al-folio upgrade overrides diff assets/css/main.scss`). If the gem adds a partial, copy the new `@use` line in and keep `@use "custom";` last. `_sass/custom/*` is invisible to the upgrade tooling because the gem ships no files of those names.

---

## Anti-Patterns

### Anti-Pattern 1: Styling gem components instead of re-pointing tokens
**What people do:** `.navbar { background: #faf6ee; } .card { background: #faf6ee; } footer { background: #faf6ee; }`
**Why it's wrong:** you will miss elements (dropdown menus, `.btn-outline-primary`, table hover, `.progress-bar`, code blocks), and every one you miss is a visibly half-redesigned page. It also forfeits dark mode permanently.
**Instead:** set `--global-bg-color` once. All of the above already read it.

### Anti-Pattern 2: Fighting `!important` utilities from `_custom.scss`
**What people do:** `.my-thing .mt-3 { margin-top: 0 !important; }`
**Why it's wrong:** `.mt-3{margin-top:1rem!important}` lives in `@layer components`, and layered `!important` beats unlayered `!important` — always, at any specificity. You will burn an hour and lose.
**Instead:** don't put `.mt-*` / `.p-*` / `.w-100` on markup you author; use your own `--space-*` scale. For gem-emitted markup carrying those classes, adjust the surrounding container instead.

### Anti-Pattern 3: Copying a layout to add one class
**What people do:** copy `_layouts/about.liquid` into the repo to wrap content in `<div class="home">`.
**Why it's wrong:** permanent gem-upgrade tax on a file that changes upstream, plus an `.al-folio-overrides.yml` entry to maintain — in exchange for a wrapper you can write in `_pages/about.md` for free.
**Instead:** wrap in the page file. Reserve layout overrides for cases where the required element *does not exist in the output at all* — and say so explicitly when you take one.

### Anti-Pattern 4: Overriding Tailwind's `--spacing`
**What people do:** set `--spacing: .3rem` at `:root` to change global rhythm in one line.
**Why it's wrong:** it silently rescales every Tailwind spacing utility in gem markup — navbar padding, dropdown geometry, card body padding — and it doesn't even work uniformly, because the Bootstrap-compat block in `@layer components` re-declares `.mt-2`…`.mt-5`, `.mb-*` and `.p-3` as fixed `rem` values with `!important`. You get half a rescale.
**Instead:** define your own `--space-*` tokens and use them in your own rules.

### Anti-Pattern 5: Aesthetic low-contrast grey on cream
**What people do:** keep the gem's `--global-text-color-light: #828282` for margin notes, `.entry-year`, `.entry-meta`, `.post-description`.
**Why it's wrong:** `#828282` on a `#faf6ee` paper ground computes to **3.57:1** (WCAG 2.1 relative-luminance formula) — below the 4.5:1 needed for body text. `axe.yml` runs in CI, and this is the single most likely design-driven CI failure. It is also the exact failure mode PROJECT.md predicts. For reference on the same ground: `#5c5349` ≈ **6.99:1** ✅, `#1f1b16` ≈ **15.9:1** ✅.
**Instead:** re-point `--global-text-color-light` in Step 1, and check every muted token against the final paper value before merging.

### Anti-Pattern 6: Letting the design system leak into page front matter
**What people do:** use `_styles:` front matter per page because it's quick.
**Why it's wrong:** duplicated tokens, no shared vocabulary, invisible to anyone reading `_sass/`, and it re-emerges as inconsistency across seven pages.
**Instead:** `_sass/custom/_pages.scss` with page-scoped wrapper classes. Keep `_styles` for genuine one-offs and experiments.

### Anti-Pattern 7: Texture that costs more than it gives
**What people do:** a large raster paper texture with `background-attachment: fixed` on `body`.
**Why it's wrong:** fixed attachment forces repaint on scroll (historically poor on mobile Safari), and a raster adds weight to every page. *(Confidence: LOW — a training-data/community claim, not verified here. Measure before deciding.)* Separately, the gem's navbar is `background-color: var(--global-bg-color); opacity: .95` — a flat bar that will visibly not carry your texture.
**Instead:** CSS gradients and/or a small inline SVG noise data-URI; keep intensity behind `--paper-texture-opacity` so it can be dialled down in one place; decide deliberately whether the navbar shares the texture.

---

## Integration Points

### Config levers (all site-owned, all zero-override)

| Key | Design effect | Watch out for |
|---|---|---|
| `max_width: 930px` | the measure; drives Sass `$max-content-width` **and** `--max-content-width` | one key, two paths; changing it re-flows everything — decide in Step 2 |
| `third_party_libraries.google_fonts.url.fonts` | the only webfont loader | not covered by the style contract (unlike the icon libraries, which need SRI); CSP already permits `https:` styles and fonts |
| `enable_darkmode` | toggle + `theme.js` + dark pygments sheet | must go false **before or with** Step 1 |
| `footer_fixed` | dark fixed bar vs bordered sticky footer | `false` also removes `body`'s 70px bottom padding |
| `navbar_fixed` | adds `body.fixed-top-nav` 57px top padding; `.progress-container` is pinned at `top: 56px` | changing navbar height means chasing three magic numbers in gem CSS |
| `imagemagick.widths: [480, 800, 1400]` | responsive WebP for every figure | source figure assets should exceed 1400px wide |
| `enable_medium_zoom` | `data-zoomable` on figures | pairs with `figure.liquid`'s `zoomable=true` |
| `sass: style: compressed` | output only | `jekyll-minifier`'s CSS pass is deliberately off — do not re-enable it (it corrupts Tailwind's `var(--spacing)` inside `calc()`) |

### Internal boundaries

| Boundary | Communication | Notes |
|---|---|---|
| site → prebuilt Tailwind CSS | **CSS custom properties only** | the only channel that exists; there is no build-time channel |
| site → gem Sass | custom properties, plus unlayered rules loaded after | `@use "variables" as v` to *read* Sass vars; never to re-configure |
| page markup → stylesheet | class hooks authored in `_pages/*.md` | the real component seam; no gem file involved |
| `_data/*.yml` → page | Liquid loops in the page file | already the pattern on four pages |
| site → layouts | `{{ content }}` slot + front matter (`profile:`, `_styles:`, `toc:`) | enough for everything this milestone needs |

### CI boundaries this work must respect

| Gate | Status | Implication |
|---|---|---|
| `lint:style-contract` | forbidden-path block **already commented out in this repo** — `_sass/`, `_layouts/`, `_includes/` are legal here | still enforces `theme: al_folio_core`, the plugin list, icon SRI pins, `tikzjax`/`tocbot` presence, and the `al_math` exact-version pin. Every `_config.yml` edit must keep these intact. |
| `prettier.yml` | active; `@shopify/prettier-plugin-liquid`, `printWidth: 150` | run `npx prettier . --write` on every SCSS *and* Liquid-in-Markdown change |
| `axe.yml` | active | the contrast budget above is a merge gate, not advice |
| `visual-regression.yml` | to be disabled in Step 0 | specs hardcode `/al-folio/` and demo routes this site doesn't have; it fires on exactly the paths this project edits |
| `upgrade-check.yml` | active | `assets/css/main.scss` is the only tracked override; keep it at gem-verbatim + one line. `_sass/custom/*` is invisible to it. |

**Correction to inherited docs:** `AGENTS.md` / `CLAUDE.md` and `.planning/codebase/STRUCTURE.md` list `_sass/` as a forbidden path. That is stale for this checkout — `test/style_contract.js` has the block commented out with an explicit rationale. `PROJECT.md` is correct. Likewise, build with a plain `bundle exec jekyll build`; the `/al-folio` baseurl does not apply here.

---

## Sources

**Primary (HIGH confidence) — the gem itself, extracted and read:**
- `al_folio_core` v1.0.15, fetched from `https://rubygems.org/downloads/al_folio_core-1.0.15.gem` and unpacked — `_sass/_themes.scss` (the `--global-*` definitions), `_sass/_variables.scss`, `_sass/_layout.scss`, `_sass/_typography.scss`, `_sass/_footer.scss`, `_sass/_navbar.scss`, `_sass/_components.scss`, `_sass/_utilities.scss`, `_sass/_blog.scss`, `assets/css/tailwind.css` (prebuilt, 27 KB), `assets/tailwind/app.css`, `_includes/head.liquid`, `_includes/figure.liquid`, `_layouts/default.liquid`, `_layouts/about.liquid`, `_layouts/page.liquid`
- This repo: `assets/css/main.scss`, `_sass/_custom.scss`, `_config.yml`, `_pages/*.md`, `test/style_contract.js`, `package.json`, `.al-folio-overrides.yml`, `Gemfile`

**Primary (HIGH confidence) — experiments run locally with Dart Sass 1.104.1:**
- `@use "custom"` resolves to `_custom.scss` and **silently ignores** `custom/_index.scss` when both exist (exit 0, no warning)
- `@use "custom/tokens"` from within `_custom.scss` resolves and emits in declaration order
- `@use "variables" as v` in `_custom.scss` reads the value `main.scss` configured; adding `with (…)` is a hard error ("This module was already loaded, so it can't be configured using `with`")
- A downstream `:root` block emits after the gem's and wins at equal specificity

**Secondary (HIGH confidence):**
- MDN, `@layer`: "Styles that are not defined in a layer always override styles declared in named and anonymous layers"; "all important declarations within CSS layers take precedence over any important declarations declared outside of a layer" — https://developer.mozilla.org/en-US/docs/Web/CSS/@layer

**Secondary (MEDIUM confidence) — token tiering practice:**
- Token Tiers (Honcho) — https://honcho.agency/design-systems/glossary/token-tiers
- Design Token Architecture 2026 (Tim Graf) — https://timgraf.com/ui/design-token-architecture-2026-the-strategic-blueprint-for-scalable-design-systems/
- Token Tier System Architecture — https://designsystemproblems.com/token-management/token-tier-system/
- Consensus across all three: three tiers (primitive → semantic → component), components must never reference primitives directly, and the semantic tier is what makes theming possible later. The recommendation here collapses tier 3 into tier 2 because the gem's `--global-*` set *is* an existing semantic contract — inventing a parallel vocabulary for it would be indirection without benefit at this size.

**Contrast figures** were computed here from the WCAG 2.1 relative-luminance definition, not quoted from a source. Re-verify against the final palette with axe before merging.

---
*Architecture research for: incremental design system on al-folio v1.x*
*Researched: 2026-09-12*

# Stack Research

**Domain:** Visual redesign of a Jekyll / al-folio v1.x academic portfolio into a "research notebook" aesthetic
**Researched:** 2026-09-12
**Confidence:** HIGH for the al-folio surface (verified by unpacking the published gem and reading every relevant file); HIGH for typography (verified against the live Google Fonts API, payloads measured); MEDIUM for texture/figure tooling (verified versions and licences via registries; technique guidance is community practice).

---

## Headline verdict: how far does CSS alone go?

**Further than expected. The redesign is ~95% achievable from `_sass/_custom.scss` plus `_config.yml` plus page content. No gem layout or include override is required for anything in the Active requirements list.**

Three findings drive this, all verified by reading `al_folio_core` 1.0.15 on disk:

### 1. The gem already exposes a full CSS custom-property token layer

`al_folio_core`'s `_sass/_themes.scss` declares **29 `--global-*` custom properties on `:root`**. Every colour in the gem's own SCSS reads from them. Redeclaring them in `_custom.scss` re-skins the whole site — no shadowing, no override record, no upgrade drift.

Complete token list (light theme, from `_sass/_themes.scss`):

```
--global-bg-color              --global-code-bg-color         --global-text-color
--global-text-color-light      --global-theme-color           --global-hover-color
--global-hover-text-color      --global-footer-bg-color       --global-footer-text-color
--global-footer-link-color     --global-distill-app-color     --global-divider-color
--global-card-bg-color         --global-highlight-color       --global-back-to-top-bg-color
--global-back-to-top-text-color --global-newsletter-bg-color  --global-newsletter-text-color
--global-tip-block   --global-tip-block-bg   --global-tip-block-text   --global-tip-block-title
--global-warning-block --global-warning-block-bg --global-warning-block-text --global-warning-block-title
--global-danger-block  --global-danger-block-bg  --global-danger-block-text  --global-danger-block-title
```

Plus `--max-content-width`, which is set twice: inline in `_includes/head.liquid` from `site.max_width`, and via the Sass variable `$max-content-width` that `assets/css/main.scss` already configures with `@use "variables" with (...)`. **Page measure is a `_config.yml` edit (`max_width: 930px`), not a CSS edit.**

`assets/css/main.scss` `@use`s `themes` before `custom`, so tokens redeclared in `_custom.scss` are emitted later and win on source order. Confirmed against the repo's actual `main.scss`.

### 2. Everything the gem ships as Tailwind sits inside cascade layers — `_custom.scss` does not

`assets/css/tailwind.css` in the gem is a **prebuilt, minified 27,355-byte artifact** compiled with Tailwind v4.1.18 at gem-release time. Verified: its entire content is wrapped in `@layer properties{…}@layer theme{…}@layer utilities{…}@layer base{…}@layer components{…}`.

`_includes/head.liquid` loads it **before** `/assets/css/main.css` (compiled from this repo's `main.scss` + `_custom.scss`), and `main.css` is entirely **unlayered**.

Per the CSS cascade, **unlayered normal declarations beat layered normal declarations regardless of specificity.** So:

```scss
// _custom.scss — this wins over tailwind.css's @layer base `body { font-family: Roboto }`
body { font-family: "Source Serif 4", Georgia, serif; font-weight: 400; }
```

No `!important`, no specificity hacks, no `:root:root` tricks. This is the single most important mechanical fact for the redesign.

**The one exception:** `!important` declarations inside a layer still beat normal unlayered ones. The gem's `@layer components` contains Bootstrap-compat utilities with `!important`:

`.d-none .d-block .d-sm-none .d-sm-block .d-md-none .d-md-block .w-100 .h-100 .mt-2 .mt-3 .mt-4 .mt-5 .mb-2 .mb-3 .mb-4 .p-3 .mt-md-0 .ml-md-4 .g-0 .no-gutters .float-left .collapse`

`_layouts/default.liquid` puts the main wrapper in `<div class="container mt-5">`, and `.mt-5 { margin-top: 3rem !important }`. **Changing the page's top spacing therefore needs `!important` in `_custom.scss`** — still CSS-only, just not pretty. Budget for a handful of these.

### 3. The compiled Tailwind is frozen — you cannot add utility classes, but you do not need to

`assets/tailwind/app.css` in the gem begins `@config "../../tailwind.config.js"` — and that config file **is not shipped in the gem**. Tailwind ran in the gem's own repo; only the output ships. Exactly **309 class selectors** exist in the built CSS, and that is the complete set available to markup in this repo.

What is available (abridged): a Bootstrap-4-shaped grid (`.container .row .col-* .col-sm-* .col-md-*`), display/flex utilities, `.m-*/.p-*` at spacing steps 0–5, `.rounded .rounded-sm .rounded-lg .rounded-circle`, `.shadow .shadow-sm .shadow-lg .shadow-none`, `.card .card-body .card-title .card-text .card-img-top`, `.btn .btn-sm .btn-outline-primary`, `.badge`, `.table*`, `.hoverable`, `.z-depth-0 .z-depth-1`, `.img-fluid`, `.clearfix`, `.sr-only`.

What is **not** available: any arbitrary-value utility (`p-[3rem]`), any colour utility beyond `bg-white bg-transparent text-white text-pink-700 border-white`, any `gap-*`, any `text-*` size except `text-3xl`, any `grid-cols-*`, any variant except `hover:text-pink-800` and the compiled responsive ones.

**Consequence for the home-page entry-point cards:** do not reach for Tailwind. Write semantic classes (`.entry-card`, `.entry-card__question`) in `_custom.scss` and hand-author the markup in `_pages/about.md`. This is already the pattern in the repo — `about.md` contains raw `<p class="exploring">` and `_custom.scss` styles `.entry`, `.subject`, `.topic-list`. The redesign extends an existing, working pattern rather than inventing one.

Note the gem's `.card` hardcodes `box-shadow: 0 2px 5px #00000029, 0 2px 10px #0000001f` and `.card-text` hardcodes `color: #747373` — neither reads a token. If you reuse `.card`, override both in `_custom.scss`. Writing your own class avoids the problem entirely; that is the recommendation.

---

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| `al_folio_core` | 1.0.15 (pinned, **current** — latest on RubyGems, published 2026-08-03) | Layouts, includes, prebuilt Tailwind, SCSS token bridge | Already installed; the pin is up to date, so no upgrade work is needed before the redesign. Verified via the RubyGems versions API. |
| `_sass/_custom.scss` | n/a | **The single design surface for this milestone** | Unlayered, loaded last, already wired. Every colour, type, texture and component rule belongs here. |
| `_config.yml` | n/a | Font URL, dark-mode flag, measure, feature flags | Three of the milestone's requirements are config-only edits, not CSS. |
| CSS Custom Properties | native | Design tokens | The gem already consumes 29 of them. Layer your own `--paper-*`, `--ink-*`, `--rule-*` tokens alongside and map the `--global-*` set onto them, so the design system is expressed once. |
| Source Serif 4 | v14 on Google Fonts | Body + heading serif | See typography section. **Vietnamese subset verified present.** |
| IBM Plex Mono | current on Google Fonts | Labels, years, grades, marginalia | **Vietnamese subset verified present.** |

### Supporting Libraries

All figure tooling is **authoring-time only**. Nothing below ships to the browser or becomes a repo dependency. Run it in a scratch directory, commit the resulting SVG.

| Library | Version | Licence | Purpose | When to Use |
|---------|---------|---------|---------|-------------|
| `svg2roughjs` | 3.2.3 (published 2026-03-07) | MIT | Converts an existing SVG into a hand-drawn, sketchy SVG | **The primary figure tool.** Export a matplotlib plot or a network graph to SVG, run it through this, commit the output. Depends on `roughjs ^4.6.6`, `svg-pathdata ^8`, `tinycolor2 ^1.6`. |
| `matplotlib` | 3.11.2 | matplotlib licence (BSD-style) | `plt.xkcd()` context manager renders plots with wobbled lines and a hand-drawn frame | For plots whose data you still have the script for. Cheapest possible path — one `with plt.xkcd():` wrapper, then `savefig('fig.svg')`. Note it warns and falls back if the "Humor Sans" / "xkcd Script" font is absent; install it or set `font.family` explicitly. |
| Excalidraw | web app, or `@excalidraw/excalidraw` 0.18.1 (MIT, published 2026-04-20) | MIT | Hand-drawn conceptual diagrams drawn by hand, exported as self-contained SVG | For diagrams with no underlying data — "what is an attention sink", an echo-chamber schematic. Excalidraw now embeds glyph-subsetted fonts into SVG exports, so the committed file renders identically with no external font request. |
| `roughjs` | 4.6.6 (MIT, last published 2023-11-20) | MIT | Low-level sketchy primitives | Only if you need to script a bespoke diagram that `svg2roughjs` cannot produce. Stable but dormant; treat as a build-time utility, never a runtime dependency. |

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| Prettier 3.8.0 + `@shopify/prettier-plugin-liquid` 1.10.0 | Formatting gate (`prettier.yml` runs on CI) | `printWidth: 150`. Run `npx prettier . --write` before pushing. Prettier **will** reformat `_custom.scss` — write it in a way that survives (avoid hand-aligned columns). |
| `npm run lint:style-contract` | Starter boundary check | **Read the actual file before trusting the docs.** `test/style_contract.js` in this repo has the forbidden-path block (`_layouts`, `_includes`, `_sass`, `assets/tailwind`, `tailwind.config.js`) **commented out** for this site, with an explanatory comment. What is *still live*: the `build:css` / `build:tailwind` / `build:tailwind:watch` npm-script ban, `theme: al_folio_core`, required plugins in `_config.yml`, SRI pins for the three icon libraries, and the exact-version pin on `al_math`. |
| `bundle exec al-folio upgrade overrides audit` | Records shadowed gem files in `.al-folio-overrides.yml` | Currently records exactly one override: `assets/css/main.scss`. If the redesign adds a second, run this and commit. |
| Browser devtools "Layers"/"Rendering" panel | Verify the paper-texture layer does not repaint on scroll | The single highest-risk performance item in this design. |

### Installation

Nothing is installed into this repo. Figure tooling runs ad hoc:

```bash
# Figure redraw, run from a scratch directory — do NOT add to package.json
npx svg2roughjs@3.2.3 input.svg -o output-rough.svg

# matplotlib route (Python toolchain already present via requirements.txt)
python3 -m pip install matplotlib==3.11.2
```

```yaml
# _config.yml — the three config-only wins

# 1. Light theme only. Removes the toggle button from the navbar AND skips
#    loading theme.js and the dark Pygments stylesheet. No override needed.
enable_darkmode: false

# 2. Typography. Replaces Roboto + Roboto Slab + Material Icons (the last of
#    which nothing in the gem actually uses — verified by grep).
third_party_libraries:
  google_fonts:
    url:
      fonts: "https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400&family=Source+Serif+4:ital,wght@0,400;0,600;1,400&display=swap"

# 3. Measure. Widen if margin notes need a gutter.
max_width: 930px
```

---

## Typography

**Hard requirement: Vietnamese diacritics.** "Phạm" contains `ạ` (U+1EA1), which lives *only* in Google Fonts' `vietnamese` unicode-range subset (U+0102-0103, 0110-0111, 0128-0129, 0168-0169, 01A0-01B0, 1EA0-1EF9, 20AB). A font without that subset renders the site owner's own name in a fallback face on the very first line of the home page.

Every candidate below was checked by fetching its live `fonts.googleapis.com/css2` response and asserting a `/* vietnamese */` `@font-face` block exists.

### Verified results

| Typeface | Vietnamese | Verdict |
|----------|:----------:|---------|
| **Source Serif 4** | ✅ | **RECOMMENDED — body + headings** |
| **IBM Plex Mono** | ✅ | **RECOMMENDED — labels, years, marginalia** |
| Literata | ✅ | Best alternative if more warmth is wanted (costs +108 KB) |
| Newsreader | ✅ | Warmest/most literary, but 405 KB — too heavy |
| EB Garamond | ✅ | Viable for the H1 only; too light for body on cream |
| Spectral, Crimson Pro, Lora, Faustina, Petrona, Bitter, Merriweather, Noto Serif, IBM Plex Serif, Playfair Display | ✅ | All safe on the Vietnamese axis |
| **Libre Baskerville** | ❌ **NO** | latin + latin-ext only. **Do not use.** |
| Inter, IBM Plex Sans, Source Sans 3, Work Sans, Public Sans, Fira Sans, Be Vietnam Pro | ✅ | Safe sans options if a humanist sans is preferred over mono for labels |
| JetBrains Mono, Space Mono, Roboto Mono, Geist Mono | ✅ | Safe mono alternatives |
| **Courier Prime, DM Mono** | ❌ **NO** | **Do not use.** |
| **Patrick Hand, Shantell Sans** | ✅ | The **only** Vietnamese-safe hand-drawn faces found |
| **Caveat, Kalam, Architects Daughter, Gloria Hallelujah, Reenie Beanie, Nanum Pen Script** | ❌ **NO** | **Do not use.** Caveat is the default pick for notebook designs everywhere and it will silently break the owner's name. |

### Measured payload (latin + vietnamese subsets only — the ones a Vietnamese-named English-language site actually downloads)

| Pairing | Faces | Payload |
|---------|-------|---------|
| **Source Serif 4 (400, 600, 400 italic) + IBM Plex Mono 400** | 4 | **171 KB** ✅ |
| Literata (400, 600, 400i) + IBM Plex Mono 400 | 4 | 279 KB |
| Newsreader (400, 600, 400i) + IBM Plex Mono 400 | 4 | 405 KB |
| Source Serif 4 **with the `opsz` axis** + Plex Mono 400/500 | 6 | **580 KB** ⚠️ |

**Do not request the optical-size (`opsz`) axis.** `family=Source+Serif+4:ital,opsz,wght@0,8..60,400..700;…` more than triples the download for a benefit no one will see at a single body size. Request static instances: `ital,wght@0,400;0,600;1,400`.

If the budget needs trimming further, drop the italic (−26 KB) and use the mono for marginalia instead — which is arguably more "lab notebook" anyway.

### Why Source Serif 4

- Adobe/Frank Grießhammer, **SIL Open Font License 1.1**, so free to self-host and redistribute.
- Drawn for on-screen reading at text sizes: open apertures, sturdy serifs, generous x-height. An admissions officer skimming for 2–3 minutes will not fight it.
- Reads as *considered and academic* rather than *decorative*. The personality in this design is meant to come from the paper ground, the margin notes and the hand-drawn marks — not from a quirky text face. A loud serif plus a loud texture is one loud thing too many.
- Full Vietnamese coverage from Adobe's own source, well-hinted — the combined diacritics (horn + tone, breve + tone) are properly drawn, not composed by the rasteriser.

### Why IBM Plex Mono for labels

Mono at 0.8rem for years, grades, section numbers and margin-note leaders reads as *lab notebook annotation*. Plex Mono is humanist rather than terminal-flavoured (true italics, moderate contrast), which keeps it away from the "dark deep-focus terminal" direction the owner explicitly rejected. It is OFL, it has Vietnamese, and one weight costs 21 KB.

### Loading strategy

**Phase 1 — use the config hook (recommended to start).** `_includes/head.liquid` emits the Google Fonts stylesheet from `site.third_party_libraries.google_fonts.url.fonts` with no SRI requirement (`style_contract.js` only demands SRI for `fontawesome`, `academicons`, `scholar-icons`). Swapping the URL is a one-line, zero-risk `_config.yml` edit. The gem's URL already carries `&display=swap`; keep it.

**Phase 2 — self-host if you want the last 100–200 ms.** The gem's `<link>` has no `rel="preconnect"` to `fonts.gstatic.com`, and adding one would require overriding `_includes/head.liquid`. **Self-hosting sidesteps that entirely:** drop woff2 files in `assets/fonts/` and write `@font-face` blocks in `_custom.scss`. The CSP in `head.liquid` permits `font-src 'self'`. The style contract only forbids `assets/fonts/academicons.*` and `assets/fonts/scholar-icons.*` — body fonts there are legal. This removes a third-party origin, a DNS lookup and a TLS handshake from the critical path, and removes a GDPR footnote.

Recommendation: ship Phase 1 in the typography phase, treat Phase 2 as a separate, optional polish phase. Do not let it block the design.

---

## Paper Texture and Hand-Drawn Marks

Ranked by cost, cheapest first. Compose the look from layers 1–3; reach for 4 only if it is not enough.

**1. Layered CSS gradients on a fixed background layer — 0 bytes, 0 requests.**
Ruled lines are `repeating-linear-gradient`. A warm vignette is a large `radial-gradient`. A faint margin rule is a single hard-stop `linear-gradient`. These composite on the GPU and cost nothing measurable. This should carry most of the paper feeling.

**2. One small tiled noise PNG — ~2–6 KB, 1 request. This is the recommended way to get grain.**
Generate the Perlin/fractal noise **once at authoring time** (an SVG `feTurbulence` rendered and exported, or ImageMagick — which is already a build dependency here via `jekyll-imagemagick`), save a 128×128 or 256×256 tileable PNG at low alpha, and `background-repeat` it on a fixed pseudo-element. Zero runtime filter cost, no Safari filter quirks, works everywhere.

**3. Inline-SVG data URIs for hand-drawn marks — 0 requests.**
Rules under headings, arrows, circles, underlines and checkmarks as `background-image: url("data:image/svg+xml,…")` on `::before`/`::after`. Each mark is 200–600 bytes inline in the stylesheet. Draw them once in Excalidraw or by hand, minify the path data, paste in. This is how the "hand-drawn rules and annotation marks" requirement gets met without a single JS byte.

**4. Live `feTurbulence` via `filter: url(#grain)` — use with care, or not at all.**
It genuinely is ~300 bytes of markup versus a 200 KB texture JPEG, which is why every tutorial recommends it. The costs the tutorials skip:

- The filter must be rasterised by the CPU at the element's full painted size. On a full-viewport element this is a real main-thread cost, and it is re-run on every resize.
- Applying `filter:` to an element creates a **containing block for `position: fixed` descendants** and a new stacking context. Applied to `body` or a wrapper, it silently breaks the fixed navbar and the back-to-top button — both of which this site has enabled (`navbar_fixed: true`, `back_to_top: true`).
- Referencing `url(#grain)` requires an `<svg><defs>` block in the document. There is nowhere to put one without overriding a gem layout — **the only override the texture work could force.** Avoid it by using technique 2 instead.

**Rules for whichever technique you pick:**
- Put the texture on `position: fixed; inset: 0; z-index: -1; pointer-events: none;` — not on `body` with `background-attachment: fixed`, which forces a full repaint on scroll in several engines.
- Never animate the grain.
- Never use `backdrop-filter` for this.
- Respect `@media (prefers-reduced-motion)` if anything moves, and keep the texture out of `@media print`.

**Correction to a planning assumption: Lighthouse is not actually gating this repo.** `.github/workflows/lighthouse-badger.yml` has `URLS: https://alshedivat.github.io/al-folio/` — it measures the **upstream demo site**, not `phamhakhanhchi.com` — and triggers only on `page_build` and `workflow_dispatch`. Likewise `.github/workflows/axe.yml` has its `push:` and `pull_request:` triggers commented out; it is `workflow_dispatch`-only. **Neither performance nor accessibility is automatically enforced on PRs.** That is freedom, not permission: the contrast risk named in PROJECT.md (grey-on-cream) is real and now has no automated backstop. Check contrast by hand, and consider pointing the Lighthouse workflow at the real domain as a cheap win.

---

## Redrawing Research Figures

The owner's figures are attention maps, echo-chamber network graphs and result plots. These are **not** the same problem, and the same tool should not be used on all three.

| Figure type | Tool | Why |
|---|---|---|
| Result plots (line, bar, scatter) | `matplotlib` 3.11.2 `with plt.xkcd():` → `savefig('.svg')` | The script probably already exists. One wrapper line. Produces genuinely hand-drawn-looking axes and wobbled lines while the data stays exact. |
| Network graphs (echo chambers) | Export from networkx/graphviz to SVG → `svg2roughjs` 3.2.3 | Node-link diagrams roughen beautifully; the sketchy stroke reads as "sketched while thinking". |
| **Attention maps / heatmaps** | **Do not roughen the data.** Redraw only the *frame*: hand-drawn axis rules, a mono caption, a circled region with an arrow and a handwritten note. | Roughening a heatmap destroys the information it exists to convey — and the whole point of including these figures is credibility. Notebook styling belongs on the annotation, not the evidence. |
| Conceptual diagrams with no data | Excalidraw → export SVG | Fastest way to get something that looks thought-through rather than generated. |

**Committing the output.** SVG works through the gem's standard include with no special handling. `_includes/figure.liquid` branches on extension: for `gif/jpeg/jpg/png/tiff` it emits an ImageMagick-generated WebP `srcset`; for anything else — including `.svg` — it falls through to `srcset="{{ include.path | relative_url }}"` and the plain `<img src>`. So:

```liquid
{% include figure.liquid path="assets/img/figures/attention-sinks.svg" class="img-fluid" caption="..." zoomable=true %}
```

works today. No override. Constrain the SVG's `width`/`height`/`viewBox` at export so it does not cause layout shift.

**Excalidraw font caveat:** Excalifont (the Excalidraw hand-drawn face) has no known Vietnamese coverage. Keep all figure text in English — which is correct for an academic audience anyway.

---

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| Redeclare `--global-*` in `_custom.scss` | Shadow the gem's `_sass/_themes.scss` and `_sass/_variables.scss` locally (documented in `docs/CUSTOMIZE.md` §"Changing theme color") | Only if you need to change a Sass *variable* the gem consumes at compile time that has no runtime token — e.g. `$back-to-top-diameter`. Costs an entry in `.al-folio-overrides.yml` and upgrade drift forever. Prefer the token route. |
| Source Serif 4 | Literata | If the design reads too cool in review and the extra 108 KB is acceptable. Literata is the warmest option that is still fast. |
| IBM Plex Mono for labels | IBM Plex Sans / Inter | If mono labels read too "engineering" against a warm paper ground. Both have Vietnamese. |
| Tiled noise PNG | Live `feTurbulence` filter | Only if the tiling seam is visible at the required opacity and you are willing to override a layout to host `<defs>`. |
| `svg2roughjs` at authoring time | `roughjs` scripted directly | When the source SVG's structure defeats the converter (dense scatter plots, gradients). |
| Static SVG marks | `rough-notation` in the browser | Never, for this project. See below. |
| Hand-authored HTML in `_pages/about.md` | Overriding `_layouts/about.liquid` | Only if the *order* of page regions must change — e.g. the entry-point cards must render above the intro prose, or the portrait must go full-bleed at the very top. `about.liquid` renders `{{ content }}` inside a `.clearfix` **between** the profile float and the news/papers/social blocks, so anything authored in the markdown lands in that one slot. Flexbox `order` on `.post > *` can reshuffle top-level regions without an override; try that first. |

---

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| **Caveat** (and Kalam, Architects Daughter, Gloria Hallelujah, Reenie Beanie, Nanum Pen Script, Courier Prime, DM Mono, Libre Baskerville) | **No Vietnamese subset — verified.** `ạ` in "Phạm" falls back to a different face mid-word. Caveat is the single most-recommended font for notebook aesthetics on the web, which makes this the most likely mistake in the whole project. | Shantell Sans or Patrick Hand for hand-drawn text; Source Serif 4 / IBM Plex Mono for everything else. |
| Source Serif 4 with the `opsz` axis | 580 KB vs 171 KB for a difference invisible at one body size | `ital,wght@0,400;0,600;1,400` static instances. |
| `rough-notation` 0.5.1 | Last published **2020-10-30** — six years unmaintained. It is runtime JS that animates annotations over live text, which adds a blocking script, forces layout reads, and injects decorative SVG into the accessibility tree for no semantic gain. | Static inline-SVG data-URI marks in `_custom.scss`. |
| `rough-viz` 2.0.5 / `chart.xkcd` 2.0.12 at runtime | Pull D3 or a chart runtime into a static academic site purely for decoration. The figures are fixed images of finished research — they have no reason to be computed in the browser. | Generate the figure once, commit the SVG. |
| The `al_charts` gem for these figures | It is installed and could render Chart.js/ECharts/Plotly, but it loads a runtime chart library per page. Same objection as above. | Committed SVG via `figure.liquid`. |
| Adding Tailwind utility classes to markup | The gem's `tailwind.css` is **prebuilt and frozen**; the `tailwind.config.js` it was compiled against is not even shipped. Unrecognised classes produce no CSS and fail silently — the exact silent-failure mode `AGENTS.md` warns about. | Semantic classes in `_custom.scss`. Only reuse classes from the verified 309-selector list. |
| A local Tailwind/PostCSS build pipeline | `test/style_contract.js` still actively rejects `build:css`, `build:tailwind` and `build:tailwind:watch` in `package.json`. Also unnecessary: plain SCSS in `_custom.scss` compiles through Jekyll's existing Sass converter and lands *after* Tailwind in the cascade, which is exactly where you want it. | `_sass/_custom.scss`. |
| `filter: url(#grain)` on `body` or any wrapper | Creates a containing block for `position: fixed` descendants — silently breaks the fixed navbar and the back-to-top button, both enabled here. Also needs an `<svg><defs>` in the document, which would force the project's only layout override. | Tiled noise PNG on a `position: fixed; z-index: -1` pseudo-element. |
| `background-attachment: fixed` for the paper ground | Forces full-page repaint on scroll in several engines; a known jank source on long pages. | A separate `position: fixed; inset: 0; z-index: -1; pointer-events: none` layer. |
| Overriding `_includes/head.liquid` just to add `rel="preconnect"` | Buys ~100–200 ms and costs a permanent override of the most upgrade-sensitive file in the gem | Self-host the fonts from `assets/fonts/` with `@font-face` in `_custom.scss` — no third-party origin, so no preconnect needed. |

---

## Stack Patterns by Variant

**If the requirement is "change a colour, a font, a spacing, a border, a shadow, a texture":**
- Use `_sass/_custom.scss`, redeclaring `--global-*` tokens and writing unlayered rules.
- Because unlayered beats every cascade layer in `tailwind.css`, and `custom` is `@use`d last in `main.scss`.

**If the requirement is "add a new visual component" (entry-point cards, book-cover grid, margin notes):**
- Hand-author semantic HTML in the page's markdown; style it with new classes in `_custom.scss`.
- Because the compiled Tailwind cannot grow, and because `about.liquid` / `page.liquid` render `{{ content }}` verbatim. Kramdown passes raw HTML through, as `_pages/about.md` already proves.

**If the requirement is "style one page differently":**
- For any page on the `page` layout: use the **`_styles:` front-matter key**. `_layouts/page.liquid` emits `{{ page._styles }}` into an inline `<style>` block, and the CSP allows `style-src 'unsafe-inline'`. A supported per-page escape hatch with zero override cost.
- For the home page (`about` layout, which has no `_styles` hook): a `<style>` block or a wrapper `<div class="home">` in `_pages/about.md`. There is **no page-specific body class** — `<body>` only ever carries `fixed-top-nav` and/or `sticky-bottom-footer`.

**If the requirement is "turn a feature off":**
- Check `_config.yml` first. Verified flags relevant here: `enable_darkmode`, `back_to_top`, `enable_progressbar`, `enable_medium_zoom`, `lazy_loading_images`, `navbar_fixed`, `footer_fixed`, `search_enabled`, `max_width`.
- Because the gem gates these with `{% if site.* %}` in `head.liquid` / `header.liquid` / `default.liquid`. Turning `enable_darkmode` off removes the toggle **markup**, the `theme.js` **script**, and the dark Pygments stylesheet in one edit.

**If the requirement is "change what element renders, or in what order":**
- Try flexbox/grid `order` on the existing containers first.
- If that genuinely cannot work, copy the single gem file into this repo, record it with `bundle exec al-folio upgrade overrides audit`, commit `.al-folio-overrides.yml`, and say so explicitly in the PR as the override policy requires. Candidates, in ascending order of likelihood: `_layouts/about.liquid` (region order), `_includes/header.liquid` (navbar markup), `_includes/head.liquid` (font preconnect / SVG defs — both avoidable).

---

## Dark Mode: the specific answer

**It is a one-line config change. No override.** Verified by reading the gem:

- `_includes/header.liquid:127` — the entire `<li class="toggle-container">` with `#light-toggle` is wrapped in `{% if site.enable_darkmode %}`. Flag off ⇒ the button is not emitted at all.
- `_includes/head.liquid:129–140` — `assets/js/theme.js`, the `initTheme()` call, and the dark Pygments stylesheet are all inside the same `{% if site.enable_darkmode %}`.
- `data-theme` appears **nowhere** in any layout or include. It is set exclusively by `theme.js` at runtime. With the flag off, `html[data-theme="dark"]` can never match, so every dark rule in `_sass/_themes.scss` is inert dead CSS.
- Nothing in the gem's SCSS or built CSS uses `@media (prefers-color-scheme)`. The only matches are inside `theme.js` itself, `giscus-setup.js` (giscus is unconfigured on this site) and two `code_diff` stylesheet links that only render when a page sets `code_diff:`.

Set `enable_darkmode: false` in `_config.yml`. That is the whole change.

One residual: `_sass/_themes.scss` still ships `:root { color-scheme: light; }`, which is correct and desirable for a light-only site — it makes form controls and scrollbars render light. Leave it.

---

## Version Compatibility

| Package | Compatible with | Notes |
|---------|-----------------|-------|
| `al_folio_core` 1.0.15 | Current latest on RubyGems (2026-08-03) | **No upgrade needed before this milestone.** Verified via `rubygems.org/api/v1/versions/al_folio_core.json`. |
| `al_folio_upgrade` 1.0.3 | Current latest (2026-05-25) | The `overrides audit` tooling is current. |
| Tailwind 4.1.18 | Declared in `_config.yml` under `al_folio.tailwind.version`; matches the `/*! tailwindcss v4.1.18 */` banner in the gem's built `assets/css/tailwind.css` | This key is **descriptive, not a build input** — changing it compiles nothing. |
| `svg2roughjs` 3.2.3 | `roughjs ^4.6.6` | Authoring-time only. Never add to `package.json`; `npx` it. |
| Google Fonts `css2` API | The gem's `google_fonts.url.fonts` key | The gem's current value uses the older `css?family=` v1 syntax. Both work; `css2` is required for variable-axis and `ital,wght` syntax. |
| Source Serif 4 v14 | SIL OFL 1.1 | Self-hosting is licence-permitted. |
| IBM Plex Mono | SIL OFL 1.1 | Same. |

---

## Sources

**Primary — the installed gem, read on disk** (HIGH confidence). Ruby is not on this machine's PATH, so `al_folio_core-1.0.15.gem` was downloaded from `rubygems.org/downloads/` and unpacked; all claims below come from reading those files:

- `_sass/_themes.scss` — the 29 `--global-*` tokens, the `html[data-theme="dark"]` block, the `#light-toggle-*` display rules
- `_sass/_variables.scss` — `$max-content-width: 930px !default`, `$back-to-top-*`, the palette
- `_sass/_layout.scss`, `_typography.scss`, `_components.scss`, `_blog.scss` — which selectors read tokens and which hardcode colours
- `assets/css/tailwind.css` — 27,355 bytes, `/*! tailwindcss v4.1.18 */`, layers `properties/theme/utilities/base/components`, 309 class selectors, `.card` and `.card-text` hardcoded colours, the `!important` Bootstrap-compat utilities
- `assets/tailwind/app.css` — `@config "../../tailwind.config.js"` referencing a file **not shipped in the gem**, confirming the CSS is frozen at gem-build time
- `_includes/head.liquid` — CSS load order (`tailwind.css` then `main.css`), `site.third_party_libraries.google_fonts.url.fonts`, the `{% if site.enable_darkmode %}` gate, the CSP
- `_includes/header.liquid` — the `{% if site.enable_darkmode %}` gate on the toggle button
- `_includes/figure.liquid` — the non-raster extension branch that makes `.svg` work unmodified
- `_layouts/about.liquid`, `page.liquid`, `default.liquid` — `{{ content }}` placement, the `page._styles` hook, the `<body>` class set

**Repo files read directly** (HIGH confidence): `assets/css/main.scss`, `_sass/_custom.scss`, `Gemfile`, `_config.yml`, `_pages/about.md`, `.al-folio-overrides.yml`, `package.json`, `test/style_contract.js` (forbidden-path block commented out), `.github/workflows/lighthouse-badger.yml` (points at the upstream demo URL), `.github/workflows/axe.yml` (`workflow_dispatch` only), `.github/workflows/visual-regression.yml`, `docs/CUSTOMIZE.md`, `docs/ARCHITECTURE.md`.

**Live API verification** (HIGH confidence):
- `https://fonts.googleapis.com/css2?family=…` — Vietnamese subset presence for 37 typefaces; woff2 payloads measured per subset by downloading each file
- `https://rubygems.org/api/v1/versions/al_folio_core.json` — 1.0.15 is latest (2026-08-03)
- `https://registry.npmjs.org/{roughjs,rough-notation,rough-viz,svg2roughjs,@excalidraw/excalidraw,chart.xkcd}` — versions, licences, publish dates
- `https://pypi.org/pypi/matplotlib/json` — 3.11.2

**Web research** (MEDIUM confidence — technique guidance, corroborated across multiple sources):
- [SVG Filter Effects: Creating Texture with feTurbulence — Codrops](https://tympanus.net/codrops/2019/02/19/svg-filter-effects-creating-texture-with-feturbulence/)
- [Grainy Gradients — CSS-Tricks](https://css-tricks.com/grainy-gradients/)
- [Creating Patterns With SVG Filters — CSS-Tricks](https://css-tricks.com/creating-patterns-with-svg-filters/)
- [Rough.js](https://roughjs.com/) and [rough-stuff/rough](https://github.com/rough-stuff/rough)
- [svg2roughjs — npm](https://www.npmjs.com/package/svg2roughjs)
- [Excalifont — Excalidraw](https://plus.excalidraw.com/excalifont) and [Adding hand-drawn CJK font to Excalidraw](https://plus.excalidraw.com/blog/adding-hand-drawn-font-for-chinese-japanese-korean) (font embedding + glyph subsetting in SVG export)

**Gaps / not resolved:**
- Excalifont's Vietnamese coverage was not verified directly (the font is not on Google Fonts). Mitigated by keeping figure text in English.
- Whether a 128×128 tiled noise PNG shows a visible seam at the chosen opacity is an empirical question — decide it in the texture phase, not in planning.
- The `al_icons` / Font Awesome CDN payload was not audited. If the redesign drops most icons, there may be a further performance win in `third_party_libraries`, but that was out of scope here.

---
*Stack research for: research-notebook visual redesign on al-folio v1.x*
*Researched: 2026-09-12*

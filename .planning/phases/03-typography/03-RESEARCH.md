# Phase 3: Typography - Research

**Researched:** 2026-09-16
**Domain:** Web typography delivery (Google Fonts v2 API, Vietnamese unicode-range subsetting, variable vs. static cuts), CSS type scale tokens, measure/line-length, PurgeCSS selector survival
**Confidence:** HIGH for everything measured against the live network and the deployed site; MEDIUM for the two items that need a browser (optical descender re-check, fallback-swap appearance)

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Typeface pairing**

- **Body serif: Literata.** Chosen over Source Serif 4, EB Garamond and Newsreader. Designed for long screen reading, warm without novelty, and its Vietnamese diacritics are properly drawn rather than auto-composed.
- **Companion: Be Vietnam Pro** (sans), carrying labels, years, metadata and status — `.entry-year`, `.entry-meta`, `.entry-status`, `.subject-grade`. Chosen over IBM Plex Sans, Inter and Source Sans 3 specifically because it was drawn by a Vietnamese foundry with stacked diacritics as a design premise, which is the one face on the shortlist where TYPE-01 and TYPE-03 are guaranteed by design intent rather than by subset availability.
- **A sans, not a mono.** Deciding input: the site has **zero code blocks and four inline backticks** total across `_pages/`, `_projects/` and `_data/`. The companion is therefore optimised for labels, which is what actually appears. A mono companion was rejected — it would pull toward the "dark deep-focus terminal" direction PROJECT.md explicitly considered and rejected.
- **Code takes the bare `monospace` generic.** Drop the `Iosevka Fixed` family name from the stack: it is never loaded (zero `@font-face` in the served `main.css`, absent from the fonts URL), so code already falls back to system mono today. This is a cleanup of a dead name, not a behaviour change.
- **The cap at `_sass/_tokens.scss:23` is set to `2`.** A CSS generic is not a chosen type family, so the cap reads honestly. Raising it to 3 for a real webfont mono was considered and rejected — real bytes and a visible cap edit, for four backticks.

**Webfont budget and delivery**

- **Five cuts, and no more:**

  | Family | Cut | Carries |
  | --- | --- | --- |
  | Literata | 400 | body copy |
  | Literata | 400 italic | `.entry-status`; Phase 4 marginalia |
  | Literata | 600 | `h1`–`h2`, `.post-title`, navbar brand |
  | Be Vietnam Pro | 400 | `.entry-year`, `.entry-meta`, nav links |
  | Be Vietnam Pro | 600 | strong labels |

  Variable fonts were rejected: only Literata has a variable version on Google Fonts, so the extra bytes buy flexibility for one of the two families.

- **Budget: 150 KB, text faces only**, measured over the `latin` + `vietnamese` subsets on first load. This is the number criterion 5 measures against.
- **Icon fonts are measured and recorded separately**, not counted against the type budget — they are inherited payload this phase is not designing. Record the figure anyway so it is visible.
- **`display=swap` is kept.** Text must always be visible: an admissions reader on a slow connection never sees a blank page. `display=optional` was rejected because a cold-cache first visit could render the entire typography phase in the fallback.
- **Fallback stacks are picked to be metric-close** — a Georgia-class serif behind Literata, a system sans behind Be Vietnam Pro — so the swap is a small shift rather than a relayout.
- **Dead payload is dropped:** Material Icons (goes with the fonts URL rewrite; used nowhere), plus `academicons` and `scholar-icons`, which render nothing because `_data/socials.yml` has only `email` active. **Font Awesome stays** for that one envelope. Replacing the envelope with inline SVG was rejected as Phase 6 territory.

**Heading hierarchy and the name**

- **Scale — "decisive", as multiples of body size:**

  | Token | Multiple | Applies to |
  | --- | --- | --- |
  | `--step-5` | 2.6x | `h1`, `.post-title` |
  | `--step-4` | 1.8x | `h2` (criterion 4 floor 1.5x) |
  | `--step-3` | 1.35x | `h3` (criterion 4 floor 1.25x) |
  | `--step-2` | 1.15x | `.entry-title`, `h4` |
  | `--step-1` | 1x | body |
  | `--step-0` | 0.85x | meta, status |

  Both floors clear with margin, deliberately. A strict 1.25 modular scale was rejected because it lands `h3` exactly on the 1.25x floor, where rem-to-px rounding could fail the measurement.

- **`--step-4` and `--step-5` are NEW token names.** `_tokens.scss` stops at `--step-3`. Its comment authorises re-tuning values; adding names is a slightly larger move and should be made deliberately, in that file, with the block comment updated.
- **Headings are serif throughout.** `h1`–`h6` and `.post-title` all take Literata; Be Vietnam Pro is reserved strictly for labels, years, metadata and status. This is the division TYPE-02 states. Sans headings were rejected: they pull toward "academic editorial magazine", a direction PROJECT.md considered and rejected.
- **Weight is the second lever.** `h1`/`h2` at 600, `h3` at 400. Costs nothing — both cuts are already in the five. This gives Phase 7's greyscale-plus-blur test a lever beyond size, alongside the ink depth Phase 2 already shipped.
- **The name appears in two places, not one.** `_config.yml:5` is `title: blank`, so the navbar brand renders the full name as well as `.post-title` does. **Both take Literata**, so the identity reads as one. Nav links (About, Academics, Research…) take Be Vietnam Pro as navigational furniture — consistent with the Phase 2 reasoning that left them deliberately un-underlined.
- Small-caps for `h3` was rejected: small-caps plus stacked Vietnamese diacritics is a real rendering hazard and not worth the risk in this phase.

**Measure and reading density**

- **`max_width` stays at `930px`.** It is NOT narrowed. Phase 2 left it untouched on purpose and flagged it as this phase's decision; the decision is to keep the page width and measure the prose instead.
- **A new `--measure` token at ~36rem (~576px)** constrains the prose flow. Arithmetic: at 930px a Literata line holds roughly 110 characters against criterion 4's 45–75 window; 36rem lands at 64–72 characters across any sensible body size. Narrowing the whole page to ~640px was rejected — `.entry` spends `--entry-year-col: 5rem` on the year gutter, and the CV page would be cramped.
- **The measure applies to the prose flow:** `p`, `h1`–`h6`, `ul`, `ol`, `blockquote` inside `.post article`. Headings and paragraphs share a right edge so the column reads as one deliberate block. **Excluded, keeping the full 930px:** `.entry-list`, `.subject-list`, `.topic-list` entry structures, CV blocks and tables. Wrapping prose in an explicit markdown container was rejected — it edits content to solve a styling problem.
- **Body size: `1.0625rem` (17px).** Literata's large x-height reads about one step above nominal, so 17px optically matches 18px Georgia. Keeps page length close to today's, which matters for a 2–3 minute read.
- **Leading: `1.6` body, with a NEW separate heading token at ~1.2.** A serif at ~68 characters needs more air than the gem's 1.5, which was tuned for Roboto at 16px across a wide column. At `--step-5` (2.6x), 1.6 leaves a visible gap inside a two-line title, so headings need their own value.
- **The leftover margin is deliberate, not waste.** 930px page minus a 576px prose column leaves ~354px — exactly where Phase 4's marginalia and Phase 5's PAGE-06 ("marginalia visibly subordinate, collapses below roughly 768px") will live. This phase creates that gutter; it does not put anything in it.

### Claude's Discretion

- Exact `rem` values once the multiples above are applied to a 17px base, and whether to express steps as computed values or literals in `_tokens.scss`.
- The precise fallback stack members, provided they are metric-close to Literata and Be Vietnam Pro respectively.
- Heading margins and vertical rhythm (space above and below each level) — not discussed; use the existing `--space-*` scale.
- Whether `--step-2` gains a name change now that `h4` shares it with `.entry-title`.
- Phone-width type behaviour beyond not breaking; PAGE-03 and the 390px audit are Phase 7.

### Deferred Ideas (OUT OF SCOPE)

- **Replacing the Font Awesome envelope with an inline SVG** and dropping the last icon CDN entirely. Raised during the payload discussion and deliberately not taken: it touches the home page's social block, which is Phase 6's territory.
- **Rewriting the `.entry` layout to use the new type scale properly** — Phase 5 (PAGE-01) owns the entry vocabulary. This phase re-points tokens; it does not restructure components.
- **`prefers-reduced-motion`** — Phase 7, and only if a transition ships in Phase 4.
- **Reconsidering `title: blank` in `_config.yml`** so the navbar brand and the hero title could diverge. Not needed for this phase's decisions, which put both in Literata.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| TYPE-01 | The body serif has a verified Vietnamese unicode-range subset. | **VERIFIED TODAY.** Literata `v40` emits three `/* vietnamese */` `@font-face` blocks (400, 600, 400 italic) with `unicode-range: …U+1EA0-1EF9…`. Exact `curl` command and its UA requirement in *Finding 1*. |
| TYPE-02 | A companion face carries labels, metadata and code. | Be Vietnam Pro `v12` verified with a `/* vietnamese */` block per cut. Consumer selectors confirmed present in the deployed HTML (*Finding 8*). "Code" resolves to the bare `monospace` generic — no CSS change is actually required, see *Finding 9*. |
| TYPE-03 | "Phạm Hà Khánh Chi" renders entirely in one typeface. | Measured: `à`/`á` (U+00E0/U+00E1) live in the **latin** subset, `ạ` (U+1EA1) in the **vietnamese** subset, of the **same family** — both files must load, both are Literata. *Finding 2*. A second, undocumented one-name-two-weights hazard exists in the navbar brand — *Finding 10*, must be fixed in this phase. |
| TYPE-04 | Heading hierarchy is distinguishable at a glance, and the measure is set deliberately rather than inherited. | Exact rem values and a `calc()` form that makes the 1.8x / 1.35x ratios greppable in the **served** CSS (*Finding 4*). Measure arithmetic from real Literata metrics: 36rem → ~70 CPL, inside the 45–75 window (*Finding 5*). Correct DOM-aware selector list in *Finding 6*. |
| TYPE-05 | Total webfont payload stays within a stated budget. | Every byte measured from `fonts.gstatic.com` today: **141,232 B (137.9 KiB)** for the five locked cuts over latin+vietnamese, against a 150 KB budget. Full table, the lever if it ever breaches, and the separately-recorded icon figure in *Finding 3*. |
</phase_requirements>

## Summary

Every load-bearing number in this phase was measured against the live network and the deployed site on 2026-09-16, not asserted. The headline result is that **the locked plan works and fits**: Literata and Be Vietnam Pro both ship real `/* vietnamese */` subsets, the five locked cuts total **141,232 bytes** over latin+vietnamese against the stated 150 KB budget, and a 36rem measure at 17px Literata lands at roughly 70 characters per line — inside criterion 4's 45–75 window.

Two of CONTEXT.md's four "research flags" turn out to be wrong or mis-diagnosed, and correcting them changes what the plan has to do. **Flag 1 is false: the v1 `css?family=` endpoint does emit `/* vietnamese */` blocks.** The real variable is the `User-Agent` — a bare `curl` gets unsubsetted TTF with no `unicode-range` at all, from *both* endpoints. Criterion 2's proof command must therefore send a modern browser UA, and the reason to move to `css2` is the API's per-axis weight syntax (and dropping Material Icons), not subset availability. **Flag 3 is settled: no preconnect or preload is reachable.** There is no config key for it, the `<head>` is gem-owned, and the fonts `<link>` is emitted as `<link defer rel="stylesheet">` (`defer` is inert on `<link>`). `display=swap` plus metric-close fallbacks is the whole loading strategy available.

The two findings the plan is most likely to get wrong on its own are structural, not typographic. First, **the home page's prose is not a direct child of `<article>`** — it sits inside `<div class="clearfix">` — while the entry pages put their `h2`/`h3` inside `<section class="entry-group">`. A naive `.post article p, .post article h2 {…}` measure hits every `.entry-group-title` and `.entry-title` (which CONTEXT explicitly excludes), and a naive `.post article > p` misses the home page entirely. Second, **PurgeCSS will silently strip `ol`, `blockquote` and possibly `h4` from any selector list this phase writes**, because none of those tags appears in any built page — the exact failure mode that cost Phase 2 a day with `:focus-visible`.

**Primary recommendation:** Run the two-family `curl` proof first and record its output verbatim in the commit; then re-point `_tokens.scss` using `calc(var(--step-1) * N)` so the ratios criterion 4 measures are auditable by `grep` against the served CSS; write the measure as an explicit two-level child-combinator selector list (`.post article > X` **and** `.post article > .clearfix > X`); and add `ol`, `blockquote`, `h4` to `purgecss.config.js` in the same commit as the rule that needs them.

---

## Standard Stack

### Core

| Thing | Version / value | Purpose | Why this one |
|---------|-------|---------|--------------|
| Google Fonts CSS API **v2** (`/css2?family=`) | live, checked 2026-09-16 | serves both families' `@font-face` + `unicode-range` | Only endpoint with the `ital,wght@` axis syntax that expresses the five locked cuts in one request. (v1 also serves vietnamese — see Finding 1 — but cannot express `ital,wght` tuples cleanly.) |
| Literata | `v40` on `fonts.gstatic.com` | body serif, all headings | Locked in CONTEXT. Verified vietnamese subset; metrics measured below. |
| Be Vietnam Pro | `v12` on `fonts.gstatic.com` | labels, years, metadata, nav | Locked in CONTEXT. Verified vietnamese subset. **No variable version exists** — `wght@400..600` returns HTTP 400, confirming CONTEXT's assumption. |
| `_sass/_tokens.scss` | this repo | the single token surface | Established Phase 2 discipline; the in-file comment already authorises Phase 3 to re-tune here. |
| `purgecss.config.js` | purgecss 8.0.0 | production CSS pruning | Load-bearing. Runs **only** in CI deploys, never locally. |
| `verify.sh` + `--live` | this repo's convention | the phase's whole test framework | No Ruby, no `bundle`, no `_site/` on this machine. The deployed site is the only real check. |

### Supporting

| Thing | Purpose | When to use |
|---------|---------|-------------|
| `@capsizecss/metrics@3.5.0` (read-only, via jsDelivr) | authoritative `unitsPerEm` / `xHeight` / `capHeight` / `xWidthAvg` per family | Already used below to pick the fallback stacks and compute CPL. **Do not add it as a dependency** — the numbers are transcribed into this document. |
| A `.planning/tools/fontbudget.js` (proposed, ~60 lines, zero deps) | re-measure the webfont payload on demand, the way `contrast.js` re-measures ratios | Recommended: criterion 5 otherwise depends on a one-off DevTools reading nobody can reproduce. Mirrors the `contrast.js` precedent exactly. |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `css2` multi-weight request | Two separate single-weight requests | Impossible — Google merges duplicate `family=` params. And the variable file is *cheaper* than the statics it replaces (Finding 3). |
| `display=swap` | `size-adjust`/`ascent-override` on a local `@font-face` fallback | Would perfect the swap, but introduces a **named font family** in `_sass/` that criterion 3's "no third type family" grep would flag, plus a second `@font-face` block to maintain. Not worth it this phase. |
| Google-hosted fonts | `third_party_libraries.download: true` | That flag is **global to all third-party libraries**, not per-library. It would also self-host Font Awesome, bootstrap-table, MathJax and highlight.js in one flip, and create `assets/webfonts/`. High blast radius, zero benefit here. Rejected. |

**Installation:** none. No npm package, no gem, no Gemfile change. The entire phase is `_config.yml` (one string), `_sass/_tokens.scss`, `_sass/_custom.scss`, `purgecss.config.js`, and a new `verify.sh`.

---

## Findings

### Finding 1 — CONTEXT research flag 1 is WRONG. The variable is the User-Agent, not the API version. **[HIGH — measured]**

CONTEXT.md states: *"The v1 Fonts API cannot satisfy criterion 2… The `/* vietnamese */` unicode-range block that criterion 2 requires by `curl` is emitted by the **v2** `css2?family=` endpoint. The rewrite to v2 is a necessity, not a preference."*

Measured, this is false. The **currently deployed** v1 URL already returns nine `/* vietnamese */` blocks:

```
$ curl -sS -A "$UA" "https://fonts.googleapis.com/css?family=Roboto:300,400,500,700|Roboto+Slab:100,300,400,500,700|Material+Icons&display=swap" \
    | grep -o '/\* [a-z-]* \*/' | sort | uniq -c
      9 /* cyrillic */   9 /* cyrillic-ext */   1 /* fallback */
      9 /* greek */      9 /* greek-ext */      9 /* latin */
      9 /* latin-ext */  4 /* math */           4 /* symbols */
      9 /* vietnamese */
```

The actual failure mode is the request's `User-Agent`. **Without** one, *both* endpoints return unsubsetted TrueType with no `unicode-range` and no subset comments at all:

```
$ curl -sS "https://fonts.googleapis.com/css2?family=Literata:wght@400&display=swap"
@font-face {
  font-family: 'Literata'; font-style: normal; font-weight: 400; font-display: swap;
  src: url(…/or3PQ6P12-…_F_Y.ttf) format('truetype');     <-- TTF, no unicode-range
}
```

**What this means for the plan.** The move to `css2` is still right — it is the endpoint with the `ital,wght@` tuple syntax, and the rewrite is where Material Icons gets dropped — but it must be justified as *syntax and payload*, not as *the only way to get vietnamese*. More importantly, **criterion 2's proof command is only valid with a browser UA**, and that is the thing to record in the commit. Use exactly:

```bash
UA='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
curl -sS -A "$UA" \
  "https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;600&family=Literata:ital,wght@0,400;0,600;1,400&display=swap" \
  | grep -c '/\* vietnamese \*/'
# => 5     (one per cut: BVP 400, BVP 600, Literata 400i, Literata 400, Literata 600)
```

A `verify.sh` row asserting `= 5` is the automated form of criterion 2.

### Finding 2 — The name spans two subset files of one family. That is correct, not a bug. **[HIGH — measured]**

| Glyph | Codepoint | Subset that carries it |
|---|---|---|
| `à` | U+00E0 | `latin` — `unicode-range: U+0000-00FF, …` |
| `á` | U+00E1 | `latin` |
| `ạ` | U+1EA1 | `vietnamese` — `unicode-range: …, U+1EA0-1EF9, U+20AB` |
| `ầ` `ợ` etc. | U+1EA0–1EF9 | `vietnamese` |

So "Phạm Hà Khánh Chi" pulls from **two `@font-face` rules of the same `font-family`**. Both are Literata, drawn together, so criterion 1 holds — but it means the vietnamese file *must* load for the name to render in Literata at all. If the vietnamese request fails, exactly one glyph falls back, which is precisely the TYPE-03 failure REQUIREMENTS.md describes.

Note also that the vietnamese range includes the **combining marks** U+0300-0301, U+0303-0304, U+0308-0309, U+0323 — so stacked diacritics compose from the vietnamese file too.

**Verification caveat for criterion 1:** `--step-5` = 2.6 × 17px = **44.2px**, which is *below* the "48px or larger" the criterion names. The criterion is describing how to *inspect* (zoom in and compare `ạ` against `à`), not prescribing the h1 size. Plan the check as a DevTools font-size bump or browser zoom on the deployed `h1.post-title`, and say so, rather than silently sizing the h1 up to 48px to satisfy a misread.

### Finding 3 — The budget: 141,232 bytes measured, against 150 KB. It fits, with 12 KB of headroom. **[HIGH — every byte downloaded and counted]**

Every `woff2` referenced by the combined css2 URL, for the `latin` and `vietnamese` subsets only:

| Family | Cut | latin (B) | vietnamese (B) | file total (B) |
|---|---|---:|---:|---:|
| Literata | 400 + 600 roman (**one shared variable file**) | 38,996 | 8,984 | **47,980** |
| Literata | 400 italic | 21,148 | 5,196 | **26,344** |
| Be Vietnam Pro | 400 | 21,168 | 11,532 | **32,700** |
| Be Vietnam Pro | 600 | 22,032 | 12,176 | **34,208** |
| | **TOTAL (8 files)** | **103,344** | **37,888** | **141,232** |

- **141,232 B = 137.9 KiB = 141.2 kB decimal.**
- The Google Fonts CSS response itself transfers at **936 B** gzipped (today's v1 URL: 2,315 B).

**Three non-obvious facts inside that table:**

1. **Literata 400 and 600 are byte-identical URLs.** Requesting more than one weight makes Google serve the *variable* font, which covers 200–900. The browser fetches it once. So the 600 heading weight does **not** cost a second file — but it is not free either: the variable roman (47,980 B) replaces what would have been a 25,604 B static 400. **The 600 weight costs 22,376 B.**
2. **`Be Vietnam Pro` has no variable version.** `css2?family=Be+Vietnam+Pro:wght@400..600` returns **HTTP 400**. CONTEXT's assumption is confirmed; the two cuts are two separate files.
3. **The single most expensive optional cut is Be Vietnam Pro 600 (34,208 B).** If the budget is ever breached, that is the lever — dropping it lands at 107,024 B. Second lever: Literata italic (26,344 B), but see the open question in *Finding 11*.

**Honest framing for the phase write-up.** Today's payload is Roboto's variable file at **57,476 B** (latin 43,136 + vietnamese 14,340; Roboto Slab and Material Icons are declared but never fetched, since no rule and no element uses them). So this phase makes the site's font payload **2.46× larger**, not smaller. It fits the budget; it is not a saving. State it that way.

**State the budget in bytes.** "150 KB" is ambiguous and the margin is ~9% — Chrome DevTools reports decimal kB (141.2) while `ls`/`du` report KiB (137.9). Recommend the phase state **"150 KiB = 153,600 bytes"**, with measured **141,232 B = 91.9% of budget**.

**Per-page caveat that will confuse the DevTools reading.** A browser fetches a subset file only when a glyph in its `unicode-range` actually renders. A page with no italic text never downloads the two Literata italic files. So the DevTools number varies by page; 141,232 B is the **worst case**, on a page that renders body + headings + italic + sans labels. Measure criterion 5 on `/research/` (which renders `.entry-status` italic, `.entry-meta` sans, `h2`/`h3` and body) and say which page it was.

**Icon payload, recorded separately as CONTEXT requires:**

| Asset | Bytes | Fetched today? |
|---|---:|---|
| `fontawesome-free@7.2.0/css/all.min.css` | 75,736 | yes (render-blocking) |
| `fa-solid-900.woff2` | 114,740 | yes — both used icons (`fa-magnifying-glass`, `fa-envelope`) are solid |
| `fa-regular-400.woff2` / `fa-brands-400.woff2` / `fa-v4compatibility.woff2` | 18,924 / 110,088 / 4,032 | no — no matching classes in any built page |
| `academicons@1.9.5/css/academicons.min.css` | 7,812 | yes, and **renders nothing** — zero `ai-` classes site-wide |
| `scholar-icons@1.0.3/css/scholar-icons.css` | 6,251 | yes, and **renders nothing** — zero `si-` classes site-wide |

**Icon total actually fetched today: 204,539 B** — larger than the entire type budget. Dropping `academicons` and `scholar-icons` removes **14,063 B and two render-blocking requests** for zero visual change; that is measured, safe, and inside this phase's locked decisions.

### Finding 4 — Exact scale values, and a form that makes criterion 4 greppable. **[HIGH]**

Root font size is 16px (the gem sets `body{font-size:1rem}` and never touches `html`), so `1rem` = 16px throughout and `--measure: 36rem` = 576px regardless of the body size change.

Applying the locked multiples to a 17px (`1.0625rem`) base:

| Token | Multiple | px | Literal rem | `calc()` form (**recommended**) |
|---|---:|---:|---|---|
| `--step-0` | 0.85 | 14.45 | `0.903125rem` | `calc(var(--step-1) * 0.85)` |
| `--step-1` | 1.00 | 17.00 | `1.0625rem` | `1.0625rem` (the base — a literal) |
| `--step-2` | 1.15 | 19.55 | `1.221875rem` | `calc(var(--step-1) * 1.15)` |
| `--step-3` | 1.35 | 22.95 | `1.434375rem` | `calc(var(--step-1) * 1.35)` |
| `--step-4` | 1.80 | 30.60 | `1.9125rem` | `calc(var(--step-1) * 1.8)` |
| `--step-5` | 2.60 | 44.20 | `2.7625rem` | `calc(var(--step-1) * 2.6)` |

**Use the `calc()` form.** Three reasons, in order of weight:

1. **Criterion 4 becomes statically verifiable.** "H2 is at least 1.5x body size and H3 at least 1.25x" can be asserted by a `verify.sh` row grepping the **served** CSS for `--step-4:calc(var(--step-1)*1.8)`. With literal rems the ratio is only recoverable by dividing two numbers a reader has to trust. This site has no browser-based test framework; a greppable ratio is the difference between an automated row and a manual one.
2. No rounding. `0.903125rem` and `1.434375rem` are ugly and invite a future "tidy-up" to `0.9rem`/`1.43rem` that silently moves the ratio.
3. Re-tuning the base re-tunes the whole scale from one line, which is what the `_tokens.scss` header comment promises.

**Sass safety (HIGH confidence).** Dart Sass parses custom-property values as unquoted strings and passes them through verbatim (only `#{}` interpolation is evaluated), so `calc(var(--step-1) * 1.8)` survives compilation unchanged. It also survives PurgeCSS, which does not touch declaration values. **But `main.css` is compiled compressed**, so write every `verify.sh` grep whitespace-tolerantly — `--step-4:[[:space:]]*calc\(var\(--step-1\)[[:space:]]*\*[[:space:]]*1\.8\)` — exactly as Phase 2's harness does.

New tokens this phase adds to the same block: `--step-4`, `--step-5`, `--measure`, `--leading-heading`, `--font-serif`, `--font-sans`. Re-pointed: `--step-0` … `--step-3`, `--leading-body` (1.5 → 1.6). Cap line at `_tokens.scss:23` gets its `2`.

**Declare the families as tokens.** `--font-serif` and `--font-sans` in `_tokens.scss` keeps `_custom.scss` literal-free in spirit and, more usefully, makes criterion 3 ("no third type family present anywhere") a one-file grep instead of a whole-directory audit.

### Finding 5 — The measure: 36rem lands at ~70 characters. It passes, and it passes for a reason you can check. **[HIGH — from real font metrics]**

Measured from `@capsizecss/metrics@3.5.0`, normalised to em:

| Family | unitsPerEm | xHeight | capHeight | xWidthAvg | → x-height/em | → avg char width/em |
|---|---:|---:|---:|---:|---:|---:|
| **Literata** | 1000 | 507 | 701 | 480 | **0.507** | **0.480** |
| Georgia | 2048 | 986 | 1419 | 913 | 0.481 | 0.446 |
| Times New Roman | 2048 | 916 | 1356 | 832 | 0.447 | 0.406 |
| **Be Vietnam Pro** | 1000 | 530 | 740 | 492 | **0.530** | **0.492** |
| Arial | 2048 | 1062 | 1467 | 913 | 0.519 | 0.446 |
| Segoe UI | 2048 | 1024 | 1434 | 908 | 0.500 | 0.443 |
| Roboto | 2048 | 1082 | 1456 | 911 | 0.528 | 0.445 |
| Helvetica Neue | 1000 | 517 | 714 | 450 | 0.517 | 0.450 |

**CPL arithmetic.** `xWidthAvg` is the English-frequency-weighted average advance width, which is what characters-per-line actually measures.

```
576px / (0.480 × 17px) = 576 / 8.16 = 70.6 characters
```

Inside the 45–75 window with ~6% margin at the top. And the margin is one-sided in our favour: ragged-right wrapping means real lines are **shorter** than the maximum, and this site's prose is technical (long words, more capitals) which lowers CPL further. **36rem is safe.** If a deployed measurement ever comes back over 75, the fix is 34rem (544px → 66.7). Also note: CONTEXT's claim that 930px holds "roughly 110 characters" checks out — 930/8.16 = 114.

**Fallback stacks — measured, not guessed:**

- **Serif: `Literata, Georgia, "Times New Roman", serif`.** Georgia is −5% on x-height and −1% on cap height against Literata; Times New Roman is −12% and −5%. Georgia must come first and Times New Roman is a distant third-choice, not an equal alternative.
- **Sans: `"Be Vietnam Pro", -apple-system, "Segoe UI", Roboto, Arial, sans-serif`.** Be Vietnam Pro's x-height (0.530) is almost exactly Roboto's (0.528) and close to Arial's (0.519); Segoe UI (0.500) is the weakest of the three but is what Windows will actually use. All are ~9% narrower than Be Vietnam Pro, so expect a small horizontal settle on swap — acceptable, because the sans only carries short labels and years, never a wrapped paragraph.
- **[MEDIUM]** All four named fallbacks (Georgia, Times New Roman, Segoe UI, Arial) ship Vietnamese coverage on current Windows and macOS, so the swap window does not break `ạ`. Not independently verified here — worth one glance during the human check, since a fallback that lacks U+1EA1 would reproduce the TYPE-03 failure for the first few hundred milliseconds.

### Finding 6 — The measure selector: the DOM does not look like CONTEXT assumes. **[HIGH — read off all seven deployed pages]**

CONTEXT says the measure applies to *"`p`, `h1`–`h6`, `ul`, `ol`, `blockquote` inside `.post article`"* while *excluding* `.entry-list`, `.subject-list` and `.topic-list` structures. Those two clauses **contradict each other** under a descendant selector, because the entry pages put their headings inside `article`:

```html
<!-- academics / research / activities -->
<article>
  <section class="entry-group">
    <h2 class="entry-group-title">Qualifications</h2>     <!-- h2 INSIDE .post article -->
    <ul class="entry-list">
      <li class="entry"><div class="entry-year">…</div>
        <div class="entry-body"><h3 class="entry-title">…</h3>  <!-- h3 INSIDE .post article -->
```

…and the home page does **not** put its prose directly in `article` either:

```html
<!-- home -->
<article>
  <div class="clearfix">                                   <!-- prose wrapper -->
    <h2 id="about-me">About me</h2>
    <p>The one thing I want you to remember…</p>
```

So:

- `.post article p { max-width: … }` (descendant) — hits `.entry-detail`, `.card-text`, and constrains `.entry-title`/`.entry-group-title` too. Violates the exclusion clause.
- `.post article > p { … }` (child) — **misses the entire home page**, the page with the most prose.

**Recommended selector: an explicit two-level child list.**

```scss
.post article > p,
.post article > ul,
.post article > ol,
.post article > blockquote,
.post article > h2,
.post article > h3,
.post article > h4,
.post article > .clearfix > p,
.post article > .clearfix > ul,
.post article > .clearfix > ol,
.post article > .clearfix > blockquote,
.post article > .clearfix > h2,
.post article > .clearfix > h3,
.post article > .clearfix > h4 {
  max-width: var(--measure);
}
```

Verbose, but every consequence is visible and every selector is greppable in the served CSS — which is this project's established discipline. The child combinators guarantee `section.entry-group > h2`, `.entry-body > h3`, `.card-body > p` and `.subject-list` are untouched, satisfying the exclusion clause exactly.

Two structural notes the planner needs:

- **`h1.post-title` and `p.post-description` live in `<header class="post-header">`, a sibling of `<article>`.** They are outside every selector above and will keep the full 930px. If the intent is "headings and paragraphs share a right edge", the page title is *not* part of that edge under this selector. That is a real design decision, not an oversight — flag it for the human checkpoint rather than silently adding `.post > header` to the list.
- On `/cv/` and `/further-reading/`, `<p class="entry-detail">` **is** a direct child of `article`, so it does pick up the measure. That is correct (it is prose), just worth knowing.

**[MEDIUM] Do not use `:is()` here.** `.post article > :is(p,ul,ol,…)` is shorter and would work in browsers, but PurgeCSS's selector-node analysis of `:is()` is not something this project has ever exercised, and the failure mode is silent. Prefer the explicit list, which is known to degrade node-by-node in a way the safelist can correct.

### Finding 7 — PurgeCSS will strip `ol`, `blockquote` and possibly `h4` from that list. **[HIGH — census of all seven deployed pages]**

Tag census of the built HTML:

| Page | h1 | h2 | h3 | h4/h5/h6 | p | ul | ol | blockquote | pre | code | table |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| home | 1 | 3 | 0 | 0 | 5 | 1 | 0 | 0 | 0 | 0 | 0 |
| academics | 1 | 2 | 6 | 0 | 3 | 5 | 0 | 0 | 0 | 0 | 0 |
| research | 1 | 2 | 5 | 0 | 2 | 3 | 0 | 0 | 0 | 0 | 0 |
| activities | 1 | 5 | 9 | 0 | 2 | 6 | 0 | 0 | 0 | 0 | 0 |
| projects | 1 | 2 | 0 | 0 | 3 | 1 | 0 | 0 | 0 | 0 | 0 |
| cv | 1 | 0 | 0 | 0 | 2 | 1 | 0 | 0 | 0 | 0 | 0 |
| further-reading | 1 | 0 | 0 | 0 | 2 | 1 | 0 | 0 | 0 | 0 | 0 |

**`ol`, `blockquote`, `pre`, `code`, `table`, `h4`, `h5`, `h6` appear nowhere on the site.** `h5`/`h6` are already safelisted (Phase 2). `ol`, `blockquote` and `h4` are not.

Live proof that the mechanism is real and already biting: `_custom.scss` declares `.topic-list { … }`, and `grep -c topic-list` against the **served** `main.css` returns **0**. It was stripped. Meanwhile `pre,code{color:var(--ink-800)}` *did* survive, because PurgeCSS's default extractor matches bare tag selectors against any word token in the HTML — and the literal strings "pre" and "code" happen to appear in the page text. **That is luck, not a rule.** Do not rely on it for `h4`, `ol` or `blockquote`.

**Required change to `purgecss.config.js`, in the same commit as the rule that needs it:**

```js
    // Same class of problem as the ":focus-visible" entry above. The prose-measure
    // selector list in _sass/_custom.scss names ol, blockquote and h4; none of the
    // three appears in any built page today, so PurgeCSS drops those nodes from the
    // list and the rule ships incomplete. Safelisting them means the first page to
    // add an ordered list or a pull quote gets the measure without a config change.
    "ol",
    "blockquote",
    "h4",
```

And — the Phase 2 lesson, restated because it is the single most expensive mistake available in this phase — **every new selector this phase introduces must be grepped in the `--live` block against the served `main.css`, not only in `_sass/`.**

### Finding 8 — Two gem declarations this phase must beat, and one that is already in the way. **[HIGH — read off the deployed CSS]**

From the served `assets/css/tailwind.css` (entirely inside `@layer`, so any unlayered declaration in `main.css` wins regardless of specificity — the Phase 2 mechanism holds):

```css
@layer base {
  body { font-family: Roboto, sans-serif; font-size: 1rem; font-weight: 300; line-height: 1.5 }
  h1,h2,h3,h4,h5,h6 { color:inherit; margin-top:0; margin-bottom:.5rem;
                      font-family:inherit; font-weight:300; line-height:1.2 }
  h1{font-size:2.5rem} h2{font-size:2rem} h3{font-size:1.75rem}
}
```

Consequences the plan must handle explicitly:

1. **`font-weight: 300` is set on `body` AND on `h1`–`h6`.** Everything on the site is currently weight 300. With only 400 and 600 faces declared, CSS font matching resolves 300 → 400, so nothing renders as faux-light — but **`h1`/`h2` will render at 400, not the locked 600, unless this phase sets `font-weight` explicitly.** Set body to 400, `h1`/`h2` to 600, `h3` to 400. Do not assume the size change carries the weight.
2. **`h1`–`h6` take `font-family: inherit`**, so setting `body { font-family: var(--font-serif) }` automatically makes every heading Literata. One declaration delivers the "headings are serif throughout" decision — no per-heading font-family rule needed.
3. **`line-height: 1.2` is already on headings.** `--leading-heading: 1.2` matches what ships today, so the token makes an existing behaviour ownable rather than changing it. Declare it anyway (CONTEXT asks for it), but do not claim it as a visual change.
4. **`.nav-link` is styled in the gem's `main.css`, not Tailwind** (`font-weight:bolder; color:var(--global-theme-color)`). Pointing nav links at Be Vietnam Pro means a `.nav-link { font-family: var(--font-sans) }` rule in `_custom.scss`; `font-weight: bolder` against faces 400/600 resolves to 600, which is the BVP 600 cut — consistent.
5. **CSP is not a problem.** The page's `Content-Security-Policy` meta allows `style-src … https:` and `font-src 'self' data: https:`, so `fonts.googleapis.com` and `fonts.gstatic.com` are already permitted.

### Finding 9 — There is nothing to do for "code", and that is the honest answer. **[HIGH — measured]**

CONTEXT says *"`font-family: Iosevka Fixed, monospace` is in the served `main.css` — the gem's own Sass, also beatable from `_custom.scss`."* True, but the only rule carrying that name is:

```css
.typogram .diagram text, .typogram .glyph, .typogram .debug text { font-family: Iosevka Fixed, monospace; … }
```

No page on this site renders a typogram, and `pre`/`code` get no `font-family` from `main.css` at all. The three other `font-family:monospace` rules in the served CSS are `figure.cover figcaption.*`, also unused.

So **code already resolves to the browser's monospace default, and no CSS change is needed to deliver the locked decision.** An override targeting `.typogram …` would be purged anyway (no `.typogram` in any built page). The right move is: set the cap line to `2`, write one comment in `_tokens.scss` recording that code takes the bare generic and *why no rule exists*, and add a `verify.sh` row asserting the served CSS contains no `Iosevka` outside the gem's typogram rule. Do not manufacture a dead override to make the decision look implemented.

### Finding 10 — An undocumented TYPE-03 hazard: the navbar brand renders the name in two weights. **[HIGH — read off the deployed HTML and CSS]**

First, a correction to CONTEXT: **the navbar brand does not render on the home page.** It appears on the six inner pages only; on `/` the name is carried solely by `h1.post-title`. CONTEXT's "the name appears in two places" is true page-by-page, but the two places are never both visible at once.

Second, and more importantly, the inner-page brand is:

```html
<a class="navbar-brand title font-weight-lighter" href="/">
  <span class="font-weight-bold">Phạm</span> Hà Khánh Chi
</a>
```

`_custom.scss` already neutralises this **for `.post-title` only**:

```scss
.post-title .font-weight-bold { font-weight: inherit; }
```

In the navbar the fix does not apply. `.font-weight-lighter { font-weight: lighter }` resolves against the inherited weight, while `.font-weight-bold` forces 700 → matches the 600 face. **So on six of seven pages the family name "Phạm" renders in Literata 600 and the rest of the name in Literata 400** — the same one-name-two-appearances failure TYPE-03 exists to prevent, in weight rather than in typeface. It is invisible today only because Roboto's variable font makes the step small and the brand is 1.25rem.

**This phase must extend the existing override**, e.g.:

```scss
.post-title .font-weight-bold,
.navbar-brand .font-weight-bold {
  font-weight: inherit;
}
```

`font-weight-bold` is already in the PurgeCSS safelist and `.navbar-brand` is in the built HTML, so both nodes survive. Add a `--live` row grepping the served CSS for `.navbar-brand .font-weight-bold`.

### Finding 11 — CONTEXT contradicts itself on `.entry-status`, and 26 KB rides on the answer. **[HIGH — textual, needs a human decision]**

Within the same Decisions block:

- The companion-face paragraph lists `.entry-status` among the classes **Be Vietnam Pro** carries: *"carrying labels, years, metadata and status — `.entry-year`, `.entry-meta`, `.entry-status`, `.subject-grade`."*
- The cuts table assigns it to **Literata 400 italic**: *"Literata | 400 italic | `.entry-status`; Phase 4 marginalia."*
- The Existing-Code section repeats the second: *"`.entry-status` … is already italic, so the Literata italic cut has a consumer on day one."*

These cannot both hold. The stake is concrete: if `.entry-status` goes to Be Vietnam Pro, **the Literata italic cut has no consumer in this phase at all** (its only other stated use is Phase 4 marginalia, which does not exist yet), and dropping it saves **26,344 B** — taking the payload from 141,232 B to 114,888 B and the budget from 92% used to 75%.

**Recommendation:** keep `.entry-status` on **Literata italic**. It is an aside inside a research entry, not a label; italic serif is the right voice for it; and the cut is pre-paid for Phase 4 regardless. But this is a decision the planner should surface at a human checkpoint rather than resolve silently, because the alternative is a 26 KB saving and CONTEXT states both.

### Finding 12 — CONTEXT research flag 3, resolved: no preconnect, no preload, no lever. **[HIGH — verified negatively against config and served HTML]**

- `_config.yml` contains no `preconnect`, `preload` or `font-display` key. The only google-fonts key is `third_party_libraries.google_fonts.url.fonts` (line 542), a single string.
- The served `<head>` contains no `rel="preconnect"` or `rel="preload"` of any kind.
- The fonts link is emitted as `<link defer rel="stylesheet" type="text/css" href="…">`. **`defer` is not a valid attribute on `<link>`** and browsers ignore it — the stylesheet is render-blocking. This is gem behaviour and not reachable from here.
- The `&` in the URL is emitted HTML-escaped as `&amp;`, which browsers parse correctly. Multi-`family` css2 URLs are therefore safe to put in that string. (Still worth one `--live` grep of the deployed HTML for the exact URL after the first push — `;` and `@` in a YAML double-quoted string pass through fine, but this is the kind of thing worth proving rather than assuming.)

**Conclusion:** `display=swap` plus metric-close fallbacks is the entire loading strategy available to this phase. There is a serial connect cost (`fonts.googleapis.com` → then `fonts.gstatic.com`) that cannot be removed. Do not plan tasks around preconnect; do not flip `third_party_libraries.download` (it is global to all libraries, not per-library).

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Vietnamese subsetting | A hand-written `@font-face` with a typed-out `unicode-range` | Google's `css2` response verbatim, via the config URL | The ranges are 12 disjoint blocks plus combining marks; one typo silently drops one glyph in the name — the exact TYPE-03 failure. |
| Metric-matched fallback | Eyeballed stack, or a `size-adjust` `@font-face` | The measured table in Finding 5; Georgia first for serif | `size-adjust` introduces a named family that criterion 3's grep flags, and a second block to maintain. The measured stack costs nothing. |
| CPL verification | Counting characters on a screenshot | `xWidthAvg` arithmetic (Finding 5) + one DevTools JS check on the deployed page | Screenshot counting is unrepeatable and Phase 8 will need the number again. |
| Byte budget | A one-off DevTools reading | A `.planning/tools/fontbudget.js` mirroring `contrast.js` | A criterion whose evidence cannot be re-run is a criterion nobody can regress-check. `contrast.js` is the established precedent for exactly this. |
| CSS pruning safety | Trusting that a correct source rule ships | A `--live` grep of the served `main.css` for every new selector | Phase 2 shipped a correct `:focus-visible` that was absent from production for a full day. `.topic-list` is stripped from production *right now*. |

**Key insight:** in this repo the source of truth for CSS is never `_sass/` — it is `https://phamhakhanhchi.com/assets/css/main.css`. There is no local Jekyll build, PurgeCSS never runs locally, and the gap between the two has already cost this project once.

---

## Common Pitfalls

### Pitfall 1: Proving criterion 2 with a bare `curl`
**What goes wrong:** `curl https://fonts.googleapis.com/css2?…` returns TTF `@font-face` blocks with no `unicode-range` and no `/* vietnamese */` comment. The check appears to fail, and the obvious "fix" is to go hunting for a different family or endpoint.
**Why it happens:** Google Fonts content-negotiates on `User-Agent`. An unknown UA gets the maximum-compatibility TrueType response.
**How to avoid:** always pass `-A "<modern Chrome UA>"`. Bake the UA into `verify.sh` as a variable so no row can accidentally omit it.
**Warning sign:** the response body contains `format('truetype')`.

### Pitfall 2: Writing the measure with a descendant selector
**What goes wrong:** `.post article h2 { max-width: var(--measure) }` narrows every `.entry-group-title` on academics, research and activities — violating CONTEXT's explicit exclusion and visibly breaking the entry layout's alignment with its year gutter.
**Why it happens:** the entry pages nest their headings inside `article`.
**How to avoid:** child combinators, two levels (`> X` and `> .clearfix > X`). See Finding 6.
**Warning sign:** the entry-group headings and the entry rows no longer share a right edge.

### Pitfall 3: Assuming the source rule is the shipped rule
**What goes wrong:** the measure rule is correct in `_sass/_custom.scss`, `verify.sh` is green on every static row, and production ships it with `ol`, `blockquote` and `h4` quietly removed from the selector list.
**Why it happens:** PurgeCSS prunes unused nodes from selector lists, runs only in CI, and reports nothing.
**How to avoid:** safelist the three tags **in the same commit**, and add `--live` rows that grep the served CSS for each selector by name.
**Warning sign:** a selector present in `_sass/` and absent from `curl …/main.css`.

### Pitfall 4: Expecting the size change to carry the weight
**What goes wrong:** `h1`/`h2` are given `--step-5`/`--step-4` and still render at 400, because Tailwind's base layer sets `font-weight: 300` on `h1`–`h6` and 300 resolves to the 400 face.
**Why it happens:** nothing in the size tokens touches weight.
**How to avoid:** explicit `font-weight: 600` on `h1`,`h2`; explicit `400` on `h3` and on `body`.
**Warning sign:** the greyscale-blur hierarchy test shows size-only separation.

### Pitfall 5: Treating the Literata 600 cut as free
**What goes wrong:** the budget is planned as "400 and 600 share a file, so 600 costs nothing", and the real number comes in 22 KB over the estimate.
**Why it happens:** requesting a second weight upgrades Google's response from a 25,604 B static instance to a 47,980 B variable font.
**How to avoid:** use the measured table in Finding 3, not the shared-URL intuition.

### Pitfall 6: Re-pointing `--underline-offset` by feel
**What goes wrong:** `0.18em` was tuned and human-approved in Phase 2 against **Roboto's** descender depth, to clear `ạ` and `ợ`. Literata's descender is −308/1000 em versus Roboto's −500/2048 (−0.244) — **Literata's descenders sit ~26% deeper**. The Phase-2 offset is very likely now too small for underlined links containing Vietnamese below-baseline marks.
**Why it happens:** the token encodes a font-specific optical measurement, and the font is changing.
**How to avoid:** re-check on the deployed site at the human checkpoint, on a body-copy link containing `ạ` or `ợ`, and re-point the token if the underline touches the mark. **[MEDIUM — the metric ratio is measured; whether 0.18em actually collides is a browser observation, not a computation.]** CONTEXT flags this; it is real, and the metrics make it more likely than not.

### Pitfall 7: Measuring criterion 5 on the wrong page
**What goes wrong:** DevTools on `/` reports ~107 KB because no italic renders there, the budget looks comfortable, and the real worst case is never measured.
**How to avoid:** measure on `/research/` (body + h2 + h3 + italic `.entry-status` + sans `.entry-meta`), name the page in the commit, and note the per-page variance.

### Pitfall 8: `KB` ambiguity at a 6% margin
**What goes wrong:** 141,232 B is 137.9 KiB *and* 141.2 kB. At a 150 "KB" budget the two readings differ by 3.3 units out of a 12-unit margin.
**How to avoid:** state the budget in bytes (recommend 153,600) and record the measurement in bytes.

---

## Code Examples

### The `_config.yml` fonts URL (the single string to change)

```yaml
# _config.yml, third_party_libraries.google_fonts.url.fonts  (currently line 542)
  google_fonts:
    url:
      fonts: "https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;600&family=Literata:ital,wght@0,400;0,600;1,400&display=swap"
```

Verified live: HTTP 200, 936 B gzipped, 5 × `/* vietnamese */`, 8 unique `woff2` over latin+vietnamese totalling 141,232 B. Material Icons and both Roboto families are dropped by this one edit.

### `_sass/_tokens.scss` — the new/re-pointed block

```scss
  /* Type families — THE CAP IS 2 (see the header). Code takes the bare
     `monospace` generic, which is a CSS keyword, not a chosen family: no rule
     declares it because nothing on this site needs one (the gem's only
     `Iosevka Fixed` rule targets .typogram, which no page renders).
     Fallbacks are metric-measured, not guessed — Georgia is -5% on x-height
     against Literata where Times New Roman is -12%. */
  --font-serif: Literata, Georgia, "Times New Roman", serif;
  --font-sans: "Be Vietnam Pro", -apple-system, "Segoe UI", Roboto, Arial, sans-serif;

  /* Scale. Written as calc() against --step-1 so the RATIOS TYPE-04 measures
     are auditable in the served CSS, not recoverable only by division. */
  --step-1: 1.0625rem;                      /* body, 17px on a 16px root */
  --step-0: calc(var(--step-1) * 0.85);     /* meta, status                  */
  --step-2: calc(var(--step-1) * 1.15);     /* .entry-title, h4              */
  --step-3: calc(var(--step-1) * 1.35);     /* h3  — TYPE-04 floor is 1.25   */
  --step-4: calc(var(--step-1) * 1.8);      /* h2  — TYPE-04 floor is 1.5    */
  --step-5: calc(var(--step-1) * 2.6);      /* h1, .post-title               */

  --leading-body: 1.6;                      /* was 1.5 (gem, tuned for Roboto/16px) */
  --leading-heading: 1.2;                   /* matches what tailwind base already ships */

  /* 36rem = 576px. Literata's xWidthAvg is 0.480em, so at 17px that is
     576 / (0.480 * 17) = ~70.6 characters — inside TYPE-04's 45-75 window,
     and real ragged-right lines land shorter still. The 930px page minus this
     column leaves ~354px: Phase 4's marginalia gutter. */
  --measure: 36rem;
```

### `_sass/_custom.scss` — the consumer rule for the body/family override

```scss
// 7. THE SITE IS SET IN LITERATA. Gem prebuilt tailwind.css @layer base sets
//    `body { font-family: Roboto, sans-serif; font-weight: 300 }`. main.css is
//    unlayered and loads last, so a normal declaration wins — the same
//    mechanism as overrides 1-6 above. h1..h6 take `font-family: inherit` from
//    that same base layer, so this one declaration also makes every heading
//    serif, which is the TYPE-02 division. The explicit font-weight is NOT
//    redundant: the gem sets 300 and, with only 400/600 faces loaded, 300
//    would silently resolve to 400 everywhere including h1 and h2.
body {
  font-family: var(--font-serif);
  font-size: var(--step-1);
  font-weight: 400;
  line-height: var(--leading-body);
}
```

### `purgecss.config.js` — the required safelist additions

```js
    // Same class of problem as the ":focus-visible" entry above. The prose
    // measure names ol, blockquote and h4; none appears in any built page, so
    // PurgeCSS drops those nodes and the rule ships incomplete. h5/h6 are
    // already listed for the heading-ink rule.
    "ol",
    "blockquote",
    "h4",
```

### Criterion 2's proof, as `verify.sh` rows

```bash
FONTS_UA='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
FONTS_URL="$(grep -o 'https://fonts.googleapis.com/css2[^"]*' _config.yml | head -1)"

check "Live      fonts CSS carries 5 /* vietnamese */ blocks (one per cut)" \
  '[ "$(curl -sS -A "$FONTS_UA" "$FONTS_URL" | grep -c "/\* vietnamese \*/")" = "5" ]'
check "Live      fonts CSS serves woff2, not the UA-less truetype fallback" \
  'curl -sS -A "$FONTS_UA" "$FONTS_URL" | grep -q "format(.woff2.)"'
check "Live      vietnamese range covers U+1EA1 (the a-dot-below in Phạm)" \
  'curl -sS -A "$FONTS_UA" "$FONTS_URL" | grep -q "U+1EA0-1EF9"'
```

### Criterion 4's CPL check, in the browser (one of the two genuinely manual rows)

```js
// Paste in DevTools on https://phamhakhanhchi.com/ — returns chars-per-line
// for the first body paragraph, measured rather than estimated.
(() => {
  const p = document.querySelector('.post article p');
  const r = document.createRange(); r.selectNodeContents(p);
  const lines = r.getClientRects().length;
  return { chars: p.textContent.trim().length, lines,
           cpl: Math.round(p.textContent.trim().length / lines) };
})();
// expect cpl between 45 and 75; the arithmetic in Finding 5 predicts ~66-71
```

---

## State of the Art

| Old approach | Current approach | Impact here |
|--------------|------------------|--------|
| `css?family=Fam:400,700` (v1) | `css2?family=Fam:ital,wght@0,400;0,700;1,400` | v1 still works and still serves vietnamese (Finding 1), but only v2 expresses ital×wght tuples. Use v2. |
| Multiple static weight files | Google auto-serves a **variable** file when >1 weight of a variable family is requested | Literata 400+600 = one file. Be Vietnam Pro has no variable version, so its two cuts are two files. |
| `@font-face` `unicode-range` typed by hand | Google's per-subset blocks | Never hand-write the Vietnamese range. |
| `font-display: auto` (FOIT) | `display=swap` | Locked in CONTEXT; correct for the audience. |

**Deprecated/outdated in this repo's own documentation:**
- CONTEXT.md research flag 1 ("v1 cannot satisfy criterion 2") — **false**, see Finding 1.
- CONTEXT.md "the navbar brand renders the full name as well as `.post-title` does" — true on the six inner pages, **false on the home page**, where no brand renders.
- CONTEXT.md's measure clause — internally inconsistent under a descendant selector; see Finding 6.
- CONTEXT.md on `Iosevka Fixed` as a code font — the name exists only on `.typogram` rules, not on `pre`/`code`; see Finding 9.

---

## Open Questions

1. **`.entry-status`: Literata italic or Be Vietnam Pro?**
   - What we know: CONTEXT states both, in the same Decisions block (Finding 11). 26,344 B rides on it.
   - What's unclear: which clause is the later thought.
   - Recommendation: Literata italic (it is an aside, not a label; the cut is pre-paid for Phase 4). Surface at a human checkpoint rather than resolving silently.

2. **Should `h1.post-title` share the prose measure?**
   - What we know: it lives in `header.post-header`, a **sibling** of `article`, so the recommended selector does not reach it. CONTEXT's stated intent ("headings and paragraphs share a right edge") suggests it should; its stated scope ("inside `.post article`") says it cannot.
   - Recommendation: leave the page title full-width this phase, and raise it at the checkpoint. Phase 6 owns the hero composition.

3. **Does `--underline-offset: 0.18em` still clear Literata's descenders?**
   - What we know: Literata's descender is 26% deeper than Roboto's, relative to em. The token was tuned for Roboto.
   - Recommendation: re-check visually on a deployed body-copy link containing `ạ`/`ợ`; re-point the token in `_tokens.scss` if it collides. Do not re-tune blind.

4. **Does `calc()` in a custom property survive Dart Sass's compressed output byte-for-byte?**
   - What we know: Sass treats custom-property values as unparsed strings (HIGH confidence). Whether compressed mode strips the spaces around `*` is not verifiable without a local Ruby/Jekyll build, which does not exist on this machine.
   - Recommendation: write every `verify.sh` grep whitespace-tolerantly, exactly as Phase 2's harness does. Then either output form passes.

5. **Do the fallback fonts render `ạ` during the swap window?** **[MEDIUM]**
   - What we know: Georgia, Times New Roman, Arial and Segoe UI all ship Vietnamese coverage on current Windows and macOS, but this was not independently verified.
   - Recommendation: one glance during the human check with the network throttled, or DevTools' "Rendering → disable webfonts".

---

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | **None, and none may be added.** Phase 1 set the convention; 01-VALIDATION and 02-VALIDATION both forbid a starter-local build/test pipeline, and `AGENTS.md`'s stop sign bans `build:css`/`build:tailwind` npm scripts. Validation is a flat `check <label> <expr>` shell harness. |
| Config file | none — Wave 1 of this phase creates `.planning/phases/03-typography/verify.sh` (and, recommended, `.planning/tools/fontbudget.js`) |
| Quick run command | `bash .planning/phases/03-typography/verify.sh` |
| Full suite command | `bash .planning/phases/03-typography/verify.sh --live` |
| Estimated runtime | static ~5–10 s (Prettier is the slow row); `--live` ~30–60 s (8 font downloads + 7 page fetches) |
| Supporting tools | `node .planning/tools/contrast.js` (existing, unchanged); `node .planning/tools/fontbudget.js` (new, proposed) |

**Environment constraints that shape everything.** No Ruby, no `bundle`, no `gem`, no `_site/`, no local Jekyll build. PurgeCSS never runs locally. The Playwright suite must **not** be run (deleted workflow, `/al-folio` baseurl, no baseline). The deployed site is the only real check, and `main.css` is served with `Cache-Control: max-age=600` behind a CDN — **every live fetch needs a `?cb=$(date +%s)` buster**, and deploy latency is ~2–3 minutes.

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| TYPE-01 | Literata serves a vietnamese subset | live/network | assert a `/* vietnamese */` block naming `'Literata'` in the css2 response | ❌ Wave 0 |
| TYPE-01/02 | 5 vietnamese blocks total, one per cut | live/network | `[ "$(curl -sS -A "$FONTS_UA" "$FONTS_URL" \| grep -c '/\* vietnamese \*/')" = 5 ]` | ❌ Wave 0 |
| TYPE-01 | `U+1EA1` is in range | live/network | `curl … \| grep -q 'U+1EA0-1EF9'` | ❌ Wave 0 |
| TYPE-02 | Serif on body; sans on the label classes | live/CSS grep | `grep -qE 'body\{[^}]*font-family:[[:space:]]*var\(--font-serif\)' $LIVE_CSS`, plus one row each for `.entry-year`/`.entry-meta`/`.entry-status`/`.subject-grade`/`.nav-link` → `var(--font-sans)` | ❌ Wave 0 |
| TYPE-02 | Exactly two families declared | static | `[ "$(grep -cE '^[[:space:]]*--font-(serif\|sans):' _sass/_tokens.scss)" = 2 ]` and no bare `font-family:` literal in `_sass/_custom.scss` | ❌ Wave 0 |
| TYPE-02 | The cap line reads `2` | static | `grep -qE 'type families[. ]+2' _sass/_tokens.scss` | ❌ Wave 0 |
| TYPE-03 | Name not split across weights in the navbar | live/CSS grep | `grep -q '\.navbar-brand \.font-weight-bold' $LIVE_CSS` | ❌ Wave 0 |
| TYPE-03 | Name renders identically at ≥48px | **manual** | DevTools zoom on deployed `h1.post-title`; compare `ạ` against `à`. Requires human visual judgement. | manual |
| TYPE-04 | h2 ≥ 1.5× body | live/CSS grep | `grep -qE -- '--step-4:[[:space:]]*calc\(var\(--step-1\)[[:space:]]*\*[[:space:]]*1\.8\)' $LIVE_CSS` | ❌ Wave 0 |
| TYPE-04 | h3 ≥ 1.25× body | live/CSS grep | same shape, `1\.35` | ❌ Wave 0 |
| TYPE-04 | h1/h2 at 600, h3 at 400 | live/CSS grep | `grep -qE 'h1,h2\{[^}]*font-weight:[[:space:]]*600' $LIVE_CSS` | ❌ Wave 0 |
| TYPE-04 | Measure rule survives PurgeCSS **whole** | live/CSS grep | one row per fragile node: `.post article>ol`, `.post article>blockquote`, `.post article>h4`, `.post article>.clearfix>p` | ❌ Wave 0 |
| TYPE-04 | 45 ≤ CPL ≤ 75 | **manual** | DevTools `getClientRects()` snippet (Code Examples). The arithmetic pre-check is automatable; the rendered count is not. | manual |
| TYPE-05 | Payload ≤ 153,600 B | live/network | `node .planning/tools/fontbudget.js "$FONTS_URL" --max 153600` — re-downloads every latin+vietnamese `woff2` and sums | ❌ Wave 0 |
| TYPE-05 | Icon payload recorded (not budgeted) | live/network | same tool, `--report-only`, against the FA/academicons/scholar URLs | ❌ Wave 0 |
| TYPE-05 | Material Icons / Roboto gone from served HTML | live/HTML grep | `! grep -q 'Material+Icons' $LIVE_HTML` and `! grep -q 'Roboto' $LIVE_HTML` | ❌ Wave 0 |
| TYPE-05 | academicons + scholar-icons gone | live/HTML grep | `! grep -qE 'academicons\|scholar-icons' $LIVE_HTML` | ❌ Wave 0 |
| (regression) | No literal outside `_tokens.scss` | static | existing Phase 2 grep, extended to `font-family` | ❌ Wave 0 |
| (regression) | No `!important` in `_sass/` | static | `! grep -rq '!important' _sass/` | ❌ Wave 0 |
| (regression) | Prettier + style contract | static | `npx prettier _sass _config.yml purgecss.config.js --check --end-of-line auto`; `node test/style_contract.js` | ✅ exists |

### Sampling Rate

- **Per task commit:** `bash .planning/phases/03-typography/verify.sh` (static only, ~5–10 s)
- **Per wave merge:** same, plus `npx prettier … --check` and `node test/style_contract.js`
- **After the phase's push:** `verify.sh --live` — and poll, do not refresh once; deploy latency ~2–3 min plus a 600 s CDN TTL, hence the cache buster
- **Phase gate:** `--live` fully green, zero `[red until …]` labels remaining, before `/gsd:verify-work`

Follow Phase 2's **red-by-design** convention: write the harness before the work, label rows that cannot be true yet `[red until plan 03-NN]`, count them in `EXPECTED_RED`, and strip every label once green. Never delete a row to clean the tally.

### Wave 0 Gaps

- [ ] `.planning/phases/03-typography/verify.sh` — the whole harness; covers TYPE-01…TYPE-05
- [ ] `.planning/tools/fontbudget.js` — zero-dependency Node byte counter; covers TYPE-05 reproducibly (mirrors `contrast.js`)
- [ ] `purgecss.config.js` safelist entries `"ol"`, `"blockquote"`, `"h4"` — must land **with** the measure rule, not after
- [ ] No framework install, no npm script, no `package.json` change — carried forward from 01/02-VALIDATION

---

## Sources

### Primary (HIGH confidence — measured on 2026-09-16)
- `https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;600&family=Literata:ital,wght@0,400;0,600;1,400&display=swap` — subset blocks, unicode-ranges, woff2 URLs, 936 B gzipped response
- `https://fonts.googleapis.com/css?family=…` (v1) — the disproof of CONTEXT research flag 1; UA-dependent TTF behaviour
- `fonts.gstatic.com` — all 8 woff2 files downloaded and byte-counted; Literata `v40`, Be Vietnam Pro `v12`
- `https://phamhakhanhchi.com/` and all six inner pages — DOM structure, tag census, navbar brand markup, CSP meta, `<head>` link list
- `https://phamhakhanhchi.com/assets/css/main.css` and `/assets/css/tailwind.css` — the served, purged, minified CSS; `@layer` inventory; `font-weight:300`; PurgeCSS survival evidence (`.topic-list` absent)
- `@capsizecss/metrics@3.5.0` via jsDelivr — `unitsPerEm`/`xHeight`/`capHeight`/`xWidthAvg` for Literata, Be Vietnam Pro, Georgia, Times New Roman, Arial, Segoe UI, Roboto, Helvetica Neue
- This repo: `_sass/_tokens.scss`, `_sass/_custom.scss`, `assets/css/main.scss`, `purgecss.config.js`, `_config.yml`, `_data/socials.yml`, `.al-folio-overrides.yml`, `.planning/phases/02-*/verify.sh`, `.planning/phases/02-*/02-VALIDATION.md`

### Secondary (MEDIUM confidence)
- Dart Sass custom-property handling (values parsed as unquoted strings) — from documentation knowledge, not re-verified against a local build; mitigated by whitespace-tolerant greps
- Vietnamese coverage of the named fallback fonts on current Windows/macOS — widely true, not independently verified here

### Not verified / could not be checked
- Any local Jekyll or Sass build — no Ruby toolchain on this machine
- Rendered appearance of anything — no browser available to this agent; all visual criteria are routed to human checkpoints

---

## Metadata

**Confidence breakdown:**
- Standard stack (font delivery, subsets, byte budget): **HIGH** — every number downloaded and counted, not cited
- Architecture (font metrics, CPL arithmetic, DOM structure, PurgeCSS behaviour, gem CSS integration points): **HIGH** — read off all seven deployed pages and the served stylesheets
- Pitfalls: **HIGH** for 1–5, 7–8 (each traced to a measurement or a prior incident in this repo); **MEDIUM** for 6 (the descender ratio is measured, the collision is a browser observation)
- Sass `calc()` compressed-output byte fidelity: **MEDIUM** — documented behaviour, unverifiable locally; mitigated

**Research date:** 2026-09-16
**Valid until:** ~2026-10-16. The byte figures are pinned to Literata `v40` / Be Vietnam Pro `v12`; Google can reissue a family and change them. Re-run `fontbudget.js` before trusting the budget in a later phase.

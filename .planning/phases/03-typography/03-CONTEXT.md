# Phase 3: Typography - Context

**Gathered:** 2026-09-16
**Status:** Ready for planning

<domain>
## Phase Boundary

The site's voice comes from its type: a body serif with verified Vietnamese coverage, a companion face for labels and metadata, a heading hierarchy that survives a five-second scan, and a measure chosen rather than inherited. Delivers TYPE-01 through TYPE-05.

Texture, marginalia and hand-drawn marks are Phase 4. Entry-component styling is Phase 5. The home-page portrait and hero composition are Phase 6. This phase sets type and the measure only — but it deliberately leaves the marginalia gutter open (see Measure below).

</domain>

<decisions>
## Implementation Decisions

### Typeface pairing

- **Body serif: Literata.** Chosen over Source Serif 4, EB Garamond and Newsreader. Designed for long screen reading, warm without novelty, and its Vietnamese diacritics are properly drawn rather than auto-composed.
- **Companion: Be Vietnam Pro** (sans), carrying labels, years, metadata and status — `.entry-year`, `.entry-meta`, `.entry-status`, `.subject-grade`. Chosen over IBM Plex Sans, Inter and Source Sans 3 specifically because it was drawn by a Vietnamese foundry with stacked diacritics as a design premise, which is the one face on the shortlist where TYPE-01 and TYPE-03 are guaranteed by design intent rather than by subset availability.
- **A sans, not a mono.** Deciding input: the site has **zero code blocks and four inline backticks** total across `_pages/`, `_projects/` and `_data/`. The companion is therefore optimised for labels, which is what actually appears. A mono companion was rejected — it would pull toward the "dark deep-focus terminal" direction PROJECT.md explicitly considered and rejected.
- **Code takes the bare `monospace` generic.** Drop the `Iosevka Fixed` family name from the stack: it is never loaded (zero `@font-face` in the served `main.css`, absent from the fonts URL), so code already falls back to system mono today. This is a cleanup of a dead name, not a behaviour change.
- **The cap at `_sass/_tokens.scss:23` is set to `2`.** A CSS generic is not a chosen type family, so the cap reads honestly. Raising it to 3 for a real webfont mono was considered and rejected — real bytes and a visible cap edit, for four backticks.

### Webfont budget and delivery

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

### Heading hierarchy and the name

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

### Measure and reading density

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

</decisions>

<specifics>
## Specific Ideas

- "A calm, well-set academic site on warm paper... reads as editorial rather than as a notebook" — the roadmap's own description of this phase's stopping state. The type should be finished enough to ship alone if Phase 4 is cut.
- The name is the thing to be remembered. It gets the largest step on the site and one typeface in both places it appears.
- Preserve Phase 2's discipline exactly: no colour or length literal outside `_sass/_tokens.scss`, and no `!important` anywhere.

</specifics>

<code_context>
## Existing Code Insights

### Reusable assets

- **`_sass/_tokens.scss:86-96`** — `--step-0`…`--step-3`, `--leading-body`, `--space-1`…`--space-4` already exist, with an in-file comment stating the names are locked and **"Phase 3 re-tunes them here without rewriting a single rule."** Consumers are already wired. Re-point values here; add `--step-4`, `--step-5`, `--measure` and a heading-leading token in the same block.
- **`_sass/_tokens.scss:23`** — the cap reads `type families ...... 2  (value set in Phase 3)`. The blank is this phase's to fill; set it to `2`.
- **`_sass/_custom.scss`** — the consumer surface. `.entry-title` already reads `--step-2`; `.entry-status` already reads `--step-0` and is already italic, so the Literata italic cut has a consumer on day one.
- **`_config.yml:540-542`** — `third_party_libraries.google_fonts.url.fonts` is the single string controlling the whole fonts request.
- **`.planning/phases/02-*/verify.sh`** and `.planning/tools/contrast.js` — the established verification pattern. This phase should carry its own `verify.sh` with `--live` rows, following Phase 2's precedent.

### Established patterns

- **Unlayered beats layered.** The gem's prebuilt `tailwind.css` is entirely inside `@layer`; `main.css` (which `_custom.scss` compiles into) is unlayered and loads last, so a normal declaration wins regardless of specificity. `_custom.scss` documents this and relies on it for all six gem overrides. **The body font-family override depends on the same mechanism** — see below.
- **Every override is annotated with its gem source**, so a later reader can tell a correction from a design choice. Continue this.
- **Zero literals outside `_tokens.scss`.** `_custom.scss` declares none; the phase harness greps for violations.
- The `.post > header.post-header + article` structure is what both layouts (`page.liquid`, `about.liquid`) produce — Phase 2 scoped the body-copy underline to `.post article a` on exactly this basis. The measure selector should use the same anchor.

### Integration points

- **`font-family: Roboto, sans-serif` is set in the gem's prebuilt `tailwind.css`**, inside `@layer` — this is what currently paints body copy, and what the Literata declaration must beat from unlayered `_sass/`. Phase 2's reasoning says it will; confirm it.
- **`font-family: Iosevka Fixed, monospace` is in the served `main.css`** — the gem's own Sass, also beatable from `_custom.scss`.
- **The `<head>` is gem-owned.** Only the URL string in `_config.yml` is controllable, which constrains preconnect/preload. The existing tag is `<link defer rel="stylesheet" ... >`.
- **`purgecss.config.js` is load-bearing and has burned this project once.** Phase 2 shipped a `:focus-visible` rule that was correct in source and stripped from every production build, unnoticed, because the harness only checked source. Any new selector this phase introduces — the prose-measure selector list especially — must be grepped **in the served CSS**, not just in `_sass/`.
- **`.al-folio-overrides.yml`** carries a hand-recorded `local_sha256` for `assets/css/main.scss`; re-record by hand if that file changes.

### Research flags (not user decisions)

1. **The v1 Fonts API cannot satisfy criterion 2.** The current URL is `https://fonts.googleapis.com/css?family=...` (v1). The `/* vietnamese */` unicode-range block that criterion 2 requires by `curl` is emitted by the **v2** `css2?family=...` endpoint. The rewrite to v2 is a necessity, not a preference.
2. **`--underline-offset: 0.18em` must be re-checked.** It was tuned and human-approved in Phase 2 to clear `ạ`/`ợ` **in Roboto**. Literata's descender depth differs; re-measure and re-point the token if needed.
3. **Confirm preconnect/preload reachability** given the gem-owned `<head>` before assuming any loading optimisation beyond `display=swap`.
4. **Verify Vietnamese coverage by `curl` for both families before writing any CSS** — this is an early-exit check. The roadmap notes it could have run during Phase 1 or 2; it did not, so it runs first here. If Be Vietnam Pro or Literata fails, the pairing changes and everything downstream moves.

</code_context>

<deferred>
## Deferred Ideas

- **Replacing the Font Awesome envelope with an inline SVG** and dropping the last icon CDN entirely. Raised during the payload discussion and deliberately not taken: it touches the home page's social block, which is Phase 6's territory.
- **Rewriting the `.entry` layout to use the new type scale properly** — Phase 5 (PAGE-01) owns the entry vocabulary. This phase re-points tokens; it does not restructure components.
- **`prefers-reduced-motion`** — Phase 7, and only if a transition ships in Phase 4.
- **Reconsidering `title: blank` in `_config.yml`** so the navbar brand and the hero title could diverge. Not needed for this phase's decisions, which put both in Literata.

</deferred>

---

*Phase: 03-typography*
*Context gathered: 2026-09-16*

# Phase 4: Notebook Art Style - Research

**Researched:** 2026-09-18
**Domain:** CSS procedural texture (SVG `feTurbulence` data-URI), decorative-mark vocabulary, marginalia markup and layout, WCAG contrast over a composited ground
**Confidence:** HIGH on the mechanics and the measurements; MEDIUM on perceived texture visibility (needs a human/device check by construction)

<user_constraints>

## User Constraints (from 04-CONTEXT.md)

### Locked Decisions

**Texture**

- **Visibility: barely perceptible.** Noticed only when looked for, or against a flat swatch. Criterion 1 still requires it be _visible_ at normal reading distance on desktop and on a 390px phone — so this is the floor, not invisibility. The register argument (PITFALLS Pitfall 3) beat the "more notebook from the ground" argument: texture is connective tissue, not a feature.
- **Grain character: fine, even tooth.** Uniform fine noise, like good uncoated writing paper. NOT coarse fibrous/handmade grain — that sits closer to the skeuomorphic edge and is harsher behind 17px Literata. Aged-paper colour grading is on the blocklist and does not ship in any form.
- **Reach: everything paper-coloured, one continuous sheet.** Body, navbar, footer, cards and code blocks all carry it. This is a deliberate rejection of "body only" — PITFALLS states plainly that a flat navbar above a textured page reads as a rendering bug. The hook already exists: Phase 2's `_sass/_custom.scss:264` already un-fades the gem's `.navbar { opacity: .95 }`.
- **Mobile: identical everywhere.** Same tile, same visibility, desktop and phone. No breakpoint, no media query, no reduced variant. The tiled approach is cheap enough (~25–75× less filter work than full-viewport) that there is no performance reason to vary it, and criterion 1 requires phone visibility anyway.
- Technique is not a user decision and is already settled by research: a ~480-byte url-encoded inline SVG `feTurbulence` in a 200×200 data-URI, `background-repeat`, `stitchTiles="stitch"`, `numOctaves` 1–3. Zero network requests, under the 2 KB budget by two orders of magnitude. **`background-attachment: fixed` is ruled out** (per-frame repaint, iOS Safari stutter).

**Mark rendering**

- **Geometric throughout.** Crisp hairline CSS rules and brackets built from the existing `--rule-200` / `--rule-500` tokens. The "notebook" reads from _where_ marks sit — margin, beside a heading — and from restraint, not from imitated handwriting.
- **The hand-drawn signature move was considered and rejected.** PITFALLS recommends "one signature move, repeated with discipline" and names the hand-drawn link underline as the candidate; the user chose geometric anyway. Do not reintroduce a drawn/irregular mark during planning or execution — this is a decided question, not an open one.
- No rotation or skew on anything containing text (register marker #4, and it is grep-checkable).

**The vocabulary**

Four marks. **The cap reads 4** — written down as a stated number in the vocabulary file, mirroring the TOKEN-06 mechanism already working at `_sass/_tokens.scss:23`. Adding a fifth mark means visibly editing that number, not quietly appending a line.

1. **Section rule** — a hairline at section headings (`.entry-group-title`, `h2`). Defence: _it shows the reader where one group of work ends and the next begins._ Structural, so it takes `--rule-500` (3.08:1), not the decorative `--rule-200` (1.43:1).
2. **Margin note** — a subordinate note in the ~354px right gutter Phase 3 deliberately created (`--measure: 36rem` against `max_width: 930px`). Defence: _it carries the open question or caveat behind the item it sits next to._
3. **Annotation bracket / tick** — a small pointer tying a note to the item it annotates. Defence: _it shows which item the note belongs to._ Meaningless on its own, which is what GROUND-05 wants; implement as a pseudo-element so it vanishes cleanly with the stylesheet off.
4. **Link underline** — already shipped in Phase 2 (`.post article a`, `--underline-thickness`, `--underline-offset`). Listed here so it is part of the named vocabulary rather than a leftover. No change to its values is in scope.

- **The cliché blocklist lives in the vocabulary file, beside the allowed list.** One document: what is allowed with each defence sentence, what is banned. Source list is PITFALLS "The notebook-cliché blocklist" — coffee/tea rings, torn or burnt edges and curled corners, tape/paperclips/pushpins/staples/sticky-notes, spiral binding and hole-punch margins, full-page blue-ruled lines behind body text, highlighter swipes as texture, crosshatch shading and doodled stars/hearts/sparkles, handwritten-signature graphics, faux-3D page curl and stacked-sheet shadows, aged-paper yellowing gradients. Criterion 5 is this list.

**Marginalia content**

- **The user authors 1–2 real notes in their own words.** This phase cannot close on placeholder prose. There is no `note:` field in any `_data/*.yml` today — margin-note content does not exist anywhere in the repo.
- **This requires a named checkpoint in the plan** that comes back to the user with a _specific_ ask: which research entries to annotate, and what kind of note each one wants. Do not ask "write me some notes" — name the items.
- **Permitted note kinds, all four acceptable:** the open question (what is still not understood — PITFALLS's own worked example), the method caveat (a limit or condition on a result), the surprising result (what was not expected), why it mattered to the author (the connection that made them pick it up).
- **Proven on the Research page only** in this phase. One page, one or two notes, fully proven. Phase 5 rolls the treatment to Academics, Activities and Further Reading; Phase 6 owns the home page, so Phase 4 stays off About to avoid two phases editing the same composition.
- **Stylesheet-off behaviour: the note reads inline, in reading order.** Real markup that, unstyled, appears as an ordinary sentence immediately after the item it annotates — nothing orphaned, nothing lost, nothing out of order. CSS moves it to the gutter. This satisfies criterion 3 and GROUND-05 by construction rather than by inspection.

**Register budget and distribution**

- **Only marks serving no content count against criterion 4's ≤2-per-first-viewport cap.** The section rule, the margin note and the annotation bracket each serve content, so none of them counts. The cap therefore binds anything added _later_ with no job — which is the failure it exists to prevent. The count is taken on a screenshot, as the criterion says, not eyeballed.
- **Distribution: the section rule goes everywhere there are sections; margin notes only on Research.** The rule is structural furniture and repeating it is what makes the site feel like one system ("repetition reads as a system; variety reads as indecision"). Notes stay rare so they stay special.
- **Register-overshoot tests the user explicitly wants run:** (a) greyscale + 8px blur on each page — headings must remain the strongest shapes, no ornament may survive the blur more strongly than an H1; (b) the stylesheet-off test — disable `main.css`, reload, confirm content complete, correctly ordered, no orphaned symbol.
- **Two further proofs are phase obligations, not options** — they are named directly in the roadmap's success criteria and were flagged to the user as such: the **written one-sentence defence per vocabulary entry** (criterion 2) and the **screenshot mark count across all seven pages** (criterion 4). The user did not select these among the tests to emphasise; they were kept because cutting them would mean amending the roadmap, which was offered and not taken.
- **Fallback if the marks read as over-decorated: drop the marks, keep ground and type.** This is the roadmap's own Phase 3 "if work stops here" state — a finished typographic paper site — and it is named now so it is a decision rather than a panic. Removing a mark is deleting one block from one file. Dialling marks quieter was considered and rejected: a quiet bad mark is still a bad mark.

**Standing tiebreaker:** the user chose the conservative option in all sixteen questions. When a judgement call arises during planning or execution and the evidence is balanced, **take the quieter option**.

### Claude's Discretion

- Exact `feTurbulence` parameters (baseFrequency, numOctaves, alpha) and the tile's measured byte size — pick values that read correctly against Literata on `#faf6ee`, and record the numbers in the token file.
- Whether the section rule sits under or beside its heading; the bracket's exact glyph/geometry and size.
- Where the vocabulary file physically lives (`docs/`, `_sass/`, or `.planning/`) and whether the mark cap sits there or alongside the other caps at `_sass/_tokens.scss:23`.
- Whether the note is authored as a `note:` key in `_data/research.yml` or as inline markup in `_pages/research.md`.
- Whether marginalia sits left or right of the column, and what happens when two consecutive entries both carry notes.
- How many deploys the phase spends and how the work is split across plans.

### Deferred Ideas (OUT OF SCOPE)

- **Rolling the marginalia treatment to Academics, Activities and Further Reading** — Phase 5 (PAGE-06), which also owns its mobile collapse below ~768px.
- **Marks on the home page / About** — Phase 6 owns that composition; Phase 4 deliberately stays off it.
- **`@media print` handling of the texture and marginalia** — Phase 7.
- **`prefers-reduced-motion`** — Phase 7, and only if this phase ships any transition (it is not planned to).
- **Re-measuring contrast on the composited textured ground** — Phase 8 criterion 1, unless this phase's plan chooses to pull it forward. **See Pitfall 1 below: this research found a measured failure that argues for pulling one token forward.**
- **The `--underline-offset: 0.18em` provenance finding** — Phase 8 unless this phase widens link scope (it is not planned to).
- **Phase 3's unrecorded readings** — check B's characters-per-line number and check C's clears/collides verdict. Phase 8.

</user_constraints>

<phase_requirements>

## Phase Requirements

| ID            | Description (from REQUIREMENTS.md)                                                                     | Research Support                                                                                                                                                                                                                                       |
| ------------- | ------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **GROUND-02** | Texture is achieved by a technique that is cheap to render on mobile.                                  | Pattern 1 (the token + consumers) with a **verified 414-byte** url-encoded `feTurbulence` data URI, compiled through Dart Sass and Prettier in this session. Consumer map derived from the **served** CSS: body, navbar, `.card`. Pitfalls 2, 3, 4, 5, 6. |
| **GROUND-03** | A small, named vocabulary of notebook marks exists — rules, marginalia, annotation — each with a written one-sentence justification. | Pattern 2 (vocabulary file placement + cap mechanism, TOKEN-06 precedent), Pattern 3 (the section rule and its real page coverage — three pages, not seven), Pattern 4 (marginalia markup + layout arithmetic). Pitfall 1 (the rule colour fails on texture). |
| **GROUND-05** | Decorative marks carry no meaning that is unavailable to a reader who cannot see them.                 | Pattern 5 (border-built bracket with `content: ""`, never a glyph — screen readers announce generated text content), Pattern 4's markup order (note is a real sibling that reads inline unstyled). Automatable as greps; see Validation Architecture.     |

</phase_requirements>

## Summary

This phase has no new dependency and no new toolchain. Everything it needs already exists in the repo: `_sass/_tokens.scss` (the single literal surface), `_sass/_custom.scss` (the literal-free consumer), `.planning/tools/contrast.js`, the phase `verify.sh` harness pattern with its `[red until plan 0N-NN]` mechanism, and `purgecss.config.js`. The only genuinely new artefact is a written vocabulary document and one Liquid/YAML change on the Research page. The technical risk is concentrated in four places, and three of them were measured rather than assumed during this research.

**The texture technique is settled and verified end to end.** A 200×200 inline-SVG `feTurbulence` data URI in a custom property is **414 bytes**, compiles verbatim through Dart Sass 1.83 in `--style=compressed` (the `//` inside `http://www.w3.org/2000/svg` survives because it sits inside a quoted CSS string), and passes `prettier --check` at `printWidth: 150` without being rewrapped. Two encoding details are load-bearing and are the usual cause of a silently-broken tile: `#` must be `%23` (it would otherwise terminate the data URI at the fragment) and `%` must be `%25`. One SVG detail is load-bearing and is the usual cause of visible tile seams: `<filter>`'s region defaults to `x=-10% y=-10% width=120% height=120%`, so `stitchTiles="stitch"` stitches a 240×240 tile against a 200×200 image unless the region is pinned to `x='0' y='0' width='100%25' height='100%25'`.

**Three claims carried into CONTEXT are wrong against the served site, and each changes the plan.** (1) The footer has **no** background rule at all — `var(--global-footer-bg-color)` has zero consumers in the served `main.css` — so the footer already shows the body ground and inherits the texture for free; no footer rule is needed or wanted. (2) **No page on this site renders `<pre>` or `<code>`**, so a texture rule on them is dead source, which is exactly the thing Phase 3 refused to write for the monospace family. (3) The **~354px gutter is a _prose_ gutter and does not exist on the Research page's entry list**: `.entry` is a flex row inside a 900px content box (`.container` = 930px max-width minus 15px padding each side), and the prose measure selector list only reaches direct children of `<article>`, which `.entry-list` is not. Phase 4 has to _create_ the note column inside `.entry`; it cannot simply move a note into space that is already empty.

**One measured finding is a hard blocker on a locked decision.** CONTEXT locks the section rule to `--rule-500` "because it is structural (3.08:1)". Composite the texture and that margin is gone: `#9c8b6e` measures **3.00:1** against the mean textured ground and **2.76:1** against the darkest noise pixel — it fails WCAG 1.4.11's 3:1 floor for a graphical object needed to understand content. The already-shipped `.subject` border on Academics uses the same token, so this is a regression of live work, not only a constraint on new work. The fix is one token value: `#8d7b60` measures 3.79 flat / 3.41 worst-case composited, a visually near-identical hairline with real headroom.

**Primary recommendation:** put the whole texture in one opaque token (`--paper-texture`) in `_sass/_tokens.scss` with its parameters recorded in a comment — the URL is opaque to the CSS engine and **cannot be parameterised by other custom properties**; apply it to exactly three selectors (`body`, `.navbar`, and `.card` via `background-color: transparent` rather than a second tile); darken `--rule-500` to `#8d7b60` in the same commit as the texture; build the annotation bracket from `border-*` on a `content: ""` pseudo-element so GROUND-05 is true by construction; write the vocabulary + blocklist to `docs/` and the cap number into `_sass/_tokens.scss` beside the existing TOKEN-06 caps.

## Standard Stack

There is **no library to install**. This phase adds zero dependencies, zero npm scripts and zero build steps — `npm run lint:style-contract` rejects `build:css` / `build:tailwind`, and `01-VALIDATION.md` / `02-VALIDATION.md` carry a standing convention against a starter-local test or build pipeline.

### Core (all already in the repo)

| Tool / surface                                    | Version / state         | Purpose in this phase                                                                       | Why it is the right one                                                                                                                       |
| ------------------------------------------------- | ----------------------- | ------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `_sass/_tokens.scss`                              | 288 lines, shipped      | Holds `--paper-texture`, the mark lengths, the cap number, the re-pointed `--rule-500`       | Phase 2 criterion 5: every colour and length literal lives here and nowhere else. The data URI is a literal; it belongs here.                    |
| `_sass/_custom.scss`                              | 437 lines, shipped      | Consumes the tokens; the three texture rules and the mark rules                              | Declares no literals. The existing "nine gem behaviours no token can reach" block is where the navbar/card overrides already live.               |
| Inline SVG `feTurbulence` data URI                | n/a — plain CSS         | The paper grain                                                                              | 414 bytes, zero network requests, filter evaluated once over 40,000 px instead of per-viewport. PITFALLS Pitfall 10's measured recommendation.   |
| `.planning/tools/contrast.js`                     | shipped, `--selftest` 8/8 | Re-measuring every ink and rule against the composited textured ground                       | Reproduces all eight PITFALLS figures to within 0.01. It is the only contrast enforcement on this repo.                                          |
| The phase `verify.sh` harness pattern             | Phases 1–3, `EXPECTED_RED` back to 0 | Every automatable criterion, static + `--live`                                    | Phase 3 explicitly kept the mechanism and its header comment **for Phase 4**. Copy the shape; do not reinvent it.                                |
| `purgecss.config.js`                              | 22 safelist entries     | Protect any selector whose nodes do not appear in built HTML                                 | PurgeCSS deleted `:focus-visible` from production for a day. Phase 3's rule: ship the safelist entry in the same commit as the rule naming it.   |
| Dart Sass (via the gem's pipeline, `style: compressed`) | verified here against 1.83.0 | Compiles the data URI verbatim                                                       | Confirmed in this session: custom-property values pass through untouched; `//` inside the quoted string is not treated as a comment.             |
| Prettier `^3.8.0` + `@shopify/prettier-plugin-liquid`, `printWidth: 150` | shipped | Gate on `_sass/**`, `docs/**`, `_pages/**`, `_data/**`                        | Verified in this session: the 414-byte single-line declaration passes `--check` unchanged.                                                       |

### Supporting

| Surface                    | Purpose                                                        | When to use                                                                                                                 |
| -------------------------- | -------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `docs/` (a new `.md` file) | The written mark vocabulary, defences and cliché blocklist      | Criterion 2's deliverable. See Pattern 2 for why `docs/` and not `.planning/`.                                              |
| `_data/research.yml`       | A `note:` key alongside `detail:` / `status:` / `url:`          | If the note is authored as data (recommended — see Pattern 4).                                                              |
| `_pages/research.md`       | The Liquid that renders the note and the bracket                | Hand-written Liquid already; adding one `{% if e.note %}` block is a four-line change.                                       |
| A throwaway static HTML swatch under `.planning/tools/` | Tuning the texture alpha in a real browser without Jekyll | There is no Ruby, no `bundle` and no local build on this machine. A plain HTML file opens directly. See Pitfall 7.            |

### Alternatives Considered

| Instead of                                | Could use                                                | Tradeoff                                                                                                                                                        |
| ----------------------------------------- | -------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| url-encoded data URI (414 B)              | base64 data URI (≈392 B payload, ≈420 B declaration)     | Base64 is marginally smaller here but unreadable and undiffable — a parameter change becomes an opaque blob rewrite. Reject; readability is worth 0 bytes.        |
| Inline data URI                           | A tiled PNG under `assets/img/`                          | 15–60 KB and an extra request for an identical visual result. Also a `paths-ignore`-relevant new binary. Reject (PITFALLS Pitfall 10).                            |
| `numOctaves="2"`                          | `numOctaves="3"`                                         | 3 adds low-frequency clustering that reads as blotchy/aged — the thing on the blocklist. 1–2 gives the "fine, even tooth" CONTEXT locked. Cap is 3, never above.  |
| Darkening `--rule-500`                    | Leaving it at `#9c8b6e` and handing the failure to Phase 8 | Legal (CONTEXT permits deferring), but it ships a known sub-3:1 structural separator to a live admissions site for the rest of the milestone. See Pitfall 1.    |
| `.card { background-color: transparent }` | Giving `.card` its own `background-image` tile            | A second tile origin means the card's grain does not line up with the page's. Transparency is exact continuity, fewer bytes and fewer rules.                      |

**Installation:** none. `npm ci` is unchanged; `package.json` is not touched.

## Architecture Patterns

### Recommended file layout (nothing new under `_sass/`)

```
_sass/_tokens.scss          # + --paper-texture (the opaque URL), + mark lengths,
                            #   + the "notebook marks ... 4" cap line beside the
                            #   existing TOKEN-06 caps at :23, + re-pointed --rule-500
_sass/_custom.scss          # + three texture consumer rules, + the four mark rules
docs/NOTEBOOK-MARKS.md      # the written vocabulary: 4 entries x 1 defence sentence,
                            #   + the cliché blocklist (criterion 5), + the cap
_data/research.yml          # + note: on the entries the user names
_pages/research.md          # + the {% if e.note %} aside block
purgecss.config.js          # + safelist entries for any node absent from built HTML
.planning/phases/04-notebook-art-style/verify.sh   # the harness, same shape as 03
```

**Do not create `_sass/_marks.scss` or any third partial.** `assets/css/main.scss` is a verbatim copy of the gem's file plus one `@use "custom";` line; adding a partial means editing that file and losing the "re-syncing after a gem update stays trivial" property `_custom.scss`'s header states. Two files is the established shape.

### Pattern 1: One opaque texture token, three consumers

**What:** The complete `url("data:…")` lives in `_sass/_tokens.scss` as `--paper-texture`. Consumers in `_custom.scss` reference `var(--paper-texture)` and declare nothing else.

**Why it must be one opaque token:** a data URI **cannot be parameterised**. The CSS engine treats the whole URL as an opaque string, so `baseFrequency` and the rect `opacity` cannot be `var()` references. The "record the numbers in the token file" discretion item is therefore satisfied by a **comment above the declaration**, in the same style as the `--measure` arithmetic comment at `_tokens.scss:158–174` — not by separate tokens.

**The three consumers, derived from the served `main.css` (not from the gem source):**

| Element              | Current served rule                                                         | Phase 4 action                                                      | Why                                                                                                                                                |
| -------------------- | ---------------------------------------------------------------------------- | ------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| `body`               | `body{padding-bottom:70px;color:…;background-color:var(--global-bg-color)}` | add `background-image: var(--paper-texture)`                        | Body's background propagates to the canvas, so it covers the whole viewport even on short pages.                                                    |
| `.navbar`            | `.navbar{…background-color:var(--global-bg-color);opacity:.95}` + `_custom.scss:264 .navbar{opacity:1}` | add `background-image: var(--paper-texture)` to the existing override block | Fixed, opaque, and `position:fixed` means content scrolls under it — it cannot be made transparent. A flat bar over a textured page reads as a bug. |
| `.card`              | `.card{background-color:var(--global-card-bg-color)}` (+ `_custom.scss:249 box-shadow:none`) | add `background-color: transparent` to the existing override block  | Cards are already flush and shadowless on the same paper. Transparent gives exact grain continuity for free; a second tile would not line up.        |
| `footer.sticky-bottom` | `border-top`, padding, `font-size` — **and no background-color at all**     | **nothing**                                                          | `var(--global-footer-bg-color)` has **zero consumers** in the served CSS. The footer already shows the body ground and will inherit the texture.     |
| `pre`, `code`        | gem sets `background-color:var(--global-code-bg-color)`; `_custom.scss:238` sets colour | **nothing**                                                  | **No page on this site renders `<pre>` or `<code>`** (tag census of all seven live pages). A texture rule there is dead source — Phase 3's precedent. |

**Anti-pattern:** `background-attachment: fixed`. Ruled out in CONTEXT and confirmed by PITFALLS; it forces a full-viewport repaint per scroll frame and stutters on iOS Safari. Nothing in this phase needs it.

### Pattern 2: The vocabulary file in `docs/`, the cap number in `_tokens.scss`

**Recommendation:** `docs/NOTEBOOK-MARKS.md` for the written list, defences and blocklist; one new line in the `_sass/_tokens.scss` cap block for the number.

Why `docs/` rather than `.planning/`:

- `AGENTS.md`'s routing table sends documentation to `docs/`, and `docs/` is the only documentation surface that is not "regenerated every phase, not source" (`.prettierignore`'s own description of `.planning/**`).
- `docs/` **is** Prettier-checked (`.prettierignore` excludes `.planning/**`, not `docs/**`), so the document is gated like source. Run `npx prettier docs/NOTEBOOK-MARKS.md --check --end-of-line auto`.
- `docs/` is in `_config.yml`'s Jekyll `exclude:` list, so it is never built, never deployed and never seen by `broken-links-site.yml`.
- **`docs/**` is in `deploy.yml`'s `paths-ignore`.** A commit whose entire diff is the vocabulary document will **not** deploy. That is correct and desirable, but the planner must not put the vocabulary doc alone in a commit it expects to see on the live site — and conversely, a commit mixing `docs/` with `_sass/` **does** deploy, because `paths-ignore` skips only when *every* changed path matches.

Why the cap number goes in `_tokens.scss`: CONTEXT explicitly names the TOKEN-06 mechanism at `_sass/_tokens.scss:23` as the model, and that block already reads

```
 *     paper tones ........ 2
 *     ink steps .......... 4  (heading, body, footer-text, muted)
 *     accent colours ..... 1
 *     type families ...... 2  (Phase 3: Literata + Be Vietnam Pro)
```

Adding `notebook marks ..... 4  (see docs/NOTEBOOK-MARKS.md)` makes the fifth cap live next to the other four, keeps "raising a cap is a visible edit" a single-file grep, and is already covered by the harness idiom Phase 3 used (`grep -qE "type families[ .]+2" "$TOKENS"`).

### Pattern 3: The section rule — and its real page coverage

CONTEXT says "the section rule goes everywhere there are sections". Measured against the seven live pages, that is **three pages**, not seven:

| Page            | `.entry-group-title` | `<h2>` | Section rule appears? |
| --------------- | -------------------- | ------ | --------------------- |
| About (home)    | 0                    | 3      | via `h2` only         |
| Academics       | 2                    | 2      | yes                   |
| Research        | 2                    | 2      | yes                   |
| Further Reading | 0                    | 0      | **no h2 at all**      |
| Projects        | 0                    | 2      | via `h2` only         |
| Activities      | 5                    | 5      | yes                   |
| CV              | 0                    | 0      | **no h2 at all**      |

Two consequences for the plan:

1. Scoping the rule to `.entry-group-title` reaches three pages; scoping it to `h2` reaches five and pulls the home page in — which Phase 6 owns. CONTEXT keeps Phase 4 off the home-page composition. **Recommended scope: `.entry-group-title`** (three pages), with `h2` deliberately left alone and the gap recorded, the same way Phase 3 recorded `title-full` as a decision rather than an oversight. This also removes any collision with Phase 6.
2. Further Reading and CV will carry ground, type and texture but **no mark at all**. That is not a defect — it is the honest consequence of "every mark names the content it serves" on pages that have no sections. Say so in the vocabulary doc so the Phase 8 screenshot count does not read it as a miss.

Geometry: a hairline **under** the heading is recommended over beside it. `border-bottom: var(--rule-hairline) solid var(--rule-500)` reuses the exact idiom already shipped on `.subject` (`_custom.scss:114–120`), which is the "repetition reads as a system" argument CONTEXT makes, and it needs no pseudo-element, no width token and no purge safelist entry.

### Pattern 4: Marginalia — markup, and the layout arithmetic CONTEXT does not have

**The gutter CONTEXT points at does not exist where the notes go.** `_tokens.scss:169–174` describes `930px − 576px ≈ 354px` of slack. That slack is real for **prose** (`.post article > p` and friends carry `max-width: var(--measure)`), but the Research page's entries are not prose: `.entry-list` sits inside `section.entry-group`, which the child-combinator selector list deliberately does not reach. Measured from the served CSS:

```
.container{width:100%;max-width:var(--max-content-width);margin-inline:auto;padding-left:15px;padding-right:15px}
--max-content-width: 930px          ->  content box = 900px
.entry{display:flex;gap:var(--space-4)}          gap  = 1.5rem = 24px
.entry-year{flex:0 0 var(--entry-year-col)}      year = 5rem   = 80px
.entry-body                                       -> no rule at all: currently 796px wide
```

So the note column has to be **created**, not occupied. Two workable splits of the 900px row:

```
 80  + 24 +        576 (= --measure)        + 24 + 196   = 900     (body pinned to the measure)
 80  + 24 +        564                      + 24 + 208   = 900     (note pinned to a 13rem token)
```

Either gives a ~196–208px note column (≈27 characters per line at `--step-0`), which is a real marginalia measure. Pin the **note** to a new token (`--note-col: 13rem`) rather than pinning the body, so the body stays fluid and Phase 5 can re-tune one number.

**Recommended markup — an `<aside>` sibling of `.entry-body`, inside `li.entry`:**

```html
<li class="entry">
  <div class="entry-year">2026</div>
  <div class="entry-body">…</div>
  <aside class="entry-note">This is the part I still don't understand: …</aside>
</li>
```

Why a sibling and not a nested + absolutely-positioned element:

- **Stylesheet-off reading order is correct by construction.** With CSS off, `li.entry` is block flow and the three children stack: year, entry, note. The note "appears as an ordinary sentence immediately after the item it annotates", exactly as CONTEXT requires — no `position`, no `order`, no visual/DOM divergence.
- **Two consecutive notes can never overlap.** A flex/grid row grows to the taller of its children. An absolutely-positioned note can and will collide when the note is taller than the entry — which is CONTEXT's explicit open question, answered by construction rather than by tuning.
- `<aside>` communicates subordination to assistive technology without any ARIA. It is valid inside `<li>`.

Required supporting declarations: `.entry { flex-wrap: wrap }` and `.entry-body { flex: 1 1 auto; min-width: 0 }`. The `flex-wrap` is **not** scope creep into Phase 5 — without it a fixed 13rem third column at a 390px viewport produces horizontal overflow, which Phase 7 criterion 1 forbids and which would ship to a live site in the meantime. Wrapping needs no media query, which keeps CONTEXT's "no breakpoint" instinct intact; Phase 5 can formalise the ≤768px behaviour on top of it.

**Authoring surface:** put the note in `_data/research.yml` as a `note:` key beside `detail:` / `status:` / `url:`, not inline in `_pages/research.md`. The page is already a pure renderer over the data file; a note in the Liquid would be the only content in the template, and Phase 5 has to read the same key for three more pages.

### Pattern 5: The annotation bracket — borders, never a glyph

**What:** `.entry-note::before { content: ""; … border-left: …; border-top: …; }` — a small L or bracket drawn from borders on a zero-size pseudo-element.

**Why not `content: "⌐"` / `"["` / `"—"`:** screen readers **do** announce generated text content from `::before` / `::after` (VoiceOver and NVDA both do). A bracket glyph in `content:` is precisely the "orphaned or unexplained symbol" criterion 3 forbids, and hiding it again needs a second mechanism. A border-drawn bracket has no text content to announce, so GROUND-05 is true by construction and stays automatable: `grep -n 'content:' _sass/` should only ever show `content: ""`.

**Colour:** `--rule-200` (decorative only, 1.43:1). The bracket is explicitly meaningless on its own, so the 3:1 floor for "graphical objects needed to understand content" does not apply to it — and saying so in the vocabulary document is what makes that an argued position rather than an oversight.

**Motion:** none. The gem ships `html.transition *:after{transition-property:background-color,border-color,box-shadow !important}`, but `html.transition` is only ever added by the gem's `theme.js`, which `enable_darkmode: false` drops entirely. The class never appears on this site, so the bracket cannot inherit a transition. Do not add one; PITFALLS register marker #8 wants 0.

### Anti-Patterns to Avoid

- **A second `_sass/` partial.** See the file-layout note above.
- **A texture rule on `pre` / `code`.** Dead source; PurgeCSS would strip it anyway, and Phase 3 explicitly rejected "manufacturing a dead override so the decision looks implemented".
- **A footer texture rule.** The footer has no background; adding one is adding a surface that does not exist today.
- **`background-attachment: fixed`.** Ruled out in CONTEXT.
- **Putting the data URI in `_custom.scss`.** It would not trip the `custom_has_no_literals` matcher (no `#`, no `rem|px|em`), so the existing harness would **not** catch it. Placement in `_tokens.scss` has to be enforced by a new explicit row, not by the inherited matcher.
- **`numOctaves` above 2** for this grain character, and never above 3 at all.
- **Rotating or skewing anything.** `grep -rn "rotate(\|skew(" _sass/` is the register check; keep it empty.

## Don't Hand-Roll

| Problem                                         | Don't build                                              | Use instead                                                                          | Why                                                                                                                                            |
| ----------------------------------------------- | -------------------------------------------------------- | ------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| Paper grain                                     | A hand-authored PNG/JPG tile, or a CSS gradient stack     | The 414-byte `feTurbulence` data URI                                                  | Zero requests, two orders of magnitude under the 2 KB budget, 25–75× less filter work than a full-viewport filter.                              |
| Seamless tiling                                 | Hand-aligning tile edges, or `background-size` fiddling   | `stitchTiles='stitch'` **plus** an explicit filter region                              | Without the pinned region the browser stitches the 240% default region and the 200px image seams anyway.                                        |
| Contrast maths on the composited ground         | Eyeballing it, or the DevTools picker alone               | `node .planning/tools/contrast.js "<fg>" "<bg>"` on the composited hexes in Pitfall 1  | It reproduces all eight PITFALLS figures to 0.01 and self-tests. It is the only contrast enforcement this repo has.                             |
| Knowing whether a rule survived to production   | A source grep                                             | A `--live` row in `verify.sh` grepping `main.css?cb=$(date +%s)`                       | PurgeCSS runs only in CI. `.topic-list` is declared in `_custom.scss` and is **absent from the served CSS right now** — standing live proof.     |
| Hiding a decorative mark from assistive tech    | `aria-hidden`, `sr-only`, or a visually-hidden span       | A pseudo-element with `content: ""` and borders                                       | Nothing to hide: there is no text node to announce. Fewer moving parts, and it survives the stylesheet-off test trivially.                      |
| Stopping two marginalia notes colliding         | `position: absolute` + manual offsets                     | A flex/grid sibling column                                                            | The row grows to its tallest child. Collision becomes impossible rather than tuned-away.                                                        |

**Key insight:** every "custom solution" available in this phase is a way of re-deriving something the repo already measured and wrote down. The token file, `contrast.js` and the `verify.sh` harness exist because this project has no CI for contrast, performance or accessibility — bypassing them means the number is asserted rather than measured, which is the failure mode all three were built to close.

## Common Pitfalls

### Pitfall 1: The texture pushes `--rule-500` below the 3:1 floor — and it is already live

**What goes wrong:** CONTEXT locks the section rule to `--rule-500` (`#9c8b6e`) *specifically because* it measures 3.08:1 and clears WCAG 1.4.11's 3:1 for a graphical object needed to understand content. That 0.08 of headroom does not survive the texture.

**Measured in this session with `.planning/tools/contrast.js`:**

| Ground                                       | Hex       | `--rule-500` `#9c8b6e` | `--ink-800` `#2b2621` | `--ink-500` `#5c5349` | `--accent-600` `#1d4ed8` |
| -------------------------------------------- | --------- | ---------------------- | --------------------- | --------------------- | ------------------------ |
| flat `--paper-100` (today)                   | `#faf6ee` | **3.08:1** pass        | 13.90:1               | 6.99:1                | 6.22:1                   |
| mean composited (black noise, α·0.5 ≈ 0.025) | `#f7f3eb` | **3.00:1 FAIL**        | 13.53:1               | 6.80:1                | 6.06:1                   |
| darkest noise pixel (black at α = 0.05)      | `#eeeae2` | **2.76:1 FAIL**        | 12.48:1               | 6.28:1                | 5.59:1                   |
| darkest pixel at α = 0.06                    | `#ebe7e0` | **2.69:1 FAIL**        | 12.15:1               | 6.11:1                | —                        |

Every ink step stays comfortably AA. **`--rule-500` is the only token the texture breaks** — and it is already consumed live by `.subject`'s `border-bottom` on the Academics page, so this is a regression of shipped work, not merely a constraint on the new section rule.

**How to avoid — candidate replacements, all measured here:**

| Candidate     | flat `#faf6ee` | mean `#f7f3eb` | worst `#eeeae2` | recess `#f2ebdd` | verdict                                            |
| ------------- | -------------- | -------------- | --------------- | ---------------- | -------------------------------------------------- |
| `#9c8b6e` (today) | 3.08          | 3.00           | 2.76            | 2.80             | fails composited                                    |
| `#948267`     | 3.45           | 3.36           | **3.10**        | 3.13             | minimum that clears; no margin                      |
| **`#8d7b60`** | **3.79**       | **3.70**       | **3.41**        | **3.45**         | **recommended** — clears with headroom, visually a hairline apart from today |
| `#88765c`     | 4.06           | 3.96           | 3.65            | 3.69             | safe but starting to read as a line, not a hairline |

This is a **one-line token swap** with the ratio comment updated — exactly the "value swap on one line; every consumer follows automatically" shape `_tokens.scss:71–74` already describes for the accent fallback. Pulling it into Phase 4 rather than Phase 8 costs one line and removes a live sub-3:1 separator; leaving it is defensible only if written down as a deferral with these numbers attached, which CONTEXT requires ("it must not be dropped silently").

**Warning sign:** anyone re-deriving 3.08:1 from the existing in-file comment and concluding the rule is fine. That comment was measured against flat `#faf6ee` and says so.

### Pitfall 2: `#` and `%` inside the data URI silently break the tile

**What goes wrong:** the image simply does not render. No console error, no fallback, no CI failure — the page just looks exactly like it did before the texture landed, which reads as "the deploy did not ship" and sends you hunting in the wrong place.

**Why it happens:** `#` is the URI fragment delimiter, so everything after it is discarded; `%` starts a percent-escape, so a bare `%` (as in `width='100%'`) leaves an invalid escape sequence for the decoder.

**How to avoid:** `#` → `%23` (the internal `filter='url(%23t)'` reference), `%` → `%25` (`width='100%25' height='100%25'`), `<` → `%3C`, `>` → `%3E`. Use single quotes inside the SVG and double quotes for the CSS string so `"` never needs encoding.

**Verified here:** the resulting 414-byte declaration round-trips through `decodeURIComponent()` to valid SVG, compiles unchanged through Dart Sass `--style=compressed`, and passes `prettier --check`.

### Pitfall 3: `stitchTiles` does not stitch, because the filter region is 240×240

**What goes wrong:** a faint but regular grid of seams every 200px. Once you see it you cannot unsee it, and it reads as a rendering artefact — the exact "looks like a bug" failure the navbar decision was made to avoid.

**Why it happens:** `<filter>` defaults to `x="-10%" y="-10%" width="120%" height="120%"` (MDN, stated explicitly). `stitchTiles="stitch"` makes the noise stitch across the borders of the **filter tile**, which is that 120% region — not across the 200×200 image the browser repeats.

**How to avoid:** pin the region: `<filter id='t' x='0' y='0' width='100%25' height='100%25'>`.

**Warning sign:** seams visible at 100% zoom on a wide monitor; more obvious on a flat swatch than on text.

### Pitfall 4: PurgeCSS strips the new selectors

**What goes wrong:** the source is correct, `jekyll serve` looks right, and production silently ships without the mark. This has already cost this project a day (`:focus-visible`, Phase 2) and is provably biting right now (`.topic-list` is declared in `_custom.scss` and appears **zero times** in the served `main.css`).

**Risk assessment for this phase's selectors:**

| Selector                         | Node PurgeCSS matches | In built HTML?                                      | Action                                                          |
| -------------------------------- | --------------------- | --------------------------------------------------- | ---------------------------------------------------------------- |
| `body`, `.navbar`, `.card`       | tag / class           | yes (all seven / all seven / projects)              | none                                                             |
| `.entry-group-title`             | class                 | yes — academics, research, activities                | none                                                             |
| `.entry-note`, `.entry-note::before` | class              | **only once the markup ships**                       | ship the markup and the rule in the **same commit**, or safelist |
| `:root` (the token declaration)  | pseudo-class          | survives today (the whole token block is live)      | none, but assert it in `verify.sh --live`                        |

**How to avoid:** Phase 3's rule, unchanged — ship the safelist entry in the same commit as the rule that names it, and then **grep the served CSS**, not the local build. Note that if the phase splits markup and CSS across plans, `.entry-note` is purgeable in between; either keep them in one commit or add `"entry-note"` to the safelist defensively.

### Pitfall 5: `.card` stays opaque and the projects page looks patched

**What goes wrong:** eight `.card` elements on `/projects/` keep `background-color: var(--global-card-bg-color)` = flat `--paper-100`, so eight flat rectangles sit on a textured page. Same failure class as the flat navbar, on the one page nobody thinks to re-check.

**How to avoid:** `background-color: transparent` on `.card`, added to the existing override 2 block at `_custom.scss:249`. Cards are already flush and shadowless by decision, so nothing else changes. Note that `.cv .card` also carries a border in the gem CSS but the CV page renders no `.card` today.

### Pitfall 6: The texture composites under the focus ring

**What goes wrong:** PITFALLS records that a focus ring over texture is visually destroyed even at a passing computed ratio. `:focus-visible` is `--ink-900` at `--focus-ring-width: 2px` / `--focus-ring-offset: 2px` — the offset was chosen partly for this, and `--ink-900` measures 14.27:1 even on the darkest composited pixel, so the number is fine. The risk is perceptual, not numeric.

**How to avoid:** put it in the human checkpoint — tab through the navbar and one body link on the deployed site after the texture lands. Do not re-tune the ring blind; the standing rule from `_custom.scss:318–328` is that the ring is never suppressed and never carried by a shadow alone.

### Pitfall 7: The alpha cannot be chosen from a description

**What goes wrong:** "barely perceptible" and "visible at normal reading distance" are two floors half a stop apart, and no amount of reading decides between α = 0.035, 0.05 and 0.07. Guessing costs a deploy (~112–168 s each, and CONTEXT budgets the phase's deploys deliberately).

**How to avoid:** there is no Ruby, no `bundle` and no local Jekyll build on this machine — but the texture needs none of that. Write a single static HTML file (`.planning/tools/` is the precedent for phase tooling, and `.planning/**` is both Prettier-ignored and deploy-ignored) containing `#faf6ee`, three or four candidate alphas side by side, a flat control swatch, and a paragraph of 17px Literata over each. Open it directly in a browser and in the phone's browser over the LAN or via a screenshot. Decide the number before the push, then record it in the `_tokens.scss` comment.

**Warning sign:** an alpha chosen in the plan and never looked at until after the deploy.

### Pitfall 8: iOS Safari and SVG-filter backgrounds

**What goes wrong:** community reports (not reproducible here, no device) describe mobile Safari rasterising or degrading complex SVG background images to save processor time. `feTurbulence` itself has been Baseline-supported since 2015, and the known hard failure is specifically **animating** `baseFrequency`, which this phase does not do.

**Confidence: LOW-to-MEDIUM.** This could not be verified in this environment.

**How to handle:** criterion 1 already requires a check on a 390px phone, so the verification exists. What the plan should add is a **named fallback decided in advance**: if the tile does not render or renders coarsely on iOS, fall back to the flat ground (delete one declaration) rather than reaching for a raster tile — the same "removing a mark is deleting one block from one file" logic CONTEXT applies to the marks.

### Pitfall 9: `gsd-tools state record-metric` will damage STATE.md again

Recorded in STATE.md as deterministic over **ten consecutive occasions**: it deletes `stopped_at:`, `resume_file:` and `progress.percent:` and rewrites `status: in-progress` to `status: unknown`, and writes its metric row in the wrong format. `advance-plan` and `update-progress` refuse outright. Budget for restoring all four by hand and `git diff .planning/STATE.md` after every call. Related: `roadmap update-plan-progress` mangles table padding unpredictably, and Git Bash needs `MSYS_NO_PATHCONV=1` before any `git show <rev>:<path>`.

## Code Examples

### The texture token (verified: 414 bytes, Dart Sass clean, Prettier clean)

```scss
// _sass/_tokens.scss — TIER 1
//
// PAPER GRAIN (GROUND-02). One opaque string, and it has to be opaque: a data
// URI cannot be parameterised, so baseFrequency / numOctaves / opacity CANNOT
// be var() references. The numbers are therefore recorded here in prose, the
// same way --measure records its arithmetic.
//
//   tile        200 x 200  -> the filter is evaluated once over 40,000 px and
//                            the raster repeats: 25-75x less work than a
//                            full-viewport filter on a dpr-3 phone.
//   type        fractalNoise  (smooth; `turbulence` gives ripples, not tooth)
//   baseFrequency 0.9      -> fine, even tooth. Lower reads coarse/fibrous.
//   numOctaves  2          -> 1-2 stays even; 3+ clusters and reads as aged
//                            blotching, which is on the cliche blocklist.
//   feColorMatrix saturate 0 -> feTurbulence emits independent R/G/B noise;
//                            without this the grain carries colour speckle.
//   opacity     0.05       -> chosen against 17px Literata on --paper-100.
//                            See Pitfall 1: this is the value every composited
//                            contrast figure below was measured at.
//   filter region x/y/width/height are PINNED. The default is -10%/120%, and
//   stitchTiles would then stitch a 240px tile against a 200px image -> seams.
//   `#` is %23 and `%` is %25 or the URI breaks silently.
//
//   measured size: 414 bytes, against a 2,048-byte budget.  Zero requests.
--paper-texture: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='200' height='200' viewBox='0 0 200 200'%3E%3Cfilter id='t' x='0' y='0' width='100%25' height='100%25'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='2' stitchTiles='stitch'/%3E%3CfeColorMatrix type='saturate' values='0'/%3E%3C/filter%3E%3Crect width='200' height='200' filter='url(%23t)' opacity='0.05'/%3E%3C/svg%3E");
```

Compiled output (Dart Sass 1.83.0, `--style=compressed`) preserves the value verbatim, including the space after the colon:

```css
:root{--paper-texture: url("data:image/svg+xml,%3Csvg xmlns=…%3C/svg%3E")}
```

**Therefore every `verify.sh` matcher for it must be whitespace-tolerant**, as the Phase 3 harness already is for `calc()`.

### The three consumers

```scss
// _sass/_custom.scss

// body — background propagates to the canvas, so this covers the viewport
// even on a short page.  NO background-attachment: fixed (per-frame repaint).
body {
  background-image: var(--paper-texture);
}

// Override 3 (existing block). The bar is fixed and opaque and cannot be made
// transparent — content scrolls under it — so it carries its own tile. Its
// origin is the viewport, not the document, so its grain does not scroll with
// the page; at this alpha that is imperceptible, and the alternative is a flat
// bar over a textured page, which reads as a rendering bug.
.navbar {
  opacity: 1;
  background-image: var(--paper-texture);
}

// Override 2 (existing block). Cards are already flush and shadowless on the
// same paper, so transparency gives exact grain continuity for nothing — a
// second tile would have its own origin and would not line up.
.card {
  box-shadow: none;
  background-color: transparent;
}
```

### The section rule (Pattern 3)

```scss
// MARK 1 of 4 — the section rule.  Defence: it shows the reader where one
// group of work ends and the next begins.  See docs/NOTEBOOK-MARKS.md.
// Structural, so --rule-500, NOT the decorative --rule-200. Same idiom as
// .subject's border above, deliberately: repetition reads as a system.
.entry-group-title {
  padding-bottom: var(--space-2);
  border-bottom: var(--rule-hairline) solid var(--rule-500);
}
```

### The margin note and its bracket (Patterns 4 and 5)

```html
<!-- _pages/research.md, inside <li class="entry"> after .entry-body -->
{% if e.note %}<aside class="entry-note">{{ e.note }}</aside>{% endif %}
```

```scss
// MARK 2 of 4 — the margin note.  Defence: it carries the open question or
// caveat behind the item it sits next to.
//
// An <aside> SIBLING of .entry-body, never a nested absolutely-positioned
// element: with the stylesheet off, li.entry is block flow and the note reads
// as an ordinary sentence immediately after the entry it annotates (GROUND-05,
// criterion 3, true by construction).  A flex row also grows to its tallest
// child, so two consecutive notes cannot overlap.
//
// flex-wrap is load-bearing, not polish: without it a fixed --note-col at a
// 390px viewport overflows horizontally. It needs no media query, so it does
// not pre-empt Phase 5's ~768px collapse.
.entry {
  flex-wrap: wrap;
}

.entry-body {
  flex: 1 1 auto;
  min-width: 0;
}

.entry-note {
  position: relative;
  flex: 0 0 var(--note-col);
  font-size: var(--step-0);
  color: var(--ink-500);
}

// MARK 3 of 4 — the annotation bracket.  Defence: it shows which item the note
// belongs to.  Meaningless alone, which is the point.
//
// BORDERS, NEVER A GLYPH. Screen readers announce generated text content, so
// content:"[" would be exactly the orphaned symbol criterion 3 forbids.
// content:"" has nothing to announce. Keep `grep -n 'content:' _sass/` showing
// only content: "".
.entry-note::before {
  content: "";
  position: absolute;
  left: calc(var(--space-3) * -1);
  top: var(--space-1);
  width: var(--space-2);
  height: var(--space-3);
  border-left: var(--rule-hairline) solid var(--rule-200);
  border-top: var(--rule-hairline) solid var(--rule-200);
}
```

```yaml
# _data/research.yml — the note lives with the data, not in the template,
# because Phase 5 reads the same key on three more pages.
- year: 2026
  title: "Rethinking Attention Sinks: …"
  role: Lead author
  status: In progress — writing
  note: # <- authored by the site owner at the plan's named checkpoint
```

### Re-measuring a composited ratio

```bash
# Darkest noise pixel over --paper-100 at alpha 0.05 is #eeeae2; the mean is
# #f7f3eb. Both are derived, not guessed: composite black at the rect opacity.
node .planning/tools/contrast.js "#9c8b6e" "#eeeae2"   # 2.76:1  FAIL
node .planning/tools/contrast.js "#8d7b60" "#eeeae2"   # 3.41:1  pass
node .planning/tools/contrast.js --selftest            # 8 pairs, 0 failed
```

## State of the Art

| Old approach                                     | Current approach                                                | When changed                | Impact                                                                        |
| ------------------------------------------------ | ---------------------------------------------------------------- | --------------------------- | ------------------------------------------------------------------------------ |
| Tiled PNG paper texture (15–60 KB + a request)   | Inline url-encoded `feTurbulence` data URI (~0.4 KB, 0 requests) | Widespread since ~2020      | Meets GROUND-02's "cheap on mobile" outright; nothing else is competitive.     |
| Base64 data URIs                                 | Percent-encoded data URIs                                        | Established practice        | Smaller for SVG in most cases, and diffable — a parameter change is readable.  |
| Full-viewport live SVG filter on `body`          | A small tiled raster the filter is evaluated into once           | PITFALLS Pitfall 10's numbers | 25–75× less filter work, worst-case on exactly the high-DPR phones in scope.  |
| `background-attachment: fixed` for a fixed ground | A `position: fixed` pseudo-element with `will-change: transform` (if ever needed) | Long-standing | Not needed here; a tiled texture does not want a fixed ground at all.          |

**Deprecated / not applicable here:**

- `numOctaves >= 5` — the SVG literature is consistent that added detail is imperceptible past ~5 and, at dpr 1, past ~3 it is finer than a CSS pixel while still being paid for on every composite.
- Anything that parameterises the noise from CSS custom properties. The URL is opaque; this is a hard limit, not a style choice.

## Open Questions

1. **The exact rect `opacity` (α).**
   - What we know: 0.05 is the value every composited contrast figure in Pitfall 1 was computed at, and PITFALLS recommends "opacity under 0.1". The range that plausibly satisfies both "barely perceptible" and "visible at normal reading distance" is roughly 0.035–0.07.
   - What is unclear: which one actually reads correctly behind 17px Literata on `#faf6ee`, on a real phone.
   - Recommendation: decide it in a browser before the push using the static swatch file (Pitfall 7), then re-run `contrast.js` against the composited hexes for the α actually chosen and update the `_tokens.scss` comment. If α rises above 0.06, re-check `--rule-500` — the table in Pitfall 1 shows it falling further.

2. **Whether to pull `--rule-500` forward into this phase or defer it to Phase 8.**
   - What we know: the numbers (Pitfall 1). The fix is one line. The failure is already live on Academics.
   - What is unclear: nothing technical — it is a scope decision belonging to the plan.
   - Recommendation: pull it forward, in the same commit as the texture, with the ratio comment updated and a `verify.sh` row asserting the new value. Deferring is defensible only if the deferral is written into REQUIREMENTS.md/STATE.md with these numbers attached.

3. **Does iOS Safari render the tile faithfully?**
   - What we know: `feTurbulence` is Baseline-supported since 2015; the well-documented failure is animating `baseFrequency`, which is not done here. Community reports of mobile Safari degrading complex SVG backgrounds exist but could not be verified in this environment.
   - Recommendation: it is already a criterion-1 check. Name the fallback (drop to the flat ground) in the plan so it is a decision, not a scramble.

4. **Whether the section rule should also reach `h2`.**
   - What we know: `.entry-group-title` reaches Academics, Research and Activities; adding `h2` would add About and Projects, and About is Phase 6's composition.
   - Recommendation: `.entry-group-title` only, with the gap recorded in the vocabulary doc — the `title-full` precedent from Phase 3, where the absence of a selector is itself the decision.

5. **Whether the human note-authoring checkpoint blocks the phase's single deploy.**
   - What we know: CONTEXT forbids closing on placeholder prose and requires a checkpoint that names specific entries. `_data/research.yml` has two research entries; one has an empty `detail:` and one has a filled one.
   - Recommendation: schedule the checkpoint **before** the CSS plan finishes, naming both research entries and offering the four permitted note kinds, so the note text is in hand when the single deploy is spent.

## Validation Architecture

`workflow.nyquist_validation` is `true` in `.planning/config.json`.

### Test Framework

| Property          | Value                                                                                                                             |
| ----------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| Framework         | **None, by standing convention.** No browser test framework, no npm test script, no `package.json` change. `test/style_contract.js` and `npx prettier` are the only repo-level gates that survive. |
| Config file       | none — the phase harness is a flat list of assertions plus a tally                                                                 |
| Quick run command | `bash .planning/phases/04-notebook-art-style/verify.sh`                                                                            |
| Full suite        | `bash .planning/phases/04-notebook-art-style/verify.sh --live`                                                                     |
| Supporting tools  | `node .planning/tools/contrast.js --selftest` · `node test/style_contract.js` · `npx prettier _sass docs/NOTEBOOK-MARKS.md _data _pages purgecss.config.js --check --end-of-line auto` |

Copy the Phase 3 harness shape verbatim: `set -uo pipefail` (never `-e`), the `check()` function, the `CHECKS` / `FAILED` / `EXPECTED_RED` tally, the `--live` flag, the `[red until plan 04-NN]` labelling, and the `?cb=$(date +%s)` cache-buster on every fetch of `main.css`. Phase 3 closed with `EXPECTED_RED` at 0 and kept the mechanism **specifically for this phase**.

### Phase Requirements → Test Map

| Req ID    | Behaviour                                                        | Test type   | Automated command                                                                                                            | Exists? |
| --------- | ----------------------------------------------------------------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------ | ------- |
| GROUND-02 | The texture token exists, in the token file, with pinned region    | static grep | `grep -qE -- "--paper-texture:[[:space:]]*url\(" _sass/_tokens.scss` + `grep -qF "stitchTiles='stitch'" _sass/_tokens.scss` + `grep -qF "x='0' y='0'" _sass/_tokens.scss` | Wave 0 |
| GROUND-02 | It is under 2,048 bytes                                           | static      | `[ "$(grep -o 'url("data:image/svg+xml,[^"]*"' _sass/_tokens.scss \| head -1 \| wc -c)" -lt 2048 ]`                             | Wave 0 |
| GROUND-02 | No `background-attachment: fixed` anywhere                        | static grep | `! grep -rqE 'background-attachment:[[:space:]]*fixed' _sass/`                                                                  | Wave 0 |
| GROUND-02 | No literal SVG/URL leaked into the consumer file                  | static grep | `! grep -q 'data:image/svg' _sass/_custom.scss` (the inherited `custom_has_no_literals` matcher does **not** catch this)        | Wave 0 |
| GROUND-02 | Zero new network requests                                         | static grep | `! grep -rq 'assets/img/.*tex' _sass/ _config.yml` + no new file under `assets/`                                               | Wave 0 |
| GROUND-02 | body / navbar / card consume the token in the **served** CSS      | live grep   | `grep -qE 'body\{[^}]*background-image:[[:space:]]*var\(--paper-texture\)' "$LIVE_CSS"` (one row per selector)                  | Wave 0 |
| GROUND-02 | No jank on a 390px phone at normal reading distance               | **manual**  | DevTools Performance, 4× CPU, paint-flashing; then a real phone                                                                | manual  |
| GROUND-03 | The vocabulary document exists and names four marks with defences | static grep | `[ -f docs/NOTEBOOK-MARKS.md ]` + one `grep -q` per mark name + `[ "$(grep -c '^Defence:' docs/NOTEBOOK-MARKS.md)" = "4" ]`     | Wave 0 |
| GROUND-03 | The cap reads 4 and sits with the other caps                      | static grep | `grep -qE "notebook marks[ .]+4" _sass/_tokens.scss`                                                                           | Wave 0 |
| GROUND-03 | The blocklist is in the same document                             | static grep | one `grep -qi` per banned item (coffee, tape, paperclip, torn, spiral, ruled, rotated…)                                         | Wave 0 |
| GROUND-03 | Nothing on the blocklist ships (criterion 5)                      | static grep | `! grep -rqiE 'coffee\|washi\|paperclip\|pushpin\|spiral\|page-curl' _sass/` and `! grep -rqE 'rotate\(\|skew\(' _sass/`        | Wave 0 |
| GROUND-03 | The section rule reaches the served CSS                           | live grep   | `grep -qE '\.entry-group-title[^{]*\{[^}]*border-bottom' "$LIVE_CSS"`                                                           | Wave 0 |
| GROUND-03 | `--rule-500` carries its **composited** ratio                     | tool        | `node .planning/tools/contrast.js "<rule-500>" "#eeeae2"` ≥ 3.0 — see Pitfall 1                                                | Wave 0 |
| GROUND-05 | No pseudo-element carries announceable text                       | static grep | `! grep -rnE 'content:[[:space:]]*"[^"]+"' _sass/` (only `content: ""` permitted)                                              | Wave 0 |
| GROUND-05 | The note is a real element in reading order                       | live grep   | `grep -qE '<aside class="entry-note">' "$LIVE_HTML_RESEARCH"` and it appears **after** its `.entry-body` in source order        | Wave 0 |
| GROUND-05 | Stylesheet-off: content complete, no orphaned symbol              | **manual**  | DevTools → disable `main.css` → reload all seven pages                                                                        | manual  |
| criterion 4 | ≤2 purely decorative marks in any first viewport                | **manual**  | full-page screenshot per page, counted                                                                                        | manual  |
| criterion 4 | Greyscale + 8px blur: headings strongest                         | **manual**  | screenshot, desaturate, blur                                                                                                  | manual  |
| regression | `.entry-note` survived PurgeCSS                                   | live grep   | `grep -q '\.entry-note' "$LIVE_CSS"` — the `.topic-list` precedent                                                            | Wave 0  |
| regression | Prettier and the style contract stay green                        | command     | `npx prettier … --check --end-of-line auto` · `node test/style_contract.js`                                                    | exists  |

Five rows are genuinely manual. That is not a gap — criteria 1, 3 and 4 are written as human observations, and `axe.yml` is `workflow_dispatch`-only while `lighthouse-badger.yml` measures the upstream demo. Batch them into one named `checkpoint:human-verify`, following the 03-04 precedent.

### Sampling Rate

- **Per task commit:** `bash .planning/phases/04-notebook-art-style/verify.sh` (static only — no network).
- **Per wave merge:** static harness + `npx prettier … --check --end-of-line auto` + `node test/style_contract.js` + `node .planning/tools/contrast.js --selftest`.
- **Phase gate:** `verify.sh --live` with `FAILED = 0` and `EXPECTED_RED = 0` after the single push, plus the batched human checkpoint, before `/gsd:verify-work`.

### Wave 0 Gaps

- [ ] `.planning/phases/04-notebook-art-style/verify.sh` — the whole harness; copy the Phase 3 shape, keep the red-by-design header comment.
- [ ] A static texture swatch for choosing α in a browser (Pitfall 7) — throwaway, under `.planning/`.
- [ ] `docs/NOTEBOOK-MARKS.md` — the criterion-2 artefact itself; it is a deliverable *and* the thing several rows grep.
- [ ] The named human checkpoint asking the site owner for 1–2 real notes on **specifically named** research entries (CONTEXT requires the ask be specific).
- [ ] No framework install, no npm script, no `package.json` change.

## Sources

### Primary (HIGH confidence)

- **This repository, read directly:** `_sass/_tokens.scss`, `_sass/_custom.scss`, `assets/css/main.scss`, `purgecss.config.js`, `package.json`, `.prettierrc`, `.prettierignore`, `_config.yml`, `_pages/research.md`, `_data/research.yml`, `.github/workflows/deploy.yml`, `.github/workflows/broken-links-site.yml`, `test/style_contract.js`, `.planning/tools/contrast.js`, `.planning/phases/03-typography/verify.sh`, `.planning/{REQUIREMENTS,ROADMAP,STATE}.md`, `.planning/research/PITFALLS.md`.
- **The deployed site, fetched during this research:** `https://phamhakhanhchi.com/assets/css/main.css` (28,546 B), `…/assets/css/tailwind.css` (16,894 B), and all seven pages. Used for the footer-background finding, the `pre`/`code` tag census, the `.entry-group-title` page coverage, and the 930/900px container arithmetic.
- **Measurements run here:** `node .planning/tools/contrast.js` (self-test 8/8) for every composited ratio in Pitfall 1; byte counts for the data URI; Dart Sass 1.83.0 `--style=compressed` compile of the token; `npx prettier --check` on the same.
- [MDN — `<filter>`](https://developer.mozilla.org/en-US/docs/Web/SVG/Reference/Element/filter) — the `x=-10% y=-10% width=120% height=120%` default region, quoted verbatim.
- [MDN — `feTurbulence`](https://developer.mozilla.org/en-US/docs/Web/SVG/Reference/Element/feTurbulence) and [MDN — `stitchTiles`](https://developer.mozilla.org/en-US/docs/Web/SVG/Reference/Attribute/stitchTiles) — semantics and Baseline support since July 2015.

### Secondary (MEDIUM confidence)

- [Codrops — SVG Filter Effects: Creating Texture with `feTurbulence`](https://tympanus.net/codrops/2019/02/19/svg-filter-effects-creating-texture-with-feturbulence/) — `fractalNoise` vs `turbulence`, `numOctaves` saturating around 5, `stitchTiles` semantics.
- [CSS-Tricks — Grainy Gradients](https://css-tricks.com/grainy-gradients/) and [Creating Patterns With SVG Filters](https://css-tricks.com/creating-patterns-with-svg-filters/) — the inline data-URI-as-background idiom.
- [Stoyan Stefanov — The Truth about encoding SVG in data URIs](https://www.phpied.com/truth-encoding-svg-data-uris/) and [tigt/mini-svg-data-uri](https://github.com/tigt/mini-svg-data-uri) — `#` → `%23`, percent-encoding smaller than base64 for SVG.
- [freeCodeCamp — Grainy CSS Backgrounds Using SVG Filters](https://www.freecodecamp.org/news/grainy-css-backgrounds-using-svg-filters/) and [ibelick — Creating grainy backgrounds with CSS](https://ibelick.com/blog/create-grainy-backgrounds-with-css) — `baseFrequency` 0.6–0.9 and `opacity` under 0.1 for UI grain (multiple independent sources agree).

### Tertiary (LOW confidence — flagged for validation)

- Community reports that mobile Safari rasterises or degrades complex SVG background images ([gist](https://gist.github.com/3602910), [mdn/browser-compat-data#18810](https://github.com/mdn/browser-compat-data/issues/18810)). Not reproducible in this environment; folded into Pitfall 8 with a named fallback rather than stated as fact.
- The claim that screen readers announce `::before` / `::after` text content is well-established behaviour for VoiceOver and NVDA but was not tested here. The recommendation (`content: ""` + borders) is safe whether or not it holds, which is why it is made unconditionally.

## Metadata

**Confidence breakdown:**

- **Standard stack: HIGH.** No libraries. Every surface was read in-repo, and the one new technique was compiled and Prettier-checked in this session.
- **Architecture: HIGH.** The consumer map, the page coverage table and the 900px layout arithmetic come from the served CSS and the seven live pages, not from the gem source or from CONTEXT's description.
- **Pitfalls: HIGH for 1–7 and 9** (all measured or read directly, several correcting CONTEXT). **LOW-to-MEDIUM for 8** (iOS Safari — unverifiable here, flagged).
- **The α value: MEDIUM at best**, and deliberately left as an open question rather than asserted; it is a perceptual judgement that needs a browser.

**Research date:** 2026-09-18
**Valid until:** ~2026-12-18 (30 days would be conservative; nothing here is fast-moving — `feTurbulence` has been stable for a decade and the repo facts change only when this project changes them). **Re-read the served `main.css` and the `gh-pages` tip at plan time**, because any deploy between now and then moves them.

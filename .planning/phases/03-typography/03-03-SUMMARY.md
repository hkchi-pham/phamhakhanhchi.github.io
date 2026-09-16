---
phase: 03-typography
plan: 03
subsystem: ui
tags: [scss, css-cascade, tailwind-layers, purgecss, safelist, literata, be-vietnam-pro, measure, font-weight, specificity]

# Dependency graph
requires:
  - phase: 03-typography
    provides: "Plan 03-02's eleven token names (--font-serif, --font-sans, --step-0..--step-5, --leading-body, --leading-heading, --measure) and the css2 request that actually loads the five cuts; plan 03-01's settled decisions (A) status-serif and (B) title-full, the 44.2px note, and the 8-row red-by-design target"
  - phase: 02-palette-and-design-tokens
    provides: "The unlayered-main.css-beats-@layer override mechanism and the six existing gem overrides that rely on it; the no-literals-in-_custom.scss matcher; the PurgeCSS safelist and the :focus-visible lesson that explains why the three tags are safelisted in this same commit"
provides:
  - "body { font-family: var(--font-serif) } — the single declaration that makes the site AND all six heading levels serif, via tailwind base's h1..h6 { font-family: inherit }"
  - "The weight lever: h1/h2 at 600, h3..h6 at 400, overriding tailwind base's font-weight: 300"
  - "Heading sizes off the scale: h1/.post-title --step-5, h2 --step-4, h3 --step-3, h4 --step-2, plus an h2..h4 space-scale rhythm correction"
  - "var(--font-sans) on exactly four classes: .entry-year, .entry-meta, .subject-grade, .nav-link"
  - "The 14-selector two-level prose measure list bounded by var(--measure)"
  - ".navbar-brand { font-family: var(--font-serif) } and the extended .post-title/.navbar-brand .font-weight-bold { font-weight: inherit }"
  - "purgecss.config.js safelist entries ol, blockquote, h4 — landed in the same commit as the rule that names them"
affects: [03-04, 04-marginalia, 05-page-composition, 06-hero, 07-mobile-print, 08-qa-audit]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "One family declaration on body, zero per-heading family rules: headings inherit through tailwind base's own font-family:inherit, so 'headings are serif' has exactly one implementation site"
    - "A selector list whose members PurgeCSS cannot see in the built HTML ships with its safelist entries in the SAME commit, never a follow-up"
    - "A settled ABSENCE (no header.post-header selector, no monospace rule) is written as a comment where the code would have gone, so the gap reads as a decision"

key-files:
  created: []
  modified:
    - _sass/_custom.scss
    - purgecss.config.js

key-decisions:
  - "The measure is a 14-selector explicit two-level child list, NOT `.post article > :is(...)`. :is() works in every supported browser but PurgeCSS's selector-node analysis of it has never been exercised on this project and its failure mode is silent; the explicit list is known to degrade node-by-node, which a safelist can correct."
  - "h2, h3 and h4 gained `margin-top: var(--space-4); margin-bottom: var(--space-2)` — the plan's explicit discretion clause. The gem leaves margin-top:0, which at a 30.6px h2 puts the heading closer to what it FOLLOWS than to what it INTRODUCES. h1/.post-title keep the gem's margins because the page title is a masthead, not an in-flow heading. .entry-title's own `margin: 0 0 var(--space-1)` is a class and outranks the tag rule, so the entry lists are untouched."
  - "`font-weight: 400` on body is written out even though 300 would resolve to the same 400 FACE with only 400/600 loaded — precisely because it looks identical, which is why it would go unnoticed propagating into h1/h2 where the locked 600 is the hierarchy lever."
  - "No monospace family is declared anywhere. See 'The monospace rule that was not written' below."
  - "`.navbar-brand { font-family: var(--font-serif) }` is declared explicitly rather than inherited from body, so 'the name is one face' is a grep in the served CSS instead of an assumption."
  - "The fenced override section's header moved from 'Six gem behaviours no token can reach' to 'Nine', and its enumeration sentence was extended, rather than leaving a count that disagrees with the groups below it."

patterns-established:
  - "The register division is stated ONCE, as a closed four-class list, above the first class that takes the sans — so 'may I make this sans too?' has a written answer instead of a precedent."
  - "Each new override group carries the exact gem/tailwind declaration it corrects in its comment, continuing the convention established by overrides 1-6."

requirements-completed: [TYPE-02, TYPE-03, TYPE-04]

# Metrics
duration: 10min
completed: 2026-09-16
---

# Phase 3 Plan 03: The Type Rules Summary

**One `body` declaration turns the site and all six heading levels Literata, a 600/400 weight lever gives hierarchy something that survives a greyscale blur, four classes and no more take Be Vietnam Pro, the name stops rendering in two weights, and a 14-selector prose measure ships with its three PurgeCSS-invisible tags safelisted in the same commit — all 8 remaining static harness rows green, 38 of 38.**

## Performance

- **Duration:** ~10 min
- **Started:** 2026-09-16T09:49:00Z
- **Completed:** 2026-09-16T09:59:00Z
- **Tasks:** 2 of 2
- **Files modified:** 2 (`_sass/_custom.scss`, `purgecss.config.js`) — exactly the two the plan predicted

## Harness result

```
bash .planning/phases/03-typography/verify.sh
  38 checks, 0 failed
```

All eight `[red until plan 03-03]` rows went green, and no previously-green row turned red:

| Row | File |
| --- | ---- |
| sets a serif body from `var(--font-serif)` | `_sass/_custom.scss` |
| points labels at `var(--font-sans)` | `_sass/_custom.scss` |
| gives the prose `max-width: var(--measure)` | `_sass/_custom.scss` |
| neutralises `.navbar-brand .font-weight-bold` | `_sass/_custom.scss` |
| sets h1/h2 to `font-weight: 600` | `_sass/_custom.scss` |
| safelists `"ol"` | `purgecss.config.js` |
| safelists `"blockquote"` | `purgecss.config.js` |
| safelists `"h4"` | `purgecss.config.js` |

Still green and still unlabelled: no font-family outside the two family tokens, no hex/rem/px/em/color-mix literal in `_custom.scss`, no `!important` on any declaration in `_sass/`, Prettier, `node test/style_contract.js`, and both selftest tools. `UNLABELLED` is 0 and there is no longer any static red to label.

`node test/style_contract.js` → `Starter style contract check passed.` (03-02's narrowed icon-CDN loop is unaffected by this plan.)

## The measure selector list, verbatim

This is the whole rule as it now stands in `_sass/_custom.scss`. Plan 03-04 and Phase 4 should compare against this rather than re-deriving it:

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

Fourteen selectors, two levels. Level 1 catches the entry pages, `/cv/` and `/further-reading/`, whose prose is a direct child of `<article>`. Level 2 catches the **home page**, whose entire body sits inside `<div class="clearfix">` and which a one-level list would miss completely — silently, with the source still looking correct.

**Child combinators, not descendant, and that is what makes the exclusion clause work.** `h2.entry-group-title` and `h3.entry-title` are both inside `<article>`, so a descendant selector would have pulled them into the measure and contradicted 03-CONTEXT's own exclusion list. At depth 2+ under a class this list does not name, `section.entry-group > h2`, `.entry-body > h3`, `.card-body > p` and the `.subject` rows are all out of reach.

**`h1.post-title` and `p.post-description` are deliberately absent** — plan 03-01's decision (B) `title-full`. They live in `<header class="post-header">`, a sibling of `<article>`, so the measure cannot reach them and the title keeps the full 930px. No `header.post-header` selector was added, and `verify.sh`'s comment marking where that row would have gone was left exactly as 03-01 wrote it.

**On `/cv/` and `/further-reading/` a `p.entry-detail` IS a direct child of `<article>` and so does pick up the measure.** That is correct: it is prose.

`max-width` alone, no auto margins — the column stays flush against the page's left edge, which is what puts the ~354px gutter entirely on the right where Phase 4's marginalia goes.

**Not collapsed into `:is()`.** `.post article > :is(p, ul, ol, ...)` is shorter and works in every browser this site supports, but PurgeCSS's selector-node analysis of `:is()` has never been exercised here and its failure mode is silent. The explicit list degrades node by node, which a safelist can correct — and does.

## The safelist, and why it had to be this commit

`purgecss.config.js` gained `"ol"`, `"blockquote"` and `"h4"` with a comment in the style of the existing `":focus-visible"` and `"h5"`/`"h6"` entries. No existing entry was removed or reordered; `":focus-visible"` keeps its leading colon. The array is now 22 entries.

Three of the fourteen selectors above name tags that appear in **no built page on this site** (03-RESEARCH Finding 7, a census of all seven deployed pages). PurgeCSS prunes unused nodes out of a selector *list* and reports nothing, so without these entries the measure rule ships with three of its selectors quietly missing while the source stays correct. The standing live proof is cited in-file: `_custom.scss` declares `.topic-list` and the **served** `main.css` contains zero occurrences of it.

Also recorded in-file, because it is luck rather than a rule: `pre,code{color:var(--ink-800)}` survives purging today only because the words "pre" and "code" happen to occur in page text and PurgeCSS's default extractor matches bare tag selectors against any word token. That is why these three got explicit entries rather than a hope.

`.al-folio-overrides.yml` is unchanged — confirmed with `git status`, not assumed. Its hash covers `assets/css/main.scss`, which this plan never touched.

## The navbar-brand correction

The plan flagged this as "the TYPE-03 hazard nobody wrote down", and it is worse than it first reads. **Both** places this site renders the name wrap the family name in `.font-weight-bold` inside a `.font-weight-lighter` container:

- `.post-title` — the home page's `<h1>` (already levelled in Phase 2)
- `.navbar-brand` — the masthead link on the **six inner pages**

`.font-weight-bold` forces 700, which snaps to the loaded 600 cut, while the rest of the name inherits the lighter weight. So "Phạm" renders heavier than "Hà Khánh Chi" — the same one-name-two-appearances failure TYPE-03 exists to prevent, expressed in weight instead of typeface. It reads as a small step today only because Roboto is a variable font and can interpolate; against discrete 400/600 cuts it is a visible jump. The existing override was **extended** rather than duplicated, so the pair cannot drift apart:

```scss
.navbar-brand {
  font-family: var(--font-serif);
}

.post-title .font-weight-bold,
.navbar-brand .font-weight-bold {
  font-weight: inherit;
}
```

### Correction to the record: the name is never in two places at once

03-CONTEXT says "the name appears in two places". That is true page by page, but **the two are never both on screen simultaneously.** The navbar brand does **not** render on the home page at all, and `.post-title` *is* the home page's own `<h1>`. A visitor sees exactly one of the two per page. The job is therefore to make them match **across** pages, not within one — which means the manual TYPE-03 check at 03-04 must compare the home page's `h1` against an inner page's masthead, not look for two instances on one screen.

`font-weight-bold` was already in the PurgeCSS safelist and `.navbar-brand` is in the built HTML, so both selector nodes survive purging without a new entry.

## The monospace rule that was not written

No `font-family` is declared for `pre`/`code`, here or anywhere, and that is a decision rather than an omission. It is now recorded as a comment attached to override 1 (the `pre, code { color: var(--ink-800) }` rule), so the gap reads as deliberate:

- `main.css` gives `pre`/`code` no `font-family` at all, so code already resolves to the browser's monospace default — which is the intended result.
- The gem's only `Iosevka Fixed` declaration targets `.typogram`, which **no page on this site renders**. An override of it would be purged as dead source anyway.
- `_tokens.scss`'s two-family cap comment records the same decision from the token side (plan 03-02).

A dead rule written to make the decision "look implemented" would have been the third family entering through the back door, which is exactly what criterion 3's grep exists to catch.

## The register division

Stated once in `_custom.scss`, above the first class that takes it, as a **closed** list of four:

`.entry-year`, `.entry-meta`, `.subject-grade` (all three already existed and gained the declaration) and `.nav-link` (new rule, override 9). Nothing else gets `var(--font-sans)`.

`.entry-status` is the deliberate odd one out among the four dimmed classes: it declares **no** `font-family` and therefore inherits `var(--font-serif)`, keeping its italic in Literata. Plan 03-01's decision (A) `status-serif` — it is an authorial aside inside an entry, not a label, and the Literata 400 italic cut is requested from css2 for this rule alone.

`.nav-link` keeps `font-weight: bolder` untouched. Against the loaded 400/600 cuts that resolves to the real Be Vietnam Pro 600 face rather than a synthesised faux-bold, and it is the non-colour active-nav marker Phase 2 chose because it survives greyscale. Only the family changed.

## Task Commits

1. **Task 1: Set the site in Literata, the labels in Be Vietnam Pro, and unsplit the name** — `68ce66e` (feat)
2. **Task 2: Give the prose its measure, and safelist it in the same commit** — `5effa77` (feat)

`git diff --stat 5356ed8..HEAD` → `_sass/_custom.scss` (+232/−5), `purgecss.config.js` (+19). Two files, as specified.

## Files Created/Modified

- `_sass/_custom.scss` (modified, +232/−5) — the register-division note and `var(--font-sans)` on the three label classes; the extended one-name rule plus `.navbar-brand`'s explicit serif; the 14-selector prose measure; the fenced section's header moved from "Six" to "Nine gem behaviours" with its enumeration extended; and three new override groups — **7** the `body` serif/size/weight/leading declaration, **8** the heading weight lever, sizes and rhythm, **9** `.nav-link` in the companion sans. Every value is a `var()` into `_tokens.scss`; no literal, no `!important`, no monospace rule.
- `purgecss.config.js` (modified, +19) — `"ol"`, `"blockquote"`, `"h4"` appended after the Phase 2 entries, with the mechanism, the `.topic-list` live proof and the `pre`/`code` luck note in-comment.

## Decisions Made

See `key-decisions` in the frontmatter. The two most likely to be revisited:

1. **The heading rhythm (`h2, h3, h4 { margin-top: var(--space-4); margin-bottom: var(--space-2) }`) is discretionary.** The plan explicitly delegated heading margins to Claude, conditional on the gem's `margin-bottom: .5rem` reading wrong at the new sizes — it does: with `margin-top: 0` a 30.6px h2 sits flush on the paragraph above it and the proximity reads backwards. This is the one visual change in this plan that no harness row covers, so **03-04's checkpoint should look at it specifically**, on `/academics/` (where `.entry-group-title` is an h2) and on the home page.
2. **The explicit 14-selector list over `:is()`.** If a later phase wants to shorten it, the thing to establish first is PurgeCSS's behaviour on `:is()` — not the browser support, which is fine.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Task 1's inline `<automated>` block carries the un-narrowed `!important` matcher**

- **Found during:** Task 1 (running the task's own verification)
- **Issue:** The plan's task-1 verify command chain includes `! grep -rq '!important' _sass/`. That bare form matches the word `!important` inside Sass `//` **comments**, and `_custom.scss` has three such lines — two written in Phase 2 explaining why none of the gem overrides needs one, and one added by this plan for the same reason about override 7. The chain therefore exits 1 on a file with zero `!important` declarations. This is the *same* matcher plan 03-01 already identified as wrong and narrowed in `verify.sh` (recorded as its deviation 2); the narrowing simply never propagated back into 03-03-PLAN.md's inline copy.
- **Fix:** No source change. The task was verified against the harness's `no_important()` semantics instead — `grep -rnE '!important' _sass/ | grep -vE '^[^:]+:[0-9]+:[[:space:]]*//'` — which is the authoritative expression of the criterion and returns empty. `verify.sh` was **not** edited; its row was already correct and is green.
- **Files modified:** none
- **Verification:** All three `!important` occurrences in `_sass/` confirmed to be `//` comment lines; `verify.sh`'s `Crit-5 no !important on any declaration in _sass/` row passes.
- **Committed in:** n/a (no code change; recorded here so the next reader does not "fix" `_custom.scss`'s prose to satisfy a matcher the project has already rejected twice)

---

**Total deviations:** 1 auto-fixed (1 bug, in the plan's inline matcher rather than in the code)
**Impact on plan:** None on scope or output. This is the fourth instance of the project's standing rule — when the gate and a correct implementation disagree, narrow the matcher and say why; never delete the check and never edit the implementation to satisfy it.

## Issues Encountered

- **The fenced section's header count was stale the moment groups 7-9 landed.** It read "Six gem behaviours no token can reach" with an enumeration sentence accounting for exactly six. Left alone it would have been a comment that contradicts the code beneath it within one plan of being written. Both the count and the sentence were updated. This is a comment edit, not a behaviour change, and no harness row references the number.
- **Nothing could be built or purged locally.** There is no Ruby, no `bundle`, no `_site/` and no local Jekyll on this machine, and PurgeCSS runs only in CI. Every claim about what *ships* is therefore a prediction until 03-04 pushes — which is precisely what the 18 `--live` rows below exist to convert into measurement.

## The exact `--live` rows plan 03-04 must watch

These are the rows this plan's work is responsible for turning green after the push. They are already in `verify.sh` under `[red until plan 03-04]`; nothing here needs to be added. **A red row in this list after the deploy means PurgeCSS or the minifier ate something, not that the source is wrong.**

**The body and the weight lever (5 rows)**

1. `served main.css: body takes var(--font-serif)`
2. `served main.css: body takes font-weight 400 (tailwind base ships 300)`
3. `served main.css: an h1 rule carries font-weight 600`
4. `served main.css: an h2 rule carries font-weight 600`
5. `served main.css: an h3 rule carries font-weight 400`

**The eight fragile measure nodes, one row each (8 rows)**

6. `.post article>p` 7. `.post article>h2` 8. `.post article>h3`
9. `.post article>h4` 10. `.post article>ol` 11. `.post article>blockquote`
12. `.post article>.clearfix>p` 13. `.post article>.clearfix>h2`

Rows 9, 10 and 11 are the ones the new safelist entries exist for. If exactly those three are red, the safelist did not take effect; if row 12 or 13 is red, the two-level structure did not survive.

**The label faces and the unsplit name (5 rows)**

14. `.navbar-brand .font-weight-bold is present (TYPE-03 weight fix)`
15-18. `.entry-year` / `.entry-meta` / `.subject-grade` / `.nav-link` each take `var(--font-sans)`

**One mechanical caution for 03-04.** Several of these rows match within a single line (`body\{[^}]*font-family:…`, `h1[^{]*\{[^}]*font-weight:…`), so they assume the served `main.css` is **minified**. It is today. If a build change ever un-minifies it, those rows go red for a formatting reason rather than a real one — check the served file's shape before chasing a rule that is present.

## User Setup Required

None — no external service configuration required.

## Next Phase Readiness

**Ready for plan 03-04**, the phase's single push. It owns:

- the deploy itself (fonts URL from 03-02 + tokens from 03-02 + these rules must reach visitors in **one** push, or the site serves Literata's bytes with Roboto's rules);
- `bash .planning/phases/03-typography/verify.sh --live`, and the 18 rows above in particular;
- the four genuinely manual criteria listed in `verify.sh`'s header note (c): the name-in-one-typeface zoom check, the characters-per-line count via `Range.getClientRects()`, the fallback-swap glance, and **re-judging `--underline-offset: 0.18em` against Literata's descenders** — Literata's are ~26% deeper relative to em than Roboto's, so a collision with `ạ`/`ợ` is more likely than not, and this plan deliberately did not touch the token;
- plus the one discretionary item this plan added and no row covers: the `h2..h4` heading rhythm.

**Nothing has been pushed.** `origin/gh-pages` is untouched; working tree is clean apart from this summary and the state files.

**Carried blocker, unchanged by this plan:** Phase 2's close-out tag `design-02-<slug>` is still outstanding and must point at `482c740`, not at local HEAD.

---

_Phase: 03-typography_
_Completed: 2026-09-16_

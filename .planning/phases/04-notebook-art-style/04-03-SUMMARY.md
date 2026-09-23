---
phase: 04-notebook-art-style
plan: 03
subsystem: ui
tags: [texture, notebook-marks, details-disclosure, purgecss, wcag-1411, ground-05, liquid]

# Dependency graph
requires:
  - phase: 04-notebook-art-style
    plan: 01
    provides: "`verify.sh` (the 53-row harness and its `[red until plan 04-03]` labels), `docs/NOTEBOOK-MARKS.md` (the four defences, the blocklist, the two fallbacks)"
  - phase: 04-notebook-art-style
    plan: 02
    provides: "`--paper-texture` at alpha 0.06, `--note-col: 13rem`, `--rule-500` re-pointed to `#8d7b60`, the `notebook marks ..... 4` cap line, and the settled `note:` / `note_full:` contract recorded in `04-VALIDATION.md` § C"
  - phase: 03-typography
    provides: "`--measure: 36rem`, which now caps the EXPANDED note rather than housing the collapsed one"
  - phase: 02-tokens-and-ground
    provides: "`.subject`'s hairline idiom that MARK 1 repeats, `.post article a` which IS mark 4"
provides:
  - "Three texture consumers in the served design: `body`, `.navbar`, `.card` — one continuous sheet with no second tile origin anywhere"
  - "The four marks as CSS: `.entry-group-title` hairline, the `.entry-note` column, `.entry-note::before` bracket, and mark 4 named in-file as already-shipped"
  - "`--entry-body-basis: 25rem` — a NEW token, and the reason the note sits beside the entry at all; it also fixes the wrap point at ~766px with no media query"
  - "`<details class=\"entry-note\">` on `_pages/research.md` — a two-state disclosure, native, no JavaScript, sibling of `.entry-body`"
  - "`note:` / `note_full:` live on two research entries, carrying the site owner's own prose"
  - "Three PurgeCSS safelist nodes (`entry-note`, `entry-note-summary`, `entry-note-full`) shipped in the same commit as the rules that name them"
  - "`verify.sh` re-pointed from `<aside>` to `<details>` — four stale rows narrowed, eight rows added, none deleted; 59 checks, 0 failed"
affects: [04-04, 05-list-pages, 06-composition, 07-responsive, 08-qa-audit]

# Tech tracking
tech-stack:
  added:
    - "Native `<details>`/`<summary>` disclosure — the first interactive widget on this site, and it runs on zero JavaScript"
  patterns:
    - "A wrapping flex row's break point is decided by each item's MAX-CONTENT width unless a basis says otherwise; `flex: 1 1 auto` on a column holding 80–100 character titles pushes the sibling off the line at every viewport"
    - "PurgeCSS matches selector NODES, so `entry-note` does not cover `entry-note-summary`; `::before` and `[open]` need no entry because they carry the class node"
    - "A stale harness row is RE-POINTED in the same commit as the markup that made it stale, and the repair is documented inside the harness rather than in the commit alone"
    - "A harness helper found wrong is fixed as part of re-pointing it, and the old defect is written down so the row's history survives"

key-files:
  created:
    - .planning/phases/04-notebook-art-style/04-03-SUMMARY.md
  modified:
    - _sass/_custom.scss
    - _sass/_tokens.scss
    - _pages/research.md
    - _data/research.yml
    - purgecss.config.js
    - docs/NOTEBOOK-MARKS.md
    - .planning/phases/04-notebook-art-style/verify.sh

key-decisions:
  - "`.card` takes `background-color: transparent` rather than its own tile, so the grain is EXACTLY continuous instead of nearly so — a second tile would have its own origin and would not line up"
  - "`--entry-body-basis: 25rem` was added rather than the plan's `flex: 1 1 auto`, because `auto` resolves to max-content and this site's real titles are 80–100 characters, which put the note on its own line at EVERY width"
  - "The bracket stays on `.entry-note` rather than moving to `.entry-note-summary`, so it marks the note in both states AND the load-bearing `::before` harness row needed no re-pointing at all"
  - "The expanded note takes `flex-basis: 100%` capped at `--measure`; `max-width` only ever caps, so a 390px viewport gets the container width and no media query is needed"
  - "The four stale `<aside>` rows were re-pointed, not deleted — and a FIFTH row named as stale in 04-VALIDATION.md turned out not to be stale and was left verbatim"
  - "`docs/NOTEBOOK-MARKS.md`'s margin-note defence was rewritten IN PLACE to the exact sentence `_custom.scss` quotes, so the two cannot drift; the `Defence:` count stays at 4"

patterns-established:
  - "When a plan's own CSS value is wrong for the real content, add the token and write the arithmetic beside it — the number then has a documented meaning and a later phase can re-tune one thing instead of re-deriving the layout."
  - "Before re-pointing a harness row, check whether it actually broke. One of the four named stale rows asserted something about the stylesheet, not the markup, and survived the scope change untouched."

requirements-completed: []

# Metrics
duration: ~40min
completed: 2026-09-23
---

# Phase 4 Plan 03: Consuming the Tokens Summary

**The phase becomes visible: one continuous paper grain across body, navbar and cards; a structural hairline under every section heading; and the site owner's own research prose shipped as a native two-state disclosure that is a sibling of the entry it annotates, so the stylesheet-off page reads it as an ordinary sentence.**

## Performance

- **Duration:** ~40 min across two sessions (11:20–11:31 and 16:39–16:41 local)
- **Tasks:** 3 of 3, plus the amendment's doc and harness work
- **Commits:** 5 — `7b21494` (the plan amendment), `2e78bf8`, `e07b911`, `003e610`, `f85b274`
- **Files modified:** 7; 1 summary created
- **Harness at close:** **59 checks, 0 failed.** Every static row in the phase is green; the `--live` rows remain `[red until plan 04-04]` by design.

## Accomplishments

- **One sheet, not three surfaces.** `body` and `.navbar` take the same tile and `.card` takes transparency rather than a fourth one, so the grain is continuous by construction — there is no second tile origin anywhere on the site to line up.
- **The note sits beside the entry, which it would not have done as planned.** The plan's `flex: 1 1 auto` on `.entry-body` resolves to max-content, and this site's real titles are 80–100 characters on one unwrapped line. The note would have wrapped below the entry at every viewport width. `--entry-body-basis: 25rem` fixes it and lands the wrap at ~766px with no media query.
- **Two states, one mark, zero JavaScript.** The owner's four- and three-paragraph accounts are in the delivered DOM whether the widget is open or shut, so the screen reader, the stylesheet-off page and the `<summary>` all read the same text. Nothing is hidden, nothing is pushed off-screen, and no pseudo-element carries a word.
- **Three safelist nodes, not one.** `entry-note-summary` and `entry-note-full` are separate selector nodes; `"entry-note"` is not a substring match that covers them. They shipped in the same commit as the rules that name them, and three live rows now watch for them in the served CSS.
- **A harness defect was found while re-pointing it.** `aside_after_entry_body` compared the LAST `.entry-body` line to the FIRST `.entry-note` line, which cannot pass on a page with more than one entry — and the Research page has five. It would have failed on correct markup.

## The selectors, and which block each one joined

**Task 1 — texture (commit `2e78bf8`).** Three declarations, each added to an **existing** override block; no new block:

| Selector  | Existing block           | Declaration added                             |
| --------- | ------------------------ | --------------------------------------------- |
| `body`    | override 7 (`:347` → `:590`) | `background-image: var(--paper-texture)` |
| `.navbar` | override 3 (`:264` → `:483`) | `background-image: var(--paper-texture)` |
| `.card`   | override 2 (`:249`)          | `background-color: transparent`          |

`--deploy-proof` re-dated to `"2026-09-18 phase-04-notebook"`. The two surfaces that deliberately get nothing — the footer (no background rule exists to texture) and `pre`/`code` (no page renders either) — are written down in-file so a later phase reads the absence as a decision.

**Task 2 — the marks (commit `e07b911`).** A fenced section headed with the cap and a pointer to `docs/NOTEBOOK-MARKS.md`, each rule carrying its defence quoted from that document:

| Selector                | New or joined                  | What it does                                          |
| ----------------------- | ------------------------------ | ----------------------------------------------------- |
| `.entry-group-title`    | **new** block, `:257`          | MARK 1 — `padding-bottom` + hairline `border-bottom` in `--rule-500` |
| `.entry`                | **joined** the existing `:76`  | `flex-wrap: wrap` — load-bearing against 390px overflow |
| `.entry-body`           | **new** block, `:305`          | `flex: 1 1 var(--entry-body-basis)`, `min-width: 0`   |
| `.entry-note`           | **new** block, `:310`          | MARK 2 — `--note-col` column, `--step-0`, `--ink-500`, `margin: 0` |
| `.entry-note-summary`   | **new** block, `:319`          | `cursor: pointer`                                      |
| `.entry-note[open]`     | **new** block, `:338`          | `flex-basis: 100%`, `max-width: var(--measure)` — the breakout |
| `.entry-note-full`      | **new** block, `:343`          | `margin-top: var(--space-2)`                           |
| `.entry-note::before`   | **new** block, `:374`          | MARK 3 — L-corner from `border-left` + `border-top`, `content: ""` |
| `.post article a`       | **comment only**               | MARK 4 — named, not touched; no value changed          |

`_sass/_tokens.scss` gained one token, `--entry-body-basis: 25rem`, with 27 lines of arithmetic above it.

## Which entries carry notes, and which do not

`_data/research.yml` has five entries in two sections. **Two carry notes; three deliberately do not.**

| Section    | Entry                                                                 | `note:` | `note_full:` |
| ---------- | --------------------------------------------------------------------- | ------- | ------------ |
| `research` | Rethinking Attention Sinks (2026) — *the open question*               | ✅ yes  | ✅ 4 paras   |
| `research` | Echo chambers across three recommender algorithms (2026) — *the surprising result* | ✅ yes  | ✅ 3 paras   |
| `courses`  | CS50's Introduction to AI with Python (2025)                          | —       | —            |
| `courses`  | AI for Beginners (2025)                                               | —       | —            |
| `courses`  | Introduction to AI (2024)                                             | —       | —            |

The three courses have no note because the site owner did not write one for them, and the phase is explicitly forbidden from closing on invented prose. Both notes are the owner's own words, shipped verbatim from `04-VALIDATION.md` § C with its twelve-item typo ledger; nothing was paraphrased or tidied at this end.

The Liquid supports a third case that no entry currently exercises: `note:` with no `note_full:` renders a plain non-collapsing `<p class="entry-note">`. It is there because the settled contract says so and because Phase 5 will reach three more pages, where a one-sentence note with nothing behind it is the likely shape.

## What a harness row forced me to narrow, and why

**Four rows re-pointed, one row found NOT stale, eight rows added, zero deleted.**

| Row                                    | Was                                     | Now                                                  | Why |
| -------------------------------------- | --------------------------------------- | ----------------------------------------------------- | --- |
| static, `_pages/research.md`           | `<aside class="entry-note">`            | `<details class="entry-note">`                        | The tag changed; the assertion did not weaken |
| static, source order                   | `aside_after_entry_body`                | `note_after_entry_body`                               | Renamed **and repaired** — see below |
| live 47                                | `<aside class="entry-note">`            | `<details class="entry-note">`                        | Same tag change against the served HTML |
| live 48                                | `aside_after_entry_body`                | `note_after_entry_body`                               | Same helper, same repair |
| static, `.entry-note::before` `content` | empty `content` string                  | **unchanged, verbatim**                               | Named as stale in `04-VALIDATION.md` follow-up 4, but it is not: it asserts something about `_custom.scss`, not about the markup. Keeping the bracket on `.entry-note` rather than moving it to the summary meant the row kept working as plan 04-01 wrote it. It is load-bearing for GROUND-05 and was left alone. |

**The helper repair is the part worth reading.** `aside_after_entry_body` took the LAST line matching `entry-body` and the FIRST line matching `entry-note` and required `n > b`. On a page with more than one entry — the served Research page has five, and the last three carry no note — the last body always follows the first note, so the row failed on **correct** markup. It also assumed one tag per line, which no minifier guarantees. It now reads class attributes in document order and requires that at least one note exists and that no note appears before a body has been seen. The trailing quote in the pattern pins the match to the exact class value, so `entry-note-summary` and `entry-note-full` — which are inside the note — do not match it.

That change opened a blind spot: "after `.entry-body`" is also satisfied by a note **nested inside** `.entry-body`, which is the one way to destroy GROUND-05 while leaving every CSS row green. A new row, `note_is_sibling_not_nested`, closes it against the Liquid source (a line-structured file Prettier keeps stable, and where the mistake would actually be made).

**Eight rows added** for what the second state introduced: the `<summary>` element, the `note_full:` block scalar, the sibling-not-nested structure, the absence of any script or `aria-hidden` on the page, the expanded body's presence in the delivered DOM, the two new safelisted class nodes in the served CSS, and the `[open]` breakout rule surviving PurgeCSS. Per harness note (a), the ones green the day they were written carry no label.

## Discretionary rules NO harness row covers — read these at 04-04's checkpoint

This is the section plan 04-04's human sweep should work from. Each of these is a judgement, and nothing automated will notice if it is wrong.

1. **`--entry-body-basis: 25rem` and therefore the ~766px wrap point.** No row asserts the number or the breakpoint. If the note wraps below the entry too early or too late on a real window, this is the one value to re-tune.
2. **`.entry-note[open] { flex-basis: 100%; max-width: var(--measure); }` — the breakout.** The open assumption `04-VALIDATION.md` already flags. It is arithmetic (≈230 words at ≈27 chars/line ≈ 50 lines), not a render. **If it reads as a jump rather than a disclosure, the fallback is written: drop the mark, keep the ground and the type.**
3. **`.entry-note-summary { cursor: pointer }`.** The only affordance the collapsed state has beyond the UA's own disclosure triangle. Whether the summary reads as clickable at `--step-0` in `--ink-500` is a human call.
4. **The UA disclosure triangle is left unstyled**, deliberately — it is a control drawn by the browser, not ink this stylesheet spends. Whether an unstyled triangle beside a paper-ground note reads as native or as unfinished is exactly the kind of thing the sweep exists for.
5. **`.entry-note-full { margin-top: var(--space-2) }`** — the only spacing between the summary sentence and the four paragraphs it opens onto.
6. **The bracket's position** (`left: calc(var(--space-3) * -1)`, `top: var(--space-1)`, `--space-2` × `--space-3`). Rows prove it exists and that its `content` is empty; nothing proves it lands where a bracket should.
7. **`.card { background-color: transparent }` on the projects page.** Eight cards, and it is the page nobody re-checks. The grain should be exactly continuous across them; a visible card boundary would mean a second tile origin got in somewhere.
8. **The navbar's viewport-origin tile.** The bar is `position: fixed`, so its grain does not scroll with the page. At alpha 0.06 that should be imperceptible — but "should be" is the whole reason it is on this list.

## Task Commits

1. **Plan amendment for the two-state note** — `7b21494` (docs)
2. **Task 1: texture reaches body, navbar and cards as one sheet** — `2e78bf8` (feat)
3. **Task 2: the four notebook marks** — `e07b911` (feat)
4. **Task 3: the two-state margin note, its data, and its safelist** — `003e610` (feat) — markup, matcher and safelist in one commit
5. **The margin note's defence describes a two-state mark** — `f85b274` (docs)

**Plan metadata:** see the final `docs(04-03)` commit.

## Files Created/Modified

- `_sass/_custom.scss` (+262 lines across two commits) — three texture declarations in existing blocks, the fenced marks section with all four defences, the breakout rule and the bracket.
- `_sass/_tokens.scss` (+28 lines) — `--entry-body-basis` and the arithmetic that produced it.
- `_pages/research.md` (+9 lines) — the two-state mark and its comment; one loop serves both the `research` and `courses` sections, so Phase 5 inherits the same shape.
- `_data/research.yml` (+34 lines) — the header field list gains `note` and `note_full`, plus both notes.
- `purgecss.config.js` (+16 lines) — three safelist nodes and the comment explaining why one is not enough.
- `docs/NOTEBOOK-MARKS.md` (12 lines changed) — the margin-note defence rewritten in place, the `<aside>` corrected to `<details>`, the created-not-occupied column corrected, the breakout recorded.
- `.planning/phases/04-notebook-art-style/verify.sh` (179 lines changed) — note (f), the two repaired/added helpers, four rows re-pointed and eight added.

## Decisions Made

- **`.card` gets transparency, not a tile.** Exact grain continuity for free; a second tile has its own origin and cannot be made to line up.
- **`--entry-body-basis` over `flex: 1 1 auto`.** The plan's value was written before anyone checked what a wrapping flex row does with an 80–100 character title. `auto` resolves to max-content, which put `80 + title + 208` past 900px and wrapped the note to its own line at every desktop width. `flex-basis: 0` fails at the other end — the line then always fits, so at 390px the note keeps its 208px and squeezes the body to ~24px. A fixed basis fixes both and changes nothing about the wide layout.
- **The bracket stays on `.entry-note`.** Moving it to `.entry-note-summary` would have marked only the collapsed state and would have forced a re-point of the one harness row that is load-bearing for GROUND-05. Absolutely positioned, so on a `<details>` it is out of flow and the disclosure widget is untouched.
- **The `::before` row was NOT re-pointed.** `04-VALIDATION.md` named four stale rows and it was right about three of them. Checking before editing is why a load-bearing accessibility assertion still reads exactly as plan 04-01 wrote it.
- **The doc's defence sentence is the same string as the stylesheet's.** Rewritten in place, matching word for word, so drift between the two is visible rather than plausible.
- **REQUIREMENTS.md stays untouched; GROUND-02, GROUND-03 and GROUND-05 stay `Pending`.** Nothing is proven against the served CSS or the served HTML until plan 04-04's deploy, and 20 `--live` rows are still `[red until plan 04-04]`. Marking them now would put REQUIREMENTS.md in disagreement with `verify.sh` — the mistake 03-02 made and reverted by hand. Fifth consecutive deliberate refusal; the convention holds.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] `flex: 1 1 auto` on `.entry-body` put the note on its own line at every width**

- **Found during:** Task 2
- **Issue:** The plan specifies `.entry-body { flex: 1 1 auto; min-width: 0; }`. A wrapping flex container decides line breaks from each item's hypothetical main size, which for a `flex-basis: auto` item is its **max-content** width. `.entry-body`'s max-content is the entry title on one unwrapped line, and this site's real titles are 80–100 characters — so `80 + (that) + 208` exceeds the 900px content box and the note wraps below the entry on a full-width desktop. The note would never have sat beside the item it annotates, which is the only thing a margin note has to do. `flex-basis: 0` fails at the other end: the line then always fits, so a 390px viewport keeps the 208px note and squeezes the body to ~24px.
- **Fix:** Added `--entry-body-basis: 25rem` to `_sass/_tokens.scss` with the full derivation above it, and used `flex: 1 1 var(--entry-body-basis)`. The wide layout is unchanged (`80 + 24 + 564 + 24 + 208 = 900`); the basis only decides where the line breaks, at a content box narrower than `80 + 400 + 208 + 2×24 = 736px`, i.e. below a ~766px viewport — which lands on the ~768px collapse Phase 5 was going to formalise, with no media query.
- **Files modified:** `_sass/_tokens.scss`, `_sass/_custom.scss`
- **Committed in:** `e07b911`

**2. [Rule 1 - Bug] The harness helper could not pass on a page with more than one entry**

- **Found during:** Task 3, while re-pointing the four stale rows
- **Issue:** `aside_after_entry_body` took the LAST `entry-body` line number and the FIRST `entry-note` line number and required the note to be later. The served Research page has five entries and only the first two carry notes, so the last body always follows the first note and the row failed on correct markup. The defect predates the two-state decision and would have bitten the `<aside>` too. It also assumed one tag per line.
- **Fix:** Rewritten as `note_after_entry_body`, reading class attributes in document order: at least one note must exist, and no note may appear before a body has been seen. The pattern pins the trailing quote so the two inner classes do not match.
- **Files modified:** `.planning/phases/04-notebook-art-style/verify.sh`
- **Committed in:** `003e610`

**3. [Rule 2 - Missing Critical] "After `.entry-body`" does not mean "not inside `.entry-body`"**

- **Found during:** Task 3
- **Issue:** Repairing the ordering helper made its blind spot explicit: a note nested **inside** `.entry-body` also reads as "after" a match for `entry-body`. Nesting is precisely the failure that destroys GROUND-05 while leaving every CSS row green — the stylesheet-off page would read the note inside the entry rather than after it, and the breakout would have no flex line to break out to.
- **Fix:** Added `note_is_sibling_not_nested`, asserted against the Liquid source: `.entry-body` opens, a `</div>` on its own line closes it, and only then does `.entry-note` appear. Checked against the source rather than the served HTML because the source is line-structured, Prettier keeps it stable, and it is where the mistake would be made.
- **Files modified:** `.planning/phases/04-notebook-art-style/verify.sh`
- **Committed in:** `003e610`

**4. [Rule 2 - Missing Critical] Two of the three new class nodes had no safelist entry and no row**

- **Found during:** Task 3
- **Issue:** The plan (written before the two-state decision) safelists `"entry-note"` and states that the pseudo-element needs no separate entry. That is true of `::before` and of `[open]`, which both carry the `.entry-note` class node — but `entry-note-summary` and `entry-note-full` are **different nodes**, and `"entry-note"` is a node match, not a substring match. Both rules would have been correct in `_sass/` and absent from production: the `.topic-list` failure, which is live on this site right now.
- **Fix:** Three safelist entries with the reasoning in-file, and the single `Purge` row turned into a loop over all three. Three `--live` rows added for the served CSS, including one for the `[open]` attribute selector — a node type PurgeCSS has not been exercised on here before.
- **Files modified:** `purgecss.config.js`, `.planning/phases/04-notebook-art-style/verify.sh`
- **Committed in:** `003e610`

**5. [Rule 3 - Blocking] `docs/NOTEBOOK-MARKS.md` described a gutter that does not reach the entry list**

- **Found during:** Task 3 (the amendment's doc rewrite)
- **Issue:** The margin-note section said the note occupies the ~354px prose gutter Phase 3 left. The plan's own divergence 3 establishes that it does not: `.entry` is a flex row in a 900px content box, and the measure selectors touch only direct children of `<article>`, which `.entry-list` is not. Leaving it would have told a later phase the column already existed and could be moved or reclaimed.
- **Fix:** The section now says the column is **created** from `--note-col` plus `flex-wrap`, and records that Phase 3's warning against reclaiming the prose gutter still stands on its own terms because this mark does not test it. The `<aside>` reference was corrected to `<details>` and the breakout was recorded with its check and its fallback in the same pass.
- **Files modified:** `docs/NOTEBOOK-MARKS.md`
- **Committed in:** `f85b274`

### Deliberate non-changes

**The `.entry-note::before` harness row was named as stale and is not.** `04-VALIDATION.md` follow-up 4 lists four superseded rows; three were superseded and one was not. That row asserts an empty `content` string in `_sass/_custom.scss`, which the tag change does not touch, and keeping the bracket on `.entry-note` rather than moving it to the summary meant it kept working verbatim. It is left exactly as plan 04-01 wrote it, and note (f) in the harness records why — so the next reader does not find a "stale" row still in place and assume it was missed.

---

**Total deviations:** 5 — 2 bug fixes, 2 missing-critical, 1 blocking documentation correction. Plus one row deliberately **not** changed despite being named for change.
**Impact on plan:** No scope creep. Deviation 1 is the difference between a margin note and a paragraph below the entry; deviations 2–4 are the difference between a green harness and a harness that measures something. The plan's `files_modified` grew by `_sass/_tokens.scss` (one token) beyond the amendment's own additions of `verify.sh` and `docs/NOTEBOOK-MARKS.md`.

## Issues Encountered

- **No Ruby toolchain in this environment** — `bundle` and `ruby` are both absent, so nothing here was verified against a real Jekyll build. The Liquid was checked by reading (`{% if %}` / `{% if %}` / `{% else %}` / `{% endif %}{% endif %}` balances, and the mark sits between the `</div>` that closes `.entry-body` and `</li>`), and Prettier's Liquid plugin parses the file without complaint, which catches a malformed tag. The real proof is plan 04-04's build and its 20 `--live` rows.
- **The note markup serves two sections from one loop.** `_pages/research.md` iterates `research` and `courses` through the same `{% for e in sorted %}`, so the mark is already available to every course entry. That is free reach, not scope creep — but Phase 5 should know the shape is already there rather than adding a second one.

## User Setup Required

None.

## Next Phase Readiness

**Plan 04-04 owns the phase's single deploy, and it is the only thing left.** Everything static is green: **59 checks, 0 failed**. The remaining work is the push, the `--live` run, and the batched human checkpoint.

**19 commits sit unpushed on `main`** (20 with this plan's metadata commit). `_sass/**`, `_data/**`, `_pages/**` and `purgecss.config.js` are all absent from `deploy.yml`'s `paths-ignore`, so these commits **will** deploy when 04-04 pushes.

**What 04-04 must check that nothing automated can:**

1. **The eight discretionary rules listed above.** That section exists for this checkpoint specifically.
2. **The breakout.** It is the one decision in this plan made from arithmetic rather than from a render, and it has a named fallback ready if it reads as a jump.
3. **The five manual rows in `04-VALIDATION.md`** — paint jank at 390px, texture at reading distance, stylesheet-off across all seven pages, ≤2 decorative marks per first viewport, greyscale-and-blur hierarchy — plus the two readings the 04-02 checkpoint asked for and did not get: **seams on a ~200px grid at 100% zoom**, and **whether 17px Literata stays crisp over the grain**. Both are still owed and 04-04's sweep is their named fallback.
4. **The three PurgeCSS survival rows.** `.entry-note`, `.entry-note-summary`, `.entry-note-full` and `.entry-note[open]` must all appear in the **served** `main.css`. Grep the served file, never the source — that is the standing rule and the `.topic-list` precedent is live proof of why.

**Carried forward, unchanged from 04-02:** every ink ratio comment in `_tokens.scss` is still a *flat*-ground figure while Phase 8 criterion 1 wants composited values. `--rule-500` was pulled forward and the rest were measured in passing (all AA), but the comments still quote flat numbers.

## Self-Check: PASSED

Files (all `FOUND`): `_sass/_custom.scss`, `_sass/_tokens.scss`, `_pages/research.md`, `_data/research.yml`, `purgecss.config.js`, `docs/NOTEBOOK-MARKS.md`, `.planning/phases/04-notebook-art-style/verify.sh`, `.planning/phases/04-notebook-art-style/04-03-SUMMARY.md`.

Commits (all `FOUND`): `7b21494`, `2e78bf8`, `e07b911`, `003e610`, `f85b274`.

Plan verification block, re-run at close:

- `bash .planning/phases/04-notebook-art-style/verify.sh` → **59 checks, 0 failed.** ✅
- `npx prettier _sass docs _data _pages purgecss.config.js --check --end-of-line auto` → all matched files use Prettier code style. ✅
- `node test/style_contract.js` → exit 0. ✅
- `grep -rnE 'content:[[:space:]]*"[^"]+"' _sass/` → no output. ✅
- `grep -rnE 'rotate\(|skew\(' _sass/` → no output. ✅
- `!important` in `_sass/_custom.scss` → three `//` comment lines only, no declaration; the harness's comment-exempt row is green. ✅
- `_sass/_custom.scss` carries no hex / `rem` / `px` / `em` / `color-mix` literal (harness row green). ✅
- `git status --short` → clean. `git log origin/main..HEAD` → **nothing pushed.** ✅

---

_Phase: 04-notebook-art-style_
_Completed: 2026-09-23_

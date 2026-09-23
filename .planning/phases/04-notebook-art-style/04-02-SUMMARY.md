---
phase: 04-notebook-art-style
plan: 02
subsystem: ui
tags: [design-tokens, svg-data-uri, feturbulence, wcag-1411, contrast, checkpoint, disclosure-widget]

# Dependency graph
requires:
  - phase: 02-tokens-and-ground
    provides: "`_sass/_tokens.scss` (the paper/ink/rule scale, the TOKEN-06 cap block, the named-measure section), `.planning/tools/contrast.js`"
  - phase: 03-typography
    provides: "`--measure: 36rem` and the ~354px prose gutter (which turns out NOT to reach the entry list), `--step-0` as the note's size"
  - phase: 04-notebook-art-style
    plan: 01
    provides: "`verify.sh`'s 04-02 rows and its two hex-reading helpers, `.planning/tools/texture-swatch.html` (the swatch the alpha was chosen from), `docs/NOTEBOOK-MARKS.md` (the cap of 4)"
provides:
  - "`--paper-texture` — a 414 B inline SVG data URI at alpha 0.06, pinned filter region, every unparameterisable value recorded in prose above it"
  - "The two composited grounds, re-derived at 0.06 and machine-readable: worst `#ebe7e0`, mean `#f3efe7`"
  - "`--rule-500` re-pointed `#9c8b6e` -> `#8d7b60`, 3.32:1 on the worst-case composited ground (was 2.69:1)"
  - "`--note-col: 13rem` — a CREATED margin column with its 900px arithmetic"
  - "The `notebook marks ..... 4` cap line, the second of the two places the number is stated"
  - "`04-VALIDATION.md` `## Checkpoint Verdicts` — the alpha, the B1 decision, the site owner's note prose verbatim, and the settled `note:` / `note_full:` data contract"
affects: [04-03, 04-04, 05-list-pages, 06-composition, 08-qa-audit]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "A comment must not quote the command that greps it: the measuring command for the data URI is deliberately NOT written out, because it would match itself and the byte-budget row takes the FIRST match"
    - "A perceptual token records WHO chose it, WHEN, and against WHAT — `opacity 0.06 ... chosen by eye on 2026-09-23 at plan 04-02's checkpoint`"
    - "A reading the checkpoint asked for and did not get is recorded as NOT SUPPLIED with a named fallback check, never back-filled"
    - "A stale ratio comment is UPDATED with its date and its old value kept in the sentence, not silently replaced"

key-files:
  created:
    - .planning/phases/04-notebook-art-style/04-02-SUMMARY.md
  modified:
    - _sass/_tokens.scss
    - .planning/phases/04-notebook-art-style/04-VALIDATION.md
    - .planning/phases/04-notebook-art-style/verify.sh

key-decisions:
  - "Alpha 0.06, chosen by a human at the swatch before the phase spent its single deploy; the seams and crispness readings were NOT SUPPLIED and are recorded as such, with 04-04's human sweep named as the fallback check"
  - "B1 accepted: --rule-500 -> #8d7b60. The old value was failing WCAG 1.4.11 on the LIVE Academics page before any texture shipped, so this repairs shipped work rather than only protecting the new section rule"
  - "The margin note becomes a TWO-STATE mark (native <details>/<summary>, no JavaScript) because the site owner's real prose is ~10x a margin note; the cap stays at 4 — one mark with two states, not a fifth mark"
  - "The expanded body breaks OUT of the margin column to the entry's width; 230 words at ~27 characters per line is ~50 lines and would break 04-03's non-overlap truth"
  - "`note:` (collapsed) and `note_full:` (expanded) settled here as the _data/research.yml contract, so 04-03 consumes a decision instead of making one"
  - "04-02-PLAN's own mean-composited literal #f7f3eb does not satisfy the formula the same block states; the formula was used, per the plan's own instruction"

patterns-established:
  - "Self-matching comments: before writing a grep pattern into a file the harness greps, check whether the harness would find the comment first. `head -1` makes the comment authoritative."
  - "A lifted constraint is annotated with its date and its superseded number, so a reader who remembers the old rule finds out it changed rather than concluding the file is wrong."

requirements-completed: []

# Metrics
duration: 36min
completed: 2026-09-23
---

# Phase 4 Plan 02: The Tier 1 Declarations Summary

**A 414-byte paper grain at a human-chosen alpha of 0.06, a structural rule colour re-pointed to clear 3:1 on the ground it will actually sit on rather than on flat paper, and the site owner's own research prose recorded verbatim — which turned the margin note into a two-state disclosure mark.**

## Performance

- **Duration:** ~36 min of execution across two sessions, separated by the blocking checkpoint
- **Started:** 2026-09-18T07:43:13Z (pre-checkpoint verification, then blocked)
- **Checkpoint answered:** 2026-09-23
- **Completed:** 2026-09-23T04:10:45Z
- **Tasks:** 2 of 2 (task 1 was the blocking checkpoint)
- **Files modified:** 3 (0 created in the repo; 1 summary created)

## Accomplishments

- **The alpha is a number a human looked at.** 0.06, chosen from `.planning/tools/texture-swatch.html` against 17px Literata, and recorded in the token comment with its date and its provenance. Not derived, not defaulted from 04-RESEARCH's 0.05.
- **The texture is one opaque token, 414 B — 20% of the 2,048 B budget.** Pinned filter region, `numOctaves='2'`, `stitchTiles='stitch'`, saturate 0. It decodes back to valid SVG with all eight required constructs.
- **A live WCAG failure was repaired, not inherited.** `--rule-500` was 2.69:1 against the composited ground at the chosen alpha — and 3.08:1 only against flat paper, which is the number Phase 2 signed off. `.subject` on Academics is an existing consumer, so the defect was already live. `#8d7b60` measures 3.32:1 worst case.
- **The site owner's words are on disk, verbatim, with a typo ledger.** Two entries, two collapsed summaries, two expanded bodies, and the twelve corrections listed so the owner can see exactly what changed in their prose.
- **The harness went 17 red → 9 red, 9 red-by-design, 0 UNLABELLED.** All eight `[red until plan 04-02]` rows are green and their labels were stripped in the same commit.

## The numbers the plan asked for

**The chosen alpha and its two derived grounds** (`round(channel * (1 - a))` on r=250 g=246 b=238):

| Quantity                              | Value         |
| ------------------------------------- | ------------- |
| alpha                                 | **0.06**      |
| mean composited ground (`a/2 = 0.03`) | **`#f3efe7`** |
| worst-case composited ground (`a`)    | **`#ebe7e0`** |

**Measured byte count of the data URI:** **414** as `wc -c` reports it (413 bytes of match plus grep's newline), against the 2,048 B budget.

**The B1/B2 answer and what followed:** **B1 — fix now.** `--rule-500` `#9c8b6e` → `#8d7b60`. Re-verified at 0.06 rather than inherited from the plan's 0.05 table:

| Colour               | flat `#faf6ee` | mean `#f3efe7`  | worst `#ebe7e0` |
| -------------------- | -------------- | --------------- | --------------- |
| `#9c8b6e` (was)      | 3.08:1         | **2.89:1 FAIL** | **2.69:1 FAIL** |
| `#8d7b60` (now)      | 3.79:1         | 3.57:1          | **3.32:1 pass** |

Side effect, recorded in-file: on the recess ground `--paper-200 #f2ebdd` the rule goes 2.80:1 → **3.45:1**, so Phase 2's standing "a structural hairline in the footer or a code block needs an ink, not a rule colour" is **lifted for `--rule-500`**. `--rule-200` is unchanged and stays decorative-only.

Every ink step survives the darker ground: `--ink-900` 13.89:1, `--ink-800` 12.15:1, `--ink-700` 9.63:1, `--ink-500` 6.11:1, `--accent-600` 5.44:1 — all AA.

**The note text and which entry it belongs to:** recorded verbatim in `04-VALIDATION.md` § C, not paraphrased here. Entry 1 (Attention Sinks) carries an **open question**; entry 2 (Echo Chambers) carries a **surprising result**. Both have a 1–2 sentence collapsed summary and a 3–4 paragraph expanded body.

**Readings the checkpoint asked for and did NOT get:** two.

1. **Seams on a ~200px grid at 100% zoom** — not supplied.
2. **Whether 17px Literata stayed crisp over the grain** — not supplied.

Both are recorded as *not supplied* in `04-VALIDATION.md` rather than invented, following the Phase 3 precedent. The fallback check for both is plan 04-04's human sweep. The structural defence against seams — the pinned filter region — is in the source regardless.

## Task Commits

1. **Task 1: The three answers only the site owner can give** — no commit (blocking checkpoint; the pre-checkpoint verification confirmed the swatch on disk and quoted both research entries back to the owner)
2. **Task 2, verdicts recorded first** — `8d29d98` (docs)
3. **Task 2, commit 1: the paper grain (GROUND-02)** — `76f14fe` (feat)
4. **Task 2, commit 2: the marks layer (GROUND-03)** — `4e1b815` (feat)

**Plan metadata:** see the final `docs(04-02)` commit.

## Files Created/Modified

- `_sass/_tokens.scss` (+130 lines) — `--paper-texture` with a 40-line parameter comment; the `notebook marks ..... 4` cap line and a paragraph on why four; `--note-col: 13rem` with its 900px arithmetic; `--rule-500` re-pointed with composited ratios; the recess-ground caveat updated with its date.
- `.planning/phases/04-notebook-art-style/04-VALIDATION.md` (+117 lines) — a `## Checkpoint Verdicts` section (A, B, C), the typo ledger, four downstream follow-ups, and a correction to the verification map's hardcoded `#eeeae2`.
- `.planning/phases/04-notebook-art-style/verify.sh` (16 lines changed) — the eight now-stale `[red until plan 04-02]` labels stripped. No matcher altered, no row added or removed.

## Decisions Made

- **The margin note is a two-state mark, and the cap stays at 4.** The owner supplied real prose ~10x longer than a margin note and chose a disclosure toggle over discarding it. Native `<details>`/`<summary>`, no JavaScript — which is what keeps 04-03's accessibility truths intact: readable with the stylesheet off, all text in the DOM for screen readers, no pseudo-element text. One mark with two states is not a fifth mark, and the token file now says so explicitly.
- **The expanded body breaks out of the margin column.** 230 words at ~27 characters per line is ~50 lines tall; inside a 208px column it would collide with the next note and break 04-03's "two consecutive notes cannot overlap" truth. Flagged in-file as an assumption for 04-04's human sweep, because it is arithmetic and not a render.
- **`note:` / `note_full:` settled here.** 04-03 gets a contract, not a decision. Both optional; `note:` alone renders a plain non-collapsing note; neither renders no mark.
- **The plan's own 0.05 mean literal is wrong and the formula won.** 04-02-PLAN states `#f7f3eb` as the mean at alpha 0.05, but `round(c * (1 - 0.025))` gives `#f4f0e8` (`#f7f3eb` is a uniform −3 per channel, roughly alpha 0.012). The plan's instruction — "use the formula, not the literals, if the chosen alpha differs" — settled it. The only consequence is that the plan's quoted "mean" ratios were measured against a ground lighter than its own formula produces, so the case for B1 was slightly stronger than the table showed.
- **REQUIREMENTS.md is deliberately untouched.** GROUND-02 and GROUND-03 stay `Pending`. This plan writes tokens that no rule consumes yet — nine harness rows are still `[red until plan 04-03]`, and nothing is proven against the served CSS until 04-04's deploy. Marking them now would put REQUIREMENTS.md in disagreement with `verify.sh`, the mistake 03-02 made and reverted by hand. Fourth consecutive deliberate refusal; the convention holds.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] The comment would have matched the harness's own byte-budget grep**

- **Found during:** Task 2, commit 1 (drafting the `--paper-texture` comment block)
- **Issue:** The plan instructs that the measured byte count be put in the comment and gives the measuring command to produce it. Writing that command out inside `_sass/_tokens.scss` makes the comment itself match `grep -o 'url("data:image/svg+xml,[^"]*"'`. `texture_uri_bytes()` takes `head -1`, and the comment sits **above** the declaration — so the harness would have measured a ~27-byte fragment of prose, passed both the non-empty and the under-2,048 clauses, and gone on passing no matter how large the real URI grew. Precisely the Phase 2 lesson ("a comment must not spell out a string a matcher asserts") in its opposite direction: here the comment would have *satisfied* the matcher.
- **Fix:** The command is described, not quoted, and the comment says why in-file so the next editor does not "helpfully" paste it back in.
- **Files modified:** `_sass/_tokens.scss`
- **Verification:** `grep -o 'url("data:image/svg+xml,[^"]*"' _sass/_tokens.scss | wc -l` → **1** match, and `wc -c` → **414**, which is the real declaration.
- **Committed in:** `76f14fe`

**2. [Rule 1 - Bug] The recess-ground ratio comment became wrong the moment `--rule-500` moved**

- **Found during:** Task 2, commit 2
- **Issue:** `_tokens.scss` carried "On that recess ground `--rule-500` drops to 2.80:1 ... so a structural hairline inside the footer or a code block needs an ink, not a rule colour." That figure is for `#9c8b6e`. After B1 it is stale, and it is a *standing instruction* recorded in STATE.md as a trap — leaving it would have made a later phase avoid a rule colour that now clears the floor.
- **Fix:** Re-measured (`#8d7b60` on `#f2ebdd` = **3.45:1**) and the paragraph updated with its date, keeping the old number in the sentence rather than deleting it. The constraint is recorded as *lifted for `--rule-500`*; `--rule-200` is unchanged at 1.30:1 and stays decorative-only.
- **Files modified:** `_sass/_tokens.scss`
- **Verification:** `node .planning/tools/contrast.js "#8d7b60" "#f2ebdd"` → 3.45:1.
- **Committed in:** `4e1b815`

**3. [Rule 2 - Missing Critical] Eight `[red until plan 04-02]` labels left on rows this plan turned green**

- **Found during:** Task 2, after commit 2's edits
- **Issue:** `verify.sh` is not in this plan's `files_modified`, but note (a) of the harness — and 04-01's own deviation 2 — make label-stripping part of the commit that turns a row green. A label on a **green** row is counted into `EXPECTED_RED` the day it regresses, which silently reclassifies a real regression as pending work. The plan's own verification block also requires that the remaining reds be labelled 04-03 or 04-04.
- **Fix:** Stripped the label from the eight `check` lines now green. No matcher was altered, no row added or removed. Line 101's header prose quotes the label while explaining note (e) and was deliberately left alone — nothing greps that phrase, the same call 04-01 made.
- **Files modified:** `.planning/phases/04-notebook-art-style/verify.sh`
- **Verification:** `grep -cE '^[[:space:]]*check .*red until plan 04-02' verify.sh` → **0**; harness prints 53 checks, 9 failed, 9 red-by-design, **0 UNLABELLED**.
- **Committed in:** `4e1b815`

**4. [Rule 2 - Missing Critical] Four harness rows are contradicted by the two-state decision, and were recorded rather than edited**

- **Found during:** Task 2 (reading the harness after answer C landed)
- **Issue:** `verify.sh` asserts `<aside class="entry-note">` in `_pages/research.md` and in the served HTML, that the aside follows its `.entry-body`, and that `.entry-note::before` carries an empty `content` string. A `<details>`/`<summary>` mark satisfies none of them as written. All four are currently red-by-design, so at 04-03 they would read as pending work rather than as a stale matcher.
- **Fix:** **Not** edited here — 04-03 owns the markup that decides the replacement matcher, and narrowing a row before the markup exists is guessing. Recorded as follow-up 4 in `04-VALIDATION.md` with the standing rule attached (narrow or re-point in the same commit as the markup; never delete), and with a note that the `::before` row is load-bearing for GROUND-05.
- **Files modified:** `.planning/phases/04-notebook-art-style/04-VALIDATION.md`
- **Verification:** The follow-up is item 4 under "Downstream follow-ups created by answer C".
- **Committed in:** `4e1b815`

**5. [Scope - owner decision] The margin note grew a second state**

- **Found during:** Task 1 (the checkpoint answer itself)
- **Issue:** Answer C is a scope change to work planned in 04-03, not a defect. The owner's prose is ~10x a margin note.
- **Fix:** Nothing implemented in this plan. Three downstream follow-ups recorded (amend 04-03; update the margin-note defence sentence in `docs/NOTEBOOK-MARKS.md` in place, since exactly four are asserted; two data keys instead of one), plus the settled `note:` / `note_full:` contract. `_data/research.yml`, `_pages/research.md`, `_sass/_custom.scss` and `purgecss.config.js` were **not** touched — `git status` confirms.
- **Files modified:** `.planning/phases/04-notebook-art-style/04-VALIDATION.md`
- **Verification:** `git status --short -- _data _pages _sass/_custom.scss purgecss.config.js _config.yml` → empty.
- **Committed in:** `8d29d98` and `4e1b815`

---

**Total deviations:** 5 — 2 bug fixes, 2 missing-critical (one fixed, one deliberately recorded rather than fixed), 1 owner-driven scope change.
**Impact on plan:** No scope creep. Deviations 1 and 3 protect harness rows that would otherwise have passed while measuring nothing; deviation 2 removes a stale instruction; deviation 4 hands 04-03 a trap it would otherwise have hit at the worst moment. The only file touched outside `files_modified` is `verify.sh`, and only to strip labels.

## Issues Encountered

- **The large quoted heredoc failed again, exactly as STATE.md records.** `cat > file <<'EOF'` with ~120 lines of prose died with `unexpected EOF while looking for matching '`. The `Write` tool produced the same file without complaint, and splicing it into `04-VALIDATION.md` with `head`/`cat`/`tail` worked. Short heredocs (the commit messages, ~20 lines) were fine. Refined rule: **quoted heredocs are reliable for commit messages and short files; use the `Write` tool above roughly 50 lines of prose.**
- **`node -e` with an inline script silently produced NO output** — no error, exit 0, nothing on stdout. Same class of failure STATE.md records for inline interpreters, but a new symptom: previously it errored, here it succeeded silently, which is worse. Every node check in this plan was written to a file in the session scratchpad and run as `node <file>`. Verbatim scripts, not weakened ones.
- **`npx prettier` prints npm's upgrade notice to the same stream**, which swallowed the result on first run. Filtered with `grep -viE '^npm notice'` and read `PIPESTATUS[0]` for the real exit code.
- **The 04-01 summary said "9 of the 17 remaining reds are `[red until plan 04-02]`"; there are eight.** The harness went 17 → 9 failed, and `grep -c` on the label finds 8 check lines. Off by one in the prose, not in the harness.

## User Setup Required

None.

## Next Phase Readiness

**Plan 04-03 can start, but its plan needs amending first — see the four follow-ups in `04-VALIDATION.md` § "Downstream follow-ups created by answer C".** It is no longer the plan that was written: the margin note is a two-state `<details>` mark, the data file needs two keys per entry, and four harness rows describe the superseded markup.

Everything 04-03 consumes is on disk:

- `--paper-texture`, `--note-col`, `--rule-500` and the cap line in `_sass/_tokens.scss`.
- The site owner's collapsed and expanded prose, verbatim, in `04-VALIDATION.md` § C. **Ship it from there.** It is the owner's own words and a paraphrase is a corruption of them; the typo ledger records every change already made.
- The settled `note:` / `note_full:` contract.

**Three things 04-03 must not get wrong:**

1. **PurgeCSS eats anything not in the safelist.** `.entry-note` already has a red row for it; any new class the two-state mark introduces needs its own entry, or the rule is correct in source and absent from production — the focus-ring failure, repeated.
2. **The `::before` row is load-bearing for GROUND-05.** Whatever replaces it must still prove no pseudo-element carries announceable text. Narrow it; do not drop it.
3. **`--rule-500` moved.** Any figure quoted from a pre-04-02 document (3.08:1, `#9c8b6e`, "a hairline in the footer needs an ink") is stale. The token file carries the current numbers and the date they changed.

**Carried forward:** every remaining ink ratio in `_tokens.scss` is still a *flat*-ground figure, and Phase 8 criterion 1 wants composited values. This plan pulled the `--rule-500` case forward and measured the rest against `#ebe7e0` in passing (all AA) — but the comments beside `--ink-*` still quote flat numbers, and that is still owed.

**Nothing is pushed.** 13 commits sit unpushed on `main`; plan 04-04 owns the phase's single deploy.

## Self-Check: PASSED

Files (all `FOUND`): `_sass/_tokens.scss`, `.planning/phases/04-notebook-art-style/04-VALIDATION.md`, `.planning/phases/04-notebook-art-style/verify.sh`, `.planning/phases/04-notebook-art-style/04-02-SUMMARY.md`.

Commits (all `FOUND`): `8d29d98`, `76f14fe`, `4e1b815`.

Plan verification block, re-run at close:

- `bash .planning/phases/04-notebook-art-style/verify.sh` → 53 checks, **9 failed, 9 red-by-design, 0 UNLABELLED**, exit 1 (correct: all nine are `[red until plan 04-03]`). Every GROUND-02 token row, the cap row and both `--rule-500` rows are green.
- `node .planning/tools/contrast.js "#8d7b60" "#ebe7e0"` → **3.32:1**, clears the 3.0 floor. ✅
- `node .planning/tools/contrast.js --selftest` → 8 pairs, 0 failed. ✅
- Decoded data URI is valid SVG and contains `url(#t)`, `stitchTiles="stitch"` and the pinned `x="0" y="0"` region — all eight required constructs. ✅
- `npx prettier _sass docs _data _pages purgecss.config.js --check --end-of-line auto` → all matched files use Prettier code style. ✅
- `node test/style_contract.js` → exit 0. ✅
- `git status --short -- _data _pages _sass/_custom.scss purgecss.config.js _config.yml` → empty. ✅
- `git log origin/main..HEAD` → 13 commits, **nothing pushed**. ✅

---

_Phase: 04-notebook-art-style_
_Completed: 2026-09-23_

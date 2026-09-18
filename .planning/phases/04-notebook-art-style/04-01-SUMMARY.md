---
phase: 04-notebook-art-style
plan: 01
subsystem: infra
tags: [bash-harness, feturbulence, svg-data-uri, wcag-contrast, design-vocabulary, purgecss]

# Dependency graph
requires:
  - phase: 02-tokens-and-ground
    provides: "`_sass/_tokens.scss` (the paper/ink/rule scale and the TOKEN-06 cap form), `.planning/tools/contrast.js`, `purgecss.config.js` and its safelist"
  - phase: 03-typography
    provides: "`verify.sh`'s red-by-design shape and `check()` tally, `--measure: 36rem` and the ~354px gutter the margin note occupies, the Literata/Be Vietnam Pro fonts URL"
provides:
  - "`.planning/phases/04-notebook-art-style/verify.sh` — 53 static rows + a 20-row `--live` block; 17 red-by-design, 0 unlabelled"
  - "`.planning/tools/texture-swatch.html` — a flat control plus alpha 0.035 / 0.05 / 0.06 / 0.07, with a 390px panel, for plan 04-02's checkpoint"
  - "`docs/NOTEBOOK-MARKS.md` — criterion 2's deliverable: four marks, four `Defence:` lines, the cliche blocklist, three recorded non-decisions, two named fallbacks"
  - "`04-VALIDATION.md` `wave_0_complete: true`"
affects: [04-02, 04-03, 04-04, 05-list-pages, 06-composition, 08-qa-audit]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "A green harness row carries NO `[red until plan NN]` label — labels are stripped in the same commit that turns the row green"
    - "Narrow a gate's matcher and write down why; never delete the row"
    - "A perceptual decision is printed as a small set of candidates in a static HTML file and chosen by eye before any deploy"

key-files:
  created:
    - .planning/phases/04-notebook-art-style/verify.sh
    - .planning/tools/texture-swatch.html
    - docs/NOTEBOOK-MARKS.md
  modified:
    - .planning/phases/04-notebook-art-style/04-VALIDATION.md

key-decisions:
  - "The mark vocabulary is capped at FOUR and the number is stated in two places — this document and (from 04-02) `_sass/_tokens.scss` — so a fifth mark means visibly editing a stated number twice"
  - "Further Reading and CV carry NO mark at all, recorded as a decision rather than left to read as a miss: neither page has an `h2`, so scoping the section rule to `.entry-group-title` reaches three of seven pages by design"
  - "The annotation bracket is `--rule-200` at 1.43:1 and that is argued, not overlooked: WCAG 1.4.11's 3:1 floor covers graphics NEEDED to understand content, and the bracket is meaningless on its own"
  - "Four candidate alphas offered (0.035, 0.05, 0.06, 0.07) with a flat control; 04-RESEARCH's 0.05 is a candidate on equal footing, not a default"
  - "`custom_has_no_literals` cannot see a leaked data URI (no bare `#`/`rem`/`px`/`em`), so texture placement in `_tokens.scss` got its own explicit harness row"
  - "The `content:` matcher is narrowed to non-empty QUOTED strings — `grep -rn 'content:'` matches the correct `justify-content: space-between` at `_custom.scss:116`"

patterns-established:
  - "Label direction: a red label means 'not true yet', never 'do not worry about this'. Stripping happens at the commit that delivers the row."
  - "Criterion-5-style blocklists live in the SAME document as the allowed list, because splitting them is how the forbidden half gets forgotten."
  - "A non-mark is recorded as a decision with its consequence stated plainly, so a later phase's screenshot count does not read it as a defect."

requirements-completed: []

# Metrics
duration: 77min
completed: 2026-09-18
---

# Phase 4 Plan 01: Wave 0 — Harness, Swatch, Vocabulary Summary

**A 53-row red-by-design phase harness, a five-panel browser swatch that turns "barely perceptible" into a choice among four printed alphas, and `docs/NOTEBOOK-MARKS.md` — the written contract plans 04-02 and 04-03 implement against.**

## Performance

- **Duration:** 77 min wall clock (13:22:04 → 14:39:19 local; task 1 landed in an earlier session and this run resumed at task 2)
- **Started:** 2026-09-18T06:22:04Z
- **Completed:** 2026-09-18T07:39:19Z
- **Tasks:** 3 of 3
- **Files modified:** 4 (3 created, 1 modified)

## Accomplishments

- **The harness can tell "not true yet" from "broken".** 53 static rows and a 20-row `--live` block. It went 33 red → **17 red, 17 red-by-design, 0 UNLABELLED** when task 3 landed. Every remaining red row names the plan that makes it true (04-02, 04-03 or 04-04). No site file changed to get there.
- **The phase's one perceptual decision is now a choice among visible candidates.** `.planning/tools/texture-swatch.html` prints a flat control and four alphas at ≥400px each, every panel carrying real 17px Literata body copy, a 30.6px Literata 600 heading and Vietnamese diacritics, plus a 390px-wide panel because CONTEXT locks the texture as identical on a phone with no breakpoint and no reduced variant. It opens by double-clicking — no Ruby, no `bundle`, no build.
- **Criterion 2's artefact exists before the CSS it constrains.** Four marks, four defence sentences, the eleven-item cliche blocklist, three non-marks recorded as decisions, and two fallbacks chosen in writing while nothing is at stake.
- **The two unmarked pages are named.** Further Reading and CV will carry ground, type and texture and no mark whatsoever. Written down so Phase 8's screenshot count reads it as zero-by-design.

## Task Commits

1. **Task 1: The phase harness** — `3c77f35` (chore)
2. **Task 2: The texture swatch** — `21865c9` (chore)
3. **Task 3: `docs/NOTEBOOK-MARKS.md`** — `4dbe8b8` (docs)

**Plan metadata:** see the final `docs(04-01)` commit.

## Files Created/Modified

- `.planning/phases/04-notebook-art-style/verify.sh` (481 lines, 26,430 B) — `set -uo pipefail` (never `-e`), `LIVE=0` / `--live`, `CHECKS` / `FAILED` / `EXPECTED_RED`, the `check <label> <expr>` function whose `case` arm increments `EXPECTED_RED` only when a **labelled row fails**, an `UNLABELLED` line when `FAILED - EXPECTED_RED > 0`, and `[ "$FAILED" -eq 0 ]` as the exit. No npm script, no test framework, `package.json` untouched.
- `.planning/tools/texture-swatch.html` (345 lines, 16,011 B) — five panels, five distinct filter ids, no JS.
- `docs/NOTEBOOK-MARKS.md` (14,378 B) — six sections; passes `npx prettier docs/NOTEBOOK-MARKS.md --check --end-of-line auto`.
- `.planning/phases/04-notebook-art-style/04-VALIDATION.md` — `wave_0_complete: true`, all five Wave 0 checklist items ticked with a provenance note each.

## The numbers the plan asked for

**Row count and the red/labelled split.**

| When                        | Checks | Failed | Red-by-design | Unlabelled |
| --------------------------- | ------ | ------ | ------------- | ---------- |
| After task 1 (`3c77f35`)    | 53     | 33     | 33            | 0          |
| After task 3 (`4dbe8b8`)    | 53     | 17     | 17            | 0          |

`--live` adds 20 more rows, all `[red until plan 04-04]` except the seven page-200 rows, which are unlabelled green.

The 16 rows that went green are exactly the vocabulary-document rows: the file exists, the four mark names, the exactly-four `Defence:` count, and the ten blocklist terms. Their labels were stripped in the same commit, per the harness's own note (a).

**The four candidate alphas offered.** `0.035`, `0.05`, `0.06`, `0.07`, against a flat `#faf6ee` control. `0.05` is 04-RESEARCH's printed value and is deliberately presented as a candidate on equal footing rather than as a default — the whole reason the swatch exists is that 0.05 was chosen from a description.

**Matchers narrowed, with reasons** (the standing rule is narrow the matcher, never delete the row):

1. **`content:` → non-empty quoted strings only.** `grep -rn 'content:' _sass/` matches `justify-content: space-between` at `_custom.scss:116`, a real and correct declaration. The row asserts the far narrower thing GROUND-05 needs: `! grep -rnE 'content:[[:space:]]*"[^"]+"' _sass/` — no pseudo-element carries *announceable* text. This is the **sixth** instance of the rule. Do not widen it back.
2. **`--paper-texture` matchers are whitespace-tolerant.** Dart Sass `--style=compressed` preserves custom-property values untouched, including the space after the colon, so every matcher uses `[[:space:]]*` exactly as the Phase 3 harness already does for `calc()`.
3. **The data-URI byte-budget row was strengthened, not loosened.** `wc -c` on an empty `grep -o` result returns 0, which is `< 2048` — the row would have passed with no texture at all. It now requires a non-empty match as well (harness note (e)).

**One row that exists because an inherited helper is blind.** `custom_has_no_literals` looks for `#` / `rem` / `px` / `em`; a percent-encoded SVG in `_custom.scss` contains none of those in a form it recognises, so a leaked data URI would sail past it. Texture placement in `_tokens.scss` therefore has its own explicit row (harness note (c)).

## Decisions Made

- **The cap is four, stated in two places.** Section 1 of `NOTEBOOK-MARKS.md` and (from 04-02) the TOKEN-06 cap block in `_sass/_tokens.scss`. Adding a fifth mark means visibly editing a stated number twice, and writing a fifth `Defence:` line — which turns harness row 12 red, because it asserts **exactly** four, not at least four.
- **The link underline is listed as a mark even though Phase 2 shipped it and this phase changes nothing about it.** A mark on the site but absent from the vocabulary is a leftover, and leftovers are how a four-mark vocabulary becomes a six-mark one without anyone deciding to.
- **The annotation bracket's 1.43:1 is defended, not hidden.** WCAG 1.4.11's 3:1 floor applies to graphical objects *needed to understand content*; the bracket is meaningless on its own and the note is fully understandable without it. Written down so a reviewer finds an argument rather than an omission.
- **Three non-marks recorded as decisions:** no hand-drawn mark (offered to the site owner and declined; do not reintroduce without reopening that section), the section rule reaching three of seven pages (scoping to `h2` would reach five and pull in the home page, which Phase 6 owns), and no rule on `pre`/`code` or in the footer (no page renders either, and the footer already shows the body ground — a rule would be dead source, the same thing Phase 3 refused to write for the monospace family).
- **Both fallbacks chosen now, in writing.** Drop the marks and keep ground and type (the roadmap's own Phase 3 stop-state); and if iOS Safari degrades the tile, drop to the flat ground rather than reaching for a raster tile. Dialling marks quieter was considered and rejected: a quiet bad mark is still a bad mark.
- **REQUIREMENTS.md is deliberately untouched.** GROUND-02, GROUND-03 and GROUND-05 stay `Pending`. This plan writes no site CSS and no content; the rows backing all three are still red until 04-02/03 and are only proven on 04-04's deploy. Marking them now would put REQUIREMENTS.md in disagreement with `verify.sh` — the mistake 03-02 made and reverted by hand. A plan's `requirements:` field means "contributes to", not "completes".

## Deviations from Plan

### 1. [Sequencing] `wave_0_complete: true` set at task 3, not task 1

- **Found during:** Task 1 (in the earlier session) and closed at task 3.
- **Issue:** The plan puts "set `wave_0_complete: true`" at the end of task 1's action, but two of the five Wave 0 checklist items in `04-VALIDATION.md` (the swatch and `NOTEBOOK-MARKS.md`) are delivered by tasks 2 and 3. Setting the flag at task 1 would have claimed Wave 0 complete with two of its artefacts missing.
- **Fix:** Task 1 ticked the two items it actually delivered (the harness; no framework install) and left the flag `false`. Task 3's commit sets `wave_0_complete: true` and ticks the remaining three.
- **Files modified:** `.planning/phases/04-notebook-art-style/04-VALIDATION.md`
- **Verification:** All five Wave 0 items are `[x]` with a provenance note each; `nyquist_compliant:` left `false` for plan 04-04 as instructed.
- **Committed in:** `4dbe8b8`

### 2. [Note (a) compliance] The 16 now-green `[red until plan 04-01]` labels stripped

- **Found during:** Task 3.
- **Issue:** Rows 10–13 were written carrying `[red until plan 04-01]` because task 1's commit preceded task 3's document. Once the document existed, those 16 rows were green **and labelled** — which is precisely what the harness's own note (a) forbids, since a label on a green row absorbs a future regression into the expected-red count.
- **Fix:** Stripped the label from all five label-bearing source sites (two are `for` loops generating 14 of the 16 rows). The prose explanation in the header comment keeps its quoted `[red until plan 04-01]` and was deliberately left alone — Phase 2's lesson that a comment must not spell out a string a matcher asserts is absent does not apply here, because no matcher greps that phrase.
- **Files modified:** `.planning/phases/04-notebook-art-style/verify.sh`
- **Verification:** `grep -cE '^[[:space:]]*check .*\[red until plan 04-01' verify.sh` → 0; harness prints 17 failed / 17 red-by-design / 0 UNLABELLED.
- **Committed in:** `4dbe8b8`

---

**Total deviations:** 2, neither a code fix. No scope creep; no site file was touched.

## Issues Encountered

- **The task-2 verifier could not be run as a single-line `node -e` in this shell.** The inline script mangled on the way through (`'ids' is not recognized as an internal or external command`), the same class of quoting failure STATE.md already records for inline interpreters. Written to a file in the session scratchpad and run as `node <file>` instead; it passes verbatim: `ok: alphas 0.05 0.035 0.06 0.07 | ids t50m t35 t50 t60 t70`. The verifier itself was not weakened.
- **`python -c` works where an inline `python - <<'PY'` heredoc is refused.** Used for the one structured edit to `04-VALIDATION.md`. Worth knowing: the refusal recorded in STATE.md is about the heredoc form specifically, not about Python.
- **Prettier reflowed `docs/NOTEBOOK-MARKS.md` on first `--write`** (table padding, list spacing). Every load-bearing construct was re-read afterwards per the standing `**`-glob hazard: the four `Defence:` lines are still at column 0, the blocklist's `grep -rnE 'rotate\(|skew\(' _sass/` survived intact inside inline code, and no stray backslash was inserted. No `**`-terminated glob was placed inside a bold span in the first place.

## User Setup Required

None.

## Next Phase Readiness

**Plan 04-02 can start immediately, and its first task is blocking.** Everything it needs is on disk:

- The swatch to put in front of the site owner: `C:\Users\Admin\Documents\phkc_portfolio\phamhakhanhchi.github.io\.planning\tools\texture-swatch.html` — double-click, no server.
- The vocabulary it implements against: `docs/NOTEBOOK-MARKS.md`.
- The rows it must turn green: 9 of the 17 remaining reds are `[red until plan 04-02]`.

**Three things 04-02 must not get wrong:**

1. **The alpha chosen at the checkpoint is transcribed into `--paper-texture`, and the composited ground is written into the token's comment block as `worst-case composited ground: #xxxxxx`.** Harness row 17 `sed`s that hex out and feeds it to `contrast.js`. Do not hardcode `#eeeae2` — it is only correct for alpha 0.05.
2. **`--rule-500`'s binding requirement is the measured ratio (≥ 3.0 on the composited ground), not the literal `#8d7b60`** that row 16 currently greps for. The checkpoint may choose a different hex; row 16's in-row comment says so.
3. **The cap line must read `notebook marks ...... 4`** in the `_tokens.scss` cap block (row 14 greps `notebook marks[ .]+4`).

**Carried forward, unchanged:** every ink ratio in `_tokens.scss` was measured against flat `#faf6ee` and the texture composites over it — Phase 8 criterion 1 demands composited values; 04-02 pulls the `--rule-500` case forward and the rest is still owed. A focus ring over texture is visually destroyed even at a passing computed ratio, which is part of why the 2px width and 2px offset shipped.

**Nothing is pushed.** Nine commits sit unpushed on `main`; the phase spends its single deploy in plan 04-04.

## Self-Check: PASSED

Files (all `FOUND`): `.planning/phases/04-notebook-art-style/verify.sh`, `.planning/tools/texture-swatch.html`, `docs/NOTEBOOK-MARKS.md`, `.planning/phases/04-notebook-art-style/04-VALIDATION.md`.

Commits (all `FOUND`): `3c77f35`, `21865c9`, `4dbe8b8`.

Plan verification block, re-run at close:

- `bash .planning/phases/04-notebook-art-style/verify.sh` → 53 checks, 17 failed, 17 red-by-design, **0 UNLABELLED**, exit 1 (correct: work for 04-02/03/04 is not done).
- Rows 10–13 green, labels stripped. ✅
- `npx prettier _sass docs _data _pages purgecss.config.js --check --end-of-line auto` → all matched files use Prettier code style. ✅
- `node test/style_contract.js` → exit 0. ✅
- `node .planning/tools/contrast.js --selftest` → 8 pairs, 0 failed. ✅
- `git diff --name-only 3c77f35 HEAD -- _sass _data _pages _config.yml purgecss.config.js` → 0 files. ✅
- `git status --short` → clean; `git log origin/main..HEAD` → 9 commits, nothing pushed. ✅

---

_Phase: 04-notebook-art-style_
_Completed: 2026-09-18_

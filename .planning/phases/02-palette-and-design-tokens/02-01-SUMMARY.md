---
phase: 02-palette-and-design-tokens
plan: 01
subsystem: testing
tags: [wcag, contrast, design-tokens, shell-harness, nodejs, verification]

# Dependency graph
requires:
  - phase: 01-deployment-guardrails
    provides: "The verify.sh harness shape (flat `check` rows, `set -uo pipefail`, `--live` flag, EXPECTED_RED tally); the proven deploy path that makes the served CSS a trustworthy source of ground truth; the retained `--deploy-proof` canary"
provides:
  - ".planning/tools/contrast.js — zero-dependency WCAG 2.x contrast CLI with a --selftest that reproduces all eight PITFALLS.md figures"
  - ".planning/phases/02-palette-and-design-tokens/verify.sh — 79 static + 16 live check rows covering TOKEN-01..06, GROUND-04 and criteria 1-5"
  - "The authoritative 30-name --global-* token list, read off the served stylesheet on 2026-09-14"
  - "A CLAUDE.md note that stops a future agent deleting _sass/_tokens.scss as a contract violation"
affects: [02-02, 02-03, 02-04, 03-typography, 07-mobile-print, 08-qa-audit]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Wave 0 verification infrastructure written BEFORE the change it verifies, so pending criteria are visibly red rather than absent"
    - "Ground truth read off the deployed artifact, not copied from a planning document"
    - "Zero-dependency Node tooling under .planning/tools/ — no npm script, no package.json change, no test framework"

key-files:
  created:
    - .planning/tools/contrast.js
    - .planning/phases/02-palette-and-design-tokens/verify.sh
  modified:
    - CLAUDE.md

key-decisions:
  - "The 30 --global-* token names are recorded in verify.sh from the served main.css, confirming 30 and not the 29 that ROADMAP, STACK and 02-CONTEXT all record."
  - "contrast.js gained a --selftest flag beyond the research listing, turning 'the tool is correct' into a check row instead of a claim."
  - "The .al-folio-overrides.yml hash row is deliberately NOT labelled red-by-design: it is green today, so labelling it would let a real 02-02 regression be absorbed into the EXPECTED_RED tally."
  - "The 13 gem-partial rows were unrolled from a loop into flat check rows to match Phase 1's flat-list convention; the 30 token rows stay a loop over the ground-truth array."
  - "The CLAUDE.md reconciliation is additive only (10 insertions, 0 deletions). AGENTS.md, docs/ARCHITECTURE.md and docs/BOUNDARIES.md are explicitly out of scope for Phase 2."

patterns-established:
  - "Red-by-design rows: a criterion that is not yet true stays in the harness labelled [red until plan 02-NN] and is counted in EXPECTED_RED. Deleting a row to get a clean tally is forbidden."
  - "Unlabelled-failure tally: the harness now prints FAILED minus EXPECTED_RED separately, so a real regression cannot hide among pending work."
  - "Live rows compare the served asset against the LOCAL source (e.g. the --deploy-proof date) rather than a hardcoded value, so they keep working after a later re-date."

requirements-contributed: [TOKEN-01, TOKEN-03, TOKEN-06]  # verification only — completion lands in 02-02/03/04; see Pending Todos in STATE.md
requirements-completed: []

# Metrics
duration: 5min
completed: 2026-09-14
---

# Phase 2 Plan 01: Verification Infrastructure Summary

**A zero-dependency WCAG contrast CLI that self-tests against eight pre-measured figures, plus a 95-row verify.sh harness carrying the 30 `--global-*` token names read off the live stylesheet — 59 rows deliberately red until plans 02-02..04 land.**

## Performance

- **Duration:** 5 min
- **Started:** 2026-09-14T03:10:46Z
- **Completed:** 2026-09-14T03:15:35Z
- **Tasks:** 3
- **Files modified:** 3 (2 created, 1 modified)

## Accomplishments

- **Every `<automated>` command in plans 02-02, 02-03 and 02-04 now has a tool that exists.** Before this plan, three of 02-RESEARCH.md's Wave 0 gaps were open and criterion 4 ("each measure at least 4.5:1") degraded to manual DevTools work.
- **The 30-token count is settled from evidence.** `curl` on the served `main.css` returned exactly 30 distinct `--global-*` names, confirming 02-RESEARCH.md Pitfall 2 and falsifying the 29 recorded in ROADMAP.md, STACK.md and 02-CONTEXT.md. The gem's dark block has 29 because it omits `--global-highlight-color`; that number got copied forward. One check row per name means a missed token names itself instead of silently staying purple.
- **The contrast tool reproduces all eight published figures to within 0.01**, so the palette needs no re-measurement — and `--selftest` makes that a check row rather than a claim.
- **`#d9cfba` on `#faf6ee` confirmed at 1.43:1 FAIL**, independently verifying that `--rule-200` is decorative-only and must never carry text or a structural separator that needs to be seen.
- **A future agent reading CLAUDE.md will not delete `_sass/_tokens.scss`.** This phase is the first to create a *new* file under `_sass/`, a path both `AGENTS.md` and `CLAUDE.md` still call forbidden.

## Task Commits

Each task was committed atomically:

1. **Task 1: Zero-dependency WCAG contrast tool with `--selftest`** — `f8dc251` (chore)
2. **Task 2: 30-token ground truth extraction and the verify.sh harness** — `638ee5f` (chore)
3. **Task 3: CLAUDE.md fork note — this fork owns `_sass/`** — `33e74ca` (docs)

**Plan metadata:** see final commit below.

## Files Created/Modified

- `.planning/tools/contrast.js` (105 lines) — WCAG 2.x relative luminance (`0.03928` / `12.92` / `2.4` gamma, `0.2126/0.7152/0.0722`), `ratio(a,b)` as `(hi+0.05)/(lo+0.05)`, 3-digit hex expansion, CLI over `process.argv.slice(2)` in pairs, plus `--selftest` asserting eight pairs to a 0.01 tolerance and exiting non-zero on drift. Zero dependencies. Added hex validation so a typo throws instead of silently computing `NaN`.
- `.planning/phases/02-palette-and-design-tokens/verify.sh` (438 lines, 49 flat `check` rows expanding to 79 static / 95 with `--live`) — the phase harness, plus the `GLOBAL_TOKENS` ground-truth array and a header block naming the three manual-only criteria.
- `CLAUDE.md` (+10 lines, −0) — `## This fork: the stop sign is disabled`, placed immediately after the intro paragraph that calls `AGENTS.md` authoritative.

## The 30 `--global-*` token names

Read off `https://phamhakhanhchi.com/assets/css/main.css?cb=<epoch>` on **2026-09-14** via
`grep -o -- '--global-[a-z0-9-]*' | sort -u`. Count: **30**. Recorded verbatim in `verify.sh`'s `GLOBAL_TOKENS` array.

```
--global-back-to-top-bg-color      --global-hover-color
--global-back-to-top-text-color    --global-hover-text-color
--global-bg-color                  --global-newsletter-bg-color
--global-card-bg-color             --global-newsletter-text-color
--global-code-bg-color             --global-text-color
--global-danger-block              --global-text-color-light
--global-danger-block-bg           --global-theme-color
--global-danger-block-text         --global-tip-block
--global-danger-block-title        --global-tip-block-bg
--global-distill-app-color         --global-tip-block-text
--global-divider-color             --global-tip-block-title
--global-footer-bg-color           --global-warning-block
--global-footer-link-color         --global-warning-block-bg
--global-footer-text-color         --global-warning-block-text
--global-highlight-color           --global-warning-block-title
```

If a re-run of that `curl` ever returns a different count, the `al_folio_core` pin has moved off 1.0.15 and 02-RESEARCH.md's token inventory needs re-reading before the array is edited.

## Harness state at hand-off

| Block | Rows | Failed | All failures labelled? |
| ----- | ---- | ------ | ---------------------- |
| Static | 79 | 59 | Yes — 0 unlabelled |
| Static + `--live` | 95 | 66 | Yes — 0 unlabelled |

Green on day one: the 13 no-shadowed-gem-partial rows, the `--deploy-proof` canary, the overrides-hash row, the `outline: none` negative assertion, the `#5c5349` contrast row, `node test/style_contract.js`, Prettier, and the contrast self-test. All seven live pages already return 200, and the served CSS already carries the current `--deploy-proof` date.

## Decisions Made

- **The overrides-hash row is not red-by-design.** `.al-folio-overrides.yml`'s `local_sha256` matches `assets/css/main.scss` today, so the plan's instruction to label it `[red until plan 02-02]` would have been wrong in a harmful direction: plan 02-02 edits `main.scss` and must re-hash **by hand** (no Ruby here, so `al-folio upgrade overrides accept` cannot run). A forgotten re-hash must fail loudly as a real regression, not be absorbed into `EXPECTED_RED`. Labelled `[re-hash by hand in plan 02-02]` instead, which does not match the red-counting pattern.
- **Added an unlabelled-failure line to the tally.** `FAILED - EXPECTED_RED` is now printed when non-zero. Without it, a genuine regression landing during 02-02 would be one more red line among 59.
- **Live rows compare served against local.** The `--deploy-proof` row greps the served CSS for whatever date `_sass/_custom.scss` currently declares, rather than a hardcoded string, so it survives plan 02-03's re-date and every later one.
- **The 30 token rows stay a loop; the 13 gem-partial rows were unrolled.** The token loop iterates the ground-truth array, which is the point of having the array. The partial list is itself the assertion and should be readable without running anything — and flat rows match Phase 1's convention.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] The overrides-hash row was specified red-by-design but is green today**

- **Found during:** Task 2
- **Issue:** The plan listed `.al-folio-overrides.yml local_sha256 matches sha256sum assets/css/main.scss` as `[red until plan 02-02]`. It passes right now (`e51ec6fb…` matches). Labelling a currently-green row red-by-design would let a real failure — 02-02 editing `main.scss` and forgetting to re-hash — be silently counted as expected pending work, which is the exact failure mode the red-by-design convention exists to prevent.
- **Fix:** Relabelled `[re-hash by hand in plan 02-02]`, which deliberately does not match the `*"[red until plan 0"*` case pattern, and added an in-file comment explaining why. Also added an unlabelled-failure line to the tally so the distinction is visible in the output.
- **Files modified:** `.planning/phases/02-palette-and-design-tokens/verify.sh`
- **Verification:** Row reports PASS today; tally shows `59 failed`, `59 red-by-design`, no unlabelled line.
- **Committed in:** `638ee5f`

**2. [Rule 1 - Bug] `no outline: none anywhere in _sass/` likewise mislabelled**

- **Found during:** Task 2
- **Issue:** Same class of error. This is a negative assertion that is true today and must *stay* true through 02-03's `:focus-visible` work; killing the focus ring while restyling focus is the classic way to lose keyboard accessibility.
- **Fix:** Relabelled `[must stay true through plan 02-03]` with a comment.
- **Files modified:** `.planning/phases/02-palette-and-design-tokens/verify.sh`
- **Verification:** Row reports PASS; not counted as red-by-design.
- **Committed in:** `638ee5f`

**3. [Rule 3 - Blocking] `^check ` row count fell short of the plan's own verify command**

- **Found during:** Task 2
- **Issue:** The plan's `<automated>` verify asserts `grep -c '^check '` ≥ 40. The first draft had 36, because the 30-token and 13-partial rows sat inside `for` loops and so were indented. The runtime row count was already 79 — the proxy, not the harness, was short.
- **Fix:** Unrolled the 13 gem-partial rows into flat column-0 `check` calls (dropping the now-unused `GEM_PARTIALS` array), which also matches Phase 1's flat-list convention. Count is now 49.
- **Files modified:** `.planning/phases/02-palette-and-design-tokens/verify.sh`
- **Verification:** The plan's full `<automated>` command for Task 2 now exits 0.
- **Committed in:** `638ee5f`

**4. [Rule 1 - Bug] Stale line reference for the disabled forbidden-path loop**

- **Found during:** Task 3
- **Issue:** The plan cited `test/style_contract.js` lines 72–86 for the commented-out forbidden-path loop. The actual location is 68–84 (explanation at 68–79, loop at 80–84). A wrong line reference in the one file written to stop a deletion would undermine its own evidence.
- **Fix:** Cited 68–84 after checking, and noted the second disabled block at 96–108 (the required-paths check for `test/visual` and two integration scripts, disabled for the same reason).
- **Files modified:** `CLAUDE.md`
- **Verification:** `grep -n` against `test/style_contract.js` confirms both ranges.
- **Committed in:** `33e74ca`

**5. [Rule 2 - Missing Critical] Hex validation in `contrast.js`**

- **Found during:** Task 1
- **Issue:** The research listing parses hex with no validation. A mistyped colour (`#5c534` or a stray `rgb(...)`) yields `NaN` and prints `NaN:1`, which sorts as neither pass nor fail — an unmeasurable ratio presented as a measurement, in a tool whose whole purpose is to make ratios trustworthy.
- **Fix:** `lum()` throws on anything that is not 3- or 6-digit hex. Also added an odd-argument-count guard so a dropped colour errors instead of silently comparing against `undefined`.
- **Files modified:** `.planning/tools/contrast.js`
- **Verification:** `--selftest` still exits 0 with all eight pairs matching.
- **Committed in:** `f8dc251`

**6. [Rule 1 - Bug] `gsd-tools state update-progress` corrupted STATE.md; repaired by hand**

- **Found during:** State updates, after Task 3
- **Issue:** The known `gsd-tools` failure recorded in STATE.md fired again. The tool searches for a bold `Progress:` label, which this file's position block does not use (it uses a plain-text line), so the first match it found was the literal string *inside the blocker bullet that documents this very bug* — and it overwrote that bullet's tail with a progress bar. It also dropped `stopped_at:` from the frontmatter. `advance-plan` errored (`Cannot parse Current Plan or Total Plans`) and `record-session` reported `No session fields found`; both were harmless. `record-metric` worked correctly.
- **Fix:** Restored `stopped_at:`, rewrote the mangled bullet into a complete and now-accurate warning, and — the actual repair — stopped writing the label strings in their literal bold form inside that bullet, so it can no longer be its own first match. Current Position, Progress and Session Continuity were edited by hand.
- **Files modified:** `.planning/STATE.md`
- **Verification:** `git diff .planning/STATE.md` reviewed line by line; frontmatter and the blocker bullet both intact.
- **Committed in:** final metadata commit

**7. [Rule 4 → judged, not escalated] `requirements mark-complete` deliberately NOT run**

- **Found during:** State updates, after Task 3
- **Issue:** The executor protocol says to mark this plan's `requirements:` frontmatter IDs complete — here `TOKEN-01, TOKEN-03, TOKEN-06`. But every requirement in this phase is claimed by several plans at once (TOKEN-01 by all four, TOKEN-06 by three, TOKEN-03 by two). Plan 02-01 built only the means of *verifying* them; the work itself lands in 02-02 (the 30-token redeclaration, the cap) and 02-03 (the `opacity` removal). Marking them Complete would have written a false green into REQUIREMENTS.md's traceability table.
- **Fix:** Skipped the command; recorded the reasoning and the hand-off in STATE.md under Pending Todos, so plan 02-04 marks them once `verify.sh --live` is fully green. Not escalated as a checkpoint because the project already has a governing convention — never record something as done that is not, annotate instead (STATE.md, SAFE-04 decision) — so this had a clear answer rather than needing a user decision.
- **Files modified:** `.planning/STATE.md`
- **Verification:** `REQUIREMENTS.md` still shows TOKEN-01/03/06 as `Pending`, which is accurate.
- **Committed in:** final metadata commit

---

**Total deviations:** 7 (6 auto-fixed, 1 judged-and-recorded)
**Impact on plan:** No scope creep; nothing was added beyond the plan's stated outputs. Four of the seven correct errors that would have weakened the harness's or the state file's ability to distinguish pending work from real regressions — the single thing this plan exists to provide. The one judgement call (requirements) was resolved by an existing project convention rather than by inventing a new rule.

## Issues Encountered

- **A large heredoc write of `verify.sh` failed with `unexpected EOF`** at the shell level. Resolved by writing the file with the Write tool instead. Worth remembering for later plans: `_tokens.scss` in 02-02 will be a similarly large multi-line file.
- **No ground-truth surprises.** The `curl` returned exactly 30 names on the first attempt, so the plan's "if the count is not 30, STOP and report" branch was not taken and `al_folio_core` is still on the pin 02-RESEARCH.md inventoried.

## User Setup Required

None — no external service configuration required. Nothing was pushed: plan 02-04 owns this phase's single push, so that `enable_darkmode: false` and the token re-point reach the live site in one deploy.

## Next Phase Readiness

**Ready for plan 02-02.** Its every `<automated>` verify now has a tool. Concretely, 02-02 should expect to turn green: the `_tokens.scss` existence row, all 30 token-declaration rows, the `@use "tokens";` ordering row, both `--step-`/`--space-` count rows, the `:root,` + `html[data-theme="dark"]` pairing, `color-scheme: light`, the four cap-comment rows, the four primitive-count rows (2/4/1/2), and the criterion-5 ratio-comment row — 42 rows in total.

**Two things 02-02 must not forget:**

1. **Re-hash `.al-folio-overrides.yml` by hand** after editing `assets/css/main.scss`. There is no Ruby here; `al-folio upgrade overrides accept` cannot run. That row is green now and will go red — as an unlabelled failure — if the hash is not recomputed.
2. **Do not fold `--deploy-proof` into the design tokens.** It is an unreferenced custom property retained on purpose (Phase 1 decision); a token audit is exactly the thing that would delete it. The harness has a dedicated canary row for this.

**Concerns:** none blocking. The static block will stay loudly red until 02-04, which is by design and is documented at the top of the script — but anyone running it for the first time should read that header before "fixing" 59 failures.

---

_Phase: 02-palette-and-design-tokens_
_Completed: 2026-09-14_

## Self-Check: PASSED

All three artifacts exist and meet their `min_lines` / `contains` constraints (`contrast.js` 105 lines, carries `0.03928`; `verify.sh` 438 lines, carries `--live`; `CLAUDE.md` names `_sass`). Both `key_links` resolve: `verify.sh` invokes `contrast.js` in two check rows and carries all 30 `--global-*` names. All three task commits (`f8dc251`, `638ee5f`, `33e74ca`) are present in `git log`.

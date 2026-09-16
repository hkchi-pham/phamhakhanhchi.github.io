---
phase: 03-typography
plan: 01
subsystem: testing
tags: [webfonts, google-fonts, vietnamese-subset, woff2, shell-harness, nodejs, verification, byte-budget]

# Dependency graph
requires:
  - phase: 02-palette-and-design-tokens
    provides: "The verify.sh harness shape (flat `check` rows, `set -uo pipefail`, `--live` flag, EXPECTED_RED tally, cache-busted live fetches); the served-CSS-is-ground-truth lesson from the :focus-visible regression; .planning/tools/contrast.js as the zero-dependency tool precedent; the 930px max_width and the 0.18em --underline-offset this phase must not silently change"
provides:
  - ".planning/tools/fontbudget.js — zero-dependency Node byte counter for a Google Fonts css2 URL, with --max, --report-only and --selftest"
  - ".planning/phases/03-typography/verify.sh — 38 static + 42 live assertion rows for TYPE-01..TYPE-05, red-by-design"
  - ".planning/phases/03-typography/03-VALIDATION.md — filled per-task map, four manual-only rows, nyquist_compliant: true"
  - "The recorded curl proof that BOTH locked families serve a real Vietnamese subset (commit ca16ad4 body)"
  - "The measured 141,232 B baseline for the five locked cuts, pinned to Literata v40 and Be Vietnam Pro v12"
  - "BOTH answers to plan 03-01's blocking checkpoint: `status-serif` and `title-full` (see 'The Two Settled Decisions' below — plans 03-02 and 03-03 read them from here)"
affects: [03-02, 03-03, 03-04, 04-marginalia, 06-hero, 07-mobile-print, 08-qa-audit]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Wave 0 verification infrastructure written BEFORE the change it verifies, carried forward from Phase 2"
    - "A phase criterion whose evidence cannot be re-run by command is not a criterion — network measurements go in a --selftest-backed tool, not a screenshot"
    - "A blocking decision that changes the bytes requested from a third party is settled BEFORE the request is written, not after"

key-files:
  created:
    - .planning/tools/fontbudget.js
    - .planning/phases/03-typography/verify.sh
  modified:
    - .planning/phases/03-typography/03-VALIDATION.md

key-decisions:
  - "(A) `.entry-status` stays Literata 400 italic (`status-serif`). The fonts URL KEEPS the italic axis `Literata:ital,wght@0,400;0,600;1,400`, so VIET_BLOCKS_EXPECTED is 5, not 4, and the payload stays 141,232 B of 153,600 B — 91.9% used, 12,368 B headroom. The 26,344 B are bought knowingly."
  - "(B) `h1.post-title` keeps the full 930px (`title-full`) and is NOT added to the prose measure. The measure selector list stays inside `.post article`; no `header.post-header` selector joins it."
  - "`--step-5` computes to 44.2px (2.6 x 17px), BELOW criterion 1's '48px or larger'. That clause describes how to INSPECT the name, not how large the h1 must be. The h1 is NOT to be sized up to 48px."
  - "The browser User-Agent is baked into fontbudget.js as a constant rather than a flag, and a format('truetype') response is a hard exit 2 — a UA-less fetch would otherwise parse to zero blocks and report a passing 0 B budget."
  - "The Vietnamese curl proof lives in commit ca16ad4's message body, not in a new markdown file, because criterion 2's wording is 'verified by curl and recorded in the commit'."
  - "Duplicate woff2 URLs are de-duplicated before counting: Literata 400 and 600 resolve to the SAME variable file, and counting it twice overstates the payload by ~48 KB."
  - "The icon payload is recorded by --report-only and deliberately NOT budgeted — inherited payload this phase is not designing."

patterns-established:
  - "Red-by-design labelling carried forward: every row that cannot be true yet carries [red until plan 03-NN] and is counted in EXPECTED_RED; a row that is green today and must merely STAY green gets NO label."
  - "One check row per fragile measure node (.post article>ol, >blockquote, >h4, >.clearfix>p ...) rather than one 'the measure shipped' row, so a PurgeCSS casualty names itself instead of starting a hunt."
  - "A settled decision whose assertion is an ABSENCE (no header.post-header row) gets a comment written where the row would have been, so a later agent cannot read the gap as an oversight."
  - "Budgets are stated in BYTES, never in 'KB': the 141,232 B payload reads as 141.2 kB in DevTools and 137.9 KiB from ls, and 3.3 of the 12-unit margin sits inside that ambiguity alone."

requirements-contributed: [TYPE-01, TYPE-02, TYPE-03, TYPE-04, TYPE-05] # verification surface only — completion lands in 03-02/03-03/03-04, following the 02-01 precedent

# Metrics
duration: 53min
completed: 2026-09-16
---

# Phase 3 Plan 01: Typography Verification Surface Summary

**A zero-dependency 141,232-byte webfont counter, a 38-static/80-live red-by-design harness for TYPE-01..TYPE-05, a curl proof that both locked families serve a real Vietnamese subset, and both blocking decisions settled before a single byte is requested from Google.**

## Performance

- **Duration:** ~53 min (first task commit 2026-09-16 15:45 +07 to plan close 16:38 +07)
- **Started:** 2026-09-16T08:45:02Z
- **Completed:** 2026-09-16T09:37:56Z
- **Tasks:** 3 of 3
- **Files modified:** 3 (2 created, 1 rewritten over its skeleton)

## The Two Settled Decisions

**Plans 03-02 and 03-03 read this section. It is the authoritative record of task 3's checkpoint answer.**

### (A) `.entry-status` takes Literata 400 italic — option `status-serif`

`.entry-status` is an authorial aside inside a research entry, not a label, and italic serif is the right voice for an aside. It is already `font-style: italic` in `_custom.scss`, so the cut has a consumer on day one rather than waiting for Phase 4.

Consequences, in plain words, for the plans that build on this:

- **The fonts URL KEEPS the italic axis.** Literata is requested as `Literata:ital,wght@0,400;0,600;1,400` — the `ital,` prefix and the `;1,400` pair both stay. Do not "simplify" the URL to `Literata:wght@400;600`.
- **The expected `/* vietnamese */` block count is FIVE, not four.** `VIET_BLOCKS_EXPECTED=5` in `verify.sh` is correct as written and needs no edit. The five cuts are Be Vietnam Pro 400, Be Vietnam Pro 600, Literata 400, Literata 600 and Literata 400 italic.
- **The budget stands at 141,232 B of 153,600 B — 91.9% used, 12,368 B of headroom.** The italic cut's 26,344 B are spent knowingly. The rejected alternative (`status-sans`) would have dropped the payload to 114,888 B / 75%, but Phase 4 marginalia would then have had to re-add and re-pay the cut.

### (B) `h1.post-title` keeps the full 930px — option `title-full`

The page title is **NOT** added to the prose measure.

- **The measure selector list stays inside `.post article`**, exactly as 03-CONTEXT scopes it. `h1.post-title` lives in `<header class="post-header">`, a sibling of `<article>`, so the measure simply does not reach it — and that is the intended outcome, not an oversight.
- **No `header.post-header` selector joins the list in plan 03-03.** Do not add `.post > header.post-header > h1` or any equivalent.
- The title reads as a masthead above the column rather than as the column's first line, it adds nothing further for PurgeCSS to strip, and Phase 6 owns hero composition if this is ever revisited.

### Carried forward with both decisions: the 44.2px note

`--step-5` computes to **44.2px** (2.6 x 17px), which is **below criterion 1's "48px or larger"**. That criterion describes how to **inspect** the name — zoom in and compare `ạ` in "Phạm" against `à` in "Hà", to confirm both subset files loaded and composed identically — **not how large the `h1` must be**. **Do not size the `h1` up to 48px in plan 03-02 to satisfy a misread of that clause.** This is recorded here, in `verify.sh`'s header note (c), and in `03-VALIDATION.md`'s Manual-Only table, so all three agree.

## Accomplishments

- **Criterion 2 is discharged.** Both locked families provably serve a Vietnamese subset: 5 `/* vietnamese */` blocks, each carrying `unicode-range: … U+1EA0-1EF9, U+20AB` and `format('woff2')`, at Literata v40 and Be Vietnam Pro v12. The proof is verbatim in commit `ca16ad4`'s body, as the criterion's "recorded in the commit" wording requires. Neither family failed, so the pairing stands and nothing downstream moves.
- **The byte budget is a command, not a memory.** `node .planning/tools/fontbudget.js … --max 153600` reproduces 03-RESEARCH Finding 3 byte for byte — `TOTAL: 141232 B (137.9 KiB, 141.2 kB)` over 8 unique files, `USED: 91.9%`, `HEADROOM: 12368 B` — and exits nonzero over budget.
- **Every automatable row of TYPE-01..TYPE-05 exists and is visibly red.** 38 static / 80 live rows; 26 static and 58 live failures, all labelled, `UNLABELLED` = 0.
- **Both blocking decisions are settled before the config edit**, which is the whole point of putting them in wave 1: one of them changes the bytes the browser downloads, and this phase is allocated a single push.

## Task Commits

1. **Task 1: Build fontbudget.js, the reproducible byte counter** — `f48b2b1` (chore)
2. **Task 2: Write the phase harness and record the Vietnamese curl proof** — `ca16ad4` (test)
3. **Task 3: Settle the two open decisions before anything is requested from Google** — `0694782` (docs)

## Files Created/Modified

- `.planning/tools/fontbudget.js` (481 lines, created) — zero-dependency CommonJS byte counter. `--max` budget mode with woff2 de-duplication and stream-summed byte counts cross-checked against `content-length`; `--report-only` for the unbudgeted icon figure; `--selftest` asserting the parser against an inline two-block fixture with a duplicate URL. Browser UA baked in as a constant; a `format('truetype')` response is a hard exit 2.
- `.planning/phases/03-typography/verify.sh` (541 lines, created, executable) — 38 static + 42 `--live` rows. Header notes cover the bytes-not-KB budget, the mandatory `FONTS_UA` and its failure signature, and the three criteria that are genuinely manual. Now also carries the settled record of both task-3 decisions.
- `.planning/phases/03-typography/03-VALIDATION.md` (132 lines, rewritten over its skeleton) — real Test Infrastructure values (Framework: **none, and none may be added**), Sampling Rate, a per-task map for plans 03-01..03-04, the ticked Wave 0 checklist, and exactly four Manual-Only rows. `nyquist_compliant: true`, `wave_0_complete: true`, `status: approved`. Row 3-01-03 is now green and names both answers.

## Decisions Made

See **The Two Settled Decisions** above for (A) and (B), which are this plan's headline output. Execution decisions beyond those are in the `key-decisions` frontmatter — chiefly that the UA is a constant and not a flag, that the curl proof lives in a commit body rather than a new file, and that duplicate woff2 URLs are de-duplicated before counting.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] `FONTS_URL` environment fallback added to fontbudget.js**

- **Found during:** Task 1 (Build fontbudget.js)
- **Issue:** `node` on PATH here is a Volta shim that re-parses argv through `cmd.exe`, so everything after the first `&` in a two-family `css2` URL is destroyed before Node sees it. Passed positionally, the two-family URL silently became a one-family URL — the tool would then measure one family and report a comfortably passing total. A budget that passes because half the payload was never fetched is worse than no budget at all.
- **Fix:** Added a `FONTS_URL` environment-variable fallback, documented at the top of the file with the measured failure output. Positional URLs still work and are preferred where the shell is known-good.
- **Files modified:** `.planning/tools/fontbudget.js`
- **Verification:** The env-var invocation returns the full 141,232 B over 8 files, matching 03-RESEARCH Finding 3.
- **Committed in:** `f48b2b1` (Task 1 commit)

**2. [Rule 1 - Bug] The `!important` row narrowed to exempt `//` comment lines**

- **Found during:** Task 2 (Write the phase harness)
- **Issue:** The planned "no `!important` anywhere in `_sass/`" row is specified as green-and-unlabelled, but a bare grep also matches the word inside Sass `//` comments, so the row failed on prose that contains no declaration at all — a green row reporting red for a non-reason, which is exactly the kind of noise that trains people to ignore a tally.
- **Fix:** The row's expression skips `//` comment lines before matching.
- **Files modified:** `.planning/phases/03-typography/verify.sh`
- **Verification:** The row passes against today's `_sass/` and still fails against an injected real `!important` declaration.
- **Committed in:** `ca16ad4` (Task 2 commit)

**3. [Rule 1 - Bug] The served-HTML fonts-URL row guarded with `[ -n "$FONTS_URL" ]`**

- **Found during:** Task 2 (Write the phase harness)
- **Issue:** `FONTS_URL` is read out of `_config.yml` and is deliberately EMPTY until plan 03-02 lands. `grep -qF "" "$LIVE_HTML"` matches every non-empty file, so the row would have reported PASS today — a red-by-design row silently green before its work exists, which defeats the entire red-by-design convention.
- **Fix:** The row is guarded with `[ -n "$FONTS_URL" ] &&` before the grep, so it fails honestly until 03-02 writes the URL.
- **Files modified:** `.planning/phases/03-typography/verify.sh`
- **Verification:** The row appears as FAIL under its `[red until plan 03-04]` label today and is counted in `EXPECTED_RED`.
- **Committed in:** `ca16ad4` (Task 2 commit)

---

**Total deviations:** 3 auto-fixed (1 blocking, 2 bugs)
**Impact on plan:** All three protect the harness from reporting a false pass — the exact failure mode Phase 2's stripped `:focus-visible` rule cost a day to find. No scope creep; no file outside `.planning/` was touched, so no deploy could fire from this plan.

## Issues Encountered

- **The checkpoint was genuinely blocking and the plan was right to make it so.** Decision (A) changes the fonts URL itself. Had plan 03-02 been allowed to run first, either answer would have required re-editing `_config.yml`, re-measuring the budget and re-deploying — and this phase is allocated a single push.
- `VIET_BLOCKS_EXPECTED` needed no numeric change: the answer was `status-serif`, which the in-file note had already pre-declared as the 5 case. The conditional note was therefore rewritten into a settled record rather than left as an open question. No row was added, removed or renumbered — the tally is still 38 checks, 26 failed, 26 red-by-design, 0 `UNLABELLED`, unchanged from `ca16ad4`.

## User Setup Required

None — no external service configuration required. No credential, dashboard step or environment variable is needed to run either the harness or the budget tool. (`FONTS_URL` is a shell-quirk workaround, not a secret, and `verify.sh` sets it itself.)

## Next Phase Readiness

**Ready for plan 03-02** (`_config.yml` + `_sass/_tokens.scss`). It must:

- request `Literata:ital,wght@0,400;0,600;1,400` **with** the italic axis, per decision (A);
- leave `VIET_BLOCKS_EXPECTED=5` alone;
- **not** size `h1` up to 48px — 44.2px is the intended `--step-5`;
- drop `Material+Icons`, `academicons:` and `scholar-icons:` while keeping `fontawesome:`;
- leave `max_width: 930px` untouched — there is an unlabelled green row watching it.

**Ready for plan 03-03** (`_custom.scss` + `purgecss.config.js`): the measure selector list stays inside `.post article` and no `header.post-header` selector joins it, per decision (B).

**Not yet exercised:** the 42 `--live` rows, which need plan 03-04's single push. Deploy latency is ~112-168s from push; poll, do not refresh once. `origin/gh-pages` reads `54483dba3691b569bc82b65183d7c286ab822e54` as of this plan, matching STATE.md.

**Carried blocker, unchanged by this plan:** Phase 2's close-out tag `design-02-<slug>` is still outstanding and must point at `482c740`, not at local HEAD.

---

_Phase: 03-typography_
_Completed: 2026-09-16_

## Self-Check: PASSED

- `.planning/tools/fontbudget.js` — FOUND
- `.planning/phases/03-typography/verify.sh` — FOUND
- `.planning/phases/03-typography/03-VALIDATION.md` — FOUND
- `.planning/phases/03-typography/03-01-SUMMARY.md` — FOUND
- Commit `f48b2b1` (task 1) — FOUND
- Commit `ca16ad4` (task 2) — FOUND
- Commit `0694782` (task 3) — FOUND
- `bash .planning/phases/03-typography/verify.sh` after the task-3 edit — 38 checks, 26 failed, 26 red-by-design, 0 UNLABELLED (unchanged from `ca16ad4`)
- `bash -n .planning/phases/03-typography/verify.sh` — clean
- `git status` — nothing outside `.planning/` modified; no deploy can fire from this plan

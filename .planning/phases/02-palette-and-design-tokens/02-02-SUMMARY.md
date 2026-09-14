---
phase: 02-palette-and-design-tokens
plan: 02
subsystem: styling
tags: [design-tokens, css-custom-properties, wcag, dark-mode, scss, cascade]

# Dependency graph
requires:
  - phase: 02-palette-and-design-tokens
    plan: 01
    provides: "The 30-name --global-* ground truth read off the served main.css; contrast.js --selftest; the 79-row verify.sh that made every criterion in this plan checkable before it was written"
  - phase: 01-deployment-guardrails
    provides: "`_sass/**` in deploy.yml's push paths, so a token-only change can reach production at all; the retained --deploy-proof canary this plan must not absorb"
provides:
  - "_sass/_tokens.scss — the single file holding every colour and length literal in the design (Tier 1 primitives with measured ratios + the written cap; Tier 2 mapping all 30 --global-* onto them)"
  - "assets/css/main.scss wired to load tokens after the gem's themes partial and before the site's custom partial"
  - "A re-recorded .al-folio-overrides.yml local_sha256 for the edited main.scss"
  - "The dark-mode neutralisation hook: `:root, html[data-theme=\"dark\"]` at (0,1,1), which a future dark theme re-points from"
affects: [02-03, 02-04, 03-typography, 04-notebook-art, 07-mobile-print, 08-qa-audit]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Two-tier tokens: literals exist only in Tier 1 primitives; Tier 2 semantic names are pure var() references, so a theme swap re-points nine colours and rewrites no rule"
    - "Contrast ratios live as trailing /* */ comments on the declaration they describe, reproducible via .planning/tools/contrast.js"
    - "Specificity-matched selector list (`:root, html[data-theme=\"dark\"]`) to neutralise a gem block that ships unconditionally, rather than relying on a config flag"

key-files:
  created:
    - _sass/_tokens.scss
    - .planning/phases/02-palette-and-design-tokens/deferred-items.md
  modified:
    - assets/css/main.scss
    - .al-folio-overrides.yml
    - .planning/phases/02-palette-and-design-tokens/verify.sh

key-decisions:
  - "The 30 --global-* names written here diff IDENTICAL to verify.sh's served-CSS ground truth — no name in the plan's token_map differed, so the served CSS never had to overrule the table."
  - "`--rule-hairline: 1px` is kept (plan 02-03 consumes it) and two verify.sh rows were narrowed instead: the TOKEN-06 cap now counts `--rule-[0-9]` colours, and the ratio assertion now matches hex VALUES rather than name prefixes."
  - "A comment quoting `outline: none` tripped verify.sh's negative assertion. The comment was reworded rather than the assertion softened — the crude grep is the point."
  - "The overrides hash was recomputed by hand over the LF working copy; with core.autocrlf=true a fresh Windows checkout would hash differently. Logged as a deferred item, not fixed here."

patterns-established:
  - "Comments in _sass/ must not quote a string that a harness asserts is absent. Prose about a forbidden declaration names it, it does not spell it."
  - "When the harness and a correct implementation disagree, narrow the harness's matcher and say why in-file — never delete or relabel the row, and prefer a narrowing that is strictly stronger elsewhere."

requirements-contributed: [TOKEN-01, TOKEN-02, TOKEN-05, TOKEN-06, GROUND-01]
requirements-completed: []

# Metrics
duration: 6min
completed: 2026-09-14
---

# Phase 2 Plan 02: The Token File Summary

**One 201-line `_sass/_tokens.scss` now holds every colour and length literal in the design — nine measured primitives under a written cap, and all 30 of the gem's `--global-*` names re-pointed onto them under a `:root, html[data-theme="dark"]` selector list that outranks nothing and ties everything, so forcing dark mode repaints nothing.**

## Performance

- **Duration:** 6 min
- **Started:** 2026-09-14T15:05Z
- **Completed:** 2026-09-14T15:11Z
- **Tasks:** 3 (plus 2 deviation fixes)
- **Files modified:** 5 (2 created, 3 modified)

## Accomplishments

- **The phase harness went from 59 red rows to 14, all 14 labelled for later plans, 0 unlabelled.** Plan 02-01 predicted 02-02 would turn "roughly 42 rows" green; the actual figure is 45. Every `[red until plan 02-02]` row in `verify.sh` is now PASS.
- **All 30 `--global-*` tokens resolve to a site primitive.** That single block repaints body, navbar, dropdowns, cards, code blocks, buttons, tables, the footer and the back-to-top button together — there is no intermediate state where the navbar is cream and the cards are still white, which is why this had to be one file and one change rather than a rule-by-rule repaint.
- **Dark mode is defused in CSS, not just in config.** The gem's `html[data-theme="dark"]` block is compiled into `main.css` unconditionally, whatever `enable_darkmode` says, and at (0,1,1) it beats a plain `:root`. Matching that specificity in a selector list and emitting later means `--global-bg-color` resolves to `#faf6ee` even with `data-theme="dark"` forced in DevTools. `color-scheme: light` is re-declared in the same block so scrollbars and form controls do not go dark either.
- **Zero literals in Tier 2.** `grep -E '^\s*--global-' _sass/_tokens.scss | grep -vE 'var\(--(paper|ink|accent|rule)-'` returns nothing, so TOKEN-05's "a dark theme is addable by re-pointing primitives inside one new block" is structurally true, not aspirational.
- **Every hex in the file carries its measured ratio**, and the figures were re-derived here with `contrast.js` rather than copied: the plan's nine primitives and all five recess-ground figures reproduced exactly (`#2b2621` on `#f2ebdd` = 12.63:1, `#5c5349` = 6.35:1, `#1d4ed8` = 5.65:1), as did the oxblood fallback at 6.78:1.

## Task Commits

1. **Task 1: Tier 1 — primitives, scale, cap, measured ratios** — `f6164fa` (feat)
2. **Task 2: Tier 2 — all 30 `--global-*` under the merged selector list** — `587f0ce` (feat)
3. **Task 3: `@use "tokens";` in main.scss + hand-recorded override hash** — `829b227` (chore)
4. Deviation fix: focus-ring comment tripping the no-`outline: none` assertion — `995b775` (fix)
5. Deviation fix: two `verify.sh` rows counting a 1px length as a rule colour — `88489aa` (fix)

## The 30-name diff against `verify.sh`'s ground truth

**Result: IDENTICAL.** The names declared in Tier 2, extracted from the file itself, were diffed against the `GLOBAL_TOKENS` array plan 02-01 read off the served `main.css`:

```
ground=30  mine=30   diff: (empty)
```

No name in the plan's `<token_map>` differed from the served CSS, so the "the served CSS wins and you must say so" branch was not taken. The count is 30, not the 29 still recorded in ROADMAP.md, STACK.md and 02-CONTEXT.md.

## The override hash, and the CRLF caveat

- **New `local_sha256`: `8a43e85c17a3839f30cba96a991fa47d64f2bee7db689177ad448ef7bfca79ae`** (was `e51ec6fb…`). `node -e crypto` and `sha256sum` agree.
- Recomputed **by hand**: there is no Ruby on this machine, so `bundle exec al-folio upgrade overrides accept assets/css/main.scss` cannot run. Safe because nothing runs the override audit in CI — `upgrade-check.yml` was among the 19 workflows deleted in Phase 1.
- `upstream_sha256` and `gem_version` are untouched (the gem's copy has not moved off 1.0.15); `acknowledged_at` is now `"2026-09-14"`; a YAML comment above the entry records the hand edit and the exact delta.
- **CRLF caveat.** `core.autocrlf=true`, and `.gitattributes` forces `eol=lf` only for `*.sh`. `assets/css/main.scss` is LF in this working copy and the hash was computed over it as it sits on disk — which is what `verify.sh` does too (`sha256sum "$MAIN"`). Git warns it will store LF and check out CRLF, so **a fresh Windows clone would compute a different hash and turn that harness row red for a reason unrelated to the override being stale.** Logged in `deferred-items.md` with two possible fixes (`*.scss text eol=lf`, or normalising line endings before hashing); deliberately not fixed here, since it changes checkout behaviour for every `.scss` in the repo.

## Files Created/Modified

- `_sass/_tokens.scss` (201 lines, new) — header stating it is *the* token file and how the ratios were computed; the TOKEN-06 cap (2 paper / 4 ink / 1 accent / 2 type families) three lines above the declarations; Tier 1's nine colours each with a trailing `N.NN:1` comment, plus the recess-ground figures, the oxblood fallback and the reason `--paper-50` is absent; `--step-0..3`, `--leading-body`, `--space-1..4`; eight named measures and strokes so `_custom.scss` can be literal-free; then Tier 2's 30 `--global-*` under `:root, html[data-theme="dark"]`.
- `assets/css/main.scss` (+3 lines) — `@use "tokens";` and a one-line comment, immediately before `@use "custom";`. Still a minimal delta from the gem's verbatim copy.
- `.al-folio-overrides.yml` (+8 / −2) — new hash, new date, and the explanatory comment.
- `.planning/phases/02-palette-and-design-tokens/verify.sh` (+13 / −3) — two matchers narrowed, see deviations.
- `.planning/phases/02-palette-and-design-tokens/deferred-items.md` (new) — the CRLF hash caveat.

## Decisions Made

- **`--rule-hairline` stayed; the harness moved.** See deviation 2. The alternative — renaming it to `--hairline` — would have left plan 02-03's `border-bottom: var(--rule-hairline) solid var(--rule-500);` referring to an undeclared custom property, which fails *silently*: the declaration is dropped and the `.subject` separator simply vanishes. Choosing between a loud harness edit and a silent CSS failure is not a close call.
- **`--global-divider-color` → `--rule-200`** as decided in the plan (1.43:1, decorative: `hr`, table/dropdown borders, navbar and footer edges). Site-owned structural separators take an explicit `--rule-500` in 02-03 instead. Recorded in place so Phase 7's low-brightness mobile check knows where to look.
- **`--global-hover-text-color` is set to `--paper-100`** even though it has no firing consumer today. Leaving the gem's `#ffffff` live would surface the first time any accent-filled surface appears, and `.btn-outline-primary:hover` is reachable on the CV page. `#faf6ee` on `#1d4ed8` is 6.22:1.
- **The three callout families are monochrome and graded by bar weight** (`--rule-500` → `--ink-500` → `--ink-900`), with an in-file comment recording that they have zero consumers today and that Phase 8 must re-check they are distinguishable *without* colour if any page ever renders one.
- **`--deploy-proof` was not touched.** It stays an unreferenced custom property in `_custom.scss`; the canary row is still green.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] A comment quoting `outline: none` turned the run's negative assertion red**

- **Found during:** Task 3 verification (the full harness run)
- **Issue:** `--focus-ring-width`'s trailing comment read ``/* >= 2px, and never `outline: none` */``. `verify.sh` asserts the literal string `outline: none` appears nowhere under `_sass/` — a deliberately crude grep, because killing the focus ring while restyling `:focus-visible` is the classic way to lose keyboard accessibility. My comment matched it, producing the run's only **unlabelled** failure, i.e. exactly the signal 02-01 built the tally to preserve.
- **Fix:** Reworded the comment to state the rule without spelling the forbidden declaration. The assertion was not softened — a harness that can be argued with is not a harness.
- **Files modified:** `_sass/_tokens.scss`
- **Verification:** `grep -rn "outline: none" _sass/` returns nothing; the row is PASS.
- **Committed in:** `995b775`

**2. [Rule 1 - Bug] Two `verify.sh` rows counted a 1px stroke width as a rule colour**

- **Found during:** Task 3 verification
- **Issue:** Plan 02-01 wrote `decl_count '--rule-'` (cap: exactly 2) and `primitives_have_ratio` matching `^\s*--(paper|ink|accent|rule)-[a-z0-9-]*:`. Plan 02-02 declares `--rule-hairline: 1px` — a stroke *width*, consumed by plan 02-03's `.subject` border — so both rows failed against a correct implementation: the cap counted 3 "rule colours", and the ratio assertion demanded a contrast ratio on a length. Note the plan's own Task 1 `<automated>` verify uses `--rule-[0-9]`, so the plan is internally consistent and the harness's matcher is the defect; it was written from CONTEXT before the named-length tokens were finalised.
- **Fix:** Narrowed the cap row to `decl_count '--rule-[0-9]'` (still catches a third rule colour such as `--rule-300`) and re-based `primitives_have_ratio` on the declaration's **value** being a hex literal rather than its name prefix — which is strictly *stronger*, since it now also catches a colour declared under a name outside the four known prefixes. Both changes carry a dated in-file comment. **No row was deleted, relabelled or removed from the `EXPECTED_RED` accounting.**
- **Files modified:** `.planning/phases/02-palette-and-design-tokens/verify.sh`
- **Verification:** Both rows PASS; the tally is 79 checks / 14 failed / 14 red-by-design / 0 unlabelled.
- **Committed in:** `88489aa`

**3. [Rule 3 - Blocking] The `@use` comment defeated the ordering row it was documenting**

- **Found during:** Task 3
- **Issue:** The one-line comment above `@use "tokens";` originally quoted `` `@use "custom";` ``. The harness finds each `@use` by `grep -n … | head -1`, so the *comment* became the first match for `@use "custom";` at line 38 — one line **above** `@use "tokens";` at line 39 — and the "tokens before custom" row failed even though the real statements were in the right order.
- **Fix:** Reworded the comment to name the partials in prose ("the gem's themes partial", "the site's custom partial") instead of quoting the statements. Re-hashed `main.scss` afterwards.
- **Files modified:** `assets/css/main.scss`, `.al-folio-overrides.yml`
- **Verification:** `@use "tokens";` at line 37, `@use "custom";` at line 41; the row is PASS.
- **Committed in:** `829b227` (fixed before the task was committed)

### Judged, not escalated

**4. [Rule 4 → judged] The plan's `git diff --stat` clause says only three files should change**

`verify.sh` is a fourth. The alternative to editing it was leaving two rows permanently red against a correct implementation — rows that plan 02-04 must see green — or renaming a token that plan 02-03 already consumes by name. Both are worse, and the project already has a governing convention for this class of call (02-01: "a criterion that is not yet true stays in the harness … deleting a row to get a clean tally is forbidden"), which the fix respects: the rows still exist, still carry their labels, and one matcher is now stricter than before. Committed separately as a `fix(02-02)` so the three-file token change is reviewable on its own.

**5. [Protocol] `requirements mark-complete` deliberately NOT run**

Same reasoning plan 02-01 recorded and STATE.md's Pending Todo carries forward: TOKEN-01/02/05/06 and GROUND-01 are each claimed by several plans in this phase. TOKEN-01's 30 re-pointed names and TOKEN-06's cap landed here, but GROUND-01 ("a warm paper ground applies across all seven pages") is not verifiable until the change is deployed and checked live in 02-04, and TOKEN-02 is not satisfied until `_custom.scss` actually *consumes* `var(--step-` / `var(--space-` in 02-03. **Plan 02-04 marks them, once `verify.sh --live` is fully green.**

---

**Total deviations:** 5 (3 auto-fixed, 2 judged-and-recorded)
**Impact on plan:** No scope creep. Two of the three fixes are the same underlying mistake — prose inside a file that a grep-based harness reads as content — which is worth remembering for 02-03, whose `_custom.scss` work is checked by six more string-matching rows.

## Issues Encountered

- **Heredoc backslash mangling.** In this shell, `\\` inside a quoted `<<'PY'` heredoc reaches Python as a single `\`, which silently turned a multi-line match string into a line continuation and made a `str.replace` no-op look like "text not found". Workaround: build backslashes as `chr(92)`, or patch by line index. This compounds the large-heredoc `unexpected EOF` failure 02-01 already recorded — for anything non-trivial, use the Write tool or index-based edits, not heredoc text matching.
- **Prettier changed nothing in `_tokens.scss`** on any of the three runs (the file was written Prettier-shaped), so the hex-case mangling 02-01 warned about did not occur. The ratio comments were re-read after each run regardless; all nine are intact.
- **No Jekyll build was possible** (no Ruby locally), so the cascade claim — that our (0,1,1) block wins over the gem's — is verified by construction and by source order, not by inspecting compiled CSS. Plan 02-04's live checks are where it becomes a measurement.

## User Setup Required

None. **Nothing was pushed.** Plan 02-04 owns this phase's single push, so the token re-point and `enable_darkmode: false` reach production in one deploy — a half-deployed state would give a dark-mode visitor a partly repainted page.

## Next Phase Readiness

**Ready for plan 02-03.** Every token it consumes now exists and is named exactly as its plan text expects, including `--rule-hairline`, `--entry-year-col`, `--subject-row-max`, `--underline-thickness{,-hover}`, `--underline-offset` and `--focus-ring-{width,offset}`.

**Three things 02-03 must not forget:**

1. **Do not write a string into `_sass/` that the harness asserts is absent.** Two of this plan's three fixes were exactly that. `_custom.scss` is checked by `custom_has_no_literals`, which exempts `//` comment lines and `--deploy-proof` but nothing else — a `/* */` comment mentioning `1px` or a hex WILL fail it.
2. **`opacity` must disappear from `_sass/` entirely** (four occurrences in `_custom.scss` today, lines 39/48/65/74). Replace with an ink token; opacity on text makes the computed colour differ from the declared one, so no ratio comment can be true about it.
3. **`--rule-500` is 3.08:1 on paper but only 2.80:1 on `--paper-200`.** A structural hairline inside the footer or a code block needs an ink, not a rule colour. The figure is recorded in `_tokens.scss`.

**Concerns:** none blocking. The CRLF hash caveat above is the only latent false-red, and it cannot fire on this machine.

---

_Phase: 02-palette-and-design-tokens_
_Completed: 2026-09-14_

## Self-Check: PASSED

All five artifacts exist (`_sass/_tokens.scss` 201 lines and carrying `html[data-theme="dark"]`, well past the 90-line floor; `assets/css/main.scss` 41 lines with `@use "tokens";` at 37 and `@use "custom";` at 41; `.al-folio-overrides.yml` carrying `local_sha256: 8a43e85c…`; `deferred-items.md`; this file). All three `key_links` resolve: main.scss loads tokens before custom, `_tokens.scss` carries the `html[data-theme="dark"]` selector, and all 30 `--global-*` values are `var(--…)` references. All five commits (`f6164fa`, `587f0ce`, `829b227`, `995b775`, `88489aa`) are present in `git log`. One claim was corrected during the check: `_custom.scss` has four `opacity` occurrences, not five.

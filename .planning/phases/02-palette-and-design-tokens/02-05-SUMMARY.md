---
phase: 02-palette-and-design-tokens
plan: 05
subsystem: infra
tags: [purgecss, safelist, focus-visible, accessibility, deploy, cdn, harness, human-verification]

# Dependency graph
requires:
  - phase: 02-palette-and-design-tokens
    plan: 03
    provides: "_sass/_custom.scss's bare `:focus-visible` rule and the h1..h6 heading-ink rule — correct in source since 02-03, and the two things PurgeCSS was quietly deleting on the way to production"
  - phase: 02-palette-and-design-tokens
    plan: 02
    provides: "--focus-ring-width and --focus-ring-offset in _sass/_tokens.scss — already live, so this plan needed no token change and made none"
  - phase: 02-palette-and-design-tokens
    plan: 01
    provides: "verify.sh's --live block and its check/EXPECTED_RED contract, which the eight new served-CSS rows plug straight into"
  - phase: 01-deployment-guardrails
    plan: 02
    provides: "deploy.yml's paths-ignore denylist — purgecss.config.js is not on it, so a one-line config edit deploys normally"
provides:
  - "purgecss.config.js safelisting the bare `:focus-visible` selector (with its leading colon) plus h5 and h6, with the reason written beside them"
  - "A keyboard focus ring that is actually in the stylesheet the CDN serves — 02-03 must-have #18 true in production, not only in source"
  - "Heading ink restored to all six levels in the served CSS: h1,h2,h3,h4,h5,h6,.post-title"
  - "Eight new --live harness rows that grep the SERVED stylesheet for every one of plan 02-03's six gem-behaviour overrides, closing the blind spot that let this ship unnoticed"
  - "verify.sh at 81 static / 105 live, 0 failed, 0 red-by-design"
  - "A human sign-off on the focus ring itself, recorded per check in 02-VALIDATION.md row 2-05-03"
affects: [02-close-out, 03-typography, 04-notebook-art, 05-page-components, 08-qa-audit]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - 'PurgeCSS matches its safelist against SELECTOR NODES, so a pseudo-class needs its leading colon — ":focus-visible" keeps the rule, "focus-visible" does not (measured against purgecss 8.0.0)'
    - "A rule that is correct in source is not evidence that it is live. Every deliberate CSS override earns a --live row that greps the CDN-served asset, not just a source-file grep"
    - "Fix a purge-stripping bug in the purge config, not in the SCSS: the source file stays byte-identical and the deploy becomes a single-variable experiment"

key-files:
  created:
    - .planning/phases/02-palette-and-design-tokens/02-05-SUMMARY.md
  modified:
    - purgecss.config.js
    - .planning/phases/02-palette-and-design-tokens/verify.sh
    - .planning/phases/02-palette-and-design-tokens/02-VALIDATION.md

key-decisions:
  - "Fixed the stripped focus ring with a PurgeCSS safelist entry rather than rewriting the selector, because the concrete-selector rewrite measurably loses two of its five selectors on this site's HTML today and would silently lose more as the markup changes"
  - "Safelisted h5 and h6 in the same edit — free, since the fix was already a safelist change, and it means a future <h5> inherits heading ink with no config change"
  - "_sass/ was not touched at all by this plan, so criterion 5 (no literals outside the token file) and must-have #19 stay true by construction rather than by re-verification"
  - "The --deploy-proof canary was deliberately NOT re-dated: the new focus-ring grep is itself the proof this build shipped, and leaving the canary alone kept the deploy a single-variable experiment"
  - "The phase close-out tag target moves off 0a7c7b0 onto 482c740 — the commit gh-pages@54483db records deploying. No tag was created by this plan"

patterns-established:
  - "Pattern: a bare pseudo-class rule (:target, :focus-within, :focus-visible) has no tag or class node for PurgeCSS's default extractor and ships as dead source unless safelisted"
  - "Pattern: the six-override group is now asserted as a GROUP against the served stylesheet, so the next rule PurgeCSS strips turns a harness row red instead of reaching a verifier"
  - "Pattern: a human checkpoint that follows an already-approved sweep asks only about what changed since — 02-04's seven-page sweep was explicitly not re-requested"

requirements-completed: [TOKEN-01, GROUND-04]

# Metrics
duration: 162min
completed: 2026-09-15
---

# Phase 2 Plan 05: Focus-Ring PurgeCSS Gap Closure Summary

**The 2px `--ink-900` keyboard focus ring that has been correct in `_sass/_custom.scss` since 02-03 is now actually in the stylesheet the CDN serves — one PurgeCSS safelist entry fixed it, eight new `--live` rows make the next silently-stripped rule impossible to miss, and a human confirmed the ring reads as a ring.**

## Performance

- **Duration:** 162 min wall clock (of which ~83 min was the blocking human checkpoint; agent work ~79 min across two sessions)
- **Started:** 2026-09-15T02:56:00Z (plan commit `d825f93`)
- **Completed:** 2026-09-15T05:38:07Z (verdict commit `5724e90`)
- **Tasks:** 3 of 3
- **Files modified:** 3 (plus this SUMMARY)

## Accomplishments

1. **The gap `02-VERIFICATION.md` found is closed in production.** PurgeCSS was deleting the bare `:focus-visible` rule from every build between 2026-09-14 and this commit, so keyboard users on the live site got the browser default instead of the site's contrast-measured ring. `purgecss.config.js` now safelists `":focus-visible"` — with the leading colon, which is load-bearing.
2. **Heading ink reaches production at all six levels.** Production served `h1,h2,h3,h4,.post-title` before this plan; `h5`/`h6` were dropped because no page renders those tags. Safelisting them cost two strings in the same edit.
3. **The blind spot that let this ship is closed too.** The phase's 95-check live harness never inspected the served stylesheet for these rules; it checked source. Eight new rows now grep the CDN-served `main.css` for all six of plan 02-03's gem-behaviour overrides as a group.
4. **`_sass/` is byte-identical to what 02-03 shipped.** `git diff 0a7c7b0..HEAD -- _sass/` is empty, and there is still no `outline: none` anywhere in `_sass/`.
5. **The ring was looked at by a human**, keyboard-only, on two live pages, and approved on all three checks.

## Task Commits

| Task | Name                                                                                       | Commit                                                        |
| ---- | ------------------------------------------------------------------------------------------ | --------------------------------------------------------------- |
| 1    | Safelist the focus ring, and teach the harness to grep the served CSS for all six overrides | `482c740`                                                     |
| 2    | One push, then prove the focus ring is in the served stylesheet                             | deploy rode on `482c740`; label strip committed as `b5e3be6`  |
| 3    | Tab through two live pages and confirm the ring reads as a ring                             | `5724e90`                                                     |

## The deploy, measured

| Fact                  | Value                                                        |
| --------------------- | ------------------------------------------------------------ |
| Pushed tip (full SHA) | `482c7405b06f7b80bbb101fc25779b8bb8431a36`                   |
| Push type             | fast-forward, `0a7c7b0..482c740`, one push, never `--force`  |
| Deploy run            | `34927923593` — **success**                                  |
| Prettier run          | `34927923606` — **success**                                  |
| `gh-pages` before     | `2e763c1bb1e2d71df691c9b13ab26b5ca5187ee7`                   |
| `gh-pages` after      | `54483dba3691b569bc82b65183d7c286ab822e54` (advanced at t≈92s) |
| New CSS served        | by t≈112s after the push                                     |

That is the **third** measurement of this repo's push-to-served-CSS latency: ~112s here, against 145-168s in 02-04 and ~124s in Phase 1. The 2-3 minute band holds; this run sat at its fast end.

### The rule, as the served file carries it

```css
:focus-visible {
  outline: var(--focus-ring-width) solid var(--ink-900);
  outline-offset: var(--focus-ring-offset);
}
h1,
h2,
h3,
h4,
h5,
h6,
.post-title {
  color: var(--ink-900);
}
```

(Served minified on one line each; expanded here for reading.) The two pre-existing gem rules (`.af-table-search:focus-visible`, `.calendar-toggle-btn:focus-visible`) also match a naive grep and are **not** the proof — they survived all along because their class names appear in the built HTML. The bare rule is the one that was missing.

## Harness tallies

|               | Before               | After                                                                                    |
| ------------- | -------------------- | ------------------------------------------------------------------------------------------ |
| Static        | 79 checks, 0 failed  | **81 checks, 0 failed**                                                                  |
| `--live`      | 95 checks, 0 failed  | **105 checks, 0 failed**                                                                 |
| Red-by-design | 0                    | **0** — all three deploy labels removed in `b5e3be6` once their rows went green           |

## The human checkpoint: APPROVED, per check

Row `2-05-03`, 2026-09-15. Keyboard only, no mouse, on `https://phamhakhanhchi.com/` and `https://phamhakhanhchi.com/cv/`.

| Check | Question                                                          | Verdict                                                       |
| ----- | ------------------------------------------------------------------- | --------------------------------------------------------------- |
| E     | Is the ring there at all, on navbar and body-copy links?          | **APPROVED** — the site's own outline appears on keyboard focus |
| F     | Does the 2px offset clear the glyphs and the Vietnamese marks?     | **APPROVED** — visible gap, no collision with `ạ` or `ợ`      |
| G     | Does it read on the CV download/view buttons?                     | **APPROVED** — surrounds the whole button, visible, not clipped |

**No token change follows.** `--focus-ring-width: 2px` and `--focus-ring-offset: 2px` stand exactly as shipped; none of the three offered fallbacks ("too tight", "too faint", "invisible on the buttons") fired. This is the second value in Phase 2 — after `--underline-offset` — that was a computed guess and is now eye-verified.

02-04's seven-page sweep was deliberately **not** re-requested. This checkpoint asked only about what changed since it was approved.

## Files Created/Modified

- `purgecss.config.js` — one commented safelist group appended: `":focus-visible"`, `"h5"`, `"h6"`. `content`, `css`, `output` and `skippedContentGlobs` untouched.
- `.planning/phases/02-palette-and-design-tokens/verify.sh` — 2 new static rows, a widened Prettier row (now covers `purgecss.config.js`), 8 new `--live` rows, and the three deploy labels removed once green.
- `.planning/phases/02-palette-and-design-tokens/02-VALIDATION.md` — rows `2-05-01..03` (now all green), a new Manual-Only row for the focus ring, the `2-05-03` verdict block, and a corrected sampling-continuity note naming both manual tasks.
- `.planning/phases/02-palette-and-design-tokens/02-05-SUMMARY.md` — this file.

## Decisions Made

- **Safelist, not selector rewrite.** Both candidates were measured against purgecss 8.0.0 on a fixture reproducing this site's markup. The concrete-selector rewrite keeps the rule but PurgeCSS deletes `input:focus-visible` and `[tabindex]:focus-visible` from the list — neither token exists in the built HTML today, and coverage would keep eroding as markup changes. The bare rule covers every focusable element, now and in Phase 5/6.
- **The leading colon is not cosmetic.** `"focus-visible"` without it does not match and is not a substitute. Measured, not assumed.
- **Rejected the universal-selector workaround.** It works, but it is a one-character change whose reason survives only in a comment, and it teaches nothing to the next bare pseudo-class rule. The fix belongs in `purgecss.config.js`, which is where the next agent writing `:target` or `:focus-within` will look.
- **The canary stayed at its 02-04 date.** Re-dating it would have added a second changed file and muddied the single-variable experiment.

## Deviations from Plan

None — plan executed exactly as written: one safelist edit, ten new harness rows, one push, one deploy, one checkpoint.

## Deferred

- **`purgecss` is installed unpinned in `deploy.yml`** (`npm install -g purgecss`), so a future major release could change safelist semantics under us. Out of scope here and deliberately not fixed; the eight new `--live` rows are what catch it if it happens.

## Phase close-out: the tag target has MOVED

**The annotated tag `design-02-<slug>` must now point at `482c740`, not `0a7c7b0`.** `0a7c7b0` was the right target as of 02-04, but this plan deployed again: `482c740` is the commit that `gh-pages@54483dba3691b569bc82b65183d7c286ab822e54` records deploying, and it is what is live. Tagging `0a7c7b0` would now tag a superseded stylesheet — one that ships no focus ring.

**No tag was created by this plan.** Tagging is phase close-out, and the plan explicitly forbade it here. `STATE.md`'s pending-todo and the Phase 1 convention (tag the commit that PRODUCED what is live, read off the `gh-pages` commit subject, never local HEAD) both carry forward unchanged — only the SHA moves.

Commits sitting unpushed at close are `.planning/**` only and on `deploy.yml`'s denylist.

## Issues Encountered

None that cost a retry. The three labelled rows went green on the first live run after the deploy; no grep needed loosening for minified whitespace.

## User Setup Required

None.

## Next Phase Readiness

Phase 2 is functionally complete and the last known gap is closed. What remains is close-out only: the annotated tag on `482c740`, and setting `02-VALIDATION.md`'s frontmatter `status:` the way Phase 1 closed. Phase 3 (Typography) inherits two things it must not re-litigate: `max_width: 930px` is untouched on purpose (it is TYPE-04), and `--underline-offset: 0.18em` — and now the focus ring's 2px offset — are eye-verified **at the gem's default face and sizes only**. Changing the body face reopens both.

## Self-Check: PASSED

All four named files exist. All three commit hashes (`482c740`, `b5e3be6`, `5724e90`) resolve. Every load-bearing claim re-checked at close: `git diff 0a7c7b0..HEAD -- _sass/` is empty, `grep -rE "outline:[[:space:]]*none" _sass/` finds nothing, `purgecss.config.js` carries `":focus-visible"`, `git ls-remote origin refs/heads/gh-pages` returns `54483dba3691b569bc82b65183d7c286ab822e54` exactly as recorded, and the served `main.css` still carries both the bare focus-ring rule and the six-level heading selector. Static harness 81/0, live harness 105/0.

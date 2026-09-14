---
phase: 02-palette-and-design-tokens
plan: 04
subsystem: infra
tags: [jekyll-config, liquid-gates, dark-mode, deploy, cdn, purgecss, human-verification]

# Dependency graph
requires:
  - phase: 02-palette-and-design-tokens
    plan: 02
    provides: "_sass/_tokens.scss and its `:root, html[data-theme=\"dark\"]` selector list — the half of TOKEN-04 that `enable_darkmode: false` cannot do, because the flag is a Liquid gate and the gem's dark CSS block ships unconditionally"
  - phase: 02-palette-and-design-tokens
    plan: 03
    provides: "_sass/_custom.scss — the six gem overrides, the body-copy underlines, and the re-dated `--deploy-proof` canary this plan grepped out of the CDN-served stylesheet"
  - phase: 02-palette-and-design-tokens
    plan: 01
    provides: "verify.sh's --live block: seven page fetches, the served-CSS greps and the served-HTML zero-counts that turned the deploy from a claim into a measurement"
  - phase: 01-deployment-guardrails
    plan: 02
    provides: "deploy.yml's paths-ignore denylist and CNAME gate — without them a `_sass`-only design phase never reaches production"
provides:
  - "_config.yml with enable_darkmode, enable_progressbar and footer_fixed all false — the Liquid half of TOKEN-04"
  - "The entire phase live on phamhakhanhchi.com in ONE deploy: 21 commits, one fast-forward push, no half-repainted state"
  - "verify.sh at 95 checks / 0 failed / 0 red-by-design — the phase's first fully green live run, and the end of the [red until plan 02-NN] labels"
  - "A human sign-off on all four manual checks, recorded per check in 02-VALIDATION.md row 2-04-03"
  - "A second measurement of this repo's push-to-served-CSS latency (145-168s), against Phase 1's ~124s"
affects: [03-typography, 04-notebook-art, 05-page-components, 07-mobile-print, 08-qa-audit]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "A config flag and the CSS it depends on ship in the SAME deploy when the flag is what puts a class into the HTML PurgeCSS scans — splitting them strips the rules that were about to become live"
    - "Batch every manual check of a phase into one blocking checkpoint at the end of the last plan, after the automated block is green, so the reviewer looks once at a finished thing"
    - "Red-by-design labels are removed the moment their rows go green, in their own commit, so a later regression cannot hide inside the EXPECTED_RED tally"

key-files:
  created:
    - .planning/phases/02-palette-and-design-tokens/02-04-SUMMARY.md
  modified:
    - _config.yml
    - .planning/phases/02-palette-and-design-tokens/verify.sh
    - .planning/phases/02-palette-and-design-tokens/02-VALIDATION.md

key-decisions:
  - "The three flags are Liquid gates verified against the gem's includes BEFORE flipping (footer.liquid:14, head.liquid:128, header.liquid:127/141, scripts.liquid:107), not guessed from their names — and `enable_darkmode: false` is explicitly only half of TOKEN-04; the CSS half is 02-02's selector list."
  - "No padding override was added for the un-fixed footer. The gem's _layout.scss:27 already zeroes body{padding-bottom:70px} under body.sticky-bottom-footer, so a hand-written dead-space fix would have been a second, conflicting owner of the same value."
  - "max_width: 930px deliberately untouched — the measure is TYPE-04 and belongs to Phase 3, even though the line sits seven lines from an edited flag."
  - "The single push carried all 21 commits of the phase, fast-forward, never --force. The phase's hard ordering constraint exists precisely to prevent a visitor with data-theme=\"dark\" stored meeting a half-repainted page."
  - "The two visual bets went to the human as EXPLICIT questions with their fallbacks pre-decided (a --rule-200 hairline for the flush .card; a one-line token change for the underline offset). Both were approved as-is, so neither contingency fires and Phase 4/5 inherit no debt."
  - "Requirements are marked complete HERE and nowhere earlier: 02-01, 02-02 and 02-03 each deliberately declined, because a plan's `requirements:` field means 'contributes to', not 'completes'."

patterns-established:
  - "Deploy verification order, now used twice: full-40-char-SHA run poll -> gh-pages ls-remote -> cache-busted served-asset grep. Only the last one proves the rule survived PurgeCSS."
  - "The phase's manual checkpoint writes its verdict into the VALIDATION document as a dated per-check table, not only into the summary prose — the validation contract is where a future reader looks for whether a criterion was ever actually seen."

requirements-completed: [TOKEN-01, TOKEN-02, TOKEN-03, TOKEN-04, TOKEN-05, TOKEN-06, GROUND-01, GROUND-04]

# Metrics
duration: 92min
completed: 2026-09-14
---

# Phase 2 Plan 04: One Push, and the Human Look Summary

**Three Liquid gates off, twenty-one commits pushed as a single deploy, and the warm-paper repaint proven on the CDN by grepping the served stylesheet — then signed off by a human across seven pages, a forced `data-theme="dark"` and a greyscale screenshot. The phase harness ended at 95 checks, 0 failed, 0 red-by-design.**

## Performance

- **Duration:** 92 min wall clock — of which ~38 min was the blocking human checkpoint and ~3 min was deploy latency. Agent-active work was roughly 20 min.
- **Started:** 2026-09-14T15:20Z
- **Completed:** 2026-09-14T16:52Z
- **Tasks:** 3 (2 automated, 1 blocking human-verify)
- **Files modified:** 3 (`_config.yml`, `verify.sh`, `02-VALIDATION.md`)

## Accomplishments

- **The phase is live.** `origin/main` advanced `59e0e03` -> `0a7c7b0` in one fast-forward push carrying all 21 commits of Phase 2 — the token file, `_custom.scss`, `assets/css/main.scss`, `.al-folio-overrides.yml`, `_config.yml`, `CLAUDE.md` and the planning docs. No force, no split, no intermediate state where the navbar was cream and the cards were still white.
- **The harness went fully green for the first time: 95 checks, 0 failed, 0 red-by-design.** It has been red by design since plan 02-01 created it (59 red), through 02-02 (14) and 02-03 (3). Every `[red until plan 02-NN]` label is now gone; a red row from here on is a real regression.
- **The repaint was proven on the CDN, not on `main`.** The served `main.css` contains `--paper-100`, `--global-bg-color:var(--paper-100)`, `--global-code-bg-color:var(--paper-200)`, `sticky-bottom` and the exact `--deploy-proof: "2026-09-14 phase-02-tokens"` canary; the served home HTML contains zero `light-toggle`, zero `fixed-bottom` and zero `progress-bar`. All seven pages return 200.
- **`sticky-bottom` came back on its own, exactly as predicted.** It was absent from the previously served CSS because PurgeCSS had stripped `footer.sticky-bottom` while no HTML used the class. Flipping `footer_fixed` put the class into the built HTML before PurgeCSS scanned, so the rules returned with no safelist entry — the single clearest vindication of this phase's one-deploy constraint.
- **A human confirmed the three things no tooling on this machine can check**, across all seven live pages, and approved both outstanding visual bets. Details below.

## Task Commits

1. **Task 1: Flip the three config flags and take the phase static-green** — `0a7c7b0` (feat)
2. **Task 2: Push once, then prove the repaint reached the CDN** — `952821d` (chore)
3. **Task 3: Seven-page sweep, dark-attribute force, greyscale link check** — `debaaec` (docs)

**Plan metadata:** see the final `docs(02-04)` commit.

`0a7c7b0` is the pushed tip and the commit `gh-pages` records deploying. `952821d` and `debaaec` are deliberately **unpushed**: both touch only `.planning/**`, which sits on `deploy.yml`'s denylist, and this phase grants exactly one contact with the remote.

## The deploy, measured

| Fact | Value |
| --- | --- |
| Pushed SHA (full 40 char) | `0a7c7b0608b1be16b93e2d052dade66b543fbf06` |
| `origin/main` before -> after | `59e0e03` -> `0a7c7b0` (fast-forward, 21 commits) |
| Deploy run | `34866984325` — **success**, ~138s |
| Prettier run | `34866984321` — **success** |
| `origin/gh-pages` before -> after | `9d0d929c…` -> `2e763c1bb1e2d71df691c9b13ab26b5ca5187ee7` |
| Push -> new CSS served | between **t=145s and t=168s** (Phase 1 measured ~124s) |
| `verify.sh --live` | 95 checks, 0 failed, exit 0 — green on the first run |

The latency figure is worth carrying forward: it is slower than Phase 1's ~124s and the gap is still GitHub's separate "pages build and deployment" run, which `deploy.yml` does not wait on. Treat ~2-3 minutes as the band and poll; a single refresh at t=120s can still show the old stylesheet and is not evidence of failure.

## The human checkpoint: APPROVED, per check

Row `2-04-03` of `02-VALIDATION.md`, the only manual verification in the phase. The reviewer opened all seven live URLs in order.

| Check | Criterion | Verdict |
| --- | --- | --- |
| **A** | 1 — warm paper everywhere, no white panel, no dark bar | **APPROVED.** Cream ground behind navbar, body and footer on all seven pages. The projects page's cards carry no leftover white. The gem's `#1c1c1d` bottom bar is gone and the footer reads as the bottom of the page. The CV page's embedded PDF object and buttons are fine. |
| **B** | 2 — dark is unreachable | **APPROVED.** No toggle anywhere, and `document.documentElement.setAttribute('data-theme','dark')` changed no colour. The `:root, html[data-theme="dark"]` list wins on source order exactly as 02-02 designed. |
| **C** | 3 — links survive greyscale | **APPROVED.** Under Achromatopsia emulation every body-copy link remains obviously a link; underlines clear the descenders and the Vietnamese marks. Bare navbar and footer links confirmed as intended. |
| **D** | register sanity | **APPROVED.** Reads as a deliberate, tasteful recolour on warm paper — not broken, not unfinished. |

**Both visual bets were accepted as-is, so neither fallback fires:**

- **The flush, shadowless projects `.card` reads as deliberate.** The pre-decided fallback — a `--rule-200` hairline boundary in Phase 4 or 5 — is not needed, and a re-added shadow was never the fix.
- **`--underline-offset: 0.18em` clears the diacritics in "Phạm Hà Khánh Chi".** It was a computed guess that had never been rendered; it is now an eye-verified value. No token change follows, and Phase 3 inherits a settled offset rather than an open question.

## Files Created/Modified

- `_config.yml` — three flags, six lines: `footer_fixed: false` (line 99), `enable_darkmode: false` (474), `enable_progressbar: false` (478). Each is a Liquid gate in the gem's includes, not CSS. `max_width: 930px` untouched.
- `.planning/phases/02-palette-and-design-tokens/verify.sh` — the three static labels dropped in Task 1, then all 37 remaining `[red until plan 02-NN]` labels stripped in Task 2. `EXPECTED_RED` is now 0; the labelling mechanism itself is retained for later phases.
- `.planning/phases/02-palette-and-design-tokens/02-VALIDATION.md` — all eleven Per-Task Verification Map rows green, `wave_0_complete: true`, and the dated per-check verdict table for row `2-04-03`.

## Decisions Made

- **`enable_darkmode: false` is only half of TOKEN-04, and the summary says so on the record.** The flag drops `theme.js`, `initTheme()`, the dark Pygments sheet and the `#light-toggle` button; it does not remove the gem's compiled `html[data-theme="dark"]` CSS block. Check B passing is joint evidence for both halves — it is the only check in the phase that could have caught a selector-list failure.
- **No footer dead-space override.** The gem already zeroes the 70px body padding under `body.sticky-bottom-footer`; writing a second rule for the same value would have created two owners and a future conflict.
- **`max_width` left alone** despite sitting seven lines from an edited flag. The measure is TYPE-04, and Phase 3 owns it.
- **The unpushed tail is intentional and must stay that way.** Anyone resuming should not "tidy up" by pushing `952821d` and `debaaec`; the next legitimate remote contact is Phase 2's close-out tag on `0a7c7b0`.

## Deviations from Plan

**None — plan executed exactly as written.** All three flags were at the line numbers the plan named; the gem include references checked out; the live block went green on its first run with no whitespace-tolerance fix needed against the minified CSS; and the checkpoint returned a clean approval with no page or check failing.

The one judgement call worth recording is not a deviation but the discharge of a standing todo: **`requirements mark-complete` was run here for all eight of the phase's requirements**, after three consecutive plans deliberately declined to run it. See below.

## Requirements: eight marked Complete, for the first time in the phase

`TOKEN-01, TOKEN-02, TOKEN-03, TOKEN-04, TOKEN-05, TOKEN-06, GROUND-01, GROUND-04` all move to Complete in `REQUIREMENTS.md`, closing the pending todo carried since plan 02-01.

Every requirement in this phase was claimed by several plans at once (TOKEN-01 by all four), so each earlier plan recorded a refusal rather than posting a false green. The gate they were all waiting on — `verify.sh --live` fully green **plus** the human sweep — is now satisfied:

- **TOKEN-01** — all 30 `--global-*` re-pointed, verified name-by-name against the served CSS; no gem file shadowed.
- **TOKEN-02** — `--step-*` and `--space-*` exist as named tokens and `_custom.scss` consumes them.
- **TOKEN-03** — no text is faded by a transparency value; the four muted classes measure 6.99:1.
- **TOKEN-04** — the toggle is gone from the served HTML (zero `light-toggle`) and forcing the attribute changes nothing (check B).
- **TOKEN-05** — the `:root, html[data-theme="dark"]` selector list IS the reintroduction hook; a future dark theme re-points values, not structure.
- **TOKEN-06** — the cap is written in `_tokens.scss` three lines above the primitives and is machine-checked.
- **GROUND-01** — warm paper on all seven pages, confirmed live and by eye (check A).
- **GROUND-04** — body-copy links underlined and identifiable in greyscale (check C).

## Issues Encountered

- **None during execution.** The two known tooling defects were worked around as STATE.md prescribes rather than discovered: the `gsd-tools` roadmap and state writers are unreliable against this repo's hand-maintained documents, so the ROADMAP row and STATE.md position were edited by hand and diffed afterwards.
- **A note for whoever runs the next live block:** the served CSS is minified, so `--global-bg-color:var(--paper-100)` has no space after the colon. The harness's greps were already whitespace-tolerant and needed no fix, but a hand-typed grep with a space will return nothing and look like a failed deploy.

## User Setup Required

None. The one action that needed a human — the seven-page sweep — is complete and recorded.

## Next Phase Readiness

**Phase 2 is functionally finished.** What remains is close-out, not work:

1. **Tag `design-02-<slug>` on `0a7c7b0`**, not on local HEAD. `0a7c7b0` is the commit that produced what is live, read off `gh-pages`; `952821d` and `debaaec` are planning-only and never deployed. Pushing a tag does not deploy, but it is not inert — see the Phase 1 decision about workflows being evaluated at the tagged commit.
2. **`02-VALIDATION.md` is 11 of 11 green** with the manual row signed off; its frontmatter `status:` is left for close-out to set, matching how Phase 1 closed.

**Phase 3 (Typography) inherits a clean base:**

- Every rule is already `var(--…)`, so type work adds families and sizes without touching colour.
- `--step-0..3` exists but is currently a scale with no typeface opinion behind it — Phase 3 sets `max_width` (TYPE-04) and the `google_fonts` URL in the same `_config.yml` this plan just edited.
- `--underline-offset: 0.18em` is eye-verified against Vietnamese below-baseline marks at gem sizes. **If Phase 3 changes the body face or its size, that verification does not carry over** and the offset needs looking at again — it is the one value in this phase whose correctness is font-dependent.
- The deploy path is now demonstrated twice end to end, and the canary in `_custom.scss` must survive Phase 3 untouched.

**Concerns:** the CRLF override-hash caveat from 02-02 is still the only latent false-red in the harness, still logged in `deferred-items.md`, and still cannot fire on this machine.

---

_Phase: 02-palette-and-design-tokens_
_Completed: 2026-09-14_

## Self-Check: PASSED

All three modified files exist. `_config.yml` reads `footer_fixed: false` (line 99), `enable_darkmode: false` (474) and `enable_progressbar: false` (478), with `max_width: 930px` intact at line 106. All three task commits are in `git log` (`0a7c7b0`, `952821d`, `debaaec`), and `git ls-remote` confirms `origin/main` at `0a7c7b0608b1be16b93e2d052dade66b543fbf06` with the two planning commits correctly unpushed, and `origin/gh-pages` at `2e763c1bb1e2d71df691c9b13ab26b5ca5187ee7`. `verify.sh --live` was re-run at summary time: **95 checks, 0 failed**. The "zero red-by-design labels" claim was checked rather than asserted — the single surviving match for the label text is prose at line 410, plus the counting mechanism itself at line 150, which is retained on purpose for later phases; no check row carries a label.

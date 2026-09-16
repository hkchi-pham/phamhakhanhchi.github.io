---
phase: 03-typography
plan: 02
subsystem: ui
tags: [webfonts, google-fonts, css2, literata, be-vietnam-pro, design-tokens, type-scale, custom-properties, scss, purgecss-adjacent]

# Dependency graph
requires:
  - phase: 03-typography
    provides: "Plan 03-01's two settled decisions (`status-serif`, `title-full`), the 44.2px note, the 38-row static harness this plan turns green, and fontbudget.js with its FONTS_URL env fallback"
  - phase: 02-palette-and-design-tokens
    provides: "_sass/_tokens.scss as the one file permitted to hold literals; the locked --step-N / --leading-body names with values explicitly reserved for Phase 3; the 930px max_width and the 0.18em --underline-offset this plan must not change"
provides:
  - "The single css2 fonts request: two families, five cuts, display=swap, 141,232 B measured"
  - "--font-serif and --font-sans — the only two type families this site has"
  - "--step-0..--step-5 as calc() against --step-1: 1.0625rem, so the 1.8x and 1.35x ratios are greppable in the served CSS"
  - "--leading-body: 1.6, --leading-heading: 1.2, --measure: 36rem"
  - "A TOKEN-06 cap line that reads 2 and says WHY it is two and not three"
  - "test/style_contract.js narrowed to enforce only `fontawesome` of the three icon CDNs"
affects: [03-03, 03-04, 04-marginalia, 05-page-composition, 06-hero, 07-mobile-print, 08-qa-audit]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "A ratio a criterion measures is written as calc() against its base, never as a pre-divided literal, so the criterion is a grep rather than an act of trust"
    - "Deleting an upstream-demo requirement from a shipped gate NARROWS the matcher with an in-file DISABLED/NARROWED note, following the two blocks this fork already disabled that way"
    - "A token's comment carries the arithmetic that justifies its value, so the next agent can re-derive the decision instead of re-litigating it"

key-files:
  created: []
  modified:
    - _config.yml
    - _sass/_tokens.scss
    - test/style_contract.js

key-decisions:
  - "The fonts URL as written, verbatim: https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;600&family=Literata:ital,wght@0,400;0,600;1,400&display=swap — the italic axis kept per decision (A) `status-serif`."
  - "preconnect, preload, a font-display config key and third_party_libraries.download were all deliberately NOT touched. 03-RESEARCH Finding 12: no such key exists, <head> is gem-owned, and `download` is global to ALL third-party libraries — flipping it would self-host Font Awesome, bootstrap-table, MathJax and highlight.js in one move and create assets/webfonts/, which the style contract still forbids. display=swap plus metric-close fallbacks is the entire loading strategy available to this phase."
  - "display=swap kept over display=optional: a cold-cache first visit would otherwise render the whole typography phase in the fallback."
  - "test/style_contract.js's icon-CDN loop narrowed from [fontawesome, academicons, scholar-icons] to [fontawesome]. Upstream requires all three because the al-folio DEMO renders ai-/si- glyphs; this site renders none. The forbidden-glob block still rejects starter-owned academicons/scholar-icons font artifacts, so icon-runtime OWNERSHIP is unchanged."
  - "--step-5 left at 2.6 (44.2px) and NOT raised to 48px, per plan 03-01. The 44.2px note is now recorded in the token file as well, making four places that agree."
  - "--underline-offset left at 0.18em. Literata's descenders are ~26% deeper relative to em than Roboto's, but whether they collide with ạ/ợ is a browser observation, and 03-04's checkpoint owns it."
  - "--measure placed with the type scale rather than with --subject-row-max, because its 70.6-CPL arithmetic only makes sense next to --step-1."

patterns-established:
  - "The calc() scale: --step-1 is the only literal in the scale and every other step is a ratio against it, so re-tuning the body size moves the whole scale coherently and no ratio can drift silently."
  - "A comment that records a NON-action (preconnect, download, the 48px non-resize, the monospace non-family) sits next to the thing it did not do, so the gap reads as a decision rather than an oversight."

requirements-completed: [TYPE-01, TYPE-02, TYPE-04, TYPE-05]

# Metrics
duration: 12min
completed: 2026-09-16
---

# Phase 3 Plan 02: The Fonts Request and the Type Tokens Summary

**A single css2 request for five cuts of two families at 141,232 measured bytes, three dead icon CDNs deleted, and the whole type scale re-expressed as greppable calc() ratios against a 17px base — 18 of the harness's 26 red rows turned green.**

## Performance

- **Duration:** ~12 min
- **Started:** 2026-09-16T09:38:00Z
- **Completed:** 2026-09-16T09:46:00Z
- **Tasks:** 2 of 2
- **Files modified:** 3 (one more than the plan's two — see Deviations)

## The fonts URL, as written

This is the exact string now in `_config.yml` under `third_party_libraries.google_fonts.url.fonts`. Plan 03-03 and 03-04 should compare against this rather than re-deriving it:

```
https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;600&family=Literata:ital,wght@0,400;0,600;1,400&display=swap
```

The `ital,` prefix and the `;1,400` pair are present, per plan 03-01's decision (A) `status-serif`. `display=swap` is present. Nothing else is requested.

Measured against that exact string with `FONTS_URL=… node .planning/tools/fontbudget.js --max 153600`:

```
TOTAL: 141232 B (137.9 KiB, 141.2 kB) over 8 unique file(s)
BUDGET: 153600 B (150.0 KiB)
USED: 91.9%
HEADROOM: 12368 B
```

Byte for byte identical to 03-RESEARCH Finding 3 and to plan 03-01's baseline. The five Vietnamese cuts resolve as Be Vietnam Pro 400 (11,532 B), Be Vietnam Pro 600 (12,176 B), Literata 400 italic (5,196 B), Literata 400 (8,984 B) and Literata 600 (the same file as 400 — a shared variable font, de-duplicated by the tool).

## What was deleted, and what was deliberately kept

**Deleted from `_config.yml`:**

- The old v1 `css?family=Roboto:…|Roboto+Slab:…|Material+Icons&display=swap` string. **Material Icons, Roboto and Roboto Slab were named only there**, so replacing that one line is what drops all three.
- The `academicons:` block (integrity / url / version).
- The `scholar-icons:` block (integrity / url / version).

Together: 14,063 B and two render-blocking requests for zero visual change. `_data/socials.yml` has only `email` active, and the deployed pages carry zero `ai-` and zero `si-` classes.

**Kept, deliberately:**

- `fontawesome:` — the one envelope icon is a Font Awesome solid glyph. Inline-SVG replacement is Phase 6's.
- `max_width: 930px` — unchanged, and there is an unlabelled green harness row watching it.
- `--underline-offset: 0.18em` — unchanged, for 03-04's checkpoint to judge against Literata.

**NOT touched, and this is a decision rather than an omission:** no `preconnect`, no `preload`, no `font-display` config key, and `third_party_libraries.download` still `false`. 03-RESEARCH Finding 12 settled this: no such config key exists, the `<head>` is gem-owned and emits the fonts link as `<link defer rel="stylesheet">` (`defer` being inert on `<link>`), and `download` is global to **all** third-party libraries — flipping it would self-host Font Awesome, bootstrap-table, MathJax and highlight.js in one move and create `assets/webfonts/`, which the style contract's forbidden-glob block still rejects. `display=swap` plus metric-close fallbacks is the entire loading strategy available to this phase.

## Token names now available to plan 03-03

Plan 03-03 consumes these and must not re-derive or rename them. All are declared in `_sass/_tokens.scss` inside the Tier 1 `:root` block.

| Token              | Value                         | Computed        | Intended consumer                 |
| ------------------ | ----------------------------- | --------------- | --------------------------------- |
| `--font-serif`     | `Literata, Georgia, "Times New Roman", serif` | —   | body, prose, headings, `.entry-status` italic |
| `--font-sans`      | `"Be Vietnam Pro", -apple-system, "Segoe UI", Roboto, Arial, sans-serif` | — | `.entry-year`, `.entry-meta`, `.subject-grade`, `.nav-link` |
| `--step-1`         | `1.0625rem`                   | 17px            | body — the only literal in the scale |
| `--step-0`         | `calc(var(--step-1) * 0.85)`  | 14.45px         | meta, status, grade               |
| `--step-2`         | `calc(var(--step-1) * 1.15)`  | 19.55px         | `.entry-title`, h4                |
| `--step-3`         | `calc(var(--step-1) * 1.35)`  | 22.95px         | h3 — criterion floor is 1.25      |
| `--step-4`         | `calc(var(--step-1) * 1.8)`   | 30.6px          | h2 — criterion floor is 1.5       |
| `--step-5`         | `calc(var(--step-1) * 2.6)`   | **44.2px**      | h1, `.post-title`                 |
| `--leading-body`   | `1.6`                         | —               | body copy (was the gem's 1.5)     |
| `--leading-heading`| `1.2`                         | —               | h1–h6                             |
| `--measure`        | `36rem`                       | 576px, ~70.6 CPL | `.post article > …` prose column  |

`--step-4` and `--step-5` are **new names**, not re-tuned values. Phase 2 locked the names and reserved the values for Phase 3; widening the locked set is recorded in the block comment rather than done quietly, because the 2.6 / 1.8 scale needs steps the provisional four did not have (the old `--step-3` was standing in for every heading level at once).

**`--step-5` is 44.2px and stays 44.2px.** Fourth recorded agreement on this point, after 03-01-SUMMARY, `verify.sh`'s header note (c) and `03-VALIDATION.md`.

## Accomplishments

- **The browser is now asked for exactly the five locked cuts of exactly two families**, and for nothing that renders nothing. Verified by measurement, not assertion: the `--live` harness block confirms 5 `/* vietnamese */` blocks, `U+1EA0-1EF9` coverage, `format('woff2')` rather than the UA-less truetype fallback, and the payload inside 153,600 B.
- **All four `[red until plan 03-02]` live rows are GREEN**, which is the payoff of 03-01's decision to label the fonts rows against this plan rather than against the deploy: this plan got live feedback at its own wave.
- **The static harness went from 26 failures to 8**, and all 8 remaining are `[red until plan 03-03]`. `UNLABELLED` is 0.
- **Criterion 4's ratios are now automatable.** `--step-4: calc(var(--step-1) * 1.8)` is a grep in this file and, after 03-04's push, in the served stylesheet. As literal rems the same fact would have been a division across two numbers with no protection against a future tidy-up.
- **The cap is a record rather than a promise.** `type families ...... 2  (Phase 3: Literata + Be Vietnam Pro)`, with the reason for two-not-three written beside it.

## Task Commits

1. **Task 1: Rewrite the fonts request and drop the three dead icon CDNs** — `61d8104` (chore)
2. **Task 2: Declare the families, the scale, the measure and the leading** — `4943981` (feat)

## Files Created/Modified

- `_config.yml` (modified, −13 / +1) — `google_fonts.url.fonts` rewritten to the css2 two-family request; `academicons:` and `scholar-icons:` blocks deleted. `fontawesome:` and `max_width: 930px` untouched.
- `_sass/_tokens.scss` (modified, +97 / −10) — the cap line filled; `--font-serif` / `--font-sans` added with their measured fallback-order justification; `--step-0`..`--step-5` re-expressed as `calc()`; `--leading-body` 1.5 → 1.6; `--leading-heading` and `--measure` added with the 70.6-CPL arithmetic and the ~354px gutter rationale in-comment.
- `test/style_contract.js` (modified, +20 / −1) — the icon-CDN loop narrowed to `["fontawesome"]` with an in-file NARROWED note. See Deviations.

## Decisions Made

See `key-decisions` in the frontmatter. The two that most constrain later plans:

1. **The fonts URL string is now fixed.** Any later edit to it re-opens the byte budget, which sits at 91.9% used with 12,368 B of headroom. There is no room for a third family or a sixth cut without removing something.
2. **`--step-1` is the only literal in the scale.** Re-tuning the body size moves every heading coherently; changing a *ratio* is what should require argument. Plan 03-03 should consume `var(--step-N)` and never re-divide.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] `test/style_contract.js` required the very icon blocks task 1 deletes**

- **Found during:** Task 1 (the fonts URL and the dead icon CDNs)
- **Issue:** Deleting the `academicons:` and `scholar-icons:` blocks made `node test/style_contract.js` exit 1 with two failures: "`_config.yml` must define `third_party_libraries.academicons` for al_icons runtime wiring" and the same for `scholar-icons`. That turned `verify.sh`'s **unlabelled green** row `Regress  node test/style_contract.js exits 0` red — an UNLABELLED failure, which the harness's own convention defines as a real regression rather than pending work. The plan anticipated a Jekyll build risk from this deletion but not a contract gate.
- **Why it is Rule 3 and not Rule 4 (ask):** the harness authored in 03-01 simultaneously asserts (a) `! grep -qE '^  (academicons|scholar-icons):' _config.yml`, red-until-03-02, and (b) `node test/style_contract.js exits 0`, unlabelled green. Both can only hold if the contract's matcher narrows. The harness itself specifies the resolution; there was no open question to put to the user. It is also the third application of a discipline this repo has now documented three times (02-02's comment-quoting rule, 02-03's value-aware opacity narrowing, 03-01's `!important` comment exemption): **when the gate and a correct implementation disagree, narrow the matcher and say why in-file — never delete the check, and never edit the implementation to satisfy a matcher.**
- **Fix:** the loop at `test/style_contract.js:40` narrowed from `["fontawesome", "academicons", "scholar-icons"]` to `["fontawesome"]`, with a 19-line `NARROWED FOR THIS SITE` comment above it, matching the format of the two `DISABLED FOR THIS SITE` blocks this fork already carries (the forbidden-path loop at the old lines 68–84 and the integration-path loop at 96–108). The comment records that upstream needs all three because the al-folio **demo** renders `ai-`/`si-` glyphs, that this site renders none, that `fontawesome` stays fully enforced including its SRI hash, and that the forbidden-glob block below still rejects starter-owned `academicons.woff` / `scholar-icons.woff` artifacts — so icon-runtime *ownership* is unchanged; this site simply stops wiring up two runtimes it never renders.
- **Files modified:** `test/style_contract.js`
- **Verification:** `node test/style_contract.js` → "Starter style contract check passed." `verify.sh`'s regression row is green again and `UNLABELLED` is back to 0. The `al_icons` plugin entry in `_config.yml`'s `plugins:` list — a separate assertion at line 33 — was not touched and still passes.
- **Committed in:** `61d8104` (Task 1 commit)
- **Consequence for the plan's stated verification:** `git diff --stat` shows **three** files, not the two the plan predicted. That is the only respect in which this plan's footprint exceeds its spec.

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** No scope creep — the third file is the minimum edit that lets task 1's specified deletion coexist with a gate the plan also requires to pass. No `_sass/_custom.scss` change (that is 03-03), no `purgecss.config.js` change (also 03-03), nothing pushed.

## Issues Encountered

- **The known risk the plan flagged is still unexercised, by design.** Whether the gem's `<head>` include reads the now-absent `academicons` / `scholar-icons` keys unconditionally cannot be checked here: there is no Ruby, no `bundle` and no local Jekyll on this machine. `verify.sh` carries the containment row (`served HTML has no empty stylesheet href`) and the fix if it fires is to restore the two blocks. It is caught at plan 03-04's push, where `deploy.yml` failing means nothing reaches visitors.
- **The `FONTS_URL` env form was mandatory, as 03-01 warned.** `node` on PATH here is a Volta shim that re-parses argv through `cmd.exe` and destroys everything after the first `&`. Passed positionally, this plan's two-family URL would have measured as one family and reported a comfortably passing budget. Every measurement above used `FONTS_URL=… node .planning/tools/fontbudget.js`.

## Harness state after this plan

```
bash .planning/phases/03-typography/verify.sh
  38 checks, 8 failed
  (8 of those are red-by-design — see the [red until plan 03-NN] labels)
  UNLABELLED: 0
```

Down from 26 failed. **18 rows went green**, and no row was edited, weakened, deleted or renumbered:

- All 5 `_config.yml` fonts rows (Be Vietnam Pro requested, Literata requested, `display=swap` kept, no `Material+Icons`, no `academicons:`/`scholar-icons:`).
- All 4 family / cap rows (2 family tokens, `--font-serif`, `--font-sans`, the cap no longer deferring its value).
- All 6 scale rows (`--step-1` through `--step-5`, each ratio matched as `calc()`).
- All 3 measure-and-leading rows (`--measure: 36rem`, `--leading-body: 1.6`, `--leading-heading: 1.2`).

`--live` additionally turned all 4 `[red until plan 03-02]` fonts rows green: 5 vietnamese blocks, `U+1EA0-1EF9` present, woff2 not truetype, payload within budget.

**The 8 remaining static reds are all `[red until plan 03-03]`:** five `_custom.scss` rows (serif body, sans labels, `max-width: var(--measure)`, `.navbar-brand .font-weight-bold`, `font-weight: 600`) and three `purgecss.config.js` safelist rows (`ol`, `blockquote`, `h4`).

## User Setup Required

None — no external service configuration required.

## Next Phase Readiness

**Ready for plan 03-03** (`_sass/_custom.scss` + `purgecss.config.js`). It should:

- consume the eleven token names in the table above **verbatim** — a typo'd `var()` name is silently dropped with no error, which is how Phase 2 lost `--rule-hairline`;
- keep the measure selector list inside `.post article` and add **no** `header.post-header` selector, per plan 03-01 decision (B) `title-full`;
- safelist `ol`, `blockquote` and `h4` in `purgecss.config.js` — no built page contains those tags, so the measure rules naming them will otherwise be stripped;
- declare `font-family` only as `var(--font-serif)` / `var(--font-sans)`; an unlabelled-green harness row rejects any literal family name in `_custom.scss`;
- keep `_custom.scss` free of hex / rem / px / em literals — Phase 2's matcher is still enforced and still green.

**Ready for plan 03-04** (the phase's single push). The 38 live rows still red are all deploy-gated. Deploy latency is ~112–168 s from push; poll, do not refresh once.

**Nothing has been pushed.** Phase 3 still owns exactly one deploy and plan 03-04 spends it — the fonts URL and the CSS consuming it must reach visitors together, or the site serves Literata's bytes with Roboto's rules.

**Carried blocker, unchanged by this plan:** Phase 2's close-out tag `design-02-<slug>` is still outstanding and must point at `482c740`, not at local HEAD.

---

_Phase: 03-typography_
_Completed: 2026-09-16_

## Self-Check: PASSED

- `_config.yml` — FOUND (css2 URL present, `Material+Icons` absent, `academicons:`/`scholar-icons:` absent, `fontawesome:` present, `max_width: 930px` present)
- `_sass/_tokens.scss` — FOUND (11 token declarations matched by `^  --(font-serif|font-sans|step-[0-5]|leading-body|leading-heading|measure):`; `--underline-offset: 0.18em` unchanged)
- `test/style_contract.js` — FOUND (`node test/style_contract.js` → passed)
- `.planning/phases/03-typography/03-02-SUMMARY.md` — FOUND
- Commit `61d8104` (task 1) — FOUND
- Commit `4943981` (task 2) — FOUND
- `bash .planning/phases/03-typography/verify.sh` — 38 checks, 8 failed, 8 red-by-design, 0 UNLABELLED
- `bash .planning/phases/03-typography/verify.sh --live` — all 4 `[red until plan 03-02]` fonts rows GREEN
- `npx prettier _config.yml _sass test/style_contract.js --check --end-of-line auto` — clean
- `git status` — clean; nothing pushed, `origin/gh-pages` untouched

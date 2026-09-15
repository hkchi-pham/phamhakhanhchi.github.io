---
phase: 02-palette-and-design-tokens
verified: 2026-09-15T12:00:00Z
status: passed
score: 26/26 must-haves verified (all 5 ROADMAP success criteria met; 81 static / 105 live phase-harness checks pass, 0 failed, 0 red-by-design remaining)
re_verification:
  previous_status: gaps_found
  previous_score: 25/26
  gaps_closed:
    - "Keyboard focus shows a visible >= 2px outline offset clear of the glyphs (02-03-PLAN must-have #18) — now true on the deployed site, not only in source."
  gaps_remaining: []
  regressions: []
---

# Phase 2: Palette and Design Tokens Verification Report

**Phase Goal:** One token file repaints the entire site onto warm paper — every page, the navbar, dropdowns, footer, cards, code blocks, buttons and tables — with no gem file shadowed, no dark theme left reachable, and no text faded by `opacity`.
**Verified:** 2026-09-15T12:00:00Z
**Status:** passed
**Re-verification:** Yes — after gap closure (plan 02-05)

## Goal Achievement

### What changed since the last verification

The prior VERIFICATION.md (2026-09-15, initial) found the phase's goal achieved at the ROADMAP level (5/5 success criteria) but flagged one real production gap: `_sass/_custom.scss`'s `:focus-visible` rule was correct in source and passed every static check, yet PurgeCSS silently stripped the bare pseudo-class selector from the deployed `main.css`, so keyboard users got the browser's default focus indicator instead of the site's contrast-measured (15.88:1) 2px ring. Plan 02-05 closed this by safelisting `":focus-visible"` (and, as a free side effect, `"h5"`/`"h6"` for the heading-ink rule) in `purgecss.config.js`, deploying once, and adding eight new `--live` harness rows that grep the served stylesheet for all six of plan 02-03's gem-behaviour overrides as a group — closing the exact blind spot that let the original gap ship unnoticed. A blocking human checkpoint then confirmed the ring reads as a ring on two live pages, keyboard-only.

All of this was independently re-verified below, not taken on the SUMMARY's word.

### Harness claim, verified directly

Ran both today, fresh:

```
bash .planning/phases/02-palette-and-design-tokens/verify.sh          -> 81 checks, 0 failed
bash .planning/phases/02-palette-and-design-tokens/verify.sh --live   -> 105 checks, 0 failed
```

`grep -n "red until" verify.sh` shows the label only inside explanatory comments and the `EXPECTED_RED` counting logic itself (lines 24, 39, 150, 425, 517) — no `check` row in the file carries an active `[red until plan 0…]` label any more. This matches plan 02-05's Task 2 requirement to strip all three labels once their rows went green, and matches the claim in the task prompt (81 static / 105 live, 0 failures) exactly.

### ROADMAP Success Criteria (the phase's primary contract)

| # | Criterion | Status | Evidence |
|---|-----------|--------|----------|
| 1 | All seven pages show warm paper behind navbar, body, cards, code blocks and footer — no leftover white panel, no dark bar | ✓ VERIFIED | Live `main.css` (fresh cache-busted fetch) contains `--global-bg-color:var(--paper-100)`, `--global-code-bg-color:var(--paper-200)`. All 7 pages return 200 (independently re-curled). Human checkpoint 2-04-03 Check A approved. |
| 2 | No theme toggle anywhere; forcing `data-theme="dark"` changes no colour | ✓ VERIFIED | Live home HTML: `light-toggle` count = 0 (re-checked via harness). Tier 2 map still positioned after the gem's own dark block by source order (unchanged since last verification — `_sass/_tokens.scss` untouched by 02-05). Human checkpoint 2-04-03 Check B approved. |
| 3 | Every link in body copy underlined, identifiable in greyscale | ✓ VERIFIED | Live CSS: `.post article a{text-decoration:underline;...}` present verbatim (re-grepped in fresh fetch). Human checkpoint 2-04-03 Check C approved. |
| 4 | `grep -rn "opacity" _sass/` returns no text selector; `.entry-year`/`.entry-meta`/`.entry-status` measure >= 4.5:1 | ✓ VERIFIED | Independently re-ran: exactly one hit, `.navbar { opacity: 1; }` — a reset, not a fade. `_sass/` directory listing confirms only `_custom.scss` and `_tokens.scss` exist, unchanged by 02-05. |
| 5 | Every colour/length literal lives in one token file, each colour carries its measured ratio, and the cap is written down | ✓ VERIFIED | `_sass/_custom.scss` remains literal-free (harness `Crit-5` rows pass); `purgecss.config.js` is a build-tool config, not a design-token file, and adding string literals to a safelist array does not violate "one token file" — it fixes a *delivery* pipeline, not the design surface. |

**Score:** 5/5 ROADMAP success criteria verified — unchanged from initial verification, now with the one production wiring gap underneath criterion 3/5's "underlined... identifiable" spirit (keyboard-visible focus) also closed.

### Plan-Level Must-Haves

All 26 must-haves from the initial verification's finer-grained table (02-01 through 02-04) were re-confirmed as still true: nothing in plan 02-05 touched `_sass/_tokens.scss`, `_sass/_custom.scss`, `_config.yml`, `CLAUDE.md`, or `.al-folio-overrides.yml` (`git diff 0a7c7b0..HEAD -- _sass/` is empty, independently re-run). The single item that changes status is:

| # | Truth | Status (initial) | Status (now) | Evidence |
|---|-------|---|---|----------|
| 18 | (02-03) Keyboard focus shows visible >=2px outline, offset clear of glyphs | ✗ FAILED (live only) | ✓ **VERIFIED** | Fresh `curl -s ".../main.css?cb=$(date +%s)"` shows the bare rule present: `:focus-visible{outline:var(--focus-ring-width) solid var(--ink-900);outline-offset:var(--focus-ring-offset)}` — distinct from the two pre-existing gem rules (`.af-table-search:focus-visible`, `.calendar-toggle-btn:focus-visible`, both `color-mix(...)`-based, still present and unrelated). Human checkpoint 2-05-03 (recorded in 02-VALIDATION.md) approved all three sub-checks (ring present, offset clears Vietnamese diacritics, reads on CV buttons). |

New must-haves introduced by plan 02-05's own frontmatter, all independently re-checked:

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 27 | Keyboard focus on the deployed site shows the site's own ring, surviving PurgeCSS | ✓ VERIFIED | See #18 above |
| 28 | Served `main.css` carries all six of 02-03's overrides, not five | ✓ VERIFIED | Live harness's 8 new rows (`pre,code` ink, `.card` shadow, `.hoverable:hover`, `.navbar opacity`, heading ink, focus ring x2, underlined links) all PASS on fresh run |
| 29 | Heading-ink rule reaches production with all six levels | ✓ VERIFIED | Fresh fetch: `h1,h2,h3,h4,h5,h6,.post-title{color:var(--ink-900)}` — h5/h6 present, unlike the pre-02-05 live state |
| 30 | A stripped design rule now turns a harness row red instead of passing unnoticed | ✓ VERIFIED | `verify.sh --live`'s new served-CSS group greps the CDN asset directly, not source; this is the mechanism, and it is in place and green |
| 31 | Focus ring never suppressed — no `outline: none` anywhere in `_sass/` | ✓ VERIFIED | `grep -rE "outline:[[:space:]]*none" _sass/` returns nothing (independently re-run) |
| 32 | `_sass/_custom.scss` unchanged by this plan | ✓ VERIFIED | `git diff 0a7c7b0..HEAD -- _sass/` is empty |

**Score:** 32/32 plan-level must-haves verified (26 carried forward + 6 introduced by 02-05, with #18 flipped from failed to verified).

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `.planning/tools/contrast.js` | Zero-dep WCAG contrast CLI + `--selftest` | ✓ VERIFIED | `--selftest` row passes in fresh harness run |
| `.planning/phases/02-palette-and-design-tokens/verify.sh` | Static + `--live` harness | ✓ VERIFIED | 81/81 static, 105/105 live, independently re-run; 8 new served-CSS rows confirmed present and passing |
| `CLAUDE.md` | Fork-ownership note | ✓ VERIFIED | Unchanged, still present (02-05 did not touch it) |
| `_sass/_tokens.scss` | Tier 1 primitives + cap + Tier 2 semantic map, 30 `--global-*` | ✓ VERIFIED | Byte-unchanged since last verification |
| `assets/css/main.scss` | `@use "tokens";` before `@use "custom";` | ✓ VERIFIED | Unchanged |
| `.al-folio-overrides.yml` | `local_sha256` matches file on disk | ✓ VERIFIED | Unchanged, not touched by 02-05 |
| `_sass/_custom.scss` | Literal-free overrides, 6 gem behaviours fixed, ALL surviving to production | ✓ **VERIFIED (was PARTIAL)** | Source unchanged and literal-free; all six overrides now confirmed present in the served stylesheet by direct fetch, closing the prior partial-production status |
| `_config.yml` | 3 flags false, `max_width` untouched | ✓ VERIFIED | Unchanged |
| `purgecss.config.js` | Safelist protects the bare `:focus-visible` selector and `h5`/`h6` | ✓ VERIFIED (new) | `grep -qF '":focus-visible"'` and `grep -qF '"h5"'`/`'"h6"'` all match; reasoning comment present beside each entry; `content`/`css`/`output`/`skippedContentGlobs` unchanged |
| `.planning/phases/02-palette-and-design-tokens/02-VALIDATION.md` | Rows 2-05-01..03 and the focus-ring checkpoint verdict | ✓ VERIFIED (new) | Rows present, all green; checkpoint verdict block for row `2-05-03` present with per-check (E/F/G) APPROVED verdicts |

### Key Link Verification

| From | To | Via | Status | Details |
|------|-----|-----|--------|---------|
| `verify.sh` | `contrast.js` | node invocation | ✓ WIRED | Confirmed by direct execution |
| `verify.sh` | `_sass/_tokens.scss` | static greps over 30-name list | ✓ WIRED | 30/30 rows pass |
| `assets/css/main.scss` | `_sass/_tokens.scss` | `@use "tokens";` before `@use "custom";` | ✓ WIRED | Confirmed compiled output present in live CSS |
| `_sass/_tokens.scss` Tier 2 | gem `html[data-theme="dark"]` block | matching (0,1,1) specificity, later source order | ✓ WIRED | Unchanged, still confirmed by live HTML/CSS behaviour |
| `.post article a` | gem/tailwind `a{text-decoration:none}` | unlayered rule beats layered rule | ✓ WIRED | Confirmed present, unlayered, rendering underline live |
| `pre, code` | gem `_utilities.scss` | same specificity, later source order | ✓ WIRED | Confirmed live |
| `_sass/_custom.scss :focus-visible` | production `main.css` | Sass compile -> PurgeCSS **safelist match** -> deployed CSS | ✓ **WIRED (was NOT WIRED)** | Confirmed by fresh cache-busted fetch: bare rule present with exact expected text |
| `purgecss.config.js` safelist | `.github/workflows/deploy.yml` "Purge unused CSS" step | `purgecss -c purgecss.config.js` | ✓ WIRED | Deploy run `34927923593` recorded as success in SUMMARY; served CSS is the direct proof the wiring held |
| `verify.sh --live` | served `main.css` | curl with cache-buster, grep for `--focus-ring-width` and the other five overrides | ✓ WIRED | 8 rows independently re-run, all pass |

### Requirements Coverage

| Requirement | Source Plan(s) | Description | Status | Evidence |
|-------------|-----------------|--------------|--------|----------|
| TOKEN-01 | 02-01..02-05 | Full palette via redeclared `--global-*`, no gem file shadowed | ✓ SATISFIED | 30/30 tokens re-pointed; `_sass/` holds only `_tokens.scss`/`_custom.scss`; the focus-ring delivery gap (a TOKEN-01 must-have per 02-05's own frontmatter) is now closed in production |
| TOKEN-02 | 02-02, 02-03 | Type scale and spacing rhythm as named tokens | ✓ SATISFIED | Unchanged, `--step-0..3`, `--space-1..4` |
| TOKEN-03 | 02-01, 02-03 | No text de-emphasised with `opacity` | ✓ SATISFIED | Confirmed by fresh grep |
| TOKEN-04 | 02-04 | Dark-mode toggle gone | ✓ SATISFIED | `enable_darkmode: false`; toggle absent from live HTML |
| TOKEN-05 | 02-02, 02-04 | Tokens structured so dark theme is reintroducible later | ✓ SATISFIED | Tier 1/Tier 2 split unchanged |
| TOKEN-06 | 02-01, 02-02, 02-04 | Token vocabulary deliberately capped | ✓ SATISFIED | Cap counts unchanged (2/4/1/2) |
| GROUND-01 | 02-02, 02-04 | Warm paper ground across all seven pages | ✓ SATISFIED | Confirmed live + human-approved |
| GROUND-04 | 02-03, 02-04, 02-05 | Links underlined; keyboard focus visibly marks interactive elements | ✓ SATISFIED | Underline confirmed live + human-approved; focus ring now also confirmed live + human-approved (2-05-03) |

`.planning/REQUIREMENTS.md`'s traceability table marks all 8 IDs "Phase 2 / Complete" (independently re-grepped). No orphaned requirements: every ID mapped to Phase 2 there appears in at least one plan's `requirements:` frontmatter field (02-01 through 02-05).

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| — | — | No TODO/FIXME/XXX/HACK/PLACEHOLDER found in `_sass/_tokens.scss`, `_sass/_custom.scss`, or `purgecss.config.js` | — | none |

The prior verification's one warning — `purgecss.config.js`'s safelist having no entry for pseudo-class-only selectors, root-caused as the reason the focus ring shipped stripped — is resolved: the safelist now carries `":focus-visible"`, `"h5"`, `"h6"`, each with an explanatory comment naming the mechanism (selector-node matching, leading-colon requirement) for the next agent who adds a bare pseudo-class rule. No new anti-patterns introduced.

### Human Verification Required

None outstanding. Two human checkpoints are on record and approved:

- `02-VALIDATION.md` row `2-04-03` (2026-09-14): seven-page sweep, `data-theme="dark"` force, greyscale link check, register sanity — all four sub-checks APPROVED.
- `02-VALIDATION.md` row `2-05-03` (2026-09-15): keyboard-only tab-through on two live pages confirming the focus ring is present, clears the Vietnamese diacritics, and reads correctly on the CV buttons — all three sub-checks (E/F/G) APPROVED.

Neither checkpoint is being re-requested here; both are treated as satisfied per their recorded verdicts, consistent with instructions.

### Gaps Summary

None. The single gap identified in the initial verification of this phase — the deployed site silently serving the browser's default keyboard focus indicator instead of the site's own contrast-measured focus ring, because PurgeCSS stripped the bare `:focus-visible` selector — is closed. The fix (a `purgecss.config.js` safelist entry, not a `_sass/` change) was the narrower of two options considered, was measured against the actual PurgeCSS version CI installs before being chosen, was deployed once, and was independently confirmed today by a fresh, cache-busted fetch of the production stylesheet showing the exact expected rule text. The harness that failed to catch the original gap now has eight new rows inspecting the served CSS directly for all six of the phase's gem-behaviour overrides as a group, closing the blind spot rather than just the symptom. A human confirmed by eye, keyboard-only, that the ring is visible, well-offset from glyphs including Vietnamese diacritics, and legible against the site's buttons.

All five ROADMAP success criteria, all 32 plan-level must-haves (26 original + 6 from the gap-closure plan), all required artifacts at all three verification levels, all key links, and all 8 mapped requirement IDs are verified. Phase 2's goal — one token file repaints the entire site onto warm paper, with no gem file shadowed, no dark theme reachable, and no text faded by `opacity` — is achieved in the codebase and confirmed on the live deployed site.

---

_Verified: 2026-09-15T12:00:00Z_
_Verifier: Claude (gsd-verifier)_

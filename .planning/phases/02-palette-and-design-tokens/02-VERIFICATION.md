---
phase: 02-palette-and-design-tokens
verified: 2026-09-15T00:00:00Z
status: gaps_found
score: 25/26 must-haves verified (all 5 ROADMAP success criteria met; 95/95 phase-harness checks pass)
gaps:
  - truth: "Keyboard focus shows a visible >= 2px outline offset clear of the glyphs (02-03-PLAN must-have)"
    status: failed
    reason: >
      The `:focus-visible { outline: var(--focus-ring-width) solid var(--ink-900); outline-offset: var(--focus-ring-offset); }`
      rule is correctly written, literal-free and present in `_sass/_custom.scss`, and every static
      check in the phase harness (verify.sh, non-live) confirms it in source. It does NOT reach the
      deployed site: PurgeCSS (`purgecss.config.js`, run in `.github/workflows/deploy.yml`) strips the
      bare selector from the production `main.css` because its default extractor finds no matching
      token for a pseudo-class with no attached tag/class name — unlike `.navbar`, `.card`, `pre`,
      `code`, `h1`-`h4` and `.post article a`, all of which have literal tag/class matches in the
      built HTML and survive. Confirmed by two independent fresh fetches of
      `https://phamhakhanhchi.com/assets/css/main.css?cb=...`: the file contains two *other*
      `:focus-visible` rules (`.af-table-search:focus-visible`, `.calendar-toggle-btn:focus-visible`,
      both pre-existing gem rules), but zero occurrences of `focus-ring-width` or the site's own
      general focus-ring rule. Keyboard users on the live site fall back to whatever the browser's
      native default focus indicator is, not the deliberate, contrast-measured (15.88:1), >=2px
      offset ring the plan specified. `verify.sh --live` never grepped the served CSS for this rule
      (it only checks --paper-100, --global-bg-color, --global-code-bg-color, --deploy-proof,
      sticky-bottom, and three HTML zero-counts), so this gap passed the phase's own 95-check harness
      undetected, and no SUMMARY mentions it.
    artifacts:
      - path: "_sass/_custom.scss"
        issue: "Rule 6 (:focus-visible) is correct in source but is stripped by PurgeCSS before it reaches production — an orphaned artifact with respect to the deployed site, not the repo."
      - path: "purgecss.config.js"
        issue: "safelist has no entry protecting a bare :focus-visible (or :focus) selector; every other safelisted entry is a class name with a literal HTML/JS match."
    missing:
      - "Either add `:focus-visible` (or `focus-visible`) to purgecss.config.js's safelist, or rewrite the rule with concrete selectors that already have literal matches in scanned HTML — e.g. `a:focus-visible, button:focus-visible, .btn:focus-visible, input:focus-visible, [tabindex]:focus-visible` — then redeploy and re-grep the served CSS for `focus-ring-width` to confirm survival."
      - "Add a `--live` row to verify.sh that greps the served main.css for the focus-ring rule (and ideally for all six 02-03 overrides), so this class of PurgeCSS-stripping regression cannot recur silently. This is exactly the kind of served-CSS inspection Phase 8's QA-03 is meant to do, but it is cheap to add now."
---

# Phase 2: Palette and Design Tokens Verification Report

**Phase Goal:** One token file repaints the entire site onto warm paper — every page, the navbar, dropdowns, footer, cards, code blocks, buttons and tables — with no gem file shadowed, no dark theme left reachable, and no text faded by `opacity`.
**Verified:** 2026-09-15T00:00:00Z
**Status:** gaps_found
**Re-verification:** No — initial verification

## Goal Achievement

### ROADMAP Success Criteria (the phase's primary contract)

| # | Criterion | Status | Evidence |
|---|-----------|--------|----------|
| 1 | All seven pages show warm paper behind navbar, body, cards, code blocks and footer — no leftover white panel, no dark bar | ✓ VERIFIED | Live `main.css` contains `--global-bg-color:var(--paper-100)`, `--global-code-bg-color:var(--paper-200)`, `--global-footer-bg-color:var(--paper-200)` (confirmed by direct `curl`). All 7 pages return 200. Human checkpoint (02-VALIDATION.md row 2-04-03, Check A) approved with no white panel/dark bar seen. |
| 2 | No theme toggle anywhere; forcing `data-theme="dark"` changes no colour | ✓ VERIFIED | Live home HTML: `light-toggle` count = 0 (independently re-curled). `_sass/_tokens.scss` Tier 2 map is emitted under `:root, html[data-theme="dark"]` and confirmed, by byte-offset inspection of the live CSS, to be positioned *after* the gem's own `html[data-theme=dark]` block (byte 1081 vs 24666) — identical (0,1,1) specificity, later source order wins, which is what the cascade mechanism requires. Human checkpoint Check B approved after literally forcing the attribute in DevTools. |
| 3 | Every link in body copy underlined, identifiable in greyscale | ✓ VERIFIED | Live CSS: `.post article a{text-decoration:underline;text-decoration-thickness:var(--underline-thickness);text-underline-offset:var(--underline-offset)}` present verbatim. Human checkpoint Check C approved under Achromatopsia emulation, including Vietnamese diacritic clearance. |
| 4 | `grep -rn "opacity" _sass/` returns no text selector; `.entry-year`/`.entry-meta`/`.entry-status` measure >= 4.5:1 | ✓ VERIFIED | Independent `grep -rn "opacity" _sass/` returns exactly one hit: `.navbar { opacity: 1; }` — a reset, not a fade (value-aware harness row already narrows correctly on this). `node .planning/tools/contrast.js "#5c5349" "#faf6ee"` independently reproduces 6.99:1 / AA-text. |
| 5 | Every colour/length literal lives in one token file, each colour carries its measured ratio, and the cap is written down | ✓ VERIFIED | `_sass/_tokens.scss` is the only file besides `_custom.scss` under `_sass/`; `_custom.scss` contains zero hex/rem/px/em/color-mix literals besides the exempted `--deploy-proof` string (independently re-grepped). All 9 Tier‑1 primitive lines carry `N.NN:1` comments; the cap block (`paper tones`/`ink steps`/`accent colours`/`type families`) is present and the declared counts (2/4/1/2) match exactly.

**Score:** 5/5 ROADMAP success criteria verified.

### Plan-Level Must-Haves (finer-grained contract from the 4 PLAN frontmatter blocks)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | (02-01) Any contrast ratio can be recomputed by one command | ✓ VERIFIED | `node .planning/tools/contrast.js --selftest` independently re-run: 8/8 pairs pass, exit 0 |
| 2 | (02-01) Every automatable criterion can be re-checked by running one script | ✓ VERIFIED | `bash verify.sh` and `--live` both independently re-run: 79/79 and 95/95, exit 0 |
| 3 | (02-01) 30 `--global-*` names recorded as ground truth off live CSS | ✓ VERIFIED | `GLOBAL_TOKENS` array present in verify.sh (line 103); independently re-fetched live CSS confirms exactly 30 distinct `--global-*` names |
| 4 | (02-01) CLAUDE.md learns this fork owns `_sass/` before deleting | ✓ VERIFIED | "This fork: the stop sign is disabled" section present, additive, names `test/style_contract.js`, `_tokens.scss`, empty baseurl, authoritative files |
| 5 | (02-02) Every literal lives in exactly one file | ✓ VERIFIED | See criterion 5 above |
| 6 | (02-02) Each colour token carries its measured ratio in a comment | ✓ VERIFIED | See criterion 5 above |
| 7 | (02-02) The cap is written in that same file | ✓ VERIFIED | See criterion 5 above |
| 8 | (02-02) All 30 `--global-*` resolve to a site token | ✓ VERIFIED | Both source (`_tokens.scss`) and live CSS confirmed, 30/30 |
| 9 | (02-02) Forcing `data-theme="dark"` resolves `--global-bg-color` to paper, not `#1c1c1d` | ✓ VERIFIED | Source-order mechanism confirmed by byte offset; human-approved live |
| 10 | (02-02) A future dark theme can be added by re-pointing primitives in one new block | ✓ VERIFIED (structural) | Tier 1/Tier 2 separation confirmed; every Tier 2 value is a `var()` reference, zero literals |
| 11 | (02-03) `grep -rn "opacity"` returns no text selector | ✓ VERIFIED | See criterion 4 above |
| 12 | (02-03) `.entry-year`/`.entry-meta`/`.entry-status`/`.subject-grade` measure 6.99:1 | ✓ VERIFIED | All four use `var(--ink-500)`, independently confirmed in `_custom.scss` |
| 13 | (02-03) Body-copy links underlined, clear Vietnamese below-baseline marks | ✓ VERIFIED | Human-approved (Check C); `--underline-offset: 0.18em` present |
| 14 | (02-03) Navbar/footer links NOT underlined | ✓ VERIFIED | `.post article a` scope confirmed to exclude navbar/footer (both outside `.post` per layout structure); human-approved |
| 15 | (02-03) Code blocks render in body ink, not link colour | ✓ VERIFIED | `pre,code{color:var(--ink-800)}` confirmed in **both** source and live served CSS |
| 16 | (02-03) Card is flush, no drop-shadow halo | ✓ VERIFIED | `.card{box-shadow:none}` and `.hoverable:hover{box-shadow:none;transform:none}` confirmed in **both** source and live served CSS |
| 17 | (02-03) Headings are deeper ink than body, hierarchy survives greyscale blur | ✓ VERIFIED (with note) | `h1,h2,h3,h4,.post-title{color:var(--ink-900)}` confirmed live. Source declares all of `h1..h6`; PurgeCSS strips `h5`/`h6` from the live selector list because no page currently renders an `<h5>`/`<h6>` (independently confirmed 0 occurrences on all 7 pages) — this is PurgeCSS behaving as designed (see `sticky-bottom` precedent) and not a live-visible defect today, but it means the h5/h6 rule is *not actually deployed* and would need a fresh build to reappear if a future page adds those tags. Not scored as a gap; noted for awareness. |
| 18 | (02-03) Keyboard focus shows visible >=2px outline, offset clear of glyphs | ✗ **FAILED (live only)** | See Gap above. Correct and literal-free in source; absent from the deployed CSS. |
| 19 | (02-03) `_sass/_custom.scss` contains no colour or length literal | ✓ VERIFIED | Independently re-grepped; zero hits besides the exempted `--deploy-proof` string |
| 20 | (02-04) No theme toggle on deployed site | ✓ VERIFIED | See criterion 2 above |
| 21 | (02-04) Forcing `data-theme="dark"` changes no colour | ✓ VERIFIED | See criterion 2 above |
| 22 | (02-04) All seven pages show warm paper | ✓ VERIFIED | See criterion 1 above |
| 23 | (02-04) No dark bar pinned to bottom; footer is the bottom of the page | ✓ VERIFIED | `footer_fixed: false` confirmed at `_config.yml:99`; live HTML `fixed-bottom` count = 0; `sticky-bottom` present in live CSS |
| 24 | (02-04) Progress bar is gone | ✓ VERIFIED | Live HTML `progress-bar` count = 0 |
| 25 | (02-04) Every link in body copy identifiable in greyscale | ✓ VERIFIED | Human-approved Check C |
| 26 | (02-04) New token CSS is what the CDN actually serves | ✓ VERIFIED | Directly confirmed via fresh `curl` with cache-buster, twice, matching source content and `--deploy-proof` value |

**Score:** 25/26 plan-level must-haves verified. The one failure (#18) is a production-pipeline (PurgeCSS) wiring gap, not a source-code defect, and it is not one of the 5 ROADMAP-level success criteria — so the phase's stated goal is achieved, but a real, fixable accessibility regression exists on the live site today.

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `.planning/tools/contrast.js` | Zero-dep WCAG contrast CLI + `--selftest` | ✓ VERIFIED | 8/8 self-test pairs pass, independently re-run |
| `.planning/phases/02-palette-and-design-tokens/verify.sh` | Static + `--live` harness | ✓ VERIFIED | 79/79 static, 95/95 live, independently re-run; edits across 02-02/02-03/02-04 checked commit-by-commit — all narrowed matchers strictly maintain or strengthen intent, none deleted or hollowed a row |
| `CLAUDE.md` | Fork-ownership note | ✓ VERIFIED | Present, additive, matches required content |
| `_sass/_tokens.scss` | Tier 1 primitives + cap + Tier 2 semantic map, 30 `--global-*` | ✓ VERIFIED | All counts and content independently confirmed against both source and live CSS |
| `assets/css/main.scss` | `@use "tokens";` before `@use "custom";` | ✓ VERIFIED | Line 37 before line 41 |
| `.al-folio-overrides.yml` | `local_sha256` matches file on disk | ✓ VERIFIED | Independently recomputed `sha256sum` matches recorded value exactly |
| `_sass/_custom.scss` | Literal-free overrides, 6 gem behaviours fixed | ⚠️ PARTIAL (production) | Source-complete and literal-free; one of its six overrides (`:focus-visible`) does not survive the production PurgeCSS pass — see Gap |
| `_config.yml` | 3 flags false, `max_width` untouched | ✓ VERIFIED | `enable_darkmode: false` (474), `enable_progressbar: false` (478), `footer_fixed: false` (99), `max_width: 930px` (106) unchanged |

### Key Link Verification

| From | To | Via | Status | Details |
|------|-----|-----|--------|---------|
| `verify.sh` | `contrast.js` | node invocation | ✓ WIRED | Confirmed by direct execution |
| `verify.sh` | `_sass/_tokens.scss` | static greps over 30-name list | ✓ WIRED | 30/30 rows pass |
| `assets/css/main.scss` | `_sass/_tokens.scss` | `@use "tokens";` before `@use "custom";` | ✓ WIRED | Confirmed compiled output present in live CSS |
| `_sass/_tokens.scss` Tier 2 | gem `html[data-theme="dark"]` block | matching (0,1,1) specificity, later source order | ✓ WIRED | Confirmed by byte-offset ordering in live CSS (1081 < 24666) |
| `.post article a` | gem/tailwind `a{text-decoration:none}` in `@layer base` | unlayered rule beats layered rule | ✓ WIRED | Confirmed present, unlayered, and rendering underline live |
| `pre, code` | gem `_utilities.scss` `pre/code{color:var(--global-theme-color)}` | same specificity, later source order | ✓ WIRED | Confirmed live |
| `_sass/_custom.scss :focus-visible` | production `main.css` | Sass compile → PurgeCSS pass → deployed CSS | ✗ **NOT WIRED (live)** | Rule compiles correctly into `_site`/pre-purge CSS (implied by source correctness and passing static checks) but PurgeCSS strips it before deploy; confirmed absent from two independent live fetches |

### Requirements Coverage

| Requirement | Source Plan(s) | Description | Status | Evidence |
|-------------|-----------------|--------------|--------|----------|
| TOKEN-01 | 02-01, 02-02, 02-03, 02-04 | Full palette via redeclared `--global-*`, no gem file shadowed | ✓ SATISFIED | 30/30 tokens re-pointed; only `_tokens.scss`/`_custom.scss` exist under `_sass/` |
| TOKEN-02 | 02-02, 02-03 | Type scale and spacing rhythm as named tokens | ✓ SATISFIED | `--step-0..3`, `--space-1..4` declared and consumed |
| TOKEN-03 | 02-01, 02-03 | No text de-emphasised with `opacity` | ✓ SATISFIED | Confirmed by independent grep; value-aware harness row is sound |
| TOKEN-04 | 02-04 | Dark-mode toggle gone | ✓ SATISFIED | `enable_darkmode: false`; toggle absent from live HTML |
| TOKEN-05 | 02-02, 02-04 | Tokens structured so dark theme is reintroducible later | ✓ SATISFIED | Tier 1/Tier 2 split confirmed |
| TOKEN-06 | 02-01, 02-02, 02-04 | Token vocabulary deliberately capped | ✓ SATISFIED | Cap written and machine-checked (2/4/1/2) |
| GROUND-01 | 02-02, 02-04 | Warm paper ground across all seven pages | ✓ SATISFIED | Confirmed live + human-approved |
| GROUND-04 | 02-03, 02-04 | Links underlined | ✓ SATISFIED | Confirmed live + human-approved |

No orphaned requirements: all 8 IDs mapped to Phase 2 in `.planning/REQUIREMENTS.md` appear in at least one plan's `requirements:` field, and all 8 are marked Complete in `.planning/REQUIREMENTS.md`'s traceability table (independently re-grepped).

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| — | — | No TODO/FIXME/XXX/HACK/PLACEHOLDER found in `_sass/_tokens.scss` or `_sass/_custom.scss` | — | none |
| `purgecss.config.js` | 6-26 | Safelist covers class-based gem behaviours but has no entry for pseudo-class-only selectors | ⚠️ Warning | Root cause of the focus-visible gap above; will recur for any future bare pseudo-class rule (e.g. `:target`) added to `_custom.scss` without a matching safelist/selector-shape fix |

No stub components, no empty handlers, no console-log-only implementations found. All literals traced to a single reviewable token file as designed.

### Human Verification Required

None outstanding. The phase's one human checkpoint (seven-page sweep, `data-theme="dark"` force, greyscale link check, register sanity) is already complete and approved — see `.planning/phases/02-palette-and-design-tokens/02-VALIDATION.md` row `2-04-03` and `02-04-SUMMARY.md`. This verification did not re-request human judgement for anything already covered there.

### Gaps Summary

Phase 2 achieves its stated ROADMAP goal and all five of its own success criteria, confirmed independently against both source and the live deployed site, and its 95-check `--live` harness is a genuine, well-maintained measurement (the three in-flight edits to `verify.sh` during 02-02/02-03/02-04 were individually inspected and each one narrows a matcher for a stated, valid reason without weakening or deleting a check).

One real gap was found by going one level deeper than the phase's own harness: the harness verifies `_sass/_custom.scss` (source) and a small, deliberately chosen set of served-CSS strings (live), but never checks that the six 02-03 gem-behaviour overrides survive the production PurgeCSS pass as a group. Five of the six do; the sixth — the general `:focus-visible` keyboard-focus ring — is silently stripped by PurgeCSS because it is a bare pseudo-class selector with no literal HTML token for PurgeCSS's default extractor to match against. This is exactly the class of problem Phase 8's QA-03 ("the CSS actually served... has been inspected, and no rule the design depends on was stripped") is designed to catch — except it is live now, three phases early, and cheap to fix immediately rather than carry forward as latent accessibility debt.

Recommended fix (small, does not require reopening this phase's design decisions): either add a safelist entry to `purgecss.config.js` for the bare pseudo-class, or rewrite the rule in `_sass/_custom.scss` using concrete selectors PurgeCSS will keep (`a:focus-visible, button:focus-visible, .btn:focus-visible, input:focus-visible, [tabindex]:focus-visible`), then redeploy and re-grep the served CSS to confirm. A follow-up `--live` row in `verify.sh` that greps for `focus-ring-width` (and ideally the other five overrides) in the served CSS would prevent this class of regression from recurring silently in later phases.

---

_Verified: 2026-09-15T00:00:00Z_
_Verifier: Claude (gsd-verifier)_

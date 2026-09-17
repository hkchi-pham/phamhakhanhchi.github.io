---
phase: 03-typography
verified: 2026-09-17T00:00:00Z
status: passed
score: 5/5 must-haves verified
---

# Phase 3: Typography Verification Report

**Phase Goal:** The site's voice comes from its type — a serif body with verified Vietnamese coverage, a companion face for labels and code, a hierarchy that survives a five-second scan, and a measure chosen rather than inherited.

**Verified:** 2026-09-17
**Status:** passed
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths (ROADMAP Success Criteria)

| # | Truth | Status | Evidence |
| - | ----- | ------ | -------- |
| 1 | "Phạm Hà Khánh Chi" renders entirely in one typeface (`ạ` vs `à` at ≥48px, visually identical) | ✓ VERIFIED | Human checkpoint (`03-VALIDATION.md` check A) recorded **APPROVED** 2026-09-17. Technical precondition independently confirmed: both `ạ` (vietnamese subset) and `à` (latin subset) are served from the same `Literata` family declaration in the deployed `<link>` tag (curl-confirmed below), and `.navbar-brand .font-weight-bold { font-weight: inherit }` is present in the served `main.css` (verified directly: `grep -oE ".nav-link[a-z0-9,.:> -]*\{[^}]*\}" /tmp/main_live.css` and the static+live harness rows for TYPE-03). Note: `--step-5` computes to 44.2px by settled 03-01 decision; the "≥48px" clause governs inspection zoom level, not h1 size — not a miss. |
| 2 | The served Google Fonts CSS contains a `/* vietnamese */` block for the chosen families, curl-verified and recorded in the commit | ✓ VERIFIED | Independently re-ran: `curl -s -A <chrome-UA> "https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;600&family=Literata:ital,wght@0,400;0,600;1,400&display=swap" \| grep -c "/* vietnamese */"` → **5**. Matches `03-04-SUMMARY.md`'s claim of "5 `/* vietnamese */` blocks, each with `U+1EA0-1EF9`," recorded verbatim in commit `ca16ad4`'s body per the summary. Live harness (`verify.sh --live`) independently re-confirms: "fonts CSS carries 5 /* vietnamese */ blocks... the vietnamese range covers U+1EA0-1EF9." |
| 3 | Body copy is the serif; labels, years, metadata and code are the companion face; no third type family anywhere in `_sass/custom/` | ✓ VERIFIED (with one documented, non-blocking scope decision on "code") | `grep -rn "font-family" _sass/*.scss` shows exactly two family tokens consumed (`var(--font-serif)`, `var(--font-sans)`) and zero third literal. Served `main.css`: `body{font-family:var(--font-serif)...}`; `.entry-year`, `.entry-meta`, `.subject-grade`, `.nav-link` all carry `font-family:var(--font-sans)` (independently curled and grepped from the live stylesheet). The "code" clause of TYPE-02 is discharged by a documented decision not to style code (no code block exists on any page; `main.css` has no `@font-face`; the gem's dead `Iosevka Fixed` targets an unused `.typogram` class) — recorded honestly as an annotation in `REQUIREMENTS.md`, not a silent omission. |
| 4 | H2 ≥1.5× body, H3 ≥1.25× body; a body paragraph measures 45–75 CPL | ✓ VERIFIED | Ratios independently confirmed from the served stylesheet: `--step-1: 1.0625rem` (body base), `--step-4: calc(var(--step-1) * 1.8)` (h2, exceeds 1.5×), `--step-3: calc(var(--step-1) * 1.35)` (h3, exceeds 1.25×); `h1,h2{font-weight:600}h3,h4,h5,h6{font-weight:400}` also confirmed live. CPL is human-eye-only: check B in `03-VALIDATION.md` is recorded as **"approved (user sign-off; no numeric reading supplied)"** on 2026-09-17. Per this verification's explicit instructions, the absence of a numbered CPL figure is an honest, approved limitation and not a gap — Phase 8 is the designated owner for re-measuring the actual figure. |
| 5 | Total webfont bytes on first load are under the stated budget, measured against the deployed site | ✓ VERIFIED | Independently re-ran `.planning/tools/fontbudget.js` against the live css2 URL: **TOTAL: 141232 B / BUDGET: 153600 B / HEADROOM: 12368 B (91.9% used)** — byte-for-byte identical to `03-04-SUMMARY.md`'s recorded figure. Icon payload (323,520 B declared, Font Awesome) is correctly excluded from the type budget per the phase's documented scope decision. |

**Score:** 5/5 truths verified

### Required Artifacts

| Artifact | Expected | Status | Details |
| -------- | -------- | ------ | ------- |
| `_sass/_tokens.scss` | Two font family tokens, type-scale steps, measure, leadings | ✓ VERIFIED | `--font-serif: Literata, Georgia, "Times New Roman", serif;`, `--font-sans: "Be Vietnam Pro", ...`, `--step-3`..`--step-5`, `--measure: 36rem`, `--leading-body: 1.6`, `--leading-heading: 1.2` all present and match served CSS values exactly. |
| `_sass/_custom.scss` | Body serif, companion-sans classes, weight hierarchy, measure applied to prose | ✓ VERIFIED | `body{font-family:var(--font-serif)}`, four sans classes (`.entry-year`, `.entry-meta`, `.subject-grade`, `.nav-link`), h1/h2 weight 600 / h3 weight 400, `.navbar-brand .font-weight-bold` neutralized — all present in source and confirmed live. |
| `_config.yml` | css2 URL requesting only Literata + Be Vietnam Pro; dead icon plugins removed | ✓ VERIFIED | `fonts:` key matches the exact URL served live; static harness confirms no `Material+Icons`, `academicons:`, `scholar-icons:` keys remain. |
| `.planning/tools/fontbudget.js` | Re-runnable byte-budget tool | ✓ VERIFIED | `--selftest` passes (static harness); independently invoked against live URL, output matches summary exactly (141,232 B). |
| `purgecss.config.js` | Safelist for fragile measure-selector tag names | ✓ VERIFIED | `"ol"`, `"blockquote"`, `"h4"` safelisted (static harness); all 8 fragile `.post article>...` measure nodes independently confirmed present in the served `main.css`. |
| `.planning/phases/03-typography/verify.sh` | Executable regression harness, static + live | ✓ VERIFIED | Re-ran directly: 38/38 static, 80/80 live, 0 failed, `EXPECTED_RED` 0, all `[red until plan 03-NN]` labels stripped. |
| `.planning/REQUIREMENTS.md` | TYPE-01..05 marked Complete, no orphans | ✓ VERIFIED | All 5 IDs present in checkbox list and coverage table as Complete; TYPE-02 carries an honest annotation about the "code" clause. |

### Key Link Verification

| From | To | Via | Status | Details |
| ---- | -- | --- | ------ | ------- |
| `_config.yml` fonts URL | Served HTML `<head>` | Jekyll gem `<link>` injection | ✓ WIRED | `curl https://phamhakhanhchi.com/` shows the exact same css2 URL, correctly `&amp;`-escaped. |
| `_sass/_tokens.scss` family tokens | `_sass/_custom.scss` overrides | `var(--font-serif)` / `var(--font-sans)` | ✓ WIRED | Confirmed by direct grep of both files — no hardcoded family names in `_custom.scss`. |
| `_sass/_custom.scss` measure rule | `purgecss.config.js` safelist | Tag-name selectors surviving PurgeCSS | ✓ WIRED | All 8 fragile measure nodes (`.post article>p`, `>h2`, `>h3`, `>h4`, `>ol`, `>blockquote`, `>.clearfix>p`, `>.clearfix>h2`) independently found in the deployed, PurgeCSS-processed `main.css`. |
| Google Fonts css2 URL | `.planning/tools/fontbudget.js` | HTTP fetch + byte sum | ✓ WIRED | Tool independently re-run against the live URL, output reproduces the recorded 141,232 B figure exactly. |
| `_sass/_custom.scss` sans classes | Deployed pages (`.entry-year` etc.) | Compiled CSS reaching the CDN | ✓ WIRED | Confirmed live: all four classes carry `font-family:var(--font-sans)` in the fetched `main.css`. |

### Requirements Coverage

| Requirement | Source Plan(s) | Description | Status | Evidence |
| ----------- | --------------- | ------------ | ------ | -------- |
| TYPE-01 | 03-01, 03-02, 03-04 | Body serif has a verified Vietnamese unicode-range subset | ✓ SATISFIED | curl-confirmed 5 vietnamese blocks, `U+1EA0-1EF9` range, live harness green |
| TYPE-02 | 03-01, 03-02, 03-03, 03-04 | Companion face carries labels, metadata and code | ✓ SATISFIED (annotated) | Four sans classes confirmed live; "code" clause discharged by documented no-op decision (no code exists on site) |
| TYPE-03 | 03-01, 03-03, 03-04 | Name renders in one typeface | ✓ SATISFIED | Human checkpoint APPROVED; navbar-brand weight fix confirmed live |
| TYPE-04 | 03-01, 03-02, 03-03, 03-04 | Heading hierarchy distinguishable; measure deliberate | ✓ SATISFIED | Ratios confirmed live (1.8x, 1.35x); CPL approved without numeric backfill (recorded limitation, not a gap) |
| TYPE-05 | 03-01, 03-02, 03-04 | Webfont payload within stated budget | ✓ SATISFIED | 141,232 B / 153,600 B, independently re-measured |

No orphaned requirements — all five IDs declared across the four plans' `requirements:` frontmatter match `.planning/REQUIREMENTS.md`'s Phase 3 mapping exactly.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
| ---- | ---- | ------- | -------- | ------ |
| — | — | None found | — | `grep -iE "TODO|FIXME|XXX|HACK|PLACEHOLDER"` across `_sass/_custom.scss`, `_sass/_tokens.scss`, `.planning/tools/fontbudget.js` returned nothing. |

No blocker or warning anti-patterns identified. Two items are open by design and were carried forward with their own documentation rather than hidden:

- **`--underline-offset: 0.18em` provenance mismatch** (`_sass/_tokens.scss:190`) — the comment claims the rule clears Vietnamese below-baseline marks in the name, but the rule it feeds (`.post article a`) is never exercised by any link containing such a mark on the deployed site. This is documented in `03-04-SUMMARY.md` and `03-VALIDATION.md` and explicitly handed to Phase 4 or Phase 8. Not a Phase 3 defect; not reported here as a new gap.
- **Close-out tags `design-02-<slug>` and `design-03-<slug>` are uncut.** Confirmed via `git tag -l "design-0*"` → only `design-00-baseline` exists. Tagging is outside this phase's scope per the task brief and is not treated as a gap.

### Human Verification Required

All four human-eye-only checks for this phase were already executed and recorded, on the user's authority, in `03-VALIDATION.md` dated 2026-09-17. No new human verification is outstanding:

1. **Check A — one typeface / one navbar weight** — APPROVED
2. **Check B — characters per line / right gutter** — approved (user sign-off; no numeric reading supplied; Phase 8 re-runs the measurement)
3. **Check C — underline offset vs. Literata descenders** — approved (user sign-off; no numeric reading supplied; open provenance discrepancy carried to Phase 4/8, not reopened here)
4. **Check D — fallback swap window** — APPROVED

No further human verification is requested by this report.

### Gaps Summary

None. All five ROADMAP success criteria are independently verified against the live deployed site (`https://phamhakhanhchi.com/`, `gh-pages` tip `a5553c1c3d8e43ca6ee2e821a119ddc16e3e2cee`, matching `git ls-remote origin refs/heads/gh-pages`), not merely against `_sass/` source or the SUMMARY's own claims. The project's own harness (`verify.sh`, 38 static + 80 live checks) was re-run fresh and returned 0 failed both times, and every numeric figure it reports (webfont bytes, vietnamese block count, step ratios, served CSS byte size) was independently cross-checked with separate `curl`/`grep`/tool invocations rather than trusted from the harness or the SUMMARY. The two items intentionally left open (underline-offset provenance, uncut close-out tags) were pre-declared as out of scope for this phase and are not reported as gaps, per the verification brief.

---

_Verified: 2026-09-17_
_Verifier: Claude (gsd-verifier)_

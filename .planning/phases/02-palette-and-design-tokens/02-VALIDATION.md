---
phase: 2
slug: palette-and-design-tokens
status: approved
nyquist_compliant: true
wave_0_complete: false
created: 2026-09-14
---

# Phase 2 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property               | Value                                                                                                                                                                                                                              |
| ---------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Framework**          | **None, and none may be added.** Phase 1 set the convention and 01-VALIDATION forbids a starter-local build/test pipeline. Validation is a flat `check <label> <expr>` shell harness plus a zero-dependency Node contrast calculator. |
| **Config file**        | none — Wave 1 (plan 02-01) creates both tools                                                                                                                                                                                        |
| **Quick run command**  | `bash .planning/phases/02-palette-and-design-tokens/verify.sh`                                                                                                                                                                        |
| **Full suite command** | `bash .planning/phases/02-palette-and-design-tokens/verify.sh --live`                                                                                                                                                                 |
| **Estimated runtime**  | static ~3-8s (Prettier is the slow row); `--live` ~15-25s (network)                                                                                                                                                                  |
| **Supporting tool**    | `node .planning/tools/contrast.js "#fg" "#bg" …` and `node .planning/tools/contrast.js --selftest`                                                                                                                                    |

**Environment constraints that shape everything below.** There is no Ruby, no `bundle`, no `gem` and no `_site/` on this machine, so there is no local Jekyll build; Docker is the only local preview route and the deployed site is the real check. `gh` is absent but the public GitHub REST API answers unauthenticated. The Playwright visual suite must **not** be run or updated — `visual-regression.yml` was deleted in Phase 1, the config hardcodes a `/al-folio` baseurl (this site's is empty), it targets deleted demo routes, and no baseline exists for this site.

---

## Sampling Rate

- **After every task commit:** `bash .planning/phases/02-palette-and-design-tokens/verify.sh` (static only)
- **After every plan wave:** same, plus `npx prettier _sass _config.yml assets/css/main.scss .al-folio-overrides.yml CLAUDE.md --check --end-of-line auto` and `node test/style_contract.js`
- **After the single push (plan 02-04 Task 2):** `verify.sh --live`
- **Before `/gsd:verify-work`:** `--live` must be fully green with zero `[red until …]` labels remaining
- **Max feedback latency:** ~8s static. The live block is network-bound and deliberately excluded from the per-task loop.

**Red-by-design rows are a feature.** Rows that cannot be true yet stay in the harness labelled `[red until plan 02-NN]` and are counted separately in an `EXPECTED_RED` tally. Deleting a row to get a clean tally is forbidden — a criterion that is not yet true must be visibly red, not invisible.

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement                | Test Type     | Automated Command                                                                                        | File Exists | Status    |
| ------- | ---- | ---- | -------------------------- | ------------- | -------------------------------------------------------------------------------------------------------- | ----------- | --------- |
| 2-01-01 | 01   | 1    | TOKEN-03                   | computation   | `node .planning/tools/contrast.js --selftest`                                                             | ❌ W0 (creates) | ⬜ pending |
| 2-01-02 | 01   | 1    | TOKEN-01, TOKEN-06         | harness build | `bash …/verify.sh` runs to a tally; `GLOBAL_TOKENS` holds 30 names read off the served CSS                | ❌ W0 (creates) | ⬜ pending |
| 2-01-03 | 01   | 1    | TOKEN-01                   | static grep   | `grep -q style_contract CLAUDE.md && npx prettier CLAUDE.md --check --end-of-line auto`                   | ✅          | ⬜ pending |
| 2-02-01 | 02   | 2    | TOKEN-02, TOKEN-06         | static grep   | primitive counts 2/4/1/2, step/space counts 4/4, cap comment present, 7 ratio comments matched            | ✅ (after 02-01) | ⬜ pending |
| 2-02-02 | 02   | 2    | TOKEN-01, TOKEN-05, GROUND-01 | static grep | 30 `--global-*` declarations, zero literals among them, `:root,` + `html[data-theme="dark"]`, `color-scheme: light` | ✅          | ⬜ pending |
| 2-02-03 | 02   | 2    | TOKEN-01                   | static + hash | `@use "tokens";` precedes `@use "custom";`; `.al-folio-overrides.yml` `local_sha256` matches the file     | ✅          | ⬜ pending |
| 2-03-01 | 03   | 3    | TOKEN-02, TOKEN-03         | static grep   | `grep -rn "opacity" _sass/` empty; no hex/rem/px/em/`color-mix` in `_custom.scss`; `#5c5349` ≥ 4.5:1      | ✅          | ⬜ pending |
| 2-03-02 | 03   | 3    | TOKEN-01, GROUND-04        | static grep   | six override rules present; `.post article a` underlined; `:focus-visible` with offset; no `outline: none` | ✅          | ⬜ pending |
| 2-04-01 | 04   | 4    | TOKEN-04, TOKEN-05         | static grep   | three flags `false`, `max_width` untouched, Prettier + style contract pass, full static block green       | ✅          | ⬜ pending |
| 2-04-02 | 04   | 4    | TOKEN-01, GROUND-01        | live          | `bash …/verify.sh --live` — 7 pages 200, served CSS greps, served HTML zero-counts                        | ✅          | ⬜ pending |
| 2-04-03 | 04   | 4    | GROUND-01, GROUND-04, TOKEN-04 | **manual** | checkpoint:human-verify — see Manual-Only table                                                          | n/a         | ⬜ pending |

_Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky_

**Sampling continuity check:** no three consecutive tasks lack an `<automated>` verify. The only manual task, `2-04-03`, is the last task of the last plan and is preceded by two fully automated tasks.

---

## Wave 0 Requirements

Wave 0 is plan **02-01**, which runs alone in Wave 1 for exactly this reason. Everything downstream depends on it.

- [ ] `.planning/tools/contrast.js` — zero-dependency WCAG 2.x relative-luminance calculator with a `--selftest` flag asserting the eight pre-measured figures from `.planning/research/PITFALLS.md` to within 0.01. Covers TOKEN-03, criterion 4, criterion 5's "each colour token carrying its measured contrast ratio", and forward to Phase 8's QA-01.
- [ ] `.planning/phases/02-palette-and-design-tokens/verify.sh` — the phase harness, shaped exactly like `.planning/phases/01-deployment-guardrails/verify.sh`: `set -uo pipefail` (never `-e`), a non-aborting `check` function, a `--live` flag, a tally, `exit 0` only at zero failures.
- [ ] A `GLOBAL_TOKENS` array inside that harness holding the **30** `--global-*` names, extracted from the live served `main.css` rather than typed from a document. ROADMAP, STACK and CONTEXT all say 29 and are wrong; the dark block has 29 because it omits `--global-highlight-color`. One check row per name, so a missed token names itself instead of silently staying purple.
- [ ] **No framework install. No npm script. No `package.json` change.**

---

## Manual-Only Verifications

All four sit in plan 02-04 Task 3 as one blocking `checkpoint:human-verify`, batched to avoid verification fatigue. Each is manual for a stated environmental reason, not for convenience.

| Behavior                                                     | Requirement          | Why Manual                                                                                                                                                             | Test Instructions                                                                                                                                                   |
| ------------------------------------------------------------ | -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Criterion 1 — no leftover white panel, no dark-grey bottom bar | GROUND-01, TOKEN-01  | Nothing on this machine renders a page. No Ruby, no `_site/`; the Playwright suite is unusable here and must not be run. `axe.yml` and `lighthouse-badger.yml` are deleted. | Open all seven live URLs in order. Look specifically at the projects page's `.card` (flush, no shadow), the footer on every page, and the CV page's PDF object and buttons. |
| Criterion 2, second clause — forcing `data-theme="dark"` changes nothing | TOKEN-04, TOKEN-05   | Requires a live DOM and a DevTools console. The *presence* of the mechanism is asserted statically; only its *effect* needs a browser.                                    | DevTools console: `document.documentElement.setAttribute('data-theme','dark')`. Nothing may change colour. A dark background is a real failure — report, do not approve.  |
| Criterion 3 — links identifiable in a greyscale screenshot     | GROUND-04            | Greyscale perception of a rendered page. No headless tooling exists here.                                                                                              | DevTools → Rendering → Emulate vision deficiencies → Achromatopsia, on the home page and one list page. Body-copy links underlined; navbar/footer links deliberately not. |
| Register sanity — "deliberate recolour" vs "broken"            | (phase goal)         | Judgement, not measurement.                                                                                                                                            | One sentence from the reviewer. Plain is expected at this stage (type is still gem default); broken is not.                                                            |

**Two things that look manual but are NOT, and must be automated:**

- **Criterion 1's code-block clause.** No page on this site renders a code block or inline code today (zero fenced blocks; the only backticks in `_pages/` sit inside a YAML comment). It is verified by CSS inspection of the served stylesheet — `--global-code-bg-color: var(--paper-200)` — never visually. Do not add a throwaway page to make it visual.
- **Criterion 4's contrast measurements.** ROADMAP wording says "with the DevTools colour picker". The contrast tool reproduces every published figure exactly and is scriptable, so `.entry-year`, `.entry-meta`, `.entry-status` and `.subject-grade` are all checked by `node .planning/tools/contrast.js "#5c5349" "#faf6ee"` → 6.99:1, plus the static grep proving all four carry `var(--ink-500)`. Phase 8's QA-01 still re-measures on the final *composited* ground (text over Phase 4 texture), which is a different measurement and is correctly deferred.

---

## Open Questions Resolved During Planning

| Question (02-RESEARCH.md §"Open Questions")     | Decision                                                                                                                                                                                                                   | Where implemented |
| ------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------- |
| Which rule token `--global-divider-color` uses   | `var(--rule-200)` (1.43:1, decorative) — matches CONTEXT verbatim; its 31 consumers are decorative furniture. Site-owned structural separators (`.subject`) get an explicit `var(--rule-500)` (3.08:1). Revisit in Phase 7. | 02-02, 02-03      |
| Separate token file or a block in `_custom.scss` | **Separate file `_sass/_tokens.scss`**, pulled in by one new `@use "tokens";` line placed before `@use "custom";`. Criterion 5's "one token file" becomes literally true and greppable.                                     | 02-02 Task 3      |
| How `.al-folio-overrides.yml` gets updated       | By hand. `bundle exec al-folio upgrade overrides accept` cannot run (no Ruby), and nothing runs the override audit in CI (`upgrade-check.yml` was deleted in Phase 1). Recompute `sha256sum`, bump `acknowledged_at`, add a YAML comment recording the hand edit and the CRLF caveat. | 02-02 Task 3      |
| Whether to set `--global-hover-text-color`       | **Yes**, to `var(--paper-100)`. No firing consumer today, but TOKEN-01 requires all 30 re-pointed and criterion 5 forbids a live gem literal. `#faf6ee` on `#1d4ed8` = 6.22:1.                                              | 02-02 Task 2      |

---

## Out of Scope, Stated Explicitly

`AGENTS.md`, `docs/ARCHITECTURE.md` and `docs/BOUNDARIES.md` carry the upstream thin-starter contract wholesale, including a stop sign that forbids `_sass/` — which is false for this fork (`test/style_contract.js` has that loop commented out, and its only runner `unit-tests.yml` was deleted in Phase 1). Rewriting those three files is a documentation milestone of its own and no Phase 2 requirement covers it. **Phase 2 does the minimum that protects its own output: an additive reconciliation note in `CLAUDE.md` (plan 02-01 Task 3)** naming the disabled check, the empty baseurl, and `_sass/_tokens.scss` as deliberate. The rest is a knowing, recorded divergence, not an oversight.

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or a Wave 0 dependency (plan 02-01 creates both tools; the one manual task is a justified `checkpoint:human-verify`)
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references (`contrast.js`, `verify.sh`, the 30-name list)
- [x] No watch-mode flags
- [x] Feedback latency < 8s for the static loop; network rows isolated behind `--live`
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** approved 2026-09-14

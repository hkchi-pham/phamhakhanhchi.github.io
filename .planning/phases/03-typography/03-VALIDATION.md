---
phase: 3
slug: typography
status: complete
nyquist_compliant: true
wave_0_complete: true
created: 2026-09-16
updated: 2026-09-17
---

# Phase 3 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property                | Value                                                                                                                                              |
| ----------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Framework**           | **none, and none may be added.** 01-VALIDATION forbids a starter-local build/test pipeline; 02-VALIDATION carries it forward; `AGENTS.md` rejects `build:css`/`build:tailwind` npm scripts outright. |
| **Config file**         | none — no `package.json` change, no npm script, no gem                                                                                             |
| **Quick run command**   | `bash .planning/phases/03-typography/verify.sh`                                                                                                    |
| **Full suite command**  | `bash .planning/phases/03-typography/verify.sh --live`                                                                                             |
| **Estimated runtime**   | ~5s static (measured 4s; `npx prettier` dominates) · ~30–60s live once the fonts URL lands (measured 12s today, because the empty `FONTS_URL` short-circuits the budget fetch; the full path downloads 141,232 B of webfonts plus the 323,520 B icon report) |
| **Supporting tools**    | `.planning/tools/fontbudget.js` (new, this plan) and `.planning/tools/contrast.js` (Phase 2) — both zero-dependency Node, both carry `--selftest`   |

**What the harness is.** A flat `check <label> <expr>` list plus a tally, `set -uo pipefail`
and never `set -e`, copied in shape from `.planning/phases/02-palette-and-design-tokens/verify.sh`.
**38 static rows, 80 with `--live`.**

**What the harness is not.** There is no Ruby, no `bundle`, no `_site/`, no local Jekyll
build and no local PurgeCSS run on this machine. The Playwright suite must NOT be run
(deleted workflow, `/al-folio` baseurl, no baseline worktree). The source of truth for CSS
is therefore never `_sass/` — it is `https://phamhakhanhchi.com/assets/css/main.css`.

---

## Sampling Rate

- **After every task commit:** `bash .planning/phases/03-typography/verify.sh` (static, ~5s).
  The row(s) the task was supposed to turn green must be green, and `UNLABELLED` must be 0.
- **After every plan wave:** static run **plus** `npx prettier _sass _config.yml purgecss.config.js --check --end-of-line auto`
  and `node test/style_contract.js` — both are already rows in the harness, so the wave gate
  is "the static run is green apart from rows labelled for a LATER plan".
- **After the phase's single push (plan 03-04):** `bash .planning/phases/03-typography/verify.sh --live`,
  **polling for ~2–3 minutes**. Measured push-to-served-CSS latency across three deploys is
  112–168s, and `main.css` is served with `Cache-Control: max-age=600` behind a CDN — every
  live fetch carries `?cb=$(date +%s)`. One refresh at t=120s showing the old stylesheet is
  not evidence of failure.
- **Before `/gsd:verify-work`:** `--live` must be 0 failed and 0 red-by-design.
- **Max feedback latency:** ~5 seconds for any static criterion; one deploy cycle (~2–3 min)
  for anything that can only be true in the served asset.

**Red-by-design accounting.** The harness was written in plan 03-01, before any type
changed, so most rows fail on the day they were committed. A row that cannot be true yet
carries `[red until plan 03-NN]` naming the plan that makes it true, and is counted in
`EXPECTED_RED`. A row that is green today and must merely STAY green carries NO label
(Phase 2 decision — a label on a green row absorbs a future regression into the expected
count and hides it). Never delete a row to clean the tally.

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement                                     | Test Type          | Automated Command                                                                                                     | File Exists | Status     |
| ------- | ---- | ---- | ----------------------------------------------- | ------------------ | --------------------------------------------------------------------------------------------------------------------- | ----------- | ---------- |
| 3-01-01 | 01   | 1    | TYPE-05                                         | tool self-test + network measurement | `node .planning/tools/fontbudget.js --selftest` then `FONTS_URL="<css2 url>" node .planning/tools/fontbudget.js --max 153600` | ✅          | ✅ green    |
| 3-01-02 | 01   | 1    | TYPE-01 · TYPE-02 · TYPE-03 · TYPE-04 · TYPE-05 | harness + recorded `curl` proof | `bash .planning/phases/03-typography/verify.sh` — runs to a tally with `UNLABELLED` = 0                                | ✅          | ✅ green    |
| 3-01-03 | 01   | 1    | TYPE-02 · TYPE-05                               | **decision (manual)** | none — a textual contradiction in CONTEXT.md, resolvable only by the site's owner. ANSWERED 2026-09-16: `status-serif` + `title-full` (see `03-01-SUMMARY.md`) | n/a         | ✅ green    |
| 3-02-01 | 02   | 2    | TYPE-01 · TYPE-05                               | static grep        | `grep -qF 'css2?family=Be+Vietnam+Pro' _config.yml && ! grep -qF 'Material+Icons' _config.yml && ! grep -qE '^  (academicons\|scholar-icons):' _config.yml` | ✅          | ✅ green    |
| 3-02-02 | 02   | 2    | TYPE-02 · TYPE-04                               | static grep        | the 12 `--step-*` / `--font-*` / `--measure` / `--leading-*` rows of `verify.sh`                                      | ✅          | ✅ green    |
| 3-03-01 | 03   | 3    | TYPE-02 · TYPE-03                               | static grep        | the 5 `_custom.scss` rows of `verify.sh` (serif body, sans labels, h1/h2 at 600, `.navbar-brand .font-weight-bold`)   | ✅          | ✅ green    |
| 3-03-02 | 03   | 3    | TYPE-04                                         | static grep        | `max-width: var(--measure)` row plus the 3 `purgecss.config.js` safelist rows (`"ol"`, `"blockquote"`, `"h4"`)        | ✅          | ✅ green    |
| 3-04-01 | 04   | 4    | TYPE-01 · TYPE-02 · TYPE-03 · TYPE-04 · TYPE-05 | live, served-asset | `bash .planning/phases/03-typography/verify.sh --live` — 42 network rows, of which 8 are the fragile measure nodes    | ✅          | ✅ green    |
| 3-04-02 | 04   | 4    | TYPE-03 · TYPE-04                               | **human-verify (manual)** | none — see Manual-Only Verifications below; all four rows land in this one batched checkpoint                  | n/a         | ✅ green    |
| 3-04-03 | 04   | 4    | TYPE-01 · TYPE-02 · TYPE-03 · TYPE-04 · TYPE-05 | live, served-asset | `bash .planning/phases/03-typography/verify.sh --live` → 0 failed, 0 red-by-design, every `[red until plan 03-NN]` label stripped | ✅          | ✅ green    |

_Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky_

**Red is the expected state for rows 3-02-01 onward on 2026-09-16.** They are written
before the work, which is the point.

> **Annotation, 2026-09-17 (plan 03-04).** The sentence above is left byte-for-byte as it
> was written, per the SAFE-04 convention — a validation record describes what was true on
> the day it was written, and is annotated rather than edited. As of the phase's single
> deploy (`b5dcdea`, `gh-pages` `54483db` → `a5553c1`) every row above is green:
> `verify.sh --live` reports **80 checks, 0 failed** and `verify.sh` static reports
> **38 checks, 0 failed**, with all 49 `[red until plan 03-NN]` labels stripped in `ed66ce3`
> and `EXPECTED_RED` back to 0. A red row from here on is a real regression.

---

## Wave 0 Requirements

- [x] `.planning/tools/fontbudget.js` — zero-dependency byte counter for a Google Fonts
      `css2` URL; `--max` exits nonzero over budget, `--report-only` records the icon
      payload without budgeting it, `--selftest` asserts the parser against an inline
      fixture with a duplicated woff2 URL. Covers **TYPE-05**.
- [x] `.planning/phases/03-typography/verify.sh` — 38 static + 42 `--live` assertion rows
      for **TYPE-01 … TYPE-05**, red-by-design, executable, with the budget stated in bytes
      and `FONTS_UA` baked into every fonts fetch.
- [x] The two-family Vietnamese `curl` proof, run and recorded **verbatim in the commit
      message body** of plan 03-01 task 2 — criterion 2's literal "verified by `curl` and
      recorded in the commit". 5 `/* vietnamese */` blocks, every one carrying
      `U+1EA0-1EF9`.
- [x] No framework install, no npm script, no `package.json` change, no gem.

---

## Manual-Only Verifications

Exactly four, all batched into plan 03-04's single `checkpoint:human-verify`. Everything
else this phase claims has a row in `verify.sh`.

| Behavior                                  | Requirement | Why Manual                                                                                                                                                                                                                                   | Test Instructions                                                                                                                                                                                                                                                                                                                                 |
| ----------------------------------------- | ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| The name renders in ONE typeface at ≥48px | TYPE-03     | `ạ` and `à` come from two different subset FILES of the same family. That both files loaded and composed identically is a rendering outcome; no grep can see it. The harness proves the blocks are SERVED, not that the glyphs match on screen. | Open `https://phamhakhanhchi.com/`. `h1.post-title` renders at ~44px (2.6 × 17px), **below** the criterion's "48px or larger" — that clause describes how to INSPECT, not how big the h1 must be, so **zoom to 125% or bump font-size in DevTools. Do NOT size the h1 up to 48px.** Compare `ạ` in "Phạm" against `à` in "Hà". Then check the navbar brand on `/academics/` is one weight throughout. |
| Characters per line inside the measure     | TYPE-04     | CPL is a laid-out result of font metrics, wrapping and container width. `36rem` is asserted statically and in the served CSS; the resulting character count needs a layout engine.                                                             | On `https://phamhakhanhchi.com/`, run the `Range.getClientRects()` snippet in plan 03-04's checkpoint and report `cpl`. Expected 66–71 against a 45–75 window. Over 75 → `--measure: 34rem` (544px → ~66.7). Also judge whether the ~354px right gutter reads as deliberate or as broken layout.                                                     |
| `--underline-offset` vs Literata's descenders | GROUND-04 (Phase 2), re-opened by TYPE-02 | `0.18em` was tuned and human-approved in Phase 2 against **Roboto**. Literata's descenders are ~26% deeper relative to em (−308/1000 vs −500/2048), so a collision is more likely than not — but whether it collides is a browser observation, not a computation. | Find a body-copy link containing `ạ` or `ợ` on `/` or `/research/`. Zoom to 200%. Does the underline touch or cut the mark? Report "clears" or "collides". A collision is a one-line token change in `_sass/_tokens.scss`, applied in plan 03-04 task 3. **Do not re-tune it blind in 03-02.**                                                        |
| The fallback-swap glance                   | TYPE-01 · TYPE-05 | `display=swap` guarantees text is visible during the swap window; what that window LOOKS like cannot be fetched. Whether Georgia carries `ạ` on the user's actual OS is a per-machine fact.                                                    | Network → throttle to Slow 3G, hard-reload. During the second or two before Literata arrives: does `ạ` render as a letter rather than a tofu box, and does the page RELAYOUT or merely settle? Georgia was chosen over Times New Roman because it is −5% on x-height against Literata rather than −12%, so a small settle is expected and acceptable. |

### Checkpoint verdict — row `3-04-02`, 2026-09-17: **APPROVED**

The reviewer answered plan 03-04's batched `checkpoint:human-verify` after Task 1's single
push (`b5dcdea`, `gh-pages` `54483db` → `a5553c1`, served `main.css` 27,285 B → 28,546 B).
The reply was the single word **"approved"**, given as the verdict on all four checks. This
checkpoint asked about what Phase 3 changed **only**; Phase 2's seven-page palette sweep
(row `2-04-03`) and keyboard-focus checks (row `2-05-03`) were already approved and were
deliberately not re-requested.

| Check | Question                                                   | Requirement | Verdict                                                | Notes |
| ----- | ---------------------------------------------------------- | ----------- | ------------------------------------------------------ | ----- |
| A | The name in one typeface (`ạ` vs `à`), and the navbar brand at one weight | TYPE-03 | **APPROVED** (user sign-off) | A yes/no question, cleanly answered. Both Literata subset files — latin for `à`, vietnamese for `ạ` — composed as one face, and the `.navbar-brand .font-weight-bold { font-weight: inherit }` fix from 03-03 holds across pages. No defect reported, so neither of the checkpoint's diagnoses fires: no fallback substitution, no purged `.navbar-brand` override. |
| B | Characters per line inside the measure, and whether the right gutter reads as deliberate | TYPE-04 | **approved (user sign-off; no numeric reading supplied)** | The reviewer approved the check but **did not report the `cpl` number** the `Range.getClientRects()` snippet returns. No figure is recorded here, because none was observed — the predicted 66–71 against the 45–75 window is a computation from `--measure: 36rem`, not a measurement, and writing it in as though it were read off the page would be a fabrication. **Phase 8's QA audit should re-run the snippet and record the actual number.** The ~354px right gutter was accepted as deliberate; `--measure` did not move. |
| C | `--underline-offset: 0.18em` against Literata's deeper descenders | GROUND-04 (Phase 2), re-opened by TYPE-02 | **approved (user sign-off; no numeric reading supplied)** | The reviewer approved the check but **did not return the literal word "clears"** the resume-signal asked for, and supplied no `offset` reading. Recorded as approved on the reviewer's authority; no observation is recorded as though it had been made. **`--underline-offset` therefore stays at `0.18em` and no token moved — no second push.** See the scope discrepancy recorded below, which this approval does **not** close. |
| D | The fallback during the swap window — `ạ` as a letter not tofu, settle not reflow | TYPE-01 · TYPE-05 | **APPROVED** (user sign-off) | A yes/no question, cleanly answered. Georgia carries `ạ` on the reviewer's machine and the swap settles rather than reflowing, which is the outcome the −5% x-height choice over Times New Roman was made to buy. |

**No token moved.** `--underline-offset: 0.18em` and `--measure: 36rem` stand exactly as
plan 03-02 shipped them, recorded here the way row `2-05-03` recorded its approved values.
Neither of the checkpoint's two contingencies fired (C "collides" → `0.24em`; B `cpl > 75` →
`--measure: 34rem`), so plan 03-04 Task 3 changed no source file and the phase closed on one
deploy.

#### Open discrepancy carried out of check C — the underline provenance does not match the rule's scope

Approving C does **not** close this, and it is recorded here so a later phase inherits it
rather than re-discovering it:

- The underline rule is scoped to **`.post article a`** (`_sass/_custom.scss:302`). Across
  all seven deployed pages there are **six** such links, and **none of them contains a
  Vietnamese below-baseline mark.**
- The only `ạ` inside a link on this site is the **navbar brand**, which sits outside
  `.post` and carries **no underline at all** — deliberately, per 02-03's "navigational
  furniture stays bare" decision.
- Meanwhile `_sass/_tokens.scss:190` justifies the value in these words:
  `--underline-offset: 0.18em; /* clears the Vietnamese below-baseline marks in "Phạm Hà Khánh Chi": ạ, ợ */`
  — a provenance that describes a case **the rule does not actually cover**.

So the token's stated reason and the token's actual reach have never agreed, on Roboto or on
Literata. The value is not wrong; its recorded justification is unfalsifiable as written,
which means neither Phase 2's approval nor Phase 3's re-check ever tested the thing the
comment claims. **The comment was deliberately NOT edited** — papering over the gap would
destroy the finding, and this project's convention (SAFE-04) is to annotate rather than
silently rewrite. Natural owners: **Phase 4 (marginalia)**, which is the next phase to touch
link treatment and may widen the rule's scope, or **Phase 8 (QA audit)**, which can retire
the claim or produce a link that actually exercises it.

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or a Wave 0 dependency — the only exceptions are
      the two checkpoint tasks (3-01-03, 3-04-02), both of which are genuinely
      human-resolvable and both of which are recorded in this document.
- [x] Sampling continuity: no 3 consecutive tasks without automated verify. The longest run
      without one is 3-01-03 → 3-02-01, a single checkpoint.
- [x] Wave 0 covers all MISSING references — `fontbudget.js` and `verify.sh` both existed
      before any `_config.yml`, `_sass/` or `purgecss.config.js` edit.
- [x] No watch-mode flags anywhere.
- [x] Feedback latency < 5s for every static criterion.
- [x] Every criterion that CAN be automated has a numbered row that is red today and goes
      green as the work lands — 58 of 80 rows were red at the moment this file was written.
- [x] `nyquist_compliant: true` set in frontmatter.

**Approval:** approved 2026-09-16

### Phase close-out, 2026-09-17

- [x] Every automated row green: `verify.sh` **38 checks, 0 failed**; `verify.sh --live`
      **80 checks, 0 failed**, both against the deployed site, not against `_sass/`.
- [x] All 49 `[red until plan 03-NN]` labels stripped (`ed66ce3`); `EXPECTED_RED` is 0 and
      the labelling mechanism plus its header comment survive for later phases. No row was
      deleted, weakened or renumbered at any point in this phase.
- [x] All four manual rows (A, B, C, D) answered and dated above, on the reviewer's
      authority, with **no numeric reading back-filled for B or C**.
- [x] TYPE-01 … TYPE-05 marked Complete in `.planning/REQUIREMENTS.md` — here and only
      here, at the last plan that touches them, per the 02-04 precedent.
- [x] One open discrepancy carried forward rather than closed: the `--underline-offset`
      provenance (see check C above). It is **not** a Phase 3 defect and blocks nothing.

**Status:** complete 2026-09-17

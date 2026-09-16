---
phase: 3
slug: typography
status: approved
nyquist_compliant: true
wave_0_complete: true
created: 2026-09-16
updated: 2026-09-16
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
| 3-02-01 | 02   | 2    | TYPE-01 · TYPE-05                               | static grep        | `grep -qF 'css2?family=Be+Vietnam+Pro' _config.yml && ! grep -qF 'Material+Icons' _config.yml && ! grep -qE '^  (academicons\|scholar-icons):' _config.yml` | ✅          | ❌ red      |
| 3-02-02 | 02   | 2    | TYPE-02 · TYPE-04                               | static grep        | the 12 `--step-*` / `--font-*` / `--measure` / `--leading-*` rows of `verify.sh`                                      | ✅          | ❌ red      |
| 3-03-01 | 03   | 3    | TYPE-02 · TYPE-03                               | static grep        | the 5 `_custom.scss` rows of `verify.sh` (serif body, sans labels, h1/h2 at 600, `.navbar-brand .font-weight-bold`)   | ✅          | ❌ red      |
| 3-03-02 | 03   | 3    | TYPE-04                                         | static grep        | `max-width: var(--measure)` row plus the 3 `purgecss.config.js` safelist rows (`"ol"`, `"blockquote"`, `"h4"`)        | ✅          | ❌ red      |
| 3-04-01 | 04   | 4    | TYPE-01 · TYPE-02 · TYPE-03 · TYPE-04 · TYPE-05 | live, served-asset | `bash .planning/phases/03-typography/verify.sh --live` — 42 network rows, of which 8 are the fragile measure nodes    | ✅          | ❌ red      |
| 3-04-02 | 04   | 4    | TYPE-03 · TYPE-04                               | **human-verify (manual)** | none — see Manual-Only Verifications below; all four rows land in this one batched checkpoint                  | n/a         | ⬜ pending  |
| 3-04-03 | 04   | 4    | TYPE-01 · TYPE-02 · TYPE-03 · TYPE-04 · TYPE-05 | live, served-asset | `bash .planning/phases/03-typography/verify.sh --live` → 0 failed, 0 red-by-design, every `[red until plan 03-NN]` label stripped | ✅          | ❌ red      |

_Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky_

**Red is the expected state for rows 3-02-01 onward on 2026-09-16.** They are written
before the work, which is the point.

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

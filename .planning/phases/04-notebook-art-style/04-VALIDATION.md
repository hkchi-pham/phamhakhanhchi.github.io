---
phase: 4
slug: notebook-art-style
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-09-18
---

# Phase 4 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.
> Derived from the Validation Architecture section of `04-RESEARCH.md`.

---

## Test Infrastructure

| Property              | Value                                                                                                                                                                                       |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Framework**         | **None, by standing convention.** No browser test framework, no npm test script, no `package.json` change. The phase harness is a flat list of shell assertions plus a tally.                |
| **Config file**       | none — Wave 0 writes `verify.sh`                                                                                                                                                            |
| **Quick run command** | `bash .planning/phases/04-notebook-art-style/verify.sh`                                                                                                                                     |
| **Full suite command**| `bash .planning/phases/04-notebook-art-style/verify.sh --live`                                                                                                                              |
| **Estimated runtime** | ~2s static · ~15s `--live` (network fetches)                                                                                                                                                |

**Supporting tools (already in repo):**

- `node .planning/tools/contrast.js --selftest`
- `node test/style_contract.js`
- `npx prettier _sass docs/NOTEBOOK-MARKS.md _data _pages purgecss.config.js --check --end-of-line auto`

**Harness shape:** copy the Phase 3 harness verbatim — `set -uo pipefail` (never `-e`), the `check()` function, the `CHECKS` / `FAILED` / `EXPECTED_RED` tally, the `--live` flag, `[red until plan 04-NN]` labelling, and the `?cb=$(date +%s)` cache-buster on every fetch of `main.css`. Phase 3 closed with `EXPECTED_RED` at 0 and kept the mechanism specifically for this phase.

---

## Sampling Rate

- **After every task commit:** `bash .planning/phases/04-notebook-art-style/verify.sh` (static only — no network)
- **After every plan wave:** static harness + `npx prettier … --check --end-of-line auto` + `node test/style_contract.js` + `node .planning/tools/contrast.js --selftest`
- **Before `/gsd:verify-work`:** `verify.sh --live` with `FAILED = 0` and `EXPECTED_RED = 0` after the single push, plus the batched human checkpoint
- **Max feedback latency:** ~2 seconds (static), ~15 seconds (`--live`)

---

## Per-Task Verification Map

| Req / Criterion | Behaviour                                                          | Test Type   | Automated Command                                                                                                                                   | File Exists | Status    |
| --------------- | ------------------------------------------------------------------ | ----------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- | --------- |
| GROUND-02       | Texture token exists, in the token file, with pinned filter region | static grep | `grep -qE -- "--paper-texture:[[:space:]]*url\("` + `grep -qF "stitchTiles='stitch'"` + `grep -qF "x='0' y='0'"` on `_sass/_tokens.scss`             | ❌ W0       | ⬜ pending |
| GROUND-02       | Data URI is under 2,048 bytes                                      | static      | `[ "$(grep -o 'url("data:image/svg+xml,[^"]*"' _sass/_tokens.scss \| head -1 \| wc -c)" -lt 2048 ]`                                                  | ❌ W0       | ⬜ pending |
| GROUND-02       | No `background-attachment: fixed` anywhere                         | static grep | `! grep -rqE 'background-attachment:[[:space:]]*fixed' _sass/`                                                                                       | ❌ W0       | ⬜ pending |
| GROUND-02       | No literal SVG/URL leaked into the consumer file                   | static grep | `! grep -q 'data:image/svg' _sass/_custom.scss` — the inherited `custom_has_no_literals` matcher does **not** catch this                             | ❌ W0       | ⬜ pending |
| GROUND-02       | Zero new network requests                                          | static grep | `! grep -rq 'assets/img/.*tex' _sass/ _config.yml` + no new file under `assets/`                                                                     | ❌ W0       | ⬜ pending |
| GROUND-02       | body / navbar / card consume the token in the **served** CSS       | live grep   | `grep -qE 'body\{[^}]*background-image:[[:space:]]*var\(--paper-texture\)' "$LIVE_CSS"` — one row per selector                                       | ❌ W0       | ⬜ pending |
| GROUND-02       | No paint jank on a 390px phone at reading distance                 | **manual**  | DevTools Performance, 4× CPU throttle, paint flashing; then a real phone                                                                             | manual      | ⬜ pending |
| GROUND-03       | Vocabulary document exists, names four marks with defences         | static grep | `[ -f docs/NOTEBOOK-MARKS.md ]` + one `grep -q` per mark name + `[ "$(grep -c '^Defence:' docs/NOTEBOOK-MARKS.md)" = "4" ]`                          | ❌ W0       | ⬜ pending |
| GROUND-03       | The cap reads 4 and sits with the other caps                       | static grep | `grep -qE "notebook marks[ .]+4" _sass/_tokens.scss`                                                                                                | ❌ W0       | ⬜ pending |
| GROUND-03       | The blocklist is in the same document                              | static grep | one `grep -qi` per banned item (coffee, tape, paperclip, torn, spiral, ruled, rotated)                                                               | ❌ W0       | ⬜ pending |
| GROUND-03       | Nothing on the blocklist ships (criterion 5)                       | static grep | `! grep -rqiE 'coffee\|washi\|paperclip\|pushpin\|spiral\|page-curl' _sass/` and `! grep -rqE 'rotate\(\|skew\(' _sass/`                             | ❌ W0       | ⬜ pending |
| GROUND-03       | The section rule reaches the served CSS                            | live grep   | `grep -qE '\.entry-group-title[^{]*\{[^}]*border-bottom' "$LIVE_CSS"`                                                                                | ❌ W0       | ⬜ pending |
| GROUND-03       | Rule token carries its **composited** ratio ≥ 3.0                  | tool        | `node .planning/tools/contrast.js "<rule-token>" "#eeeae2"` — see Pitfall 1 / open question 2                                                        | ✅ exists   | ⬜ pending |
| GROUND-05       | No pseudo-element carries announceable text                        | static grep | `! grep -rnE 'content:[[:space:]]*"[^"]+"' _sass/` — only `content: ""` permitted                                                                    | ❌ W0       | ⬜ pending |
| GROUND-05       | The note is a real element in reading order                        | live grep   | `grep -qE '<aside class="entry-note">' "$LIVE_HTML_RESEARCH"` and it appears **after** its `.entry-body` in source order                             | ❌ W0       | ⬜ pending |
| GROUND-05       | Stylesheet-off: content complete, no orphaned symbol               | **manual**  | DevTools → disable `main.css` → reload all seven pages                                                                                               | manual      | ⬜ pending |
| Criterion 4     | ≤2 purely decorative marks in any first viewport                   | **manual**  | full-page screenshot per page, counted on the screenshot                                                                                             | manual      | ⬜ pending |
| Criterion 4     | Greyscale + 8px blur: headings strongest                           | **manual**  | screenshot, desaturate, blur                                                                                                                         | manual      | ⬜ pending |
| Regression      | `.entry-note` survived PurgeCSS                                    | live grep   | `grep -q '\.entry-note' "$LIVE_CSS"` — the `.topic-list` precedent                                                                                   | ❌ W0       | ⬜ pending |
| Regression      | Prettier and the style contract stay green                         | command     | `npx prettier … --check --end-of-line auto` · `node test/style_contract.js`                                                                          | ✅ exists   | ⬜ pending |

_Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky_

---

## Wave 0 Requirements

- [ ] `.planning/phases/04-notebook-art-style/verify.sh` — the whole harness; copy the Phase 3 shape, keep the red-by-design header comment
- [ ] A static texture swatch for choosing the rect `opacity` (α) in a browser (Pitfall 7) — throwaway, under `.planning/tools/`
- [ ] `docs/NOTEBOOK-MARKS.md` — the criterion-2 artefact itself; it is a deliverable **and** the thing several rows grep
- [ ] A named human checkpoint asking the site owner for 1–2 real notes on **specifically named** research entries (CONTEXT requires the ask be specific)
- [ ] No framework install, no npm script, no `package.json` change

---

## Manual-Only Verifications

Five rows are genuinely manual. That is not a gap — criteria 1, 3 and 4 are written as human observations, and `axe.yml` is `workflow_dispatch`-only while `lighthouse-badger.yml` measures the upstream demo. **Batch all five into one named `checkpoint:human-verify`, following the 03-04 precedent.**

| Behavior                                  | Requirement             | Why Manual                                    | Test Instructions                                                                                             |
| ----------------------------------------- | ----------------------- | --------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| No paint jank on a 390px phone            | GROUND-02 / criterion 1 | Perceptual + device-dependent; no device lab   | DevTools Performance with 4× CPU throttle and paint flashing at 390px, then confirm on a real phone           |
| Texture visible at normal reading distance| GROUND-02 / criterion 1 | Perceptual judgement by design                 | View desktop and 390px at arm's length; texture present but never noticed as a pattern                        |
| Stylesheet-off loses no information       | GROUND-05 / criterion 3 | Requires reading seven pages as prose          | DevTools → disable `main.css` → reload all seven pages; no orphaned or unexplained symbol                     |
| ≤2 decorative marks per first viewport    | criterion 4             | Must be counted on a screenshot, not eyeballed | Full-page screenshot per page at desktop and 390px; count purely decorative marks above the fold              |
| Greyscale + blur: headings strongest      | criterion 4             | Perceptual hierarchy check                     | Screenshot → desaturate → 8px blur; headings must remain the strongest element                                |

---

## Validation Sign-Off

- [ ] All tasks have an `<automated>` verify or a Wave 0 dependency
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all ❌ W0 references above
- [ ] No watch-mode flags
- [ ] Feedback latency < 15s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending

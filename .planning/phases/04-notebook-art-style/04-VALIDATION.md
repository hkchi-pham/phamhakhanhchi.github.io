---
phase: 4
slug: notebook-art-style
status: draft
nyquist_compliant: false
wave_0_complete: true
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
| GROUND-03       | Rule token carries its **composited** ratio ≥ 3.0                  | tool        | `node .planning/tools/contrast.js "#8d7b60" "#ebe7e0"` = 3.32:1 — ground re-derived at the chosen alpha 0.06; `#eeeae2` was the alpha-0.05 placeholder                                                        | ✅ exists   | ⬜ pending |
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

- [x] `.planning/phases/04-notebook-art-style/verify.sh` — the whole harness; copy the Phase 3 shape, keep the red-by-design header comment
      _(plan 04-01 task 1: 53 static rows, 33 red-by-design, 0 unlabelled. `--live` adds 20 more.)_
- [x] A static texture swatch for choosing the rect `opacity` (α) in a browser (Pitfall 7) — throwaway, under `.planning/tools/`
      _(plan 04-01 task 2: `.planning/tools/texture-swatch.html` — flat control + α 0.035 / 0.05 / 0.06 / 0.07, five distinct filter ids, one 390px panel.)_
- [x] `docs/NOTEBOOK-MARKS.md` — the criterion-2 artefact itself; it is a deliverable **and** the thing several rows grep
      _(plan 04-01 task 3: four marks, exactly four `Defence:` lines, the blocklist, the three recorded non-decisions, the two fallbacks. Harness rows 10–13 are green and their labels are stripped.)_
- [x] A named human checkpoint asking the site owner for 1–2 real notes on **specifically named** research entries (CONTEXT requires the ask be specific)
      _(plan 04-02 task 1, option C: a blocking `checkpoint:decision` that quotes each entry’s current `title`, `status` and `detail` back to the owner.)_
- [x] No framework install, no npm script, no `package.json` change
      _(plan 04-01: `package.json` untouched; the harness is a flat shell list, the swatch is a static HTML file.)_

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

## Checkpoint Verdicts

**Recorded 2026-09-23, plan 04-02 task 1** — a blocking `checkpoint:decision` put to the site owner before any SCSS was written. All three answers arrived together; none was filled in with a default. Two readings were explicitly **not supplied** and are recorded as such rather than invented, following the Phase 3 precedent (an approval that omitted the reading it asked for was recorded as _omitted_, not back-filled).

Plan 04-03 ships the note text **from this section**. It is the owner's own prose; a paraphrase here is a corruption of it.

### A — The texture alpha

**Alpha = 0.06.** Chosen in a browser against `.planning/tools/texture-swatch.html` (flat `#faf6ee` control plus alpha 0.035 / 0.05 / 0.06 / 0.07, each behind real 17px Literata).

| Reading asked for                            | Answer                                                                                                                                                                                                                                                                       |
| -------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| The alpha (0.035 / 0.05 / 0.06 / 0.07)       | **0.06**                                                                                                                                                                                                                                                                     |
| Seams on a ~200px grid at 100% zoom?         | **NOT SUPPLIED.** Recorded as not supplied. Fallback check: plan 04-04's human sweep. The filter region is pinned in source regardless (`x='0' y='0' width='100%25' height='100%25'`), which is the structural defence against seams.                                         |
| Did 17px Literata stay crisp over the grain? | **NOT SUPPLIED.** Recorded as not supplied. Fallback check: plan 04-04's human sweep.                                                                                                                                                                                        |

**The composited grounds were RE-DERIVED at 0.06, not copied.** Black at opacity `a` over `--paper-100` `#faf6ee` (r=250, g=246, b=238) is `round(channel * (1 - a))` per channel; the worst case uses `a`, the mean uses `a/2`.

| Ground                                | Formula                 | Hex at alpha 0.06 |
| ------------------------------------- | ----------------------- | ----------------- |
| mean composited                       | `round(c * (1 - 0.03))` | **`#f3efe7`**     |
| worst-case composited (darkest pixel) | `round(c * (1 - 0.06))` | **`#ebe7e0`**     |

Measured with `.planning/tools/contrast.js` against the alpha 0.06 grounds:

| Colour                       | flat `#faf6ee` | mean `#f3efe7`  | worst `#ebe7e0`                            |
| ---------------------------- | -------------- | --------------- | ------------------------------------------ |
| `--rule-500` `#9c8b6e` (old) | 3.08:1         | **2.89:1 FAIL** | **2.69:1 FAIL**                            |
| `#948267`                    | 3.45:1         | —               | 3.02:1 (clears, no margin)                 |
| `#8d7b60` (chosen)           | 3.79:1         | 3.57:1          | **3.32:1 pass**                            |
| `#88765c`                    | 4.06:1         | —               | 3.56:1                                     |
| `--ink-900` `#1f1b16`        | 15.88:1        | —               | 13.89:1                                    |
| `--ink-800` `#2b2621`        | 13.90:1        | —               | 12.15:1                                    |
| `--ink-700` `#3d3630`        | 11.01:1        | —               | 9.63:1                                     |
| `--ink-500` `#5c5349`        | 6.99:1         | —               | 6.11:1                                     |
| `--accent-600` `#1d4ed8`     | 6.22:1         | —               | 5.44:1                                     |
| `--rule-200` `#d9cfba`       | 1.43:1         | —               | 1.25:1 (decorative-only by prior decision) |

**Every ink step, and the accent, stays comfortably AA on the darker 0.06 ground. `--rule-500` remains the only token the texture breaks — and at 0.06 it breaks harder than the 0.05 figures the plan was written against (2.69 worst, not 2.76).**

**Discrepancy found, resolved in favour of the formula.** 04-02-PLAN's measurements block states that alpha 0.05 yields `#eeeae2` worst and `#f7f3eb` mean. The worst case reproduces; the **mean does not** — `round(c * (1 - 0.025))` gives `#f4f0e8`, not `#f7f3eb` (which is a uniform −3 per channel, roughly alpha 0.012). The plan's own instruction covers this exactly: _"use the formula, not the literals, if the chosen alpha differs."_ The alpha did differ, the formula was used, and the only effect of the error is that the plan's quoted "mean" ratios were measured against a ground lighter than its own formula produces — i.e. the real case for option B1 was slightly stronger than the table showed.

### B — `--rule-500`: **B1, fix now**

`--rule-500` is re-pointed **`#9c8b6e` → `#8d7b60`**, verified at the chosen alpha 0.06 rather than inherited from the 0.05 table: **3.79:1 flat, 3.57:1 mean, 3.32:1 worst case** — clears WCAG 1.4.11's 3:1 floor with headroom on the ground it will actually sit on.

Recorded as the owner asked:

- **This knowingly changes a token Phase 2 shipped and Phase 2 signed off on.** `02-VALIDATION.md` row `2-04-03` returned APPROVED against `#9c8b6e`.
- **The Academics page `.subject` separator will be a hairline darker than the Phase 2 human sweep approved.** `.subject`'s border is an existing live consumer, so this change also repairs a separator that is failing 1.4.11 on the live site **today**, before any texture ships — the defect is pre-existing and the texture would only have deepened it.
- Every other consumer follows automatically from the one-line token change; no rule is rewritten.

### C — The margin notes: a scope change to a **two-state** mark

The site owner supplied real prose for **both** research entries, but roughly 10x longer than a margin note (four paragraphs and three). Rather than discard it, the owner chose a **disclosure toggle**: a short collapsed note that expands on click to the full text.

**Owner's decision, recorded verbatim:**

- The margin note becomes a **TWO-STATE mark**: collapsed = a 1-2 sentence summary; expanded = the owner's full text.
- Implementation must be **native `<details>`/`<summary>`. NO JavaScript.** This keeps it readable with the stylesheet off, keeps all text in the DOM for screen readers, and carries no pseudo-element text — preserving 04-03's accessibility truths.
- **LAYOUT CONSTRAINT (assumption, flagged for 04-04's human sweep):** the EXPANDED body must break out of the ~200px margin column to the entry's own column width. Expanding 230 words inside a 200px column is ~50 lines tall and would collide with the next note, breaking 04-03's "two consecutive notes cannot overlap" truth. The COLLAPSED summary stays in the margin as originally designed.

#### Entry 1 — "Rethinking Attention Sinks: Query-Side Attribution, Layer-Wise Dynamics, and Regime-Dependent Function"

**Kind: the open question.**

**Collapsed summary:**

> Started from a heatmap, not a hypothesis. What drives sink behaviour — not just where it occurs — is the part still being worked out.

**Expanded body** (owner's words; typos corrected, British spelling normalised to match the owner's own "characterised"):

> This research detailed my journey of studying attention sinks. I went from observing the phenomenon to investigating the mechanisms underlying it, beginning from the observation of attention heatmaps to a series of targeted experiments.
>
> I first reproduced and characterised the properties of attention sinks, establishing the phenomenon across different inputs, heads, positions, and languages. From there the research shifted towards understanding what drives and governs sink behaviour rather than simply describing where it occurs.
>
> The main investigation focused on three directions. First, through query-side causal intervention, I examined how differences in the query pathway can determine head-specific sink behaviour, particularly within shared KV groups. Second, I investigated the sink's layer-wise dynamics, examining how its representation and behaviour evolve across transformer layers rather than treating them as a static property. Finally, I explored the regime-dependent function of attention sinks, asking whether their role changes depending on the computational regime and context in which they emerge.
>
> The document therefore records not only the findings themselves, but the progression of my research from visual observation and characterisation towards causal and dynamic explanations of attention sink behaviour.

#### Entry 2 — "Investigating the emergence of echo chambers across three recommender algorithms"

**Kind: the surprising result.**

**Collapsed summary:**

> None of the three real algorithms could form an echo chamber. I had to build a fourth to get the effect — and genres narrowed while distinct titles went up.

**Expanded body** (owner's words; typos corrected):

> Investigated whether recommender algorithms (content-based, collaborative filtering, popularity-based) create "echo chambers" by increasingly reducing the variety of genres a user sees.
>
> I built a simulation of 100 users interacting with a MovieLens-based recommender system across 100 rounds, where each round consisted of generating recommendations, simulating a user click based on a genre-preference model, and feeding that behaviour back into the system. Genre diversity and Shannon entropy of each recommender system were tracked over time as the metrics of exposure narrowing, alongside a random-recommendation baseline to distinguish genuine algorithmic effects from noise.
>
> The three original algorithms proved structurally incapable of forming an echo chamber, since none had the two necessary properties: reading a user's evolving preferences and updating recommendations based on their behaviour. I designed and implemented a fourth, adaptive content-based algorithm specifically to test this hypothesis. This showed a genuine, statistically robust effect: the algorithm's inferred model of user preference measurably diverged from users' true taste over time, with genre-level diversity narrowing significantly compared to a matched non-adaptive control. Interestingly, this narrowing occurred at the genre level while the number of distinct individual titles recommended actually increased, and the effect saturated within roughly 30 interactions rather than compounding indefinitely.

#### Typos corrected in the owner's prose

Recorded so the owner can see exactly what changed in their words:

`"begining"` → `"beginning"`; `"Form therem"` → `"From there"`; `"toweards"` → `"towards"`; `"then simply"` → `"than simply"`; `"attention sink,"` → `"attention sinks,"`; `"three direction"` → `"three directions"`; `"uncapable"` → `"incapable"`; `"an user's"` → `"a user's"`; `"the 2 necessary"` → `"the two necessary"`; `"increasingly reduce"` → `"increasingly reducing"`; `"behavior"` → `"behaviour"` (normalised throughout); `"baseline algorithm"` → `"baseline"`.

### Downstream follow-ups created by answer C

The disclosure toggle changes work that was already planned. **None of it is implemented in plan 04-02** — this plan touches only `_sass/_tokens.scss`, this file, and a label strip in `verify.sh` (see follow-up 4 and the summary's deviations). Recorded here so 04-03 consumes a settled contract rather than re-deciding it:

1. **Plan 04-03 must be amended.** It plans a plain `<aside class="entry-note">`; it becomes a `<details>`/`<summary>` two-state mark, with the expanded-body breakout rule above, plus PurgeCSS safelist entries for any new classes. (The `.topic-list` and bare-`:focus-visible` precedents: an unsafelisted class is stripped from production while every static row still passes.)
2. **`docs/NOTEBOOK-MARKS.md` needs its margin-note `Defence:` sentence updated** to describe a two-state mark rather than a single-state one. The cap stays at **4** — this is the same mark with two states, not a fifth mark. Harness row 12 asserts EXACTLY four `Defence:` lines, so the sentence is rewritten in place and no line is added.
3. **`_data/research.yml` needs TWO keys per entry.** Settled contract, decided here so 04-03 does not have to: **`note:`** carries the collapsed summary (the `<summary>` text) and **`note_full:`** carries the expanded body (the `<details>` body). Both are optional per entry; an entry with `note:` and no `note_full:` renders a plain non-collapsing note, and an entry with neither renders no mark at all. `note_full:` holds multi-paragraph prose, so it takes a YAML block scalar.
4. **Four harness rows now describe markup the two-state decision supersedes, and plan 04-02 deliberately did NOT edit them.** `verify.sh` asserts `<aside class="entry-note">` in `_pages/research.md` (static) and in the served HTML (live row 47), that the aside appears after its `.entry-body` (static and live row 48), and that `.entry-note::before` carries an empty `content` string (static). A `<details>`/`<summary>` mark satisfies none of them as written, and all four are currently red-by-design, so they would fail at 04-03 looking like pending work rather than a stale matcher. **04-03 must narrow or re-point them in the same commit that changes the markup — never delete them**, per the standing rule. Left untouched here because `verify.sh` is outside this plan's `files_modified` and 04-03 owns the markup that decides the new matcher. The `::before` row in particular is load-bearing for GROUND-05: whatever replaces it must still prove that no pseudo-element carries announceable text.

**Open assumption for 04-04's human sweep:** the expanded-body breakout is a layout judgement made from arithmetic, not from a render. If the breakout reads as a jump rather than a disclosure, the fallback is already written in `docs/NOTEBOOK-MARKS.md` — drop the mark, keep ground and type.

---

## Validation Sign-Off

- [ ] All tasks have an `<automated>` verify or a Wave 0 dependency
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all ❌ W0 references above
- [ ] No watch-mode flags
- [ ] Feedback latency < 15s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending

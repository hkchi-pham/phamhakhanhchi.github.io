---
phase: 03-typography
plan: 04
subsystem: deployment
tags: [deploy, gh-pages, served-asset-verification, webfont-budget, purgecss, checkpoint, human-verify, literata, be-vietnam-pro]

# Dependency graph
requires:
  - phase: 03-typography
    provides: "Plan 03-01's verify.sh harness (38 static / 80 live, red-by-design) and fontbudget.js with its FONTS_URL env fallback; plan 03-02's css2 fonts request and the eleven type tokens; plan 03-03's fourteen-selector measure, the weight lever, the four sans classes and the three PurgeCSS safelist entries"
  - phase: 02-palette-and-design-tokens
    provides: "The single-push-per-phase discipline and the measured 112-168s deploy latency; the cache-buster requirement on every served-asset fetch; the served-CSS-is-ground-truth lesson from the stripped :focus-visible rule; the 0.18em --underline-offset this plan had to re-judge against a new typeface"
provides:
  - "Phase 3's typography LIVE on https://phamhakhanhchi.com — the served main.css, not just _sass/, carries every rule plans 03-02 and 03-03 wrote"
  - "verify.sh --live at 80 checks / 0 failed on its FIRST run, with EXPECTED_RED back to 0 and all 49 [red until plan 03-NN] labels stripped"
  - "The measured 141,232 B webfont payload and the separately-recorded 323,520 B declared icon payload, both re-derivable by command"
  - "All four manual verdicts (A, B, C, D) recorded in 03-VALIDATION.md, dated 2026-09-17, with NO numeric reading back-filled"
  - "TYPE-01..TYPE-05 Complete in REQUIREMENTS.md — the phase's requirement discharge"
  - "The gh-pages tip a5553c1c3d8e43ca6ee2e821a119ddc16e3e2cee, which is what Phase 3's close-out tag must point at"
  - "An open discrepancy handed to Phase 4 or Phase 8: the --underline-offset provenance describes a case the rule does not cover"
affects: [04-marginalia, 05-page-composition, 06-hero, 07-mobile-print, 08-qa-audit]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "A phase gets ONE contact with the remote, and the last plan spends it — the fonts URL and the CSS that consumes it must reach visitors in the same deploy or the site serves one family's bytes against another's rules"
    - "A human checkpoint verifies AFTER the automation, never instead of it: all 80 live rows were green before a single question was put to the reviewer"
    - "An approval that omits the reading it was asked for is recorded as an approval WITHOUT the reading — the predicted number is never written in as though it had been observed"
    - "A finding surfaced while answering a check survives the check's approval; approving C did not close C's discrepancy"

key-files:
  created:
    - .planning/phases/03-typography/03-04-SUMMARY.md
  modified:
    - .planning/phases/03-typography/verify.sh
    - .planning/phases/03-typography/03-VALIDATION.md
    - .planning/REQUIREMENTS.md

key-decisions:
  - "NO TOKEN MOVED. --underline-offset stays at 0.18em and --measure stays at 36rem. Neither of the checkpoint's two contingencies fired, so the phase closed on ONE deploy where 02-05's shape (a second push after a checkpoint finding) was budgeted for and expected."
  - "B's cpl figure and C's clears/collides word were NOT back-filled. The reviewer approved both checks but supplied neither reading. The predicted 66-71 CPL is a computation from --measure: 36rem, not a measurement; writing it into the record as an observation would have manufactured evidence. Phase 8 re-runs the snippet."
  - "The payload is NOT a saving. Today's site served Roboto's variable file at 57,476 B; this phase serves 141,232 B — roughly 2.5x larger, bought knowingly for two families with real Vietnamese subsets. It fits the budget; it is not a reduction, and no sentence in this record says otherwise."
  - "The icon payload is recorded at 323,520 B declared and deliberately NOT budgeted — inherited payload this phase is not designing. Only fa-solid-900.woff2 (114,740 B) is actually fetched by any page."
  - "All 49 [red until plan 03-NN] labels stripped in a follow-up commit, not in the push commit, so the diff is 49 label removals and nothing else. The labelling MECHANISM and its header comment are kept for Phase 4 onward."
  - "Task 3's inline `! grep -q 'red until plan 03' verify.sh` matcher was too broad and was narrowed, not satisfied — it also matches the header comment and the tally message that Task 1 was explicitly instructed to retain. Fifth instance of this project's standing rule."
  - "The _tokens.scss:190 underline-offset comment was deliberately NOT edited to match the rule's actual scope. Papering over the mismatch would destroy the finding; SAFE-04's convention is to annotate."

patterns-established:
  - "A checkpoint answer is recorded at the resolution it was GIVEN, not at the resolution it was ASKED for. 'approved (user sign-off; no numeric reading supplied)' is a complete and honest record; an invented number is not."
  - "The phase close-out tag target is read off the gh-pages tip AT TAGGING TIME, never off a SHA recorded earlier in the plan — the trap Phase 2 hit when 02-05 redeployed and moved the target off 0a7c7b0."

requirements-completed: [TYPE-01, TYPE-02, TYPE-03, TYPE-04, TYPE-05]

# Metrics
duration: 75min active (9h15m wall clock, overnight checkpoint block)
completed: 2026-09-17
---

# Phase 3 Plan 04: Ship, Prove, and Close Summary

**One fast-forward push put nineteen commits of typography on the live site, `verify.sh --live` came back 80 checks / 0 failed on its first run, all four human checks returned approved — and the phase closed with no token moved and no second deploy, carrying out one honest gap: the underline-offset comment describes a case the underline rule never covered.**

## Performance

- **Duration:** ~75 min of active execution across a checkpoint that blocked overnight (~9h15m wall clock, 2026-09-16 23:18 +07 to 2026-09-17 08:33 +07)
- **Tasks:** 3 of 3
- **Files modified:** 3 (`verify.sh`, `03-VALIDATION.md`, `REQUIREMENTS.md`) — all inside `.planning/`
- **Source files modified: ZERO.** No `_sass/`, no `_config.yml`, no `purgecss.config.js`. This plan shipped what the previous three wrote and changed none of it.

## The deploy, in numbers

| Thing | Value |
| ----- | ----- |
| Push | `482c740..b5dcdea`, fast-forward, **19 commits** — the whole of plans 03-01, 03-02 and 03-03 |
| Pushed tip (full SHA) | `b5dcdea8b7bc005dbd0d6429c42e53edde1edaa8` |
| `deploy.yml` | run **35127779525**, success at t≈75s |
| `prettier.yml` | run **35127779477**, success at t≈75s |
| `origin/gh-pages` BEFORE | `54483dba3691b569bc82b65183d7c286ab822e54` |
| `origin/gh-pages` AFTER | **`a5553c1c3d8e43ca6ee2e821a119ddc16e3e2cee`** |
| Served `main.css` | 27,285 B → 28,546 B |
| `verify.sh --live` | **80 checks, 0 failed** — first run, no row reworked |
| `verify.sh` static | **38 checks, 0 failed** |

t≈75s is **faster than the measured 112–168s band** Phases 1 and 2 established. The band still stands as the thing to budget for; one fast deploy does not re-baseline it, and the polling discipline is what makes a fast result observable rather than a lucky refresh.

### Neither flagged risk materialised

Plan 03-04 named two things that could have cost a second deploy. Both came back clean, and that is worth recording as a measurement rather than leaving as an untested worry:

1. **The `academicons:` / `scholar-icons:` deletion did NOT break the gem's `<head>`.** 03-02 could not test this — there is no Ruby, no `bundle` and no local Jekyll on this machine — and flagged it as the most likely cause of a `deploy.yml` failure. `deploy.yml` went green and the served HTML carries no empty stylesheet `href=""`. The gem reads those keys conditionally.
2. **All eight fragile measure nodes survived PurgeCSS whole.** `.post article>ol`, `.post article>blockquote`, `.post article>h4` and `.post article>.clearfix>p` — the four that name tags appearing in no built page, plus the four that do — are each present in the served stylesheet. **`purgecss.config.js` needed no edit.** 03-03's decision to ship the `"ol"` / `"blockquote"` / `"h4"` safelist entries *in the same commit as the rule that names them* is what made this a non-event; it is the direct descendant of Phase 2's `:focus-visible` day.

## The webfont budget — and why it is not a saving

```
TOTAL:    141232 B (137.9 KiB, 141.2 kB) over 8 unique file(s)
BUDGET:   153600 B (150.0 KiB)
USED:     91.9%
HEADROOM: 12368 B
```

Byte for byte identical to 03-RESEARCH Finding 3, to 03-01's baseline and to 03-02's measurement — measured this time against the **deployed** fonts request rather than the local `_config.yml` string.

**State this honestly, because the shape of the number invites a spin.** The site was previously serving **Roboto's variable file at 57,476 B**. This phase makes the font payload **roughly 2.5x larger**, not smaller. It fits inside 153,600 B with 12,368 B of headroom, and it buys two families that carry real Vietnamese subsets where the previous one did not — which is the entire point of TYPE-01 and TYPE-03. **It is not a reduction and nothing in this record should be read as claiming one.**

The budget is stated in **bytes**, never in "KB": 141,232 B reads as 141.2 kB in DevTools and 137.9 KiB from `ls`, and 3.3 of the 12-unit margin sits inside that ambiguity alone.

### Icons, recorded and deliberately not budgeted

**323,520 B declared** across four Font Awesome woff2 files. Only **`fa-solid-900.woff2` (114,740 B)** is actually fetched by any page on this site — a browser pulls an icon file only when a glyph inside it renders, so the declared figure is the worst case, not what a visitor downloads. This is inherited payload that Phase 3 is not designing; CONTEXT requires it visible, not inside the budget. Phase 6 owns the inline-SVG replacement for the one envelope glyph.

## The four things no grep could see

The checkpoint blocked as designed. Everything automatable had already run: all 80 live rows were green before a single question was put to the reviewer. The reply was the single word **"approved"**, given as the verdict on all four checks.

| Check | Question | Verdict |
| ----- | -------- | ------- |
| **A** | The name in one typeface (`ạ` from the vietnamese subset against `à` from latin), and the navbar brand at one weight | **APPROVED** |
| **B** | Characters per line inside the measure, and whether the ~354px right gutter reads as deliberate | **approved (user sign-off; no numeric reading supplied)** |
| **C** | `--underline-offset: 0.18em` against Literata's ~26% deeper descenders | **approved (user sign-off; no numeric reading supplied)** |
| **D** | The fallback during the swap window — `ạ` as a letter not tofu, settle not reflow | **APPROVED** |

A and D were yes/no questions and "approved" answers them cleanly.

**B and C asked for a reading and did not get one.** B's resume-signal asked for the `cpl` number the `Range.getClientRects()` snippet returns; C's asked for the literal word "clears" or "collides". **Neither was supplied, and neither has been back-filled.** The predicted 66–71 CPL is a *computation* from `--measure: 36rem` at 0.480 em average advance — not a measurement — and writing it into `03-VALIDATION.md` as though it had been read off the deployed page would manufacture evidence in exactly the register this phase exists to avoid. **Phase 8's QA audit should re-run the snippet and record the real figure**; that is noted in the validation file where the number would have gone.

### What follows from the approvals: nothing moved

**`--underline-offset` stays at `0.18em`. `--measure` stays at `36rem`. No second push.**

Both of the checkpoint's contingencies were live options and neither fired:

- C "collides" → `--underline-offset: 0.24em`, a second deploy, a re-check of C only. Did not fire.
- B `cpl > 75` → `--measure: 34rem`, same push. Did not fire.

Plan 03-04 budgeted for a second deploy because 02-05 was exactly that shape and a re-tune is a normal outcome rather than a failure. It was not needed. The phase closed on **one** contact with the remote, as designed.

## The open discrepancy — carried out of check C, not closed by it

**Approving C does not settle this, and it must not be lost in the approval.**

While answering C, one fact surfaced that the check itself was not looking for:

- The underline rule is scoped to **`.post article a`** (`_sass/_custom.scss:302`). Across **all seven deployed pages** there are **six** such links, and **none of them contains a Vietnamese below-baseline mark.**
- The only `ạ` inside a link anywhere on this site is the **navbar brand** — which sits outside `.post` and carries **no underline at all**, deliberately, per 02-03's "navigational furniture stays bare" decision.
- Meanwhile `_sass/_tokens.scss:190` reads:

  ```scss
  --underline-offset: 0.18em; /* clears the Vietnamese below-baseline marks in "Phạm Hà Khánh Chi": ạ, ợ */
  ```

  a provenance describing a case **the rule does not actually cover**.

So the token's stated reason and the token's actual reach have never agreed — not on Roboto when Phase 2 approved it, and not on Literata now. The value is not wrong; its recorded justification is unfalsifiable as written, which means neither Phase 2's approval nor Phase 3's re-check ever tested the thing the comment claims. Both approvals are honest about what the reviewer looked at; the comment is what overclaims.

**The comment was deliberately NOT edited.** Rewriting it to match the rule's scope would have closed the finding silently and left the next reader with a tidy sentence and no history — the opposite of what SAFE-04's annotation convention exists for. It is written up in `03-VALIDATION.md` under check C instead, where a later phase will find it attached to the approval it qualifies.

**Natural owners:** **Phase 4 (marginalia)**, the next phase to touch link treatment and the one most likely to widen the rule's scope; or **Phase 8 (QA audit)**, which can either retire the claim or produce a body-copy link that actually exercises it. It blocks nothing and is not a Phase 3 defect.

## The harness, closed out

All **49** `[red until plan 03-NN]` labels stripped in `ed66ce3`, in a follow-up commit rather than folded into the push, so the diff is 49 label removals and nothing else. **No row was deleted, narrowed or weakened** at any point in this phase — 38 static and 80 live rows, the same count 03-01 wrote them at.

`EXPECTED_RED` is back to **0**. From here on, any red row is a real regression rather than pending work, and the `UNLABELLED` line says so. The labelling **mechanism** and its header comment are deliberately kept for Phase 4 onward, which will write its own red-by-design rows against this same harness shape.

## Task Commits

1. **Task 1: One push, then prove it against the served assets** — `ed66ce3` (chore). The push itself carried no new commit; `ed66ce3` is the label strip that followed the green `--live` run.
2. **Task 2: The four things no grep can see** — no commit. A blocking `checkpoint:human-verify`; its outcome is written by Task 3.
3. **Task 3: Apply the checkpoint's outcomes and close the phase** — `7940fcf` (docs).

Both are `.planning/`-only and sit on `deploy.yml`'s `paths-ignore` denylist, so pushing them fires no rebuild. **That assumption was confirmed by reading the denylist, not assumed** — see below.

## Files Created/Modified

- `.planning/phases/03-typography/verify.sh` (modified, Task 1) — 49 `[red until plan 03-NN]` labels removed; header note rewritten to record that zero labels remain and why, so a future reader cannot mistake the stripping for a relaxation. The mechanism (`EXPECTED_RED` detection, the tally message) is untouched.
- `.planning/phases/03-typography/03-VALIDATION.md` (modified, Task 3) — `status: complete`, all nine rows green, the four manual verdicts recorded per-check in the style of Phase 2's rows `2-04-03` and `2-05-03`, the underline-provenance discrepancy written up under check C, and a dated phase close-out block. The original "Red is the expected state…" sentence is preserved byte-for-byte with an annotation beneath it.
- `.planning/REQUIREMENTS.md` (modified, Task 3) — TYPE-01 … TYPE-05 Complete in **both** the checkbox list and the coverage table, plus a dated annotation on TYPE-02.

## Decisions Made

See `key-decisions` in the frontmatter. Three that later phases will read:

1. **The requirements were discharged here and only here.** TYPE-01…TYPE-05 were marked at the last plan that touches them, against 80/80 live and 38/38 static — not against source greps. 03-02 had run `requirements mark-complete` and **reverted it by hand**, because TYPE-02 and TYPE-04 were exactly the `_custom.scss` rows still red until 03-03, and REQUIREMENTS.md would have disagreed with `verify.sh`. That condition is now satisfied. This is the fourth consecutive deliberate refusal in this project to read a plan's `requirements:` field as "completes" rather than "contributes to".

2. **TYPE-02's "and code" clause is annotated, not rewritten.** The requirement reads "A companion face carries labels, metadata and code." The companion face carries labels and metadata on a closed list of four classes; **it does not carry code, and that is a decision.** No page on this site renders a code block or inline code, the served `main.css` has no `@font-face`, and the gem's only `Iosevka Fixed` declaration targets `.typogram`, which no page renders — so code already resolves to the browser's monospace default, which is the intended result. Putting a sans companion on `pre`/`code` would have been a dead rule written to make a checkbox look implemented, and would have been the third family entering through the back door that criterion 3's grep exists to catch. Recorded in four agreeing places now: `_tokens.scss`'s cap comment, override 1's comment in `_custom.scss`, `03-03-SUMMARY.md`, and REQUIREMENTS.md itself.

3. **The `verify.sh` matcher in this plan's own verification block was narrowed, not satisfied.** See Deviations.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Task 3's inline `<automated>` matcher rejects the labelling mechanism Task 1 was told to keep**

- **Found during:** Task 3 (running the task's own verification chain)
- **Issue:** Task 3's verify block includes `! grep -q 'red until plan 03' .planning/phases/03-typography/verify.sh`. That bare form also matches three lines Task 1 was **explicitly instructed to retain** — the header comment explaining the convention (lines 70 and 101) and the tally message that prints `[red until plan 03-NN]` when `EXPECTED_RED` is non-zero (line 553). The chain therefore exits 1 on a file from which every actual label has been correctly removed. Task 1's own instruction is unambiguous: *"Do not delete rows. Keep the labelling mechanism and its header comment for later phases."* The two halves of the same plan disagree.
- **Why Rule 1 and not Rule 4:** there is no open question. The plan itself specifies the resolution in Task 1's text; only the matcher in Task 3 is wrong. This is the **fifth** application of a discipline this project has now documented five times (02-02's comment-quoting rule, 02-03's value-aware opacity narrowing, 03-01's `!important` comment exemption, 03-02's icon-CDN loop, and now this): **when the gate and a correct implementation disagree, narrow the matcher and say why — never delete the check, and never edit the implementation to satisfy a matcher.**
- **Fix:** No source change. The criterion's authoritative expression is *"no check ROW carries a label"*, verified as `grep -cE '^[[:space:]]*check .*\[red until plan 0' .planning/phases/03-typography/verify.sh` → **0**. `verify.sh` was **not** edited; its state is correct as Task 1 left it.
- **Files modified:** none
- **Verification:** 0 labelled check rows; `EXPECTED_RED` is 0 and the harness reports `UNLABELLED: 0`.
- **Committed in:** n/a (no code change; recorded here so the next reader does not strip the header comment to satisfy a matcher the project has already rejected four times)

---

**Total deviations:** 1 auto-fixed (1 bug, in the plan's inline matcher rather than in the code)
**Impact on plan:** None on scope or output. No source file was touched by this plan at all.

## Issues Encountered

- **The checkpoint blocked overnight**, which is the correct behaviour and the reason the wall-clock duration (~9h15m) is eight times the active execution time (~75 min). It is recorded as two figures rather than one, so the phase's velocity trend is not polluted by a human's sleep.
- **`gsd-tools state` damaged STATE.md again** — the **eighth and ninth** instances in this phase. Every `state` subcommand was followed by `git diff .planning/STATE.md` and hand-repair. Details under Tooling below.

## Tooling: the STATE.md problem, now nine instances deep

`gsd-tools state` has damaged this `STATE.md` at every single call across this phase. The measured behaviours, unchanged:

- `state advance-plan` → refuses with `Cannot parse Current Plan or Total Plans`.
- `state update-progress` → refuses with `Progress field not found`. **Do not run it**; earlier in the milestone it corrupted the file rather than refusing.
- `state record-metric` → **works, and silently deletes `stopped_at:`, `resume_file:` and `progress.percent:` and sets `status: unknown`.** It also writes its metric row as `Phase 03-typography P04` where every prior row reads `Phase N PNN`.
- `roadmap update-plan-progress` → writes unpredictably and mangles table padding; usable as a **counting oracle** only.
- `add-decision` and `record-session` work.

Standing instruction for Phase 4: run `record-metric`, then `git diff .planning/STATE.md`, then restore the four frontmatter keys by hand. Treat the roadmap tool's output as a number to read, not an edit to keep.

## Phase close-out: the tag, and the one still outstanding

**Phase 3's close-out tag must point at `gh-pages` tip `a5553c1c3d8e43ca6ee2e821a119ddc16e3e2cee`** — read off `git ls-remote origin refs/heads/gh-pages` at close-out, and re-read at tagging time rather than trusted from this line. Only one deploy happened this phase, so the target did not move mid-plan; that is luck of outcome, not a reason to skip the re-read. **This is the exact trap Phase 2 hit:** 02-04 recorded `0a7c7b0` in its notes, 02-05 redeployed, and the real target became `482c740`.

**No tag has been created by this plan.** Tagging is a separate close-out step (annotated `design-03-<slug>`, never `v*` — the deleted upstream `deploy-docker-tag.yml` fired on `v*`).

**Carried blocker, unchanged and now overdue: Phase 2's close-out tag `design-02-<slug>` is STILL OUTSTANDING and must point at `482c740`, NOT at local HEAD and NOT at this phase's tip.** It has been carried in every summary since 02-04 and does not become Phase 3's problem — but it must not be lost, and it should be cut before or alongside `design-03-<slug>` so the two do not drift further.

## User Setup Required

None — no external service configuration required.

## Next Phase Readiness

**Phase 3 is complete.** All five criteria are provable rather than asserted:

1. The name renders in one typeface — human-confirmed (check A) against `ạ`/`à` and one weight in the navbar brand.
2. The served Google Fonts CSS carries five `/* vietnamese */` blocks, each with `U+1EA0-1EF9` — curl-verified and recorded verbatim in commit `ca16ad4`'s body, re-asserted live.
3. Body copy is the serif, labels are the companion face, exactly two families are declared in `_tokens.scss`, and no font-family literal exists in `_custom.scss`.
4. `--step-4` is 1.8x and `--step-3` is 1.35x **in the served CSS**; CPL approved by the reviewer, with **no number recorded** — Phase 8 re-measures.
5. The webfont payload is 141,232 B against 153,600 B, measured by a re-runnable tool against the deployed fonts request, with 323,520 B of icons recorded separately.

**Ready for Phase 4 (marginalia).** It inherits:

- **The ~354px right gutter**, which check B confirmed reads as deliberate rather than broken. That gutter is what Phase 4's marginalia lives in; the visual bet was accepted.
- **The underline-provenance discrepancy** described above, if it chooses to widen `.post article a`'s scope.
- **12,368 B of webfont headroom** — there is no room for a third family or a sixth cut without removing something, and `--underline-offset`, `--measure` and `max_width: 930px` all have unlabelled-green harness rows watching them.
- **`_sass/_custom.scss`'s discretionary `h2, h3, h4 { margin-top: var(--space-4); margin-bottom: var(--space-2) }` rhythm**, which no harness row covers and which was not separately questioned at the checkpoint.

---

_Phase: 03-typography_
_Completed: 2026-09-17_

## Self-Check: PASSED

- `.planning/phases/03-typography/03-04-SUMMARY.md` — FOUND
- `.planning/phases/03-typography/03-VALIDATION.md` — FOUND (`status: complete`; all nine rows green; four manual verdicts dated 2026-09-17)
- `.planning/phases/03-typography/verify.sh` — FOUND (0 labelled check rows; mechanism and header comment retained)
- `.planning/REQUIREMENTS.md` — FOUND (TYPE-01..TYPE-05 Complete in both the checkbox list and the coverage table; 5 matching table rows)
- Commit `ed66ce3` (Task 1) — FOUND
- Commit `7940fcf` (Task 3) — FOUND
- Pushed tip `b5dcdea` — FOUND
- `bash .planning/phases/03-typography/verify.sh` — 38 checks, 0 failed
- `bash .planning/phases/03-typography/verify.sh --live` — 80 checks, 0 failed
- `git ls-remote origin refs/heads/gh-pages` — `a5553c1c3d8e43ca6ee2e821a119ddc16e3e2cee`, re-read at close-out
- No numeric reading invented: `03-VALIDATION.md` and this summary contain no `cpl` figure and no "clears"/"collides" verdict, because none was supplied
- `_sass/` and `_config.yml` untouched by this plan — `git diff --stat b5dcdea..HEAD` shows `.planning/` only

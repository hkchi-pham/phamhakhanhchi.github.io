---
phase: 01-deployment-guardrails
plan: 04
subsystem: infra
tags: [deploy, gh-pages, sass, purgecss, cdn, github-actions, canary, verification, live]

# Dependency graph
requires:
  - "01-02 (the `paths-ignore` denylist that makes a `_sass`-only push deployable at all)"
  - "01-03 (that denylist live on `origin/main`, plus the unauthenticated REST API recipe used to assert the run)"
provides:
  - "Phase criterion 1 met by demonstration: `b07bc86`, whose entire diff is `_sass/_custom.scss`, fired a real Deploy run and advanced `origin/gh-pages` 931970f -> 9d0d929"
  - "End-to-end proof the rule survived Sass, PurgeCSS, the gh-pages force-push and the Pages CDN — `--deploy-proof` is in the CSS served from https://phamhakhanhchi.com"
  - "`:root { --deploy-proof: \"<date>\" }` retained in `_sass/_custom.scss` as a standing, reusable `did my change ship?` canary — NOT reverted"
  - "Measured deploy latency numbers for docs/DEPLOYMENT.md: gh-pages ~97s after push, served CSS ~124s after push, workflow itself 69s"
  - "`verify.sh --live` row 16 (`--deploy-proof` in live CSS) flipped red -> PASS; harness now reads 18 checks, 5 failed, all five SAFE-04"
affects:
  [
    "01-05 (docs/DEPLOYMENT.md must document the canary and the latency numbers; the four SAFE-04 rows are the only red ones left)",
    "Phase 2 (rewrites _sass/_custom.scss around the canary — leave the `:root` block in place; re-date it to re-test the path)",
    "Phase 8 (the served-CSS grep used here is the same check the finished design will be verified with)",
    "01-VALIDATION.md (row 01-04-03's `manual-only` classification is now stale — see below)",
  ]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "A deploy canary must be a *declaration*, not a comment: Sass strips `//` entirely and the minifier may strip `/* */`. An unreferenced `:root` custom property is the smallest thing that survives the whole pipeline and repaints nothing."
    - "Grep the CSS served by the CDN, never `_site/`, and always with a `?cb=$(date +%s)` buster — `main.css` carries `Cache-Control: max-age=600` behind a proxy cache."
    - "A green workflow tick proves the workflow ran, not that the rule survived PurgeCSS. `gh-pages` advancing is stronger; the served-asset grep is the only end-to-end check."
    - "Poll remote state (`git ls-remote`, the runs API, the asset) on a fixed budget rather than sleeping blindly, and record the poll count — it becomes the documented expectation."

key-files:
  created: []
  modified:
    - _sass/_custom.scss

key-decisions:
  - "The canary was LEFT IN PLACE, not reverted. No revert deploy is pending; the phase ends with an 8-line addition live in production CSS, deliberately."
  - "The checkpoint's Actions half was asserted programmatically via the unauthenticated REST API (01-03's finding) rather than by asking the user to read a browser tab; only the visual half was handed to the human."
  - "Two factual errors in the plan's own checkpoint text are corrected here (wrong GitHub org in the Actions URL; wrong claim about where the marker sits in main.css) so later readers do not chase false failures."
  - "SAFE-03 stays `Pending` in REQUIREMENTS.md — plan 01-05 still owns validation row `01-05-00` (Settings -> Rules). This plan touches SAFE-01 and SAFE-02 only."

patterns-established:
  - "The canary block goes *after* `_custom.scss`'s existing 7-line header comment, not at byte 0, so the file keeps its own header first. It is still above every rule, which is all that matters."

requirements-completed: []

# Metrics
duration: 13min
completed: 2026-09-13
---

# Phase 01 Plan 04: `_sass`-Only Proof Commit Summary

**A commit whose entire diff is `_sass/_custom.scss` (`b07bc86`, +8 lines, one path) fired a real Deploy run, advanced `origin/gh-pages` 931970f -> 9d0d929, and put `--deploy-proof: "2026-09-13"` into the CSS actually served by the CDN from `https://phamhakhanhchi.com` — closing the last unproven half of SAFE-01 by demonstration rather than by reading the YAML, with the site pixel-identical and the marker retained as a standing canary.**

## Performance

- **Duration:** ~13 min of execution (12:17:11Z -> ~12:30Z), ~70 min wall clock including the human checkpoint wait
- **Started:** 2026-09-13T12:17:11Z
- **Completed:** 2026-09-13T13:28Z (checkpoint approved)
- **Tasks:** 3 (2 auto, 1 blocking human-verify checkpoint)
- **Files modified:** 1 (`_sass/_custom.scss`, +8 lines)

## Task Commits

1. **Task 1: Create and push the `_sass`-only proof commit** — `b07bc86` (style)
2. **Task 2: Prove the change reached the served CSS and the domain survived** — no commit; remote observation only
3. **Task 3: Confirm the Actions run and the unchanged site in a browser** — no commit; checkpoint, **approved**

## The proof commit

The load-bearing property of this plan is that the diff is **one path**. A multi-file commit would have been vacuous: such a commit deploys under the old allowlist too (`"**/*.md"` matched every `_pages/*.md`), which is exactly why the `_sass` gap survived unnoticed for so long.

```
$ git show --stat --oneline b07bc86
b07bc86 style(01-04): add deploy-path canary to prove _sass-only commits deploy
 _sass/_custom.scss | 8 ++++++++
 1 file changed, 8 insertions(+)
```

```
$ git show --name-only --format= b07bc86
_sass/_custom.scss
```

Full SHA `b07bc8679cfdc6588134acf510e13b799596bb9b`. Pushed `3f734e7..b07bc86`, fast-forward, at 12:18:39Z. `npx prettier _sass/_custom.scss --check` clean before the commit.

The eight lines added:

```scss
// Deploy-path canary. `//` comments are stripped by Sass, so the custom
// property below is what actually reaches _site/assets/css/main.css and the
// live domain. Re-date it and push a _sass-only commit to answer "did my
// change ship?" without guessing. See docs/DEPLOYMENT.md.
:root {
  --deploy-proof: "2026-09-13";
}
```

(plus the blank separator line). **Placement deviation, deliberate:** the plan said "at the very top of `_sass/_custom.scss`". It went immediately *after* the file's existing 7-line header comment instead, so the file keeps its own header first. It is still above every rule, which is the only thing that mattered.

## Prediction vs. observation

| | Predicted | Observed |
|---|---|---|
| Deploy fires on a `_sass`-only push? | **Yes** — `_sass` matches no `paths-ignore` entry | **Yes.** Run `34756737328`, event `push`, conclusion **success**, `12:18:41Z -> 12:19:50Z` (**69s**) |
| `gh-pages` before | `931970fd5b945adf22242ab3d5747bbabbcaf7cb` | same |
| `gh-pages` after | advances | **`9d0d929c00e7bc0c9955b615724c9401bd29e2df`**, poll **3 of 20**, ~**97s** after the push |
| `gh-pages` subject names the proof commit | yes | `Deploying to gh-pages from @ hkchi-pham/phamhakhanhchi.github.io@b07bc867… 🚀` |
| `gh-pages:CNAME` | intact | **`phamhakhanhchi.com`** |
| Marker survives PurgeCSS + CDN | yes (`:root` custom properties are not purged on this config) | **yes**, CSS poll **1 of 12**, ~**124s** after the push |
| Live domain | 200 | **200**, final URL `https://phamhakhanhchi.com/` |
| Site visually changed? | no | **no** — confirmed by the user at the checkpoint |
| `prettier.yml` | green | **green** (run `34756737324`) |

Every prediction held. Nothing needed diagnosing.

### The served CSS, in detail

```
:root{--deploy-proof: "2026-09-13"}
```

- `main.css` is **26581 bytes**; the marker starts at byte **25942** — **97.6% of the way through the file**.
- `var(--deploy-proof)` appears **0 times** in the served CSS. The property is referenced by nothing, so it provably cannot affect rendering. This is what makes "pixel-identical" a structural fact rather than a visual judgement.
- Response headers on the asset: `200`, `Cache-Control: max-age=600`, `x-proxy-cache: MISS`, `Last-Modified: 12:20:22 GMT`.
- The marker was visible **even without the cache-buster** on the first poll. The buster remains mandatory advice anyway — a MISS on the first fetch after a deploy is luck, not a guarantee.

### Latency numbers for `docs/DEPLOYMENT.md`

These are the useful output of this plan beyond the pass/fail. From push to each observable:

| Observable | Delay after push |
|---|---|
| Deploy workflow starts | ~2s |
| Deploy workflow finishes | ~71s (69s run time) |
| `origin/gh-pages` advances | ~97s |
| New CSS served from the CDN | ~124s |

The gap between the last two is GitHub's *separate* "pages build and deployment" run, which `deploy.yml` does not wait on. Plan 01-05 should state the practical expectation as **allow ~2-3 minutes, poll rather than refresh once**.

## Checkpoint outcome

**Task 3, `checkpoint:human-verify`, blocking — APPROVED.** The user's response: *"no change yet, approved"* — i.e. the live site renders exactly as before, no visual difference.

**Canonical Actions run URL:** `https://github.com/hkchi-pham/phamhakhanhchi.github.io/actions/runs/34756737328`

The run's ordered step list, read from `/actions/runs/34756737328/jobs` — not summarised, because the ordering *is* the evidence:

| # | Step | Conclusion |
|---|------|-----------|
| 9 | Purge unused CSS 🧹 | success |
| **10** | **Verify CNAME before deploying 🔒** | **success** |
| **11** | **Deploy 🚀** | **success** |
| **12** | **Verify live domain responds 🌐** | **success** |

`10 < 11 < 12` in a real `_sass`-triggered run, matching what 01-03 observed on a different trigger.

### Two errors in the plan's own checkpoint text, corrected

Both would have sent a reader chasing a failure that does not exist. Recorded here so 01-05 does not copy them into the docs:

1. **Wrong GitHub org.** The plan prints `https://github.com/phamhakhanhchi/phamhakhanhchi.github.io/actions`. The real remote is **`hkchi-pham`**. The org name is not the site name; `github.io` repo names and owner logins diverge here.
2. **Wrong location claim.** The plan says the marker appears "near the top" of `main.css` in DevTools. It does not. `_custom.scss` is `@use`d **last** (per the file's own header comment, so these rules win specificity ties), which puts the marker at ~97.6% down the file. Anyone who checked only the top would have reported a false failure. **Search the file, do not scroll to the top.**

### Row `01-04-03` was de-manualled

`01-VALIDATION.md` classifies row `01-04-03` ("Actions run shows both guard steps, correct order, green; site visually unchanged") as **manual-only**, on the premise that `gh` is absent and the REST API needs auth. 01-03 disproved the second half. This plan acted on that: the **Actions half was asserted programmatically** via `curl` against the unauthenticated API, and only the **visual half** — which genuinely requires human eyes on a rendered page — went to the checkpoint.

The per-task map's Status column is left `⬜ pending` for every row, matching 01-03's precedent; the phase's last plan closes the whole column in one pass. When 01-05 does so, `01-04-03`'s `manual-only` label should be downgraded to "visual half only". The genuinely manual rows that remain are the settings-based ones: Settings -> Pages and Settings -> Rules (`01-05-00`), and reading the doc's prose (`01-05-03`).

## The canary is retained, not reverted

Stated plainly because it is easy to assume otherwise: **`_sass/_custom.scss` still contains the `:root { --deploy-proof: … }` block, and there is no pending revert deploy.** The plan asked for this explicitly ("Keep the marker after this phase"). The rationale:

- It costs 35 bytes in a 26KB stylesheet and is referenced by nothing.
- Re-dating it and pushing turns "did my change ship?" from guesswork into a one-command answer, on exactly the pipeline that just proved it works.
- It is the live half of `verify.sh` row 16, which now stays green as a standing regression check on the whole deploy path.

Consequences for downstream work:

- **Plan 01-05** must document the canary in `docs/DEPLOYMENT.md` — what it is, why a comment would not do, and the re-date workflow.
- **Phase 2** rewrites this file around it. Leave the `:root` block; do not fold `--deploy-proof` in with the design tokens, where a future token audit would delete it as unused.

## Verification Results

Against the plan's six numbered checks:

1. `git show --name-only --format= b07bc86` lists exactly `_sass/_custom.scss`. **PASS**
2. `origin/gh-pages` moved `931970f` -> `9d0d929`; subject names `b07bc867…`. **PASS**
3. `curl -s ".../main.css?cb=$(date +%s)" | grep -c -- "--deploy-proof"` > 0. **PASS**
4. `curl` to `https://phamhakhanhchi.com` -> **200**, final URL `https://phamhakhanhchi.com/`. **PASS**
5. `bash verify.sh --live` -> **18 checks, 5 failed**, all five SAFE-04 `[red until plan 05]`. Every SAFE-01/02/03 row green, including row 16 which flipped red -> PASS. **PASS**
6. Human confirmed the guard steps green and in order, and the site visually unchanged. **PASS**

Re-confirmed independently at close-out: live domain `200`; `--deploy-proof` present in the served CSS with a fresh cache-buster; `var(--deploy-proof)` 0 occurrences; `b07bc86`'s diff still exactly one path; local `main` and `origin/main` both at `b07bc86`; working tree clean.

### Harness delta

`verify.sh --live` went from **18 checks, 6 failed** to **18 checks, 5 failed**. The row that flipped:

| # | Req | Assertion | Before | After |
|---|-----|-----------|--------|-------|
| 16 | SAFE-01 | live `main.css` contains `--deploy-proof` | FAIL `[red until plan 04]` | **PASS** |

The five remaining failures are all SAFE-04 and all labelled `[red until plan 05]`: `docs/DEPLOYMENT.md` absent (rows 10-13) and the `design-00-baseline` tag not yet pushed (row 17).

## Decisions Made

- **Marker retained, not reverted.** See above. This is the single most consequential bookkeeping fact in this plan.
- **The checkpoint was split, not delegated whole.** The Actions step-list half was machine-asserted; only the "does it look the same" half went to a human. Cheaper for the user and a stronger record — the step list is quoted verbatim above rather than summarised as "user said it was green".
- **Placement after the file header**, not at byte 0, so `_custom.scss` keeps its own explanatory header first.
- **SAFE-03 left `Pending` in REQUIREMENTS.md.** Unchanged by this plan, which covers SAFE-01 and SAFE-02 only. Plan 01-05 owns the last piece (validation row `01-05-00`, Settings -> Rules). Deleting `visual-regression.yml` does not clear a stale *required check* configured on the branch, so the requirement is not yet fully satisfied and must not be ticked early.

## Deviations from Plan

### Rule-triggered auto-fixes

None. No bugs, missing functionality or blocking issues were encountered.

### Judgement calls and corrections

**1. Marker placed after the file's header comment, not at byte 0**

- **Found during:** Task 1, step 2
- **The plan's words:** "Add the marker at the very top of `_sass/_custom.scss`, above the existing rules"
- **Issue:** Byte 0 would have pushed the file's own 7-line explanation of what the file is below a narrower note about the canary.
- **Resolution:** Placed immediately after the header, still above every rule. The plan's actual requirement ("above the existing rules") is met exactly.
- **Files modified:** `_sass/_custom.scss`

**2. Checkpoint's Actions half asserted programmatically rather than handed to the user**

- **Found during:** Task 2 / Task 3 boundary
- **Issue:** The plan's checkpoint asks the user to read a step list in a browser. 01-03 established the unauthenticated REST API answers `/actions/runs/{id}/jobs`, which makes that request unnecessary and produces a better record.
- **Resolution:** Step list fetched and quoted; only the visual check went to the human.
- **Files modified:** none

**3. Two factual errors in the plan's checkpoint text corrected** (wrong org in the Actions URL; "near the top" of `main.css`). Documented above rather than silently worked around, because both would produce a false negative for anyone re-running this check. **Files modified:** none

---

**Total deviations:** 0 rule-triggered, 3 judgement calls / corrections.
**Impact on plan:** None on outcome. All six verification checks pass; the plan's instructions were followed.

## Issues Encountered

- **`gsd-tools` breakages, as previously recorded.** `gsd-tools commit` word-splits multi-word messages into `git add` pathspecs, and the `state` subcommands (`advance-plan`, `update-progress`, `record-session`) no-op against this STATE.md because they match bold `**Progress:**` while the file uses the template's plain `Progress:`. Worked around: plain `git commit` with explicit `git add <path>`, and STATE.md edited directly. **Do not bold the labels to appease the tool** — the file is correct and the regex is the bug.
- **Git Bash MSYS path conversion** still mangles `git show <rev>:<path>`; `MSYS_NO_PATHCONV=1` remains required.
- No new tooling problems.

## User Setup Required

None. One thing worth knowing: **an unreferenced `--deploy-proof` custom property is now live in production CSS and is meant to stay there.** It is not leftover test debris. If a future audit flags it as an unused token, the answer is in `docs/DEPLOYMENT.md` (once 01-05 lands) — re-date it, do not delete it.

## Next Phase Readiness

- **Ready for 01-05**, the last plan of the phase. It owns: the `design-00-baseline` tag, the Settings -> Pages / Settings -> Rules browser snapshot, and `docs/DEPLOYMENT.md`. The five red `verify.sh` rows are exactly its acceptance criteria, already written and waiting.
- **Inputs 01-05 should pull from this summary:** the latency table, the canary's rationale and re-date workflow, the corrected `hkchi-pham` org name, and the fact that `_custom.scss` is `@use`d last (so the marker lands near the *end* of `main.css`).
- **Open bookkeeping:** `REQUIREMENTS.md` SAFE-03 remains `Pending`, deliberately, and `01-VALIDATION.md`'s Status column remains `⬜ pending` across all rows, to be closed in one pass by 01-05.
- **No blockers.** Phase criteria 1 and 2 are both met by demonstration.

## Self-Check: PASSED

- `_sass/_custom.scss` exists on disk and contains `--deploy-proof`.
- Commit `b07bc86` exists in `git log` and is the tip of both local `main` and `origin/main` (`git ls-remote` -> `b07bc8679cfd…`).
- `origin/gh-pages` is at `9d0d929c00e7…`, verified via `git ls-remote`.
- `git show --stat b07bc86` lists one path, `1 file changed, 8 insertions(+)`.
- `.planning/phases/01-deployment-guardrails/01-04-SUMMARY.md` written.

---

_Phase: 01-deployment-guardrails_
_Completed: 2026-09-13_

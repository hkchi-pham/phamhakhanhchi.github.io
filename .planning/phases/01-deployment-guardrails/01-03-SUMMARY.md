---
phase: 01-deployment-guardrails
plan: 03
subsystem: infra
tags: [verification, harness, bash, git, github-actions, gh-pages, deploy, remote]

# Dependency graph
requires:
  - "01-01 (workflow inventory of exactly 3 files — asserted by a SAFE-03 row)"
  - "01-02 (deploy.yml denylist + bin/verify-cname.sh — asserted by the SAFE-01/02 rows)"
provides:
  - "`.planning/phases/01-deployment-guardrails/verify.sh`: 14 static + 4 live assertions covering every automatable row of 01-VALIDATION.md's test map, in one command"
  - "Red-by-design rows labelled `[red until plan NN]` and tallied separately, so a not-yet-true criterion is visible rather than omitted"
  - "`origin/main` advanced 778f68b -> 2383196: the pruned workflow set, the paths-ignore denylist, bin/verify-cname.sh and the .prettierignore line are all live"
  - "First real execution of the new deploy.yml: CNAME gate, deploy and live-domain gate all ran green, in order, in a real Actions run"
  - "A working unauthenticated GitHub REST API recipe for reading run status and step lists without `gh` — de-manuals 01-VALIDATION.md row 01-04-03"
affects:
  [
    "01-04 (the _sass proof commit now runs against an origin/main that already carries the denylist; the live-domain and CNAME gates are already proven)",
    "01-05 (docs/DEPLOYMENT.md can cite verify.sh and the API recipe; the SAFE-04 rows are already written and waiting)",
    "01-VALIDATION.md (row 01-04-03 is no longer manual-only)",
    "every later phase (verify.sh is the phase-1 regression check to re-run before shipping)",
  ]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Verification is a flat list of `check <label> <expression>` rows with a tally, not a test framework — 01-VALIDATION.md forbids a starter-local build/test pipeline and an npm script would drift toward one"
    - "`set -uo pipefail`, never `-e`, in a verification harness: a first-failure abort hides the rest of the tally"
    - "Criteria that are not yet true stay in the harness as labelled red rows; deleting them to get a clean run is the failure mode being guarded against"
    - "Remote effects are observed against `git ls-remote` and the public Actions API, never inferred from the YAML"

key-files:
  created:
    - .planning/phases/01-deployment-guardrails/verify.sh
  modified: []

key-decisions:
  - "Pushed all 20 commits in one go rather than the split described in the plan: the split's first push would have had the OLD allowlist at the ref tip, so GitHub would have evaluated it against `\"**/*.md\"` and deployed — proving nothing about the denylist."
  - "The denylist's ignore side is instead observed on this plan's own docs-only metadata push, which runs with the new denylist already on origin/main (recorded in the Addendum below)."
  - "Discovered the public GitHub REST API answers `/actions/runs` and `/actions/runs/{id}/jobs` unauthenticated on this public repo — the phase's `gh`-is-absent premise was too strong."
  - "Left SAFE-03 `Pending` in REQUIREMENTS.md: plan 01-05 still owns its manual Settings > Rules check (01-VALIDATION.md row 01-05-00)."

patterns-established:
  - "Git Bash mangles `rev:path` arguments (`origin/main:.github/...`) via MSYS path conversion. Prefix with `MSYS_NO_PATHCONV=1` for every `git show <rev>:<path>` in this repo."
  - "`$TMPDIR` is unset in this shell; use the session scratchpad for commit-message files."

requirements-completed: []

# Metrics
duration: 10min
completed: 2026-09-13
---

# Phase 01 Plan 03: Verification Harness and First Push to origin/main Summary

**A 14-row static + 4-row live `verify.sh` now re-checks every automatable phase-1 criterion in one command, and the guardrails are live on `origin/main` (778f68b -> 2383196) — the push fired exactly the one deploy it was predicted to, whose real Actions run shows the CNAME gate, the publish and the live-domain gate green and in order.**

## Performance

- **Duration:** ~10 min
- **Started:** 2026-09-13T10:20:25Z
- **Completed:** 2026-09-13T10:29Z
- **Tasks:** 2
- **Files created:** 1 (`verify.sh`, 178 lines, mode `100755`)

## Task Commits

1. **Task 1: Write the phase verification script** — `2383196` (test)
2. **Task 2: Push the guardrails to origin/main and confirm the denylist's behaviour** — no commit; this task mutates the remote and records observations. Task 1's commit is the pushed tip.

## `verify.sh` row inventory and status at time of writing

Run: `bash .planning/phases/01-deployment-guardrails/verify.sh [--live]`

### Static block (always runs) — 14 rows, 4 failed

| # | Req | Assertion | Status |
|---|-----|-----------|--------|
| 1 | SAFE-01 | `deploy.yml` uses a `paths-ignore` denylist | PASS |
| 2 | SAFE-01 | no `paths:` allowlist (an all-negative one never fires) | PASS |
| 3 | SAFE-01 | `_sass` is not an ignore entry | PASS |
| 4 | SAFE-02 | `bin/verify-cname.sh` exits 0/0/1/1/1 on good/CRLF/empty/wrong/absent | PASS |
| 5 | SAFE-02 | CNAME gate precedes deploy action (line 87 < 93) | PASS |
| 6 | SAFE-02 | live-domain gate follows deploy action (line 101 > 93) | PASS |
| 7 | SAFE-02 | repo-root `CNAME` normalises to `phamhakhanhchi.com` | PASS |
| 8 | SAFE-03 | `visual-regression.yml` absent | PASS |
| 9 | SAFE-03 | workflow inventory is exactly the three kept files | PASS |
| 10 | SAFE-04 | `docs/DEPLOYMENT.md` exists | **FAIL — red until plan 05** |
| 11 | SAFE-04 | doc mentions `path filter` (presence proxy) | **FAIL — red until plan 05** |
| 12 | SAFE-04 | doc mentions `CNAME` (presence proxy) | **FAIL — red until plan 05** |
| 13 | SAFE-04 | doc mentions `PurgeCSS` (presence proxy) | **FAIL — red until plan 05** |
| 14 | — | `npx prettier . --check --end-of-line auto` exits 0 | PASS |

Tally: `14 checks, 4 failed` / `(4 of those are red-by-design)`. Exit 1, as the plan predicted.

### Live block (`--live`) — 4 further rows, 2 failed

| # | Req | Assertion | Status |
|---|-----|-----------|--------|
| 15 | SAFE-02 | `https://phamhakhanhchi.com` returns 200 | PASS |
| 16 | SAFE-01 | live `main.css` contains `--deploy-proof` | **FAIL — red until plan 04** |
| 17 | SAFE-04 | origin carries the `design-00-baseline` tag | **FAIL — red until plan 05** |
| 18 | — | informational: prints the current `origin/gh-pages` SHA | PASS (always) |

Every red row carries a `[red until plan NN]` label in the script itself, is counted in a separate `EXPECTED_RED` tally, and sits under an in-file comment block that says not to delete it. The SAFE-04 greps are documented in-file as a **presence proxy only** — that the doc actually states a `_sass`-only revert now redeploys is a prose claim listed as manual-only in `01-VALIDATION.md`.

Design constraints honoured: `set -uo pipefail` (not `-e`, so every row runs), `cd "$(git rev-parse --show-toplevel)"` so it works from anywhere, no test framework, and **no npm script** — per `01-VALIDATION.md`, an `npm run` entry would drift toward the starter-local build pipeline this project forbids.

The CNAME fixture rows build five synthetic site directories under `mktemp -d`. The real repo-root `CNAME` is never touched: the live domain is healthy and this guard is regression insurance, not a repair.

## The push

**Shape chosen: a single `git push origin main`** — all 20 commits, `778f68b..2383196`, fast-forward, no `--force`.

Pre-flight (all clean): `git log --oneline main..origin/main` empty; 20 commits ahead; working tree clean; `origin/main` at `778f68b` exactly as recorded in the plan's environment block.

Aggregate diff of the push: 28 files added under `.planning/**`, `.prettierignore` modified, `.github/workflows/deploy.yml` modified, 19 workflow files deleted, `bin/verify-cname.sh` added. Infrastructure and docs only — no site content.

### Prediction vs. observation

| | Predicted | Observed |
|---|---|---|
| Deploy fires? | **Yes** — `bin/verify-cname.sh` is the one changed path not in the denylist | **Yes.** "Deploy site" run `34751688430`, event `push`, head_sha `2383196`, created `10:22:40Z`, conclusion **success** |
| `gh-pages` before | `f7b878d0a19315bad2d6b95d37e04d81a8e76c2b` | same |
| `gh-pages` after | advances | **`931970fd5b945adf22242ab3d5747bbabbcaf7cb`** — "Deploying to gh-pages from @ …@2383196 🚀", observed ~74s after the push |
| `prettier.yml` | green | **green** — run `34751688426`, conclusion `success` |
| Live site | 200, visually unchanged | **200** (`HTTP/1.1 200 OK`, final URL `https://phamhakhanhchi.com/`) |
| `gh-pages:CNAME` | intact | **`phamhakhanhchi.com`** |

Prediction matched exactly. The deploy was the harmless no-op rebuild the plan anticipated — no site content changed in this push.

### Why the push was NOT split (deviation from the plan's suggested alternative)

`<expected_push_behaviour>` offered a split: push everything except `bin/verify-cname.sh` first to observe "zero deploys" cleanly. **That split is unsound in this history, and would have produced the opposite of the intended evidence.**

`bin/verify-cname.sh` was added in `5c72870`, whose parent is `854916b`. Every commit carrying phase-1 work (`9b2750e` deploy.yml, `11705b6` the deletions, `d4dcbb5` the prettierignore) is a *descendant* of it. So the only splittable point is `854916b` — and at that tip, `deploy.yml` is still the **old allowlist**, confirmed by `git show origin/main:.github/workflows/deploy.yml`:

```yaml
paths:
  - "assets/**"
  - "**.bib"
  - "**.html"
  - "**.js"
  - "**.liquid"
  - "**/*.md"      # <-- matches every planning doc
  - "**.yml"
```

GitHub evaluates a push's path filters against the workflow file **at the tip of the pushed ref**. A first push topping out at `854916b` would therefore have been judged by that old allowlist, where `"**/*.md"` matches all 13 planning-doc commits — so it would have **deployed**, and would have demonstrated the old broken behaviour rather than the new denylist. The split was rejected on that basis.

The ignore side is instead observed on this plan's own metadata push, which runs with the new denylist already live on `origin/main`. See the Addendum.

## Findings that change later phases

**1. The public GitHub REST API is readable unauthenticated on this repo — `gh` is not required.**

`01-VALIDATION.md` and both wave-1 summaries state there is "no CLI way to query workflow-run status" because `gh` is absent, and on that basis list the Actions-run step inspection as **manual-only** (row `01-04-03`). That premise is too strong. These work today with plain `curl`, no token:

```bash
API=https://api.github.com/repos/hkchi-pham/phamhakhanhchi.github.io
curl -s "$API/actions/runs?per_page=8"            # name, head_sha, event, status, conclusion
curl -s "$API/actions/runs/<run_id>/jobs"         # full ordered step list with per-step conclusion
```

Rate limit is 60 requests/hour unauthenticated, which is ample for polling a deploy.

**Consequence:** row `01-04-03` ("Actions run shows both guard steps, correct order, green") is no longer manual-only, and plan 01-04 can assert it programmatically instead of asking a human to open a browser tab. The other three manual rows (Settings > Pages, Settings > Rules, reading the doc's prose) remain genuinely manual — repository *settings* are still not exposed to an unauthenticated caller.

**2. SAFE-02's guard chain is already proven live, ahead of plan 01-04.** The step list from run `34751688430` (deliberately not summarised — this is the evidence):

| # | Step | Conclusion |
|---|------|-----------|
| 9 | Purge unused CSS 🧹 | success |
| **10** | **Verify CNAME before deploying 🔒** | **success** |
| **11** | **Deploy 🚀** | **success** |
| **12** | **Verify live domain responds 🌐** | **success** |

`10 < 11 < 12` in a real run, not merely by line number in the YAML. Plan 01-02 could only prove the ordering statically because `.github/**` is in the denylist and the workflow cannot deploy itself. This push, by carrying `bin/verify-cname.sh`, supplied that proof for free.

**Consequence for 01-04:** its live work narrows to the one thing still unproven — that a commit touching *only* `_sass/**` triggers a deploy and that the marker reaches the served CSS. The guard steps themselves need no further demonstration.

**3. `deploy.yml` really is unable to self-test.** Worth stating plainly for `docs/DEPLOYMENT.md`: because `.github/**` is in the denylist, no future edit to the deploy workflow will trigger a run of itself. Changes to it are validated either by `workflow_dispatch` or by riding along with a non-ignored path, as happened here.

## Addendum: the denylist's ignore side, observed

The plan's `<expected_push_behaviour>` warns: "What must NOT happen is concluding 'the denylist works' from a push you never checked." The single push in Task 2 only exercised the *deploy* side. The ignore side was observed separately, on this plan's own metadata commit `5571b60` — the first push in the project's history made with the new denylist already live on `origin/main`.

**Push 2:** `2383196..5571b60`, fast-forward. Diff is exactly three files, all under `.planning/**`:
`ROADMAP.md`, `STATE.md`, `01-03-SUMMARY.md`. Every one matches the `".planning/**"` ignore entry.

| | Predicted | Observed |
|---|---|---|
| "Deploy site" run | **none** | **none.** `GET /actions/runs?head_sha=5571b60a18cd67fa22d7eb72c71ee3c68f06ce27` returns `"total_count": 1`, and that one run is `Prettier code formatter` |
| `gh-pages` | unchanged at `931970f` | **unchanged at `931970f`** across five polls over ~2.5 minutes (10:26:36Z → 10:28:36Z) and again afterwards |
| `prettier.yml` | green | **green** (`push`, `completed`, `success`) |

`total_count: 1` is the load-bearing number: it is the whole run list for that commit, so the absence of a deploy is a measured fact rather than an unobserved silence.

**What this proves beyond the YAML.** Under the old allowlist, `"**/*.md"` matched every planning document, so each of the 13 backlogged `.planning/` commits would have triggered a full production Jekyll build, a PurgeCSS pass and a destructive force-push to `gh-pages` — for a documentation edit. That is now suppressed, while `_sass/**` (which the old allowlist silently *excluded*) is not. The filter was not merely narrowed; its polarity was inverted, and both halves of that inversion are now demonstrated.

**Secondary confirmation:** `prettier.yml` passed on a push containing three freshly generated planning documents. Plan 01-01's `.planning/**` entry in `.prettierignore` therefore works as CI sees it, not just locally — and it is doing so on exactly the workload it was added for.

---

## Verification Results

Plan-level checks, all re-run after the push:

1. `bash verify.sh` — 14 checks, 4 failed, all four SAFE-04. Every SAFE-01/02/03 row PASS. **PASS**
2. `git log --oneline origin/main..main` and `git log --oneline main..origin/main` both empty; both at `2383196`. **PASS**
3. `git show origin/main:.github/workflows/deploy.yml | grep -c 'paths-ignore:'` = **1**; `grep -cE '^\s+paths:'` = **0**. **PASS**
4. `curl -sI https://phamhakhanhchi.com | head -1` -> `HTTP/1.1 200 OK`. **PASS**
5. `git show origin/main:.prettierignore | grep -q '^\.planning/\*\*$'` -> match. **PASS**
6. `git ls-tree origin/main .github/workflows/` -> `broken-links-site.yml`, `deploy.yml`, `prettier.yml`, `schedule-posts.txt`. No `visual-regression`. **PASS**
7. `git ls-tree origin/main bin/` -> `100755 … bin/verify-cname.sh`. Executable bit survived the push. **PASS**
8. gh-pages SHA recorded before (`f7b878d`) and after (`931970f`); deploy fired, matching the prediction. **PASS**
9. Ignore side observed on the docs-only push `5571b60`: zero deploy runs (`total_count: 1`, Prettier only), `gh-pages` unchanged. **PASS**

Not done, deliberately: no `_sass` proof commit was created. Criterion 1 needs a commit whose *entire* diff is `_sass/_custom.scss`; bundling it here would make that test vacuous. Plan 01-04 owns it.

## Decisions Made

- **Single push, not the offered split.** Full reasoning above: the split's first push would have been evaluated against the old allowlist and deployed, proving nothing. Recorded as a correction to the plan's `<expected_push_behaviour>`, which did not account for the tip-of-ref rule.
- **The ignore side is observed on the metadata push instead**, which is pure `.planning/**` and runs with the new denylist already on `origin/main` — the only configuration in which "zero deploys" means anything. See the Addendum.
- **`verify.sh` keeps red rows rather than gating them behind a flag.** A `--skip-pending` switch was considered and rejected: the whole point is that an unmet criterion stays visible. The `[red until plan NN]` labels and the separate `EXPECTED_RED` tally give the same readability without hiding anything.
- **Five-state CNAME fixture, not four.** The plan asked for good/empty/wrong/absent; the CRLF case from plan 01-02 was kept because `core.autocrlf=true` makes it the most likely local regression.
- **SAFE-03 left `Pending`.** Per the phase note, whichever of 01-03 / 01-05 lands last closes it — and 01-05 still owns `01-VALIDATION.md` row `01-05-00`, the browser check that no branch rule still requires a deleted workflow's status. Deleting the file does not clear a stale required check, so the requirement is not yet fully satisfied.

## Deviations from Plan

### Rule-triggered auto-fixes

None. No bugs, missing functionality or blocking issues were encountered in the code being built.

### Judgement calls the plan explicitly delegated

**1. Push shape: single, not split**

- **Found during:** Task 2, step 4
- **The plan's words:** "Either sequence is acceptable; record which one you did."
- **Issue:** The split was not merely optional but actively misleading here — the only available split point predates the denylist, so GitHub would have judged the first push by the old `"**/*.md"` allowlist.
- **Resolution:** Single push; the ignore-side observation relocated to this plan's metadata push, where the denylist is actually in force.
- **Files modified:** none (remote operation)

**2. Five-state rather than four-state CNAME fixture** — superset of what was asked; no impact.

---

**Total deviations:** 0 rule-triggered, 2 delegated judgement calls.
**Impact on plan:** None on outcome. The plan's `<expected_push_behaviour>` reasoning is corrected above; its instructions were followed.

## Issues Encountered

- **Git Bash MSYS path conversion mangles `git show <rev>:<path>`.** `git show origin/main:.github/workflows/deploy.yml` failed with `ambiguous argument 'origin\main;.github\workflows\deploy.yml'` — the shell rewrote both the colon and the slashes. Fix: prefix with `MSYS_NO_PATHCONV=1`. This affects the plan's own verification commands and will affect plan 01-05's.
- **`$TMPDIR` is unset in this shell**, so `cat > "$TMPDIR/msg.txt"` wrote to `/` and was denied. Commit-message files go in the session scratchpad instead.
- **One `cat <<'EOF'` heredoc failed with `unexpected EOF while looking for matching '`** when the body contained backslash-escaped nested quotes. The `Write` tool was used for `verify.sh` instead; simpler heredocs worked fine afterwards. Not investigated further.
- **`curl -sI … | head -1` exits 23** (SIGPIPE on the truncated body write). Cosmetic; the status line is still correct. `curl -o /dev/null -w '%{http_code}'` avoids it and is what `verify.sh` uses.
- The known `gsd-tools` breakages (`commit` word-splitting, the `state` subcommands' bold-label regex) were worked around as instructed: plain `git commit -F`, and `STATE.md` edited directly.

## User Setup Required

None. One thing worth knowing: **`origin/main` is no longer 20 commits behind — the guardrails are live.** Any future push to `main` whose diff includes even one non-ignored path will now rebuild and republish the site.

## Next Phase Readiness

- **Ready for 01-04.** `origin/main` carries the denylist, so a `_sass`-only commit is now a genuine test of it. Two of 01-04's concerns are already discharged by this plan's run: the CNAME and live-domain gates are proven green in a real run, and the API recipe above lets 01-04 confirm its own run programmatically rather than by browser.
- **Ready for 01-05.** `verify.sh`'s four SAFE-04 rows are already written and waiting; 01-05 turns them green by creating `docs/DEPLOYMENT.md` and pushing the `design-00-baseline` tag.
- **Open bookkeeping item:** `REQUIREMENTS.md` SAFE-03 remains `Pending`, deliberately. 01-05 owns the last piece (Settings > Rules). SAFE-01 and SAFE-02 were already marked `Complete` by plan 01-02 and are untouched here.
- **No blockers.**

## Self-Check: PASSED

- `.planning/phases/01-deployment-guardrails/verify.sh` exists on disk, mode `100755`, and runs.
- Commit `2383196` exists in `git log` and is the tip of both local `main` and `origin/main`.
- `origin/gh-pages` is at `931970f`, verified via `git ls-remote`.

---

_Phase: 01-deployment-guardrails_
_Completed: 2026-09-13_

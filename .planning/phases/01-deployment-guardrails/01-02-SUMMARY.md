---
phase: 01-deployment-guardrails
plan: 02
subsystem: infra
tags: [github-actions, gh-pages, ci, deploy, cname, custom-domain, bash]

# Dependency graph
requires: []
provides:
  - "deploy.yml triggers on a paths-ignore DENYLIST, so any push to main deploys unless every changed file is infra/docs — _sass/** now deploys"
  - "bin/verify-cname.sh: reusable, locally testable CNAME content assertion with Actions ::error annotations"
  - "Pre-deploy CNAME gate that fails the job before the destructive gh-pages force-push"
  - "Post-deploy live-domain gate (12 x 15s retry) that turns the run red if phamhakhanhchi.com stops answering"
  - "deploy-gh-pages concurrency group serialising deploys"
affects:
  [
    "01-04 (proves the _sass trigger live via a marker commit)",
    "01-05",
    "02-visual-tokens",
    "03-typography",
    "04-notebook-art-style",
    "any phase shipping SCSS",
  ]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Guard logic lives in a committed script called by the workflow, not inline YAML, so CI and local runs exercise identical code"
    - "Deploy path filters are denylists (fail-open to deploying), never allowlists (fail-closed to silence)"

key-files:
  created:
    - bin/verify-cname.sh
  modified:
    - .github/workflows/deploy.yml

key-decisions:
  - "Implemented the locked 'invert the path filter' decision as `paths-ignore:`, not an all-negative `paths:` list — GitHub rejects the latter and the workflow would never fire."
  - "Dropped the `pull_request:` trigger entirely (RESEARCH open question 3, resolved as DROP). This was a decision, not an omission."
  - "Kept `if: github.event_name != 'pull_request'` on the Deploy step even though it is now always true, so re-adding a PR trigger cannot silently start publishing from pull requests."
  - "Live-domain retry budget set to 12 x 15s (~3 min) rather than CONTEXT's ~60s, to absorb GitHub's separate 'pages build and deployment' run and remove the cry-wolf risk."
  - "`.github/**` is in the denylist, so editing deploy.yml does not itself deploy — deliberate, and the reason this file cannot be proven by pushing it."

patterns-established:
  - "Destructive-step guards run strictly BEFORE the destructive step; post-step checks report disasters, they do not prevent them."
  - "Every guard failure carries a `::error title=...::` annotation that names the problem and the fix in the Actions summary line, without opening logs."

requirements-completed: [SAFE-01, SAFE-02]

# Metrics
duration: 2min
completed: 2026-09-13
---

# Phase 01 Plan 02: Deploy Trigger and CNAME Guardrails Summary

**`deploy.yml` converted from a silent-failure allowlist to a `paths-ignore` denylist, with `bin/verify-cname.sh` blocking any build whose `_site/CNAME` is missing or wrong before the gh-pages force-push, plus a retrying live-domain gate and a `deploy-gh-pages` concurrency group.**

## Performance

- **Duration:** 2 min
- **Started:** 2026-09-13T10:08:40Z
- **Completed:** 2026-09-13T10:11:05Z
- **Tasks:** 2
- **Files modified:** 2 (1 created, 1 rewritten)

## Accomplishments

- **SAFE-01 closed.** The old allowlist never listed `_sass/**`, so every pure-SCSS commit of Phases 2-7 would have silently never reached the live site with no failed workflow to signal it. The trigger is now a denylist: a push deploys unless *every* changed file matches the ignore list. `_sass` appears nowhere in that list.
- **SAFE-02 closed.** `bin/verify-cname.sh` runs between "Purge unused CSS" and "Deploy", refusing to publish a build with a missing, empty, truncated or wrong-hostname `CNAME`.
- Live-domain gate added below the deploy; a deploy that leaves `phamhakhanhchi.com` unreachable now turns the run red instead of passing quietly.
- `concurrency: deploy-gh-pages` with `cancel-in-progress: false` means two deploys minutes apart are serialised and cannot race the force-push.

## Task Commits

1. **Task 1: Write `bin/verify-cname.sh` and prove it against all four CNAME states** — `5c72870` (feat)
2. **Task 2: Rewrite `deploy.yml` — paths-ignore denylist, CNAME gate, live-domain gate, concurrency** — `9b2750e` (fix)

## Files Created/Modified

- `bin/verify-cname.sh` (created, mode `100755`) — Single source of truth for the CNAME assertion. Takes an optional site-dir argument (default `_site`) so it is testable without a Jekyll build. Compares whitespace-stripped contents via `tr -d '[:space:]'`, so a CRLF checkout still passes. Runs under `set -euo pipefail`; the `$GITHUB_STEP_SUMMARY` append is guarded with `${GITHUB_STEP_SUMMARY:-}` so `set -u` cannot abort it locally.
- `.github/workflows/deploy.yml` (rewritten trigger + 2 inserted steps) — all build steps, action versions and pins left byte-identical.

## The `paths-ignore` list as committed

```yaml
paths-ignore:
  - ".planning/**"
  - "docs/**"
  - "lighthouse_results/**"
  - ".github/**"
  - "README.md"
  - "AGENTS.md"
  - "CLAUDE.md"
  - "LICENSE"
  - ".prettierignore"
  - ".prettierrc"
  - ".gitignore"
```

No `paths:` key, no `tags:`, no `pull_request:`, and `master` dropped from `branches:` (this repo has no `master`). `_sass` occurs exactly once in the whole file — inside the explanatory comment, never as an ignore entry.

## `bin/verify-cname.sh` four-state proof

Run against a synthetic temp directory; the real repo-root `CNAME` was never touched.

| Fixture                         | Exit | Annotation emitted        |
| ------------------------------- | ---- | ------------------------- |
| `phamhakhanhchi.com\n` (LF)     | 0    | — (success line)          |
| `phamhakhanhchi.com\r\n` (CRLF) | 0    | — (success line)          |
| empty file                      | 1    | `CNAME wrong` (actual `''`) |
| `example.com\n`                 | 1    | `CNAME wrong`             |
| file absent                     | 1    | `CNAME missing`           |

`git diff --stat HEAD~2 -- CNAME` is empty — the live custom domain was never put at risk to test the guard.

## Step ordering proof (line numbers in the committed file)

| Line | Step                                     |
| ---- | ---------------------------------------- |
| 87   | `run: bash bin/verify-cname.sh _site`    |
| 93   | `uses: JamesIves/github-pages-deploy-action@v4` |
| 101  | `- name: Verify live domain responds 🌐` |

`87 < 93 < 101` — the CNAME gate precedes the destructive force-push, the live check follows it.

## Decisions Made

- **`paths-ignore:`, not an inverted `paths:` list.** The plan's locked decision ("invert the path filter to a denylist") is correct, but GitHub rejects a `paths:` list made only of `!` exclusions, and `paths`/`paths-ignore` are mutually exclusive for the same event. The `paths:` key was deleted outright.
- **The `pull_request:` trigger was DROPPED, deliberately.** This resolves open question 3 in `01-RESEARCH.md` as "drop". Rationale: the Deploy step was already `if: github.event_name != 'pull_request'`, so the PR half only ever produced a build-without-deploy smoke test; this project pushes direct to `main` with no branch-per-phase and no reviewer; and one path list is better than two kept in sync. **A future reader should treat this as a decision, not an omission.**
- **Live-domain budget widened to ~3 minutes.** CONTEXT suggested ~60s. The job does not wait on GitHub's separate "pages build and deployment" run, so 12 x 15s absorbs that latency and removes the main false-alarm risk.
- **Guard phrased as regression insurance, not repair.** Per RESEARCH: three deploys ran on 2026-09-11 after `CNAME` landed on `main`, `origin/gh-pages:CNAME` is byte-identical to `main:CNAME`, and the live domain returns 200. The pipeline is healthy; this guard protects a working state.
- **The assertion checks contents, not existence.** `JamesIves/github-pages-deploy-action`'s `src/git.ts` adds `--exclude CNAME` to its `rsync --delete` when `_site/CNAME` is absent, so an *absent* CNAME already leaves gh-pages intact. The genuinely uncovered hazard is a *present-but-wrong* CNAME being rsynced over the good one.

## Deviations from Plan

One minor addition, no rule-triggered auto-fixes.

**1. Retained `if: github.event_name != 'pull_request'` on the Deploy step**

- **Found during:** Task 2
- **Issue:** With the `pull_request:` trigger removed, this condition is always true and is arguably dead code. The plan did not say whether to keep or remove it.
- **Resolution:** Kept verbatim, with a comment explaining why. The plan's instruction was "leave every existing build step, action version and pin exactly as it is", and keeping it is defence-in-depth: if a PR trigger is ever re-added, deploys still cannot fire from pull requests. Removing it would have been a silent behavioural change contingent on a future edit.
- **Files modified:** `.github/workflows/deploy.yml`
- **Committed in:** `9b2750e` (Task 2 commit)

---

**Total deviations:** 1 (conservative retention, not a fix)
**Impact on plan:** None. No scope creep; all four required changes landed exactly as specified.

## Issues Encountered

- **No YAML parser available locally.** Neither `js-yaml` (node) nor `pyyaml` (python) is installed on this machine, so the plan's "confirm valid YAML" check could not be done with a parser directly. Resolved by relying on `npx prettier .github/workflows/deploy.yml --check`, which must fully parse the YAML to report on it — it passed, which is itself the validity proof. The repo-wide `npx prettier . --check --end-of-line auto` also exits 0.
- **No Ruby/Bundler on this machine**, as the plan anticipated, so there is no way to produce a real `_site/` locally. `bin/verify-cname.sh` was proven against synthetic temp fixtures instead, per the plan's instruction.
- **Parallel plan 01-01** was editing `.prettierignore` and `.github/workflows/*` concurrently. Only `bin/verify-cname.sh` and `.github/workflows/deploy.yml` were staged, using explicit `git add <path>`.

## Verification Results

All plan-level checks pass:

1. Trigger shape — one `push` trigger with `paths-ignore`, plus `workflow_dispatch`. No `paths:`, no `pull_request:`, no `tags:`. PASS
2. `_sass` absent from the ignore list. PASS
3. Step order asserted by line number: 87 < 93 < 101. PASS
4. `bin/verify-cname.sh` returns 0/0/1/1/1 across good/CRLF/empty/wrong/absent. PASS
5. `npx prettier . --check --end-of-line auto` exits 0. PASS
6. Repo-root `CNAME` unmodified across both commits. PASS

## User Setup Required

None — no external service configuration required. Note that `Settings > Pages` must continue to show `phamhakhanhchi.com` as the custom domain; the new live-domain step is what will now report it if that ever changes.

## Next Phase Readiness

- **Ready.** SCSS-only commits will now deploy, which unblocks Phases 2-4 (tokens, typography, notebook art style) — those phases touch little but `_sass/**`.
- **Not yet proven live.** Because `.github/**` is in the denylist, committing this workflow does not itself trigger a deploy. Plan 01-04's `_sass`-only marker commit is the live proof that SAFE-01 works end to end; `workflow_dispatch` is available if an earlier manual run is wanted.
- **Concern for 01-04:** the live-domain step asserts the domain *resolves*, not that new content shipped — served CSS carries `Cache-Control: max-age=600` behind a CDN. Plan 04's marker grep remains necessary and must account for that cache window.

## Self-Check: PASSED

---

_Phase: 01-deployment-guardrails_
_Completed: 2026-09-13_

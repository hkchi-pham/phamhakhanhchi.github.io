---
phase: 01-deployment-guardrails
plan: 01
subsystem: infra
tags: [github-actions, ci, prettier, workflow-pruning, fork-hygiene]

# Dependency graph
requires: []
provides:
  - "`.github/workflows/` reduced from 22 inherited al-folio files to the 3 that can pass here: deploy.yml, prettier.yml, broken-links-site.yml"
  - "`visual-regression.yml` deleted, so no PR can display that check regardless of path filters — SAFE-03 made structurally true"
  - "Zero surviving workflows auto-commit to `main`; `docs/DEPLOYMENT.md` (plan 01-05) cannot be rewritten by a bot"
  - "`.planning/**` in `.prettierignore`, so GSD's own documents no longer turn `prettier.yml` red on every push"
affects:
  [
    "01-03 (first push to origin/main lands against this workflow set)",
    "01-05 (docs/DEPLOYMENT.md is now safe from update-tocs.yml)",
    "any phase editing _data/cv.yml (render-cv.yml auto-commit removed)",
    "any future plan touching .github/workflows/ (permission gate, below)",
  ]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "A CI check is kept only if a green tick on it means something about THIS site; inherited checks guarding the upstream thin-starter boundary are deleted, not disabled"
    - "Structural removal over configuration: delete the workflow file rather than narrow its path filter, so the guarantee cannot be re-broken by a later filter edit"
    - "Generated planning artefacts are excluded from formatters, not reformatted in perpetuity"

key-files:
  created: []
  modified:
    - .prettierignore
  deleted:
    - .github/workflows/visual-regression.yml
    - .github/workflows/unit-tests.yml
    - .github/workflows/update-tocs.yml
    - .github/workflows/render-cv.yml
    - .github/workflows/star-history.yml
    - .github/workflows/upgrade-check.yml
    - .github/workflows/docker-slim.yml
    - .github/workflows/deploy-image.yml
    - .github/workflows/deploy-docker-tag.yml
    - .github/workflows/broken-links.yml
    - .github/workflows/lighthouse-badger.yml
    - .github/workflows/release.yml
    - .github/workflows/update-screenshots.yml
    - .github/workflows/copilot-setup-steps.yml
    - .github/workflows/prettier-html.yml
    - .github/workflows/prettier-comment-on-pr.yml
    - .github/workflows/axe.yml
    - .github/workflows/codeql.yml
    - .github/workflows/update-citations.yml

key-decisions:
  - "Deleted the 19 workflows outright rather than stripping them to `workflow_dispatch:` — five were already dispatch-only, so stripping would have gained nothing and left 22 files of reading cost."
  - "`unit-tests.yml` removed for IRRELEVANCE, not failure. It passes today (81e55bd already disabled its forbidden-path check); everything it still asserts guards the upstream thin-starter boundary, which is not a property this personal site has."
  - "`star-history.yml`, `broken-links.yml`, `deploy-image.yml`, `release.yml`, `update-screenshots.yml` removed for NOISE, not danger — each already carried an `alshedivat` repository guard that skipped its job on this fork."
  - "`test/visual/` and the `test:visual*` npm scripts deliberately left in place for a possible future TEST-01 retarget, even though the workflow that ran them is gone."
  - "`.planning/**` added to `.prettierignore` rather than reformatting 17 planning documents, because GSD regenerates them every phase and `prettier.yml` has no path filter."

patterns-established:
  - "Never run a bare `npx prettier . --write` on this checkout: `core.autocrlf=true` makes it rewrite ~99 files with line-ending-only churn. Always pass `--end-of-line auto`, and fix individual files by path."
  - "Workflow-file changes must be staged and committed from the repo root by the orchestrator, not by a subagent (see Issues Encountered)."

requirements-completed: [SAFE-03]

# Metrics
duration: 7min
completed: 2026-09-13
---

# Phase 01 Plan 01: Workflow Pruning and Prettier Scope Summary

**`.github/workflows/` cut from 22 inherited al-folio files to the 3 that can pass on this site, deleting `visual-regression.yml` (so SAFE-03 holds structurally) and both unguarded auto-committers, with `.planning/**` excluded from Prettier so the phase's first push does not go red.**

## Performance

- **Duration:** 7 min
- **Started:** 2026-09-13T10:09:17Z (Task 1 commit)
- **Completed:** 2026-09-13T10:16:38Z (Task 2 commit)
- **Tasks:** 2
- **Files modified:** 20 (1 modified, 19 deleted, 1401 lines removed)

## Accomplishments

- **SAFE-03 satisfied structurally, not by configuration.** `visual-regression.yml` no longer exists, so a PR touching `_sass/**`, `_pages/**` or `assets/**` cannot show that check no matter how path filters are later edited. Its specs targeted `/al-folio/` routes and v0.16.3 demo content this site does not have; it could never have passed.
- **Both unguarded auto-committers are gone.** `update-tocs.yml` matched `docs/*.md` — exactly where plan 01-05's `docs/DEPLOYMENT.md` lands — and `render-cv.yml` triggered on `_data/cv.yml`. Either would have produced a bot commit on `main` mid-phase and a non-fast-forward rejection on the next local push.
- **Every surviving workflow can pass here.** Final inventory is exactly `broken-links-site.yml`, `deploy.yml`, `prettier.yml`, plus the non-workflow `schedule-posts.txt` (GitHub ignores it; left alone).
- **CI is green from the first push.** `npx prettier . --check --end-of-line auto` went from 17 failures — all under `.planning/` — to "All matched files use Prettier code style!".

## Task Commits

1. **Task 1: Stop `prettier.yml` going red on agent-authored planning docs** — `d4dcbb5` (chore)
2. **Task 2: Prune the 19 inherited workflows that cannot pass or should not run here** — `11705b6` (chore)

## Final workflow inventory

`ls .github/workflows/`:

| File                    | Kept because                                                            |
| ----------------------- | ----------------------------------------------------------------------- |
| `deploy.yml`            | The single deploy path. Untouched here; plan 01-02 owns and rewrote it. |
| `prettier.yml`          | The one inherited check that genuinely applies to this repo's source.   |
| `broken-links-site.yml` | Deployed-site link check; used again in Phase 8.                        |
| `schedule-posts.txt`    | Not a workflow — GitHub ignores it. Deliberately left in place.          |

Deleted (19, grouped by reason — the full rationale is in commit `11705b6`'s message):

| Group                                                                          | Reason                                                              |
| ------------------------------------------------------------------------------ | ------------------------------------------------------------------- |
| `visual-regression.yml`                                                        | Can never pass; deleting it is what makes phase criterion 3 true     |
| `update-tocs.yml`, `render-cv.yml`                                             | `contents: write`, no repository guard — real auto-commit hazard     |
| `unit-tests.yml`                                                               | Passes today; guards the upstream boundary, not this site            |
| `star-history`, `broken-links`, `deploy-image`, `release`, `update-screenshots` | Already skipped by an `alshedivat` repository guard — noise          |
| `upgrade-check`, `render-cv`, `update-citations`                               | Need the al-folio CLI / `rendercv` / `scholarly` plus a Scholar ID   |
| `docker-slim`, `deploy-image`, `deploy-docker-tag`                             | Publish upstream's container images                                  |
| `axe`, `lighthouse-badger`, `prettier-html`                                    | Already `workflow_dispatch`-only; lighthouse measures upstream demo  |
| `copilot-setup-steps`                                                          | Triggers only on its own file                                        |
| `codeql`                                                                       | Code scanning on a static Jekyll site is noise                       |
| `prettier-comment-on-pr`                                                       | Only fires on a `repository_dispatch` sent by `prettier.yml`         |

`prettier.yml` now dispatches into nothing. This is harmless: that dispatch step sits inside a `failure()` guard, and a failed dispatch cannot un-fail an already-red job.

## Findings that change later phases

**1. `render-cv.yml` was a SECOND unguarded auto-committer.** The plan's research named `update-tocs.yml` as "the only one with `contents: write` and no repository guard". That premise was understated: `render-cv.yml` has the identical shape — `contents: write`, no repository guard — and it triggers on pushes touching `_data/cv.yml`, a file later content phases are likely to edit. It was already in the deletion set, so the plan's outcome is unaffected, but the reasoning behind it was incomplete. **Consequence:** later phases editing `_data/cv.yml` are now safe from bot commits causing non-fast-forward push rejections — a hazard nobody had budgeted for.

**2. Workflow files sit behind a permission gate for subagents in this environment.** See Issues Encountered; this is a standing constraint on every future plan that touches CI.

## Verification Results

All plan-level checks pass, re-confirmed against the committed state:

1. `ls .github/workflows/` lists exactly `broken-links-site.yml`, `deploy.yml`, `prettier.yml` (plus `schedule-posts.txt`). PASS
2. `npx prettier . --check --end-of-line auto` exits 0 — "All matched files use Prettier code style!" (was 17 failures, all under `.planning/`). PASS
3. `grep -rn "contents: write" .github/workflows/` matches only `deploy.yml:40`, whose write scope is the `gh-pages` publish. No surviving workflow can push to `main`. PASS
4. Nothing under `_sass/`, `_pages/`, `assets/` or `docs/` was touched. `d4dcbb5` changes only `.prettierignore` (+2 lines); `11705b6` changes only `.github/workflows/` (19 deletions, 1401 lines). PASS
5. `.prettierignore` contains a bare `.planning/**` line with its rationale comment above it. PASS

A bare `npx prettier . --write` was never run, so there is no CRLF churn anywhere in the tree.

## Decisions Made

- **Deletion, not `workflow_dispatch:` stripping.** CONTEXT's default was deletion, and five of the nineteen were already dispatch-only, so stripping would have preserved 22 files of reading cost for zero safety gain.
- **`unit-tests.yml` removed for irrelevance.** The premise correction from the plan's `research_corrections` was applied and stated in the commit message. `81e55bd` already commented out the forbidden-path block in `test/style_contract.js`, so the workflow passes today and would have kept passing through Phases 2-8. It still goes, because everything it asserts (`theme: al_folio_core`, five plugin ids, three SRI hashes, the `al_math` exact-version pin) guards the upstream thin-starter boundary. Under this phase's own standard — a green tick must mean something — a check guarding someone else's invariant should not be wired up.
- **`star-history.yml` and four siblings removed for noise, not danger.** Each carries a job-level `if:` on the `alshedivat` repository, so their jobs were already skipped on this fork. Recorded so a future reader does not mistake them for live hazards narrowly averted.
- **`test/visual/` and the `test:visual*` npm scripts kept.** CONTEXT does not ask for their removal and a future TEST-01 milestone may retarget them at this site's real routes. Only the workflow that ran them is gone.
- **Planning docs excluded rather than reformatted.** `prettier.yml` runs on every push to `main` with no path filter, and GSD rewrites `.planning/**` every phase. Reformatting them once would only defer the problem to the next phase.

## Deviations from Plan

None — plan executed exactly as written. Both tasks landed with the specified files and the specified commit rationale.

The one substantive discovery (`render-cv.yml` as a second auto-committer) required no change of action, because that file was already in the plan's deletion list. It is recorded above as a correction to the plan's stated reasoning, not as a deviation from its instructions.

## Issues Encountered

- **Subagent permission gate on `.github/workflows/`.** This environment's permission classifier denies subagent `git add` and `git commit` on paths under `.github/workflows/`. Task 2's 19 deletions had to be staged and committed by the orchestrator from the repo root instead. **Any future plan in this project that adds, modifies or deletes a workflow file will hit the same gate and needs the same hand-off** — budget for it rather than treating it as a failure.
- **`gsd-tools.cjs commit` is unusable here for multi-word messages** — it word-splits the message into `git add` pathspecs and stages the wrong thing. Plain `git commit -m` / `-F` with explicit `git add <path>` was used throughout.
- **`gsd-tools state update-progress` / `record-session` / `advance-plan` no-op against this `STATE.md`.** The tool matches bold `**Progress:**` / `**Stopped At:**` labels; this file uses plain `Progress:` / `Stopped at:` — which is what the GSD state template itself uses. `STATE.md` is correct and the tool's regex is the bug. `STATE.md` was edited directly, as plan 01-02 also did. Do not "fix" this by bolding the labels.
- **Parallel plan 01-02** was editing `.github/workflows/deploy.yml` and `bin/verify-cname.sh` concurrently. Only this plan's paths were staged, explicitly. `deploy.yml` was never touched by 01-01.

## User Setup Required

None — no external service configuration required.

One consequence worth knowing: the GitHub Actions status list on this repo is now much shorter. If a previously familiar check (CodeQL, axe, unit-tests) is missing from a PR, that is this plan, not a broken pipeline.

## Next Phase Readiness

- **Ready for 01-03.** The workflow set that the first `origin/main` push will land against is final and minimal, and Prettier is clean the way CI sees it — the two preconditions 01-03 needs before pushing the guardrails.
- **Ready for 01-05.** `docs/DEPLOYMENT.md` can be written without `update-tocs.yml` rewriting it and auto-committing mid-phase.
- **Open bookkeeping item:** `REQUIREMENTS.md` still lists SAFE-03 as `Pending` in its traceability table. This plan satisfies the requirement text ("design PRs are not blocked by `visual-regression.yml`"), but SAFE-03 is also claimed by plans 01-03 and 01-05, so it was deliberately left unmarked here rather than closed early. Whichever of those plans lands last should mark it Complete.
- **No blockers.**

## Self-Check: PASSED

- All three surviving workflow files and `.prettierignore` exist on disk; all nineteen deletions confirmed absent (spot-checked `visual-regression`, `update-tocs`, `unit-tests`, `render-cv`).
- Both task commits `d4dcbb5` and `11705b6` exist in git history.

---

_Phase: 01-deployment-guardrails_
_Completed: 2026-09-13_

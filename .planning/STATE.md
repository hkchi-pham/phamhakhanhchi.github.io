---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: milestone
status: unknown
last_updated: "2026-09-13T10:30:00.000Z"
progress:
  total_phases: 1
  completed_phases: 0
  total_plans: 5
  completed_plans: 3
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-09-13)

**Core value:** A reader should open the site and feel curious about the person behind it — curious enough to click into the research, projects and reading rather than skim a list of achievements.
**Current focus:** Phase 1 — Deployment Guardrails

## Current Position

Phase: 1 of 8 (Deployment Guardrails)
Plan: 3 of 5 in current phase
Status: In progress
Last activity: 2026-09-13 - Plan 01-03 complete (verify.sh harness; guardrails pushed to origin/main, 778f68b -> 2383196, deploy fired and went green as predicted)

Progress: [██████░░░░] 60%

## Performance Metrics

**Velocity:**

- Total plans completed: 0
- Average duration: —
- Total execution time: 0.0 hours

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
| ----- | ----- | ----- | -------- |
| -     | -     | -     | -        |

**Recent Trend:**

- Last 5 plans: —
- Trend: —

_Updated after each plan completion_
| Phase 01 P01 | 7min | 2 tasks | 20 files |
| Phase 01 P02 | 2min | 2 tasks | 2 files |
| Phase 01 P03 | 10min | 2 tasks | 1 file |

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Recent decisions affecting current work:

- [Roadmap]: `enable_darkmode: false` (TOKEN-04) moved from Phase 1 into Phase 2, to land in the same change as the token re-point — `html[data-theme="dark"]` (0,1,1) outranks `:root` (0,1,0).
- [Roadmap]: Research's "Ground and Type" step split into Phase 3 (Typography) and Phase 4 (Notebook Art Style), so a finished typographic site is a deadline fallback if the marks have to be cut.
- [Roadmap]: GROUND-04 (links underlined) assigned to Phase 2, because re-pointing `--global-theme-color` to a warm ink accent is what creates the colour-alone hazard.
- [Roadmap]: Mobile/print/scannability (Phase 7) and the manual QA audits (Phase 8) kept as separate phases so QA is a budgeted gate, not a checkbox.
- [Phase 01]: Deploy path filter implemented as `paths-ignore:` (denylist), not an inverted `paths:` list — GitHub rejects an all-negative `paths:` and the workflow would never fire. `_sass/**` now deploys.
- [Phase 01]: The `pull_request:` trigger on deploy.yml was DROPPED deliberately (RESEARCH open question 3), not omitted: the Deploy step was already PR-guarded, and one path list beats two kept in sync.
- [Phase 01]: CNAME guard asserts file CONTENTS via bin/verify-cname.sh, not existence: the deploy action already excludes an absent CNAME from its rsync --delete, so the real hazard is a present-but-wrong CNAME overwriting the good one.
- [Phase 01]: `.github/workflows/` pruned 22 → 3 (`deploy.yml`, `prettier.yml`, `broken-links-site.yml`). Deletion, not `workflow_dispatch:` stripping — five were already dispatch-only. `schedule-posts.txt` left alone (not a workflow).
- [Phase 01]: `unit-tests.yml` deleted for IRRELEVANCE, not failure — it passes today (`81e55bd` disabled its forbidden-path check), but everything it asserts guards the upstream thin-starter boundary. Standard adopted: a green tick must mean something about THIS site.
- [Phase 01]: `test/visual/` and the `test:visual*` npm scripts deliberately KEPT even though `visual-regression.yml` was deleted — a future TEST-01 milestone may retarget them.
- [Phase 01]: `.planning/**` added to `.prettierignore` rather than reformatting 17 generated planning docs; `prettier.yml` has no path filter so they gated every push.
- [Phase 01]: Phase verification lives in `.planning/phases/01-deployment-guardrails/verify.sh` — a flat `check <label> <expr>` list with a tally, `set -uo pipefail` (never `-e`), NO test framework and NO npm script (01-VALIDATION forbids a starter-local test pipeline). Criteria that are not yet true stay in as `[red until plan NN]` rows rather than being omitted.
- [Phase 01]: The guardrail push was a SINGLE `git push origin main`, not the split the plan offered. GitHub evaluates a push's path filters against the workflow at the TIP of the pushed ref; the only available split point (`854916b`) predates the denylist, so its first push would have been judged by the old `"**/*.md"` allowlist and deployed — proving nothing.

### Pending Todos

None yet.

### Blockers/Concerns

- **CORRECTION: `gh` is absent but the PUBLIC GitHub REST API is readable UNAUTHENTICATED on this repo.** `01-VALIDATION.md` and both wave-1 summaries claim there is no CLI way to query workflow-run status; that premise is too strong. `curl -s https://api.github.com/repos/hkchi-pham/phamhakhanhchi.github.io/actions/runs?per_page=8` and `.../actions/runs/<id>/jobs` both work with no token (60 req/hr). This DE-MANUALS 01-VALIDATION row `01-04-03` — plan 01-04 can assert its run's step list programmatically. Repository *settings* (Pages, Rules) remain genuinely browser-only.
- **Tooling: Git Bash mangles `git show <rev>:<path>`** via MSYS path conversion (`origin/main:.github/...` becomes `origin\main;.github\...`). Prefix every such command with `MSYS_NO_PATHCONV=1`. Also: `$TMPDIR` is unset in this shell — write commit-message files to the session scratchpad, not `$TMPDIR`.
- **No CI gate covers contrast, performance or accessibility on this site.** `axe.yml` is `workflow_dispatch`-only; `lighthouse-badger.yml` measures the upstream demo. Every QA number in this milestone is self-enforced.
- ~~**The CNAME fix on `main` is untested.**~~ CORRECTED then RESOLVED in plan 01-02. Research found three deploys DID run on 2026-09-11 after `CNAME` reached `main`, and `origin/gh-pages:CNAME` is byte-identical to `main:CNAME`; the pipeline is healthy. `bin/verify-cname.sh` (`5c72870`) is now regression insurance on that working state, not a repair.
- ~~**`_sass/**` is absent from `deploy.yml`'s push path filter.**~~ RESOLVED in plan 01-02 (`9b2750e`) and now LIVE on `origin/main` as of 01-03 (`2383196`). Still not demonstrated by a `_sass`-ONLY commit — plan 01-04 supplies that last proof. Everything else about the new workflow is proven: run `34751688430` ran the CNAME gate (step 10), the publish (11) and the live-domain gate (12) all green, in order, and advanced `gh-pages` `f7b878d` -> `931970f`.
- **Register overshoot (PITFALLS 3) is partly unrecoverable.** Prevention lives in Phase 2 (cap the token vocabulary) and Phase 8 (count the markers); there is no recovery path after a reader forms an impression.
- **Environment constraint: subagents cannot commit under `.github/workflows/`.** This environment's permission classifier denies subagent `git add`/`git commit` on those paths; plan 01-01's 19 deletions had to be staged and committed by the orchestrator from the repo root. Any future plan that adds, modifies or deletes a workflow file needs the same hand-off — budget for it, do not treat it as a failure.
- **Tooling: `gsd-tools` state commands no-op against this STATE.md.** `update-progress`, `record-session` and `advance-plan` match bold `**Progress:**` / `**Stopped At:**`; this file uses the template's plain `Progress:` / `Stopped at:`. STATE.md is correct and the tool's regex is the bug — edit STATE.md directly and do NOT bold the labels. `gsd-tools commit` also word-splits multi-word messages into `git add` pathspecs; use plain `git commit` with explicit `git add <path>`.
- ~~**`update-tocs.yml` will auto-commit over this phase's `docs/DEPLOYMENT.md`.**~~ RESOLVED in plan 01-01 (`11705b6`). Research understated this: `render-cv.yml` was a SECOND unguarded auto-committer (`contents: write`, no repo guard, triggers on `_data/cv.yml`). Both are deleted; only `deploy.yml` retains `contents: write`, scoped to the `gh-pages` publish.
- **`AGENTS.md` / `CLAUDE.md` describe the upstream al-folio demo, not this site.** Baseurl here is empty, the seven integration tests were dropped in `81e55bd`, and `_sass/`/`_layouts/`/`_includes/` are not forbidden here. Trust PROJECT.md and `.planning/codebase/`.

## Session Continuity

Last session: 2026-09-13
Stopped at: Completed 01-03-PLAN.md. `verify.sh` exists (14 static + 4 live rows; 4 static FAILs, all SAFE-04, red-by-design until plan 01-05). The guardrails are LIVE: `origin/main` advanced 778f68b -> 2383196 in one fast-forward push, which fired exactly the one deploy predicted (carried by `bin/verify-cname.sh`, the one changed path not in the denylist). That run went green end to end, `prettier.yml` went green, `gh-pages` advanced f7b878d -> 931970f with its CNAME intact, and the live site still returns 200. Next is 01-04 (the `_sass`-only proof commit — the last unproven half of SAFE-01), then 01-05 (tag, Pages/Rules snapshot, docs/DEPLOYMENT.md).
Resume file: None

Denylist proven in BOTH directions on real pushes, not read off the YAML:
- `2383196` (carries `bin/verify-cname.sh`, a non-ignored path) -> deploy FIRED, green, gh-pages f7b878d -> 931970f.
- `5571b60` (pure `.planning/**`) -> deploy did NOT fire. `GET /actions/runs?head_sha=5571b60a…` returns `total_count: 1` and that single run is Prettier, which passed. gh-pages unchanged. Under the OLD allowlist `"**/*.md"` would have matched all three files and rebuilt production for a docs edit.

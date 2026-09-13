---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: milestone
status: unknown
last_updated: "2026-09-13T10:11:22.326Z"
progress:
  total_phases: 1
  completed_phases: 0
  total_plans: 5
  completed_plans: 1
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-09-13)

**Core value:** A reader should open the site and feel curious about the person behind it — curious enough to click into the research, projects and reading rather than skim a list of achievements.
**Current focus:** Phase 1 — Deployment Guardrails

## Current Position

Phase: 1 of 8 (Deployment Guardrails)
Plan: 1 of 5 in current phase
Status: In progress
Last activity: 2026-09-13 - Plan 01-02 complete (deploy denylist + CNAME/live-domain guardrails)

Progress: [██░░░░░░░░] 20%

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
| Phase 01 P02 | 2min | 2 tasks | 2 files |

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

### Pending Todos

None yet.

### Blockers/Concerns

- **No CI gate covers contrast, performance or accessibility on this site.** `axe.yml` is `workflow_dispatch`-only; `lighthouse-badger.yml` measures the upstream demo. Every QA number in this milestone is self-enforced.
- ~~**The CNAME fix on `main` is untested.**~~ CORRECTED then RESOLVED in plan 01-02. Research found three deploys DID run on 2026-09-11 after `CNAME` reached `main`, and `origin/gh-pages:CNAME` is byte-identical to `main:CNAME`; the pipeline is healthy. `bin/verify-cname.sh` (`5c72870`) is now regression insurance on that working state, not a repair.
- ~~**`_sass/**` is absent from `deploy.yml`'s push path filter.**~~ RESOLVED in plan 01-02 (`9b2750e`): the filter is now a `paths-ignore` denylist. Not yet demonstrated on a real push — plan 01-04 supplies that proof.
- **Register overshoot (PITFALLS 3) is partly unrecoverable.** Prevention lives in Phase 2 (cap the token vocabulary) and Phase 8 (count the markers); there is no recovery path after a reader forms an impression.
- **`AGENTS.md` / `CLAUDE.md` describe the upstream al-folio demo, not this site.** Baseurl here is empty, the seven integration tests were dropped in `81e55bd`, and `_sass/`/`_layouts/`/`_includes/` are not forbidden here. Trust PROJECT.md and `.planning/codebase/`.

## Session Continuity

Last session: 2026-09-13
Stopped at: Completed 01-02-PLAN.md (deploy.yml denylist + CNAME and live-domain guardrails). Not yet proven live: .github/** is in the denylist so this commit does not self-deploy; plan 01-04 is the live proof.
Resume file: None

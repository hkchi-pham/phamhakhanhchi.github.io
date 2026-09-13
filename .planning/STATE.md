---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: milestone
status: in_progress
last_updated: "2026-09-13T14:00:17.959Z"
progress:
  total_phases: 8
  completed_phases: 1
  total_plans: 5
  completed_plans: 5
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-09-13)

**Core value:** A reader should open the site and feel curious about the person behind it — curious enough to click into the research, projects and reading rather than skim a list of achievements.
**Current focus:** Phase 2 — Palette and Design Tokens

## Current Position

Phase: 2 of 8 (Palette and Design Tokens)
Plan: 0 of TBD in current phase
Status: Ready to plan (Phase 1 complete and verified 4/4)
Last activity: 2026-09-13 - Phase 1 closed out in full. The Task 3 human read-through of `docs/DEPLOYMENT.md` returned APPROVED: §4's criterion-4 sentence judged "plain and unhedged", all three §5 failure modes judged followable at 11pm, no placeholders or stale claims. The reviewer's one challenge (§5.1's "3,000 files" limit) was researched — the number is correct for GitHub's native `paths-ignore` filter, 300 is the superseded figure — but it exposed a genuinely defective two-way hedge around it, fixed in `b56a9d5`. GitHub settings independently confirmed in the browser (Pages `gh-pages`/root, DNS verified, HTTPS enforced; Rulesets and branch protection both EMPTY), discharging the last SAFE-03 caveat. `01-VALIDATION.md` is 13 of 13 rows green.

Progress: [█░░░░░░░░░] 13% (1 of 8 phases complete)

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
| Phase 01 P04 | 13min | 3 tasks | 1 file |
| Phase 01 P05 | 7min | 4 tasks | 3 files |

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
- [Phase 01]: The `--deploy-proof` canary in `_sass/_custom.scss` is RETAINED, not reverted — no revert deploy is pending. It is an unreferenced `:root` custom property (35 bytes, `var(--deploy-proof)` appears 0 times in the served CSS, so it provably repaints nothing). Re-date it and push a `_sass`-only commit to answer "did my change ship?". Phase 2 must leave it in place and must NOT fold it in with the design tokens, where a token audit would delete it as unused.
- [Phase 01]: A deploy canary must be a DECLARATION, not a comment — Sass strips `//` entirely and the minifier may strip `/* */`. And it must be grepped from the CDN-served asset with a `?cb=` buster, never from `_site/`: a green tick proves the workflow ran, `gh-pages` advancing is stronger, but only the served-asset grep proves the rule survived PurgeCSS.
- [Phase 01]: Plan 01-04's checkpoint was SPLIT rather than delegated whole — the Actions step-list half was asserted programmatically via the unauthenticated REST API and only the "does it look the same" half went to the human. This de-manuals the Actions half of 01-VALIDATION row `01-04-03`; only settings-based rows (Pages, Rules) remain genuinely browser-only.
- [Phase 01]: Repository SETTINGS are not as browser-only as the phase assumed. `/repos/.../pages` 404s and `/branches/main/protection` 401s unauthenticated, but `/branches` (`"protected": false`), `/rules/branches/main` (`[]`) and `/rulesets` (`[]`) all answer, and the Pages values are MEASURABLE: `hkchi-pham.github.io/phamhakhanhchi.github.io/` 301s to the custom domain (domain configured + DNS validated) and `http://` 301s to `https://` with HSTS (Enforce HTTPS on). Plan 01-05's blocking human-action checkpoint was resolved by measurement instead of being raised. CONFIRMED IN THE BROWSER at close-out: Pages source `gh-pages` / `(root)`, DNS verified, HTTPS enforced; Rulesets EMPTY and branch protection rules EMPTY, nothing targeting `main` on either front. Every measured value matched, so the residual "an unauthenticated caller might see a filtered ruleset list" caveat is discharged and SAFE-03 is closed without residue.
- [Phase 01]: Tag scheme for the milestone is `design-NN-<slug>`, one annotated tag per phase completion, NEVER `v*` (the deleted upstream `deploy-docker-tag.yml` fired on `v*`). Tag the commit that PRODUCED what was live — read it off the `gh-pages` commit subject — not local HEAD.
- [Phase 01]: Pushing a tag does not deploy, but it is NOT inert. GitHub evaluates workflows at the commit being pushed, so tagging a PRE-cleanup commit resurrects that commit's workflow set: `design-00-baseline` on `778f68b` started `copilot-setup-steps.yml` (no `branches:` restriction on its `on.push`). Harmless, succeeded, documented in `docs/DEPLOYMENT.md` §3.
- [Phase 01]: `deploy.yml`'s path filtering has THREE silent scale limits and they do NOT point the same way. Over 3,000 files in the diff (and the filter's matches not among the first 3,000 returned) -> the workflow does NOT run. Over 1,000 commits in the push, or diff-generation timeout -> path filtering is bypassed and the workflow ALWAYS runs. 3,000 is the current native `on.push.paths-ignore` figure; 300 is the superseded value still quoted by older sources, and some of them confuse it with the third-party `dorny/paths-filter` action, which this repo does not use. A diff in the hundreds of files is therefore NOT explained by the file limit — check the denylist first. Written up in `docs/DEPLOYMENT.md` §5.1 (`b56a9d5`) with a dated citation.
- [Phase 01]: SAFE-04's requirement text is ANNOTATED, not rewritten. Its clause "a revert touching only `_sass/**` will not redeploy either" became false the moment SAFE-01 landed, but requirement text is a historical record of what was asked and why (SAFE-01 and SAFE-02 likewise describe the broken pre-phase state in the present tense). The original sentence is byte-for-byte intact with a dated sub-bullet beneath it naming the stale clause, the commit that falsified it (`b07bc86`) and where the corrected behaviour now lives. Convention for later phases: never silently edit a requirement to match its outcome; annotate.
- [Phase 01]: The guardrail push was a SINGLE `git push origin main`, not the split the plan offered. GitHub evaluates a push's path filters against the workflow at the TIP of the pushed ref; the only available split point (`854916b`) predates the denylist, so its first push would have been judged by the old `"**/*.md"` allowlist and deployed — proving nothing.

### Pending Todos

None yet.

### Blockers/Concerns

- **CORRECTION: `gh` is absent but the PUBLIC GitHub REST API is readable UNAUTHENTICATED on this repo.** `01-VALIDATION.md` and both wave-1 summaries claim there is no CLI way to query workflow-run status; that premise is too strong. `curl -s https://api.github.com/repos/hkchi-pham/phamhakhanhchi.github.io/actions/runs?per_page=8` and `.../actions/runs/<id>/jobs` both work with no token (60 req/hr). This DE-MANUALS 01-VALIDATION row `01-04-03` — plan 01-04 can assert its run's step list programmatically. Repository *settings* (Pages, Rules) remain genuinely browser-only.
- **Tooling: Git Bash mangles `git show <rev>:<path>`** via MSYS path conversion (`origin/main:.github/...` becomes `origin\main;.github\...`). Prefix every such command with `MSYS_NO_PATHCONV=1`. Also: `$TMPDIR` is unset in this shell — write commit-message files to the session scratchpad, not `$TMPDIR`.
- **No CI gate covers contrast, performance or accessibility on this site.** `axe.yml` is `workflow_dispatch`-only; `lighthouse-badger.yml` measures the upstream demo. Every QA number in this milestone is self-enforced.
- ~~**The CNAME fix on `main` is untested.**~~ CORRECTED then RESOLVED in plan 01-02. Research found three deploys DID run on 2026-09-11 after `CNAME` reached `main`, and `origin/gh-pages:CNAME` is byte-identical to `main:CNAME`; the pipeline is healthy. `bin/verify-cname.sh` (`5c72870`) is now regression insurance on that working state, not a repair.
- ~~**`_sass/**` is absent from `deploy.yml`'s push path filter.**~~ FULLY RESOLVED. Fixed in 01-02 (`9b2750e`), live on `origin/main` as of 01-03 (`2383196`), and DEMONSTRATED in 01-04 by `b07bc86`, whose entire diff is `_sass/_custom.scss` (+8 lines, one path): run `34756737328` fired on it, went green in 69s with the CNAME gate (step 10) above the publish (11) and the live-domain gate (12) below, advanced `gh-pages` `931970f` -> `9d0d929`, and put `--deploy-proof` into the CSS served by the CDN. Criteria 1 and 2 of the phase are met by demonstration, not by reading the YAML.
- **Deploy latency, measured — expect ~2-3 minutes, and poll rather than refreshing once.** From push: workflow starts ~2s, finishes ~71s, `gh-pages` advances ~97s, the new CSS is served ~124s. The last gap is GitHub's SEPARATE "pages build and deployment" run, which `deploy.yml` does not wait on. Also: `main.css` carries `Cache-Control: max-age=600` behind a proxy cache, so always grep it with `?cb=$(date +%s)`.
- **`_custom.scss` is `@use`d LAST, so its rules land near the END of `main.css`, not the top.** The `--deploy-proof` marker sits at byte 25942 of 26581 (~97.6% down). Search the served stylesheet; do not scroll to the top and conclude the deploy failed. (Plan 01-04's own checkpoint text got this wrong, and also printed the Actions URL under org `phamhakhanhchi` — the real remote is **`hkchi-pham`**.)
- **Tooling: `/actions/runs?head_sha=` needs the FULL 40-character SHA.** A short SHA returns `"total_count": 0`, which is indistinguishable from "no run fired" — the exact false negative this phase exists to prevent. Four polls were wasted on it in 01-05.
- **Tooling: Prettier mangles a `**`-terminated glob inside a bold span.** `**... `_sass/**` ...**` is rewritten to `**... `\_sass/**` ...\*\*`, breaking the bold and inserting a literal backslash; adjacent inline-code words get fused. It hit the phase's load-bearing criterion-4 sentence in 01-05 and EVERY automated check still passed (`prettier --check` considers the mangled form correct). Keep `**` globs out of bold spans, and re-read any load-bearing sentence after formatting.
- **Register overshoot (PITFALLS 3) is partly unrecoverable.** Prevention lives in Phase 2 (cap the token vocabulary) and Phase 8 (count the markers); there is no recovery path after a reader forms an impression.
- **Environment constraint: subagents cannot commit under `.github/workflows/`.** This environment's permission classifier denies subagent `git add`/`git commit` on those paths; plan 01-01's 19 deletions had to be staged and committed by the orchestrator from the repo root. Any future plan that adds, modifies or deletes a workflow file needs the same hand-off — budget for it, do not treat it as a failure.
- **Tooling: `gsd-tools` state commands no-op against this STATE.md.** `update-progress`, `record-session` and `advance-plan` match bold `**Progress:**` / `**Stopped At:**`; this file uses the template's plain `Progress:` / `Stopped at:`. STATE.md is correct and the tool's regex is the bug — edit STATE.md directly and do NOT bold the labels. `gsd-tools commit` also word-splits multi-word messages into `git add` pathspecs; use plain `git commit` with explicit `git add <path>`.
- ~~**`update-tocs.yml` will auto-commit over this phase's `docs/DEPLOYMENT.md`.**~~ RESOLVED in plan 01-01 (`11705b6`). Research understated this: `render-cv.yml` was a SECOND unguarded auto-committer (`contents: write`, no repo guard, triggers on `_data/cv.yml`). Both are deleted; only `deploy.yml` retains `contents: write`, scoped to the `gh-pages` publish.
- **`AGENTS.md` / `CLAUDE.md` describe the upstream al-folio demo, not this site.** Baseurl here is empty, the seven integration tests were dropped in `81e55bd`, and `_sass/`/`_layouts/`/`_includes/` are not forbidden here. Trust PROJECT.md and `.planning/codebase/`.

## Session Continuity

Last session: 2026-09-13
Stopped at: Completed 01-05-PLAN.md — the last plan of Phase 1. `design-00-baseline` is annotated on `origin` at `778f68b` (the commit that produced `gh-pages@f7b878d`, i.e. what was actually live), and `docs/DEPLOYMENT.md` (245 lines, 7 sections, no placeholders) is on `origin/main` as `d21f9fd`. `verify.sh --live` went 18 checks / 5 failed -> **18 checks, 0 failed**. All four SAFE requirements are Complete: SAFE-03 closed because `/branches` reports `"protected": false` for `main` and both `/rules/branches/main` and `/rulesets` return `[]`, so no branch rule requires a status check from any of the 19 deleted workflows and no PR can hang on "Expected". The docs push (`.planning/**` + `docs/**`, four files) fired NO deploy — `total_count: 1`, Prettier only, `gh-pages` unmoved at `9d0d929` — a second independent demonstration of the denylist's ignore side. `01-VALIDATION.md`'s Status column is closed: 12 of 13 rows green, `status: complete`.
THAT LAST ITEM IS NOW CLOSED. Validation row `01-05-03` — the human read-through of `docs/DEPLOYMENT.md`'s prose — returned APPROVED on 2026-09-13. §4 was judged "plain and unhedged ... backs it with a demonstrated example rather than a description of intended behavior"; all three §5 failure modes were judged followable at 11pm; §2's Pages values were confirmed against the browser; no placeholders or known-wrong claims. Leaving the row `⬜` for a human was vindicated: the read-through found a defect four automated rows had passed over. §5.1 hedged the path-filter scale limits in both directions when the documented behaviour is one-way; corrected in `b56a9d5` (the reviewer's suggested number, 300, was itself wrong — but the sentence around it was genuinely broken). `01-VALIDATION.md` is 13 of 13 green, `status: complete`. NOTHING IN PHASE 1 IS OUTSTANDING.
Resume file: None

Previous session note (01-03): `verify.sh` exists (14 static + 4 live rows; 4 static FAILs, all SAFE-04, red-by-design until plan 01-05). The guardrails are LIVE: `origin/main` advanced 778f68b -> 2383196 in one fast-forward push, which fired exactly the one deploy predicted (carried by `bin/verify-cname.sh`, the one changed path not in the denylist). That run went green end to end, `prettier.yml` went green, `gh-pages` advanced f7b878d -> 931970f with its CNAME intact, and the live site still returns 200. Next is 01-04 (the `_sass`-only proof commit — the last unproven half of SAFE-01), then 01-05 (tag, Pages/Rules snapshot, docs/DEPLOYMENT.md).

Denylist proven in BOTH directions on real pushes, not read off the YAML:
- `b07bc86` (pure `_sass/**` — the case the OLD allowlist silently excluded, and the reason this phase exists) -> deploy FIRED, green in 69s, gh-pages 931970f -> 9d0d929, marker reached the served CSS ~124s after the push.
- `2383196` (carries `bin/verify-cname.sh`, a non-ignored path) -> deploy FIRED, green, gh-pages f7b878d -> 931970f.
- `5571b60` (pure `.planning/**`) -> deploy did NOT fire. `GET /actions/runs?head_sha=5571b60a…` returns `total_count: 1` and that single run is Prettier, which passed. gh-pages unchanged. Under the OLD allowlist `"**/*.md"` would have matched all three files and rebuilt production for a docs edit.

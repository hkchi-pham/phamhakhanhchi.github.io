---
phase: 01-deployment-guardrails
verified: 2026-09-13T13:59:16Z
status: passed
score: 4/4 must-haves verified
---

# Phase 1: Deployment Guardrails Verification Report

**Phase Goal:** A stylesheet-only change reaches the live site, the custom domain survives the deploy that carries it, design PRs run green, and there is a written way back.
**Verified:** 2026-09-13T13:59:16Z
**Status:** passed
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths (Success Criteria from ROADMAP.md)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | A commit touching only `_sass/_custom.scss` produces a GitHub Actions run and advances `origin/gh-pages` | ✓ VERIFIED | `git show --name-only --format= b07bc86` returns exactly `_sass/_custom.scss`. `GET /actions/runs/34756737328` shows `head_sha=b07bc867...`, `conclusion: success`. `git ls-remote origin refs/heads/gh-pages` is currently `9d0d929c00e7bc0c9955b615724c9401bd29e2df`, matching the documented post-deploy SHA. Independently re-confirmed live (not just re-reading SUMMARY claims). |
| 2 | `curl -sI https://phamhakhanhchi.com` returns 200 after that deploy, and a build missing `_site/CNAME` fails loudly instead of shipping | ✓ VERIFIED | `curl -sI https://phamhakhanhchi.com` returned `HTTP/1.1 200 OK` live. `bin/verify-cname.sh` read in full: exits 1 with `::error title=CNAME missing - refusing to deploy::...` when absent, and `::error title=CNAME wrong - refusing to deploy::...` when empty/wrong-host, normalizing CRLF/whitespace first. `deploy.yml` line 87 (`Verify CNAME before deploying 🔒`) precedes line 93 (`Deploy 🚀`, the `JamesIves/github-pages-deploy-action@v4` step) — the guard genuinely gates the destructive publish rather than following it. |
| 3 | A PR touching `_sass/**`, `_pages/**` or `assets/**` shows no `visual-regression` check in its status list | ✓ VERIFIED | `.github/workflows/visual-regression.yml` does not exist; workflow directory contains exactly `broken-links-site.yml`, `deploy.yml`, `prettier.yml` (plus a non-`.yml` `schedule-posts.txt`, inert to Actions). No workflow re-adds a `pull_request` trigger that could run visual-regression logic. Went further than the stated criterion: independently queried `GET /branches/main` (`"protected": false`), `GET /rules/branches/main` (`[]`), `GET /rulesets` (`[]`) — no branch rule on `main` could hold a stale required check from the deleted workflow, closing the residual caveat noted in 01-VALIDATION.md. |
| 4 | A known-good commit is tagged and the rollback procedure is written down, including the fact that a revert touching only `_sass/**` now redeploys because of criterion 1 | ✓ VERIFIED | `git ls-remote --tags origin` shows `design-00-baseline` -> `778f68bad87b9b2eb5e1c91e0356185c9397ffb0` (annotated tag, dereferences correctly). `git rev-parse design-00-baseline^{}` confirms `778f68b`. `docs/DEPLOYMENT.md` §4 states, unhedged: "A commit whose entire diff sits inside the `_sass` directory... now triggers a deploy and reaches the live site automatically. **Before this phase it did not.**" — backed by the `b07bc86` / `931970f`->`9d0d929` demonstration, not a description of intended behavior. §5 covers all three silent failure modes (path filter, CNAME, PurgeCSS) each with symptom/confirm/fix. |

**Score:** 4/4 truths verified

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `.github/workflows/deploy.yml` | `paths-ignore` denylist, CNAME guard before deploy, live-domain guard after | ✓ VERIFIED | Read in full. `paths-ignore:` list present, no `paths:` allowlist, `_sass` not in the denylist. Guard ordering confirmed by line number and confirmed at runtime via the jobs API (step 10 CNAME, step 11 Deploy, step 12 live-domain, all `success`). |
| `bin/verify-cname.sh` | Single source of truth for the CNAME assertion, fails loudly on missing/empty/wrong content | ✓ VERIFIED | Read in full. Checks existence then normalized content against `phamhakhanhchi.com`; annotates failures with `::error title=...` for Actions UI visibility; called by `deploy.yml` (not duplicated logic). |
| `docs/DEPLOYMENT.md` | Rollback procedure, tag list, three failure modes, Pages settings snapshot | ✓ VERIFIED | 252 lines, all sections present and substantive (not a presence-proxy pass — read end to end). Cites real SHAs, real timings, real API endpoints, and a documented correction (`b56a9d5`) showing the doc was actually reviewed rather than templated. |
| `design-00-baseline` git tag | Known-good pre-redesign commit, tagged on origin | ✓ VERIFIED | `git ls-remote --tags origin` confirms presence and target commit. |
| Pruned `.github/workflows/` | Only workflows capable of passing on this site | ✓ VERIFIED | 3 `.yml` files remain (`deploy.yml`, `prettier.yml`, `broken-links-site.yml`), matching the plan's stated inventory. |
| `.prettierignore` `.planning/**` entry | Prevents planning docs from failing the prettier CI gate | ✓ VERIFIED | Present at line 7; `npx prettier . --check --end-of-line auto` exits 0 (re-run live). |

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|----|--------|---------|
| `deploy.yml` "Verify CNAME" step | `bin/verify-cname.sh` | `run: bash bin/verify-cname.sh _site` | ✓ WIRED | Single source of truth — no duplicated inline logic in the workflow that could drift from the script. |
| `deploy.yml` push trigger | Actual push behavior | `paths-ignore:` evaluated by GitHub Actions | ✓ WIRED | Proven by a real push (`b07bc86`) rather than by reading YAML — this is the strongest possible wiring evidence. |
| CNAME guard step | Deploy step | Step ordering in `deploy.yml` | ✓ WIRED | Line 87 < line 93; confirmed at runtime the CNAME step ran and passed before the Deploy step ran. |
| Live-domain guard step | Deploy step | Step ordering in `deploy.yml` | ✓ WIRED | Line 101 > line 93; confirmed at runtime it ran after Deploy and passed. |
| `docs/DEPLOYMENT.md` §4 claim | `b07bc86` / gh-pages SHA advance | Cited evidence in prose | ✓ WIRED | Independently re-verified: `git ls-remote` and API data match the cited SHAs exactly. |

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|------------|-------------|--------|----------|
| SAFE-01 | 01-02, 01-03, 01-04 | Stylesheet-only commit triggers a production deploy | ✓ SATISFIED | Denylist filter in place; proof commit `b07bc86` fired a real, successful deploy. |
| SAFE-02 | 01-02, 01-03, 01-04 | Production deploy leaves the custom domain resolving; CNAME verified not assumed | ✓ SATISFIED | `bin/verify-cname.sh` gate + live-domain retry gate, both wired and exercised on a real run; `curl -sI` returns 200 live. |
| SAFE-03 | 01-01, 01-03, 01-05 | Design PRs not blocked by `visual-regression.yml` | ✓ SATISFIED | Workflow deleted; independently confirmed no branch rule/ruleset on `main` could substitute a stale requirement. |
| SAFE-04 | 01-05 | Known-good commit tagged; rollback procedure written, including the corrected `_sass`-only-revert-now-redeploys fact | ✓ SATISFIED | Tag verified on origin; `docs/DEPLOYMENT.md` §4 states the corrected fact unhedged with supporting evidence. REQUIREMENTS.md's own 2026-09-13 annotation (line 18) transparently documents that the requirement's original wording is now stale and explains why — this is good practice, not a gap. |

No orphaned requirements: REQUIREMENTS.md's Phase 1 row maps exactly to SAFE-01..04, and all four appear in at least one plan's `requirements:` frontmatter.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| — | — | none found | — | `grep -n -E "TODO|FIXME|XXX|HACK|PLACEHOLDER"` across `deploy.yml`, `bin/verify-cname.sh`, `docs/DEPLOYMENT.md` returned nothing. |

One informational note, not a defect: `.github/workflows/schedule-posts.txt` sits in the workflows directory but is not a `.yml` file, so GitHub Actions does not parse it as a workflow. Harmless; not in scope of this phase's plans.

### Human Verification Required

None outstanding. The four manual-only rows tracked in `01-VALIDATION.md` were all closed during phase execution:
- Actions run step order/success — de-manualled via the unauthenticated Actions API (re-confirmed independently in this verification).
- GitHub Pages settings snapshot — de-manualled via observable-behavior proxies, then browser-confirmed by the human reviewer on 2026-09-13.
- Branch/ruleset check for stale requirements — de-manualled via three independent API endpoints, then browser-confirmed by the human reviewer.
- `docs/DEPLOYMENT.md` prose read-through — genuinely manual, completed 2026-09-13, returned "approved" with one correction (`b56a9d5`) already applied.

### Gaps Summary

None. All four ROADMAP success criteria were independently re-derived against live systems (a real push's commit diff and Actions API result, a live `curl`, the branch-protection/ruleset API, and the tag on `origin`) rather than accepted from SUMMARY claims or the phase's own `verify.sh` harness. The harness's 18 checks all reflect real, currently-true assertions, and its assertions were cross-checked against the four stated criteria rather than taken as sufficient on their own — criterion 3 in particular was strengthened by checking branch protection/rulesets directly via API, which the harness itself does not attempt. No stub code, no orphaned requirements, no unresolved human-verification items.

---

_Verified: 2026-09-13T13:59:16Z_
_Verifier: Claude (gsd-verifier)_

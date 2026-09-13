---
phase: 1
slug: deployment-guardrails
status: approved
nyquist_compliant: true
wave_0_complete: false
created: 2026-09-13
---

# Phase 1 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

**Framework decision: none, deliberately.** This phase's artefacts are workflow YAML, shell guards, git tags and prose. There is no unit-testable code. The repo's only JS "test" is `test/style_contract.js` (a lint, not a test), and `test/visual/*.spec.js` targets `/al-folio/` demo routes whose workflow is deleted in plan 01. **Do not install a test framework and do not add an npm script for `verify.sh`** — a starter-local build/test pipeline is exactly the scope creep this project forbids.

**Environment constraint that shapes everything below:** `ruby`, `bundle` and `gh` are all absent from this machine. There is no local Jekyll build, so no local `_site/` to inspect and no CLI query of workflow-run status. Every build-side assertion is verified either against a synthetic fixture (`bin/verify-cname.sh` against a temp dir), against remote git refs (`git ls-remote`), or against the deployed site (`curl`). Repository *settings* are browser-only.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | None applicable — see above. Do not create one. |
| **Config file** | none |
| **Quick run command** | `npx prettier . --check --end-of-line auto` |
| **Full suite command** | `bash .planning/phases/01-deployment-guardrails/verify.sh` (add `--live` for the network block) |
| **Estimated runtime** | static ~10s (dominated by the Prettier row); `--live` ~20s |

`--end-of-line auto` is not optional locally. `core.autocrlf=true` on this Windows checkout makes a bare `npx prettier . --check` report 99 false failures against 17 real ones, and a bare `npx prettier . --write` would rewrite 99 files with line-ending-only churn. CI runs on Linux with LF and sees only the real failures.

---

## Sampling Rate

- **After every task commit:** `npx prettier . --check --end-of-line auto`, plus the static greps for whatever that commit touched (each is sub-second).
- **After every plan wave:** `bash verify.sh` (static block). The live block is meaningless until plan 04 has pushed the proof commit.
- **Before `/gsd:verify-work`:** `bash verify.sh --live` fully green, plus all four manual-only rows below signed off.
- **Max feedback latency:** 10s static. The live rows are inherently slower — `gh-pages` advance and CDN turnover are polled over ~10 minutes in plan 04; that latency is the system's, not the harness's.

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 01-01-01 | 01 | 1 | SAFE-03 | static | `npx prettier . --check --end-of-line auto` ; `grep -q '^\.planning/\*\*$' .prettierignore` | ✅ | ⬜ pending |
| 01-01-02 | 01 | 1 | SAFE-03 | static | workflow inventory equals `broken-links-site.yml deploy.yml prettier.yml` ; `test ! -f .github/workflows/visual-regression.yml` | ✅ | ⬜ pending |
| 01-02-01 | 02 | 1 | SAFE-02 | unit (shell) | four-state fixture: `bin/verify-cname.sh` on good/empty/wrong/absent `_site` → exit 0/1/1/1 | ❌ W0 (task creates it) | ⬜ pending |
| 01-02-02 | 02 | 1 | SAFE-01, SAFE-02 | static | `grep -q 'paths-ignore:'` **and** `! grep -qE '^\s+paths:'` **and** `! grep -qE '^\s+- "?_sass'` on `deploy.yml` ; CNAME-step line < deploy-action line < live-check line | ✅ | ⬜ pending |
| 01-03-01 | 03 | 2 | SAFE-01..04 | harness | `bash verify.sh` runs and tallies; SAFE-01/02/03 rows green, SAFE-04 rows red-by-design | ❌ W0 (task creates it) | ⬜ pending |
| 01-03-02 | 03 | 2 | SAFE-01, SAFE-03 | integration (remote) | `git log main..origin/main` empty ; `git show origin/main:.github/workflows/deploy.yml \| grep -q paths-ignore` ; live 200 | ✅ | ⬜ pending |
| 01-04-01 | 04 | 3 | SAFE-01 | integration (git) | `git show --name-only --format= HEAD` lists exactly `_sass/_custom.scss` | ✅ | ⬜ pending |
| 01-04-02 | 04 | 3 | SAFE-01, SAFE-02 | integration (live) | `git ls-remote origin refs/heads/gh-pages` differs from recorded before-SHA ; `curl -s ".../main.css?cb=$(date +%s)" \| grep -c -- "--deploy-proof"` > 0 ; `curl -w '%{http_code}' https://phamhakhanhchi.com` = 200 | ✅ | ⬜ pending |
| 01-04-03 | 04 | 3 | SAFE-01, SAFE-02 | **manual-only** | Actions run shows both guard steps, correct order, green; site visually unchanged | n/a | ⬜ pending |
| 01-05-00 | 05 | 4 | SAFE-03 | **manual-only** | Settings → Pages and Settings → Rules read in a browser; stale required checks removed | n/a | ⬜ pending |
| 01-05-01 | 05 | 4 | SAFE-04 | integration (remote) | `git ls-remote --tags origin \| grep -q design-00-baseline` ; tag resolves to `778f68b` | ✅ | ⬜ pending |
| 01-05-02 | 05 | 4 | SAFE-04 | static | `docs/DEPLOYMENT.md` exists and greps for `path filter`, `CNAME`, `PurgeCSS`, `design-00-baseline`, `verify.sh`, `Enforce HTTPS`; ≥70 non-blank lines; no placeholders | ❌ W0 (task creates it) | ⬜ pending |
| 01-05-03 | 05 | 4 | SAFE-04 | **manual-only** | A human reads the doc and confirms the criterion-4 sentence and the three failure-mode entries are actually usable | n/a | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

**Sampling continuity check:** no three consecutive tasks lack an `<automated>` verify. The three manual-only tasks (01-04-03, 01-05-00, 01-05-03) are each preceded and/or followed by an automated one.

---

## Wave 0 Requirements

The `❌ W0` rows above are all created by the very task that first needs them; there is no separate Wave 0 plan, because every gap is a file this phase authors anyway.

- [ ] `bin/verify-cname.sh` — plan 02 task 1. The CNAME assertion as a **single** source of truth, called by `deploy.yml` and exercised by the four-state fixture, so the workflow and the test cannot drift.
- [ ] `.planning/phases/01-deployment-guardrails/verify.sh` — plan 03 task 1. Composes every automatable row above; `--live` gates the network block so it is runnable before the proof push exists.
- [ ] `.prettierignore` entry `.planning/**` — plan 01 task 1. Without it the "CI stays green" row fails from the phase's first push, and every future GSD phase re-breaks it.
- [ ] `docs/DEPLOYMENT.md` — plan 05 task 2. Target of the SAFE-04 static rows, which are red-by-design until then.
- [ ] **No framework install.** Do not add one.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| A GitHub Actions run exists for the `_sass`-only commit, with the CNAME gate above the deploy step and the live-domain gate below it, both green | SAFE-01, SAFE-02 | `gh` is not installed and the REST API needs auth. `git ls-remote` proves `gh-pages` advanced (a stronger fact) but cannot show the step list. | Open the repo's Actions tab, find the newest **Deploy site** run, confirm its trigger commit is the `style(01-04):` one, and that **Verify CNAME before deploying 🔒** and **Verify live domain responds 🌐** both appear and passed, in that order relative to **Deploy 🚀**. Checkpoint in plan 04. |
| GitHub Pages settings: source branch/folder, custom domain, DNS check, Enforce HTTPS | SAFE-02 | Repository settings are not in the git tree and `gh` is absent. Read-only by decision — verify and record, do not change. | Settings → Pages. Transcribe every value into `docs/DEPLOYMENT.md` §2. Checkpoint in plan 05. |
| No branch rule requires a status check from a deleted workflow | SAFE-03 | Required checks are configured in repo settings, not in workflow files — deleting the file does not clear them. A stale requirement leaves PRs stuck on "Expected", which is worse than a red X. | Settings → Rules → Rulesets and Settings → Branches. If `visual-regression`, `unit-tests` or `style-contract` is listed as required on `main`, remove it. "None" is the expected and acceptable answer. Checkpoint in plan 05. |
| `docs/DEPLOYMENT.md` actually states that a `_sass`-only revert now redeploys (and that it did not before) | SAFE-04 | Prose claim. `grep -q "_sass"` proves the word appears, not that the sentence says the right thing — it is a weak proxy and must not be treated as passing. | A human reads §4 end to end and confirms the sentence is present and unhedged, and that each of the three failure modes has a usable symptom/confirm/fix. Checkpoint in plan 05. |

**Deliberately not tested by breaking production:** the CNAME guard is proven by running `bin/verify-cname.sh` against a synthetic `_site` in four states, never by damaging the real `CNAME`. The domain is currently healthy (`origin/gh-pages:CNAME` is byte-identical to `main:CNAME`) and must stay that way — the guard is regression insurance, not a repair.

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or a named Wave 0 dependency
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references (`bin/verify-cname.sh`, `verify.sh`, `.prettierignore` line, `docs/DEPLOYMENT.md`)
- [ ] No watch-mode flags
- [ ] Feedback latency < 10s for the static suite
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** approved 2026-09-13 (planning); manual rows to be ticked at plan 05 completion.

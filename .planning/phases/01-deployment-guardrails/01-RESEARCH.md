# Phase 1: Deployment Guardrails - Research

**Researched:** 2026-09-13
**Domain:** GitHub Actions workflow triggers, GitHub Pages custom-domain publishing, CI pruning, git rollback procedure
**Confidence:** HIGH (every claim below is either from official GitHub docs, from the deploy action's own source, or measured directly against this repo and the live domain)

<user_constraints>

## User Constraints (from CONTEXT.md)

### Locked Decisions

**Deploy trigger scope**

- **Invert `deploy.yml`'s path filter from an allowlist to a denylist.** Every push to `main` deploys except explicitly excluded paths. Do not just bolt `_sass/**` and `**.scss` onto the existing allowlist — the allowlist shape is the bug, and it recurs for the next unlisted file type (fonts, `.json` data, image assets).
- Exclusions to carve out: `docs/`, `README.md`, `.planning/**`, `lighthouse_results/**`, `AGENTS.md`, `CLAUDE.md`, and agent/tooling-only workflow files.
- **Changes land as direct pushes to `main`.** Solo project, no reviewer, no branch-per-phase. Criterion 3 is therefore about removing a latent landmine, not unblocking a workflow in active use.
- **Proof commit for criterion 1: a traceable no-op marker.** Add a dated comment _plus_ one harmless verifiable rule to `_sass/_custom.scss` (e.g. a custom property that survives to the served CSS). Then grep the stylesheet actually served from the live domain to prove the change travelled the full path — build, PurgeCSS, deploy — not merely that a workflow ran green. A comment-only change is insufficient: Sass strips `//` comments.
- **Failure visibility: GitHub's default failure email, plus deliberately self-explaining step names.** Guard steps must name the problem in the Actions failure line (e.g. "CNAME missing — refusing to deploy", "live domain not responding"). No new notification services or secrets.

**CNAME safety net**

- **The guard is a pre-deploy step in `deploy.yml`**, positioned after the PurgeCSS step and before the `JamesIves/github-pages-deploy-action@v4` step. It must fail the job so nothing reaches `gh-pages` — the check has to precede the destructive branch replacement, not follow it.
- **Assertion: `_site/CNAME` exists AND its contents are exactly `phamhakhanhchi.com`.** An empty, truncated or stale-hostname CNAME breaks the domain just as completely as a missing one.
- **Post-deploy live check: curl `https://phamhakhanhchi.com` with retries** (poll a few times across roughly 60s) and **fail the run** if it never returns 200. Retries exist to absorb GitHub Pages publish lag so the check does not cry wolf; a genuine outage still goes red.
- **GitHub Pages repo settings: verify and record, do not change.** Confirm the custom domain and "Enforce HTTPS" in Settings → Pages and write the current state into the rollback doc. Removes the unknown without introducing a change this phase has to justify.

**Inherited CI pruning**

- **Delete `visual-regression.yml`.** Its specs target `/al-folio/` routes and v0.16.3 demo content this site does not have; it can never pass. Deleting makes criterion 3 structurally true — no filter left to misconfigure. TEST-01 (retargeted specs) is already deferred out of this roadmap.
- **Delete `unit-tests.yml`.** It runs al-folio's `lint:style-contract`, which fails CI when `_sass/` exists. This is a user site where shadowing gem files is explicitly legal, so the contract is wrong here and would red-X every commit of the design pass.
- **Disable both auto-committing workflows: `update-tocs.yml` and `star-history.yml`.** Bot commits to `main` mid-pass cause non-fast-forward rejections on the next push, and under the new denylist filter each bot commit would also trigger a full deploy.
- **Prune everything else that tests upstream al-folio rather than this site**: `upgrade-check.yml`, `render-cv.yml`, `docker-slim.yml`, `deploy-image.yml`, `deploy-docker-tag.yml`, `broken-links.yml`, `lighthouse-badger.yml`, `release.yml`, `update-screenshots.yml`, `copilot-setup-steps.yml`, `prettier-html.yml`, `prettier-comment-on-pr.yml`, `axe.yml`.
- **Keep `prettier.yml`** — the one inherited check that genuinely applies. It formats the `_sass` files this milestone will fill, and a red X is always a real one-command fix (`npx prettier . --write`).
- **Keep `broken-links-site.yml`** — checks the deployed site, useful for Phase 8.
- **Delete `codeql.yml` and `update-citations.yml`.** CodeQL scanning a static Jekyll site is noise; `update-citations` needs the `scholarly` package and a Scholar ID that are not wired up.
- **Standard to hold to:** after pruning, a green tick must mean something. Anything left running should be capable of passing on this site.

**Rollback procedure**

- **Mechanism: `git revert` on `main`.** Revert the bad commit and push; because of the denylist filter, a revert touching only `_sass/**` now redeploys automatically — which is precisely the fact criterion 4 requires be written down, and which is false today. `gh-pages` is never hand-edited.
- **Tagging: a tag per phase completion**, starting with a pre-redesign baseline tag on today's known-good commit. Scheme along the lines of `design-00-baseline`, `design-02-tokens`. Every roadmap phase boundary is already defined as a shippable state, so rollback granularity matches how the work is structured.
- **Doc location: a new `docs/DEPLOYMENT.md`.** Site-specific operations doc; survives the milestone, not buried in `.planning/`, and distinct from the inherited al-folio docs around it.
- **Doc scope: commands + the three silent failure modes.** The revert recipe, the tag list and what each tag means, plus short how-to-recognise entries for: (1) change never deployed — path filter; (2) domain dropped — CNAME; (3) CSS rule vanished — PurgeCSS. Also record the Pages settings snapshot from the CNAME work.

### Claude's Discretion

- Exact denylist entry syntax and how the push/`pull_request` path lists are kept in sync (or whether the now-unused `pull_request` build path is retained at all).
- Shell implementation of the CNAME assertion and the retry/backoff shape of the live curl.
- Whether pruned workflows are deleted outright or stripped to `workflow_dispatch` — decided per file, with deletion as the default given "a green tick must mean something".
- Exact wording of step names, tag message format, and `docs/DEPLOYMENT.md` structure.
- Ordering of guardrail commits relative to the proof push, so long as the proof push genuinely exercises the fixed filter.

### Deferred Ideas (OUT OF SCOPE)

- **Retargeting visual-regression specs at this site's own pages** — already deferred out of this roadmap as TEST-01. Deleting the workflow does not foreclose it; a future milestone would write new specs against real pages.
- **Automated contrast/accessibility gating in CI** — `axe.yml` is dispatch-only and `lighthouse-badger.yml` measures the upstream demo. Phase 8 handles this by hand deliberately; building a real automated gate is a separate concern.
- **PurgeCSS safelist hardening** — Phase 8 criterion 3 inspects the served CSS by hand. Turning that into a CI check is out of scope here; Phase 1 only documents the failure mode.

</user_constraints>

<phase_requirements>

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| SAFE-01 | A commit that changes only `_sass/**` triggers a production deploy. | Finding A1 (the denylist **must** be `paths-ignore:`, not inverted `paths:` — GitHub rejects an all-negative `paths` list). Pattern 1 gives the exact replacement block. Finding A2 explains why the bug has been invisible so far. |
| SAFE-02 | A production deploy leaves `phamhakhanhchi.com` resolving; `CNAME` appears in `_site/` and survives the deploy action. | Findings B1-B4 (current state is verified-good, not broken; the action's real clean semantics; exact byte content of both CNAME blobs). Patterns 2 and 3 give the pre-deploy assertion and the post-deploy live check. |
| SAFE-03 | Design PRs are not blocked by `visual-regression.yml`. | Finding C1 (full trigger audit of all 22 workflows, with the five that are already inert via `if: github.repository == ...`), Finding C2 (`unit-tests.yml` already passes — CONTEXT's stated reason is stale), Finding C3 (`update-tocs.yml` is the only live auto-committer and `docs/DEPLOYMENT.md` trips it). Pattern 5 is the prune list with a delete/keep decision per file. |
| SAFE-04 | A known-good commit is tagged and the rollback procedure is written down, including the fact that a `_sass`-only revert now redeploys. | Finding D1 (`origin/main` is at `778f68b`, which is what is live — that is the baseline commit), Finding D2 (tag pushes do not trigger `deploy.yml`), Pattern 6 (tag + revert recipe), Pattern 7 (`docs/DEPLOYMENT.md` skeleton covering the three silent failure modes). |

</phase_requirements>

## Summary

This phase is almost entirely YAML, shell and prose — there is no library to choose and no framework to learn. The research value is therefore not "what stack" but **"what is actually true in this repo right now"**, because several premises carried forward from REQUIREMENTS.md and STATE.md have gone stale since they were written, and one locked decision cannot be implemented the way it is phrased.

The single blocking technical fact: **GitHub Actions does not allow a `paths:` list made only of `!` exclusions.** The official syntax reference states "If you define a path with the `!` character, you must also define at least one path without the `!` character. If you only want to exclude paths, use `paths-ignore` instead." The denylist decision is correct; its implementation is `paths-ignore:`, and `paths` and `paths-ignore` are mutually exclusive within the same event. Anything that tries to keep the existing `paths:` key and just negate its entries will silently never fire.

The second cluster of findings is about CNAME, and it is good news that changes the shape of the work. Three real deploys ran on 2026-09-11 (`599d45d`, `0d1b92e`, `f7b878d`), all after `CNAME` reached `main`, and `origin/gh-pages:CNAME` is byte-identical to `main:CNAME` today (`phamhakhanhchi.com\n`, blob `e4f56c9`). The live domain returns `200`. So SAFE-02 is not repairing a broken pipeline — it is installing a regression guard on a pipeline that currently works. Separately, reading the deploy action's own source shows it already `--exclude`s `CNAME` from rsync's `--delete` **when the source folder lacks one**, so "CNAME vanished from `_site`" is a smaller hazard than assumed; the real uncovered hazard is a *present-but-wrong* `_site/CNAME` overwriting the good one, which is exactly the assertion CONTEXT already specifies.

The third cluster is about landmines this phase will step on while doing its own work: `prettier.yml` runs on **every** push to `main` with no path filter, 17 `.planning/**` files currently fail Prettier, and there are **10 unpushed commits** on local `main` — so the first push of this phase goes red unless `.planning/**` is added to `.prettierignore`. And `update-tocs.yml` triggers on `docs/*.md`, which is precisely where this phase's `docs/DEPLOYMENT.md` lands, and it auto-commits to `main`. Order of operations matters.

**Primary recommendation:** Replace `deploy.yml`'s two `paths:` blocks with a single `paths-ignore:` denylist (dropping the `pull_request` trigger entirely, since the deploy step already skips PRs and the project pushes direct to `main`); add a fail-fast `_site/CNAME` assertion between "Purge unused CSS" and "Deploy" and a retrying live-domain check after it, both using `::error::` annotations so the failure is legible without opening logs; prune workflows *before* creating `docs/DEPLOYMENT.md` so `update-tocs.yml` is already gone; add `.planning/**` to `.prettierignore` in the same pass; then tag `778f68b` as `design-00-baseline` and make the proof push a `:root` custom property in `_sass/_custom.scss`, verified by curling the served CSS with a cache-busting query string.

## Ground Truth: what this repo actually looks like today

Measured on 2026-09-13, after `git fetch origin --prune --tags`.

| Fact | Value | How verified |
|------|-------|--------------|
| `origin/main` HEAD | `778f68b` "Stop the CV page linking to a PDF that does not exist" | `git log -3 origin/main` |
| Local `main` HEAD | `3f2b9ff` — **10 unpushed commits**, all `.planning/**`, 18 files, 5011 insertions | `git rev-list --count origin/main..main` |
| `origin/gh-pages` HEAD | `f7b878d` "Deploying ... from ...@778f68b" (2026-09-11 17:02 UTC) | `git log origin/gh-pages` |
| Deploys since `CNAME` landed on `main` | **three** — `599d45d`, `0d1b92e`, `f7b878d`, all 2026-09-11 | `git log --date=iso origin/gh-pages` |
| `main:CNAME` | blob `e4f56c9`, bytes `phamhakhanhchi.com\n` (trailing newline present) | `od -c CNAME` |
| `origin/gh-pages:CNAME` | blob `e4f56c9` — **identical** | `git cat-file -p origin/gh-pages:CNAME \| od -c` |
| Live domain | `HTTP/1.1 200 OK`, `Server: GitHub.com`, `Last-Modified: Fri, 11 Sep 2026 17:03:24 GMT` | `curl -sI https://phamhakhanhchi.com` |
| Served CSS | `https://phamhakhanhchi.com/assets/css/main.css` — contains `:root{...--global-bg-color: #ffffff...}` and `.entry-year` | `curl -s ... \| head -c 300` |
| Served CSS caching | `Cache-Control: max-age=600`, CDN `x-proxy-cache` header present | response headers |
| Tags | **none exist** | `git tag -l` |
| `_sass/` | one file, `_custom.scss`, 74 lines | `ls -la _sass/` |
| Compilation path | `assets/css/main.scss` ends with `@use "custom";` -> `_site/assets/css/main.css` | file read |
| `.nojekyll` | absent from repo root **and** from `gh-pages` | `git ls-tree origin/gh-pages -- .nojekyll` -> empty |
| `_config.yml` `exclude:` | single key at line 228; `CNAME` is **not** listed -> Jekyll copies it | `grep -n "^exclude:" _config.yml` |
| `_config.yml` `keep_files:` | `[CNAME, .nojekyll]` at line 249 | file read |
| `_config.yml` `baseurl:` | **blank** (line 23); `url: https://phamhakhanhchi.com` | file read |
| Workflow count | 22 `.yml` files in `.github/workflows/` | `ls .github/workflows/` |
| Local toolchain | node v24.11.1, npm 11.6.2 present; **`ruby`, `bundle`, `gh` all absent** | `ruby -v`, `bundle -v`, `gh --version` |
| `core.autocrlf` | `true` — files on disk are CRLF | `git config --get core.autocrlf` |

### Finding A1 — the denylist must be `paths-ignore:` (HIGH)

`deploy.yml` currently uses `paths:` with a mixed allow/deny list (positives like `"**/*.md"` plus negatives like `"!README.md"`). The locked decision is to invert it. GitHub's workflow-syntax reference is explicit on three points that constrain the implementation:

1. "You cannot use both the `paths` and `paths-ignore` filters for the same event in a workflow."
2. "If you define a path with the `!` character, you must also define at least one path without the `!` character. If you only want to exclude paths, use `paths-ignore` instead."
3. Order matters within a mixed list: "A matching negative pattern (prefixed with `!`) after a positive match will exclude the path. A matching positive pattern after a negative match will include the path again."

And the decision rule for `paths-ignore`: "When **all** the path names match patterns in `paths-ignore`, the workflow will not run." So a push touching `.planning/FOO.md` **and** `_sass/_custom.scss` runs, because not every changed file is ignored. That is the desired behaviour.

Two documented scale limits worth recording in `docs/DEPLOYMENT.md`: a diff of **more than 3,000 files** may not match, and a push of **more than 1,000 commits** bypasses path filtering entirely. Neither is reachable on this repo, but they are the fourth silent failure mode of path filters.

### Finding A2 — why SAFE-01 has been invisible so far (HIGH)

`.entry-year` (defined only in `_sass/_custom.scss`) **is** present in the live CSS. That is not a contradiction: the commits that introduced those rules also touched `_pages/*.md`, which matched `"**/*.md"` in the allowlist, and a triggered build compiles the whole site including `_sass`. The bug fires only when a commit touches **nothing but** `_sass/**` — which is precisely every commit of Phases 2-7. The planner should not be surprised to find `_sass` styles already live; that does not weaken SAFE-01.

Corollary for the proof push: it must be a commit whose **entire** diff is `_sass/_custom.scss`. Adding the marker alongside any `.md` or `.yml` change proves nothing.

### Finding A3 — `.planning/**` currently triggers deploys (HIGH)

`"**/*.md"` in the present allowlist matches `.planning/**/*.md`. The 10 unpushed planning commits would each fire a full production build under today's filter. Under the new `paths-ignore` denylist with `.planning/**` listed, they will not. This is a real, immediate improvement, and it means the first push of this phase should sequence the `deploy.yml` fix **before or with** the planning-docs push if wasted builds matter.

### Finding B1 — CNAME is currently healthy; the premise in STATE.md is stale (HIGH)

STATE.md says "No deploy has run since `CNAME` reached `main`." That was true when written and is now false: `599d45d`, `0d1b92e` and `f7b878d` all deployed on 2026-09-11, after `a5dd00f` put `CNAME` on `main`, and `origin/gh-pages:CNAME` is byte-identical to `main:CNAME`. This is **empirical proof that Jekyll copies `CNAME` into `_site/`** under this `_config.yml`, which is the fact the guard was meant to establish. Report this to the user: the domain is not currently at risk; the guard is regression insurance.

### Finding B2 — what `JamesIves/github-pages-deploy-action@v4`'s `clean` really does (HIGH)

Read from the action's own `src/git.ts`. The deploy is an `rsync -q -av --checksum --progress ... --delete <excludes>` into a checkout of the target branch. Exclusions:

- **Always excluded:** `.ssh`, `.git`, `.github` (unless `include-github-folder` is set), and the temp deployment dir.
- **Conditionally excluded:** `CNAME` and `.nojekyll` — but only when the file is **absent from the source folder**:

```ts
!fs.existsSync(`${action.folderPath}/${DefaultExcludedFiles.CNAME}`)
  ? `--exclude ${DefaultExcludedFiles.CNAME}`
  : ''
```

Read the direction carefully. If `_site/CNAME` does **not** exist, the action adds `--exclude CNAME`, so `--delete` will **not** remove the CNAME already sitting on `gh-pages`. The README states the same thing in prose: "If you're using a custom domain and require a `CNAME` file ... you can safely commit these files directly into the deployment branch without them being overridden after each deployment."

**Consequence for the threat model.** The scenario CONTEXT is most worried about — `_site/CNAME` missing — is already mitigated by the action for the *branch* file. What is **not** mitigated:

1. `_site/CNAME` present but **empty, truncated, or the wrong hostname** — rsync happily overwrites the good file on `gh-pages` with the bad one. This is the live, uncovered hazard, and it is exactly what CONTEXT's "exists AND contents are exactly `phamhakhanhchi.com`" assertion catches.
2. A future switch to `single-commit: true` (which "will also cause any existing history to be wiped") or a branch recreation, either of which loses the branch-side file.
3. Drift between the repo `CNAME`, the branch `CNAME`, and the **Settings → Pages** custom-domain value, which is a separate piece of state.

State this honestly in the plan rather than restating "a CNAME-less deploy silently kills the domain" — the guard is still worth having (defence in depth, catches the wrong-content case, and documents the invariant), but the reasoning should match reality.

### Finding B3 — the assertion must tolerate a trailing newline (HIGH)

`main:CNAME` is `phamhakhanhchi.com\n` — 19 bytes with a trailing LF. A naive `[ "$(cat _site/CNAME)" = "phamhakhanhchi.com" ]` happens to work in bash (command substitution strips trailing newlines), but `grep -qx` against a file with CRLF, or a `cmp` against a heredoc, will not. Normalise explicitly: `tr -d '[:space:]' < _site/CNAME`.

### Finding B4 — the post-deploy curl proves "domain resolving", not "new content live" (HIGH)

Because the site is already up, `curl -sI https://phamhakhanhchi.com` returns 200 the instant the job reaches it, before GitHub's "pages build and deployment" has republished. That is fine for SAFE-02 as worded ("leaves `phamhakhanhchi.com` resolving") and is the right scope for a hard-failing gate — it catches DNS loss, custom-domain unset, and Pages-disabled, without flaking on publish lag.

It does **not** prove criterion 1's "the change travelled the full path". That needs a separate content grep of `/assets/css/main.css`, and that grep faces a real obstacle: the served CSS carries `Cache-Control: max-age=600` behind a caching proxy (`x-proxy-cache` header observed). Use a cache-busting query string and a retry window of several minutes.

### Finding C1 — full workflow trigger audit, with the five already-inert files (HIGH)

All 22 files in `.github/workflows/`, with what actually fires on this repo:

| File | Trigger | Fires here? | Note |
|------|---------|-------------|------|
| `deploy.yml` | push+PR `main`, allowlist `paths`, `workflow_dispatch` | **yes** | the target of SAFE-01/02 |
| `prettier.yml` | push+PR `main`, **no path filter** | **yes, on every push** | CONTEXT keeps it. See Finding C4 |
| `broken-links-site.yml` | `workflow_run` on "Deploy site" completed | **yes, after every deploy** | CONTEXT keeps it |
| `codeql.yml` | push+PR `main`, weekly cron | **yes** | CONTEXT deletes it |
| `unit-tests.yml` | push+PR, paths incl. `_config.yml`, `assets/**` | **yes — and currently passes** | see Finding C2 |
| `visual-regression.yml` | PR `main`/`master`/`v1.0-dev` + push `v1.0-dev`; paths incl. `_pages/**`, `assets/**` | **on PRs only** | can never pass; delete |
| `upgrade-check.yml` | push+PR, paths incl. `_config.yml`, `_pages/**`, `assets/**` | **yes** | needs `bundle exec al-folio`; delete |
| `update-tocs.yml` | push `main`, paths `*.md` + `docs/*.md`; **auto-commits to main** | **yes — and this phase trips it** | see Finding C3 |
| `render-cv.yml` | push `main`, paths `_data/cv.yml`, `assets/rendercv/*` | yes if those change | needs `rendercv[full]`; delete |
| `copilot-setup-steps.yml` | push/PR on its own file only | effectively never | delete |
| `deploy-docker-tag.yml` | push tag `v*` + paths | **would fire on `v*` tags** | tags here are `design-*`, so no collision — but delete anyway |
| `star-history.yml` | push `main` (`paths-ignore`), weekly cron | job is `if: github.repository == 'alshedivat/al-folio'` -> **skipped** | see Finding C5 |
| `broken-links.yml` | push `main` + paths | job `if: github.repository == 'alshedivat/al-folio'` -> **skipped** | |
| `deploy-image.yml` | push `main` + paths | job `if: github.repository_owner == 'alshedivat'` -> **skipped** | |
| `release.yml` | `workflow_dispatch` | job repo-guarded | |
| `update-screenshots.yml` | `workflow_dispatch` | job repo-guarded | |
| `axe.yml` | `workflow_dispatch` only | manual only | |
| `lighthouse-badger.yml` | `workflow_dispatch` only | manual only | |
| `prettier-html.yml` | `workflow_dispatch` only | manual only | |
| `prettier-comment-on-pr.yml` | `repository_dispatch` type `prettier-failed-on-pr` | only if dispatched | |
| `update-citations.yml` | cron Mon/Wed/Fri, `workflow_dispatch` | **yes, three times a week** | needs `scholarly` + Scholar ID; delete |
| `docker-slim.yml` | push `main` on its own file, `workflow_run`, dispatch | rarely | delete |

(`schedule-posts.txt` is a `.txt`, not a workflow — GitHub ignores it.)

### Finding C2 — `unit-tests.yml` already passes; CONTEXT's reason for deleting it is stale (HIGH)

CONTEXT says it "fails CI when `_sass/` exists". It does not, any more. Commit `81e55bd` ("Drop the template's integration tests from CI") already commented out the forbidden-path block in `test/style_contract.js`, with a comment explaining exactly the reasoning CONTEXT gives:

```js
// DISABLED FOR THIS SITE.
// ... a user site MAY shadow gem-owned files ...
// for (const forbiddenPath of ["_includes", "_layouts", "_sass", ...]) { ... }
```

What the contract still asserts: `theme: al_folio_core`, five plugins present in `_config.yml`, SRI hashes for `fontawesome`/`academicons`/`scholar-icons`, `third_party_libraries.tikzjax`/`tocbot` present, and `al_math` pinned to `= x.y.z` in the `Gemfile`. **None of those are things this milestone changes**, so the workflow would stay green through Phases 2-8.

Deleting it is still defensible — it guards the *upstream thin-starter boundary*, which is not a property this site cares about, so its green tick means nothing here, which is CONTEXT's own standard. But the plan should say that, not repeat the stale claim. Flag this to the user; it is a decision worth re-confirming rather than silently carrying forward a wrong premise.

### Finding C3 — `update-tocs.yml` is the only live auto-committer, and `docs/DEPLOYMENT.md` trips it (HIGH)

`update-tocs.yml` triggers on `paths: ["*.md", "docs/*.md"]` with `permissions: contents: write`, downloads `gh-md-toc`, inserts a TOC into changed markdown, runs `npm ci` + `npx prettier --write`, and auto-commits to `main`. It carries **no repository guard**. `docs/DEPLOYMENT.md` — this phase's own deliverable — matches `docs/*.md` exactly.

Note GitHub path-filter globbing: `*` does not cross `/`, so `*.md` is root-level only and `docs/*.md` is one level deep. `.planning/**/*.md` does **not** match, so the planning docs are safe from it.

**Ordering constraint for the plan: remove/disable `update-tocs.yml` in a commit that lands before the commit creating `docs/DEPLOYMENT.md`.** Otherwise the bot rewrites the new doc and pushes to `main`, and the next local push is rejected non-fast-forward — the exact failure CONTEXT wanted to avoid.

### Finding C4 — the Prettier landmine this phase will detonate (HIGH)

`prettier.yml` runs on **every** push to `main` with no path filter. Measured with `npx prettier . --check --end-of-line auto`: **17 files fail, and all 17 are under `.planning/`** —

```
.planning/codebase/{ARCHITECTURE,CONCERNS,CONVENTIONS,INTEGRATIONS,STACK,STRUCTURE,TESTING}.md
.planning/phases/01-deployment-guardrails/01-CONTEXT.md
.planning/{PROJECT,REQUIREMENTS,ROADMAP,STATE}.md
.planning/research/{ARCHITECTURE,FEATURES,PITFALLS,STACK,SUMMARY}.md
```

`.prettierignore` does not exclude `.planning/`. Those files are in the 10 unpushed commits. **The first `git push` of this phase turns `prettier.yml` red**, and will do so again on every future GSD phase that writes planning docs.

Recommended fix, in this phase, as one line in `.prettierignore`:

```
.planning/**
```

This is squarely within the phase's own standard ("a green tick must mean something") and is cheaper and more durable than reformatting agent-authored docs forever. The alternative — `npx prettier .planning --write` — must be re-run every phase and will churn the docs.

### Finding C5 — five workflows are already inert; do not over-claim (MEDIUM-HIGH)

`star-history.yml`, `broken-links.yml`, `deploy-image.yml`, `release.yml` and `update-screenshots.yml` all carry a job-level `if: github.repository == 'alshedivat/al-folio'` (or `repository_owner`). Their jobs are **skipped** on this fork — they still create a workflow *run* entry (which renders as a grey/green skipped check), but they cannot commit, build or fail. `star-history.yml` in particular is described in CONTEXT as an auto-committing risk; it is not, because of that guard. Deleting them is still right for noise reduction, but the plan's justification should be "noise", not "danger".

### Finding D1 — the baseline commit is `778f68b` (HIGH)

`origin/gh-pages@f7b878d` says `Deploying to gh-pages from ...@778f68b`, and `778f68b` is `origin/main` HEAD. So **`778f68b` is the commit that produced what is live right now** — it is the known-good commit SAFE-04 asks for, and it is a stronger choice than "local HEAD" (which is 10 unpushed doc commits ahead and has never been built).

### Finding D2 — pushing a tag does not trigger `deploy.yml` (HIGH)

`deploy.yml`'s `on.push` has `branches:` only, no `tags:`, so `git push origin design-00-baseline` raises no deploy. One nearby trap: `deploy-docker-tag.yml` **does** fire on `push: tags: ["v*"]`. The `design-*` scheme avoids it, and CONTEXT deletes that workflow anyway — but do not change the tag scheme to `v*` without re-checking.

### Finding E1 — `.nojekyll` is missing from `gh-pages` (MEDIUM — observation, not phase scope)

Neither the repo root nor `gh-pages` contains `.nojekyll`, so GitHub runs its own Jekyll pass over the published branch and drops underscore-prefixed directories. Verified: `gh-pages` contains `_pages/dropdown/index.html`, and `https://phamhakhanhchi.com/_pages/dropdown/` returns **404**. Nothing this site links to lives under an underscore path (the seven real pages are at `/academics`, `/research`, ... and all resolve), so this is currently harmless. A one-line `.nojekyll` at the repo root would close it (it is already in `keep_files:`). **Out of this phase's scope** — raise it as a note, not a task, unless the user wants it.

## Standard Stack

There is no package to install. The "stack" is the set of platform primitives this phase composes.

### Core

| Tool | Version | Purpose | Why standard |
|------|---------|---------|--------------|
| GitHub Actions `on.push.paths-ignore` | platform | The denylist trigger | The **only** supported way to express "run on everything except X"; `paths:` cannot be all-negative |
| `JamesIves/github-pages-deploy-action` | `@v4` (already pinned in `deploy.yml`) | Publishes `_site` to `gh-pages` | Already in use; do not change the action or its version in this phase |
| GitHub workflow commands (`::error::`, `$GITHUB_STEP_SUMMARY`) | platform | Self-explaining failures in the Actions UI without opening logs | Satisfies the locked "failure visibility" decision with no new services or secrets |
| `bash` + `curl` on `ubuntu-latest` | preinstalled | CNAME assertion and live-domain poll | No action dependency, no supply-chain surface, fully readable |
| `git tag -a` / `git revert` | git | Rollback mechanism | Locked decision; `gh-pages` is never hand-edited |

### Supporting

| Tool | Purpose | When to use |
|------|---------|-------------|
| `.prettierignore` | Add `.planning/**` | Now — otherwise `prettier.yml` reds out on this phase's own first push (Finding C4) |
| `concurrency:` block on `deploy.yml` | Serialise deploys | Recommended: two pushes close together currently race to force-push `gh-pages` |
| `curl -s -o /dev/null -w '%{http_code}'` | HTTP status without body | The live check; avoid `--retry`, which does not retry non-2xx statuses without `--fail --retry-all-errors` |

### Alternatives Considered

| Instead of | Could use | Tradeoff |
|------------|-----------|----------|
| `paths-ignore:` denylist | Keep `paths:` allowlist, add `"**.scss"` and `"_sass/**"` | Explicitly rejected by CONTEXT — and rightly: it recurs for fonts, `.json`, images |
| Deleting a workflow file | Stripping it to `workflow_dispatch:` only | Keeps the file as reference but leaves a runnable thing that cannot pass. CONTEXT's default is deletion; reserve dispatch-stripping for anything the user might want to run by hand (`axe.yml`, `lighthouse-badger.yml` are already dispatch-only, so deletion loses nothing they don't already have) |
| Shell CNAME assertion | An off-the-shelf "verify file" action | New dependency, worse failure message, no benefit |
| Bash retry loop for the live check | `curl --retry 6 --retry-all-errors --retry-delay 10 --fail` | Works, but the failure message is curl's, not yours; the loop can emit a precise `::error::`. Either is defensible |
| Duplicating the ignore list across `push` and `pull_request` | YAML anchors (supported since 2025-09-18; merge keys `<<` still unsupported) | Simplest answer is to **drop the `pull_request` trigger** — the Deploy step already has `if: github.event_name != 'pull_request'`, and this project pushes direct to `main` |

## Architecture Patterns

### Pattern 1: `paths-ignore` denylist on `deploy.yml`

**What:** Replace both `paths:` blocks with one `paths-ignore:` on `push` only.
**Why this shape:** `paths` and `paths-ignore` are mutually exclusive per event; an all-negative `paths` list is rejected; and the `pull_request` half of the trigger only ever produced a build-without-deploy smoke test that this direct-push project does not use.

```yaml
name: Deploy site

on:
  push:
    branches:
      - main
    # DENYLIST, not an allowlist. Every push to main deploys unless every
    # changed file matches something below. The previous allowlist omitted
    # `_sass/**`, so the entire design pass would never have shipped.
    # GitHub runs the workflow unless ALL changed paths match these patterns.
    paths-ignore:
      - ".planning/**"
      - "docs/**"
      - "lighthouse_results/**"
      - "README.md"
      - "AGENTS.md"
      - "CLAUDE.md"
      - ".github/**"
      - ".prettierignore"
      - ".prettierrc"
  workflow_dispatch:
```

Notes for the planner:

- `.github/**` being ignored means a change to `deploy.yml` itself does not deploy. That is deliberate — but it also means you cannot prove a `deploy.yml` edit works by pushing it. Use the already-present `workflow_dispatch` for that, and make the criterion-1 proof a separate `_sass`-only commit.
- Keep `master` out of `branches:` if you like (this repo has no `master`), or leave it — harmless either way.
- Do **not** add `tags:`.
- Consider adding, directly under `on:`:

```yaml
concurrency:
  group: deploy-gh-pages
  cancel-in-progress: false
```

  Two pushes minutes apart currently both force-push `gh-pages`; serialising removes a whole class of "which build won?" confusion from the rollback doc.

### Pattern 2: fail-fast CNAME assertion (between "Purge unused CSS" and "Deploy")

**What:** Assert `_site/CNAME` exists and normalises to exactly `phamhakhanhchi.com`, before anything touches `gh-pages`.

```yaml
      - name: Verify CNAME before deploying
        run: |
          set -euo pipefail
          expected="phamhakhanhchi.com"

          if [ ! -f _site/CNAME ]; then
            echo "::error title=CNAME missing - refusing to deploy::_site/CNAME was not produced by the build. Deploying now would hand gh-pages a site with no custom domain. Check that CNAME is still at the repo root and is not listed under exclude: in _config.yml."
            exit 1
          fi

          actual="$(tr -d '[:space:]' < _site/CNAME)"
          if [ "$actual" != "$expected" ]; then
            echo "::error title=CNAME wrong - refusing to deploy::_site/CNAME contains '${actual}' but must contain '${expected}'. Deploying would overwrite the good CNAME on gh-pages and drop the custom domain."
            exit 1
          fi

          echo "CNAME verified: ${actual}" >> "$GITHUB_STEP_SUMMARY"
```

Why `tr -d '[:space:]'`: the file legitimately ends in `\n` (Finding B3), and a CRLF checkout would add `\r`. Trimming all whitespace makes the comparison robust without being lax about the hostname.

Why `set -euo pipefail`: without it a typo in the step silently succeeds — which is the same class of bug this phase exists to remove.

### Pattern 3: post-deploy live-domain check (after "Deploy")

```yaml
      - name: Verify live domain responds
        if: github.event_name != 'pull_request'
        run: |
          set -uo pipefail
          url="https://phamhakhanhchi.com"
          for attempt in $(seq 1 12); do
            code="$(curl -s -o /dev/null -w '%{http_code}' -L --max-time 20 "$url" || echo 000)"
            echo "attempt ${attempt}: ${code}"
            if [ "$code" = "200" ]; then
              echo "Live domain OK (${url} -> 200)" >> "$GITHUB_STEP_SUMMARY"
              exit 0
            fi
            sleep 15
          done
          echo "::error title=Live domain not responding::${url} did not return 200 within 3 minutes of deploying (last status ${code}). Check Settings > Pages still shows the custom domain, and that gh-pages still has a CNAME file."
          exit 1
```

- 12 x 15s is about 3 minutes. CONTEXT says "roughly 60s"; 3 minutes is the same design with more headroom for GitHub's "pages build and deployment" step, which is a *separate* run from this workflow and is not waited on. Erring long costs a few runner-minutes and removes the main cry-wolf risk.
- Do **not** use `set -e` alone with `curl` un-guarded; the `|| echo 000` keeps a DNS failure inside the loop instead of aborting the step on the first attempt.
- Remember Finding B4: this proves the domain resolves, not that new content shipped.

### Pattern 4: the criterion-1 proof marker

**What:** A `_sass`-only commit carrying something that survives Sass compilation **and** PurgeCSS, then grepped from the served CSS.

```scss
// Deploy-path proof marker - 2026-09-13.
// Sass strips `//` comments, so the comment alone proves nothing; the custom
// property below is what actually reaches _site/assets/css/main.css.
// See docs/DEPLOYMENT.md for why this exists.
:root {
  --deploy-proof: "2026-09-13";
}
```

Why `:root` is safe under PurgeCSS — verified two ways:

1. `purgecss.config.js` does **not** set `variables: true`, so PurgeCSS's custom-property removal is off by default and declarations inside a retained selector are untouched.
2. Empirically: the CSS served from the live domain today begins `:root{color-scheme:light;--global-bg-color: #ffffff;...}`. `:root` survives PurgeCSS on this exact config.

Verification command (note the cache-buster — the CSS is served with `Cache-Control: max-age=600` behind a proxy):

```bash
curl -s "https://phamhakhanhchi.com/assets/css/main.css?cb=$(date +%s)" | grep -c -- "--deploy-proof"
```

Sequencing that actually proves SAFE-01:

1. Land the `deploy.yml` denylist (and the rest of the guardrails) and push.
2. Record `git ls-remote origin refs/heads/gh-pages` — the "before" value.
3. Commit **only** `_sass/_custom.scss` with the marker. Verify with `git show --stat HEAD` that the diff is that one file.
4. Push. Confirm a "Deploy site" run appears.
5. `git ls-remote origin refs/heads/gh-pages` again — must differ from step 2. (Criterion 1: "advances `origin/gh-pages`".)
6. Curl the served CSS with the cache-buster until the marker appears; then `curl -sI https://phamhakhanhchi.com` -> 200 (criterion 2).

Leave the marker in place or remove it in a follow-up `_sass`-only commit — removing it is itself a second proof that the path works in both directions, and it keeps the milestone's token file clean for Phase 2.

### Pattern 5: pruning order

Delete in one commit, before touching `docs/`:

```
.github/workflows/visual-regression.yml      # SAFE-03 - structurally impossible to pass
.github/workflows/unit-tests.yml             # see Finding C2 - passes today, but guards the wrong boundary
.github/workflows/update-tocs.yml            # auto-commits to main; trips on docs/DEPLOYMENT.md
.github/workflows/star-history.yml           # repo-guarded, inert; noise
.github/workflows/upgrade-check.yml
.github/workflows/render-cv.yml
.github/workflows/docker-slim.yml
.github/workflows/deploy-image.yml
.github/workflows/deploy-docker-tag.yml
.github/workflows/broken-links.yml
.github/workflows/lighthouse-badger.yml
.github/workflows/release.yml
.github/workflows/update-screenshots.yml
.github/workflows/copilot-setup-steps.yml
.github/workflows/prettier-html.yml
.github/workflows/prettier-comment-on-pr.yml
.github/workflows/axe.yml
.github/workflows/codeql.yml
.github/workflows/update-citations.yml
```

Kept: `deploy.yml`, `prettier.yml`, `broken-links-site.yml`. That is 3 of 22.

Two judgement calls to surface to the user rather than decide silently:

- **`prettier-comment-on-pr.yml`** only fires on a `repository_dispatch` that `prettier.yml` sends when a PR check fails. Deleting it while keeping `prettier.yml` leaves `prettier.yml` dispatching into nothing — harmless (the dispatch step is inside a `failure()` guard and a failed dispatch does not un-fail the already-red job), but worth a line in the commit message.
- **`schedule-posts.txt`** is not a workflow and needs no action.

### Pattern 6: tag and revert

```bash
# Baseline on the commit that produced what is live right now (Finding D1).
git tag -a design-00-baseline 778f68b \
  -m "Pre-redesign baseline. Deployed as gh-pages@f7b878d on 2026-09-11; phamhakhanhchi.com verified 200. Site is gem-default al-folio styling."
git push origin design-00-baseline
```

Rollback of a bad design commit:

```bash
git revert --no-edit <bad-sha>     # may touch only _sass/**
git push origin main               # under paths-ignore this DOES redeploy - the SAFE-04 fact
```

Rollback of a whole phase:

```bash
git revert --no-edit <oldest-sha>^..<newest-sha>
git push origin main
```

Never `git push --force` to `main`, and never commit to `gh-pages` by hand — the next deploy's `rsync --delete` erases it (the one exception being `CNAME`/`.nojekyll` when absent from `_site`, per Finding B2).

### Pattern 7: `docs/DEPLOYMENT.md` skeleton

CONTEXT fixes the scope: commands, the tag list, the three silent failure modes, and the Pages settings snapshot. Suggested headings:

```markdown
# Deploying phamhakhanhchi.com

## How a change reaches the live site
   main -> .github/workflows/deploy.yml -> _site -> gh-pages -> GitHub Pages -> phamhakhanhchi.com
   What triggers a deploy (paths-ignore denylist) and what does not.

## GitHub Pages settings snapshot (verified YYYY-MM-DD, read-only)
   Source branch / folder - Custom domain - Enforce HTTPS - DNS records

## Tags
   design-00-baseline - 778f68b, pre-redesign, live as of 2026-09-11
   (one line per phase tag as they are cut)

## Rolling back
   Single commit - A whole phase - Why a _sass-only revert now redeploys

## Three failures that produce no error message
   1. The change never deployed - path filter. Symptom / how to confirm / fix.
   2. The domain dropped - CNAME. Symptom / how to confirm / fix.
   3. A CSS rule vanished - PurgeCSS. Symptom / how to confirm / fix.

## Verifying a deploy by hand
   curl -sI https://phamhakhanhchi.com
   curl -s "https://phamhakhanhchi.com/assets/css/main.css?cb=$(date +%s)" | grep ...
```

Also worth one line each, since they are genuinely silent: GitHub's 3,000-changed-file and 1,000-commit path-filter limits (Finding A1), and the `max-age=600` CDN cache on served assets (Finding B4).

### Anti-Patterns to Avoid

- **Inverting `paths:` into an all-`!` list.** Rejected by GitHub; the workflow will not run. Use `paths-ignore:`. (Finding A1)
- **Keeping both `paths:` and `paths-ignore:` on the same event.** Not allowed.
- **Putting the CNAME guard after the Deploy step.** The deploy is a force-push; a guard after it reports a disaster instead of preventing one.
- **Making the proof commit touch anything but `_sass/_custom.scss`.** Any `.md`/`.yml` in the same diff makes the test vacuous under the old filter *and* the new one.
- **A comment-only proof marker.** Sass strips `//` comments; `/* */` would survive Sass but Jekyll's minifier may strip it too. Use a declaration.
- **Running `npx prettier . --write` on this Windows checkout.** See Pitfall 5 — it rewrites 99 files' line endings.
- **Creating `docs/DEPLOYMENT.md` before removing `update-tocs.yml`.** The bot rewrites and commits it. (Finding C3)
- **Adding `_layouts/`, `_includes/`, `_scripts/`, `assets/tailwind/`, `tailwind.config.js` or `assets/webfonts/` to this repo.** `AGENTS.md`'s stop sign is written for the *upstream starter*, and `test/style_contract.js` has that check commented out here — but this phase has no reason to create any of them, and `_sass/` is the only shadowed path this milestone needs.

## Don't Hand-Roll

| Problem | Don't build | Use instead | Why |
|---------|-------------|-------------|-----|
| "Deploy on everything except X" | A first job that diffs `git log` and sets an output the deploy job gates on | `on.push.paths-ignore` | Native, evaluated before the run is even created, no wasted runner minutes, nothing to get wrong |
| Publishing `_site` to `gh-pages` | A hand-written `git checkout gh-pages && cp -r && push` | The existing `JamesIves/github-pages-deploy-action@v4` | Already working; it also carries the CNAME/`.nojekyll` protection of Finding B2, which a hand-rolled copy would lose |
| Preventing a bad CNAME from shipping | `clean-exclude: [CNAME]` on the deploy action | The pre-deploy assertion (Pattern 2) | `clean-exclude` only protects the branch copy from deletion; it does **not** stop a wrong `_site/CNAME` being rsynced over the good one |
| A rollback mechanism | Committing directly to `gh-pages` | `git revert` on `main` + the tag list | Locked decision, and the next deploy's `rsync --delete` erases hand edits to `gh-pages` anyway |
| A "did my change ship?" check | Trusting a green Actions tick | Grep the served CSS with a cache-buster | Green means the workflow ran, not that the rule survived PurgeCSS. This distinction is the whole reason Phase 8 exists |
| Surfacing a failure reason | A custom notifier / webhook / secret | `::error title=...::` + `$GITHUB_STEP_SUMMARY` + GitHub's default failure email | Locked decision: "No new notification services or secrets" |

**Key insight:** every guardrail in this phase should be a platform primitive or five lines of `bash`. Anything bigger becomes a thing that itself fails silently — which is the failure class the phase exists to eliminate.

## Common Pitfalls

### Pitfall 1: writing the denylist as negated `paths:`
**What goes wrong:** The workflow never fires. Worse, it fires *sometimes* if a stray positive pattern is left in, so it looks like it works.
**Why it happens:** GitHub requires at least one non-`!` pattern in a `paths:` list, and forbids combining `paths` with `paths-ignore`.
**How to avoid:** Delete the `paths:` key entirely and write `paths-ignore:`.
**Warning signs:** The diff still contains the word `paths:` under `on.push`.

### Pitfall 2: proving criterion 1 with a commit that touches more than `_sass/`
**What goes wrong:** The deploy would have fired under the *old* filter too, so the test proves nothing.
**Why it happens:** It is natural to bundle the marker with the workflow edit or a doc update.
**How to avoid:** `git show --stat HEAD` before pushing — exactly one file, `_sass/_custom.scss`. Capture that output in the plan notes.
**Warning signs:** More than one path in `git show --stat`.

### Pitfall 3: the proof marker is stripped between source and served CSS
**What goes wrong:** The workflow is green, `gh-pages` advanced, and the grep still finds nothing.
**Why it happens:** Sass deletes `//` comments; PurgeCSS deletes unreferenced selectors; the CDN serves a cached copy for up to 600s.
**How to avoid:** Use a `:root` custom property (proven to survive — the gem's own `--global-*` tokens are in the live CSS), and append `?cb=$(date +%s)` to the curl. Allow a few minutes and retry before concluding failure.
**Warning signs:** `grep -c` returns 0 while `Last-Modified` on the HTML has moved.

### Pitfall 4: `docs/DEPLOYMENT.md` gets auto-rewritten by `update-tocs.yml`
**What goes wrong:** A bot commit lands on `main`; your next push is rejected non-fast-forward; and once the denylist is in place that bot commit would itself have triggered a deploy (`docs/**` being ignored prevents that, but only if the ignore list is already merged).
**Why it happens:** `update-tocs.yml` matches `docs/*.md` and has `contents: write`.
**How to avoid:** Delete `update-tocs.yml` in an earlier commit than the one that creates the doc.
**Warning signs:** A commit on `main` authored by `github-actions[bot]` titled "Auto update markdown TOC".

### Pitfall 5: `npx prettier . --write` on this Windows checkout rewrites 99 files
**What goes wrong:** `core.autocrlf=true`, so files on disk are CRLF; Prettier's default `endOfLine: "lf"` marks every file as unformatted. `--check` reports **99** failures locally versus **17** real ones. A blind `--write` produces an enormous line-ending-only diff.
**Why it happens:** Windows checkout plus a Linux-normalised repo.
**How to avoid:** Locally, always `npx prettier . --check --end-of-line auto`. If a real fix is needed, write that one file: `npx prettier --write path/to/file`. CI runs on Linux with LF and sees only the real 17.
**Warning signs:** A `git diff --stat` with hundreds of files and near-equal insertions and deletions.

### Pitfall 6: `prettier.yml` goes red on this phase's own first push
**What goes wrong:** 17 `.planning/**` files fail Prettier and `prettier.yml` has no path filter. The first push of the phase — which includes 10 backlogged planning commits — turns `main` red, immediately violating the phase's own "a green tick must mean something".
**Why it happens:** `.prettierignore` does not cover `.planning/`.
**How to avoid:** Add `.planning/**` to `.prettierignore` in the same phase, ideally in the first commit.
**Warning signs:** "Code style issues found in 17 files" from `npx prettier . --check --end-of-line auto`.

### Pitfall 7: the live-domain check cries wolf on GitHub Pages publish lag
**What goes wrong:** The deploy action pushes `gh-pages`, the job's curl runs immediately, and GitHub's separate "pages build and deployment" has not finished. Because the site is already live this usually returns 200 anyway — but during a first-ever publish, or after a Pages settings change, it will not.
**Why it happens:** The Pages build is a different workflow run that this job does not wait on.
**How to avoid:** Retry across about 3 minutes (Pattern 3), and understand that the check asserts "domain resolves", not "new content is live" (Finding B4).
**Warning signs:** A red run whose only failing step is the live check, while the site loads fine in a browser.

### Pitfall 8: assuming the CNAME situation is currently broken
**What goes wrong:** The plan spends effort "fixing" something that already works, or the verification step is written as "restore the domain" rather than "confirm the guard fires".
**Why it happens:** SAFE-02's wording and STATE.md predate the 2026-09-11 deploys. (Finding B1)
**How to avoid:** Verify the guard by *simulating* a bad CNAME — run the assertion script locally against a temp dir with a wrong/empty CNAME. Do not break the real one to test it.
**Warning signs:** A task phrased as "restore the custom domain".

### Pitfall 9: deleting a workflow that a branch-protection rule still requires
**What goes wrong:** If `visual-regression` (or `style-contract`) is configured as a **required status check** in branch protection or a ruleset, deleting the workflow leaves PRs permanently "Expected — waiting for status to be reported", which is worse than a red X.
**Why it happens:** Required checks are configured in repo settings, not in the workflow file, so deleting the file does not clear them.
**How to avoid:** While in Settings > Pages for the CNAME snapshot, also open Settings > Branches / Rules and confirm no required status checks are configured. Record the answer in `docs/DEPLOYMENT.md`. `gh` is **not installed** on this machine, so this is a manual browser check.
**Warning signs:** A PR stuck on "Expected" rather than showing a check result.

### Pitfall 10: two deploys racing
**What goes wrong:** Two pushes minutes apart both force-push `gh-pages`; the older build can land last.
**Why it happens:** `deploy.yml` has no `concurrency:` group.
**How to avoid:** Add the group from Pattern 1's note.
**Warning signs:** `gh-pages` HEAD referencing an older `main` commit than the newest deploy run.

### Pitfall 11: `git push` is rejected because local `main` is 10 commits ahead of a moved remote
**What goes wrong:** The push fails, and under time pressure someone reaches for `--force`.
**Why it happens:** 10 unpushed commits plus any bot commit on the remote.
**How to avoid:** `git fetch origin && git log --oneline origin/main..main` before the first push. Never force-push `main`; `git pull --rebase` if the remote moved.
**Warning signs:** "Updates were rejected because the remote contains work that you do not have locally."

## Code Examples

Verified patterns, all run against this repo or the live site on 2026-09-13.

### Verify what is live, right now

```bash
curl -sI https://phamhakhanhchi.com | head -3
# HTTP/1.1 200 OK
# Server: GitHub.com

curl -s "https://phamhakhanhchi.com/assets/css/main.css?cb=$(date +%s)" | head -c 200
# :root{color-scheme:light;--global-bg-color: #ffffff;--global-text-color: #000000;...
```

### Confirm `gh-pages` actually advanced

```bash
before="$(git ls-remote origin refs/heads/gh-pages | cut -f1)"
# ... push the _sass-only commit, wait for the run ...
after="$(git ls-remote origin refs/heads/gh-pages | cut -f1)"
[ "$before" != "$after" ] && echo "gh-pages advanced: $before -> $after"
```

### Confirm the proof commit is `_sass`-only

```bash
git show --stat --oneline HEAD
# expect exactly:  _sass/_custom.scss | N ++
```

### Test the CNAME assertion logic without breaking anything

```bash
tmp="$(mktemp -d)"; mkdir -p "$tmp/_site"
printf 'phamhakhanhchi.com\n' > "$tmp/_site/CNAME"   # good  -> passes
: > "$tmp/_site/CNAME"                               # empty -> must fail
printf 'example.com\n'        > "$tmp/_site/CNAME"   # wrong -> must fail
rm -f "$tmp/_site/CNAME"                             # gone  -> must fail
```

Run the same three-branch shell from Pattern 2 against `$tmp` before wiring it into the workflow.

### Check Prettier the way CI will, from Windows

```bash
npx prettier . --check --end-of-line auto
# Today: 17 files, all under .planning/
```

## State of the Art

| Old approach | Current approach | When changed | Impact |
|--------------|------------------|--------------|--------|
| Allowlist `paths:` with `!` exceptions bolted on | `paths-ignore:` denylist | n/a (both always existed) | The allowlist shape is the bug; `paths-ignore` is the supported denylist |
| Custom `git push` to `gh-pages` in a run step | `JamesIves/github-pages-deploy-action@v4` | v4, 2021 | Already in use; keep it |
| No YAML reuse in Actions | YAML anchors/aliases supported | **2025-09-18** (GitHub Changelog) | Merge keys (`<<`) are still unsupported, so anchors only help if you alias a whole sequence. Dropping the `pull_request` trigger is simpler |
| Publishing from a branch with a `CNAME` file | Pages via a custom Actions workflow, where "any existing `CNAME` file is ignored and is not required" | ongoing | **Not applicable here** — this repo publishes *from the `gh-pages` branch*, so the `CNAME` file remains load-bearing. Do not follow branch-less advice found online |

**Deprecated/outdated in this repo:**

- The seven `test/integration_*.sh` scripts are already gone (`81e55bd`); `AGENTS.md` and `CLAUDE.md` still document them as the validated command set. Both files describe the **upstream demo** (including a `/al-folio` baseurl that is wrong here — `_config.yml:23` has a blank `baseurl`). STATE.md already flags this; do not run the command sets in `AGENTS.md` verbatim.
- `test/visual/` and the `test:visual*` npm scripts become orphaned once `visual-regression.yml` is deleted. CONTEXT does not ask for their removal and TEST-01 may reuse them; leave them.

## Open Questions

1. **Are any required status checks configured on `main`?**
   - What we know: the project pushes direct to `main` and `branching_strategy` is `"none"`, so protection is probably off.
   - What's unclear: cannot be checked from here — `gh` is not installed and the API needs auth.
   - Recommendation: fold it into the read-only Settings inspection this phase already requires (Pages tab), and record the answer in `docs/DEPLOYMENT.md`. If `visual-regression` or `style-contract` *is* required, remove the requirement in the same sitting as deleting the workflow (Pitfall 9).

2. **Is `unit-tests.yml` still worth deleting, now that it passes?**
   - What we know: it passes today and would keep passing through this milestone (Finding C2). Its assertions guard the upstream thin-starter boundary.
   - What's unclear: whether the user wants the `al_math` pin / SRI-hash assertions kept as incidental value.
   - Recommendation: delete, per CONTEXT — but say in the commit message that it passes and is being removed for irrelevance, not for failing. Surface the correction to the user; it is a stale premise, not a wrong decision.

3. **Keep or drop `deploy.yml`'s `pull_request` trigger?**
   - What we know: the Deploy step is already `if: github.event_name != 'pull_request'`, so PRs get a build-only smoke test. The project uses direct pushes.
   - Recommendation: drop it. One list to maintain, and Pattern 1's `paths-ignore` then has exactly one home. If the user later wants PR smoke builds, re-add with the same list.

4. **Should `.nojekyll` be added?**
   - What we know: it is absent everywhere, and `/_pages/dropdown/` 404s as a result (Finding E1). Nothing the site links to is affected.
   - Recommendation: out of scope. Mention it in `docs/DEPLOYMENT.md` as a known quirk, or raise it as a one-line todo — do not expand the phase.

5. **Exactly which commit gets `design-00-baseline`?**
   - What we know: `778f68b` is what produced the live site (Finding D1). Local `main` is 10 doc-only commits ahead and has never been built.
   - Recommendation: tag `778f68b`. Nothing between it and local HEAD changes a byte of the site.

6. **Was the 2026-09-10 incident actually a CNAME-in-`_site` failure?**
   - What we know: the two 2026-09-10 deploys (`a608b18` from `545d014`, `aa91529` from `c146db5`) both predate `a5dd00f`, which put `CNAME` on `main`. So there was simply no CNAME to copy. `ed4c9cf` "Delete CNAME" / `ca2d479` "Create CNAME" on `gh-pages` is the manual rescue.
   - What's unclear: nothing material — but this means the root cause was "CNAME not yet in the source", which the pre-deploy assertion does catch.
   - Recommendation: write the timeline accurately in `docs/DEPLOYMENT.md`; an accurate post-mortem is worth more than a dramatic one.

## Validation Architecture

`workflow.nyquist_validation` is `true` in `.planning/config.json`.

### Test Framework

| Property | Value |
|----------|-------|
| Framework | **None applicable.** This phase's artefacts are workflow YAML, shell guards, git tags and prose. There is no unit-testable code. The repo's only JS "test" is `test/style_contract.js` (a lint, not a test) and `test/visual/*.spec.js` (Playwright specs targeting `/al-folio/` demo routes, deleted along with their workflow). |
| Config file | none — and **do not create one**. A test harness added here would be exactly the "starter-local build pipeline" scope creep the project forbids |
| Quick run command | `npx prettier . --check --end-of-line auto` (the only automatable local gate; `--end-of-line auto` per Pitfall 5) |
| Full suite command | `bash .planning/phases/01-deployment-guardrails/verify.sh` — a phase-local verification script the planner should create, composing the curl / `git ls-remote` / `grep` checks below. Everything in it is a one-liner; the script exists so criterion verification is repeatable, not so a framework exists. |

Note: `ruby` and `bundle` are **not installed** on this machine, so `bundle exec jekyll build` cannot be run locally. Every build-side assertion has to be verified either in CI or against the deployed site. Plan tasks accordingly — there is no local `_site/` to inspect.

### Phase Requirements -> Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| SAFE-01 | A `_sass`-only push triggers a deploy | integration (live) | `git show --stat HEAD` (one file) then push, then compare `git ls-remote origin refs/heads/gh-pages` before/after | ❌ Wave 0 |
| SAFE-01 | The change reaches served CSS | integration (live) | `curl -s "https://phamhakhanhchi.com/assets/css/main.css?cb=$(date +%s)" \| grep -q -- "--deploy-proof"` | ❌ Wave 0 |
| SAFE-01 | The denylist is syntactically valid | static | `! grep -qE '^\s+paths:' .github/workflows/deploy.yml && grep -q 'paths-ignore:' .github/workflows/deploy.yml` | ❌ Wave 0 |
| SAFE-02 | Bad/missing `_site/CNAME` fails the job | unit (shell) | Run the Pattern 2 script against a temp `_site` in four states (good / empty / wrong / absent); expect exit 0,1,1,1 | ❌ Wave 0 |
| SAFE-02 | The guard precedes the Deploy step | static | Assert the "Verify CNAME" step's line number in `deploy.yml` is less than the `JamesIves/github-pages-deploy-action` line number | ❌ Wave 0 |
| SAFE-02 | The live domain answers 200 after deploy | integration (live) | `curl -s -o /dev/null -w '%{http_code}' -L https://phamhakhanhchi.com` -> `200` | ❌ Wave 0 |
| SAFE-03 | No `visual-regression` check can appear | static | `test ! -f .github/workflows/visual-regression.yml` | ❌ Wave 0 |
| SAFE-03 | Nothing left in `.github/workflows/` targets upstream al-folio | static | `ls .github/workflows/*.yml` equals exactly `broken-links-site.yml deploy.yml prettier.yml` | ❌ Wave 0 |
| SAFE-03 | Branch protection does not require a deleted check | **manual-only** | Settings > Branches / Rules in the browser — `gh` is not installed and the API needs auth | n/a |
| SAFE-04 | A baseline tag exists on the remote | integration | `git ls-remote --tags origin \| grep -q design-00-baseline` | ❌ Wave 0 |
| SAFE-04 | The rollback doc exists and names the three failure modes | static | `test -f docs/DEPLOYMENT.md && grep -qi "path filter" docs/DEPLOYMENT.md && grep -qi "CNAME" docs/DEPLOYMENT.md && grep -qi "PurgeCSS" docs/DEPLOYMENT.md` | ❌ Wave 0 |
| SAFE-04 | The doc states that a `_sass`-only revert now redeploys | **manual-only** | Prose assertion — a reviewer reads it. A grep for `_sass` is a weak proxy and should not be treated as passing | n/a |
| — | Pages settings snapshot recorded | **manual-only** | Settings > Pages in the browser; transcribed into the doc | n/a |
| — | CI stays green on the first push | static | `npx prettier . --check --end-of-line auto` -> 0 files | ❌ Wave 0 (needs the `.prettierignore` line) |

### Sampling Rate

- **Per task commit:** `npx prettier . --check --end-of-line auto` plus the static greps for whatever that commit touched. All sub-second.
- **Per wave merge:** the full `verify.sh` static block (file-presence, step ordering, workflow inventory). The live block is skipped until the proof push exists.
- **Phase gate:** `verify.sh` in full — static **and** live — plus the three manual-only rows (Pages settings, branch rules, a human reading `docs/DEPLOYMENT.md`) before `/gsd:verify-work`.

### Wave 0 Gaps

- [ ] `.planning/phases/01-deployment-guardrails/verify.sh` — composes every automatable row above; a `--live` flag gates the curl / `ls-remote` checks so it is runnable before the proof push. Covers SAFE-01, SAFE-02, SAFE-03, SAFE-04.
- [ ] A single source of truth for the CNAME assertion (the Pattern 2 body) that both `deploy.yml` and the four-state shell test exercise — either duplicated with a comment tying them together, or extracted to `bin/verify-cname.sh` and called from the workflow. Extraction is cleaner but adds a file the workflow depends on; either is fine, just do not let them drift.
- [ ] `.prettierignore` entry `.planning/**` — without it the "CI stays green" row fails from the first push.
- [ ] No framework install. Do not add one.

## Sources

### Primary (HIGH confidence)

- **This repository, measured directly on 2026-09-13** — `git fetch origin --prune --tags`, `git log` / `ls-tree` / `cat-file` on `main` and `origin/gh-pages`, `od -c` on both `CNAME` blobs, full reads of all 22 workflow files, `_config.yml`, `purgecss.config.js`, `assets/css/main.scss`, `_sass/_custom.scss`, `test/style_contract.js`, `package.json`, `.prettierrc`, `.prettierignore`, `.gitignore`; `npx prettier . --check` with and without `--end-of-line auto`.
- **The live site, measured 2026-09-13** — `curl -sI https://phamhakhanhchi.com` (200), `curl -s .../assets/css/main.css` (`:root` tokens and `.entry-year` present; `Cache-Control: max-age=600`), `curl .../_pages/dropdown/` (404).
- **GitHub Docs — Workflow syntax, `on.<push|pull_request>.<paths|paths-ignore>`** — `paths`/`paths-ignore` mutual exclusion; the "at least one non-`!` pattern" rule; negative-pattern ordering; "when all path names match `paths-ignore`, the workflow will not run"; the 3,000-file and 1,000-commit limits. https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax
- **`JamesIves/github-pages-deploy-action` — `src/git.ts` (dev branch)** — the literal `rsync -q -av --checksum --progress ... --delete` invocation and the `!fs.existsSync(...CNAME) ? '--exclude CNAME' : ''` conditional; always-excluded `.git` / `.github` / `.ssh`. https://github.com/JamesIves/github-pages-deploy-action
- **`JamesIves/github-pages-deploy-action` README (v4)** — `clean` defaults on, `clean-exclude`, `force` defaults on, `single-commit` wipes history, and the CNAME / `.nojekyll` guidance.

### Secondary (MEDIUM confidence)

- **GitHub Docs — Managing a custom domain for your GitHub Pages site** — confirms that saving a custom domain writes a `CNAME` commit to the source branch, and that a *custom Actions workflow* publish ignores `CNAME`. It does **not** document what happens when the file is deleted from a branch-published site; that behaviour is attested by community reports rather than by the docs. https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site
- **GitHub Changelog, 2025-09-18 — "Actions: YAML anchors and non-public workflow templates"** — anchors/aliases supported; merge keys (`<<`) are not. https://github.blog/changelog/2025-09-18-actions-yaml-anchors-and-non-public-workflow-templates/

### Tertiary (LOW confidence — flagged, not relied upon)

- Community threads on custom domains being reset by `gh-pages` deploys (`gitname/react-gh-pages#89`, `tschaub/gh-pages#236`, GitHub Community Discussions #22366 and #159544). Consistent with the source-code reading above, but the plan's behaviour claims rest on `src/git.ts`, not on these.

## Metadata

**Confidence breakdown:**

- **Repo ground truth: HIGH** — every row of the ground-truth table was produced by a command run in this session against this checkout and the live domain, not inferred.
- **`paths-ignore` semantics: HIGH** — official workflow-syntax reference; four independent statements, all load-bearing for the implementation.
- **Deploy-action `clean` behaviour: HIGH** — read from the action's own source, corroborated by its README.
- **Workflow prune list: HIGH** — every trigger block and every `if: github.repository` guard read directly from the 22 files.
- **Pitfalls: HIGH** — Pitfalls 4, 5, 6 and 11 were reproduced or directly measured here; the rest follow from the docs and source above.
- **GitHub Pages custom-domain-unset-on-CNAME-delete: MEDIUM** — not stated in official docs; widely attested by community reports. This is the one claim in the phase's motivation that is not officially documented, and the guard does not depend on it being precisely true.
- **Branch-protection / required-checks state: UNKNOWN** — cannot be determined from this machine (`gh` absent). Listed as Open Question 1 and as a manual verification row.

**Corrections to upstream planning documents that the planner should carry forward and surface to the user:**

1. `paths:` cannot be inverted into an all-`!` denylist — the mechanism is `paths-ignore:`.
2. STATE.md's "No deploy has run since `CNAME` reached `main`" is stale — three deploys ran 2026-09-11 and CNAME survived all three; the domain is currently healthy.
3. CONTEXT's reason for deleting `unit-tests.yml` ("fails CI when `_sass/` exists") is stale — `81e55bd` already disabled that check; it passes today.
4. CONTEXT lists `star-history.yml` as an auto-commit risk — it is repo-guarded to `alshedivat/al-folio` and its job is skipped here. Same for `broken-links.yml`, `deploy-image.yml`, `release.yml`, `update-screenshots.yml`.
5. `update-tocs.yml` is the **only** live auto-committer, and it triggers on `docs/*.md` — the very path this phase writes to.
6. `prettier.yml` has no path filter and 17 `.planning/**` files currently fail it, with 10 unpushed commits waiting. Add `.planning/**` to `.prettierignore` or the phase reds out its own first push.

**Research date:** 2026-09-13
**Valid until:** approximately 2026-10-13 (30 days). The repo-state rows go stale the moment anything is pushed; re-run the ground-truth commands if planning is deferred.

# Phase 1: Deployment Guardrails - Context

**Gathered:** 2026-09-13
**Status:** Ready for planning

<domain>
## Phase Boundary

Make a stylesheet-only change able to reach `https://phamhakhanhchi.com`, make a CNAME-less deploy impossible rather than silent, stop inherited al-folio CI from blocking or corrupting design work, and write down a way back.

Nothing visual changes in this phase. The site must be pixel-identical when it ends. All palette, type and component work belongs to Phases 2-8.

</domain>

<decisions>
## Implementation Decisions

### Deploy trigger scope

- **Invert `deploy.yml`'s path filter from an allowlist to a denylist.** Every push to `main` deploys except explicitly excluded paths. Do not just bolt `_sass/**` and `**.scss` onto the existing allowlist — the allowlist shape is the bug, and it recurs for the next unlisted file type (fonts, `.json` data, image assets).
- Exclusions to carve out: `docs/`, `README.md`, `.planning/**`, `lighthouse_results/**`, `AGENTS.md`, `CLAUDE.md`, and agent/tooling-only workflow files.
- **Changes land as direct pushes to `main`.** Solo project, no reviewer, no branch-per-phase. Criterion 3 is therefore about removing a latent landmine, not unblocking a workflow in active use.
- **Proof commit for criterion 1: a traceable no-op marker.** Add a dated comment _plus_ one harmless verifiable rule to `_sass/_custom.scss` (e.g. a custom property that survives to the served CSS). Then grep the stylesheet actually served from the live domain to prove the change travelled the full path — build, PurgeCSS, deploy — not merely that a workflow ran green. A comment-only change is insufficient: Sass strips `//` comments.
- **Failure visibility: GitHub's default failure email, plus deliberately self-explaining step names.** Guard steps must name the problem in the Actions failure line (e.g. "CNAME missing — refusing to deploy", "live domain not responding"). No new notification services or secrets.

### CNAME safety net

- **The guard is a pre-deploy step in `deploy.yml`**, positioned after the PurgeCSS step and before the `JamesIves/github-pages-deploy-action@v4` step. It must fail the job so nothing reaches `gh-pages` — the check has to precede the destructive branch replacement, not follow it.
- **Assertion: `_site/CNAME` exists AND its contents are exactly `phamhakhanhchi.com`.** An empty, truncated or stale-hostname CNAME breaks the domain just as completely as a missing one.
- **Post-deploy live check: curl `https://phamhakhanhchi.com` with retries** (poll a few times across roughly 60s) and **fail the run** if it never returns 200. Retries exist to absorb GitHub Pages publish lag so the check does not cry wolf; a genuine outage still goes red.
- **GitHub Pages repo settings: verify and record, do not change.** Confirm the custom domain and "Enforce HTTPS" in Settings → Pages and write the current state into the rollback doc. Removes the unknown without introducing a change this phase has to justify.

### Inherited CI pruning

- **Delete `visual-regression.yml`.** Its specs target `/al-folio/` routes and v0.16.3 demo content this site does not have; it can never pass. Deleting makes criterion 3 structurally true — no filter left to misconfigure. TEST-01 (retargeted specs) is already deferred out of this roadmap.
- **Delete `unit-tests.yml`.** It runs al-folio's `lint:style-contract`, which fails CI when `_sass/` exists. This is a user site where shadowing gem files is explicitly legal, so the contract is wrong here and would red-X every commit of the design pass.
- **Disable both auto-committing workflows: `update-tocs.yml` and `star-history.yml`.** Bot commits to `main` mid-pass cause non-fast-forward rejections on the next push, and under the new denylist filter each bot commit would also trigger a full deploy.
- **Prune everything else that tests upstream al-folio rather than this site**: `upgrade-check.yml`, `render-cv.yml`, `docker-slim.yml`, `deploy-image.yml`, `deploy-docker-tag.yml`, `broken-links.yml`, `lighthouse-badger.yml`, `release.yml`, `update-screenshots.yml`, `copilot-setup-steps.yml`, `prettier-html.yml`, `prettier-comment-on-pr.yml`, `axe.yml`.
- **Keep `prettier.yml`** — the one inherited check that genuinely applies. It formats the `_sass` files this milestone will fill, and a red X is always a real one-command fix (`npx prettier . --write`).
- **Keep `broken-links-site.yml`** — checks the deployed site, useful for Phase 8.
- **Delete `codeql.yml` and `update-citations.yml`.** CodeQL scanning a static Jekyll site is noise; `update-citations` needs the `scholarly` package and a Scholar ID that are not wired up.
- **Standard to hold to:** after pruning, a green tick must mean something. Anything left running should be capable of passing on this site.

### Rollback procedure

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

</decisions>

<specifics>
## Specific Ideas

- "A green tick must mean something" — the pruning standard. Anything left wired should be able to pass on this site.
- The guard must fire _before_ the destructive step. The 2026-09-10 incident was survivable only because a human noticed; the whole point is that the pipeline notices first.
- Prefer fixes that remove a class of failure over fixes that patch one instance — hence denylist over allowlist, deletion over narrowed filters.
- Failures should be self-explaining in the Actions UI without opening logs.

</specifics>

<code_context>
## Existing Code Insights

### Reusable Assets

- `.github/workflows/deploy.yml` — the single deploy path. Ruby 3.3.5 / Python 3.13 / Node 20, `npm ci`, a `giscus.repo` yaml-update step, `bundle exec jekyll build` under `JEKYLL_ENV=production`, global `purgecss -c purgecss.config.js`, then `JamesIves/github-pages-deploy-action@v4` with `folder: _site`. Already has `workflow_dispatch`. The CNAME guard slots between the PurgeCSS and Deploy steps.
- `CNAME` exists at repo root containing `phamhakhanhchi.com`, and is present on `origin/gh-pages` (from the manual rescue commit).
- `_config.yml:22-23` — `url: https://phamhakhanhchi.com`, `baseurl:` blank. This fork correctly does _not_ use the upstream `/al-folio` baseurl, so a plain `bundle exec jekyll build` is right here.
- `_config.yml:249-251` — `keep_files: [CNAME, .nojekyll]`. Preserves them in an existing destination; does not help a fresh CI build, and does not survive the deploy action's clean.
- `_config.yml:228+` — `exclude:` list. `CNAME` is not excluded, so Jekyll should copy it to `_site/`; the guard verifies this rather than assuming it.
- `_sass/_custom.scss` — 74 lines, the only file in `_sass/`. Home of the proof marker, and the file the whole milestone will grow.
- `purgecss.config.js` — sits between build and deploy; the reason the proof must be grepped from served CSS, and a named failure mode in the rollback doc.

### Established Patterns

- **Direct commits to `main`; `origin/gh-pages` is deploy output only.** No tags exist yet.
- **This repo is a fork of the al-folio v1 thin starter, used as a personal site.** `AGENTS.md`'s stop sign (no `_sass/`, `_layouts/`, `_includes/`) applies to the _upstream starter repo_, not here — a user's own site may legally shadow gem-owned files. `_sass/_custom.scss` already does. This is why `unit-tests.yml`'s style contract is wrong for this repo.
- **Gem-based runtime:** `theme: al_folio_core` with `al-*` plugin gems. Design work lands in local `_sass/`, never in gem files.
- 22 workflow files inherited from upstream; 12 fire on push/PR today, two of those auto-commit to `main`.

### Integration Points

- `deploy.yml` `on.push.paths` and `on.pull_request.paths` — the allowlist→denylist inversion (SAFE-01).
- `deploy.yml` steps, between "Purge unused CSS" and "Deploy" — the CNAME assertion; a new step after "Deploy" — the retrying live curl (SAFE-02).
- `.github/workflows/` as a directory — the pruning pass (SAFE-03).
- New file `docs/DEPLOYMENT.md`, plus git tags on `main` (SAFE-04).
- GitHub repo Settings → Pages — read-only verification, snapshot recorded in the doc.

</code_context>

<deferred>
## Deferred Ideas

- **Retargeting visual-regression specs at this site's own pages** — already deferred out of this roadmap as TEST-01. Deleting the workflow does not foreclose it; a future milestone would write new specs against real pages.
- **Automated contrast/accessibility gating in CI** — `axe.yml` is dispatch-only and `lighthouse-badger.yml` measures the upstream demo. Phase 8 handles this by hand deliberately; building a real automated gate is a separate concern.
- **PurgeCSS safelist hardening** — Phase 8 criterion 3 inspects the served CSS by hand. Turning that into a CI check is out of scope here; Phase 1 only documents the failure mode.

</deferred>

---

_Phase: 01-deployment-guardrails_
_Context gathered: 2026-09-13_

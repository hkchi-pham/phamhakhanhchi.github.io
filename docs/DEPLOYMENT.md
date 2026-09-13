# Deploying this site

**This file is about _this_ site — `phamhakhanhchi.com`. Every other document in `docs/` was inherited from the upstream al-folio template and describes the upstream demo, not this deployment.** When the two disagree, this file wins for anything about publishing, rollback or the custom domain.

Written 2026-09-13, at the end of the deployment-guardrails phase. Every number below was measured against the live site, not read off the YAML.

---

## 1. How a change reaches the live site

```
push to main
  -> .github/workflows/deploy.yml   (GitHub Actions)
     -> bundle exec jekyll build     (JEKYLL_ENV=production, ImageMagick + nbconvert installed)
     -> purgecss -c purgecss.config.js
     -> bash bin/verify-cname.sh _site         <- guard, must pass
     -> JamesIves/github-pages-deploy-action@v4  (rsync --delete, force-push)
        -> gh-pages branch
           -> GitHub Pages "pages build and deployment" (a separate run)
              -> https://phamhakhanhchi.com
     -> curl the live domain, retry up to 12 times   <- guard, after the publish
```

There is no staging environment. `main` is production.

### What triggers a deploy

**Everything except the denylist.** `deploy.yml` uses `paths-ignore`, so a push to `main` deploys _unless every file it changed_ matches one of these:

```
.planning/**
docs/**
lighthouse_results/**
.github/**
README.md
AGENTS.md
CLAUDE.md
LICENSE
.prettierignore
.prettierrc
.gitignore
```

This is a denylist on purpose. The previous version was an allowlist (`assets/**`, `**/*.md`, `**.yml`, ...) that never listed `_sass/**`, so stylesheet-only commits silently never shipped. An allowlist would simply have re-broken for the next unlisted file type — fonts, `.json` data, images — so the polarity was inverted rather than patched.

Two consequences that surprise people:

- **A change under `.github/` does not deploy.** `deploy.yml` cannot test itself. Validate a workflow edit with `workflow_dispatch` from the Actions tab, or by riding along with a non-ignored path in the same push.
- **A push that mixes an ignored file with a non-ignored one _does_ deploy.** The run is skipped only when _all_ changed paths match the denylist. A commit touching `docs/DEPLOYMENT.md` and `_sass/_base.scss` together will rebuild and republish the site.

---

## 2. GitHub Pages settings snapshot

Verified 2026-09-13. Read-only — nothing was changed. See "How these were established" below: these values were measured from the live service and the public API, not transcribed from the settings pages.

| Setting                       | Value                                                                                                                                       |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| Repository                    | `hkchi-pham/phamhakhanhchi.github.io` (note: the owner login is `hkchi-pham`, **not** `phamhakhanhchi` — the org name is not the site name) |
| Pages enabled                 | yes (`has_pages: true`)                                                                                                                     |
| Source branch / folder        | `gh-pages` / `/ (root)`                                                                                                                     |
| Custom domain                 | `phamhakhanhchi.com`                                                                                                                        |
| DNS check                     | passing                                                                                                                                     |
| Enforce HTTPS                 | on                                                                                                                                          |
| Branch rules targeting `main` | **none** — no classic protection, no ruleset                                                                                                |
| Required status checks        | **none**                                                                                                                                    |

**How these were established.** `GET /repos/.../pages` refuses without a token, so the values above were derived from observable behaviour instead of transcribed from a screenshot:

- Source is `gh-pages` at the root: the branch's root tree holds `index.html`, `assets/`, `CNAME`, `sitemap.xml`; it has no `docs/` directory, and `https://phamhakhanhchi.com/assets/css/main.css` serves the file at `gh-pages:assets/css/main.css`. A `/docs` source folder would serve nothing at those paths.
- Custom domain and a passing DNS check: `https://hkchi-pham.github.io/phamhakhanhchi.github.io/` returns **301 to `https://phamhakhanhchi.com/`**. GitHub only issues that redirect for a custom domain it has configured and validated.
- Enforce HTTPS: `http://phamhakhanhchi.com` returns **301 to `https://phamhakhanhchi.com/`**, and the HTTPS response carries `Strict-Transport-Security: max-age=31556952`.
- No branch rules: `GET /repos/.../branches` reports `"protected": false` for `main`, and both `GET /repos/.../rules/branches/main` and `GET /repos/.../rulesets` return an empty list.

**"No required status checks" is the load-bearing line here.** Nineteen workflows were deleted in this phase, including `visual-regression`, `unit-tests` and `style-contract`. Deleting a workflow file does _not_ clear a required status check configured in settings — a stale requirement leaves every future pull request hanging on "Expected — waiting for status to be reported", which is worse than a red X because nothing ever reports. There are no rules on `main` at all, so there is nothing stale to clear. For a solo direct-push project that is the expected and acceptable answer.

**Three separate pieces of state, which can drift apart.** The repository _setting_ (above), `CNAME` in `main`, and `CNAME` on `gh-pages` are three different things. All three currently say `phamhakhanhchi.com`. Disagreement between them is its own failure mode — see §5.2.

---

## 3. Tags

The scheme: **one annotated tag per completed phase, named `design-NN-<slug>`.** Never `v*` — the upstream `deploy-docker-tag.yml` fired on `v*` tags. It has been deleted, but the `design-*` prefix avoids the collision permanently. Do not switch schemes without re-checking every remaining workflow's triggers.

| Tag                  | Commit    | What was live there                                                                                                                                                                   |
| -------------------- | --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `design-00-baseline` | `778f68b` | Pre-redesign. Gem-default al-folio styling: white ground, gem default type, no design-pass changes. Published as `gh-pages@f7b878d` on 2026-09-11; `phamhakhanhchi.com` verified 200. |

`778f68b` is the baseline rather than "whatever `main` was when the phase started" because `gh-pages@f7b878d` says _"Deploying to gh-pages from ...@778f68b"_ — it is the commit that actually produced what was live. Everything between it and the end of this phase is planning documents and guardrails, plus a single unreferenced CSS custom property. Not a byte of the rendered design.

### Tag pushes do not deploy — with one caveat

`deploy.yml`'s `on.push` lists `branches:` only and no `tags:`, so pushing a tag cannot trigger it. Confirmed: pushing `design-00-baseline` left `gh-pages` unchanged at `9d0d929`, and the Actions API lists no Deploy run for it.

**The caveat is worth knowing before you tag an old commit.** GitHub evaluates workflows as they exist _at the commit being pushed_. `778f68b` predates this phase's cleanup, so it still carries all 22 original workflow files — and one of them, `copilot-setup-steps.yml`, has an `on.push` with no `branches:` restriction. Pushing the tag therefore started a "Copilot Setup Steps" run on ref `design-00-baseline`. It is harmless (`contents: read`, no publish, no commit) but it is not nothing, and it will happen again for any tag placed on a pre-cleanup commit. All three workflows that remain on `main` today are branch-scoped or `workflow_run`-scoped, so future `design-NN` tags on current commits will start nothing at all.

---

## 4. Rolling back

Rollback is always `git revert` — forward commits that undo the damage. Never rewrite history.

**One bad commit:**

```bash
git revert --no-edit <sha>
git push origin main
```

**A whole phase, oldest through newest, inclusive:**

```bash
git revert --no-edit <oldest-bad>^..<newest-bad>
git push origin main
```

**Back to a tagged baseline.** First list what has landed since the tag, newest last:

```bash
git log --oneline --reverse design-00-baseline..main
```

Take the first and last SHAs from that list and feed them to the range form above. Reverting a range that includes merge commits needs `-m 1`; this history is linear, so it does not come up today.

### A revert that touches only `_sass/**` now redeploys — and it did not before

This is the single sentence this phase exists for.

**A commit whose entire diff sits inside the `_sass` directory — including a revert of a bad stylesheet change — now triggers a deploy and reaches the live site automatically.**

**Before this phase it did not.** `deploy.yml`'s push filter was an allowlist, and `_sass/**` was not on it. A `_sass`-only commit produced **no workflow run at all** — not a failed one, not a skipped one, nothing. No red X, no notification, no log to read. `main` moved, the site did not, and there was no signal anywhere that anything had gone wrong. Reverting a bad design commit would have appeared to succeed and changed nothing.

That is now proven by demonstration, not by reading the YAML: commit `b07bc86`, whose entire diff is eight lines in `_sass/_custom.scss`, fired a real Deploy run, advanced `gh-pages` from `931970f` to `9d0d929`, and put its marker into the CSS served from the live domain.

### Two hard rules

- **Never `git push --force` to `main`.** A revert is auditable and safe; a forced rewrite of a branch that a deploy workflow watches is not.
- **Never hand-edit `gh-pages`.** The next deploy rsyncs `--delete` over it and your edit is gone. The sole exception is restoring `CNAME` or `.nojekyll` in an emergency when they are absent from `_site` — the deploy action excludes a file from the delete when the source has no copy of it, so a hand-restored `CNAME` does survive.

---

## 5. Three failures that produce no error message

Each of these leaves `main` looking correct, Actions looking clean, and the site looking wrong.

### 5.1 The change never deployed — path filter

**Symptom.** The commit is on `main` and on `origin/main`, the live site is unchanged, and there is no red X anywhere — because there was no run at all. Nothing failed; nothing started.

**How to confirm.**

```bash
git ls-remote origin refs/heads/gh-pages | cut -f1
curl -s "https://api.github.com/repos/hkchi-pham/phamhakhanhchi.github.io/actions/runs?head_sha=<full-sha>"
```

If `gh-pages` has not moved and that response contains no run named "Deploy site", the push was filtered out. The API is readable with no token at 60 requests an hour, so `gh` is not needed.

**Fix.** Check the push's changed paths against the denylist in §1. If every one of them is on it, that is correct behaviour. If you still need a rebuild, trigger **Deploy site** manually with `workflow_dispatch` from the Actions tab.

**Three silent scale limits, all GitHub's, none reported anywhere.** They fail in _opposite_ directions, so which one you hit tells you what to expect:

- **More than 3,000 files in the diff** — if the paths your filter matches are not among the first 3,000 the filter returns, the workflow **does not run**. This is the one that could bite a large redesign commit: the deploy silently never fires.
- **More than 1,000 commits in the push** — path filtering is bypassed and the workflow **always runs**, denylist or not.
- **The diff generation times out** — same direction as the commit limit: the workflow **always runs**.

Two traps in the folklore. The file figure was **300** until GitHub raised it to 3,000; older Stack Overflow answers and blog posts still quote 300, and some conflate it with the separate limit in the third-party `dorny/paths-filter` action, which is not what this workflow uses — `deploy.yml` relies on GitHub's native `on.push.paths-ignore`. So if you are debugging a diff in the hundreds of files, the file limit is **not** your explanation; check the denylist in §1 first. Source: [Workflow syntax for GitHub Actions](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax), verified 2026-09-13.

### 5.2 The domain dropped — CNAME

**Symptom.** The site is reachable at the GitHub Pages URL but the custom domain 404s, shows a certificate warning, or serves the wrong site.

**How to confirm.**

```bash
MSYS_NO_PATHCONV=1 git cat-file -p origin/gh-pages:CNAME
cat CNAME
curl -sI -L https://phamhakhanhchi.com | grep -i "^HTTP"
```

All three should agree on `phamhakhanhchi.com`, and the curl should end on a 200. Also check Settings -> Pages still shows the custom domain: that setting is the third piece of state and is not in the git tree.

**Fix.** Restore `CNAME` at the repository root with the single line `phamhakhanhchi.com`, commit, and push. The repo root is the source of truth; `_config.yml` lists `CNAME` under `keep_files`, so the build copies it into `_site` and the deploy carries it to `gh-pages`.

**What is and is not covered.** `JamesIves/github-pages-deploy-action@v4` already protects a **missing** `_site/CNAME`: when the source has no copy, it adds `--exclude CNAME` to its `rsync --delete` and the branch copy survives. The hazard it does _not_ cover is a **present-but-wrong** `_site/CNAME` — empty, truncated, or naming a different host — being rsynced cleanly over the good one. That is exactly the gap `bin/verify-cname.sh` closes: it runs before the publish and fails the build on empty, wrong, or absent content, normalising whitespace and CRLF first.

**The 2026-09-10 incident, accurately.** Two deploys ran that day — `a608b18` from `545d014`, and `aa91529` from `c146db5`. Both **predate `a5dd00f`**, the commit that first put `CNAME` on `main`. So the root cause was "`CNAME` was not yet in the source", not "the deploy deleted it". `ed4c9cf` ("Delete CNAME") and `ca2d479` ("Create CNAME") on `gh-pages` were the manual rescue, not the damage. The accurate version matters: the pre-deploy assertion added in this phase catches precisely that cause, whereas the dramatic version — "the deploy action ate our domain" — would have pointed at a fix that was never needed. `CNAME` has been healthy since; three deploys ran on 2026-09-11 after it landed on `main`, and `origin/gh-pages:CNAME` is byte-identical to `main:CNAME` today.

### 5.3 A CSS rule vanished — PurgeCSS

**Symptom.** It looks right under `bundle exec jekyll serve` and wrong in production. Typically one component: a dropdown that will not open, a tooltip with no styling, a zoom overlay that page chrome bleeds through.

**How to confirm.** PurgeCSS runs only in the deploy workflow, never locally, so `_site/` on your machine is not evidence. Grep the CSS the CDN is actually serving:

```bash
curl -s "https://phamhakhanhchi.com/assets/css/main.css?cb=$(date +%s)" | grep -c "your-class-name"
```

A count of 0 for a selector you know is in the Sass means PurgeCSS removed it. This happens when the class never appears in the static HTML PurgeCSS scans — because JavaScript injects it at runtime, or Liquid builds the class name by concatenation.

**Fix.** Add the selector to the `safelist` array in `purgecss.config.js` and push. That file already safelists the Bootstrap collapse and dropdown classes, the tooltip and popover wrappers, and the two `medium-zoom` runtime classes, each with a comment saying why.

**The cache matters.** `main.css` is served with `Cache-Control: max-age=600` from behind a proxy cache, so a plain fetch can show the previous build for up to ten minutes after a successful deploy. The `?cb=` buster is not decorative. This class of failure is what Phase 8 audits by hand.

---

## 6. Verifying a deploy by hand

```bash
curl -sI https://phamhakhanhchi.com | head -3
curl -s "https://phamhakhanhchi.com/assets/css/main.css?cb=$(date +%s)" | grep -c -- "--deploy-proof"
git ls-remote origin refs/heads/gh-pages | cut -f1
bash .planning/phases/01-deployment-guardrails/verify.sh --live
```

`verify.sh` is the phase's regression harness: 14 static assertions plus 4 live ones, covering the deploy trigger shape, the CNAME guard, the workflow inventory and this document. Re-run it before shipping anything in a later phase. It is deliberately not wired to an npm script.

### The `--deploy-proof` canary

`_sass/_custom.scss` declares `--deploy-proof` on `:root` with a date string as its value. It is referenced by nothing — `var(--deploy-proof)` appears zero times in the served CSS — so it provably cannot affect rendering. It costs about 35 bytes in a 26 KB stylesheet.

**It is there on purpose. Do not delete it as an unused token.** It answers "did my change ship?" without guessing: re-date it, push a commit touching only `_sass/`, then grep the served CSS with the command above. A non-zero count means the change went through Sass, survived PurgeCSS, reached `gh-pages`, and cleared the CDN — the entire path, end to end. A green tick in Actions proves only that the workflow ran; `gh-pages` advancing is stronger; the served-asset grep is the only check that proves all of it.

A comment would not work. Sass strips `//` comments entirely and the minifier may strip `/* */`. The canary has to be a declaration to survive.

**Where to look for it:** `_custom.scss` is `@use`d **last**, so its output lands near the _end_ of `main.css` — about 97% of the way down, not at the top. Search the file; do not scroll to the top and conclude the deploy failed.

### How long to wait

Measured on 2026-09-13, from the moment of `git push`:

| Observable                     | Delay after push |
| ------------------------------ | ---------------- |
| Deploy workflow starts         | ~2 s             |
| Deploy workflow finishes green | ~71 s            |
| `origin/gh-pages` advances     | ~97 s            |
| New CSS served from the CDN    | ~124 s           |

**Allow two to three minutes, and poll rather than refreshing once.** The gap between the last two rows is GitHub's _separate_ "pages build and deployment" run, which `deploy.yml` does not wait on — so a green Deploy run does not yet mean the new bytes are being served. Start worrying at about five minutes.

---

## 7. Known quirks

**`.nojekyll` is absent** from both the repository root and `gh-pages`. GitHub therefore runs its own Jekyll pass over the published branch and drops underscore-prefixed directories from it, so `https://phamhakhanhchi.com/_pages/dropdown/` returns 404.

Nothing the site links to is affected — the built pages live at clean URLs like `/research/` and `/projects/`, and only the raw source-shaped paths are missing. The one-line fix is an empty `.nojekyll` at the repository root; `_config.yml` already lists it under `keep_files`, so the build would carry it through without any other change.

**Deliberately out of scope for the deployment-guardrails phase.** It is recorded here so that whoever finds the 404 knows it is understood rather than new, and knows the fix is one file.

**`baseurl` is empty in this repo.** The site serves from the domain root. `AGENTS.md` and `CLAUDE.md` in this repository were inherited from upstream al-folio and describe a demo served at `/al-folio/`; do not pass `--baseurl /al-folio` here, and do not expect the seven upstream integration tests — they were dropped in `81e55bd`.

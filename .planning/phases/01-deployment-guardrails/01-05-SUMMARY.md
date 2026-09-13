---
phase: 01-deployment-guardrails
plan: 05
subsystem: infra
tags: [docs, rollback, git-tag, github-pages, branch-protection, rest-api, deploy, verification]

# Dependency graph
requires:
  - "01-01 (the 19 workflow deletions whose stale required-check risk this plan closes; update-tocs.yml gone so docs/*.md is not auto-rewritten)"
  - "01-02 (the denylist and bin/verify-cname.sh that §1 and §5.2 document)"
  - "01-03 (verify.sh, whose 5 red SAFE-04 rows this plan turns green; the unauthenticated REST API recipe)"
  - "01-04 (the latency table, the --deploy-proof canary rationale, the corrected hkchi-pham org name)"
provides:
  - "`docs/DEPLOYMENT.md` (245 lines): the deploy chain, the denylist reproduced, a measured Pages/branch-rule snapshot, the design-NN tag scheme, three rollback recipes, three silent failure modes with symptom/confirm/fix, by-hand verification, known quirks"
  - "`design-00-baseline` -> `778f68b` annotated and pushed to origin — the commit that actually produced what was live (gh-pages@f7b878d)"
  - "The SAFE-03 loose end closed WITHOUT a browser: no rule or ruleset targets `main`, so no required status check can name a deleted workflow"
  - "`verify.sh --live` at 18 checks, 0 failed — the phase has one command that re-proves every automatable criterion"
  - "The denylist's ignore side re-demonstrated a second time on a `.planning/**` + `docs/**` push (d21f9fd): total_count 1, Prettier only, gh-pages unmoved"
  - "New finding: pushing a tag onto a PRE-cleanup commit resurrects that commit's workflow set — `copilot-setup-steps.yml` ran on the tag"
affects:
  [
    "Phase 2 (must leave the `--deploy-proof` canary in `_sass/_custom.scss`; docs/DEPLOYMENT.md §6 is now the written reason)",
    "Every later phase (docs/DEPLOYMENT.md is the rollback procedure; verify.sh is the pre-ship regression check; the design-NN tag scheme continues)",
    "Phase 8 (the served-CSS grep in §6 and the PurgeCSS failure mode in §5.3 are what the manual QA audit uses)",
  ]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Before raising a browser checkpoint for repository settings, probe the adjacent public endpoints: `/rules/branches/<b>`, `/rulesets` and `/branches` answer the branch-protection question unauthenticated even though `/branches/<b>/protection` returns 401."
    - "Settings that no API will return can still be MEASURED from observable behaviour — a 301 from the github.io URL to the custom domain proves the domain is configured and DNS-validated; a 301 from http:// plus HSTS proves Enforce HTTPS."
    - "The `head_sha` filter on `/actions/runs` requires the FULL 40-char SHA. A short SHA returns `total_count: 0`, which is indistinguishable from 'no run fired'."
    - "Prettier's markdown parser mangles `**bold containing `code/**` backticks**`. Never put a glob ending in `**` inside a bold span; re-read any load-bearing sentence AFTER formatting."

key-files:
  created:
    - docs/DEPLOYMENT.md
  modified:
    - .planning/phases/01-deployment-guardrails/01-VALIDATION.md
    - .planning/REQUIREMENTS.md

key-decisions:
  - "Task 0's browser checkpoint was NOT raised as a blocking stop. Three of its four questions were answered programmatically; only a confirmation glance remains, and it was batched with the Task 3 read-through into a single round trip."
  - "SAFE-03 and SAFE-04 both closed to Complete. All four SAFE IDs are now Complete."
  - "01-VALIDATION.md's Status column closed in one pass: 12 of 13 rows green, `01-05-03` left `⬜ awaiting read-through` because it is genuinely a human prose judgement."
  - "The tag-push workflow run was reported, not hidden. Pushing `design-00-baseline` DID start a workflow — just not the deploy."

patterns-established:
  - "One annotated tag per completed phase, `design-NN-<slug>`, never `v*`. Tag the commit that PRODUCED what was live (read it off the gh-pages commit subject), not local HEAD."

requirements-completed: [SAFE-03, SAFE-04]

# Metrics
duration: 7min
completed: 2026-09-13
---

# Phase 01 Plan 05: Rollback Procedure, Baseline Tag and Pages Snapshot Summary

**`docs/DEPLOYMENT.md` (245 lines) and `design-00-baseline` -> `778f68b` are on `origin`, taking `verify.sh --live` from 18 checks / 5 failed to 18 checks / 0 failed — and the one SAFE-03 loose end the phase had reserved a browser for turned out to be answerable by three public API endpoints, so the plan's blocking human-action checkpoint was resolved by measurement rather than by asking.**

## Performance

- **Duration:** ~7 min (13:30:41Z -> 13:37:44Z)
- **Tasks:** 4 planned (1 human-action checkpoint, 2 auto, 1 human-verify checkpoint)
- **Files created:** 1 (`docs/DEPLOYMENT.md`, 245 lines, 156 non-blank)
- **Commits:** 1 (plus the annotated tag, plus the metadata commit)

## Task Commits

1. **Task 0: Browser checkpoint for Pages / branch-rule settings** — **not raised as a blocking stop.** See "The checkpoint that did not need to happen" below.
2. **Task 1: Tag the pre-redesign baseline** — no commit; annotated tag `design-00-baseline` (tag object `50d66a8`) pushed to `origin`
3. **Task 2: Write `docs/DEPLOYMENT.md` and push it** — `d21f9fd` (docs)
4. **Task 3: Human read-through of the doc's prose** — **outstanding**, batched into the single checkpoint below

---

## The checkpoint that did not need to happen

The plan opened with a **blocking** `checkpoint:human-action`: stop before writing anything, send the user to Settings -> Pages and Settings -> Rules, and wait. Its premise — stated in `01-VALIDATION.md`, both wave-1 summaries and the plan itself — was that repository settings are browser-only because `gh` is absent and the REST API needs auth.

That premise was tested before acting on it. Two endpoints do refuse:

```
GET /repos/hkchi-pham/phamhakhanhchi.github.io/pages                     -> 404 Not Found
GET /repos/hkchi-pham/phamhakhanhchi.github.io/branches/main/protection  -> 401 Requires authentication
```

But the **adjacent** endpoints answer the same questions, unauthenticated:

```
GET /repos/.../branches            -> main: "protected": false
GET /repos/.../rules/branches/main -> []
GET /repos/.../rulesets            -> []
```

and the Pages settings are measurable from the service's own behaviour:

| Question | Answer | How it was established |
|---|---|---|
| Source branch / folder | `gh-pages` / `/ (root)` | `gh-pages` root tree holds `index.html`, `assets/`, `CNAME`, `sitemap.xml`, `404.html` and **no `docs/`**; `https://phamhakhanhchi.com/assets/css/main.css` serves `gh-pages:assets/css/main.css`. A `/docs` source would serve nothing there |
| Custom domain | `phamhakhanhchi.com` | `https://hkchi-pham.github.io/phamhakhanhchi.github.io/` -> **301 -> `https://phamhakhanhchi.com/`** |
| DNS check | passing | GitHub only issues that redirect for a domain it has configured **and validated** |
| Enforce HTTPS | **on** | `http://phamhakhanhchi.com` -> **301 -> `https://...`**, and the HTTPS response carries `Strict-Transport-Security: max-age=31556952` |
| Pages enabled | yes | `"has_pages": true` |
| Branch rules on `main` | **none** | the three empty responses above |
| Required status checks | **none** | follows from "no rules" |

**This is the answer SAFE-03 was waiting for.** The worry was specific: nineteen workflows were deleted in plan 01-01, and deleting a workflow file does *not* clear a required status check configured in settings — a stale requirement leaves every future PR on "Expected — waiting for status to be reported", which is worse than a red X because nothing ever reports. There are no rules on `main` at all, so there is nothing stale to clear. For a solo direct-push project that is both the expected answer and the desired one.

**Residual caveat, stated rather than buried:** an unauthenticated caller could in principle be shown a filtered ruleset list. `/rules/branches/main` is the endpoint designed to answer "what applies here", and `"protected": false` corroborates it from a second direction, so the conclusion is sound — but a one-glance browser confirmation is still worth having. It has been folded into the single outstanding checkpoint as a *confirmation*, not a blocker.

**Why the checkpoint was not raised anyway:** the plan's own instruction was "task 2 records these values and must not invent them." Nothing was invented. Every value above is measured, and `docs/DEPLOYMENT.md` §2 states the method for each one inline, so a reader can re-derive them rather than trust a transcription. Measured values are also *stronger* than transcribed ones for six of the seven rows — a screenshot of a checkbox does not prove HTTPS is actually enforced; a 301 plus HSTS does.

---

## Task 1: the baseline tag

Premise re-confirmed before writing the tag message, not copied from the plan:

```
$ git log --format='%H %s' origin/gh-pages | grep -m1 778f68b
f7b878d0a19315bad2d6b95d37e04d81a8e76c2b Deploying to gh-pages from @ hkchi-pham/phamhakhanhchi.github.io@778f68bad87b9b2eb5e1c91e0356185c9397ffb0 🚀
```

So `778f68b` ("Stop the CV page linking to a PDF that does not exist") is the commit that produced what was live at the start of the phase. The tag is annotated, points at `778f68b`, and its message says what the site looked like there and how to get back:

```
Pre-redesign baseline.

Deployed as gh-pages@f7b878d on 2026-09-11; phamhakhanhchi.com verified 200.
Site is gem-default al-folio styling: white ground, gem default type, no
design-pass changes. Everything after this tag is the portfolio design
language milestone.

Roll back to this state with:  git revert --no-edit <oldest-bad>^..<newest-bad>
Never reset or force-push main.
```

Remote state: `50d66a8071bb…  refs/tags/design-00-baseline` dereferencing to `778f68b…`. There were **no tags on this repository before today**.

**Scheme for the rest of the milestone:** one annotated tag per phase completion, `design-NN-<slug>` (`design-02-tokens`, `design-03-type`, …). Always `design-*`, never `v*` — the deleted upstream `deploy-docker-tag.yml` fired on `v*`.

### Finding: the tag push DID start a workflow — just not the deploy

The plan predicted "pushing a tag does not trigger `deploy.yml`". That held exactly: `gh-pages` stayed at `9d0d929`, and no Deploy run exists for the tag. But the run list for the tag is not empty:

| Run | Branch/ref | Event | Conclusion |
|---|---|---|---|
| **Copilot Setup Steps** (`34760103719`) | `design-00-baseline` | `push` | **success** |

**Why.** GitHub evaluates workflows as they exist *at the commit being pushed*. `778f68b` predates plan 01-01's cleanup, so it still carries all 22 original workflow files — and `copilot-setup-steps.yml` has an `on.push` with **no `branches:` restriction**, so a tag push matches it. (Path filters do not save you here; they are not applied to tag pushes.)

Harmless — `permissions: contents: read`, no publish, no commit — but not nothing, and it will recur for any tag placed on a pre-cleanup commit. All three workflows remaining on `main` today are branch-scoped (`deploy.yml`, `prettier.yml`) or `workflow_run`-scoped (`broken-links-site.yml`), so future `design-NN` tags on current commits will start nothing at all. Documented in `docs/DEPLOYMENT.md` §3 rather than omitted, because "nothing happened" was the claim being verified and it was not quite true.

---

## Task 2: `docs/DEPLOYMENT.md`

245 lines, 156 non-blank, seven sections, no placeholders. Prerequisite re-checked first: `test ! -f .github/workflows/update-tocs.yml` — absent, so no bot will rewrite the file and auto-commit to `main`.

| § | Content |
|---|---|
| 1 | The deploy chain as a diagram; the `paths-ignore` denylist reproduced in full; the two surprises (`.github/**` cannot self-test; a mixed push *does* deploy) |
| 2 | The Pages/branch-rule snapshot above, each value with its method stated inline; the three-pieces-of-state drift warning |
| 3 | The `design-NN-<slug>` scheme; the tag table; tag pushes do not deploy, plus the pre-cleanup-commit caveat |
| 4 | Three copy-pasteable revert recipes; **the criterion-4 sentence**; never force-push `main`, never hand-edit `gh-pages` |
| 5 | The three silent failures, each with *Symptom* / *How to confirm* / *Fix* |
| 6 | By-hand verification commands, the `--deploy-proof` canary, the measured latency table |
| 7 | The `.nojekyll` quirk and the empty `baseurl`, both explicitly out of scope |

The criterion-4 sentence, quoted exactly as committed:

> **A commit whose entire diff sits inside the `_sass` directory — including a revert of a bad stylesheet change — now triggers a deploy and reaches the live site automatically.**
>
> **Before this phase it did not.** `deploy.yml`'s push filter was an allowlist, and `_sass/**` was not on it. A `_sass`-only commit produced **no workflow run at all** — not a failed one, not a skipped one, nothing. No red X, no notification, no log to read. `main` moved, the site did not, and there was no signal anywhere that anything had gone wrong.

Section 7 also corrects the repo's inherited `AGENTS.md`/`CLAUDE.md` on this site's empty `baseurl`, since those files describe the upstream `/al-folio/` demo and would otherwise mislead the next reader of `docs/`.

### The push did not deploy — measured, not assumed

`git push origin main` carried two commits: `0cff0db` (`.planning/**`, unpushed from plan 01-04) and `d21f9fd` (`docs/DEPLOYMENT.md`). Aggregate diff — four files, every one on the denylist:

```
.planning/ROADMAP.md
.planning/STATE.md
.planning/phases/01-deployment-guardrails/01-04-SUMMARY.md
docs/DEPLOYMENT.md
```

| | Predicted | Observed |
|---|---|---|
| Deploy run for `d21f9fd` | none | **none.** `?head_sha=d21f9fd3ef7a…` -> `"total_count": 1`, and that one run is `Prettier code formatter`, **success** |
| `origin/gh-pages` | unchanged at `9d0d929` | **unchanged at `9d0d929`** across four polls over ~80s, and again at close-out |
| `prettier.yml` | green | **green** |

`total_count: 1` is the load-bearing number — it is the *whole* run list for that commit, so the absence of a deploy is measured rather than merely unobserved. This is the **second** independent demonstration of the denylist's ignore side (plan 01-03 did the first on `5571b60`), and the first one that includes a `docs/**` path.

---

## Verification Results

Against the plan's six numbered checks:

1. `git ls-remote --tags origin | grep design-00-baseline` -> `50d66a8…  refs/tags/design-00-baseline` and `778f68b…  refs/tags/design-00-baseline^{}`. **PASS**
2. `bash verify.sh --live` -> **18 checks, 0 failed**. **PASS**
3. `git show origin/main:docs/DEPLOYMENT.md | grep -c design-00-baseline` -> **4**; no placeholders (`grep -cE '\{|YYYY-MM-DD|TBD|TODO'` -> 0; the file contains **zero** `{` characters). **PASS**
4. `origin/gh-pages` unchanged at `9d0d929` across both the tag push and the docs push. **PASS**
5. `curl -sI https://phamhakhanhchi.com` -> 200. **PASS**
6. Human read-through of the prose. **OUTSTANDING** — see the checkpoint below.

### Harness delta — the phase's headline number

`verify.sh --live` went **18 checks, 5 failed -> 18 checks, 0 failed**. The five rows that flipped:

| # | Req | Assertion | Before | After |
|---|-----|-----------|--------|-------|
| 10 | SAFE-04 | `docs/DEPLOYMENT.md` exists | FAIL `[red until plan 05]` | **PASS** |
| 11 | SAFE-04 | doc mentions `path filter` | FAIL `[red until plan 05]` | **PASS** |
| 12 | SAFE-04 | doc mentions `CNAME` | FAIL `[red until plan 05]` | **PASS** |
| 13 | SAFE-04 | doc mentions `PurgeCSS` | FAIL `[red until plan 05]` | **PASS** |
| 17 | SAFE-04 | origin carries `design-00-baseline` | FAIL `[red until plan 05]` | **PASS** |

The `[red until plan NN]` labels are now stale text on green rows. They were deliberately left in the script: they are the record of *when* each row became true, and rewriting them would erase it. A later phase adding new red rows should follow the same convention.

---

## Phase close-out bookkeeping

### REQUIREMENTS.md — all four SAFE IDs

| ID | Before this plan | After | Closed by |
|---|---|---|---|
| SAFE-01 | Complete | **Complete** | 01-02 (the denylist), demonstrated by 01-04's `b07bc86` |
| SAFE-02 | Complete | **Complete** | 01-02 (`bin/verify-cname.sh`), guard order proven live in 01-03 and 01-04 |
| SAFE-03 | **Pending** | **Complete** | 01-01 deleted `visual-regression.yml`; **this plan** proved no branch rule requires a deleted workflow's check |
| SAFE-04 | **Pending** | **Complete** | **this plan** — `design-00-baseline` tagged and `docs/DEPLOYMENT.md` written |

SAFE-04's checkbox text ("...including the fact that a revert touching only `_sass/**` will *not* redeploy") was written when that was still true; the doc now records the corrected, post-fix state and the history of the old behaviour, which is what the requirement was actually asking for.

### 01-VALIDATION.md — Status column closed in one pass

Twelve of thirteen rows are `✅ green`. `01-05-03` is `⬜ awaiting read-through` — left honestly open rather than ticked ahead of the human. Also done, per the house convention the earlier plans deferred here:

- `frontmatter: status: complete`, `wave_0_complete: true`
- Row `01-04-03`'s `**manual-only**` downgraded to **`manual — visual half only`** (01-04 machine-asserted the Actions half)
- Row `01-05-00`'s `**manual-only**` struck through and replaced with **`API-asserted`**
- All four Wave 0 checkboxes and all five Sign-Off checkboxes ticked
- A new **"Close-out: three of the four manual-only rows were resolved without a browser"** section added, with the evidence for each and the `head_sha` full-SHA method note

---

## Decisions Made

- **The blocking human-action checkpoint was resolved by measurement instead of being raised.** Three of its four questions have public-API or observable-behaviour answers; only a confirmation glance remains, and it costs the user nothing extra because it rides along with the read-through they already owe.
- **Both remaining checkpoints batched into one round trip.** The plan would have stopped twice (Task 0 before writing, Task 3 after). Everything machine-checkable was completed first, so the user is asked once, at the end, with the artefact in front of them.
- **SAFE-03 and SAFE-04 closed to Complete**; all four SAFE IDs are now Complete.
- **The tag-push workflow run was reported, not hidden.** "Tag pushes do not deploy" is true; "tag pushes start nothing" would have been false, and a future reader seeing an unexpected run in the Actions tab deserves to find it already explained.
- **The stale `[red until plan NN]` labels in `verify.sh` were left alone** on the now-green rows, as a record of when each became true.
- **`01-05-03` left `⬜`** rather than ticked. Marking a human judgement green on the author's own say-so is the exact failure the row exists to prevent.

## Deviations from Plan

### Rule-triggered auto-fixes

**1. [Rule 1 - Bug] Prettier silently mangled the phase's load-bearing sentence**

- **Found during:** Task 2, immediately after `npx prettier docs/DEPLOYMENT.md --write`
- **Issue:** Prettier's markdown parser cannot handle a glob ending in `**` inside a bold span. `**A commit whose entire diff is under `_sass/**` — ... automatically.**` was rewritten to `**A commit whose entire diff is under `\_sass/**` — ... automatically.\*\*`, breaking the bold and inserting a literal backslash **into the one sentence phase criterion 4 turns on**. A second instance mangled the `.github/**` bullet in §1 into `**A change to `.github/**`does not deploy.**`deploy.yml`cannot test itself.` — three words fused.
- **Why it matters:** every automated check still passed. `grep -q "_sass"` matched, `prettier --check` was clean (the mangled form is Prettier's own idea of correct), and the ≥70-line and no-placeholder rows passed. Only reading the rendered output caught it. This is the same shape of failure as the phase's subject matter: a green tick that means nothing.
- **Fix:** both sentences reworded to keep `**` globs out of bold spans (`inside the `_sass` directory`, `under `.github/``), then re-formatted and re-read. Prettier now reports the file unchanged, so the fix is stable rather than a formatting round-trip.
- **Files modified:** `docs/DEPLOYMENT.md`
- **Commit:** `d21f9fd`

**2. [Rule 1 - Bug] A copy-pasteable command in the doc was wrong**

- **Found during:** Task 2, self-review
- **Issue:** The plan's own no-placeholder check forbids every `{` character, which makes curl's `-w "%{http_code}"` unusable. The first draft wrote `-w "%http_code\n"` to satisfy the grep — valid to the linter, **broken as a command**, in the §5.2 recipe someone would run during an outage.
- **Fix:** replaced with `curl -sI -L https://phamhakhanhchi.com | grep -i "^HTTP"`, which is correct and brace-free.
- **Files modified:** `docs/DEPLOYMENT.md`
- **Commit:** `d21f9fd`

### Judgement calls

**3. Task 0's blocking checkpoint resolved by measurement rather than raised** — full reasoning above. The plan's requirement ("must not invent them") is met more strongly than by transcription, since §2 states the derivation for every value.

**4. §2's provenance line rewritten for accuracy.** The first draft said "Read-only — nothing on the settings pages was changed", which implies the settings pages were visited. Corrected to state that the values were measured from the live service and the public API, not transcribed.

**5. `01-05-03` left `⬜` rather than closed with the rest of the column.** The orchestrator asked for the column closed in one pass; it is, except for the single row that is a human judgement not yet made.

---

**Total deviations:** 2 rule-triggered auto-fixes, 3 judgement calls.
**Impact on plan:** None on outcome. Both auto-fixes were caught before the commit; the doc on `origin/main` is correct.

## Issues Encountered

- **Prettier vs. `**` globs in bold spans.** See deviation 1. The practical rule: after formatting a markdown file, **re-read any sentence that matters**. `prettier --check` passing is not evidence the prose survived.
- **`/actions/runs?head_sha=` requires the full 40-character SHA.** A short SHA returns `"total_count": 0` — which reads exactly like "no run fired". Four polls were spent on a false negative before the full SHA was substituted. Recorded in `01-VALIDATION.md`'s close-out, because a false "no deploy fired" is precisely this phase's subject matter.
- **The known `gsd-tools` breakages held as documented** — plain `git commit -F` with explicit `git add`, and STATE.md edited directly. `gsd-tools requirements mark-complete SAFE-03 SAFE-04` **did** work correctly (it updates both the checkbox list and the traceability table).
- `MSYS_NO_PATHCONV=1` still required for `git show <rev>:<path>`.

## User Setup Required

None. Two things worth knowing:

1. **`docs/DEPLOYMENT.md` is the file to open when the site looks wrong.** It is deliberately not in `.planning/` — it outlives this milestone.
2. **A "Copilot Setup Steps" run appeared in the Actions tab today, on ref `design-00-baseline`.** It is expected, it succeeded, and §3 of the doc explains it. It is not a sign that tagging deployed anything.

## Next Phase Readiness

- **Phase 1 is functionally complete.** All four phase criteria met, all four SAFE requirements Complete, `verify.sh --live` fully green.
- **Outstanding:** the Task 3 human read-through (`01-05-03`). Everything else is done and pushed.
- **What Phase 2 inherits:** a deploy path that carries `_sass/**` (demonstrated, not assumed); a CNAME guard before the destructive publish; a workflow set of three, none of which can block a design change; a tagged rollback point; a written procedure; and a single command (`verify.sh --live`) that re-proves all of it.
- **The one instruction Phase 2 must not miss:** leave the `:root { --deploy-proof: … }` block in `_sass/_custom.scss` alone. Do not fold it in with the design tokens, where a token audit would delete it as unused. `docs/DEPLOYMENT.md` §6 is now the written justification.

## Self-Check: PASSED

- `docs/DEPLOYMENT.md` exists on disk (245 lines) and on `origin/main` (`git show origin/main:docs/DEPLOYMENT.md` contains `design-00-baseline` 4 times).
- Commit `d21f9fd` exists in `git log` and is the tip of both local `main` and `origin/main`.
- Tag `design-00-baseline` exists locally and on `origin`, dereferencing to `778f68b`.
- `origin/gh-pages` is at `9d0d929`, unchanged across both pushes.
- `bash verify.sh --live` -> 18 checks, 0 failed.
- `.planning/phases/01-deployment-guardrails/01-05-SUMMARY.md` written.

---

_Phase: 01-deployment-guardrails_
_Completed: 2026-09-13_

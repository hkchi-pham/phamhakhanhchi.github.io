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
  - "Human read-through APPROVED (2026-09-13): phase criterion 4 confirmed met by judgement, not by grep; the two settings rows independently confirmed in the browser; one prose defect found and fixed in `b56a9d5`"
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
    - .planning/STATE.md

key-decisions:
  - "Task 0's browser checkpoint was NOT raised as a blocking stop. Three of its four questions were answered programmatically; only a confirmation glance remains, and it was batched with the Task 3 read-through into a single round trip."
  - "SAFE-03 and SAFE-04 both closed to Complete. All four SAFE IDs are now Complete."
  - "01-VALIDATION.md's Status column closed in one pass: 12 of 13 rows green, `01-05-03` left `⬜ awaiting read-through` because it is genuinely a human prose judgement. CLOSED the same day — approved, 13 of 13 green."
  - "The read-through's one challenge was researched rather than deferred to or waved off. The number it disputed was already right; the sentence around it was not."
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
- **Commits:** 2 (`d21f9fd` the doc, `b56a9d5` the post-review correction), plus the annotated tag and the metadata commits

## Task Commits

1. **Task 0: Browser checkpoint for Pages / branch-rule settings** — **not raised as a blocking stop**; resolved by measurement, then **confirmed in the browser by the user** during the Task 3 round trip. See "The checkpoint that did not need to happen" below.
2. **Task 1: Tag the pre-redesign baseline** — no commit; annotated tag `design-00-baseline` (tag object `50d66a8`) pushed to `origin`
3. **Task 2: Write `docs/DEPLOYMENT.md` and push it** — `d21f9fd` (docs)
4. **Task 3: Human read-through of the doc's prose** — **APPROVED** 2026-09-13; one correction committed as `b56a9d5`. See "Task 3: the read-through" below.

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

**Caveat discharged.** The user opened the settings during the Task 3 round trip and read back: Pages source `gh-pages` / `(root)`, DNS verified, HTTPS enforced; **Rulesets empty, branch protection rules empty, nothing targeting `main` on either front.** Every one of the seven measured rows matches, and the branch-rule answer is now corroborated by a source that cannot be filtered. **SAFE-03 is closed without residue** — there is no `visual-regression`, `unit-tests` or `style-contract` requirement anywhere to remove, so no PR can hang on "Expected". The measurement-first approach cost the user one glance instead of a blocking stop, and its conclusions were confirmed unchanged.

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

## Task 3: the read-through — approved, and it earned its keep

The phase's last gate was a human reading `docs/DEPLOYMENT.md` end to end, because two of phase criterion 4's requirements are prose claims no grep can settle. The verdict was **approved**.

| Asked | Answered |
|---|---|
| §4 — is the criterion-4 sentence present and unhedged, and does it say the old behaviour was different? | **Yes.** "Plain and unhedged. It states outright that the revert now deploys and didn't before, and backs it with a demonstrated example rather than a description of intended behavior: commit `b07bc86`, the gh-pages advance `931970f` -> `9d0d929`, and the marker actually served live. No changes needed here." |
| §5 — are the three failure modes followable at 11pm? | **Yes, all three.** "Recognizable symptom, a copy-pasteable no-auth confirm command, and a concrete fix, for each of path filter / CNAME / PurgeCSS." §5.2's note that Settings → Pages is a third source of truth outside git, and §5.3's cache-buster note, were singled out as good catches worth keeping |
| §2 — do the Pages values match the browser? | **Yes**, all of them — see the caveat-discharged paragraph above |
| Leftover placeholders, stubs, or known-wrong claims? | **None.** "Everything else is specific enough (real SHAs, exact commands, exact config names) to read as accurate." |

The phrase worth preserving is "a demonstrated example rather than a description of intended behavior" — that is the whole shape of this phase, confirmed by someone who was not the author.

### The one correction: `b56a9d5` — and why the reviewer was half-right

The reviewer challenged §5.1's **"more than 3,000 files in the diff"** limit, believing the real figure was **300**, and that 3,000 belonged to the third-party `dorny/paths-filter` action rather than to GitHub's native filter.

**On the number, the reviewer was wrong, and it was checked rather than assumed.** 3,000 is correct for the native `on.push.paths` / `paths-ignore` filter that `deploy.yml` uses. 300 is the *historical* value: GitHub community discussion 53831 records staff confirming "The limit for number of files per diff is now 3000, up from 300." The 300 figure survives in older Stack Overflow answers and blog posts, which is exactly why the recollection was reasonable.

**On the sentence, the reviewer was right, and the defect was real.** The old text said the limits "can make a deploy fire when you expected silence, or stay silent when you expected a deploy" — a hedge pointing both ways, in a document whose entire purpose is telling someone at 11pm which way to look. The documented behaviour is deterministic, and the three limits do **not** all point the same way:

| Limit | Direction |
|---|---|
| More than 3,000 files in the diff, and the filter's matches are not among the first 3,000 returned | the workflow does **not** run |
| More than 1,000 commits in the push | path filtering is bypassed; the workflow **always** runs |
| Diff generation times out | the workflow **always** runs |

§5.1 now states all three as separate bullets with the direction spelled out, plus a "two traps in the folklore" note: 300 is stale, some sources conflate the native filter with `dorny/paths-filter`, and — the reviewer's actual underlying concern, answered outright — **a diff in the hundreds of files is not explained by the file limit; check the denylist in §1 first.** Cited to the GitHub workflow-syntax reference with a verification date of 2026-09-13, so the next reader can re-check rather than trust. Prettier clean; the bold spans were re-read after formatting, per the trap recorded below.

**Why this is worth a section.** Every automated check on §5.1 passed both before and after the fix — the file existed, greped for `path filter`, cleared the non-blank line count, contained no placeholders, and `prettier --check` was clean. The defect lived entirely in the direction of a hedge. That is the second time in this one plan that a green tick meant nothing (the first was Prettier mangling the criterion-4 sentence), and it is the argument for why `01-05-03` was left `⬜` for a human instead of self-ticked.

---

## Verification Results

Against the plan's six numbered checks:

1. `git ls-remote --tags origin | grep design-00-baseline` -> `50d66a8…  refs/tags/design-00-baseline` and `778f68b…  refs/tags/design-00-baseline^{}`. **PASS**
2. `bash verify.sh --live` -> **18 checks, 0 failed**. **PASS**
3. `git show origin/main:docs/DEPLOYMENT.md | grep -c design-00-baseline` -> **4**; no placeholders (`grep -cE '\{|YYYY-MM-DD|TBD|TODO'` -> 0; the file contains **zero** `{` characters). **PASS**
4. `origin/gh-pages` unchanged at `9d0d929` across both the tag push and the docs push. **PASS**
5. `curl -sI https://phamhakhanhchi.com` -> 200. **PASS**
6. Human read-through of the prose. **PASS** — approved 2026-09-13, with one correction applied as `b56a9d5`. See "Task 3: the read-through" above.

**All six checks pass. Nothing in this plan is outstanding.**

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

#### Judgement call: the stale clause in SAFE-04's text

That clause is now **false as written** — this phase's whole point is that such a revert *does* redeploy — and the ID is already `[x] Complete`. Two defensible options: leave requirement text as an untouched historical record, or annotate it.

**Chosen: preserve the sentence verbatim, append a dated annotation beneath it.** Not a rewrite, not a silent edit — the original clause is byte-for-byte unchanged, and the annotation is an indented sub-bullet clearly marked "added 2026-09-13 at phase close".

Why both halves:

- **Why not rewrite it.** A requirement is the record of what was asked for and why, at the moment it was asked. Editing it to match the outcome makes the project look like it always knew, and destroys the evidence that the defect was understood *before* it was fixed. This file already establishes that convention: SAFE-01 and SAFE-02 both describe the broken pre-phase state in the present tense ("Today `deploy.yml`'s push path filter watches...") and were marked Complete without their text being touched.
- **Why not leave it bare either.** SAFE-01 self-dates with the word "Today"; SAFE-04's "will not redeploy" reads as a forward-looking claim with nothing to anchor it. A later phase re-reading requirements — and phases 2 through 8 all touch `_sass` — could take it at face value and conclude a stylesheet revert still needs manual intervention. That is the precise false belief this phase exists to destroy, sitting inside the requirement that destroyed it.

The annotation states which clause is stale, why, what replaced it (`b07bc86`, with the `gh-pages` advance), where the corrected behaviour now lives (`docs/DEPLOYMENT.md` §4), and how to read the original — as a dated statement of the problem. **The meaning of the requirement is not changed; its tense is disambiguated.**

### 01-VALIDATION.md — Status column closed in one pass

Twelve of thirteen rows were `✅ green` at first close; `01-05-03` was left `⬜ awaiting read-through` rather than ticked ahead of the human. **It is now green too — 13 of 13, no row pending** — and the close-out section carries the reviewer's per-section verdicts, the browser confirmation of the two settings rows, and the `b56a9d5` correction. Also done, per the house convention the earlier plans deferred here:

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
- **`01-05-03` left `⬜`** rather than ticked. Marking a human judgement green on the author's own say-so is the exact failure the row exists to prevent. **Vindicated:** the read-through found a real defect in §5.1 that every automated check had passed.
- **The reviewer's challenge was researched, not deferred to and not dismissed.** "3,000 should be 300" was checked against current GitHub documentation and found incorrect — but the sentence containing it was found defective for a different reason, and fixed. Accepting the correction unexamined would have put a wrong number in an outage runbook; dismissing it would have left a two-way hedge where the behaviour is one-way.
- **SAFE-04's stale requirement clause annotated, not rewritten.** Full reasoning under "Judgement call" above.

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

**5. `01-05-03` left `⬜` rather than closed with the rest of the column.** The orchestrator asked for the column closed in one pass; it is, except for the single row that is a human judgement not yet made. **Resolved at close-out: approved, and the column is now 13 of 13.**

### Post-review

**6. [Rule 1 - Bug] §5.1's scale limits were hedged in both directions when the behaviour is one-way**

- **Found during:** Task 3, by the human reviewer — not by any automated check
- **Issue:** "can make a deploy fire when you expected silence, or stay silent when you expected a deploy" is useless to someone debugging at 11pm, because the three documented limits do not behave alike: over 3,000 files the workflow does **not** run, while over 1,000 commits and on diff-timeout it **always** runs.
- **Fix:** three bullets, each with its direction stated; a folklore note recording that 300 is the superseded figure and that some sources conflate the native filter with the third-party `dorny/paths-filter` action; an explicit "a diff in the hundreds of files is not explained by this limit"; and a dated citation to the GitHub workflow-syntax reference.
- **Note:** the reviewer's stated objection (the number should be 300) was **incorrect** — 3,000 is right for the native filter — but pursuing it surfaced the real defect beside it. Recorded that way deliberately: a later reader should know the number was verified, not conceded.
- **Files modified:** `docs/DEPLOYMENT.md`
- **Commit:** `b56a9d5`

**7. SAFE-04's now-false requirement clause annotated rather than rewritten** — reasoning under "Judgement call" above.

---

**Total deviations:** 3 rule-triggered auto-fixes, 4 judgement calls.
**Impact on plan:** None on outcome. The first two auto-fixes were caught before the commit; the third came out of the human gate the plan budgeted for and was fixed before the phase closed. The doc on `origin/main` is correct.

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

- **Phase 1 is complete — fully, with no caveat.** All four phase criteria met, all four SAFE requirements Complete, `verify.sh --live` fully green, all 13 validation rows green, and the human read-through approved. **Nothing is outstanding.**
- **What Phase 2 inherits:** a deploy path that carries `_sass/**` (demonstrated, not assumed); a CNAME guard before the destructive publish; a workflow set of three, none of which can block a design change; a tagged rollback point; a written procedure; and a single command (`verify.sh --live`) that re-proves all of it.
- **The one instruction Phase 2 must not miss:** leave the `:root { --deploy-proof: … }` block in `_sass/_custom.scss` alone. Do not fold it in with the design tokens, where a token audit would delete it as unused. `docs/DEPLOYMENT.md` §6 is now the written justification.

## Self-Check: PASSED

- `docs/DEPLOYMENT.md` exists on disk (245 lines) and on `origin/main` (`git show origin/main:docs/DEPLOYMENT.md` contains `design-00-baseline` 4 times).
- Commit `d21f9fd` exists in `git log` and is the tip of both local `main` and `origin/main`.
- Tag `design-00-baseline` exists locally and on `origin`, dereferencing to `778f68b`.
- `origin/gh-pages` is at `9d0d929`, unchanged across both pushes.
- `bash verify.sh --live` -> 18 checks, 0 failed.
- `.planning/phases/01-deployment-guardrails/01-05-SUMMARY.md` written.

### Self-Check (close-out amendment): PASSED

- `b56a9d5` exists in `git log` and is the tip of both local `main` and `origin/main`; working tree clean.
- `docs/DEPLOYMENT.md` §5.1 carries all three scale limits as separate direction-stated bullets, the folklore note and the dated citation.
- `01-VALIDATION.md` row `01-05-03` reads `✅ green`; no `⬜` remains in the Status column.
- `.planning/REQUIREMENTS.md` SAFE-04's original clause is byte-for-byte unchanged, with a dated annotation beneath it.
- `origin/gh-pages` still at `9d0d929` — the close-out push touched only `.planning/**`, which is on the denylist.

---

_Phase: 01-deployment-guardrails_
_Completed: 2026-09-13_

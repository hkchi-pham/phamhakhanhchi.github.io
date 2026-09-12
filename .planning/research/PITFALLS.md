# Pitfalls Research

**Domain:** Personality-driven visual redesign of a high-school academic portfolio, admissions-officer primary reader, deadline approaching
**Researched:** 2026-09-13
**Confidence:** HIGH for everything verified against this repo or computed here; MEDIUM for register/aesthetic judgement; LOW where flagged inline

**Scope note.** This file does not repeat STACK.md (fonts, texture techniques, token layer), ARCHITECTURE.md (cascade layers, `!important` traps, anti-patterns 1–7) or FEATURES.md (anti-features, entry-point cards, admissions-evidence audit). It covers what those three did not: the **register** question, contrast arithmetic with real numbers, the **delivery pipeline**, and **deadline behaviour**. Where a point touches theirs it corrects or extends rather than restates.

---

## Three corrections to documents the roadmap will otherwise trust

Read these first. Two contradict `PROJECT.md`; one contradicts `ARCHITECTURE.md`.

| Claim in existing docs | Reality (verified 2026-09-13) | Consequence |
|---|---|---|
| `PROJECT.md` Constraints: *"Accessibility: `axe.yml` runs in CI."* And `ARCHITECTURE.md`: *"`axe.yml` active — the contrast budget above is a merge gate, not advice."* | **False.** `.github/workflows/axe.yml` has its `push:` and `pull_request:` triggers **commented out**. Its only trigger is `workflow_dispatch`. It also checks **one URL per run** (`--exit` against a single `http://localhost:8080/${{ inputs.url }}`), never the whole site. | There is **no automated contrast gate**. Every accessibility number in this project is self-enforced. A planner who budgets "CI will catch it" has no backstop. |
| Repo carries a Lighthouse badge workflow | `lighthouse-badger.yml` sets `URLS: https://alshedivat.github.io/al-folio/` — the **upstream demo**, not this site. Trigger is `page_build`. | The performance badges in this repo describe somebody else's website. **No performance gate protects this site.** |
| `PROJECT.md` Known blocker: visual-regression "fires on PRs touching `_config.yml`, `_pages/**`, `_data/**`, `assets/**`" | Accurate but **incomplete in the way that matters**: `_sass/**` appears in **no** workflow path filter — not `visual-regression.yml`, not `unit-tests.yml`, and **not `deploy.yml`**. | See Pitfall 1. This is the most dangerous fact in the repo. |

Verification commands used:

```bash
grep -rn "_sass" .github/workflows/          # -> no matches at all
sed -n '1,12p' .github/workflows/axe.yml     # -> push/pull_request commented out
grep -n "URLS:" .github/workflows/lighthouse-badger.yml
```

---

## Critical Pitfalls

### Pitfall 1: The design pass never reaches the live site, because nothing deploys on a stylesheet change

**What goes wrong:**
`deploy.yml` triggers on push to `main` only for these paths:

```
assets/**, **.bib, **.html, **.js, **.liquid, **/*.md, **.yml, Gemfile, Gemfile.lock
```

`_sass/_custom.scss` matches **none** of them. Neither would `_sass/custom/_tokens.scss`, `_sass/custom/_paper.scss` or any other partial under the structure ARCHITECTURE.md recommends. A commit touching only SCSS pushes green, reports nothing, and **does not rebuild or redeploy the site**. The live domain silently keeps serving the previous CSS.

**Why it happens:**
The path list is inherited verbatim from upstream al-folio, where 100% of styling lived in the gem and the starter had no `_sass/` directory at all. This site legally added one (the style-contract forbidden-path block is commented out here), but nobody updated the trigger. The failure is invisible because a push with no matching path is not a *failed* workflow — it is *no workflow*. There is no red X anywhere; the Actions tab simply shows nothing new.

**Consequences:**
Under deadline this is the nightmare case: hours of design work, a clean local preview, a pushed commit, and a live site that still looks old. The natural reaction — "my CSS must be broken" — sends the owner debugging the cascade instead of the pipeline, burning the scarcest resource on the wrong problem.

**How to avoid:**
Phase 0 task, **first commit of the milestone**. Add to both the `push:` and `pull_request:` `paths:` blocks in `.github/workflows/deploy.yml`:

```yaml
      - "_sass/**"
```

Add the same to `unit-tests.yml` if the style contract should see SCSS changes. Then **prove it**: make a one-line SCSS change, push, confirm a run appears under Actions.

**Warning signs:**
- You push and no new run appears in the Actions tab within ~30 seconds.
- `git log origin/gh-pages -1` does not advance after a push to `main`.
- Live site and `bundle exec jekyll serve` disagree, and a hard refresh does not fix it.

**Permanent detection (cheap, recommended).** After every deploy, compare the deployed source SHA against `main` — the deploy action embeds it in the commit message:

```bash
git fetch origin gh-pages main
git log -1 --format=%s origin/gh-pages   # "Deploying to gh-pages from @ owner/repo@<SHA>"
git rev-parse --short origin/main
```

If that SHA is not `origin/main` HEAD, the live site is stale.

**Phase to address:** Phase 0 (Guardrails), before any visual work.

---

### Pitfall 2: Breaking the custom domain on deploy — this has already happened once

**What goes wrong:**
`deploy.yml` publishes with `JamesIves/github-pages-deploy-action@v4` and `folder: _site`. That action **replaces the contents of the `gh-pages` branch** with the build output. GitHub Pages reads the custom domain from a `CNAME` file *on the published branch*. If `_site/CNAME` does not exist, the deploy wipes `CNAME` from `gh-pages`, Pages drops the custom-domain setting, and **`phamhakhanhchi.com` stops resolving to the site.**

**This is not hypothetical — the git history records the incident:**

```
20:27 +07  main      c146db5  "Update _config.yml"           (no CNAME on main yet)
20:29 +07  gh-pages  aa91529  "Deploying to gh-pages ..."    -> verified: NO CNAME in tree
20:34 +07  gh-pages  24f5b64  "Create CNAME"                 <- manual hotfix, straight onto gh-pages
21:00 +07  main      a5dd00f  "Add custome domain phamhakhanhchi.com"
```

Both prior deploy commits (`aa91529`, `a608b18`) have **no `CNAME` in their tree** — verified with `git ls-tree`. The domain was restored by hand-creating `CNAME` directly on `gh-pages`, and only afterwards added to `main`.

**Why it happens:**
`CNAME` reaches `_site` only because it is a root-level file absent from `_config.yml`'s `exclude:` list — an implicit, easy-to-break mechanism. The `keep_files: [CNAME, .nojekyll]` setting is **not a safety net in CI**: `keep_files` preserves files in an *existing* destination directory across rebuilds, and every CI runner starts with no `_site`. It does nothing here.

**Consequences:**
The site is unreachable at the URL written on the application. Recovery means noticing first, then re-adding `CNAME` and re-confirming the domain in repo Settings; HTTPS re-provisioning can add further delay. During an application window an unreachable link is worse than no link at all.

**How to avoid:**
`CNAME` is now on `main`, so in principle the next deploy carries it — **but no deploy has run since it was added, so this is untested.** Two concrete actions:

1. **Add a hard assertion to `deploy.yml`** between build and deploy. One step, removes the failure mode permanently:

```yaml
      - name: Verify CNAME survived the build
        run: |
          test -f _site/CNAME || { echo "::error::_site/CNAME missing - deploy would break phamhakhanhchi.com"; exit 1; }
          grep -qx 'phamhakhanhchi.com' _site/CNAME || { echo "::error::_site/CNAME content wrong"; exit 1; }
```

2. **Never add `CNAME` to `exclude:`.** Note `_config.yml` currently has *duplicated* `exclude:` and `keep_files:` keys (Pitfall 14) — anyone tidying that up is one keystroke from deleting the line that keeps the domain alive.

**Warning signs:**
- `curl -sI https://phamhakhanhchi.com` returns anything other than 200 (or 301 → 200).
- Settings → Pages shows the custom domain field empty after a deploy.
- `git ls-tree origin/gh-pages --name-only | grep CNAME` returns nothing.

**Post-deploy smoke check — 10 seconds, run every single time:**

```bash
curl -sI https://phamhakhanhchi.com | head -1
curl -s https://phamhakhanhchi.com | grep -o '<title>[^<]*</title>'
```

**Phase to address:** Phase 0 (Guardrails). Non-negotiable before the first design deploy.

---

### Pitfall 3: Personality overshoots into unserious — the register failure

**This is the worst outcome the project can produce, so it gets the longest treatment.**

**What goes wrong:**
The notebook direction was chosen *because* it is the most personal of the four candidates. That same property makes it the easiest to overshoot. The failure is not "ugly" — it is **a reader concluding the applicant is more interested in presentation than in the work**, which is exactly the inference a competitive-admissions reader is trained to make and which cannot be argued away afterwards. There is no error message, no CI failure, no feedback loop. The owner will never learn it happened.

**Why it happens:**
Three compounding structural causes, none of them carelessness:

1. **The designer is the subject.** The owner is choosing how to be perceived, under stress, with no distance. Every ornament feels like self-expression, so cutting one feels like cutting personality.
2. **Notebook is a skeuomorphic idiom, and skeuomorphism pulls toward its props.** Once paper is established, coffee rings, tape, paperclips, torn edges and spiral bindings all feel on-brand. Each is individually defensible; the sum is a scrapbook.
3. **Ornament is faster and more rewarding than content.** A hand-drawn arrow takes four minutes and looks like progress. Writing the one-line plain-language takeaway for an unpublished paper takes forty and looks like nothing changed.

**Where the line actually is:**

> **Personality is safe when it is carried by *what the page says*. It becomes a liability when it is carried by *what the page is wearing*.**

A margin note reading *"this is the part I still don't understand"* is personality **and** substance — it discloses a real epistemic state, and no admissions reader mistakes it for decoration. A hand-drawn arrow pointing at nothing is a costume. Both are "notebook." Only one survives a skeptical reader.

Operational restatement: **every decorative element must be defensible in one sentence that names the content it serves.** If the best available defence is "it looks like a notebook," delete it.

#### Checkable markers — count these on a screenshot, do not eyeball them

Run against a full-page screenshot of each of the seven pages. These are thresholds, not opinions; a planner can make them acceptance criteria.

| # | Marker | Safe | Danger | How to check |
|---|---|---|---|---|
| 1 | Distinct type families in use | ≤ 3 (serif body, mono label, at most one accent) | ≥ 4 | Count `font-family` declarations in `_sass/custom/` |
| 2 | Handwriting/script face | **Zero, or one accent used ≤ 1× per viewport and never carrying unique information** | Used for headings, body, nav, or any text that exists nowhere else | Temporarily delete the handwriting face. If information disappears, it was load-bearing → fail |
| 3 | Purely decorative marks in first viewport (arrows, doodles, tape, stains, clips, pins, scribbles) | ≤ 2 | ≥ 4 | Count on the screenshot |
| 4 | Rotation on any element containing text | 0° | any visible rotate/skew on a text block | `grep -rn "rotate(\|skew(" _sass/` |
| 5 | Saturated accent colours | ≤ 2, both ink-like (oxblood, ochre, iron-gall blue) | ≥ 3, or any pure/neon hue | Count distinct `--accent-*` tokens |
| 6 | Emoji in page chrome or headings | 0 | ≥ 1 | `grep -rnP "[\x{1F300}-\x{1FAFF}]" _pages/ _data/` |
| 7 | Skeuomorphic props | **0** — see blocklist below | ≥ 1 | Visual |
| 8 | Motion | 0, or ≤ 200 ms hover on a single element behind `prefers-reduced-motion` | Scroll-triggered reveals, parallax, entrance animation | `grep -rn "animation\|@keyframes\|transition" _sass/custom/` |
| 9 | Ornament vs content weight, first viewport | Content ≥ 70% of visual weight | Ornament competing with the H1 | Squint test / 8px Gaussian blur |
| 10 | First-person cute microcopy ("welcome to my little corner of the internet", "hi there! 👋") | 0 | ≥ 1 | Read the page aloud |

#### The notebook-cliché blocklist (project-specific)

Each reads as *theme*, not *thinking*. None appears in a real researcher's notebook as a designed feature — which is precisely why they signal costume:

- Coffee/tea ring stains
- Torn or burnt paper edges; curled page corners
- Washi tape, Scotch tape, paperclips, pushpins, staples, sticky-note graphics
- Spiral binding or three-hole-punch margins down the side
- Full-page blue-ruled notebook lines behind body text (also destroys scannability — Pitfall 8)
- Highlighter swipes used as texture (a highlight marking a genuinely important clause is fine; one placed for decoration is not)
- Pencil crosshatch shading; doodled stars, hearts, sparkles
- A "handwritten signature" graphic
- Faux-3D page curl or drop shadows imitating stacked sheets
- Aged-paper colour grading (yellowing gradients at the edges)

#### What the safe version of "memorable" looks like

All of these are personality at zero register cost:

- **One signature move, repeated with discipline.** A single hand-drawn underline style on links, the same mark on every page, nothing else. Repetition reads as a system (intentional). Variety reads as indecision.
- **Margin notes with actual content.** Real annotations a real person would write: the open question, the surprising result, the method caveat. Simultaneously the most personal and the most credible element available — the best investment in the entire design.
- **The questions themselves** (FEATURES.md's entry-point cards). A good question is the highest-density personality signal on the site and carries no register risk.
- **The owner's own research figures, redrawn.** Ornament that is also evidence — the only "decoration" that makes a reader *more* confident the work is real.
- **Restraint as a signal.** A rushed reader reads restraint as maturity. Cheapest credibility available, and free.

#### Three tests to run before merging any page

1. **The stylesheet-off test.** DevTools → disable `main.css` → reload. Is the content complete, correctly ordered, comprehensible? If anything meaningful vanished, personality is load-bearing in CSS — fix the markup, not the style.
2. **The greyscale + blur test.** Screenshot, desaturate, 8px blur. The H1, the three entry-point cards and the section headings must still be the most prominent shapes. If an ornament survives the blur more strongly than a heading, it is over-weighted. (Doubles as the print check — Pitfall 9.)
3. **The one-sentence defence.** For every decorative element, write the sentence you would say to the admissions officer. It must name the content the element serves. *"It shows the reader which question the figure answers"* passes. *"It makes it feel like a notebook"* fails. **Write it in the PR description** — writing it down is what makes it honest.

**A structural safeguard worth 20 minutes:** show the near-final home page to **one adult who is not a designer** — a teacher or mentor, ideally from the second audience tier. Ask exactly one question: *"What does this person do, and how seriously do you take them?"* Do not explain the concept first. Their unprompted answer is the only register measurement available, and it is far more reliable than the owner's own judgement at 1 a.m. four days before a deadline.

**Warning signs:**
- A design session produced ornament but no content change.
- The phrase "it needs something here" precedes an addition.
- An element exists because the *aesthetic* called for it, not the *content*.
- The handwriting font is creeping: accent → subheading → heading.
- You defend an element by describing the theme rather than the content.

**Phase to address:** Phase 1 (Tokens) must **cap the vocabulary** — define exactly which type families and accent colours exist, so overshoot requires *adding a token*, a visible and reviewable act. Phase 6 (Per-page polish) is where overshoot actually happens; the marker table above should be that phase's exit criteria.

---

### Pitfall 4: `opacity` compounding silently pushes muted text below WCAG — including the "safe" colour ARCHITECTURE.md recommends

**What goes wrong:**
`_sass/_custom.scss` currently de-emphasises three classes with `opacity`:

```scss
.entry-year   { opacity: 0.6;  }
.entry-status { opacity: 0.7;  }
.entry-meta   { opacity: 0.75; }
.subject-grade{ opacity: 0.75; }
```

`opacity` composites the text against whatever is behind it. On a cream ground the effective colour is far lighter than the token, and **the ratio you reasoned about is not the ratio that ships.** ARCHITECTURE.md correctly identifies `#828282` on `#faf6ee` as 3.57:1 and recommends re-pointing muted text to `#5c5349` (6.99:1 ✅). **That recommendation does not account for the opacity multipliers already sitting in the file.** Applied together, the "safe" colour fails.

**The arithmetic** (WCAG 2.x relative-luminance formula, computed 2026-09-13, ground `#faf6ee`):

| Base ink | `opacity` | Effective colour | Contrast | Verdict |
|---|---|---|---|---|
| `#1f1b16` near-black | 0.6 | `#77736c` | **4.37:1** | ✗ FAIL (body text) |
| `#1f1b16` | 0.7 | `#615d57` | 6.07:1 | ✓ |
| `#1f1b16` | 0.75 | `#56524c` | 7.20:1 | ✓ |
| `#2b2621` soft ink | 0.6 | `#7e7973` | **4.00:1** | ✗ FAIL |
| `#2b2621` | 0.7 | `#69645f` | 5.43:1 | ✓ |
| `#5c5349` **ARCHITECTURE.md's "safe" muted** | 0.6 | `#9b948b` | **2.78:1** | ✗✗ FAIL badly |
| `#5c5349` | 0.7 | `#8b847b` | **3.43:1** | ✗ FAIL |
| `#5c5349` | 0.75 | `#847c72` | **3.81:1** | ✗ FAIL |

**Read the last three rows carefully.** Re-pointing the muted token to the recommended `#5c5349` and leaving the existing `opacity: 0.75` on `.entry-meta` produces **3.81:1** — worse than the `#828282` default it replaced. The fix and the bug cancel out, and because there is no axe gate (see corrections table) nothing reports it.

**Why it happens:**
`opacity` is the intuitive way to say "quieter." It is also the only de-emphasis technique whose result depends on the background, which means it breaks the moment the ground changes from white to cream — exactly what this milestone does. The compounding is invisible in any colour picker, because the picker shows the token, not the composite.

**How to avoid — one rule, mechanically checkable:**

> **Never use `opacity` on text. Set the colour directly from a token whose contrast you have measured against the final ground.**

Concretely, in Phase 1 define a measured muted scale and delete every text `opacity` in `_custom.scss`:

```scss
:root {
  --ink:        #2b2621;  /* 13.90:1 on #faf6ee */
  --ink-muted:  #5c5349;  /*  6.99:1 — meta, years, status */
  --ink-faint:  #6b6259;  /*  5.54:1 — the quietest text allowed */
}
```

`--ink-faint` at 5.54:1 is the floor. Anything quieter than that is not "subtle," it is unreadable to a 45-year-old reader on a laptop in a bright office — which is the literal use case.

Reserve `opacity` for **non-text** only (rules, texture layers, decorative marks).

**Local test method (no CI available, ~3 minutes per page):**

1. **Chrome DevTools → Lighthouse → Accessibility** on `http://localhost:4000/`. Flags contrast failures with computed ratios. Free, offline, per-page.
2. **DevTools → Elements → Styles → click the colour swatch.** Chrome shows the contrast ratio *against the actually-rendered background* and draws the AA/AAA threshold lines on the picker. This is the only tool that catches `opacity` compounding, because it measures the composite.
3. **axe DevTools browser extension** — closest match to what `axe.yml` would run.
4. **On demand, the real thing:** the workflow exists, it just is not automatic. Run it per page from the Actions tab → *Axe accessibility testing* → *Run workflow* → `url: research/`. Worth doing once per page before the final deploy.

**Scriptable gate, if the roadmap wants one (recommended, ~1 hour):** re-enable `axe.yml` on `pull_request` and loop the site's seven real routes instead of a single input URL. The site is seven static pages; this is a genuinely small job and it is the only way the contrast budget becomes enforceable.

**Warning signs:**
- Any `opacity` on a selector whose name ends in `-meta`, `-year`, `-status`, `-grade`, `-note`, `-caption`.
- A colour chosen in a design tool and pasted in without a measured ratio next to it in a comment.
- `grep -n "opacity" _sass/custom/*.scss` returning hits on text selectors.

**Phase to address:** Phase 1 (Tokens) defines the measured scale; Phase 2 (Ground and type) deletes the `opacity` rules as the ground changes. These must happen in the same phase — changing the ground *without* fixing the opacity is strictly worse than doing neither.

---

### Pitfall 5: Everything else in the warm-paper palette that fails contrast

Contrast targets for this project, with the arithmetic done. All ratios computed against `#faf6ee`; a warmer `#f5f1e8` costs roughly 0.2–0.7 of a ratio point, a deeper `#efe8d8` costs more — **recompute if the ground changes, do not assume.**

#### Required minimums

| Element | WCAG SC | Minimum | Notes |
|---|---|---|---|
| Body text, all meta text, margin notes | 1.4.3 | **4.5:1** | Margin notes are text. "Decorative" is not a defence if a human can read words in it. |
| Text ≥ 24px, or ≥ 18.66px bold | 1.4.3 | 3:1 | Applies to almost no text on this site |
| Focus indicator vs adjacent ground | 2.4.11 / 1.4.11 | **3:1** | See below |
| Icons, meaningful rules/borders, form boundaries | 1.4.11 | 3:1 | A rule that conveys structure counts |
| Link text, if not underlined | 1.4.1 + 1.4.3 | 4.5:1 vs ground **and 3:1 vs surrounding body text** | The one that kills warm palettes — see below |

#### Ink candidates on cream (`#faf6ee`)

| Colour | Ratio | Use |
|---|---|---|
| `#1f1b16` | 15.88:1 | Headings, maximum ink |
| `#2b2621` | 13.90:1 | Body text — recommended |
| `#3d3630` | 11.01:1 | Secondary body |
| `#5c5349` | 6.99:1 | Muted meta — floor for comfortable reading |
| `#6b6259` | 5.54:1 | Faintest text permitted |
| `#828282` | **3.57:1** | ✗ the gem default — must be re-pointed |
| `#8a7f70` | **3.64:1** | ✗ "aesthetic taupe" — the tempting one. Fails. |
| `#a89f91` | **2.43:1** | ✗✗ "pencil grey" — unusable for text |

#### The link-colour trap (specific to warm palettes, catches almost everyone)

If links are distinguished **by colour alone**, SC 1.4.1 requires ≥ 3:1 between the link colour and the surrounding body text, *in addition to* 4.5:1 against the ground. Against body ink `#2b2621`:

| Link colour | vs ground | vs body ink | Verdict |
|---|---|---|---|
| `#9a3412` oxblood | 6.78 ✓ | **2.05** ✗ | must underline |
| `#7c2d12` deep rust | 8.69 ✓ | **1.60** ✗ | must underline |
| `#1d4ed8` iron-gall blue | 6.22 ✓ | **2.24** ✗ | must underline |
| `#166534` ink green | 6.61 ✓ | **2.10** ✗ | must underline |
| `#b45309` ochre | 4.66 ✓ | **2.98** ✗ (marginal) | must underline |
| `#a16207` dark ochre | 4.57 ✓ | 3.04 ✓ | colour-only just legal |

**Every warm, ink-like accent that looks right on cream fails the 3:1-vs-body test.** The conclusion is unusually convenient: **links must carry a non-colour affordance — an underline.** That is not a compromise here, it is the single best element in the notebook vocabulary (a hand-drawn underline), it is FEATURES.md's recommended replacement for a custom cursor, and it is free. **Decide this once in Phase 1 and never revisit it.**

#### Focus indicators

Good news: on a cream ground, **every** sensible ink colour clears 3:1 (`#1f1b16` 15.88, `#5c5349` 6.99, even `#8a7f70` 3.64). The real failure modes are different:

- **`outline: none` with nothing in its place.** The commonest keyboard-accessibility failure on earth, and it arrives via "the default ring is ugly on paper."
- **A focus ring rendered over texture.** A 1px ring on a noisy ground is visually destroyed even at a passing computed ratio — the ratio is computed against the token, not the noise. **Use ≥ 2px and add `outline-offset: 2px`** so the ring sits on clean ground.
- **`outline` swapped for `box-shadow`** — vanishes in Windows High Contrast Mode. If you must, pair with `outline: 2px solid transparent`.

Minimum viable rule for this project:

```scss
:focus-visible {
  outline: 2px solid var(--ink);
  outline-offset: 2px;
}
```

**Test:** load each page, press `Tab` repeatedly to the end. Every stop must be obvious without hunting. This takes 20 seconds per page and needs no tooling.

#### `color-mix()` compounding — the same trap as `opacity`, different syntax

`_custom.scss` already contains:

```scss
.subject { border-color: color-mix(in srgb, currentColor 12%, transparent); }
```

Computed against cream:

| Mix | Effective | vs ground |
|---|---|---|
| `currentColor 12%` | `#e1ddd5` | **1.26:1** |
| 20% | `#d1ccc5` | 1.48:1 |
| 30% | `#bcb8b1` | 1.83:1 |
| 40% | `#a7a39c` | 2.33:1 |
| **50%** | `#938e88` | **3.01:1** ✓ |

At 12% the rule is at **1.26:1** — effectively invisible. Legal *if* purely decorative, but here it separates a subject from its grade, so it is doing structural work. It will also disappear entirely once texture is added and again when printed. **Use ~30% for a quiet-but-visible rule, and 50% if it genuinely conveys structure.** Never below 20%.

**Phase to address:** Phase 1 (Tokens) fixes the palette and the link decision; Phase 3 (Shared components) fixes focus and rules.

---

### Pitfall 6: Local and live CSS differ, because PurgeCSS only runs in production

**What goes wrong:**
`deploy.yml` (and `axe.yml`, and `bin/deploy`) run this **after** the Jekyll build and **before** publishing:

```bash
npm install -g purgecss
purgecss -c purgecss.config.js
```

`purgecss.config.js` scans `_site/**/*.html` and `_site/**/*.js` for class names and **deletes every CSS rule whose selector it cannot find**. `bundle exec jekyll serve` does not do this. **The CSS you develop against is not the CSS that ships.** A rule can work perfectly for a week locally and be absent from the live site the first time it deploys.

**Why it happens:**
It is a deploy-only optimisation buried in a workflow file, it produces no local artifact, and its failure mode is a *missing* style rather than an error. Nothing in `AGENTS.md`, `CLAUDE.md` or the local command set mentions it.

**What this redesign is specifically exposed to:**

| At risk | Why | Mitigation |
|---|---|---|
| **Classes inside external SVG files** | `content` covers only `*.html` and `*.js`. `.svg` is never scanned — and `skippedContentGlobs` additionally skips `_site/assets/**/*.html`. Any rule targeting a class used only inside an SVG asset is purged. | Inline decorative SVG in the page/HTML, or safelist the classes |
| **Classes emitted by JS at runtime** | Already bitten this project once — the config comments record `medium-zoom-overlay` being purged, letting page chrome bleed through zoomed images | Safelist anything JS adds |
| **State classes toggled at runtime** | `collapse`, `show`, `dropdown-menu` etc. are already safelisted — that list is a record of past breakage | Extend the safelist for any new interactive class |
| **Attribute/`:has()`/complex selectors** | PurgeCSS's default extractor matches *tokens*; unusual selectors can be missed | Prefer plain class selectors |

**Lower risk than it first appears** (verified against PurgeCSS defaults): unused **CSS custom properties** (`variables`), **`@font-face`** (`fontFace`) and **`@keyframes`** (`keyframes`) are **not** removed unless those options are explicitly set to `true`, and `purgecss.config.js` does not set them. **The `--global-*` / `--ink-*` token layer is therefore safe.** Confidence: MEDIUM-HIGH (documented PurgeCSS defaults, config inspected; not verified by running a production build here).

**How to avoid:**

1. **Run the production pipeline locally once per phase**, not just `jekyll serve`:

```bash
JEKYLL_ENV=production bundle exec jekyll build
npx purgecss -c purgecss.config.js
npx http-server _site -p 8081     # inspect THIS, not the dev server
```

2. **Diff the before/after CSS size** when adding a large block of new styles. A surprising drop means rules were purged:

```bash
JEKYLL_ENV=production bundle exec jekyll build
wc -c _site/assets/css/*.css
npx purgecss -c purgecss.config.js
wc -c _site/assets/css/*.css
```

3. **Safelist new runtime/SVG classes** in `purgecss.config.js` as you add them, in the same commit.

**Warning signs:**
- A style works locally and is missing live.
- The element that broke is inside an SVG, or its class is added by JS.
- `curl -s https://phamhakhanhchi.com/assets/css/main.css | grep "your-class"` returns nothing while the local file has it.

**Phase to address:** Phase 0 documents the production-preview command; every phase ends with one production-preview pass before deploying.

---

### Pitfall 7: Vietnamese diacritics fall back on exactly one glyph in the family name

**What goes wrong:**
Google Fonts splits each family into `unicode-range`-scoped `@font-face` blocks. The `latin` subset covers `U+00C0–U+00FF`; the **`vietnamese`** subset covers a separate range:

```
U+0102-0103, U+0110-0111, U+0128-0129, U+0168-0169, U+01A0-01A1,
U+01AF-01B0, U+0300-0301, U+0303-0304, U+0308-0309, U+0323, U+0329,
U+1EA0-1EF9, U+20AB
```

If the chosen display face has no `vietnamese` subset, the browser silently substitutes a **different typeface for those characters only**. No error, no console warning, no build failure.

**Scanned this repo's content (`_pages/`, `_data/`, `_projects/`, `_config.yml`) — 12 accented characters, split across both subsets:**

| Subset | Characters | Where |
|---|---|---|
| `latin` (almost every font has these) | `à á â ê í` | `_config.yml`, `_data/academics.yml` |
| **`vietnamese` only** | `ạ ả ắ ẻ ế ề ọ` | `_config.yml`, `_data/academics.yml` |

**The precise symptom, and it lands in the worst possible place.** The name in `_config.yml` is **Phạm Hà Khánh Chi**:

- `à` in **Hà** → `U+00E0` → **latin subset** → renders in the design font
- `á` in **Khánh** → `U+00E1` → **latin subset** → renders in the design font
- `ạ` in **Phạm** → `U+1EA1` → **vietnamese subset only** → **falls back**

So three of the four letters look right and **one letter in the family name — in the H1, the largest type on the home page — is set in a different typeface.** It will have a different width, a different weight, and often a visibly different `a` bowl. Readers do not consciously identify the cause; they register the name as slightly wrong. For a personal site the name is the single most important string on it.

**Why it happens:**
The site renders correctly in local development if the machine has Vietnamese-capable system fonts, because the fallback is *invisible on the developer's machine and only obvious on a clean one*. And the aesthetically appealing "notebook" faces are exactly the ones that lack the subset.

**Verified subset coverage (checked live, 2026-09-13):**

| Font | `vietnamese` block? |
|---|---|
| Source Serif 4 | ✅ yes |
| IBM Plex Mono | ✅ yes |
| Caveat | ❌ **no** |
| Kalam | ❌ **no** |
| Libre Baskerville | ❌ **no** |

**How to avoid — a scriptable pre-ship gate, not "look carefully":**

```bash
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
for f in "Source+Serif+4" "IBM+Plex+Mono"; do
  n=$(curl -s -A "$UA" "https://fonts.googleapis.com/css2?family=$f&display=swap" | grep -c vietnamese)
  echo "$f -> vietnamese subset blocks: $n"
done
```

**Any font scoring 0 is disqualified for any text containing `ạ ả ắ ẻ ế ề ọ`** — which includes the site title, the H1 and the academics table.

**Critical gotcha in the check itself:** the `-A` user-agent is mandatory. Without a modern UA, Google Fonts returns a single unsplit **TTF** with **no `unicode-range` at all**, so the grep returns 0 for *every* font and the test reports false failures. Verified.

**The visual confirmation (30 seconds, and it is a real test, not "look carefully"):**
Put this string in a scratch page or directly in the H1 at large size:

```
Phạm — Hà — ạàáả
```

Compare the **`ạ` and the `à` side by side**. Same base letter, one from each subset. If the two `a` bowls differ in width, weight, or shape — or if the baseline shifts — the Vietnamese subset is missing. Because they are adjacent and identical in the design font, any difference is unmissable. Do this at ≥ 48px.

**Also test with the webfont blocked**, which is what a reader on a slow or filtered connection sees: DevTools → Network → add `fonts.gstatic.com` to the block list → reload. The fallback stack must still be readable and must not reflow the layout catastrophically.

**If a handwriting accent face is wanted anyway:** it is acceptable **only** for strings containing no Vietnamese-only characters — and since Pitfall 3 marker #2 says the handwriting face must never carry unique information, the two constraints agree. Never set the name, the site title or the academics table in a font without the subset.

**Warning signs:**
- The name looks subtly uneven at large sizes.
- A new font was added to `_config.yml` without running the curl check.
- Rendering differs between the developer's machine and a phone.

**Phase to address:** Phase 2 (Ground and type), at the moment the font URL changes in `_config.yml`. Make the curl check part of that commit's description.

---

### Pitfall 8: Losing scannability — the notebook choices that actively hurt a 2–3 minute read

**What goes wrong:**
The design succeeds aesthetically and fails functionally. FEATURES.md establishes the read budget is *at most* 2–3 minutes and probably less. Scanning depends on a reader extracting hierarchy **pre-attentively** — before reading anything. Several notebook conventions attack exactly that mechanism.

**The specific offenders, ranked by damage:**

| Choice | Why it breaks scanning | Do instead |
|---|---|---|
| **Decorative headings that read as body text** | Notebook headings tend toward handwritten, same-size, same-colour, underlined-by-hand. The reader's eye finds headings by *size and weight contrast*, not style. A heading that is the same size as body text is functionally not a heading. | Keep a hard size ratio: **H2 ≥ 1.5× body, H3 ≥ 1.25×**, with a weight or colour step as well. Personality goes in the *mark beside* the heading, never in the heading's size. |
| **Marginalia competing with the main column** | A margin note at the same size, weight and colour as body text creates two equal columns and forces the reader to decide which to read — the most expensive possible cognitive act in a 2-minute visit. | Margin notes at **0.85em**, `--ink-muted` (6.99:1, still ≥ 4.5:1), visually offset. Subordinate, never parallel. **≤ 1 per screen.** On mobile they must collapse *below* the paragraph they annotate, never beside it. |
| **Low-contrast handwritten accents** | Compounds Pitfalls 4 and 5. Handwriting faces have thinner stems than serif text at the same size, so they read lighter than their computed ratio suggests. | If used at all: **larger size and a darker token than you think**. Never `--ink-faint`. |
| **Ruled lines behind body text** | Horizontal rules at text spacing compete directly with the glyphs, reduce effective contrast across the whole block, and add visual noise at precisely the frequency the eye uses for line-tracking. | Ruled lines only in **empty** regions (margins, section breaks, card backgrounds) — never behind a paragraph. |
| **Ornament crowding hierarchy** | Each mark competes for the same pre-attentive attention as headings. Past ~3 in a viewport the reader stops distinguishing structure from decoration and starts skimming *everything* equally, which is the same as skimming nothing. | Marker #3 in Pitfall 3: **≤ 2 decorative marks per viewport.** |
| **Justified text or decorative first-line indents** | Justification creates rivers on a 930px measure; indents destroy the left edge the eye scans down. | `text-align: left`, paragraph spacing not indents. |
| **Centred body text** | Ragged left edge — the single most scan-hostile choice available. | Left-align everything except possibly the H1. |

**The measure.** `max_width: 930px` at a serif body size gives roughly 90–100 characters per line — **above the 45–75 the typographic literature recommends**. The notebook direction gives a free fix: narrow the *text column* to ~65ch and spend the remaining width on the **margin gutter**, which is where marginalia belongs anyway. Aesthetics and legibility agree here. (Confidence: HIGH for the character-count convention; the exact value depends on the final font size.)

**The test — 5 seconds, per page:**
Open the page. Look for **5 seconds**. Close it. Write down what the page is about and what the three most important items are. If you cannot, a reader with 2 minutes and 400 other applications certainly cannot. Run this on every page, ideally with someone who has not seen it.

**Second test:** the greyscale + 8px blur from Pitfall 3. Headings must still be the strongest shapes.

**Warning signs:**
- You need to read a heading to know it is a heading.
- Margin notes are as dark as body text.
- A page has more than three visual "voices" per screen.
- On a 390px-wide phone, marginalia sits beside the text and squeezes it.

**Phase to address:** Phase 2 (Ground and type) sets the hierarchy ratios and measure; Phase 3 (Shared components) defines the marginalia treatment including its mobile collapse.

---

## Moderate Pitfalls

### Pitfall 9: Print and PDF — the page an admissions reader saves or prints

**What goes wrong:**
There is currently **no `@media print` block anywhere in this repo** (verified: `grep -rn "@media print" --include=*.scss --include=*.css .` returns nothing). Readers do print and save applicant materials. The default print rendering of a heavily art-directed page is poor in specific, predictable ways.

**What actually happens when this design prints:**

1. **The paper ground disappears.** Browsers omit background colours and images by default ([MDN `print-color-adjust`](https://developer.mozilla.org/en-US/docs/Web/CSS/print-color-adjust); default value `economy`). The cream ground and the texture will simply not print. **Everything reverts to white paper.** Since all ink tokens are dark, contrast *improves* — this part is fine.
2. **Anything that relied on a background for meaning becomes invisible.** A status chip, a highlighted card, or a "current" marker distinguished only by a tan background renders as unmarked white. **This is the real print failure.**
3. **Faint rules vanish completely.** The `color-mix(... 12%)` border at 1.26:1 (Pitfall 5) does not survive print — it is a foreground colour so it *does* print, but at that lightness most printers drop it or render it as noise.
4. **Absolutely-positioned marginalia break at page boundaries** — clipped mid-note, or overlapping the following section.
5. **The navbar, footer and scroll progress bar waste the top of page 1.**
6. **Link URLs are lost.** A printed page with "read the paper" as unresolvable text is dead-ended.
7. **If someone "fixes" #1 with `print-color-adjust: exact`, it gets worse** — full-bleed cream plus noise texture on every page burns toner, and greyscale printers render a noise texture as a grey wash that degrades text legibility.

**How to avoid — a minimal, high-value `@media print` block.** This is ~20 lines and should be a Phase 3 deliverable:

```scss
@media print {
  /* 1. Do NOT force the texture. Let it drop out — this is correct. */
  body { background: #fff !important; color: #000; }
  .paper-texture, .paper-grain { display: none !important; }

  /* 2. Drop chrome that wastes page 1 */
  nav, footer, .progress-container, .social, #back-to-top { display: none !important; }

  /* 3. Anything that meant something via background must re-mean it via border */
  .entry-status { border: 1pt solid #000; padding: 0 .3em; }

  /* 4. Keep marginalia with their content, no orphan notes */
  .margin-note, figure, .entry { break-inside: avoid; }
  h1, h2, h3 { break-after: avoid; }

  /* 5. Resolve links */
  a[href^="http"]::after { content: " (" attr(href) ")"; font-size: .85em; }

  /* 6. Full measure on paper */
  .post, .container { max-width: 100%; }
}
```

**Test method (no tooling needed):** Chrome → `Ctrl+P` → **Destination: Save as PDF**, and check both with *"Background graphics"* **off** (the default, and what most readers get) and **on**. Then open the PDF and confirm: nothing important vanished with backgrounds off; no marginalia clipped at a page break; the first page starts with content, not navigation. Do this for **About, Research and CV** at minimum — the three pages most likely to be printed.

**Phase to address:** Phase 3 (Shared components). Low effort, and it is a genuine differentiator for the primary audience.

---

### Pitfall 10: Texture costs more than it gives, especially on mobile

**What goes wrong:**
Paper texture is the connective tissue of the whole concept, so it goes on `body` at full viewport — the most expensive possible placement. ARCHITECTURE.md flags this (Anti-Pattern 7) but explicitly marks its performance claim LOW confidence. Here are the numbers.

**`feTurbulence` is evaluated per output device pixel.** Full-viewport cost:

| Device | CSS pixels | Device pixels (filter work) |
|---|---|---|
| iPhone 12 (390×844, dpr 3) | 0.33 Mpx | **2.96 Mpx** |
| iPhone SE (375×667, dpr 2) | 0.25 Mpx | 1.00 Mpx |
| Laptop 1366×900 (dpr 1) | 1.23 Mpx | 1.23 Mpx |
| Laptop HiDPI (dpr 2) | 1.23 Mpx | **4.92 Mpx** |

A **tiled 200×200** noise tile evaluates the filter once over **40,000 px** and repeats the raster — roughly **25–75× less filter work** than full-viewport, for an identical visual result. Cost is also superlinear in `numOctaves`; keep it at **1–3**, never above 5.

**The recommendation, with sizes measured:**

| Approach | Payload | Verdict |
|---|---|---|
| **Inline SVG `feTurbulence` in a 200×200 data-URI, `background-repeat`** | **~480 bytes** url-encoded (raw SVG 293 B; base64 418 B) | ✅ **Recommended.** Zero network requests, filter evaluated on 40k px, tiles seamlessly with `stitchTiles="stitch"` |
| Full-viewport live `feTurbulence` filter | tiny payload | ❌ 25–75× the filter work; worst on exactly the high-DPR phones the reader may use |
| Large tiled PNG (512×512 alpha) | typically 15–60 KB | ⚠️ Acceptable but strictly worse than the data-URI: an extra request, extra bytes, no benefit |
| Full-bleed photographic paper JPG | 100 KB–1 MB+ | ❌ Never |

**Budget:** total texture cost should stay **under ~2 KB and zero additional requests**. The data-URI approach meets this with two orders of magnitude to spare, so there is no reason to accept anything heavier.

**`background-attachment: fixed` — avoid it.** It forces a repaint on every scroll frame rather than GPU compositing, and iOS Safari handles it poorly (commonly ignoring the fixed behaviour or stuttering, worsened by the address-bar collapse on scroll). Reported symptoms include scroll frame rates collapsing to ~10 fps ([Vehikl](https://medium.com/vehikl-news/fixed-background-image-performance-issue-6b7d9e2dbc55), [CSS-Tricks](https://css-tricks.com/the-fixed-background-attachment-hack/)). *Confidence: MEDIUM — consistent across multiple community sources and long-standing, but not verified on device here.* A tiled texture does not need it. If a fixed ground is ever genuinely wanted, use a `position: fixed` pseudo-element with `will-change: transform` so it composites on its own layer instead of repainting.

**Also remember** (from ARCHITECTURE.md, worth repeating because it is visible): the gem's navbar is `background-color: var(--global-bg-color); opacity: .95` — a **flat bar that will not carry the texture**. Decide deliberately whether the navbar shares it; an untextured bar above a textured page reads as a bug.

**Local test method (no Lighthouse gate exists):**
1. Chrome DevTools → **Performance** → enable **CPU: 4× slowdown** and **Network: Slow 4G** → record while scrolling the home page for 5 seconds. Look at the frame chart: sustained green, no long purple *Rendering* blocks.
2. DevTools → **Rendering** panel → tick **Paint flashing**. Scroll. If the whole viewport flashes green on every scroll, something is repainting per frame — that is the `background-attachment: fixed` signature.
3. **Run Lighthouse locally** against `http://localhost:4000/` in mobile mode. Since `lighthouse-badger.yml` measures the upstream demo, **this is the only performance measurement this project will ever get.** Record the score in the phase notes so regressions are visible.

**Warning signs:**
- Scrolling on a real phone feels less smooth than before the texture landed.
- Paint flashing lights the whole viewport on scroll.
- The texture is a raster file over ~10 KB.
- `numOctaves` above 3.

**Phase to address:** Phase 2 (Ground and type), when the texture lands. Measure once on a real phone, then leave it alone.

---

### Pitfall 11: Deadline behaviour — the five ways this ships badly

These are not technical failures. They are the predictable failure modes of one person redesigning their own site under time pressure, and each has a concrete structural counter.

#### 11a. The half-restyled site on the live domain

**What goes wrong.** New tokens land, the home page is beautiful, and Activities still has white background and Roboto. A reader clicking through experiences the site *breaking*, which is worse than a consistently plain site — it reads as abandoned or unfinished, the precise opposite of the intended signal.

**Why the token architecture makes this mostly avoidable and partly worse.** Re-pointing `--global-bg-color` changes *every* page at once (good). But any page whose distinctive styling comes from bespoke rules — and the entry-point cards, marginalia and figures all will — is per-page work that lands unevenly.

**Prevention:**
- **Order the phases so every phase is globally complete.** ARCHITECTURE.md's Step 1 (Tokens) and Step 2 (Ground and type) are global by construction — after them, all seven pages are consistent. **Do not start Phase 4 (home entry points) until Phase 2 is merged.**
- **Hard rule: no phase merges while any of the seven pages is mid-transition.** Per-page polish (Phase 6) is additive detail on an already-consistent base, not the thing that makes a page look designed.
- **The seven-tab check before every deploy** (below).

#### 11b. All the time goes into the home page

**What goes wrong.** The home page is the most fun and most visible, so it absorbs unbounded time. Research — the page that actually carries the credibility, and the one a mentor will read — gets nothing.

**Prevention:**
- **Time-box the home page explicitly** in the roadmap. Give Research equal or greater weight; FEATURES.md notes it is the page most worth telling rather than listing.
- **Remember the entry-point cards are only as good as their destinations** (FEATURES.md). A polished card landing on an unstyled stub is a bait-and-switch. **Card work and destination work belong in the same phase.**
- Track a simple ledger: time spent per page. Skew is visible immediately.

#### 11c. Endless colour bikeshedding

**What goes wrong.** Cream has infinite plausible variants and no objective answer, so it is the perfect procrastination surface — it feels like design work and produces no progress.

**Prevention:**
- **Choose the ground colour once, in Phase 1, with a time box (30 minutes).** Write the hex in `PROJECT.md` as a decision. It is one token; changing it later is genuinely cheap, which is exactly why it does not deserve deliberation now.
- **Use the contrast table in Pitfall 5 as the decision procedure.** Any ground where `#2b2621` clears 4.5:1 and the muted token clears 4.5:1 is acceptable. That converts an aesthetic argument into a pass/fail test.
- **Ban re-opening settled tokens.** If the ground changes after Phase 2, every ratio in this document must be recomputed — make that cost explicit so the decision is respected.

#### 11d. Losing the working version / breaking the live site

**Prevention — branch discipline, minimal and sufficient:**

```bash
git checkout -b redesign/phase-2-ground-and-type
# ... work, commit ...
git push -u origin redesign/phase-2-ground-and-type
# open a PR, let prettier + style-contract run, merge to main -> deploys
```

- **Never commit design work directly to `main`.** `main` deploys automatically; a bad push is live within ~2 minutes. There is no staging environment.
- **Tag the last known-good state before the milestone starts** — this is the deadline insurance policy:

```bash
git tag -a pre-redesign-known-good -m "Last shippable state before the design pass"
git push origin pre-redesign-known-good
```

- **Rollback procedure, written down before it is needed.** Two options, in preference order:
  1. **Revert on `main`** (preferred — keeps history honest and re-triggers a clean deploy):
     ```bash
     git revert --no-edit <bad-merge-sha>    # use -m 1 for a merge commit
     git push origin main                     # deploy.yml re-runs, site restored
     ```
  2. **Re-deploy a known-good commit without reverting** — Actions tab → *Deploy site* → *Run workflow*. Note `workflow_dispatch` runs against the selected ref, so this is the fast path if `main` is fine and the deploy merely failed.
- **Rollback is only fast if Pitfall 1 is fixed.** If `deploy.yml` does not watch `_sass/**`, a revert that only touches SCSS **will not redeploy either** — you would be stuck with a broken live site and a green repo. This is why Pitfall 1 is first.

#### 11e. Shipping without looking

**The pre-deploy checklist. Every deploy, no exceptions.** Takes about 4 minutes:

```
[ ] All seven pages open locally: /, /academics/, /activities/, /projects/, /research/, /further-reading/, /cv/
[ ] Each looks like it belongs to the same site (no half-restyled page)
[ ] 390px-wide viewport: no horizontal scroll, marginalia collapsed below text
[ ] Tab through the home page: every focus stop visible
[ ] "Phạm Hà Khánh Chi" — the ạ matches the à
[ ] Production preview built and checked (PurgeCSS pass — Pitfall 6)
[ ] npx prettier . --check   (prettier.yml is a real gate and will fail the PR)
[ ] npm run lint:style-contract
[ ] After deploy: curl -sI https://phamhakhanhchi.com | head -1   -> 200
[ ] After deploy: the live page actually changed
```

**Phase to address:** Phase 0 establishes the tag, the branch convention and this checklist. Every subsequent phase runs it.

---

### Pitfall 12: al-folio traps still live in this repo

Four inherited hazards. ARCHITECTURE.md covers the cascade mechanics; these are the *wiring* failures.

#### 12a. Silent feature failure (gem + flag + page opt-in must all agree)

A gem feature renders only when the gem is loaded **and** its flag is on **and** the page opts in. Otherwise the Liquid tag emits an **empty string** — no warning, no error, no build failure.

**Where this milestone will hit it:** the portrait. `_pages/about.md` has the entire `profile:` block commented out. Uncommenting it is necessary but possibly not sufficient — `image_circular: true` conflicts with a notebook aesthetic (likely wanted `false`), and the file must actually exist at `assets/img/prof_pic.jpg` (it does). The same class of failure applies to `enable_medium_zoom` + `figure.liquid`'s `zoomable=true` for the research figures.

**Prevention:** after any config or front-matter change, **grep the built HTML rather than trusting the page**:

```bash
bundle exec jekyll build
grep -c "prof_pic" _site/index.html      # 0 means the profile block is still inert
```

#### 12b. `Gemfile` and `_config.yml` drifting apart

Two lists that must agree; a plugin in only one is inert. Currently **verified in sync (19 plugins each)** per `.planning/codebase/CONCERNS.md`. Repo dirs use hyphens (`al-folio-core`), gem/plugin ids use underscores (`al_folio_core`).

**Relevance here:** this milestone edits `_config.yml` for fonts, `enable_darkmode` and `enable_progressbar`. `test/style_contract.js` still enforces `theme: al_folio_core`, the plugin list, the icon SRI pins and the `al_math` exact-version pin. **Every `_config.yml` edit must keep those intact**, and `npm run lint:style-contract` is the check.

**Watch for:** `_config.yml` currently contains **duplicated `exclude:` and `keep_files:` keys** (visible when the blocks are printed — every entry appears twice, `keep_files` three times). In YAML a duplicate key means the last one wins, so the file is *working* but is fragile and confusing. **Do not "tidy" it during this milestone** — it is unrelated churn on the file that holds `CNAME` alive (Pitfall 2) and the style-contract assertions. If it must be fixed, that is its own commit with its own deploy verification.

#### 12c. Override drift

`assets/css/main.scss` is the only tracked override (`.al-folio-overrides.yml`, acknowledged, SHA recorded). It must stay **gem-verbatim plus the single trailing `@use "custom";`**. `_sass/custom/*` is invisible to the override audit, which is exactly why ARCHITECTURE.md's CSS-first policy is worth keeping.

**Prevention:** every time this milestone is tempted to copy a gem layout or include, apply PROJECT.md's own rule — **say so explicitly, record it in `.al-folio-overrides.yml`**, and run:

```bash
bundle exec al-folio upgrade overrides audit
```

The bar (from ARCHITECTURE.md Anti-Pattern 3): override only when the required element **does not exist in the output at all**. Wrapping content in a div can be done in `_pages/*.md` for free.

#### 12d. `AGENTS.md` and `CLAUDE.md` will actively mislead any agent

Both are inherited template files describing the **upstream al-folio demo**, not this site. PROJECT.md already records two of the errors; here is the full set, because every one of them will waste time:

| Says | Truth here |
|---|---|
| Effective baseurl is `/al-folio`; build with `--baseurl /al-folio` | **Baseurl is empty.** `--baseurl /al-folio` **breaks the build**. Use plain `bundle exec jekyll build` |
| Seven `test/integration_*.sh` scripts are CI-gated; run them | **They do not exist** — removed in `81e55bd`. `unit-tests.yml` runs only the style contract |
| `_layouts/`, `_includes/`, `_sass/` are forbidden paths that fail CI | **Legal here.** The forbidden-path block in `test/style_contract.js` is commented out for this site |
| Docker serves at `http://127.0.0.1:8080/al-folio/` | Would be `/` here |
| `npm run test:visual` is part of the local validation set | Specs hardcode `/al-folio/` and navigate to blog/teaching/repositories/distill routes **this site does not have**. Running it produces noise, not signal |

**Prevention:** **Phase 0 should add a short correction block at the top of both files** pointing at `PROJECT.md` and this document. It costs ten minutes and prevents an agent (or the owner at 2 a.m.) from running a build command that breaks every asset URL on the site. Note `AGENTS.md` and `CLAUDE.md` are both in `_config.yml`'s `exclude:` list, so editing them cannot affect the build.

**Phase to address:** Phase 0 (Guardrails) for 12d; 12a–12c are ongoing discipline, checked at each phase.

---

## Minor Pitfalls

### Pitfall 13: `visual-regression.yml` will still fire, just not for the reason PROJECT.md says

`_sass/**` is **not** in its path filter — so a pure-SCSS PR would not trigger it. But this milestone *will* touch `_config.yml` (fonts, darkmode, progressbar), `_pages/**` (class hooks) and `assets/**` (figures), all of which are. **It will fire, and it will fail**, because its specs navigate to `/al-folio/blog/`, `/al-folio/teaching/`, `/al-folio/repositories/` and a distill post — none of which exist here — and it diffs against a **v0.16.3 baseline from ~1.5 years ago**. PROJECT.md's decision to disable rather than repair or delete it is correct. Do it in Phase 0, before the first design PR, so no time is ever spent reading a red X that means nothing.

### Pitfall 14: `enable_progressbar: true` is still on

A hard chrome-coloured scroll bar pinned at `top: 56px` is the least notebook-like element available, and on pages this short it sits at roughly 40% permanently. FEATURES.md lists it as an anti-feature. **One config line.** Also note (ARCHITECTURE.md) that `.progress-container` is pinned to a hard-coded `top: 56px` in gem CSS — if `navbar_fixed` or navbar height changes, three magic numbers need chasing. Turning the bar off avoids that entirely.

### Pitfall 15: The portrait is not print- or retina-safe

Uncommenting `profile:` is Phase 4 work, but check: `image_circular: true` (currently set) is a web convention that reads as social-media avatar rather than notebook; the source should exceed 1400px so `imagemagick.widths: [480, 800, 1400]` can generate responsive WebP; and a portrait with a white background on a cream ground will show as a visible white rectangle. Verify the cutout or give it a deliberate frame.

### Pitfall 16: `jekyll-terser` is pinned to a git branch with no ref

`Gemfile` line 23 pins `jekyll-terser` to a GitHub branch with no commit or tag, so rebuilds are non-deterministic — an upstream push can change CI output with no commit here. Out of scope for a design milestone, but if the build starts behaving strangely mid-milestone **this is the first thing to suspect**, not your CSS.

---

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|---|---|---|---|
| `opacity` to mute text | One property, instantly "quieter" | Contrast depends on the background; silently fails the moment the ground changes (Pitfall 4) | **Never.** Use a measured token |
| Copy a gem layout to add one wrapper class | Unblocks in 2 minutes | Permanent gem-upgrade tax + an override to maintain | Only when the element does not exist in the output at all — and say so in the PR |
| Hard-code a hex instead of adding a token | Faster in the moment | Re-emerges as inconsistency across 7 pages; forfeits a future dark mode | Throwaway experiments only, never merged |
| Per-page `_styles:` front matter | No new file | Duplicated tokens, invisible to anyone reading `_sass/` (ARCHITECTURE.md AP-6) | Genuine one-offs only |
| Skip the production/PurgeCSS preview | Saves ~60s per phase | A style silently missing from the live site (Pitfall 6) | Never before a deploy; fine mid-phase |
| Leave `visual-regression.yml` enabled and ignore the red X | No config change | Normalises ignoring CI; the one gate that *does* matter (prettier) gets ignored with it | Never — disable it in Phase 0 |
| Commit design work straight to `main` | Skips a PR | Auto-deploys to the live domain in ~2 min with no review (Pitfall 11d) | Never during this milestone |
| Defer `@media print` | Saves 30 min | A printed page loses every background-encoded meaning (Pitfall 9) | Acceptable to defer to the final phase, **not** to drop |
| Add a handwriting font without the subset check | It looks right in the mockup | One glyph in the family name set in a different face (Pitfall 7) | Never for text containing `ạ ả ắ ẻ ế ề ọ` |

---

## Performance Traps

Scale here is not traffic — it is **content volume, device class and connection quality**.

| Trap | Symptoms | Prevention | When it breaks |
|---|---|---|---|
| Full-viewport live `feTurbulence` | Scroll jank on phones; long Rendering blocks in the Performance panel | 200×200 tiled data-URI (~480 B) | Immediately on dpr-3 phones: 2.96 Mpx of filter work per paint |
| `background-attachment: fixed` | Whole viewport paint-flashes on scroll; iOS Safari ignores or stutters | Tiled background, or a fixed pseudo-element with `will-change: transform` | Any mobile scroll, worst during address-bar collapse |
| Too many webfont families/weights | Flash of fallback text; layout shift as the name reflows | ≤ 3 families, ≤ 2 weights each; `display=swap` (already set) | Above ~4 files on a slow connection |
| Unoptimised research figures | Slow first paint on the page that matters most to mentors | Source > 1400px so `imagemagick.widths` generates WebP; let `figure.liquid` emit `srcset` | Any figure over ~200 KB |
| Raster paper texture | Every page carries the weight | Keep total texture under ~2 KB and zero extra requests | Above ~30 KB on a slow connection |
| Layout shift from marginalia | Content jumps as fonts load | Reserve the gutter with layout, not with the note's own size | Any slow font load |

**There is no automated performance gate for this site.** Local Lighthouse (mobile preset) on `http://localhost:4000/` is the only measurement this project will get — run it at the end of Phase 2 and again before the final deploy, and record both numbers.

---

## Security Mistakes

Minimal surface — a static site — but three domain-specific items:

| Mistake | Risk | Prevention |
|---|---|---|
| Hotlinking book covers or figures from third parties | Leaks the reader's request to a third party, breaks silently, and raises a copyright question on an admissions-facing site | Covers are **out of scope this milestone**. For figures, store locally |
| Adding a font/icon CDN without an SRI pin | `test/style_contract.js` enforces SRI on the icon libraries; a new unpinned CDN is a supply-chain hole and may fail the contract | Prefer Google Fonts (already permitted by the CSP) and add nothing new |
| Personal information beyond what the application already discloses | A publicly indexed personal site belongs to a minor. Home address, school timetable, phone number, or a photo identifying the daily location are not required by any reader | Name, school, work, and a contact email. Nothing more. **Worth an explicit check in the final phase** |

---

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
|---|---|---|
| Marginalia beside the text on a 390px phone | Squeezes the main column to unreadable width; may cause horizontal scroll | Collapse below the annotated paragraph under ~768px |
| Removing link underlines for a cleaner paper look | Every warm accent fails the 3:1-vs-body test (Pitfall 5); links become invisible to many readers | Hand-drawn underline — the signature move, and it is required anyway |
| Making the reader hunt for the research | The primary reader has 2–3 minutes and will not explore | Three entry-point cards above the fold (FEATURES.md) |
| Texture strong enough to compete with text | Reduces effective contrast everywhere; worst on low-quality laptop panels in bright rooms | Keep intensity behind `--paper-texture-opacity`; check at ≤ 0.04 first and only increase if invisible |
| Dark-mode users get an unexpected bright page | Light-only is a deliberate, recorded decision | Ensure `enable_darkmode: false` removes the *toggle* too — a toggle that does nothing is worse than no toggle |
| The CV page with no PDF | A reader clicking "CV" and finding nothing | Already handled gracefully (`778f68b`). **Do not regress this during the visual pass** |

---

## "Looks Done But Isn't" Checklist

- [ ] **Deploy pipeline:** `_sass/**` is in `deploy.yml` `paths:` — verify a SCSS-only push actually triggers a run
- [ ] **Custom domain:** `_site/CNAME` exists after build; `curl -sI https://phamhakhanhchi.com` returns 200 after deploy
- [ ] **Production CSS:** the PurgeCSS'd build was previewed, not just `jekyll serve`
- [ ] **All seven pages:** not just the home page — About, Academics, Activities, Projects, Research, Further Reading, CV
- [ ] **Contrast:** no `opacity` remains on any text selector; every muted token measured against the *final* ground
- [ ] **Focus:** Tab through each page — every stop visible, ≥ 2px with `outline-offset`
- [ ] **Vietnamese:** the `ạ` in "Phạm" matches the `à` in "Hà" at ≥ 48px; the font's Google CSS contains a `vietnamese` block
- [ ] **Mobile:** 390px viewport, no horizontal scroll, marginalia collapsed, texture not janky
- [ ] **Print:** Ctrl+P with background graphics **off** — nothing important disappeared, no marginalia clipped at a page break
- [ ] **Webfont blocked:** DevTools blocks `fonts.gstatic.com` — page still readable, no catastrophic reflow
- [ ] **Stylesheet off:** content complete and correctly ordered
- [ ] **Register:** all ten markers in Pitfall 3 counted on a screenshot, not eyeballed
- [ ] **Entry-point cards:** each destination actually answers its question (FEATURES.md hard dependency)
- [ ] **Research headings:** the pass did not quietly rename "Research in progress" to "Publications"
- [ ] **Prettier:** `npx prettier . --check` passes — it is a real gate and will fail the PR
- [ ] **Style contract:** `npm run lint:style-contract` passes after every `_config.yml` edit
- [ ] **Overrides:** `bundle exec al-folio upgrade overrides audit` clean, or every new override deliberately acknowledged

---

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---|---|---|
| SCSS changes never deployed (P1) | **LOW** | Add `_sass/**` to `deploy.yml` paths, push (that edit is a `.yml`, so it self-triggers), verify Actions run |
| Custom domain broken (P2) | **MEDIUM** | Re-add `CNAME` to `gh-pages`, re-confirm the domain in Settings → Pages, wait for HTTPS re-provisioning. Then add the build-time assertion so it cannot recur |
| Half-restyled site live (P11a) | **LOW–MEDIUM** | `git revert` the merge on `main`; deploy re-runs. Only fast **if P1 is fixed** |
| Contrast failures shipped (P4/P5) | **LOW** | Tokens are one place. Re-point, delete text `opacity`, re-verify with the DevTools colour picker, redeploy |
| Personality overshoot (P3) | **HIGH — partly unrecoverable** | Ornament can be deleted quickly; a reader's impression cannot be retracted. **This is why prevention matters more than recovery.** Prevent with the marker table and the outside-reader check, before deploying, not after |
| Vietnamese fallback shipped (P7) | **LOW** | Swap the font in `_config.yml` to one with a `vietnamese` block, redeploy. Cheap — *if* noticed |
| PurgeCSS stripped a rule (P6) | **LOW** | Add the class to `safelist` in `purgecss.config.js`, redeploy |
| Texture jank on mobile (P10) | **LOW** | Swap live filter for a tiled data-URI; drop `background-attachment: fixed`; both are localised changes |
| Lost working version (P11d) | **LOW if tagged, HIGH if not** | `git checkout pre-redesign-known-good`. **Create the tag in Phase 0** — this is the whole point |
| An override that blocks a gem upgrade (P12c) | **MEDIUM** | `al-folio upgrade overrides diff <path>`, re-merge upstream changes, `overrides accept`. Cost grows with every override taken |

---

## Pitfall-to-Phase Mapping

Phases follow ARCHITECTURE.md's build order (Step 0 → Step 6).

| Pitfall | Prevention Phase | Verification |
|---|---|---|
| P1 SCSS never deploys | **0 — Guardrails** | SCSS-only push produces an Actions run and advances `origin/gh-pages` |
| P2 Domain breakage | **0 — Guardrails** | `deploy.yml` asserts `_site/CNAME`; post-deploy `curl` returns 200 |
| P12d Misleading AGENTS/CLAUDE docs | **0 — Guardrails** | Correction block added at the top of both files |
| P13 visual-regression noise | **0 — Guardrails** | Workflow disabled; no red X on the first design PR |
| P11d Lost working version | **0 — Guardrails** | `pre-redesign-known-good` tag pushed; rollback steps written in the roadmap |
| P4 `opacity` compounding | **1 — Tokens** (define) + **2 — Ground and type** (delete) | `grep -n "opacity" _sass/custom/` returns no text selectors; DevTools picker shows ≥ 4.5:1 on `.entry-meta` |
| P5 Palette/link/focus contrast | **1 — Tokens** | Every token has a measured ratio in a comment; links underlined; `:focus-visible` ≥ 2px with offset |
| P3 Register overshoot | **1 — Tokens** (cap vocabulary) + **6 — Per-page polish** (enforce) | All ten markers counted on screenshots of all seven pages; one outside reader asked the register question |
| P11c Colour bikeshedding | **1 — Tokens** | Ground hex recorded as a decision in `PROJECT.md` within a 30-min box |
| P7 Vietnamese fallback | **2 — Ground and type** | `curl` subset check in the commit description; `ạ` vs `à` compared at ≥ 48px |
| P8 Scannability loss | **2 — Ground and type** (hierarchy, measure) + **3 — Shared components** (marginalia) | 5-second test passes on all seven pages; greyscale-blur keeps headings dominant |
| P10 Texture performance | **2 — Ground and type** | Local mobile Lighthouse recorded; paint-flashing clean on scroll; texture < 2 KB, 0 extra requests |
| P9 Print | **3 — Shared components** | Save-as-PDF with backgrounds **off** on About, Research, CV — nothing lost, nothing clipped |
| P6 PurgeCSS divergence | **Every phase, at deploy** | Production preview inspected before each deploy |
| P11a Half-restyled site | **Phase ordering itself** | Seven-tab check before every deploy; no phase merges mid-transition |
| P11b Home page absorbs the time | **4 — Home entry points** (time-boxed) + **5 — Figures** | Research page has received at least as much time as About; every card destination is styled |
| P12a Silent feature failure | **4 — Home entry points** (portrait) | `grep -c "prof_pic" _site/index.html` returns > 0 |
| P12b Gemfile/config drift | **Every `_config.yml` edit** | `npm run lint:style-contract` passes |
| P12c Override drift | **Every phase** | `al-folio upgrade overrides audit` clean; each override justified in writing |
| P14 Progress bar | **1 — Tokens** (config sweep) | Bar absent from rendered HTML |
| P15 Portrait quality | **4 — Home entry points** | Renders on cream without a white box; source > 1400px |

---

## Sources

**Primary — this repository, read and verified 2026-09-13 (HIGH confidence):**
- `.github/workflows/deploy.yml` — path filters (no `_sass/**`), purgecss step, `JamesIves/github-pages-deploy-action@v4`
- `.github/workflows/axe.yml` — `push`/`pull_request` triggers commented out; `workflow_dispatch` only; single-URL axe run
- `.github/workflows/lighthouse-badger.yml` — `URLS: https://alshedivat.github.io/al-folio/`
- `.github/workflows/unit-tests.yml`, `visual-regression.yml` — path filters
- `purgecss.config.js` — `content`, `css`, `skippedContentGlobs`, `safelist` (incl. the `medium-zoom-*` regression note)
- `_config.yml` — blank `baseurl`, `max_width: 930px`, `enable_darkmode: true`, `enable_progressbar: true`, duplicated `exclude:`/`keep_files:` keys, legacy `css?family=` Google Fonts URL
- `_sass/_custom.scss` — the `opacity: 0.6/0.7/0.75` and `color-mix(... 12%)` rules
- `assets/css/main.scss`, `CNAME`, `_pages/about.md` (commented-out `profile:` block)
- **Git history:** `git ls-tree` on `aa91529`, `a608b18`, `24f5b64` proving the CNAME deploy incident; `git log` timestamps on `main` and `gh-pages`

**Computed here (HIGH confidence — WCAG 2.x relative-luminance formula, sRGB alpha compositing):**
- All contrast ratios in Pitfalls 4 and 5, including opacity- and `color-mix`-composited values
- feTurbulence per-device-pixel arithmetic and the inline-SVG data-URI byte measurements in Pitfall 10

**Verified live over the network 2026-09-13 (HIGH confidence):**
- Google Fonts CSS API `vietnamese` subset presence for Source Serif 4, IBM Plex Mono, Caveat, Kalam, Libre Baskerville; the exact `unicode-range` of the `vietnamese` subset; and the user-agent dependency of the response format
- Character scan of `_pages/`, `_data/`, `_projects/`, `_config.yml` classifying all 12 accented characters by subset

**External (MEDIUM confidence unless noted):**
- [MDN — `print-color-adjust`](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/print-color-adjust) — HIGH; browsers omit backgrounds by default (`economy`)
- [CSS-Tricks — `print-color-adjust`](https://css-tricks.com/almanac/properties/p/print-color-adjust/), [fvsch — Printing background colors with CSS and SVG](https://fvsch.com/css-print-background)
- [Codrops — SVG Filter Effects: Creating Texture with feTurbulence](https://tympanus.net/codrops/2019/02/19/svg-filter-effects-creating-texture-with-feturbulence/), [CSS-Tricks — Creating Patterns With SVG Filters](https://css-tricks.com/creating-patterns-with-svg-filters/) — per-pixel cost, `numOctaves` guidance
- [Vehikl — Fixed background image performance issue](https://medium.com/vehikl-news/fixed-background-image-performance-issue-6b7d9e2dbc55), [CSS-Tricks — The Fixed Background Attachment Hack](https://css-tricks.com/the-fixed-background-attachment-hack/) — `background-attachment: fixed` repaint cost; MEDIUM, community-reported, not device-verified here
- [google/fonts #189 — Correct vietnamese subset](https://github.com/google/fonts/issues/189), [adobe-fonts/source-serif #119 — Questions about Vietnamese diacritics](https://github.com/adobe-fonts/source-serif/issues/119) — historical subset gaps and mixed-glyph fallback behaviour

**Deliberately not used:** the "68% of admissions officers review applicant websites (NACAC 2023)" and "15–20% of competitive applicants" figures circulating on vendor blogs. FEATURES.md traced both to an uncited commercial source and found no such questions in NACAC's actual 2023 output. **Treated as fabricated; no recommendation here rests on them.**

**Companion documents (read these, not summaries of them):** `.planning/research/STACK.md`, `ARCHITECTURE.md`, `FEATURES.md`; `.planning/codebase/CONCERNS.md`, `TESTING.md`; `.planning/PROJECT.md`.

---
*Pitfalls research for: personality-driven academic portfolio redesign under deadline, al-folio v1.x / Jekyll, admissions-officer primary reader*
*Researched: 2026-09-13*

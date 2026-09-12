# Feature Research

**Domain:** Personal academic portfolio site — visual/presentational redesign. Primary reader: university admissions officer with 2-3 minutes. Secondary: research mentors. Tertiary: curious peers.
**Researched:** 2026-09-12
**Confidence:** MEDIUM overall. HIGH on presentational conventions and accessibility rules (verifiable specs, named real sites). MEDIUM on the entry-point/curiosity-gap question (strong empirical study, but from a different domain). LOW on admissions-officer behaviour (see the honesty note below — most of what circulates is uncited consultant marketing).

---

## Read this first: a content blocker that changes the shape of the milestone

PROJECT.md lists four visual-material sources. **Two of them have no underlying asset or content in the repo today**, and PROJECT.md states one of them incorrectly.

| PROJECT.md claim | Actual repo state | Consequence |
|---|---|---|
| Book covers "**Already in repo** at `assets/img/book_covers/`" | `assets/img/book_covers/` **exists but is empty** — zero files | The book-cover feature has no assets |
| Reading list content exists | `_data/further_reading.yml` is `papers: []` and `books: []` — entirely empty, with only commented-out examples | **The Further Reading page currently renders a single placeholder sentence.** There is no reading list to design |
| Research figures "To be produced" | Correct. Also `_data/research.yml` has empty `detail:` on the attention-sinks paper and blank `url:` on both papers | Figures and the text around them are both missing |
| Portrait "Already in repo, commented out" | Correct — `assets/img/prof_pic.jpg` and `prof_pic_color.png` both exist | Ready to ship |
| Projects have content | `_projects/soul-garden.md` and `friendship-web-game.md` are both literally `TODO — details to come.` | Project cards will render as empty shells |

**The collision:** PROJECT.md puts "New content" explicitly out of scope. But three of the milestone's Active requirements — entry-point cards with real questions, book covers as a curiosity signal, figures placed where they earn attention — are *content-bearing features*. Cards need question text written. A reading list needs books listed. A figure needs a caption.

**Recommendation for the roadmap:** carve out a narrow, named exception — *"micro-copy and list population required to make an existing page presentable"* — rather than either (a) silently writing new prose under a no-new-content banner, or (b) shipping empty design shells. Bound it explicitly: roughly 3 card questions (~10 words each), 6-10 reading-list entries with one sentence each, 1-2 figure captions, 1-2 sentences per project. That is an afternoon of the owner's writing, not a content milestone. Everything downstream in this document assumes that carve-out; where a feature cannot survive without it, it is flagged **[needs content carve-out]**.

---

## Honesty note on the admissions-behaviour evidence

The research focus asked for evidence, not folklore. Here is the honest state of it.

**What does not survive checking.** Several SEO/vendor pages assert *"A 2023 survey by NACAC found that 68% of admissions officers reported reviewing applicant websites when URLs were provided, up from 42% in 2019."* I traced this to [collegebase.org](https://www.collegebase.org/blog/personal-website-college-admissions), a commercial admissions-database vendor's blog. **The page gives no link, no methodology, no publication.** NACAC's actual 2023 research output ([State of College Admission](https://www.nacacnet.org/state-of-college-admission-report/), [College Admission Process Survey, Aug 2023](https://www.nacacnet.org/wp-content/uploads/NACAC-College-Admission-Process-Research_FINAL.pdf)) is organised around test-optional policy, application volume and the post-*SFFA* landscape; I found no such question in it. The same vendor page also claims "approximately 15-20% of competitive applicants include personal websites," again uncited. **Treat both numbers as fabricated. Do not design against them.** (Confidence that these are unreliable: HIGH — the absence of citation is directly verifiable.)

**What does survive checking.**

1. **Admissions readers spend single-digit minutes per *application*.** Jeffrey Selingo embedded for a full cycle inside the admissions offices of Emory, Davidson and the University of Washington for *Who Gets In and Why* (2020) and documents roughly **eight-minute reads** of complete files ([Emory](https://news.emory.edu/stories/2020/10/er_selingo_admission_book/campus.html), [Davidson](https://www.davidson.edu/news/2020/10/19/new-book-offers-inside-look-college-admissions-process-and-spotlights-davidson)). Confidence: MEDIUM-HIGH — first-hand embedded journalism at three named institutions, not a survey. **Implication: if the whole file gets ~8 minutes, an optional website gets a fraction of that. PROJECT.md's 2-3 minute budget is, if anything, generous.** The "8-minute rule" as repeated by consultancies is folklore; Selingo's observation is the real thing underneath it.

2. **Most admissions officers do not routinely look up applicants online, though most think it is permissible.** Kaplan's annual survey of admissions officers found **28% had actually visited an applicant's social media** in the 2023 round, against **67% who said it was "fair game"** ([Kaplan, 2023](https://kaplan.com/about/press-media/kaplan-survey-college-admissions-officers-applicant-social-media)); the actual-visit figure ran 25% (2018) → 36% (2019-20) → 27% (2021) → 28% (2023) ([2020](https://www.kaptest.com/blog/press/2020/01/13/kaplan-survey-percentage-of-college-admissions-officers-who-visit-applicants-social-media-pages-on-the-rise-again/), [2021](https://www.kaptest.com/blog/press/2021/01/28/kaplan-survey-college-admissions-officers-increasingly-say-applicants-social-media-content-is-fair-game/)). Confidence: MEDIUM — repeated annual survey by a commercial test-prep firm, but methodology is disclosed and the series is consistent. **Caveat: this measures social media, not a website URL supplied by the applicant. It is the nearest real proxy, not the thing itself.**

3. **Overclaiming unpublished work is a documented, measurable failure among applicants.** A study of **122 hand-surgery fellowship applicants** found **27% (33 of 122) listed submitted-but-unaccepted manuscripts under a "Publications" heading** ([J Hand Surg Glob Online / PMC10837291](https://pmc.ncbi.nlm.nih.gov/articles/PMC10837291/)). The authors' recommendation is directly transferable: unpublished work belongs **under a separate heading such as "Submitted Works" or "Current Projects," never under "Publications."** Confidence: HIGH for the finding; MEDIUM for transfer to undergraduate admissions (different population, same reviewer instinct).

**The honest bottom line:** there is no credible published evidence about how admissions officers read applicant *websites* specifically. What exists is (a) hard evidence that review time is very short, (b) survey evidence that only a minority look applicants up at all, and (c) hard evidence that reviewers in adjacent contexts *do* catch publication overclaiming. Design accordingly: assume a short, skeptical, possibly-never-happens read. The site's more reliable payoff is with audience #2 (mentors, who *will* click a link you send them) and #3.

---

## Feature Landscape

### Table Stakes (absence is noticed)

| Feature | Why Expected | Complexity | Notes |
|---|---|---|---|
| **A face on the landing page** | Every award-winning site in the 2025 [Best Personal Academic Websites contest](https://theacademicdesigner.com/2025/winners-of-the-best-personal-academic-websites-contest-2025/) has a photo above the fold; [jeffhuang.com](https://jeffhuang.com/) puts a headshot near the top. A portfolio with no face reads as a document, not a person. | **LOW** | Asset already exists. Uncomment the `profile:` block in `_pages/about.md`. Use `prof_pic_color.png` or `prof_pic.jpg`. The single highest value-per-effort item in the milestone. |
| **Comfortable measure and a real type scale** | Serif body at a ~60-75ch measure is the baseline expectation for a "research notebook" register. Current `_sass/_custom.scss` is self-described as "deliberately plain." | **MEDIUM** | This is the design-token work. Everything else depends on it. |
| **Contrast that passes WCAG AA on warm paper** | `axe.yml` runs in CI. PROJECT.md already names low-contrast greys on cream as the obvious failure mode — correctly. Current `_custom.scss` leans on `opacity: 0.6 / 0.7 / 0.75` for `.entry-year`, `.entry-meta`, `.entry-status`, which **multiplies against a cream ground and is exactly how this fails**. | **MEDIUM** | Replace opacity-based de-emphasis with explicit, contrast-checked token colours. Non-negotiable: CI gate. |
| **Working links, or no links** | Two research entries have blank `url:`; both projects have commented-out `github:`. A dead or absent link on a paper the reader was invited to click is worse than no invitation. | **LOW** | The Liquid in `_pages/research.md` already guards `{% if e.url %}`. Verify the no-URL path looks deliberate, not broken. |
| **Fast first paint** | A warm-paper aesthetic tempts large background texture JPEGs and multiple webfont weights. At a 2-3 minute budget, a 2-second blank screen is 1-2% of the reader's entire attention. | **MEDIUM** | Prefer CSS/SVG-generated texture (PROJECT.md already specifies this) over raster. Subset fonts; cap to 2 families × 2-3 weights. |
| **Mobile layout that does not just shrink** | Marginalia and hand-drawn rules are the first thing to break at 375px. A margin note that collapses into the text column mid-paragraph destroys legibility. | **MEDIUM** | Decide the margin-note mobile behaviour *up front* — inline blockquote-style, or collapsed/hidden. Do not leave it to reflow. |
| **Print / PDF sanity** | Recommenders and mentors print things. A cream background printing as a solid ink block, or dark-on-dark, is an embarrassing and entirely avoidable failure. | **LOW** | One `@media print` block: white ground, black text, suppress texture/marginalia decoration, expand link URLs after anchors. Cheap insurance. |
| **Honest status labels on unpublished work** | The 27%-misclassification finding above. This is the single highest-stakes credibility item on the site. | **LOW-MEDIUM** | See the dedicated section below. |
| **Scannable hierarchy — the 20-second skim** | Selingo's eight-minute application read implies the site is skimmed, not read. Name, one line of what they work on, and the two papers must all be absorbable without scrolling twice. | **MEDIUM** | Already partly present via the `.hero-role` / `.hero-line` / `.hero-school` spans in `about.md`. |
| **`prefers-reduced-motion` respected** | If any annotation/ink-draw animation ships, [WCAG 2.3.3 Animation from Interactions](https://w3c.github.io/wcag/understanding/animation-from-interactions) (AAA) and [SC 2.2.2 Pause, Stop, Hide](https://dequeuniversity.com/resources/wcag2.1/2.3.3-animations-from-interactions) (A, for anything auto-moving) apply. | **LOW** | CSS-first opt-in: wrap motion in `@media (prefers-reduced-motion: no-preference)`. Costs one media query at authoring time; retrofitting costs far more. |
| **Alt text on every figure and book cover** | `axe.yml`. Also: a figure without alt text is invisible to the reader who most needs the caption. | **LOW** | Caption and alt text are different things — write both. |

### Differentiators (what would make this site memorable)

| Feature | Value Proposition | Complexity | Notes |
|---|---|---|---|
| **Home-page entry-point cards phrased as real questions** | The milestone's headline feature. Done right, it is the difference between "here is a student with good grades" and "here is someone with a question I also find interesting." | **MEDIUM** **[needs content carve-out]** | See the dedicated section below — there is real evidence on how to phrase these, and a real way to get it wrong. |
| **Annotated section descriptions instead of bare category headings** | [maggieappleton.com](https://maggieappleton.com/) labels her Notes section *"Loose, unopinionated notes on things I don't entirely understand yet"* and Essays as *"Opinionated, longform narrative writing with an agenda."* One line under a heading converts a filing cabinet into an invitation — and does epistemic work at the same time. | **LOW** **[needs content carve-out]** | The cheapest differentiator on this list. One sentence under each `.entry-group-title` on Research and Further Reading. Works *within* the out-of-scope constraint on navbar changes, because it adds invitation without renaming anything. |
| **One research figure, above the fold, from the owner's own work** | [Deep Paper Gestalt](https://arxiv.org/pdf/1812.08775) (Huang, 2018) trained a classifier on paper *appearance* alone and its class-activation maps localise on **first-page teaser figures** as a signal of good papers. [Distill](https://distill.pub/about/) built an entire journal on the premise that the figure carries the idea. A hand-drawn attention map on a paper ground says "real work happened here" faster than any sentence. | **MEDIUM-HIGH** **[asset does not exist]** | Highest credibility-per-pixel item, but the figure has to be produced first. Must have a caption that states what it shows in one line. |
| **Book covers as a colour-and-curiosity block** | Maggie Appleton's Library section and [sive.rs/book](https://sive.rs/book) both use cover thumbnails; Sivers pairs each with a rating and a short personal summary. Covers are the fastest non-verbal signal of intellectual range — a reader parses a shelf in two seconds. | **MEDIUM** **[no assets, no data]** | Blocked twice over: `assets/img/book_covers/` is empty **and** `further_reading.yml` is empty. Also carries a copyright/hotlink decision (see anti-features). |
| **"Why I read this" annotations on the reading list** | `_data/further_reading.yml`'s own comment nails it: *"A bare list of titles says only that you read them; a sentence on what you took from one says you thought about it."* This is the difference between a curiosity signal and a performance of erudition. | **LOW** per entry **[needs content carve-out]** | The `notes` field and `.entry-notes` rendering already exist and already run `markdownify`. The plumbing is built; the content is not. |
| **Marginalia as genuine commentary, not decoration** | The notebook language only earns its keep if the margin notes *say something* — a second thought, a caveat, a "this is the part I'm least sure about." A margin note containing lorem-ipsum-grade filler is worse than no margin at all, because it advertises that the aesthetic is a costume. | **MEDIUM** **[needs content carve-out]** | Budget 3-6 real margin notes site-wide. Do not templatise them. |
| **Multiple curated entry paths rather than one chronological list** | [gwern.net/index](https://gwern.net/index) offers three simultaneous doors — **Newest**, **Popular**, **Notable** — on the premise that different readers arrive with different motives. Here that maps cleanly onto the three ranked audiences. | **MEDIUM** | For a 7-page site, 2-3 doors is the ceiling. The entry-point cards *are* this feature. Don't build a second mechanism. |
| **A visible statement of what is currently unresolved** | Andy Matuschak's ["working with the garage door up"](https://notes.andymatuschak.org/About_these_notes) — *"If a note seems confusing or under-explained, it's probably because I didn't write it for you"* — models intellectual honesty as an attractive quality rather than a liability. For a student whose work is *all* in progress, this reframes the weakest fact about the portfolio as its most human one. | **LOW** **[needs content carve-out]** | Two sentences on the About page, in the owner's voice. Cheap, distinctive, and it directly defuses the overclaiming risk. |
| **Figure zoom on research images** | `enable_medium_zoom: true` is already set in `_config.yml`. A hand-drawn attention map at thumbnail size is a texture; at full size it is evidence. | **LOW** | Already available from the gem. Verify it doesn't fight the paper ground visually. |

### Anti-Features (deliberately not built)

Opinionated, as requested. Each of these has a specific cost *for this reader*.

| Anti-Feature | Why It Gets Requested | Why It's Wrong Here | Do Instead |
|---|---|---|---|
| **Scroll-jacking / parallax / scroll-driven reveal animation** | It looks like craft. Design-award sites do it. | Directly against the primary use case. An officer with 2-3 minutes is *skimming* — jacked scroll takes away the one control they are actively using. [NN/g](https://www.nngroup.com/topic/animation/) documents parallax as slow-loading and hard-to-read, and notes that **upward of 35% of participants with vestibular disorders had difficulty with heavy-motion sites**; [peer-reviewed work on scrolljacking](https://link.springer.com/chapter/10.1007/978-3-032-16454-4_6) examines it as a universal-design failure. Also: a reader who has to fight the scroll on a *student's* site concludes the student values effect over substance. | Static ink/paper composition. If anything moves, make it a ≤200ms hover on a single annotation mark, gated behind `prefers-reduced-motion`. |
| **Splash / intro screen ("loading…", name fade-in, "enter" gate)** | Feels cinematic and confident. | It spends the reader's scarcest resource — the first 3 seconds — on zero information. At a 2-3 minute budget that is 2% of the visit purchased with nothing. It also blocks the crawler-and-skimmer path and is a hard stop for keyboard/AT users. | Put the name, the one-line positioning, the face and the first question card in the first viewport. That *is* the intro. |
| **Custom cursor** | Signals "designed." | Breaks the affordance the reader uses to find links; adds JS to a static site; frequently unusable on touch and with pointer AT. To a 45-year-old admissions reader it reads as a teenager's Tumblr theme, which is precisely the register PROJECT.md is trying to escape ("must never obstruct the academic substance"). | Distinctive *link* styling — a hand-drawn underline on the paper ground. Same personality, zero interaction cost. |
| **Autoplaying background media (video, audio, animated texture)** | Atmosphere. | WCAG SC 2.2.2 (Level A) territory; bandwidth cost on a mobile connection; and sound in a shared admissions office is a hostile act. | Static paper texture, CSS/SVG generated. PROJECT.md already specifies this. |
| **Skills bars / percentage proficiency meters ("Python 85%")** | Every portfolio template ships one. | It "turns a real skill into an invented number with no scale under it" ([Peter Kang](https://www.peterkang.com/remove-those-silly-bars-on-resumes/)); it is Dunning-Kruger bait; hiring-side reviewers report they "mean nothing" ([dev.to review of 40+ portfolios](https://dev.to/kethmars/what-i-learned-after-reviewing-over-40-developer-portfolios-9-tips-for-a-better-portfolio-4me7)). **For a high-school applicant the damage is specific and severe: a self-assigned 90% in "Machine Learning" is an overclaim, and this is a reader trained to detect overclaiming.** | Named artefacts. "Wrote a query-side attribution analysis of attention sinks" is a skill claim with evidence attached. |
| **"Years of experience" counters / animated stat counters ("3 years coding!")** | Fills space; looks quantitative. | A 17-year-old's experience counters invite an unflattering comparison the reader was not going to make unprompted. The animation is also motion-for-nothing. | Dates on the work itself. `_data/research.yml` and `academics.yml` already carry `year:` fields — the timeline tells the story without a scoreboard. |
| **Testimonials / recommendation quotes on the site** | Social proof. | Admissions already collects letters through an authenticated channel; an unverifiable teacher quote on a personal site adds nothing and looks like it is trying to substitute for the real thing. It reads as marketing, and marketing is the register that costs you credibility with mentors. | Let the work and the named institutions (BVIS, HUST, CS50) carry it. |
| **Gamified elements (badges, XP, achievement unlocks, easter-egg hunts)** | "Shows personality." | Directly inverts the PROJECT.md balance requirement (*serious about the work* **and** curious). Gamification reads as the curiosity half with the seriousness half deleted. | The question cards are the play. A good question *is* the personality. |
| **A dark-mode toggle** | Habit; the gem ships one (`enable_darkmode: true`). | **Explicitly out of scope in PROJECT.md** — one look done well under deadline pressure. Flagged here so nobody re-proposes it. Note it is *deferred, not rejected*. | Ship light-only; keep the token layer structured so a dark palette is a later token swap, not a rewrite. |
| **Scroll progress bar** | `enable_progressbar: true` is currently on in `_config.yml`. | On pages this short it's decoration that is permanently at ~40%. It also fights the paper ground — a hard chrome-coloured bar is the most un-notebook element available. | Turn it off, or restyle it as an ink rule. Turning it off is one config line. |
| **Renaming navbar tabs to creative labels** | The notebook concept tempts it ("Marginalia", "Open Questions"). | **Explicitly out of scope in PROJECT.md**, for the right reason: a rushed reader must never wonder where to click. | Invitation lives on the home page; the navbar stays boring and legible. |
| **A carousel / slider of projects or figures** | Fits more in less space. | Everything past slide 1 is effectively unpublished; the auto-advance variant is a SC 2.2.2 violation; and with **two** projects it is absurd. | Show both projects. There are two. |
| **Hotlinking book covers from Amazon/Goodreads** | Zero-effort way to fill the empty `book_covers/` directory. | Breaks silently when the remote changes, leaks the reader's request to a third party, adds an uncontrolled render-blocking dependency, and is a copyright question you don't want on an admissions-facing site. | Either store small, locally-optimised covers with a source note, or **skip covers entirely and use a typographic treatment** — author/title/one-line-note on ruled lines is completely legitimate and ships today. |
| **A blog, news feed, or "latest posts" module** | The gem supports all three. | `announcements.enabled: false` and `latest_posts.enabled: false` are already correctly set. An empty or three-month-stale feed actively signals abandonment. | Leave them off. Revisit only if there is a real writing habit. |

---

## The entry-point card pattern, in detail

This is the milestone's headline feature and deserves its own treatment.

### What the evidence actually says about question-led framing

The strongest available finding is **Aubin Le Quéré & Matias, "When curiosity gaps backfire: effects of headline concreteness on information selection decisions," *Scientific Reports* (2025)** — a **pre-registered meta-analysis of 8,977 headline A/B experiments** ([Nature](https://www.nature.com/articles/s41598-024-81575-9), [PMC](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC11704130/)). The finding is **curvilinear, not monotonic**:

- When the surrounding headline is **too vague**, *adding* concreteness **increases** clickthrough.
- When it is **already concrete**, *adding more* concreteness **decreases** clickthrough.
- Optimum: headlines that "convey just the right amount of information."

**Confidence: MEDIUM-HIGH for the finding, LOW-MEDIUM for transfer.** The corpus is news headlines on a mass-market platform, with readers choosing entertainment. An admissions officer assessing an applicant is a different task with a different utility function. The *shape* of the result transfers — over-teasing backfires — but do not treat the effect sizes as applicable.

The second relevant body of work cuts against pure curiosity gaps: **clickbait framing reliably lowers perceived credibility of the source.** Kaur et al., ["Clickbait — Trust and Credibility of Digital News"](https://ieeexplore.ieee.org/document/9405359) (*IEEE Trans. Technology and Society*, 2021) ran 200 participants across matched clickbait/non-clickbait headlines for the same articles and found a significant negative effect on trust (p < .001). Note there is contrary evidence too — ["The (Null) Effects of Clickbait Headlines on Polarization, Trust, and Learning"](https://www.researchgate.net/publication/344620233_The_Null_Effects_of_Clickbait_Headlines_on_Polarization_Trust_and_Learning) found no effect. **Sources genuinely disagree on magnitude; they do not disagree on direction of risk.** For an audience whose entire job is credibility assessment, take the cautious read.

### The operational rule that falls out of this

**A good entry-point card states the real question and answers nothing. A bad one withholds the subject.**

| Good — concrete question, subject fully disclosed | Bad — withholds the subject (this is the failure mode) |
|---|---|
| "Why do attention sinks appear in transformer layers?" | "I found something strange inside GPT-2." |
| "Do three recommender algorithms build the same echo chamber?" | "Three algorithms. One surprising result." |
| "What is a 'sink' actually attending to?" | "The answer changed how I think about attention." |

The owner's own example from PROJECT.md — *"Why do attention sinks appear?"* — is on the right side of that line. Keep it. Consider adding the object ("...in transformer layers") to move slightly further toward concreteness, which the *Scientific Reports* result favours for an audience that is *already* in an information-seeking rather than entertainment mode.

### How real sites do this

| Site | Mechanism | What to steal |
|---|---|---|
| [maggieappleton.com](https://maggieappleton.com/) | Section headers carry a one-line editorial description of *what kind of thinking lives there*: Notes = "Loose, unopinionated notes on things I don't entirely understand yet." Each essay card carries a hand-drawn illustration thumbnail. | The annotated-section line. It is one sentence and it does more work than any card animation. Also: illustration-per-item is exactly the "figures as bait" pattern, and she proves it survives on a personal site. |
| [gwern.net/index](https://gwern.net/index) | Three parallel doors — Newest / Popular / Notable. Titles are deliberately written to *be* the annotation ("uniform solid blocks of text," per the page's own HTML comments). Page-level metadata exposes `status:` and `confidence:`. | Titles-as-annotations. Also the explicit status/confidence metadata — highly relevant to the in-progress-papers problem. |
| [jeffhuang.com](https://jeffhuang.com/) | No cards at all: dense, fast, hierarchical publication list with badges. A curated "Long-Term Habits" section of selected essays sits alongside. A manifesto, "This Page is Designed to Last," states the site's values in one link. | The *curated selection alongside the complete list* pattern. And the reassurance that a fast, plain academic site is still a winning academic site — you are not obliged to be clever. |
| [ciechanow.ski](https://ciechanow.ski/) | Article pages open with a figure you can manipulate before you have read a paragraph. | Figure-before-prose ordering. The picture makes the promise; the text keeps it. |
| [neelnanda.io](https://www.neelnanda.io/) | Descriptive full-sentence post titles plus a short summary line per entry, and a single time-sensitive announcement pinned at top. | Title + one-line summary is the minimum viable entry point and is cheaper than cards. Directly domain-adjacent (mech interp) if the owner wants a peer reference. |
| [cecibaldoni.github.io](https://cecibaldoni.github.io/) (Best Interactive, 2025 contest) | A "Shrews" page that unfolds one research story visually; captioned photographs throughout. | One page that *tells* rather than lists. If only one page gets the full treatment, make it Research. |
| [kamsekar.github.io](https://kamsekar.github.io/) (Accessible SciComm award, 2025) | Publications carry **plain-language overview summaries with takeaways, beyond the abstract**, grouped by contextual relevance rather than date. | The single best model for the two in-progress papers: a one-line plain-language takeaway per paper, grouped by theme. |

### What makes it read as gimmicky

1. **Question cards on top of content that answers nothing.** If the "Why do attention sinks appear?" card lands on `_data/research.yml`'s current entry — a title, "In progress — writing," an empty `detail:` and no URL — the reader experiences a bait-and-switch. **The card is only as good as its destination.** This is a hard dependency, not a nice-to-have.
2. **Too many of them.** Three cards read as a curated selection. Seven read as a navigation menu wearing a costume, and re-create the problem PROJECT.md rejected when it ruled out renaming the navbar.
3. **Questions the owner cannot actually speak to.** A question implies the author has spent time in it. "What is consciousness?" on a student portfolio is a liability. "Do three recommender algorithms build the same echo chamber?" is defensible because there is a paper behind it.
4. **Rhetorical questions.** "Ready to see my work?" is not curiosity; it's a landing-page CTA. Every card must be a question the owner has genuinely asked.

**Recommended shape: exactly three cards.** One per research paper, one for the reading list or a project. Each = a concrete question + one clause of context + a destination that immediately addresses it.

---

## Presenting in-progress work honestly

Both papers are unpublished. This is the highest-stakes presentational decision on the site, because the audience that matters most is trained to spot inflation.

**Signals rigour:**

- **A heading that is not "Publications."** The hand-surgery study's explicit recommendation: use **"Submitted Works," "Current Projects," or "Research in Progress"** ([PMC10837291](https://pmc.ncbi.nlm.nih.gov/articles/PMC10837291/)). The current page heading is **"Research"** under a page titled **"Research & Learning"** — this is already correct and should be *preserved*, not "upgraded" during the redesign. **Flag for the roadmap: do not let a visual pass quietly rename this section to something more impressive.**
- **Specific status, not vague status.** `_data/research.yml` already has `In progress — writing` and `In progress — not yet submitted`. The second is better than the first because it is unambiguous about the stage. Specificity *is* the credibility signal.
- **Stating the method rather than the result.** "Comparing content-based, popularity-based and collaborative filtering approaches" (already present on the echo-chambers entry) is a verifiable claim about what was done. It survives scrutiny in a way that a claimed finding would not.
- **Naming a real supervisor/context if one exists**, or saying plainly that it was independent. Either is fine; ambiguity is not.
- **Visible uncertainty.** Gwern's per-page `status:` / `confidence:` metadata, and Matuschak's garage-door framing, both convert "unfinished" from an apology into a stance.
- **Honest first-person voice.** The About page already does this well — *"I'm drawn to questions that make me want to keep digging"* — and the design should amplify that register rather than formalise it away.

**Signals overclaiming — avoid all of these:**

- The word "Publications," or any venue/journal name next to an unsubmitted paper.
- Fabricated or placeholder DOIs, arXiv IDs, or BibTeX entries. (`enable_publication_badges` and `bib_search` are on in `_config.yml` — **do not route these papers through the publications machinery**, which is built to display citation counts and venue badges that do not exist here.)
- A `.entry-status` badge styled loud. The current CSS gets this exactly right and the comment says why: *"Deliberately quiet: it should read as honest labelling, not as a badge competing with the title."* **Preserve this intent through the redesign.** The temptation in a notebook aesthetic is to turn "In progress" into a charming rubber-stamp graphic — that converts a disclosure into a decoration, which is precisely the wrong direction.
- Blank `url:` fields that render as a dead-looking title. Prefer an explicit "draft available on request" over an inert link stub.
- Grand claims in figure captions. "Attention sink behaviour across layers, GPT-2 small, preliminary" beats "Discovering why attention sinks exist."

**Visual treatment recommendation.** In the notebook language, in-progress work has a natural and *honest* idiom: the draft page. Ruled paper, a pencil-weight rule rather than an ink one, status in the margin as a note rather than a badge. This lets the design carry the honesty instead of the design fighting it — and it costs nothing extra.

---

## Reading lists as a curiosity signal

**Currently unbuildable as specified** — `further_reading.yml` is empty and `book_covers/` has no files.

What the good examples do:

- **[sive.rs/book](https://sive.rs/book)**: cover thumbnail + a rating out of 10 + date read + a short personal paragraph, with an explicit caveat that the summary is a reminder of the book's essence, not a substitute for it. The caveat is what keeps it from reading as showing off.
- **[maggieappleton.com](https://maggieappleton.com/)** Library: covers with author names, linking out to Google Books/Goodreads. Minimal annotation, but the *section framing* elsewhere on her site does the honesty work.
- **[patrickcollison.com/bookshelf](https://patrickcollison.com/bookshelf)**: an explicitly *unannotated* catalogue of physical books owned, with the disclosure that **he has read only about half of them**. That single admission is what makes the page read as a bookshelf rather than a brag. It has also not been updated in ~10 years — a live demonstration of the staleness risk.

**What separates genuine intellectual life from performance:**

| Genuine | Performance |
|---|---|
| 6-10 entries, each with a specific sentence about what stuck | 40 entries, no notes |
| Includes something the reader disagreed with, or didn't finish | Only canonical prestige titles |
| Mixes registers — a textbook, a paper, a novel, something off-topic | Uniformly on-brand "AI researcher" reading |
| Dated, so the reader sees a trajectory | Undated, so it could be aspirational |
| A book that connects visibly to the research ("read this *because* of the sinks question") | No link between reading and work |

**Recommendation:** a short annotated list beats a long gallery, and it ships without waiting for cover assets. Build the typographic treatment first — title, author, year on a ruled line, with the `notes` field as a margin annotation. Treat covers as a **v1.x enhancement**, not a v1 dependency. The `notes` field, `markdownify` rendering and `.entry-notes` class already exist in the codebase; only the data is missing.

**Staleness is a real risk.** A reading list dated 2025 viewed in a 2027 admissions cycle actively harms. Either keep years off individual entries and put one "last updated" line at the bottom, or commit to updating it. Collison's decade-stale shelf is the cautionary case.

---

## Research figures as curiosity bait

**What makes a reader click through rather than scroll past:**

1. **The figure is legible at the size it is displayed.** A downscaled matplotlib plot with 8px axis labels is noise. A redrawn notebook-style figure with 2-3 hand-lettered labels is readable at card size — which is the entire argument for PROJECT.md's redraw decision, and it is a correct one.
2. **The caption states what you are looking at, in one line, in plain language.** [Kamšek's site](https://kamsekar.github.io/) won a 2025 award specifically for plain-language takeaways beyond the abstract. The caption, not the image, is what converts a glance into a click.
3. **The figure shows a *pattern*, not a *result table*.** An attention heatmap with a visible bright column is a picture of a question. A bar chart of accuracy numbers is a picture of an answer, and answers do not create curiosity.
4. **The figure is the owner's own, and says so.** "From my analysis of GPT-2 small" is a credibility claim that a stock illustration cannot make. Conversely, a borrowed or decorative AI-generated figure in this slot is actively damaging — note that the 2025 contest singled out Akshata Naik's site for *disclosing* AI art use, which is the standard now.
5. **Position: figure, then question, then link.** [ciechanow.ski](https://ciechanow.ski/) opens with the visual; [Deep Paper Gestalt](https://arxiv.org/pdf/1812.08775) found first-page teaser figures salient in classifying good papers. Lead with the image.
6. **One figure, not a gallery.** At 2-3 minutes, three figures compete and none wins.

**Complexity is HIGH and the dependency is on the owner, not the code.** The figure must be produced before the landing page can be finished. **Roadmap implication: sequence a "hero figure" task early, or design a graceful fallback** — e.g. the landing page composition works with the portrait alone, and the figure slot is additive. Do not build a layout that has a hole in it if the figure slips.

---

## Feature Dependencies

```
[Design tokens: colour, type scale, spacing, texture]
    └──required by──> [Paper ground across 7 pages]
    └──required by──> [Marginalia treatment]
    └──required by──> [Entry-point cards]
    └──required by──> [Contrast/axe pass]   <-- gate, must pass CI

[Light-theme-only decision]
    └──unblocks──> [Design tokens]  (halves the token surface)
    └──conflicts with──> [enable_darkmode: true in _config.yml]

[Portrait rendered]
    └──requires──> nothing. Asset exists. Ship first.

[Entry-point cards]
    └──requires──> [Card question micro-copy]              [CONTENT CARVE-OUT]
    └──requires──> [Destination content worth landing on]  <-- HARD. research.yml
                       details are empty; both _projects/*.md say "TODO".
    └──enhanced by──> [Hero research figure]

[Hero research figure on landing]
    └──requires──> [Figure produced + redrawn]         [ASSET DOES NOT EXIST]
    └──requires──> [One-line plain-language caption]   [CONTENT CARVE-OUT]
    └──enhanced by──> [enable_medium_zoom — already on]

[Book-cover reading-list block]
    └──requires──> [further_reading.yml populated]     [DATA IS EMPTY]
    └──requires──> [Cover images stored locally]       [DIRECTORY IS EMPTY]
    └──requires──> [Licensing/hotlink decision]
    └──ALTERNATIVE that ships today──> [Typographic reading list, notes as marginalia]
                       (needs only the data, no images)

[Any annotation/ink animation]
    └──requires──> [prefers-reduced-motion gating]     <-- WCAG; do not defer

[Print stylesheet]
    └──requires──> [Design tokens]  (needs to know what to neutralise)
    └──independent of everything else

[Honest in-progress status treatment]
    └──requires──> nothing new. PRESERVE existing .entry-status intent.
    └──conflicts with──> [any "Publications" framing, publication badges, fake BibTeX]
```

### Dependency notes

- **Cards require destinations.** This is the one dependency that can sink the headline feature. A card asking "Why do attention sinks appear?" that lands on a title with no abstract, no detail and no link is worse than no card. Either fill the `detail:` field for both papers, or point the cards at the pages that *do* have substance.
- **Light-only unblocks rather than merely simplifies.** Dropping dark mode roughly halves the token surface and removes every "does this warm grey work on both grounds" decision. It is the reason the rest of the milestone is achievable before the deadline.
- **The typographic reading list is the unblock for Further Reading.** It removes the image dependency entirely and can ship the same day the data is written.
- **Contrast is a gate, not a task.** `axe.yml` fails the build. Token colours must be contrast-checked at definition time, not audited at the end.

---

## MVP Definition

### Launch with (v1) — every item leaves the site shippable

- [ ] **Design tokens** (colour, type scale, spacing, texture primitives) in `_sass/_custom.scss` — everything depends on it; contrast-checked at definition time
- [ ] **Light-only**; `enable_darkmode: false` — halves the token surface, per PROJECT.md
- [ ] **Portrait rendered** on About — uncomment `profile:`; highest value per unit of effort in the whole milestone
- [ ] **Paper ground + serif body + hierarchy** across all 7 pages — the actual "one visual language" requirement
- [ ] **Preserve the quiet in-progress status treatment**, and keep the "Research" (not "Publications") heading — highest-stakes credibility item, costs nothing
- [ ] **Three entry-point cards** with concrete questions on About — the headline differentiator [needs content carve-out]
- [ ] **Annotated one-line section descriptions** on Research and Further Reading — cheapest differentiator available [needs content carve-out]
- [ ] **Mobile marginalia behaviour decided explicitly**, not left to reflow
- [ ] **`@media print` block** — white ground, black ink, expanded URLs
- [ ] **axe + Prettier + style-contract green**
- [ ] **`enable_progressbar: false`** (or restyled as an ink rule) — one config line

### Add after validation (v1.x)

- [ ] **Hero research figure**, redrawn, captioned — trigger: the figure asset exists. Design the landing page so this slot is additive, not load-bearing
- [ ] **Reading list populated** with 6-10 entries and real `notes` — trigger: the owner writes them. Ship typographic, no covers
- [ ] **Book covers** — trigger: reading list is live *and* local cover assets with a licensing decision exist
- [ ] **3-6 genuine margin notes** placed on About and Research — trigger: the owner writes real ones. Never templatise
- [ ] **One-line plain-language takeaway per paper** (the Kamšek pattern) — the single best upgrade to the Research page

### Future consideration (v2+)

- [ ] **Dark theme** — deferred by PROJECT.md, not rejected. Token layer should make this a palette swap
- [ ] **Interactive figure** (Ciechanowski/Distill register) — very high effort; wrong side of the deadline
- [ ] **A `/now` page** ([nownownow.com](https://nownownow.com/about), Derek Sivers' convention) — "what you'd tell a friend you hadn't seen in a year." Genuinely well-matched to the curiosity goal, but a staleness liability during an application cycle. Only worth it with a maintenance commitment
- [ ] **Repair `test/visual/*.spec.js`** for this site's real routes — PROJECT.md defers this correctly; the workflow is disabled, not fixed

---

## Feature Prioritization Matrix

| Feature | Reader Value (2-3 min admissions read) | Cost | Priority |
|---|---|---|---|
| Portrait rendered | HIGH | LOW | **P1** |
| Design tokens + contrast-safe palette | HIGH (enables all) | MEDIUM | **P1** |
| Paper ground + serif hierarchy, 7 pages | HIGH | MEDIUM | **P1** |
| Preserve honest in-progress labelling | HIGH (downside protection) | LOW | **P1** |
| Three question-led entry cards | HIGH | MEDIUM | **P1** |
| Annotated section descriptions | MEDIUM-HIGH | LOW | **P1** |
| Light-only / drop dark toggle | MEDIUM (enabler) | LOW | **P1** |
| Mobile marginalia behaviour | HIGH (failure is very visible) | MEDIUM | **P1** |
| axe contrast pass | HIGH (CI gate) | MEDIUM | **P1** |
| Print stylesheet | LOW-MEDIUM | LOW | **P2** |
| Turn off scroll progress bar | LOW | LOW | **P2** |
| Hero research figure | HIGH | HIGH (asset blocked) | **P2** |
| Reading list populated, typographic | MEDIUM-HIGH | LOW-MEDIUM (content blocked) | **P2** |
| Plain-language takeaway per paper | HIGH | LOW (content blocked) | **P2** |
| Genuine margin notes | MEDIUM | MEDIUM | **P2** |
| Book covers | MEDIUM | MEDIUM (double-blocked) | **P3** |
| `/now` page | LOW-MEDIUM | LOW + ongoing | **P3** |
| Dark theme | MEDIUM (some readers) | HIGH | **P3** |
| Interactive figures | HIGH if done well | VERY HIGH | **P3** |

---

## Competitor / Reference Feature Analysis

| Feature | [maggieappleton.com](https://maggieappleton.com/) | [jeffhuang.com](https://jeffhuang.com/) | [gwern.net](https://gwern.net/index) | This site's approach |
|---|---|---|---|---|
| Landing entry points | Annotated sections + illustrated cards | Dense list + curated "Long-Term Habits" | Newest / Popular / Notable | **3 question cards on About only** (navbar stays untouched per PROJECT.md) |
| Status of unfinished work | "things I don't entirely understand yet" | Essay on "the struggle for each paper" | `status:` + `confidence:` metadata | **Quiet `.entry-status`, non-"Publications" heading** |
| Figures | Hand-drawn illustration per essay | None | Sparse | **One redrawn notebook figure, hero slot, additive** |
| Reading list | Library with covers | None | Sparse annotations | **Typographic + notes first; covers later** |
| Face | Yes | Yes, near top | No | **Yes — asset already exists** |
| Motion | Minimal | None | Minimal | **None beyond ≤200ms hover, `prefers-reduced-motion`-gated** |
| Register | Playful-scholarly | Plain-fast-academic | Dense-archival | **Notebook: warm, serious, curious** |

---

## Sources

**Real example sites examined**

- [maggieappleton.com](https://maggieappleton.com/) — annotated sections, illustrated cards, Library with covers (fetched)
- [notes.andymatuschak.org/About_these_notes](https://notes.andymatuschak.org/About_these_notes) — "working with the garage door up," honest framing of unfinished work (fetched)
- [gwern.net/index](https://gwern.net/index) — Newest/Popular/Notable triple entry, titles-as-annotations, status/confidence metadata (fetched)
- [jeffhuang.com](https://jeffhuang.com/) — fast plain academic homepage, curated selection alongside full list (fetched)
- [ciechanow.ski](https://ciechanow.ski/) — figure-before-prose (fetched)
- [neelnanda.io](https://www.neelnanda.io/) — domain-adjacent; descriptive titles + one-line summaries (fetched)
- [sive.rs/book](https://sive.rs/book) — reading list with covers, ratings, dates, personal notes and an explicit caveat (fetched)
- [patrickcollison.com/bookshelf](https://patrickcollison.com/bookshelf) — unannotated shelf with an honest "read about half" disclosure; ~10 years stale
- 2025 Best Personal Academic Websites contest winners (fetched) — [cecibaldoni.github.io](https://cecibaldoni.github.io/), [kamsekar.github.io](https://kamsekar.github.io/), [megmindlin.com](https://www.megmindlin.com/), [anaikowl.com](https://www.anaikowl.com/), [patrick-manser.com](https://www.patrick-manser.com/), via [theacademicdesigner.com](https://theacademicdesigner.com/2025/winners-of-the-best-personal-academic-websites-contest-2025/)

**Empirical sources (strongest first)**

- Aubin Le Quéré & Matias, ["When curiosity gaps backfire: effects of headline concreteness on information selection decisions"](https://www.nature.com/articles/s41598-024-81575-9), *Scientific Reports* (2025) — pre-registered meta-analysis of 8,977 headline experiments. **HIGH internal validity, LOW-MEDIUM transfer to this audience.**
- ["Characterization of Unpublished Manuscripts by Applicants to an Orthopedic Hand Surgery Fellowship"](https://pmc.ncbi.nlm.nih.gov/articles/PMC10837291/) — 122 applicants; 27% misfiled submitted work under "Publications." **HIGH for the finding, MEDIUM for transfer.**
- Kaur et al., ["Clickbait — Trust and Credibility of Digital News"](https://ieeexplore.ieee.org/document/9405359), *IEEE Trans. Technology and Society* (2021) — n=200, clickbait framing lowers trust, p<.001. **MEDIUM**; contradicted on magnitude by ["The (Null) Effects of Clickbait Headlines…"](https://www.researchgate.net/publication/344620233_The_Null_Effects_of_Clickbait_Headlines_on_Polarization_Trust_and_Learning) — sources genuinely disagree.
- Selingo, *Who Gets In and Why* (2020) — embedded at [Emory](https://news.emory.edu/stories/2020/10/er_selingo_admission_book/campus.html), [Davidson](https://www.davidson.edu/news/2020/10/19/new-book-offers-inside-look-college-admissions-process-and-spotlights-davidson), U. Washington; ~8-minute application reads. **MEDIUM-HIGH.**
- [Kaplan admissions-officer surveys](https://kaplan.com/about/press-media/kaplan-survey-college-admissions-officers-applicant-social-media), 2018-2023 — 25-36% actually look applicants up; 67% consider it fair game. **MEDIUM** (commercial, but disclosed methodology, consistent series). **Measures social media, not supplied website URLs.**
- Huang, ["Deep Paper Gestalt"](https://arxiv.org/pdf/1812.08775) (arXiv, 2018) — first-page teaser figures salient in appearance-only classification of paper quality. **MEDIUM**, and deliberately tongue-in-cheek, but empirical.
- [A Usability and Universal Design Investigation into Scrolljacking](https://link.springer.com/chapter/10.1007/978-3-032-16454-4_6) (Springer) — peer-reviewed treatment of scrolljacking as a universal-design failure. **MEDIUM-HIGH.**

**Standards and guidance**

- [WCAG SC 2.3.3 Animation from Interactions](https://w3c.github.io/wcag/understanding/animation-from-interactions) (AAA) and [SC 2.2.2 Pause, Stop, Hide](https://dequeuniversity.com/resources/wcag2.1/2.3.3-animations-from-interactions) (A) — **HIGH**, normative
- [NN/g animation topic index](https://www.nngroup.com/topic/animation/) and [Executing UX Animations](https://www.nngroup.com/articles/animation-duration/) — parallax/scroll-jacking usability and vestibular harms. **MEDIUM-HIGH.**
- [nownownow.com/about](https://nownownow.com/about) — the `/now` page convention (Derek Sivers). **HIGH** (primary source for its own convention).
- Skill-bar criticism: [Peter Kang](https://www.peterkang.com/remove-those-silly-bars-on-resumes/), [dev.to — 40+ developer portfolios reviewed](https://dev.to/kethmars/what-i-learned-after-reviewing-over-40-developer-portfolios-9-tips-for-a-better-portfolio-4me7). **LOW-MEDIUM** — practitioner consensus, not controlled study, but unanimous.

**Explicitly rejected as unreliable**

- [collegebase.org, "Does Creating a Personal Website Help with College Admissions"](https://www.collegebase.org/blog/personal-website-college-admissions) — vendor blog; the widely-repeated "68% of admissions officers review applicant websites (NACAC 2023)" and "15-20% of competitive applicants have websites" figures carry **no citation, no methodology, no link**, and do not appear in NACAC's actual 2023 research. **Do not cite. Do not design against.**

**Repo state verified directly** (`assets/img/book_covers/` empty; `_data/further_reading.yml` both lists empty; `_data/research.yml` `detail:`/`url:` blank; `_projects/*.md` TODO stubs; `_config.yml` `enable_progressbar: true`, `enable_darkmode: true`, `enable_medium_zoom: true`; `_sass/_custom.scss` opacity-based de-emphasis). **HIGH.**

---
*Feature research for: personal academic portfolio — presentational redesign for a 2-3 minute admissions read*
*Researched: 2026-09-12*

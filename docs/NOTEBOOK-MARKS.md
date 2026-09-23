# Notebook marks — the vocabulary, the defences, and the blocklist

This is the written contract Phase 4 implements against. It is not a record of work already done: it was written before any CSS, and plans 04-02 and 04-03 build to it.

A "mark" here means a piece of non-textual decoration that makes the site read as a working notebook rather than a template — a rule, a bracket, an underline. The ground (warm paper) and the type (Literata and Be Vietnam Pro) are not marks; they are the page itself. Texture is not a mark either, for the same reason: it has no edges and names no content.

The whole argument of this document is that a notebook reads from **placement and restraint**, not from quantity. Every mark below names the content it serves. A mark that serves no content is decoration, and decoration is what this phase exists to ration.

---

## 1. The cap is four

**Four.** That is the whole vocabulary. Not "about four", not "four for now".

The number also lives in `_sass/_tokens.scss`, beside the TOKEN-06 caps that Phase 2 wrote there (plan 04-02 adds the line; the phase harness greps for it). It is stated in two places on purpose: adding a fifth mark therefore means visibly editing a stated number twice, rather than quietly appending a block to a stylesheet and a paragraph to a document.

Why a cap at all, when no individual mark is objectionable: register overshoot is only **partly recoverable**. A rule that turns out to be too loud can be deleted and the page returns to what it was. A reader who has already formed the impression that this is a busy, over-designed page cannot un-form it — they have moved on. The cost of the fifth mark is not paid by the fifth mark; it is paid by the whole page, retroactively, and it is not refundable. So the cap binds before the fact, which is the only time a cap can bind.

Every mark in the list below is **geometric**. The recommended "one hand-drawn signature move" was offered to the site owner and declined — see section 3.

---

## 2. The four marks

Each mark gets one section. Each section carries exactly one line that begins with the word _Defence_ followed by a colon, at the start of the line, and the phase harness counts those lines and requires **exactly four**. That is the enforcement mechanism for section 1: a fifth mark cannot arrive without either writing a fifth defence sentence (which turns the harness red) or shipping a mark nobody was willing to defend in one sentence (which is the failure the cap exists to prevent).

### Section rule

Defence: it shows the reader where one group of work ends and the next begins.

**Where:** `.entry-group-title` — a hairline **under** the heading, `border-bottom: var(--rule-hairline) solid var(--rule-500)`.

**Why that idiom:** it is the same construction already shipped on `.subject` in Phase 2. The repetition is deliberate. Two unrelated separators drawn two different ways read as accident; the same separator drawn the same way twice reads as a system, which is the entire perceptual mechanism this phase runs on.

**Why `--rule-500` and not `--rule-200`:** the section rule is **structural**. It carries the information "the list changes here", so a reader who cannot see it loses something. `--rule-500` measures 3.08:1 against the flat paper ground and clears WCAG 1.4.11's 3:1 floor for non-text content; `--rule-200` measures 1.43:1 and is decorative only. Plan 04-02 re-points `--rule-500` and re-measures it against the **composited** ground (paper plus texture), because every ink ratio in the token file today was measured against flat `#faf6ee` and the texture sits on top of that. The binding requirement is the measured ratio, not any particular hex.

**Reach:** three of the seven pages. That is a decision, not a shortfall — see section 3.

### Margin note

Defence: it carries the open question or caveat behind the item it sits next to, in one sentence that opens to the full account for a reader who wants it.

**Two states, one mark.** Collapsed, the note is a one-or-two-sentence summary in the margin beside the entry. Expanded, it is the site owner's full text. The second state arrived at plan 04-02's checkpoint (answer C): the owner supplied real prose roughly ten times the length of a margin note and chose a disclosure toggle over discarding it. That is one mark with two states and **not a fifth mark**, so the cap in section 1 stays at four — which is why the defence sentence above was rewritten in place rather than joined by a fifth. The "exactly four" count is the mechanism that forces that choice to be made deliberately.

**Where:** `.entry-note`, a native `<details>` that is a **sibling** of `.entry-body` inside `li.entry`, with the collapsed summary in its `<summary>`. Research page only in this phase; the About page belongs to Phase 6's composition work and the other three list pages to Phase 5.

**Native `<details>`, and no JavaScript.** A scripted toggle would put the expanded text behind a class this site has no way to guarantee. With the native element, every word of both states is in the DOM whether the widget is open or shut — so a screen reader reaches it, the stylesheet-off page still has all of it, and nothing has to be announced out of a pseudo-element.

**Why the column exists — and where it does not.** Phase 3 set `--measure: 36rem` against a 930px content width, which leaves roughly 354px of gutter on the right. That gutter was built deliberately and Phase 3's token file carries an in-line comment warning against reclaiming it. But it is a **prose** gutter and it does not reach this list: `.entry` is a flex row in a 900px content box, and the measure selectors touch only direct children of `<article>`, which `.entry-list` is not. The note column is therefore **created** here, out of `--note-col` plus `flex-wrap`, rather than moved into a gutter that was already there. Phase 3's warning still stands on its own terms; this mark does not test it.

**The expanded state breaks out of that column.** Roughly 230 words at about 27 characters per line is some 50 lines, and inside a ~208px column it would run far past its own entry and collide with the next note — breaking the non-overlap property the flex row otherwise gives for free. Open, the note takes its own flex line at the entry's full width, capped at `--measure` so four paragraphs read at the same measure as the rest of the site's prose. This is a layout judgement made from arithmetic and not from a render: plan 04-04's human sweep is the check, and if the breakout reads as a jump rather than as a disclosure, the fallback is the one already named in section 5 — drop the mark, keep the ground and the type.

**Why it is real markup and not a pseudo-element:** a margin note is **content**. It has to be there when the stylesheet is off, it has to be there for a screen reader, and it has to read in a sensible order as prose. Putting it in the markup after the body it annotates satisfies that by construction rather than by inspection — there is nothing to verify afterwards, because there is no way to get it wrong.

**Notes stay rare so they stay special.** One or two real notes, authored by the site owner about specifically named entries. The phase cannot close on placeholder prose: a margin note containing invented text is worse than no margin note, because it teaches the reader that the marginalia is set dressing.

### Annotation bracket

Defence: it shows which item the note belongs to.

**Where:** `.entry-note::before` — an L-shaped corner drawn from `border-left` plus `border-top` on a pseudo-element whose `content` is the empty string.

**Why a pseudo-element:** it must vanish cleanly. With the stylesheet off there is no bracket, no stray character, and nothing for a screen reader to announce. An empty `content` string is what makes that true; a bracket drawn as a literal character in `content` would be announced, which is exactly the failure GROUND-05 is about.

**Colour `--rule-200` (1.43:1), and why that is legitimate rather than an oversight.** WCAG 1.4.11 sets a 3:1 floor for "graphical objects needed to understand content". The bracket is not one. It is meaningless on its own: remove it and the note is still there, still readable, still in the right place in the reading order, still obviously about the entry it sits beside — because it sits beside it. The bracket adds a small amount of visual binding for a reader who can see it and takes nothing from a reader who cannot. That is the argued position. It is written down here so that a later reviewer finds an argument rather than an omission, and so that anyone who disagrees with the argument knows exactly which sentence to disagree with.

### Link underline

Defence: it marks a link without spending colour, which every warm ink accent on this site fails the 3:1 test against.

**Where:** `.post article a`, shipped in Phase 2. `a.btn` is exempt; navbar and footer links stay bare, because position already signals clickability in navigational furniture.

**It is listed here because the vocabulary is the complete list.** A mark that exists on the site but is absent from this document is a leftover, and leftovers are how a four-mark vocabulary becomes a six-mark one without anyone deciding to make it so. Naming it puts it under the cap.

**No change to its values is in scope for this phase.** `--underline-offset` stays at `0.18em` and `--underline-thickness-hover` stays as Phase 2 shipped it; both were eye-verified at the 03-04 checkpoint and neither contingency fired.

---

## 3. What is not a mark, and why — three decisions, not three omissions

### No hand-drawn mark

PITFALLS recommends "one signature move, repeated with discipline", and names a hand-drawn link underline as the candidate. It was offered to the site owner during Phase 4's context session and **declined**. The vocabulary is geometric throughout.

This is a **decided** question, not an unexplored one. Do not reintroduce a drawn, wobbly, or deliberately irregular mark in a later phase without reopening this section first — a later phase finding the site "a bit stiff" and adding a hand-drawn flourish would be re-deciding a settled question by accident.

### The section rule reaches three pages, not seven

Measured against the seven live pages: `.entry-group-title` appears on Academics (2 instances), Research (2) and Activities (5). Scoping the rule to `h2` instead would reach five pages — and would pull in the **home page**, whose composition Phase 6 owns.

The consequence, stated plainly rather than discovered later: **Further Reading and CV have no `h2` at all, and will carry the ground, the type and the texture but no mark whatsoever.**

That is the honest result of "every mark names the content it serves" applied to pages that have no sections. There is no content on those pages for a section rule to serve, so drawing one would be decoration by definition. Phase 8's screenshot-based mark count must read those two pages as **zero by design**, not as a miss. The precedent is Phase 3's `title-full` decision, where the deliberate absence of a selector was itself the decision and was recorded as one.

### No mark on `pre` / `code`, and none in the footer

No page on this site renders a `<pre>` or a `<code>` element. The footer has no background rule at all — `var(--global-footer-bg-color)` has zero consumers in the served CSS, so the footer already shows the body ground and there is nothing there to separate from anything.

A rule targeting either would be **dead source**: written, compiled, shipped, and never rendered. That is exactly what Phase 3 refused to write when it declined to declare a monospace family for code that does not exist. A dead rule added to make a decision look implemented is the third family entering by the back door, under a different name.

---

## 4. The cliche blocklist

Criterion 5 **is** this list, which is why it lives in the same document as the allowed marks rather than in a separate one. The allowed list and the forbidden list are two halves of one decision, and separating them is how the forbidden half gets forgotten.

None of the following ships, in any phase, in any form:

- Coffee or tea rings.
- Torn, burnt, or curled paper edges.
- Tape, washi tape, paperclips, pushpins, staples, or sticky notes.
- Spiral binding, ring binding, and hole-punch margins.
- Full-page blue-ruled or grid-ruled lines behind body text.
- Highlighter swipes used as texture or emphasis.
- Crosshatch shading, and doodled stars, hearts, arrows, or sparkles.
- Handwritten-signature graphics.
- Faux-3D page curl and stacked-sheet drop shadows.
- Aged-paper yellowing gradients and foxing stains.
- **No rotation or skew on anything containing text.** A tilted note is the single most common way a "notebook" site announces that it is a costume.

The last item is the one with a check behind it: `grep -rnE 'rotate\(|skew\(' _sass/` must stay empty, and the phase harness asserts it. The rest are enforced by reading this list before adding anything.

The general failure these all share: each one is a picture **of** a notebook. This site is not trying to look like a photograph of a notebook. It is trying to read like one — which is a property of restraint, spacing and annotation, and is destroyed rather than helped by literal props.

---

## 5. The two named fallbacks

Both are chosen now, in writing, while nothing is at stake. A fallback improvised at the point of failure is chosen under pressure by someone who has already sunk a phase into the thing that is failing, and it is reliably the wrong one.

### If the marks read as over-decorated: drop the marks, keep the ground and the type

The site then sits exactly at the roadmap's own Phase 3 "if work stops here" state — a finished typographic paper site, which was designed to be a legitimate stopping point precisely so that this fallback would exist.

Removing a mark is deleting one block from one file. It is cheap, and it is meant to be.

**Dialling the marks quieter was considered and rejected.** A quiet bad mark is still a bad mark: it keeps all of the cost (a rule in the stylesheet, a line in this document, a slot under the cap, a thing for a reader's eye to resolve) and gives up the only thing that justified it. If a mark is not earning its place at full strength, it is not earning its place.

### If iOS Safari does not render the tile faithfully: drop to the flat ground

Delete the single `background-image` declaration. The ground returns to flat `#faf6ee`, which is what Phase 2 shipped and what every contrast ratio in the token file was originally measured against.

**Do not reach for a raster tile.** A PNG or JPEG replacement costs a network request and 15-60 KB to solve a problem the fallback already solves for free, and it would be chosen in exactly the state of mind — late, annoyed, on a deadline — in which 15-60 KB stops feeling like a lot.

Why this is named rather than expected: `feTurbulence` has been Baseline-supported since 2015, and its one well-documented hard failure is **animating** `baseFrequency`, which this phase does not do. But community reports of mobile Safari degrading complex SVG background images could not be verified in this environment, which has no device lab. An unverifiable risk gets a named fallback, not a shrug and not a redesign.

---

## 6. Where the numbers live

No number in this document is authoritative, and none is restated here that lives somewhere else. One fact, one home.

| What                                                                           | Where it lives                   |
| ------------------------------------------------------------------------------ | -------------------------------- |
| Texture parameters (base frequency, octaves, tile size, the chosen rect alpha) | `_sass/_tokens.scss`             |
| Contrast ratios, including the composited-ground figures the texture forces    | `_sass/_tokens.scss`, in-comment |
| How any ratio was measured                                                     | `.planning/tools/contrast.js`    |
| The mark cap, as a number, beside the TOKEN-06 caps                            | `_sass/_tokens.scss`             |
| Which alpha was chosen, and what it was chosen against                         | plan 04-02's recorded checkpoint |
| Whether any of the above is actually true of the deployed site                 | the phase harness, `--live`      |

If a number in this document ever disagrees with one of those, the file is right and this document is stale. Fix this document.

# Phase 4: Notebook Art Style - Context

**Gathered:** 2026-09-18
**Status:** Ready for planning

<domain>
## Phase Boundary

Paper texture on the warm ground Phase 2 already shipped, plus a small, written, named vocabulary of notebook marks — rules, marginalia, annotation — each carrying a one-sentence defence that names the content it serves (GROUND-02, GROUND-03, GROUND-05).

What this phase does NOT deliver: the entry treatment on the four data-driven list pages (Phase 5), the home page composition (Phase 6), `@media print` and the mobile hardening sweep (Phase 7), the contrast/register audit against the deployed site (Phase 8).

</domain>

<decisions>
## Implementation Decisions

### Texture

- **Visibility: barely perceptible.** Noticed only when looked for, or against a flat swatch. Criterion 1 still requires it be *visible* at normal reading distance on desktop and on a 390px phone — so this is the floor, not invisibility. The register argument (PITFALLS Pitfall 3) beat the "more notebook from the ground" argument: texture is connective tissue, not a feature.
- **Grain character: fine, even tooth.** Uniform fine noise, like good uncoated writing paper. NOT coarse fibrous/handmade grain — that sits closer to the skeuomorphic edge and is harsher behind 17px Literata. Aged-paper colour grading is on the blocklist and does not ship in any form.
- **Reach: everything paper-coloured, one continuous sheet.** Body, navbar, footer, cards and code blocks all carry it. This is a deliberate rejection of "body only" — PITFALLS states plainly that a flat navbar above a textured page reads as a rendering bug. The hook already exists: Phase 2's `_sass/_custom.scss:264` already un-fades the gem's `.navbar { opacity: .95 }`.
- **Mobile: identical everywhere.** Same tile, same visibility, desktop and phone. No breakpoint, no media query, no reduced variant. The tiled approach is cheap enough (~25–75× less filter work than full-viewport) that there is no performance reason to vary it, and criterion 1 requires phone visibility anyway.
- Technique is not a user decision and is already settled by research: a ~480-byte url-encoded inline SVG `feTurbulence` in a 200×200 data-URI, `background-repeat`, `stitchTiles="stitch"`, `numOctaves` 1–3. Zero network requests, under the 2 KB budget by two orders of magnitude. **`background-attachment: fixed` is ruled out** (per-frame repaint, iOS Safari stutter).

### Mark rendering

- **Geometric throughout.** Crisp hairline CSS rules and brackets built from the existing `--rule-200` / `--rule-500` tokens. The "notebook" reads from *where* marks sit — margin, beside a heading — and from restraint, not from imitated handwriting.
- **The hand-drawn signature move was considered and rejected.** PITFALLS recommends "one signature move, repeated with discipline" and names the hand-drawn link underline as the candidate; the user chose geometric anyway. Do not reintroduce a drawn/irregular mark during planning or execution — this is a decided question, not an open one.
- No rotation or skew on anything containing text (register marker #4, and it is grep-checkable).

### The vocabulary

Four marks. **The cap reads 4** — written down as a stated number in the vocabulary file, mirroring the TOKEN-06 mechanism already working at `_sass/_tokens.scss:23`. Adding a fifth mark means visibly editing that number, not quietly appending a line.

1. **Section rule** — a hairline at section headings (`.entry-group-title`, `h2`). Defence: *it shows the reader where one group of work ends and the next begins.* Structural, so it takes `--rule-500` (3.08:1), not the decorative `--rule-200` (1.43:1).
2. **Margin note** — a subordinate note in the ~354px right gutter Phase 3 deliberately created (`--measure: 36rem` against `max_width: 930px`). Defence: *it carries the open question or caveat behind the item it sits next to.*
3. **Annotation bracket / tick** — a small pointer tying a note to the item it annotates. Defence: *it shows which item the note belongs to.* Meaningless on its own, which is what GROUND-05 wants; implement as a pseudo-element so it vanishes cleanly with the stylesheet off.
4. **Link underline** — already shipped in Phase 2 (`.post article a`, `--underline-thickness`, `--underline-offset`). Listed here so it is part of the named vocabulary rather than a leftover. No change to its values is in scope.

- **The cliché blocklist lives in the vocabulary file, beside the allowed list.** One document: what is allowed with each defence sentence, what is banned. Source list is PITFALLS "The notebook-cliché blocklist" — coffee/tea rings, torn or burnt edges and curled corners, tape/paperclips/pushpins/staples/sticky-notes, spiral binding and hole-punch margins, full-page blue-ruled lines behind body text, highlighter swipes as texture, crosshatch shading and doodled stars/hearts/sparkles, handwritten-signature graphics, faux-3D page curl and stacked-sheet shadows, aged-paper yellowing gradients. Criterion 5 is this list.

### Marginalia content

- **The user authors 1–2 real notes in their own words.** This phase cannot close on placeholder prose. There is no `note:` field in any `_data/*.yml` today — margin-note content does not exist anywhere in the repo.
- **This requires a named checkpoint in the plan** that comes back to the user with a *specific* ask: which research entries to annotate, and what kind of note each one wants. Do not ask "write me some notes" — name the items.
- **Permitted note kinds, all four acceptable:** the open question (what is still not understood — PITFALLS's own worked example), the method caveat (a limit or condition on a result), the surprising result (what was not expected), why it mattered to the author (the connection that made them pick it up).
- **Proven on the Research page only** in this phase. One page, one or two notes, fully proven. Phase 5 rolls the treatment to Academics, Activities and Further Reading; Phase 6 owns the home page, so Phase 4 stays off About to avoid two phases editing the same composition.
- **Stylesheet-off behaviour: the note reads inline, in reading order.** Real markup that, unstyled, appears as an ordinary sentence immediately after the item it annotates — nothing orphaned, nothing lost, nothing out of order. CSS moves it to the gutter. This satisfies criterion 3 and GROUND-05 by construction rather than by inspection.

### Register budget and distribution

- **Only marks serving no content count against criterion 4's ≤2-per-first-viewport cap.** The section rule, the margin note and the annotation bracket each serve content, so none of them counts. The cap therefore binds anything added *later* with no job — which is the failure it exists to prevent. The count is taken on a screenshot, as the criterion says, not eyeballed.
- **Distribution: the section rule goes everywhere there are sections; margin notes only on Research.** The rule is structural furniture and repeating it is what makes the site feel like one system ("repetition reads as a system; variety reads as indecision"). Notes stay rare so they stay special.
- **Register-overshoot tests the user explicitly wants run:** (a) greyscale + 8px blur on each page — headings must remain the strongest shapes, no ornament may survive the blur more strongly than an H1; (b) the stylesheet-off test — disable `main.css`, reload, confirm content complete, correctly ordered, no orphaned symbol.
- **Two further proofs are phase obligations, not options** — they are named directly in the roadmap's success criteria and were flagged to the user as such: the **written one-sentence defence per vocabulary entry** (criterion 2) and the **screenshot mark count across all seven pages** (criterion 4). The user did not select these among the tests to emphasise; they were kept because cutting them would mean amending the roadmap, which was offered and not taken.
- **Fallback if the marks read as over-decorated: drop the marks, keep ground and type.** This is the roadmap's own Phase 3 "if work stops here" state — a finished typographic paper site — and it is named now so it is a decision rather than a panic. Removing a mark is deleting one block from one file. Dialling marks quieter was considered and rejected: a quiet bad mark is still a bad mark.

### Claude's Discretion

- Exact `feTurbulence` parameters (baseFrequency, numOctaves, alpha) and the tile's measured byte size — pick values that read correctly against Literata on `#faf6ee`, and record the numbers in the token file.
- Whether the section rule sits under or beside its heading; the bracket's exact glyph/geometry and size.
- Where the vocabulary file physically lives (`docs/`, `_sass/`, or `.planning/`) and whether the mark cap sits there or alongside the other caps at `_sass/_tokens.scss:23`.
- Whether the note is authored as a `note:` key in `_data/research.yml` or as inline markup in `_pages/research.md`.
- Whether marginalia sits left or right of the column, and what happens when two consecutive entries both carry notes.
- How many deploys the phase spends and how the work is split across plans.

</decisions>

<specifics>
## Specific Ideas

- The user consistently chose the conservative option in every one of the sixteen questions asked. That is itself a decision about this phase: **when a judgement call arises during planning or execution and the evidence is balanced, take the quieter option.**
- PITFALLS's worked example of a good margin note — *"this is the part I still don't understand"* — is the register to aim for. A hand-drawn arrow pointing at nothing is the register to avoid. Both are "notebook"; only one survives a skeptical reader.
- The ~354px gutter is not spare space. `_sass/_tokens.scss:157–175` warns in-comment that narrowing `max_width` to match `--measure` "would look like an improvement and would silently delete a future phase's canvas." That future phase is this one.

</specifics>

<code_context>
## Existing Code Insights

### Reusable Assets

- `_sass/_tokens.scss` — THE token file; every colour and length literal in the design lives here and nowhere else (Phase 2 criterion 5). A hex, rem, em or px in any other `_sass/` file is a bug. The texture tile's parameters and any new mark lengths belong here.
- `--rule-200: #d9cfba` (1.43:1, **decorative only, never load-bearing**) and `--rule-500: #9c8b6e` (3.08:1, structural separators) — the section rule takes `--rule-500`.
- `--measure: 36rem` (576px) against `max_width: 930px` leaves the **~354px gutter** this phase's marginalia occupies. Created deliberately in Phase 3 and documented as such in-comment.
- `--space-1` … `--space-4`, `--rule-hairline: 1px`, `--underline-thickness`, `--underline-offset: 0.18em`, `--focus-ring-width: 2px`, `--focus-ring-offset: 2px`.
- `.planning/tools/contrast.js` — reproduces all eight PITFALLS figures to within 0.01, self-tests via `--selftest`. No CI gate on this site covers contrast; this tool plus the in-file ratio comments are the whole enforcement.
- The phase-`verify.sh` harness pattern from Phases 1–3, with its `[red until plan 0N-NN]` red-by-design label mechanism and `EXPECTED_RED` counter. Phase 3 closed with `EXPECTED_RED` back to 0 and **kept the mechanism and its header comment specifically for Phase 4**.

### Established Patterns

- **Token file / consumer split.** `_sass/_tokens.scss` declares; `_sass/_custom.scss` consumes and declares no literals. Phase 3 kept this intact.
- **`_sass/` is NOT a forbidden path on this fork.** `test/style_contract.js` has its forbidden-path loops commented out at lines 68–84 and 96–108 with in-file explanations. `CLAUDE.md`'s "This fork: the stop sign is disabled" section is authoritative over the inherited upstream text.
- **Annotate, never paper over.** When a gate and a correct implementation disagree, narrow the matcher and write down why — done five times so far. When a recorded justification turns out to describe a case the rule does not cover (the `--underline-offset` provenance, `_sass/_tokens.scss:190`), the comment is left standing and the finding written up separately.
- **Caps are written numbers.** `_sass/_tokens.scss:23` states paper tones 2 / ink steps 4 / accent colours 1 / type families 2, three lines above the declarations. The mark cap follows this form.
- **PurgeCSS silently strips rules.** It deleted `:focus-visible` from every production build across all of Phase 2 unnoticed. `purgecss.config.js` has 22 safelist entries; Phase 3's rule was to **ship safelist entries in the same commit as the rule that names them**, and that made a predicted breakage a non-event. Any new mark selector follows the same rule, and the phase must grep the **served** CSS, not the local build.
- **No `!important` anywhere in `_sass/`.** Verified by a narrowed matcher (the naive grep hits comment prose).
- **`opacity` is reserved for non-text only** — rules, texture layers, decorative marks. All four previously-dimmed text classes were converted to `--ink-500` in Phase 2.

### Integration Points

- `_sass/_custom.scss:264` `.navbar` — already overrides the gem's `opacity: .95`; this is the hook for the navbar sharing the texture.
- `_sass/_custom.scss:249` `.card` / `:253` `.hoverable:hover` — already strip tailwind's hardcoded black shadows; cards are flush and shadowless by decision, which is why `--paper-50` was never declared.
- `_sass/_custom.scss:239` `code` — the `--paper-200` recess ground.
- `_pages/research.md` — hand-written Liquid over `_data/research.yml`; `.entry-group`, `.entry-group-title`, `.entry-list`, `.entry`, `.entry-year`, `.entry-body`, `.entry-title`, `.entry-meta`, `.entry-status`, `.entry-detail`, `.topic-list`. A `note:` key would slot alongside `detail:` / `status:` / `url:`.
- `assets/css/main.scss` loads `_tokens.scss` immediately before `@use "custom";`.
- `purgecss.config.js` — safelist, 22 entries. The leading colon in `":focus-visible"` is load-bearing.
- `deploy.yml` uses a `paths-ignore` denylist that includes `.planning/**`, so planning commits do not trigger deploys. Deploy band measured at 112–168 s, with one 75 s outlier that does **not** re-baseline it.

### Hazards carried in from earlier phases

- **Every ink ratio in `_tokens.scss` was measured against flat `#faf6ee`, not against noise.** Texture composites over the ground, so the real ratios shift. Criterion 1 of Phase 8 explicitly demands "composited values — text over texture, not text over the flat token." Whether this phase re-measures or hands it to Phase 8 is a planning decision, but it must not be dropped silently.
- **A focus ring over texture is visually destroyed even at a passing computed ratio** (PITFALLS). The 2px width and 2px offset already shipped were chosen partly for this; verify the ring still reads once the grain is on.
- Two close-out tags are still outstanding and are NOT this phase's work: `design-02-<slug>` on `482c740`, and `design-03-<slug>` on `gh-pages` tip `a5553c1c3d8e43ca6ee2e821a119ddc16e3e2cee` (re-read the tip at tagging time).
- `gsd-tools state record-metric` has deleted `stopped_at:`, `resume_file:` and `progress.percent:` and set `status: unknown` on **ten** consecutive occasions, and writes its metric row in the wrong format. Expect to restore all four by hand.

</code_context>

<deferred>
## Deferred Ideas

- **Rolling the marginalia treatment to Academics, Activities and Further Reading** — Phase 5 (PAGE-06), which also owns its mobile collapse below ~768px.
- **Marks on the home page / About** — Phase 6 owns that composition; Phase 4 deliberately stays off it.
- **`@media print` handling of the texture and marginalia** — Phase 7. PITFALLS already drafts the block: let the texture drop out rather than forcing it, and keep notes with their content so none is orphaned at a page break.
- **`prefers-reduced-motion`** — Phase 7, and only if this phase ships any transition (it is not planned to).
- **Re-measuring contrast on the composited textured ground** — Phase 8 criterion 1, unless this phase's plan chooses to pull it forward.
- **The `--underline-offset: 0.18em` provenance finding** — `_sass/_tokens.scss:190` justifies the value by Vietnamese below-baseline marks in links, but no link on any of the seven deployed pages contains one. Owned by **Phase 4 if it widens link scope** (it is not planned to) or otherwise Phase 8. The value is not wrong; its recorded reason has never been tested. Blocks nothing.
- **Phase 3's unrecorded readings** — check B's characters-per-line number and check C's clears/collides verdict were approved without a measurement being supplied. Phase 8 should re-run the `Range.getClientRects()` snippet.

</deferred>

---

*Phase: 04-notebook-art-style*
*Context gathered: 2026-09-18*

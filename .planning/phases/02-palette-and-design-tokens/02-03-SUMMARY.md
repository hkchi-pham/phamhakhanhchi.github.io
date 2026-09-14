---
phase: 02-palette-and-design-tokens
plan: 03
subsystem: styling
tags: [design-tokens, cascade, wcag, gem-overrides, focus-visible, underlines]

# Dependency graph
requires:
  - phase: 02-palette-and-design-tokens
    plan: 02
    provides: "_sass/_tokens.scss — the nine primitives, the --step-/--space- scale and the eight named measures (--entry-year-col, --subject-row-max, --rule-hairline, --underline-thickness{,-hover}, --underline-offset, --focus-ring-{width,offset}) that make a literal-free _custom.scss possible at all"
  - phase: 02-palette-and-design-tokens
    plan: 01
    provides: "verify.sh's eleven [red until plan 02-03] rows, which defined this plan's finish line before it was written; .planning/tools/contrast.js"
provides:
  - "_sass/_custom.scss (215 lines) — de-faded, de-literalised entry styles plus the six gem behaviours no token can reach"
  - "Body-copy link underlines scoped to `.post article a`, with navbar and footer deliberately excluded (GROUND-04)"
  - "The site's only :focus-visible rule — the gem defines none"
  - "A re-dated deploy canary: --deploy-proof: \"2026-09-14 phase-02-tokens\", which plan 02-04 greps out of the served CSS"
  - "A value-aware no-faded-text assertion in verify.sh, replacing one that no correct implementation could satisfy"
affects: [02-04, 03-typography, 04-notebook-art, 07-mobile-print, 08-qa-audit]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Gem overrides live in one clearly-fenced section, each rule carrying a comment naming its gem source file and line, so a later reader can tell a correction from a design choice"
    - "Link affordance is underline-first: hover changes the STROKE WEIGHT, not the colour, so no second accent value ever has to be kept in contrast"
    - "No !important anywhere: main.css is unlayered and loads after the gem's fully-@layer'd tailwind.css, so an unlayered normal declaration wins without a specificity fight"

key-files:
  created: []
  modified:
    - _sass/_custom.scss
    - .planning/phases/02-palette-and-design-tokens/verify.sh

key-decisions:
  - "All six heading levels PLUS .post-title take --ink-900 (15.88:1) against body copy's --ink-800 (13.90:1). 02-CONTEXT left the scope open; hierarchy now rides on size, weight AND ink depth, which is the second lever Phase 7's greyscale-blur test needs."
  - "The active-nav marker is the gem's existing `font-weight: bolder` on `.nav-item.active > .nav-link` (_navbar.scss:120-127). It is a non-colour marker, it survives greyscale, and no new mechanism was invented."
  - "Underlines are scoped to `.post article a` exactly — navbar and footer links stay bare, because position already signals clickability in navigational furniture. `a.btn` is exempted for the CV page's .cv-actions buttons."
  - "verify.sh's TOKEN-03 row was narrowed from name-aware to value-aware. It contradicted the adjacent `.navbar opacity: 1` row outright; the row keeps its number, label and EXPECTED_RED accounting."
  - "NO token was added to _sass/_tokens.scss. Every value this plan needed already existed by name — the token file is byte-identical to how plan 02-02 left it."

patterns-established:
  - "Prose inside _sass/ must not spell a string the harness asserts is absent — tripped once again here, in the very comment explaining the removal, and caught before the first commit."
  - "When two harness rows contradict each other, narrow the one whose matcher is further from the criterion's MEANING (here: the value, not the property name), and write the contradiction into the file with its date."

requirements-contributed: [TOKEN-01, TOKEN-02, TOKEN-03, GROUND-04]
requirements-completed: []

# Metrics
duration: 7min
completed: 2026-09-14
---

# Phase 2 Plan 03: The Overrides Tokens Cannot Reach Summary

**`_sass/_custom.scss` is now literal-free and fade-free — four `opacity` dims replaced by a measured 6.99:1 ink, every `rem`/`em` snapped to a token — and carries the six gem behaviours no re-pointed `--global-*` could ever fix: code painted as a link, cards wearing hardcoded black halos, a 95%-faded navbar, one ink for headings and body alike, no underline on body links, and no focus ring anywhere in the gem.**

## Performance

- **Duration:** 7 min
- **Started:** 2026-09-14T15:15Z
- **Completed:** 2026-09-14T15:22Z
- **Tasks:** 2 (plus 1 deviation fix, plus 1 caught-before-commit)
- **Files modified:** 2

## Accomplishments

- **The phase harness went from 14 red rows to 3.** All eleven `[red until plan 02-03]` rows are green; the three that remain are `enable_darkmode`, `enable_progressbar` and `footer_fixed`, every one of them labelled `[red until plan 02-04]`. **79 checks, 3 failed, 3 red-by-design, 0 unlabelled.**
- **`grep` for a fade in `_sass/` now returns exactly one line, and its value is `1`.** The four dimmed classes (`.entry-year` 0.6, `.entry-meta` 0.75, `.subject-grade` 0.75, `.entry-status` 0.7) all take `var(--ink-500)` instead, measured at **6.99:1** on the paper ground. `.subject-grade` was not named in TOKEN-03 or in criterion 4 — it had the identical defect and 02-CONTEXT puts it in scope, so it was fixed with the other three.
- **`_custom.scss` holds no colour and no length literal.** `custom_has_no_literals` passes: no hex, no `rem`/`px`/`em`, no `color-mix`, with only the `--deploy-proof` date string and `//` comment lines exempt. The `.subject` separator's `color-mix(in srgb, currentColor 12%, transparent)` — measured at 1.26:1, i.e. structurally load-bearing and effectively invisible — is now `var(--rule-hairline) solid var(--rule-500)` at **3.08:1**, clearing WCAG 1.4.11's 3:1 for a graphical object you need in order to read the row.
- **Links are identifiable without colour.** `--accent-600` against `--ink-800` re-measures at **2.24:1 (FAIL)**, which is the whole argument: colour alone cannot carry a link on this palette. `.post article a` is underlined with the offset token that clears Vietnamese below-baseline marks, hover thickens the stroke rather than shifting the hue, and `a.btn` is exempt.
- **The site has a focus ring for the first time.** The gem defines no `:focus-visible` rule at all; this one is `var(--focus-ring-width)` (2px) solid `--ink-900` at **15.88:1** on paper, with a 2px offset putting it on clean ground clear of the glyphs.
- **No `!important`, no specificity fight, no new token.** Every override wins on the cascade fact plan 02-03 was handed — unlayered `main.css` after fully-`@layer`'d `tailwind.css` — and every value it needed already existed in `_tokens.scss` by name.

## Task Commits

1. **Task 1: strip the fades and the literals from the entry styles** — `b84f98a` (fix)
2. **Task 2: the six gem-behaviour overrides + re-dated canary** — `3c08c35` (feat)
3. Deviation fix: the no-faded-text harness row made value-aware — `a19e3bb` (fix)

## The deploy canary (plan 02-04 greps for this)

```
--deploy-proof: "2026-09-14 phase-02-tokens";
```

`_sass/_custom.scss` line 19. It was re-dated, not deleted, not folded into `_tokens.scss` — a token audit is precisely the thing that would wrongly remove an unreferenced custom property. The harness's live row compares the served CSS against whatever this file currently declares, so it needs no edit to follow this change.

## Tokens added to `_sass/_tokens.scss`

**None.** Plan 02-02's "Next Phase Readiness" claim held exactly: every name this plan consumes — `--space-1..4`, `--step-0`, `--step-2`, `--entry-year-col`, `--subject-row-max`, `--rule-hairline`, `--rule-500`, `--ink-500`, `--ink-800`, `--ink-900`, `--underline-thickness`, `--underline-thickness-hover`, `--underline-offset`, `--focus-ring-width`, `--focus-ring-offset` — already existed and already spelled the way this plan's text expected. `_tokens.scss` is untouched by this plan.

## The six overrides, and what each one was fighting

| # | Rule | Gem source | Why a token cannot do it |
| - | ---- | ---------- | ------------------------ |
| 1 | `pre, code { color: var(--ink-800) }` | `_utilities.scss:26,47` | The gem paints both from `--global-theme-color`; re-pointing that token repaints links too. Same (0,0,1), later source order. |
| 2 | `.card { box-shadow: none }` + `.hoverable:hover { box-shadow: none; transform: none }` | prebuilt `tailwind.css`; `_components.scss:56-67` | The shadows are raw literals inside the un-recompilable prebuilt CSS, so no token reaches them. |
| 3 | `.navbar { opacity: 1 }` | `_navbar.scss:11` | No `--global-*` name controls a fade on the whole fixed element. |
| 4 | `h1..h6, .post-title { color: var(--ink-900) }` | `_typography.scss:7-19` | One `--global-text-color` covers `p` and every heading level together. |
| 5 | `.post article a` underline set | — | The gem/tailwind `a { text-decoration: none }` sits in `@layer base`; an unlayered rule beats it without `!important`. |
| 6 | `:focus-visible { outline: … }` | — | The gem has no such rule to re-point. |

Spacing shifts inside the entry lists (`1.75rem` → `--space-4` = 1.5rem, `0.15rem` → `--space-1` = 0.25rem, `1.1rem` → `--space-3` = 1rem, `0.2rem` → `--space-1`) are intended: the file's own comment calls these styles "deliberately plain -- the real design pass replaces this wholesale", and that pass is Phase 5. The four-step scale is the point.

## Things deliberately NOT done

- **No navbar bottom rule was added.** The gem's navbar border already reads `--global-divider-color`, so 02-CONTEXT's "a bottom rule rather than a tonal band" was delivered by plan 02-02's re-point. Adding one here would have doubled it.
- **No new active-nav mechanism.** `_navbar.scss:120-127` already sets `font-weight: bolder` on `.nav-item.active > .nav-link`. Non-colour, survives greyscale, already shipping.
- **Nothing pushed.** Plan 02-04 owns this phase's single push.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Two harness rows contradicted each other over the navbar reset**

- **Found during:** Task 2 verification (the full harness run)
- **Issue:** `verify.sh` carried criterion 4's command verbatim — the property name must not appear anywhere under `_sass/` — while the Override row sixty lines below it *requires* `.navbar { opacity: 1 }` in `_custom.scss`. The only CSS that can undo the gem's fade is that same property set back to `1`, so the two rows were mutually unsatisfiable and **no correct implementation could turn both green**. Task 1 passed the row; Task 2 necessarily broke it. Note that this plan's own `must_haves` phrases the truth as "returns no *text selector*", so the plan anticipated the gap even though the harness did not.
- **Fix:** Added a `no_faded_text()` helper that flags any declaration of the property whose value is not exactly `1`, and pointed the row at it. Narrowing is on the VALUE, which is where the criterion's meaning lives. Strictly stronger in one respect — the old row could be satisfied by a file that still faded text through a shorthand the grep did not name — and weaker only in permitting the single deliberate un-fade. The row keeps its number, its `[red until plan 02-03]` label and its place in the `EXPECTED_RED` accounting; the contradiction and its date are written into the file above the helper.
- **Files modified:** `.planning/phases/02-palette-and-design-tokens/verify.sh`
- **Verification:** Sanity-checked against synthetic input — `0.75` and `.9` are caught, `1;` is not. The row is PASS; tally is 79 / 3 failed / 3 red-by-design / 0 unlabelled.
- **Committed in:** `a19e3bb`

**2. [Rule 1 - Bug] The comment explaining the removal spelled the forbidden string**

- **Found during:** Task 1, before the first commit
- **Issue:** The new comment above the entry styles read "the four classes that used to carry an opacity value… opacity makes the COMPUTED colour differ from the declared one". `_sass/` is grepped for that exact word, so the prose *about* removing the fades would itself have kept the row red. This is the same mistake plan 02-02 made twice and explicitly warned 02-03 about — and it reappeared inside the sentence documenting the fix.
- **Fix:** Reworded to "dimmed by a transparency value" / "dimming text that way", with a closing line stating that the comment deliberately does not spell the property name and why. Caught before `git add`, so it never entered history.
- **Files modified:** `_sass/_custom.scss`
- **Verification:** The word appears exactly once in `_sass/`, in the `.navbar` declaration itself.
- **Committed in:** `b84f98a` (fixed pre-commit)

### Judged, not escalated

**3. [Rule 4 → judged] `git diff --stat` touched a second file, as in 02-02**

The plan's verification clause allows `_sass/_custom.scss` plus `_tokens.scss`. `verify.sh` is the actual second file, for the same reason and under the same governing convention 02-02 recorded (02-01: "a criterion that is not yet true stays in the harness … deleting a row to get a clean tally is forbidden"). The alternative was leaving one row permanently red against a correct implementation, or shipping a translucent navbar. Committed separately as `fix(02-03)` so the `_custom.scss` change is reviewable on its own.

**4. [Protocol] `requirements mark-complete` deliberately NOT run**

Third time, same reasoning as 02-01 and 02-02. TOKEN-02 is now genuinely satisfied (`_custom.scss` consumes `var(--space-` and `var(--step-`), TOKEN-03's fades are gone and GROUND-04's underlines exist — but all three are also claimed by 02-04, and GROUND-01/TOKEN-04 cannot be true until the change is deployed and looked at. **Plan 02-04 marks TOKEN-01..06, GROUND-01 and GROUND-04 once `verify.sh --live` is fully green.**

---

**Total deviations:** 4 (2 auto-fixed, 2 judged-and-recorded)
**Impact on plan:** No scope creep. Both bugs are the same underlying phenomenon the previous plan named — a grep-based harness reads prose as content, and a crude assertion eventually meets a legitimate exception. Neither cost more than a reword.

## Issues Encountered

- **A `python - <<'PY'` heredoc was refused by this environment's permission classifier**, so the one multi-line text replacement went through the Edit tool instead. Combined with 02-01's `unexpected EOF` and 02-02's backslash mangling, the standing rule holds: **write whole files with a quoted `cat > … <<'SCSS'` heredoc, and make targeted edits with the Edit tool — never with an inline interpreter.**
- **No Jekyll build is possible here** (no Ruby), so "the unlayered rule beats the layered one" and "later source order wins the (0,0,1) tie" are verified by construction and by the cascade facts the plan supplied, not by inspecting compiled CSS. Plan 02-04's live block is where they become measurements.
- **Prettier changed nothing** in either `_sass/` file — both were written Prettier-shaped — so no comment was re-flowed and no ratio figure was mangled.

## User Setup Required

None. **Nothing was pushed.** Plan 02-04 owns this phase's single push, so the token re-point, the overrides and `enable_darkmode: false` reach production in one deploy.

## Next Phase Readiness

**Ready for plan 02-04.** Everything it needs is in place:

1. **The canary to grep for is `"2026-09-14 phase-02-tokens"`** — and the live row already reads that value out of `_sass/_custom.scss` rather than a hardcoded copy, so no harness edit is needed.
2. **Three static rows remain red, all three in `_config.yml`:** `enable_darkmode: false`, `enable_progressbar: false`, `footer_fixed: false`. They are the whole of 02-04's static work.
3. **Requirements to mark:** TOKEN-01..06, GROUND-01, GROUND-04 — once `verify.sh --live` is fully green, per the pending todo carried since 02-01.

**Two things 02-04's human-verify checkpoint should look at specifically**, because nothing here could check them:

- **The projects page `.card`.** Flush cards with no shadow is a real visual bet: if the card boundary now reads as nothing at all, the fix is a `--rule-200` hairline in Phase 4/5, not a re-added shadow.
- **Underline collisions under Vietnamese diacritics.** `--underline-offset: 0.18em` is a computed guess at clearing ạ and ợ; it has never been rendered. If it collides, it is a one-line token change.

**Concerns:** none blocking. The CRLF override-hash caveat from 02-02 is still the only latent false-red and still cannot fire on this machine.

---

_Phase: 02-palette-and-design-tokens_
_Completed: 2026-09-14_

## Self-Check: PASSED

Both artifacts exist (`_sass/_custom.scss` is 215 lines against the plan's 110-line floor and contains `.post article a`; `verify.sh` is 472 lines). All three key_links resolve: 18 `var(--ink-|--paper-|--rule-|--accent-|--step-|--space-)` references in `_custom.scss`, `text-decoration: underline` present, and `pre,` matching the harness's line-anchored pre/code pattern. All three commits (`b84f98a`, `3c08c35`, `a19e3bb`) are in `git log`. `_sass/_tokens.scss` was confirmed untouched — its last commit is still 02-02's `995b775` — so the "no token added" claim is verified rather than asserted.
</content>
</invoke>

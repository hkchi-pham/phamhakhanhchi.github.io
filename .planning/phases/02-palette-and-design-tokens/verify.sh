#!/usr/bin/env bash
#
# Phase 2 (Palette and Design Tokens) — repeatable verification harness.
#
# Composes every AUTOMATABLE row of 02-VALIDATION.md's "Per-Task Verification
# Map" into one command, so each phase criterion can be re-checked on demand
# instead of being a one-off command someone has to remember.
#
#   bash .planning/phases/02-palette-and-design-tokens/verify.sh          # static only
#   bash .planning/phases/02-palette-and-design-tokens/verify.sh --live   # + network block
#
# Same shape as .planning/phases/01-deployment-guardrails/verify.sh, on
# purpose. It is deliberately NOT a test framework and deliberately NOT wired
# to an npm script: 01-VALIDATION.md forbids a starter-local build/test
# pipeline and 02-VALIDATION.md carries that forward ("No framework install.
# No npm script. No package.json change."). It is a flat list of assertions
# plus a tally.
#
# ---------------------------------------------------------------------------
# RED-BY-DESIGN ROWS — READ BEFORE "FIXING" ANYTHING
#
# This harness was written in plan 02-01, BEFORE any colour changed. Most of
# the static block therefore FAILS on the day it was committed. That is
# correct. Rows that cannot be true yet carry a `[red until plan 02-NN]` label
# and are counted separately in the EXPECTED_RED tally.
#
# DO NOT delete a row to get a clean tally. A criterion that is not yet true
# must be visibly red, not invisible. The whole point of writing the harness
# first is that a token nobody re-pointed fails loudly instead of silently
# staying purple.
#
# Green on the day this was written: the no-shadowed-gem-partial rows, the
# --deploy-proof canary row, the overrides hash row, the contrast self-test,
# the style contract and Prettier. Everything else goes green as plans 02-02,
# 02-03 and 02-04 land.
# ---------------------------------------------------------------------------
#
# ---------------------------------------------------------------------------
# WHAT THIS SCRIPT DOES NOT COVER — three genuinely manual-only criteria
#
# There is no Ruby, no `bundle`, no `_site/` and no local Jekyll build on this
# machine; the Playwright suite is unusable here and must not be run
# (02-RESEARCH.md Pitfall 9); `axe.yml` and `lighthouse-badger.yml` were
# deleted in Phase 1. So these three need a browser and a person, and live in
# plan 02-04's single batched checkpoint:human-verify:
#
#   1. Criterion 1 — the seven-page sweep. Open all seven live URLs and look
#      for a leftover white panel or a dark-grey bottom bar. Specifically the
#      projects page .card, the footer on every page, and the CV page's PDF
#      object and buttons.
#   2. Criterion 2, second clause — DevTools console
#      document.documentElement.setAttribute('data-theme','dark') must change
#      NOTHING. The presence of the merged selector is asserted statically
#      below; only its effect needs a browser.
#   3. Criterion 3 — the greyscale link check. DevTools > Rendering > Emulate
#      vision deficiencies > Achromatopsia. Body-copy links must stay
#      identifiable (underlined); navbar and footer links deliberately are not.
#
# Criterion 1's code-block clause is NOT in that list: no page on this site
# renders a code block (02-RESEARCH.md Pitfall 12), so it is verified by CSS
# inspection in the --live block, never visually. Criterion 4's contrast
# measurements are likewise automated, via .planning/tools/contrast.js.
# ---------------------------------------------------------------------------
#
# Exit: 0 only when zero checks failed.

set -uo pipefail

cd "$(git rev-parse --show-toplevel)" || exit 2

LIVE=0
[ "${1:-}" = "--live" ] && LIVE=1

CHECKS=0
FAILED=0
EXPECTED_RED=0

TOKENS="_sass/_tokens.scss"
CUSTOM="_sass/_custom.scss"
MAIN="assets/css/main.scss"
SITE="https://phamhakhanhchi.com"

# GROUND TRUTH — the 30 --global-* custom properties this site must re-point.
#
# Read off the SERVED stylesheet on 2026-09-14, not typed from a document:
#   curl -s "https://phamhakhanhchi.com/assets/css/main.css?cb=$(date +%s)" \
#     | grep -o -- '--global-[a-z0-9-]*' | sort -u
#
# The count is 30. ROADMAP.md, STACK.md and 02-CONTEXT.md all say 29 and are
# all wrong (02-RESEARCH.md Pitfall 2): the gem's dark block has 29 because it
# omits --global-highlight-color, and 29 got copied forward from there. If a
# re-run of that curl ever returns a different count, the al_folio_core pin
# has moved off 1.0.15 and 02-RESEARCH.md's token inventory needs re-reading
# before this list is edited.
GLOBAL_TOKENS=(
  --global-back-to-top-bg-color
  --global-back-to-top-text-color
  --global-bg-color
  --global-card-bg-color
  --global-code-bg-color
  --global-danger-block
  --global-danger-block-bg
  --global-danger-block-text
  --global-danger-block-title
  --global-distill-app-color
  --global-divider-color
  --global-footer-bg-color
  --global-footer-link-color
  --global-footer-text-color
  --global-highlight-color
  --global-hover-color
  --global-hover-text-color
  --global-newsletter-bg-color
  --global-newsletter-text-color
  --global-text-color
  --global-text-color-light
  --global-theme-color
  --global-tip-block
  --global-tip-block-bg
  --global-tip-block-text
  --global-tip-block-title
  --global-warning-block
  --global-warning-block-bg
  --global-warning-block-text
  --global-warning-block-title
)

# check <label> <shell-expression>
# Runs the expression, prints PASS/FAIL, increments the failure counter.
# Never aborts — the point is a full tally, not a first-failure stop. This is
# why the script uses `set -uo pipefail` and NOT `set -e`.
check() {
  local label="$1"
  shift
  CHECKS=$((CHECKS + 1))
  if eval "$@" >/dev/null 2>&1; then
    printf '  PASS  %s\n' "$label"
  else
    printf '  FAIL  %s\n' "$label"
    FAILED=$((FAILED + 1))
    case "$label" in
    *"[red until plan 0"*) EXPECTED_RED=$((EXPECTED_RED + 1)) ;;
    esac
  fi
}

# --- helpers ---------------------------------------------------------------

# Count DECLARATION lines with a given custom-property prefix in _tokens.scss.
# Anchored at ^\s*--prefix so var(--paper-100) references are not counted: the
# TOKEN-06 cap is on how many primitives EXIST, not on how often they are
# used. Prints 0 (not empty) when the file is absent, so the numeric
# comparisons fail loudly instead of comparing nothing.
decl_count() {
  if [ ! -f "$TOKENS" ]; then
    printf '0'
    return
  fi
  printf '%s' "$(grep -cE "^[[:space:]]*$1[a-z0-9-]*:" "$TOKENS" 2>/dev/null || printf '0')"
}

# Line number of the first match in a file, or 0 if absent/unmatched.
line_of_in() {
  local n
  n="$(grep -n -- "$2" "$1" 2>/dev/null | head -1 | cut -d: -f1)"
  printf '%s' "${n:-0}"
}

# TOKEN-04/05: the light block and the dark block must be ONE rule, i.e. a
# line that is exactly ":root," immediately followed by the dark attribute
# selector. html[data-theme="dark"] (0,1,1) outranks :root (0,1,0), so a
# separate dark block would win; merging the selectors is what makes forcing
# data-theme="dark" a no-op.
root_dark_pair() {
  [ -f "$TOKENS" ] || return 1
  awk '/^[[:space:]]*:root,[[:space:]]*$/ { if ((getline nxt) > 0 && nxt ~ /html\[data-theme="dark"\]/) { found = 1 } } END { exit(found ? 0 : 1) }' "$TOKENS"
}

# Criterion 5: every colour PRIMITIVE declaration carries its measured contrast
# ratio in a trailing /* */ comment. A "//" comment would work in Sass but is
# stripped before anyone reviewing the built CSS can see it; more to the point,
# a ratio that is not written next to the hex is a ratio nobody re-checks.
# Fails if any primitive line lacks an N.NN:1 figure inside a /* */.
primitives_have_ratio() {
  [ -f "$TOKENS" ] || return 1
  local lines bad
  lines="$(grep -nE '^[[:space:]]*--(paper|ink|accent|rule)-[a-z0-9-]*:' "$TOKENS" 2>/dev/null)"
  [ -n "$lines" ] || return 1
  bad="$(printf '%s\n' "$lines" | grep -vE '/\*.*:1.*\*/')"
  [ -z "$bad" ]
}

# Criterion 5: _custom.scss must carry NO colour or length literal — every
# value comes from a token. Two documented exemptions, both encoded below:
#
#   1. The --deploy-proof date string. It is a deliberately retained deploy
#      canary (Phase 1 decision: an unreferenced custom property that provably
#      repaints nothing, and which a token audit must NOT delete). Its value is
#      a quoted date, not a colour or a length.
#   2. SCSS "//" comment lines. Prose explaining a rule may legitimately quote
#      a hex or a pixel value; Sass strips those lines entirely, so they can
#      never reach the served CSS.
custom_has_no_literals() {
  [ -f "$CUSTOM" ] || return 1
  local hits
  hits="$(grep -nE '#[0-9a-fA-F]{3,8}|[0-9]*\.?[0-9]+(rem|px|em)\b|color-mix' "$CUSTOM" |
    grep -v -- '--deploy-proof' |
    grep -vE '^[0-9]+:[[:space:]]*//')"
  [ -z "$hits" ]
}

echo "=== Phase 2 — Palette and Design Tokens: static checks ======================="
echo

echo "TOKEN-01 — one token file, and no gem partial shadowed"
check "TOKEN-01  $TOKENS exists  [red until plan 02-02]" \
  'test -f "$TOKENS"'
# Written out flat rather than looped, matching Phase 1's convention: the list
# of gem partials this site must NOT shadow is itself the assertion, and it
# should be readable without running anything. _custom.scss and _tokens.scss
# are this site's own files and are deliberately not on this list.
check "TOKEN-01  gem partial _themes.scss is NOT shadowed locally" 'test ! -f _sass/_themes.scss'
check "TOKEN-01  gem partial _variables.scss is NOT shadowed locally" 'test ! -f _sass/_variables.scss'
check "TOKEN-01  gem partial _layout.scss is NOT shadowed locally" 'test ! -f _sass/_layout.scss'
check "TOKEN-01  gem partial _typography.scss is NOT shadowed locally" 'test ! -f _sass/_typography.scss'
check "TOKEN-01  gem partial _navbar.scss is NOT shadowed locally" 'test ! -f _sass/_navbar.scss'
check "TOKEN-01  gem partial _footer.scss is NOT shadowed locally" 'test ! -f _sass/_footer.scss'
check "TOKEN-01  gem partial _blog.scss is NOT shadowed locally" 'test ! -f _sass/_blog.scss'
check "TOKEN-01  gem partial _publications.scss is NOT shadowed locally" 'test ! -f _sass/_publications.scss'
check "TOKEN-01  gem partial _components.scss is NOT shadowed locally" 'test ! -f _sass/_components.scss'
check "TOKEN-01  gem partial _utilities.scss is NOT shadowed locally" 'test ! -f _sass/_utilities.scss'
check "TOKEN-01  gem partial _tabs.scss is NOT shadowed locally" 'test ! -f _sass/_tabs.scss'
check "TOKEN-01  gem partial _teachings.scss is NOT shadowed locally" 'test ! -f _sass/_teachings.scss'
check "TOKEN-01  gem partial _typograms.scss is NOT shadowed locally" 'test ! -f _sass/_typograms.scss'
echo

echo "TOKEN-01 — all 30 --global-* tokens re-pointed  [all red until plan 02-02]"
# One row per name, deliberately. A single "all 30 present" row would tell you
# that something is missing; these tell you WHICH, which is the difference
# between a five-minute fix and a hunt for the one link that stayed purple.
for t in "${GLOBAL_TOKENS[@]}"; do
  check "TOKEN-01  ${t} is declared in _tokens.scss  [red until plan 02-02]" \
    "grep -qE '^[[:space:]]*${t}:' \"\$TOKENS\""
done
echo

echo "TOKEN-01 — the token file is wired in ahead of the overrides"
check "TOKEN-01  main.scss has @use tokens before @use custom  [red until plan 02-02]" \
  '[ "$(line_of_in "$MAIN" "@use \"tokens\";")" -gt 0 ] && [ "$(line_of_in "$MAIN" "@use \"tokens\";")" -lt "$(line_of_in "$MAIN" "@use \"custom\";")" ]'
# NOT labelled red-by-design: this row is GREEN today and must be RE-greened by
# plan 02-02, which edits main.scss and then re-hashes BY HAND (there is no
# Ruby here, so `al-folio upgrade overrides accept` cannot run). If 02-02
# forgets to recompute the hash this must fail LOUDLY as a real regression,
# not be absorbed into the EXPECTED_RED tally.
check "TOKEN-01  .al-folio-overrides.yml local_sha256 matches main.scss  [re-hash by hand in plan 02-02]" \
  'grep -q "$(sha256sum "$MAIN" | cut -d" " -f1)" .al-folio-overrides.yml'
echo

echo "TOKEN-02 — a capped scale, consumed by the overrides"
check "TOKEN-02  exactly 4 --step- declarations (have: $(decl_count '--step-'))  [red until plan 02-02]" \
  '[ "$(decl_count "--step-")" -eq 4 ]'
check "TOKEN-02  exactly 4 --space- declarations (have: $(decl_count '--space-'))  [red until plan 02-02]" \
  '[ "$(decl_count "--space-")" -eq 4 ]'
check "TOKEN-02  _custom.scss consumes var(--space-  [red until plan 02-03]" \
  'grep -q -- "var(--space-" "$CUSTOM"'
check "TOKEN-02  _custom.scss consumes var(--step-  [red until plan 02-03]" \
  'grep -q -- "var(--step-" "$CUSTOM"'
echo

echo "TOKEN-03 — contrast is measured, and nothing fakes it with opacity"
# Criterion 4's own command, verbatim. opacity on text is the classic way to
# ship an unmeasurable contrast ratio: the computed colour is no longer the
# declared one, so no token comment can be true about it.
check "TOKEN-03  grep -rn opacity _sass/ returns zero hits  [red until plan 02-03]" \
  '! grep -rn "opacity" _sass/'
check "TOKEN-03  muted ink #5c5349 on paper #faf6ee clears 4.5:1" \
  'node .planning/tools/contrast.js "#5c5349" "#faf6ee" | grep -q "AA-text"'
echo

echo "TOKEN-04 / TOKEN-05 — dark mode off, and defused in CSS as well as config"
check "TOKEN-04  _config.yml sets enable_darkmode: false  [red until plan 02-04]" \
  "grep -qE '^enable_darkmode:[[:space:]]*false' _config.yml"
check "TOKEN-04/05  _tokens.scss merges :root, with html[data-theme=dark]  [red until plan 02-02]" \
  'root_dark_pair'
check "TOKEN-05  that block declares color-scheme: light  [red until plan 02-02]" \
  'grep -qE "^[[:space:]]*color-scheme:[[:space:]]*light" "$TOKENS"'
echo

echo "TOKEN-06 — the vocabulary is capped, and the cap is written down"
# The cap is the whole anti-overshoot mechanism (PITFALLS 3: register overshoot
# is partly unrecoverable). A cap nobody wrote down is a cap the next agent
# raises by one token at a time.
check "TOKEN-06  cap comment names 'paper tones'  [red until plan 02-02]" \
  'grep -qi "paper tones" "$TOKENS"'
check "TOKEN-06  cap comment names 'ink steps'  [red until plan 02-02]" \
  'grep -qi "ink steps" "$TOKENS"'
check "TOKEN-06  cap comment names 'accent colours'  [red until plan 02-02]" \
  'grep -qi "accent colours" "$TOKENS"'
check "TOKEN-06  cap comment names 'type families'  [red until plan 02-02]" \
  'grep -qi "type families" "$TOKENS"'
check "TOKEN-06  exactly 2 --paper- declarations (have: $(decl_count '--paper-'))  [red until plan 02-02]" \
  '[ "$(decl_count "--paper-")" -eq 2 ]'
check "TOKEN-06  exactly 4 --ink- declarations (have: $(decl_count '--ink-'))  [red until plan 02-02]" \
  '[ "$(decl_count "--ink-")" -eq 4 ]'
check "TOKEN-06  exactly 1 --accent- declaration (have: $(decl_count '--accent-'))  [red until plan 02-02]" \
  '[ "$(decl_count "--accent-")" -eq 1 ]'
check "TOKEN-06  exactly 2 --rule- declarations (have: $(decl_count '--rule-'))  [red until plan 02-02]" \
  '[ "$(decl_count "--rule-")" -eq 2 ]'
echo

echo "Criterion 5 — every primitive carries its ratio; the overrides carry no literals"
check "Crit-5   every --paper-/--ink-/--accent-/--rule- line has an N.NN:1 comment  [red until plan 02-02]" \
  'primitives_have_ratio'
check "Crit-5   _custom.scss has no hex / rem / px / em / color-mix literal  [red until plan 02-03]" \
  'custom_has_no_literals'
echo

echo "GROUND-04 and the six gem overrides"
check "GROUND-04  _custom.scss styles body-copy links (.post article a)  [red until plan 02-03]" \
  'grep -q "\.post article a" "$CUSTOM"'
check "GROUND-04  that rule declares text-decoration: underline  [red until plan 02-03]" \
  'grep -qE "text-decoration:[[:space:]]*underline" "$CUSTOM"'
check "Override  pre/code ink re-pointed  [red until plan 02-03]" \
  'grep -qE "^[[:space:]]*(pre|code)[,[:space:]{]" "$CUSTOM"'
check "Override  .card box-shadow: none (flush panels, no floating white)  [red until plan 02-03]" \
  'grep -A6 "\.card" "$CUSTOM" | grep -qE "box-shadow:[[:space:]]*none"'
check "Override  .navbar opacity: 1 (gem ships opacity .95 — 02-RESEARCH Pitfall 8)  [red until plan 02-03]" \
  'grep -A6 "\.navbar" "$CUSTOM" | grep -qE "opacity:[[:space:]]*1"'
check "Override  headings h1..h6 re-pointed to heading ink  [red until plan 02-03]" \
  'grep -qE "h1[,[:space:]]" "$CUSTOM" && grep -qE "h6[,[:space:]{]" "$CUSTOM"'
check "Override  :focus-visible carries a visible outline  [red until plan 02-03]" \
  'grep -A6 ":focus-visible" "$CUSTOM" | grep -qE "outline:"'
# Green today and must STAY green: this is the one row in this group that is a
# negative assertion, so it is not red-by-design. Killing the focus ring while
# restyling :focus-visible is the classic way to lose keyboard accessibility.
check "Override  no outline: none anywhere in _sass/  [must stay true through plan 02-03]" \
  '! grep -rqE "outline:[[:space:]]*none" _sass/'
echo

echo "Supporting config flags and the retained deploy canary"
check "Support   _config.yml sets enable_progressbar: false  [red until plan 02-04]" \
  "grep -qE '^enable_progressbar:[[:space:]]*false' _config.yml"
check "Support   _config.yml sets footer_fixed: false  [red until plan 02-04]" \
  "grep -qE '^footer_fixed:[[:space:]]*false' _config.yml"
# Phase 1 decision, restated here because a token audit is exactly the thing
# that would delete it: --deploy-proof is an UNREFERENCED custom property kept
# on purpose. It is how "did my change ship?" gets answered against the CDN.
# It must NOT be folded in with the design tokens.
check "Canary    --deploy-proof is still declared in _custom.scss (do not delete)" \
  'grep -q -- "--deploy-proof" "$CUSTOM"'
echo

echo "Regression — this phase must not turn a surviving gate red on its way in"
check "Regress   node test/style_contract.js exits 0" \
  'node test/style_contract.js'
# --end-of-line auto is mandatory locally. core.autocrlf=true makes a bare
# --check report line-ending-only false failures; CI runs on Linux/LF and sees
# only real ones. Never run `npx prettier . --write` on this checkout.
check "Regress   npx prettier _sass _config.yml CLAUDE.md --check --end-of-line auto" \
  'npx prettier _sass _config.yml CLAUDE.md --check --end-of-line auto'
check "Tool      node .planning/tools/contrast.js --selftest exits 0" \
  'node .planning/tools/contrast.js --selftest'
echo

if [ "$LIVE" -eq 1 ]; then
  echo "=== Live checks (--live) ====================================================="
  echo
  # Everything here is red until plan 02-04 performs this phase's SINGLE push.
  # enable_darkmode:false and the token re-point must reach the live site in
  # one deploy, so there is deliberately nothing to see before then.
  #
  # The cache-buster is mandatory, not decorative: main.css is served with
  # Cache-Control max-age=600 behind a CDN, so a plain fetch can show the
  # PREVIOUS build for ~10 minutes after a successful deploy. Deploy latency
  # from push is ~2-3 minutes (Phase 1, measured) — poll, do not refresh once.
  LIVE_CSS="$(mktemp)"
  curl -s --max-time 30 "${SITE}/assets/css/main.css?cb=$(date +%s)" >"$LIVE_CSS" 2>/dev/null
  LIVE_HTML="$(mktemp)"
  curl -s -L --max-time 30 "${SITE}/?cb=$(date +%s)" >"$LIVE_HTML" 2>/dev/null

  for page in "" academics research further-reading projects activities cv; do
    check "Live      ${SITE}/${page} returns 200  [red until plan 02-04]" \
      "[ \"\$(curl -s -o /dev/null -w '%{http_code}' -L --max-time 20 '${SITE}/${page}')\" = '200' ]"
  done
  echo

  # The served stylesheet is minified, so every grep below tolerates optional
  # whitespace after the colon rather than assuming the authored spacing.
  check "Live      served main.css declares --paper-100  [red until plan 02-04]" \
    'grep -q -- "--paper-100" "$LIVE_CSS"'
  check "Live      served main.css: --global-bg-color -> var(--paper-100)  [red until plan 02-04]" \
    'grep -qE -- "--global-bg-color:[[:space:]]*var\(--paper-100\)" "$LIVE_CSS"'
  # This IS criterion 1's code-block clause. No page on this site renders a
  # code block (02-RESEARCH.md Pitfall 12), so it is verified by inspecting the
  # served CSS and never visually. Do not add a throwaway page to make it
  # visual.
  check "Live      served main.css: --global-code-bg-color -> var(--paper-200)  [red until plan 02-04]" \
    'grep -qE -- "--global-code-bg-color:[[:space:]]*var\(--paper-200\)" "$LIVE_CSS"'
  # Compares the served canary against the LOCAL one rather than a hardcoded
  # date, so this row keeps working after plan 02-03 re-dates it and after any
  # later re-date. A mismatch means the push did not ship — or has not landed
  # yet; see the ~2-3 min latency note above.
  check "Live      served main.css carries the CURRENT --deploy-proof value  [red until plan 02-04]" \
    'grep -q -- "$(grep -o -- "--deploy-proof:[^;]*" "$CUSTOM" | sed "s/.*\"\(.*\)\".*/\1/")" "$LIVE_CSS"'
  # PurgeCSS strips rules whose selectors appear in no HTML. footer_fixed:false
  # puts sticky-bottom into the markup, which restores those rules — so this
  # row is a live proof that the config flag actually took effect, not merely
  # that it was written.
  check "Live      served main.css contains sticky-bottom (PurgeCSS restored it)  [red until plan 02-04]" \
    'grep -q -- "sticky-bottom" "$LIVE_CSS"'
  echo

  check "Live      home HTML has zero light-toggle occurrences  [red until plan 02-04]" \
    '! grep -q -- "light-toggle" "$LIVE_HTML"'
  check "Live      home HTML has zero fixed-bottom occurrences  [red until plan 02-04]" \
    '! grep -q -- "fixed-bottom" "$LIVE_HTML"'
  check "Live      home HTML has zero progress-bar occurrences  [red until plan 02-04]" \
    '! grep -q -- "progress-bar" "$LIVE_HTML"'

  # Informational, always PASS. Record before a push, compare after.
  GHP_SHA="$(git ls-remote origin refs/heads/gh-pages 2>/dev/null | cut -f1)"
  check "INFO      origin/gh-pages is at ${GHP_SHA:-<unreadable>}" 'true'

  rm -f "$LIVE_CSS" "$LIVE_HTML"
  echo
fi

echo "============================================================================="
echo "${CHECKS} checks, ${FAILED} failed"
if [ "$EXPECTED_RED" -gt 0 ]; then
  echo "(${EXPECTED_RED} of those are red-by-design — see the [red until plan 02-NN] labels)"
fi
UNLABELLED=$((FAILED - EXPECTED_RED))
if [ "$UNLABELLED" -gt 0 ]; then
  echo "(${UNLABELLED} UNLABELLED failure(s) — real regressions, not pending work)"
fi

[ "$FAILED" -eq 0 ]

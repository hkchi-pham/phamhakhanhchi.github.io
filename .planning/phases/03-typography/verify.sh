#!/usr/bin/env bash
#
# Phase 3 (Typography) — repeatable verification harness.
#
# Composes every AUTOMATABLE row of 03-VALIDATION.md's "Per-Task Verification
# Map" into one command, so each phase criterion can be re-checked on demand
# instead of being a one-off command someone has to remember.
#
#   bash .planning/phases/03-typography/verify.sh          # static only
#   bash .planning/phases/03-typography/verify.sh --live   # + network block
#
# Same shape as .planning/phases/02-palette-and-design-tokens/verify.sh, on
# purpose — the check() function, the tally, the --live flag and the
# red-by-design labelling are copied, not reinvented. It is deliberately NOT a
# test framework and deliberately NOT wired to an npm script: 01-VALIDATION.md
# forbids a starter-local build/test pipeline, 02-VALIDATION.md carries that
# forward, and AGENTS.md's style contract rejects build:css / build:tailwind
# npm scripts outright. It is a flat list of assertions plus a tally.
#
# ---------------------------------------------------------------------------
# (a) THE BUDGET IS 153,600 BYTES = 150 KiB, AND IT IS STATED IN BYTES
#
# "150 KB" is ambiguous and the margin is only ~9%. The measured payload is
# 141,232 B, which Chrome DevTools reports as 141.2 kB (decimal) and `ls`/`du`
# report as 137.9 KiB (binary). That is 3.3 of the 12-unit margin sitting
# inside the unit ambiguity alone — enough for two readings of the same file
# to disagree about whether the budget was met. So the number below is a byte
# count, and every write-up of it must say bytes.
#
# (b) FONTS_UA IS MANDATORY ON EVERY FONTS FETCH
#
# Google Fonts content-negotiates on User-Agent. Without a modern browser UA,
# BOTH the v1 (css?family=) and v2 (css2?family=) endpoints return unsubsetted
# TrueType with no unicode-range and no subset comments at all (03-RESEARCH
# Finding 1 — this corrects 03-CONTEXT research flag 1, which blamed the API
# version). Failure signature: the response body contains format('truetype').
# A fonts row that omits -A "$FONTS_UA" does not fail loudly; it reports zero
# vietnamese blocks, which reads identically to "the family has no Vietnamese
# subset" — the exact false negative this phase exists to rule out.
#
# (c) WHAT THIS SCRIPT DOES NOT COVER — the genuinely manual criteria
#
# There is no Ruby, no `bundle`, no `_site/` and no local Jekyll build on this
# machine; PurgeCSS runs only in CI; the Playwright suite is unusable here and
# must NOT be run (deleted workflow, no baseline). So these live in plan
# 03-04's single batched checkpoint:human-verify and are deliberately absent
# from this file:
#
#   1. Criterion 1 / TYPE-03 — the name in one typeface. Zoom the deployed
#      h1.post-title (it renders at ~44px, BELOW the criterion's "48px or
#      larger"; that clause describes how to INSPECT, not how big the h1 must
#      be) and compare `ạ` against `à`. They come from two different subset
#      FILES of the same family, so this is an eye check that both loaded.
#   2. Criterion 4 / TYPE-04 — characters per line. A Range.getClientRects()
#      count in the DevTools console on the deployed page. The 36rem measure
#      is asserted statically and in the served CSS below; only the resulting
#      CPL needs a browser.
#   3. --underline-offset against Literata's descenders. 0.18em was tuned and
#      human-approved in Phase 2 against ROBOTO. Literata's descenders are
#      ~26% deeper relative to em, so a collision with `ạ`/`ợ` is more likely
#      than not — but whether it collides is a browser observation, not a
#      computation. Do not re-tune it blind.
#   4. The fallback-swap glance — Georgia standing in during the swap window.
#
# ---------------------------------------------------------------------------
# RED-BY-DESIGN ROWS — READ BEFORE "FIXING" ANYTHING
#
# This harness was written in plan 03-01, BEFORE any type changed. Most rows
# therefore FAIL on the day they were committed. That is correct. A row that
# cannot be true yet carries a `[red until plan 03-NN]` label naming the plan
# that makes it true, and is counted separately in the EXPECTED_RED tally.
#
# DO NOT delete a row to get a clean tally. A criterion that is not yet true
# must be visibly red, not invisible.
#
# And — Phase 2's decision, carried forward and worth restating — a row that
# is GREEN today and must merely STAY green gets NO label. A label on a green
# row absorbs a genuine future regression into the expected-red count and
# hides it. The red label means "not true yet", never "do not worry about
# this". The unlabelled-green rows here are: max_width 930px, fontawesome
# still declared, the Phase 2 purge safelist entries, no !important, no
# literals in _custom.scss, the two self-tests, Prettier, the style contract
# and the seven live 200s.
#
# ---------------------------------------------------------------------------
# WHICH PLAN A LIVE ROW IS LABELLED AGAINST — a deliberate refinement
#
# 03-01-PLAN.md grouped every --live row under `[red until plan 03-04]`, the
# phase's single push. That is right for rows that read the DEPLOYED site, and
# wrong for the rows that fetch Google Fonts: those read FONTS_URL out of the
# LOCAL _config.yml and never touch phamhakhanhchi.com, so the plan that makes
# them true is 03-02, which rewrites that string — no deploy required. They
# are labelled 03-02 here for two reasons: plan 03-02 then has live feedback
# available at its own wave instead of none, and a fonts row still red after
# 03-02 lands is a real signal rather than an expected one. No row was dropped
# or weakened; only the label was made precise. Same principle as Phase 2's
# "narrow the matcher, never delete the row".
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
PURGE="purgecss.config.js"
CONFIG="_config.yml"
SITE="https://phamhakhanhchi.com"

# Chrome 120 on Windows. See note (b) above — mandatory on every fonts fetch.
FONTS_UA='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'

# Read out of _config.yml rather than hardcoded, so this harness follows the
# string plan 03-02 writes instead of needing an edit alongside it. EMPTY until
# 03-02 lands (today's value is a v1 css?family= URL), which is why every row
# consuming it is labelled red until then.
FONTS_URL="$(grep -o 'https://fonts.googleapis.com/css2[^"]*' "$CONFIG" | head -1)"

# 150 KiB, in BYTES on purpose. See note (a).
FONT_BUDGET_BYTES=153600

# The Font Awesome stylesheet, recorded but NOT budgeted. 03-CONTEXT: icon
# fonts are inherited payload this phase is not designing — "record the figure
# anyway so it is visible".
ICONS_CSS_URL="$(grep -o 'https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@[^"]*all.min.css' "$CONFIG" | head -1)"
ICONS_CSS_URL="${ICONS_CSS_URL/\{\{version\}\}/7.2.0}"

# Expected count of /* vietnamese */ blocks in the fonts response: one per
# locked cut. SETTLED AT FIVE — plan 03-01's checkpoint was answered
# `status-serif` on 2026-09-16. `.entry-status` stays Literata 400 italic, so
# the fonts URL KEEPS the italic axis (`Literata:ital,wght@0,400;0,600;1,400`)
# and the five locked cuts are BVP 400, BVP 600, Literata 400, Literata 600 and
# Literata 400 italic. The italic cut's 26,344 B are bought knowingly: the
# phase ships at 141,232 B of the 153,600 B budget — 91.9% used, 12,368 B of
# headroom — and Phase 4 marginalia is pre-paid rather than re-paid.
#
# The rejected alternative (`status-sans`) would have dropped `ital,` and
# `;1,400` from the URL and made this FOUR. It was NOT chosen. The number below
# needs no further edit; plans 03-02 and 03-03 build against five. Do not
# delete this row, and do not renumber it to make a tally look tidier.
VIET_BLOCKS_EXPECTED=5

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

# Criterion 3's proxy: _custom.scss may declare a font-family, but only as a
# var() into one of the two family tokens. A literal family name anywhere here
# is a third type family entering through the back door, which is the register
# overshoot TOKEN-06's cap exists to prevent. Green today (the file declares
# none at all) and must STAY green — so it carries no red label.
custom_families_are_tokens_only() {
  [ -f "$CUSTOM" ] || return 1
  local hits
  hits="$(grep -nE '^[[:space:]]*font-family:' "$CUSTOM" | grep -vE 'var\(--font-(serif|sans)\)')"
  [ -z "$hits" ]
}

# Phase 2's matcher, carried forward VERBATIM (02-VALIDATION criterion 5).
# Two documented exemptions: the --deploy-proof date string (a deliberately
# retained deploy canary that a token audit must not delete) and SCSS "//"
# comment lines, which Sass strips entirely so they can never reach the served
# CSS. Phase 3 adds font-weight values (unitless) and var() references, none of
# which are literals, so this row must stay green through 03-03.
custom_has_no_literals() {
  [ -f "$CUSTOM" ] || return 1
  local hits
  hits="$(grep -nE '#[0-9a-fA-F]{3,8}|[0-9]*\.?[0-9]+(rem|px|em)\b|color-mix' "$CUSTOM" |
    grep -v -- '--deploy-proof' |
    grep -vE '^[0-9]+:[[:space:]]*//')"
  [ -z "$hits" ]
}

# Criterion 5 / Phase 2 discipline: no rule in _sass/ may carry !important.
#
# NARROWED ON 2026-09-16, ON THE DAY THIS ROW WAS WRITTEN, and recorded here
# rather than quietly fixed. As first written this row was the bare command
# `! grep -rqE '!important' _sass/`, and it failed immediately — against
# _custom.scss lines 112 and 116, which are `//` COMMENTS explaining why none
# of Phase 2's six gem overrides needs one ("Why none of these needs …", "…
# whose @layer components …"). The prose is correct and load-bearing; the row
# was wrong.
#
# This is the third instance of a pattern Phase 2 documented twice (02-02's
# comment-quoting rule, 02-03's value-aware opacity narrowing): when the
# harness and a correct implementation disagree, NARROW THE MATCHER and say
# why in-file — never delete the row, and never edit _sass/ to satisfy a
# matcher. The exemption is exactly the one custom_has_no_literals already
# uses: Sass strips `//` lines entirely, so they can never reach the served
# CSS and cannot make a declaration important. A real `!important` on a
# declaration line still fails, which is what the criterion actually means.
no_important() {
  local hits
  hits="$(grep -rnE '!important' _sass/ | grep -vE '^[^:]+:[0-9]+:[[:space:]]*//')"
  [ -z "$hits" ]
}

# grep -c prints 0 AND exits 1 when there is no match, so a `|| echo 0`
# fallback appends a SECOND zero and the label reads "have: 0\n0". Swallow the
# exit status instead of substituting a value.
family_token_count() {
  grep -cE '^[[:space:]]*--font-(serif|sans):' "$TOKENS" 2>/dev/null || true
}

echo "=== Phase 3 — Typography: static checks ====================================="
echo

echo "TYPE-01 / TYPE-05 — the fonts request names two families and nothing dead"
# -F, not -E: '+' is an ERE metacharacter and 'Be+Vietnam+Pro' is a literal
# plus-encoded family name, not "one or more e".
check "TYPE-01  $CONFIG requests Be Vietnam Pro from the css2 endpoint  [red until plan 03-02]" \
  "grep -qF 'css2?family=Be+Vietnam+Pro' \"\$CONFIG\""
check "TYPE-01  $CONFIG requests Literata in the same css2 URL  [red until plan 03-02]" \
  "grep -qF 'family=Literata:' \"\$CONFIG\""
check "TYPE-05  $CONFIG keeps display=swap  [red until plan 03-02]" \
  "grep -qF 'display=swap' \"\$CONFIG\" && [ -n \"\$FONTS_URL\" ]"
check "TYPE-05  $CONFIG no longer names Material+Icons  [red until plan 03-02]" \
  "! grep -qF 'Material+Icons' \"\$CONFIG\""
check "TYPE-05  $CONFIG no longer declares academicons: or scholar-icons:  [red until plan 03-02]" \
  "! grep -qE '^  (academicons|scholar-icons):' \"\$CONFIG\""
# Green today and must STAY green: the one envelope in _data/socials.yml is a
# Font Awesome solid glyph. Replacing it with inline SVG is Phase 6 territory
# and was deliberately deferred, so deleting this block here would be a
# regression, not a cleanup.
check "TYPE-05  $CONFIG still declares fontawesome: (the envelope stays)" \
  "grep -qE '^  fontawesome:' \"\$CONFIG\""
# Green today and must STAY green. 03-CONTEXT locks the PAGE width and
# measures the prose instead; the ~354px left over is the gutter Phase 4's
# marginalia and Phase 5's PAGE-06 will use. This row exists to catch a
# well-meaning later narrowing — which would look like an improvement and
# would silently delete a future phase's canvas.
check "TYPE-04  $CONFIG max_width is UNCHANGED at 930px (the gutter is deliberate)" \
  "grep -qE '^max_width:[[:space:]]*930px' \"\$CONFIG\""
echo

echo "TYPE-02 / TOKEN-06 — exactly two type families, and the cap says so"
check "TYPE-02  $TOKENS declares exactly 2 family tokens (have: $(family_token_count))  [red until plan 03-02]" \
  '[ "$(family_token_count)" = "2" ]'
check "TYPE-02  $TOKENS declares --font-serif  [red until plan 03-02]" \
  'grep -qE "^[[:space:]]*--font-serif:" "$TOKENS"'
check "TYPE-02  $TOKENS declares --font-sans  [red until plan 03-02]" \
  'grep -qE "^[[:space:]]*--font-sans:" "$TOKENS"'
# Already reads 2 today — the digit was written in Phase 2. Unlabelled, so a
# later edit to 3 fails loudly as a real regression rather than hiding inside
# the expected-red tally.
check "TOKEN-06 the cap line for type families reads 2" \
  'grep -qE "type families[ .]+2" "$TOKENS"'
# ...but the parenthetical still defers the value to this phase. 03-02 replaces
# it with the two family names, which is what makes the cap a record rather
# than a promise.
check "TOKEN-06 the cap's type families line no longer defers its value to Phase 3  [red until plan 03-02]" \
  '! grep -q "value set in Phase 3" "$TOKENS"'
echo

echo "TYPE-04 — the scale, as calc() so the ratios are greppable not inferred"
# The calc() form is not a style preference. Criterion 4 says "H2 is at least
# 1.5x body size and H3 at least 1.25x"; with literal rems that ratio is only
# recoverable by dividing two numbers a reader has to trust. As calc() it is a
# grep, here and against the SERVED stylesheet below. Every matcher is
# whitespace-tolerant because main.css compiles compressed and the authored
# spacing is not what ships.
check "TYPE-04  --step-1 is the 17px base 1.0625rem  [red until plan 03-02]" \
  'grep -qE -- "--step-1:[[:space:]]*1\.0625rem" "$TOKENS"'
check "TYPE-04  --step-0 is calc(var(--step-1) * 0.85)  [red until plan 03-02]" \
  'grep -qE -- "--step-0:[[:space:]]*calc\(var\(--step-1\)[[:space:]]*\*[[:space:]]*0\.85\)" "$TOKENS"'
check "TYPE-04  --step-2 is calc(var(--step-1) * 1.15)  [red until plan 03-02]" \
  'grep -qE -- "--step-2:[[:space:]]*calc\(var\(--step-1\)[[:space:]]*\*[[:space:]]*1\.15\)" "$TOKENS"'
check "TYPE-04  --step-3 is calc(var(--step-1) * 1.35) — floor is 1.25  [red until plan 03-02]" \
  'grep -qE -- "--step-3:[[:space:]]*calc\(var\(--step-1\)[[:space:]]*\*[[:space:]]*1\.35\)" "$TOKENS"'
check "TYPE-04  --step-4 is calc(var(--step-1) * 1.8) — floor is 1.5  [red until plan 03-02]" \
  'grep -qE -- "--step-4:[[:space:]]*calc\(var\(--step-1\)[[:space:]]*\*[[:space:]]*1\.8\)" "$TOKENS"'
check "TYPE-04  --step-5 is calc(var(--step-1) * 2.6)  [red until plan 03-02]" \
  'grep -qE -- "--step-5:[[:space:]]*calc\(var\(--step-1\)[[:space:]]*\*[[:space:]]*2\.6\)" "$TOKENS"'
echo

# Decision B of plan 03-01's checkpoint, settled 2026-09-16 as `title-full`:
# `h1.post-title` does NOT join the measure. It lives in <header
# class="post-header">, a SIBLING of <article>, and the measure selector list
# stays inside `.post article` exactly as 03-CONTEXT scopes it. No
# `header.post-header` selector joins that list in plan 03-03 — the title keeps
# the full 930px and reads as a masthead above the column. There is therefore
# deliberately NO row below grepping for a title-in-measure selector; its
# absence is the assertion. Phase 6 owns hero composition and may revisit.
echo "TYPE-04 — the measure and the two leadings"
check "TYPE-04  --measure: 36rem is declared (576px, ~70.6 CPL at 17px Literata)  [red until plan 03-02]" \
  'grep -qE -- "--measure:[[:space:]]*36rem" "$TOKENS"'
check "TYPE-04  --leading-body is 1.6 (was the gem's 1.5, tuned for Roboto)  [red until plan 03-02]" \
  'grep -qE -- "--leading-body:[[:space:]]*1\.6" "$TOKENS"'
check "TYPE-04  --leading-heading: 1.2 is declared  [red until plan 03-02]" \
  'grep -qE -- "--leading-heading:[[:space:]]*1\.2" "$TOKENS"'
echo

echo "TYPE-02 / TYPE-03 — the overrides consume the tokens and nothing else"
check "TYPE-02  $CUSTOM sets a serif body from var(--font-serif)  [red until plan 03-03]" \
  'grep -qE -- "font-family:[[:space:]]*var\(--font-serif\)" "$CUSTOM"'
check "TYPE-02  $CUSTOM points labels at var(--font-sans)  [red until plan 03-03]" \
  'grep -qE -- "font-family:[[:space:]]*var\(--font-sans\)" "$CUSTOM"'
check "TYPE-04  $CUSTOM gives the prose max-width: var(--measure)  [red until plan 03-03]" \
  'grep -qE -- "max-width:[[:space:]]*var\(--measure\)" "$CUSTOM"'
check "TYPE-03  $CUSTOM neutralises .navbar-brand .font-weight-bold  [red until plan 03-03]" \
  'grep -q -- ".navbar-brand .font-weight-bold" "$CUSTOM"'
check "TYPE-04  $CUSTOM sets h1/h2 to font-weight 600 (tailwind base ships 300)  [red until plan 03-03]" \
  'grep -qE -- "font-weight:[[:space:]]*600" "$CUSTOM"'
# Green today (the file declares no font-family at all) and must STAY green.
check "Crit-3   $CUSTOM declares no font-family outside the two family tokens" \
  'custom_families_are_tokens_only'
# Green today and must STAY green — Phase 2's matcher, unchanged.
check "Crit-5   $CUSTOM has no hex / rem / px / em / color-mix literal" \
  'custom_has_no_literals'
# Green today and must STAY green. Unlayered main.css already beats the gem's
# fully-@layer'd tailwind.css outright, so an !important here would be someone
# not understanding why their rule already wins.
check "Crit-5   no !important on any declaration in _sass/ (// comments exempt)" \
  'no_important'
echo

echo "PurgeCSS — the three tags the measure names that no built page contains"
# 03-RESEARCH Finding 7, from a tag census of all seven deployed pages: ol,
# blockquote, pre, code, table, h4, h5 and h6 appear NOWHERE on this site.
# PurgeCSS prunes unused nodes out of a selector LIST and reports nothing, so
# the measure rule would ship with three of its fourteen selectors silently
# removed. Live proof the mechanism is biting right now: _custom.scss declares
# .topic-list and `grep -c topic-list` against the SERVED main.css returns 0.
check "Purge    $PURGE safelists \"ol\"  [red until plan 03-03]" \
  "grep -qF -- '\"ol\"' \"\$PURGE\""
check "Purge    $PURGE safelists \"blockquote\"  [red until plan 03-03]" \
  "grep -qF -- '\"blockquote\"' \"\$PURGE\""
check "Purge    $PURGE safelists \"h4\"  [red until plan 03-03]" \
  "grep -qF -- '\"h4\"' \"\$PURGE\""
# Green today and must STAY green — these are Phase 2's, and 02-05 exists
# because the first of them was missing. The leading colon is load-bearing:
# the safelist is matched against SELECTOR NODES, so "focus-visible" without
# it does not match and is not a substitute (measured against purgecss 8.0.0).
# A regression here re-strips the keyboard focus ring from production.
check "Purge    $PURGE still safelists \":focus-visible\" WITH its leading colon" \
  "grep -qF -- '\":focus-visible\"' \"\$PURGE\""
check "Purge    $PURGE still safelists \"h5\" and \"h6\" (heading ink keeps all six levels)" \
  "grep -qF -- '\"h5\"' \"\$PURGE\" && grep -qF -- '\"h6\"' \"\$PURGE\""
echo

echo "Regression — this phase must not turn a surviving gate red on its way in"
# --end-of-line auto is mandatory locally. core.autocrlf=true makes a bare
# --check report line-ending-only false failures; CI runs on Linux/LF and sees
# only real ones. Never run `npx prettier . --write` on this checkout.
check "Regress  npx prettier _sass $CONFIG $PURGE --check --end-of-line auto" \
  "npx prettier _sass \"\$CONFIG\" \"\$PURGE\" --check --end-of-line auto"
check "Regress  node test/style_contract.js exits 0" \
  'node test/style_contract.js'
check "Tool     node .planning/tools/fontbudget.js --selftest exits 0" \
  'node .planning/tools/fontbudget.js --selftest'
# Phase 2's tool, untouched by this phase. Green, no label — a red row here
# means someone edited contrast.js, not that Phase 3 is incomplete.
check "Tool     node .planning/tools/contrast.js --selftest exits 0" \
  'node .planning/tools/contrast.js --selftest'
echo

if [ "$LIVE" -eq 1 ]; then
  echo "=== Live checks (--live) ====================================================="
  echo
  # The cache-buster is mandatory, not decorative: main.css is served with
  # Cache-Control max-age=600 behind a CDN, so a plain fetch can show the
  # PREVIOUS build for ~10 minutes after a successful deploy. Deploy latency
  # from push is ~112-168s across three measurements — poll, do not refresh
  # once, and do not conclude from one stale fetch that the push failed.
  LIVE_CSS="$(mktemp)"
  curl -s --max-time 30 "${SITE}/assets/css/main.css?cb=$(date +%s)" >"$LIVE_CSS" 2>/dev/null
  LIVE_HTML="$(mktemp)"
  curl -s -L --max-time 30 "${SITE}/?cb=$(date +%s)" >"$LIVE_HTML" 2>/dev/null
  FONTS_CSS="$(mktemp)"
  [ -n "$FONTS_URL" ] && curl -sS -A "$FONTS_UA" --max-time 30 "$FONTS_URL" >"$FONTS_CSS" 2>/dev/null

  # Green today and must STAY green: the site is already live. A red row here
  # is a deploy that broke a page, not pending work.
  for page in "" academics research further-reading projects activities cv; do
    check "Live     ${SITE}/${page} returns 200" \
      "[ \"\$(curl -s -o /dev/null -w '%{http_code}' -L --max-time 20 '${SITE}/${page}')\" = '200' ]"
  done
  echo

  echo "TYPE-01 — the Vietnamese subsets, fetched with a browser UA"
  # These read FONTS_URL out of the LOCAL _config.yml and never touch the
  # deployed site, so they go green when plan 03-02 rewrites that string — no
  # push required. See the labelling note in the header.
  check "TYPE-01  fonts CSS carries ${VIET_BLOCKS_EXPECTED} /* vietnamese */ blocks, one per locked cut  [red until plan 03-02]" \
    '[ "$(grep -c "/\* vietnamese \*/" "$FONTS_CSS")" = "$VIET_BLOCKS_EXPECTED" ]'
  check "TYPE-01  the vietnamese range covers U+1EA0-1EF9 (carries ạ, U+1EA1)  [red until plan 03-02]" \
    'grep -q "U+1EA0-1EF9" "$FONTS_CSS"'
  # The UA failure signature. If this row is red while the two above are also
  # red, suspect the UA before suspecting the families.
  check "TYPE-01  fonts CSS serves woff2, not the UA-less truetype fallback  [red until plan 03-02]" \
    'grep -q "format(.woff2.)" "$FONTS_CSS" && ! grep -q "format(.truetype.)" "$FONTS_CSS"'
  check "TYPE-05  webfont payload is within ${FONT_BUDGET_BYTES} B over latin+vietnamese  [red until plan 03-02]" \
    'FONTS_URL="$FONTS_URL" node .planning/tools/fontbudget.js --max "$FONT_BUDGET_BYTES"'
  echo

  echo "TYPE-02 / TYPE-04 — the tokens in the stylesheet the CDN actually serves"
  # Phase 2's most expensive lesson, restated: a source grep is NOT evidence
  # that a rule is live. _custom.scss was correct and production had no focus
  # ring for a full day, because nothing ever fetched the served stylesheet.
  # Every deliberate rule this phase writes earns a row here.
  check "Live     served main.css declares --font-serif  [red until plan 03-04]" \
    'grep -q -- "--font-serif" "$LIVE_CSS"'
  check "Live     served main.css declares --font-sans  [red until plan 03-04]" \
    'grep -q -- "--font-sans" "$LIVE_CSS"'
  check "Live     served main.css: --step-4 is calc(var(--step-1)*1.8)  [red until plan 03-04]" \
    'grep -qE -- "--step-4:[[:space:]]*calc\(var\(--step-1\)[[:space:]]*\*[[:space:]]*1\.8\)" "$LIVE_CSS"'
  check "Live     served main.css: --step-3 is calc(var(--step-1)*1.35)  [red until plan 03-04]" \
    'grep -qE -- "--step-3:[[:space:]]*calc\(var\(--step-1\)[[:space:]]*\*[[:space:]]*1\.35\)" "$LIVE_CSS"'
  check "Live     served main.css: --step-5 is calc(var(--step-1)*2.6)  [red until plan 03-04]" \
    'grep -qE -- "--step-5:[[:space:]]*calc\(var\(--step-1\)[[:space:]]*\*[[:space:]]*2\.6\)" "$LIVE_CSS"'
  check "Live     served main.css: --measure is 36rem  [red until plan 03-04]" \
    'grep -qE -- "--measure:[[:space:]]*36rem" "$LIVE_CSS"'
  # The minifier may regroup a selector list, so these tolerate any rule whose
  # selector contains the element rather than demanding an exact grouping.
  check "Live     served main.css: body takes var(--font-serif)  [red until plan 03-04]" \
    'grep -qE -- "body\{[^}]*font-family:[[:space:]]*var\(--font-serif\)" "$LIVE_CSS"'
  check "Live     served main.css: body takes font-weight 400 (tailwind base ships 300)  [red until plan 03-04]" \
    'grep -qE -- "body\{[^}]*font-weight:[[:space:]]*400" "$LIVE_CSS"'
  check "Live     served main.css: an h1 rule carries font-weight 600  [red until plan 03-04]" \
    'grep -qE -- "[^a-z0-9-]h1[^{]*\{[^}]*font-weight:[[:space:]]*600" "$LIVE_CSS"'
  check "Live     served main.css: an h2 rule carries font-weight 600  [red until plan 03-04]" \
    'grep -qE -- "[^a-z0-9-]h2[^{]*\{[^}]*font-weight:[[:space:]]*600" "$LIVE_CSS"'
  check "Live     served main.css: an h3 rule carries font-weight 400  [red until plan 03-04]" \
    'grep -qE -- "[^a-z0-9-]h3[^{]*\{[^}]*font-weight:[[:space:]]*400" "$LIVE_CSS"'
  echo

  echo "TYPE-04 — the fragile measure nodes, one row each"
  # These eight are the PurgeCSS casualties. ol, blockquote and h4 appear in
  # no built page, and .clearfix-wrapped prose is the home page's entire body.
  # One row per node, deliberately: a single "the measure shipped" row would
  # tell you something is missing; these tell you WHICH selector was pruned,
  # which is the difference between one safelist entry and a hunt.
  for node in "p" "h2" "h3" "h4" "ol" "blockquote"; do
    check "Live     served main.css keeps .post article>${node} in the measure  [red until plan 03-04]" \
      "grep -qE -- '\.post article[[:space:]]*>[[:space:]]*${node}[,{[:space:]]' \"\$LIVE_CSS\""
  done
  for node in "p" "h2"; do
    check "Live     served main.css keeps .post article>.clearfix>${node} (the home page)  [red until plan 03-04]" \
      "grep -qE -- '\.post article[[:space:]]*>[[:space:]]*\.clearfix[[:space:]]*>[[:space:]]*${node}[,{[:space:]]' \"\$LIVE_CSS\""
  done
  echo

  echo "TYPE-02 / TYPE-03 — the label faces and the unsplit name"
  check "Live     served main.css: .navbar-brand .font-weight-bold is present (TYPE-03 weight fix)  [red until plan 03-04]" \
    'grep -qE -- "\.navbar-brand[[:space:]]+\.font-weight-bold" "$LIVE_CSS"'
  for cls in "entry-year" "entry-meta" "subject-grade" "nav-link"; do
    check "Live     served main.css: .${cls} takes var(--font-sans)  [red until plan 03-04]" \
      "grep -qE -- '\.${cls}[^{]*\{[^}]*font-family:[[:space:]]*var\(--font-sans\)' \"\$LIVE_CSS\""
  done
  echo

  echo "TYPE-05 — the served HTML asks for what _config.yml says, and nothing dead"
  # The gem's <head> emits the & HTML-escaped as &amp;, which browsers parse
  # correctly. Compare against the escaped form rather than asserting the raw
  # one is absent.
  # The `-n "$FONTS_URL"` guard is NOT belt-and-braces. Until plan 03-02 lands,
  # FONTS_URL is empty, and `grep -qF ""` matches EVERY line of any file — so
  # without the guard this row reports PASS today, on a site that requests
  # Roboto and Material Icons. A row that is green for the wrong reason is
  # worse than a red one: it is the false negative the whole harness exists to
  # prevent, and it was observed on this row's first run.
  check "Live     served HTML carries the css2 fonts URL (&amp;-escaped is correct)  [red until plan 03-04]" \
    '[ -n "$FONTS_URL" ] && grep -qF -- "$(printf "%s" "$FONTS_URL" | sed "s/&/\&amp;/g")" "$LIVE_HTML"'
  check "Live     served HTML names no Material+Icons  [red until plan 03-04]" \
    '! grep -qF -- "Material+Icons" "$LIVE_HTML"'
  check "Live     served HTML names no academicons  [red until plan 03-04]" \
    '! grep -q -- "academicons" "$LIVE_HTML"'
  check "Live     served HTML names no scholar-icons  [red until plan 03-04]" \
    '! grep -q -- "scholar-icons" "$LIVE_HTML"'
  # The containment row for plan 03-02's known risk: if the gem's <head>
  # reads the academicons/scholar-icons keys unconditionally, the build may
  # succeed and emit <link rel="stylesheet" href="">. Harmless but wrong, and
  # invisible without this row. The fix is to restore the two config blocks.
  #
  # GREEN TODAY and must STAY green, so it carries NO red label — verified on
  # this row's first run. It is a containment row, not pending work: it asserts
  # that a deletion 03-02 makes does not leave a broken <link> behind. Labelling
  # it would bury a genuine regression inside the expected-red tally, which is
  # precisely the Phase 2 decision this harness's header restates.
  check "Live     served HTML has no empty stylesheet href" \
    '! grep -qE "<link[^>]*rel=\"stylesheet\"[^>]*href=\"\"" "$LIVE_HTML" && ! grep -qE "<link[^>]*href=\"\"[^>]*rel=\"stylesheet\"" "$LIVE_HTML"'
  echo

  # ---- informational rows, always PASS ------------------------------------
  # 03-CONTEXT: icon fonts are inherited payload this phase is not designing.
  # Recorded so the figure is visible, deliberately NOT counted against
  # FONT_BUDGET_BYTES. Measured 2026-09-16: 323,520 B declared across the
  # stylesheet and its four woff2 files, of which fa-solid-900.woff2 (114,740 B)
  # is the only one this site actually fetches — both used glyphs are solid.
  echo "INFO — icon payload, recorded separately and NOT budgeted"
  if [ -n "$ICONS_CSS_URL" ]; then
    node .planning/tools/fontbudget.js "$ICONS_CSS_URL" --report-only 2>&1 | sed 's/^/     /'
  else
    echo "     (no fontawesome CSS URL found in $CONFIG)"
  fi
  check "INFO     icon payload recorded above, not counted against the type budget" 'true'

  GHP_SHA="$(git ls-remote origin refs/heads/gh-pages 2>/dev/null | cut -f1)"
  check "INFO     origin/gh-pages is at ${GHP_SHA:-<unreadable>}" 'true'

  rm -f "$LIVE_CSS" "$LIVE_HTML" "$FONTS_CSS"
  echo
fi

echo "============================================================================="
echo "${CHECKS} checks, ${FAILED} failed"
if [ "$EXPECTED_RED" -gt 0 ]; then
  echo "(${EXPECTED_RED} of those are red-by-design — see the [red until plan 03-NN] labels)"
fi
UNLABELLED=$((FAILED - EXPECTED_RED))
if [ "$UNLABELLED" -gt 0 ]; then
  echo "(${UNLABELLED} UNLABELLED failure(s) — real regressions, not pending work)"
fi

[ "$FAILED" -eq 0 ]

#!/usr/bin/env bash
#
# Phase 4 (Notebook Art Style) — repeatable verification harness.
#
# Composes every AUTOMATABLE row of 04-VALIDATION.md's "Per-Task Verification
# Map" into one command, so each phase criterion can be re-checked on demand
# instead of being a one-off command someone has to remember.
#
#   bash .planning/phases/04-notebook-art-style/verify.sh          # static only
#   bash .planning/phases/04-notebook-art-style/verify.sh --live   # + network block
#
# Same shape as .planning/phases/03-typography/verify.sh, on purpose — the
# check() function, the tally, the --live flag and the red-by-design labelling
# are COPIED, not reinvented. It is deliberately NOT a test framework and
# deliberately NOT wired to an npm script: 01-VALIDATION.md forbids a
# starter-local build/test pipeline, 02- and 03-VALIDATION.md carry that
# forward, and AGENTS.md's style contract rejects build:css / build:tailwind
# npm scripts outright. It is a flat list of assertions plus a tally.
#
# ---------------------------------------------------------------------------
# RED-BY-DESIGN ROWS — READ BEFORE "FIXING" ANYTHING
#
# (Phase 3's explanation, retained because it was kept specifically for this
# phase.)
#
# This harness was written in plan 04-01, BEFORE any CSS changed. Most rows
# therefore FAIL on the day they were committed. That is correct. A row that
# cannot be true yet carries a `[red until plan 04-NN]` label naming the plan
# that makes it true, and is counted separately in the EXPECTED_RED tally.
#
# DO NOT delete a row to get a clean tally. A criterion that is not yet true
# must be visibly red, not invisible. When a gate and a correct implementation
# disagree, NARROW THE MATCHER and write down why — never delete the row, and
# never edit _sass/ to satisfy a matcher.
#
# Phase 3 closed with EXPECTED_RED at 0 and every label stripped in a commit
# whose diff was 49 label removals and nothing else. Plan 04-04 does the same
# for this phase's labels, once — and only once — each row is true against the
# served asset.
#
# ---------------------------------------------------------------------------
# PHASE 4 NOTES
#
# (a) A ROW THAT IS GREEN TODAY AND MUST MERELY STAY GREEN CARRIES NO LABEL.
#
# A label on a green row absorbs a genuine regression into the expected-red
# count and hides it. The red label means "not true yet", never "do not worry
# about this". The unlabelled-green rows in this file are: no !important in
# _sass/, no literals in _custom.scss, the contrast.js self-test, the style
# contract, Prettier, max_width 930px, --measure 36rem, --underline-offset
# 0.18em, the Phase 2 purge safelist entries (":focus-visible" with its leading
# colon, "h5", "h6", "ol", "blockquote", "h4"), no background-attachment fixed,
# no data:image/svg in _custom.scss, zero new network requests, nothing from
# the cliche blocklist, no announceable pseudo-element text, and the seven live
# 200s.
#
# Rows 10-13 (the vocabulary document) were written carrying a
# `[red until plan 04-01]` label, because plan 04-01's task 1 committed this
# harness BEFORE its task 3 wrote docs/NOTEBOOK-MARKS.md. Those four labels
# were stripped in the same commit that created the document, for exactly the
# reason stated above: they are green now, and a green row must not carry a
# label. Nothing about the rows themselves changed.
#
# (b) THE `content:` MATCHER IS NARROWED ON PURPOSE.
#
# `grep -rn 'content:' _sass/` matches `justify-content: space-between` at
# _custom.scss:116 — a real, correct declaration that has nothing to do with
# pseudo-element text. The row below asserts the far narrower thing GROUND-05
# actually needs: that no `content:` declaration carries a NON-EMPTY QUOTED
# STRING, i.e. that no pseudo-element announces text to a screen reader. An
# empty string is permitted and is what plan 04-03 writes.
#
# This is the SIXTH instance of the standing rule (02-02 comment-quoting,
# 02-03 value-aware opacity, 03-01 !important, 03-03 the inline verify, 03-04
# the label matcher): when a gate and a correct implementation disagree, narrow
# the matcher and write down why. Do not widen it back.
#
# (c) `custom_has_no_literals` DOES NOT CATCH A LEAKED DATA URI.
#
# The inherited matcher looks for `#`, `rem`, `px` and `em`. A percent-encoded
# SVG in _custom.scss contains none of those in a form it recognises — `%23` is
# not `#`, and the tile's dimensions are bare integers. So placing the texture
# in the consumer file instead of the token file would pass every inherited row
# silently. That is why row 7 below exists as its own explicit assertion rather
# than being folded into the literals helper.
#
# (d) THE TOKEN IS COMPILED VERBATIM, INCLUDING THE SPACE AFTER THE COLON.
#
# Dart Sass --style=compressed preserves custom-property VALUES untouched (it
# does not parse them), so the authored spacing is not reliably what ships and
# neither is its absence. Every matcher for --paper-texture below is therefore
# whitespace-tolerant, exactly as the Phase 3 harness already is for calc(). A
# matcher demanding one exact space is a row that goes red for a reason that
# has nothing to do with the design.
#
# (e) ONE MATCHER WAS STRENGTHENED AT WRITE TIME, AND IT IS RECORDED HERE.
#
# 04-01-PLAN.md specifies row 5 (the data URI byte budget) as a bare
# `wc -c` result being less than 2048. With no texture in the token file that
# command substitutes the empty string, `wc -c` reports 0, and 0 is less than
# 2048 — so the row would PASS today while carrying a `[red until plan 04-02]`
# label on a green row, which is precisely what note (a) forbids. The row now
# additionally requires the match to be NON-EMPTY, so it is genuinely red until
# 04-02 writes the token and genuinely green afterwards. Strictly stronger,
# same criterion, no row removed.
#
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
MARKS="docs/NOTEBOOK-MARKS.md"
PAGE="_pages/research.md"
DATA="_data/research.yml"
SITE="https://phamhakhanhchi.com"

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

# Phase 2's matcher, carried forward VERBATIM through Phase 3 (02-VALIDATION
# criterion 5). Two documented exemptions: the --deploy-proof date string (a
# deliberately retained deploy canary that a token audit must not delete) and
# SCSS "//" comment lines, which Sass strips entirely so they can never reach
# the served CSS. See note (c): this does NOT catch a leaked data URI.
custom_has_no_literals() {
  [ -f "$CUSTOM" ] || return 1
  local hits
  hits="$(grep -nE '#[0-9a-fA-F]{3,8}|[0-9]*\.?[0-9]+(rem|px|em)\b|color-mix' "$CUSTOM" |
    grep -v -- '--deploy-proof' |
    grep -vE '^[0-9]+:[[:space:]]*//')"
  [ -z "$hits" ]
}

# Phase 3's narrowed matcher, copied unchanged. As first written this row was
# the bare recursive grep for the important keyword and it failed against
# _custom.scss lines 112 and 116, which are `//` COMMENTS explaining why none
# of Phase 2's gem overrides needs one. Sass strips `//` lines entirely, so
# they can never reach the served CSS and cannot make a declaration important.
# A real bang-important on a declaration line still fails.
no_important() {
  local hits
  hits="$(grep -rnE '!important' _sass/ | grep -vE '^[^:]+:[0-9]+:[[:space:]]*//')"
  [ -z "$hits" ]
}

# Byte length of the FIRST --paper-texture data URI in the token file, or 0
# when there is none. `grep -o` prints nothing and exits 1 on no match, so the
# substitution yields the empty string and `wc -c` yields 0 — see note (e) for
# why the row that consumes this also requires a non-zero result.
texture_uri_bytes() {
  grep -o 'url("data:image/svg+xml,[^"]*"' "$TOKENS" 2>/dev/null | head -1 | wc -c | tr -d '[:space:]'
}

# The --rule-500 hex as currently declared in the token file. Read, never
# hardcoded: Phase 2's rule is that a live row compares the served asset
# against the LOCAL source, and 04-02's checkpoint may choose a hex other than
# the recommended one.
rule_500_hex() {
  sed -nE 's/^[[:space:]]*--rule-500:[[:space:]]*(#[0-9a-fA-F]{6}).*/\1/p' "$TOKENS" 2>/dev/null | head -1
}

# The worst-case composited ground hex, written into the --paper-texture
# comment block by plan 04-02 as `worst-case composited ground: #xxxxxx`.
# Do NOT hardcode #eeeae2 — that value is only correct for alpha 0.05, and the
# alpha is chosen at 04-02's checkpoint from .planning/tools/texture-swatch.html.
composited_ground_hex() {
  sed -nE 's/.*worst-case composited ground:[[:space:]]*(#[0-9a-fA-F]{6}).*/\1/p' "$TOKENS" 2>/dev/null | head -1
}

# contrast.js prints "<fg> on <bg> = N.NN:1  <verdict>". Extract N.NN and
# compare against the 3.0 floor with awk, because bash has no float compare.
rule_on_ground_clears_3() {
  local fg bg out r
  fg="$(rule_500_hex)"
  bg="$(composited_ground_hex)"
  [ -n "$fg" ] && [ -n "$bg" ] || return 1
  out="$(node .planning/tools/contrast.js "$fg" "$bg" 2>/dev/null)" || return 1
  r="$(printf '%s' "$out" | sed -nE 's/.*=[[:space:]]*([0-9]+\.[0-9]+):1.*/\1/p' | head -1)"
  [ -n "$r" ] || return 1
  awk -v v="$r" 'BEGIN { exit (v >= 3.0) ? 0 : 1 }'
}

# The aside must come AFTER the element it annotates, in source order — that is
# what makes GROUND-05 and criterion 3 true by construction rather than by
# inspection. Compares line numbers within one file.
aside_after_entry_body() {
  local f="$1"
  [ -f "$f" ] || return 1
  awk '/entry-body/ { b = NR } /entry-note/ { if (!n) n = NR } END { exit (b && n && n > b) ? 0 : 1 }' "$f"
}

# git ls-files + grep -c: grep prints 0 and EXITS 1 on no match, so a bare
# command substitution is fine but the pipeline status is not. Swallow it.
texture_files_under_assets() {
  git ls-files assets/ 2>/dev/null | grep -ci 'tex' || true
}

echo "=== Phase 4 — Notebook Art Style: static checks ============================="
echo

echo "GROUND-02 — the paper grain is a token, pinned, cheap and request-free"
# 1
check "GROUND-02 $TOKENS declares --paper-texture as a url()" \
  'grep -qE -- "--paper-texture:[[:space:]]*url\(" "$TOKENS"'
# 2 — without stitchTiles the per-tile noise is generated independently and the
# 200x200 grid is visible as a checkerboard.
check "GROUND-02 the tile sets stitchTiles='stitch'" \
  "grep -qF \"stitchTiles='stitch'\" \"\$TOKENS\""
# 3 — <filter>'s region DEFAULTS to x=-10% y=-10% width=120% height=120%, so
# stitchTiles stitches a 240x240 region against a 200x200 image and the tile
# seams. Pinning the region to the image is what makes the grain seamless.
check "GROUND-02 the filter region is PINNED (x='0' y='0')" \
  "grep -qF \"x='0' y='0'\" \"\$TOKENS\""
# 4 — 3+ octaves clusters the noise and reads as aged blotching, which is on
# the cliche blocklist in docs/NOTEBOOK-MARKS.md.
check "GROUND-02 numOctaves is 1 or 2, never 3+ (blotching)" \
  "grep -qE \"numOctaves='[12]'\" \"\$TOKENS\""
# 5 — see note (e): the non-empty clause is a deliberate strengthening.
check "GROUND-02 the data URI is non-empty and under 2048 B (have: $(texture_uri_bytes))" \
  '[ "$(texture_uri_bytes)" -gt 0 ] && [ "$(texture_uri_bytes)" -lt 2048 ]'
# 6 — unlabelled green. Ruled out in 04-RESEARCH: per-frame repaint, iOS
# Safari stutter. A later "parallax" idea must fail loudly here.
check "GROUND-02 no background-attachment: fixed anywhere in _sass/" \
  "! grep -rqE 'background-attachment:[[:space:]]*fixed' _sass/"
# 7 — unlabelled green. See note (c): the inherited literals helper cannot see
# a percent-encoded SVG, so this row is the only thing keeping the texture in
# the token file where the cap and the comments live.
check "GROUND-02 no data:image/svg leaked into $CUSTOM (see note (c))" \
  "! grep -q 'data:image/svg' \"\$CUSTOM\""
# 8 — unlabelled green. The whole point of the inline data URI is zero extra
# requests; a raster tile smuggled into assets/ would defeat it silently.
check "GROUND-02 zero new network requests — no texture image in _sass/, $CONFIG or assets/" \
  "! grep -rqiE 'assets/img/[^\"]*tex' _sass/ \"\$CONFIG\" && [ \"\$(texture_files_under_assets)\" = '0' ]"
# 9 — the three consumers. CONTEXT locks the texture as ONE continuous sheet
# across every paper-coloured surface; a flat navbar above a textured page
# reads as a rendering bug (PITFALLS).
check "GROUND-02 [red until plan 04-03] $CUSTOM: body takes background-image: var(--paper-texture)" \
  'grep -qE -- "body[^{]*\{" "$CUSTOM" && grep -qE -- "background-image:[[:space:]]*var\(--paper-texture\)" "$CUSTOM"'
check "GROUND-02 [red until plan 04-03] $CUSTOM: .navbar takes background-image: var(--paper-texture)" \
  'awk "/\.navbar[^{]*\{/,/\}/" "$CUSTOM" | grep -qE -- "background-image:[[:space:]]*var\(--paper-texture\)"'
check "GROUND-02 [red until plan 04-03] $CUSTOM: .card takes background-color: transparent" \
  'awk "/\.card[^{]*\{/,/\}/" "$CUSTOM" | grep -qE -- "background-color:[[:space:]]*transparent"'
echo

echo "GROUND-03 — four marks, four defences, one blocklist, one cap"
# 10-13 — the vocabulary document. These four went green when plan 04-01's
# task 3 wrote the file; their labels were stripped in
# that same commit, per note (a).
check "GROUND-03 $MARKS exists" \
  '[ -f "$MARKS" ]'
for mark in "section rule" "margin note" "annotation bracket" "link underline"; do
  check "GROUND-03 $MARKS names the mark: ${mark}" \
    "grep -qi -- '${mark}' \"\$MARKS\""
done
# 12 — EXACTLY four. Not "at least": the cap is the mechanism, and a fifth
# defence sentence means a fifth mark arrived without the cap being edited.
check "GROUND-03 $MARKS carries EXACTLY 4 lines starting 'Defence:' (have: $(grep -c '^Defence:' "$MARKS" 2>/dev/null || echo 0))" \
  '[ "$(grep -c "^Defence:" "$MARKS")" = "4" ]'
# 13 — the blocklist lives in the SAME document as the allowed list, because
# criterion 5 IS that list.
for term in coffee tape paperclip pushpin torn spiral ruled highlighter crosshatch aged; do
  check "GROUND-03 $MARKS blocklists: ${term}" \
    "grep -qi -- '${term}' \"\$MARKS\""
done
# 14 — the cap as a NUMBER in the token file, beside the TOKEN-06 caps, so a
# fifth mark means visibly editing a stated number in two places.
check "GROUND-03 $TOKENS cap line reads 'notebook marks ... 4'" \
  'grep -qE "notebook marks[ .]+4" "$TOKENS"'
# 15 — unlabelled green, VERIFIED empty on the day this row was written. This
# is criterion 5 enforced against the shipping CSS rather than against the
# document that lists it.
check "Crit-5    nothing from the blocklist ships in _sass/ (no coffee/tape/spiral/curl...)" \
  "! grep -rqiE 'coffee|washi|paperclip|pushpin|spiral|page-curl|torn-edge' _sass/"
check "Crit-5    no rotate() or skew() anywhere in _sass/ (marks are geometric, never jaunty)" \
  "! grep -rqE 'rotate\(|skew\(' _sass/"
# 16 — the recommended hex. NOTE: 04-02's checkpoint may legitimately choose a
# different value; the BINDING requirement is row 17 (the composited ratio),
# not this literal. If a different hex is chosen, re-point this row to it —
# do not delete it, and do not weaken row 17 to match.
check "GROUND-03 --rule-500 is re-pointed to #8d7b60 (see row 17: the ratio binds, not this hex)" \
  'grep -qE -- "--rule-500:[[:space:]]*#8d7b60" "$TOKENS"'
# 17 — the binding row. Every ink ratio in _tokens.scss was measured against
# FLAT #faf6ee; the texture composites OVER it and lowers every one of them.
# The ground hex is read from 04-02's own comment, never hardcoded — #eeeae2
# is correct only for alpha 0.05.
check "GROUND-03 --rule-500 clears 3.0 on the COMPOSITED ground (rule $(rule_500_hex) on $(composited_ground_hex))" \
  'rule_on_ground_clears_3'
# 18 — the section rule itself, the same border idiom already shipped on
# .subject: repetition reads as a system.
check "GROUND-03 [red until plan 04-03] $CUSTOM declares .entry-group-title with the hairline border-bottom" \
  'grep -qE "\.entry-group-title" "$CUSTOM" && awk "/\.entry-group-title[^{]*\{/,/\}/" "$CUSTOM" | grep -qE -- "border-bottom:[[:space:]]*var\(--rule-hairline\)[[:space:]]+solid[[:space:]]+var\(--rule-500\)"'
echo

echo "GROUND-05 — the marks are decoration; the content is markup"
# 19 — unlabelled green. See note (b) for why this matcher is narrow.
check "GROUND-05 no pseudo-element carries announceable text (empty content only)" \
  "! grep -rnE 'content:[[:space:]]*\"[^\"]+\"' _sass/"
# 20
check "GROUND-05 [red until plan 04-03] .entry-note::before exists and uses an EMPTY content string" \
  'grep -qE "\.entry-note::before" "$CUSTOM" && awk "/\.entry-note::before[^{]*\{/,/\}/" "$CUSTOM" | grep -qE "content:[[:space:]]*\"\""'
# 21 — real markup in reading order. The <aside> must be a SIBLING of
# .entry-body and appear after it, so an unstyled page reads the note inline
# and in order.
check "GROUND-05 [red until plan 04-03] $PAGE carries <aside class=\"entry-note\">" \
  'grep -qF "<aside class=\"entry-note\">" "$PAGE"'
check "GROUND-05 [red until plan 04-03] in $PAGE the aside appears AFTER the .entry-body it annotates" \
  'aside_after_entry_body "$PAGE"'
# 22 — the phase cannot close on placeholder prose. CONTEXT: the site owner
# authors 1-2 REAL notes.
check "GROUND-05 [red until plan 04-03] $DATA carries at least one NON-EMPTY note: value" \
  'grep -qE "^[[:space:]]+note:[[:space:]]*[^[:space:]#]" "$DATA"'
echo

echo "Regression — this phase must not turn a surviving gate red on its way in"
# 23-24 — Phase 2/3 helpers, copied unchanged. Unlabelled green.
check "Regress   no !important on any declaration in _sass/ (// comments exempt)" \
  'no_important'
check "Regress   $CUSTOM has no hex / rem / px / em / color-mix literal" \
  'custom_has_no_literals'
# 25 — no CI gate on this site covers contrast; this tool is the whole
# enforcement, so its own correctness is a row.
check "Tool      node .planning/tools/contrast.js --selftest exits 0" \
  'node .planning/tools/contrast.js --selftest'
# 26
check "Regress   node test/style_contract.js exits 0" \
  'node test/style_contract.js'
# 27 — --end-of-line auto is mandatory locally. core.autocrlf=true makes a bare
# --check report line-ending-only false failures; CI runs on Linux/LF and sees
# only real ones. Never run `npx prettier . --write` on this checkout.
# docs/ IS Prettier-gated (only .planning/** is ignored), so NOTEBOOK-MARKS.md
# is covered here.
check "Regress   npx prettier _sass docs _data _pages $PURGE --check --end-of-line auto" \
  "npx prettier _sass docs _data _pages \"\$PURGE\" --check --end-of-line auto"
# 28 — Phase 2's safelist, unlabelled green. The leading colon is load-bearing:
# the safelist is matched against SELECTOR NODES, so "focus-visible" without it
# does not match and is not a substitute (measured against purgecss 8.0.0). A
# regression here re-strips the keyboard focus ring from production.
check "Purge     $PURGE still safelists \":focus-visible\" WITH its leading colon" \
  "grep -qF -- '\":focus-visible\"' \"\$PURGE\""
for node in h5 h6 ol blockquote h4; do
  check "Purge     $PURGE still safelists \"${node}\"" \
    "grep -qF -- '\"${node}\"' \"\$PURGE\""
done
# 29 — .entry-note is a class node PurgeCSS matches, but it must land in the
# SAME commit as the rule that names it. Standing live proof the mechanism
# bites: _custom.scss declares .topic-list and the served main.css contains
# zero occurrences of it.
check "Purge     [red until plan 04-03] $PURGE safelists \"entry-note\"" \
  "grep -qF -- '\"entry-note\"' \"\$PURGE\""
# 30 — this phase changes NONE of these. A change to any is a real regression,
# not pending work, so none carries a label. max_width's leftover ~354px is
# the gutter the margin note occupies; narrowing it would silently delete this
# phase's canvas.
check "Regress   $CONFIG max_width is UNCHANGED at 930px (the note gutter depends on it)" \
  'grep -qE "^max_width:[[:space:]]*930px" "$CONFIG"'
check "Regress   $TOKENS --measure is UNCHANGED at 36rem" \
  'grep -qE -- "--measure:[[:space:]]*36rem" "$TOKENS"'
check "Regress   $TOKENS --underline-offset is UNCHANGED at 0.18em" \
  'grep -qE -- "--underline-offset:[[:space:]]*0\.18em" "$TOKENS"'
echo

if [ "$LIVE" -eq 1 ]; then
  echo "=== Live checks (--live) ====================================================="
  echo
  # The cache-buster is mandatory, not decorative: main.css is served with
  # Cache-Control max-age=600 behind a CDN, so a plain fetch can show the
  # PREVIOUS build for ~10 minutes after a successful deploy. Deploy latency
  # from push is ~75-168s across four measurements — poll, do not refresh once,
  # and do not conclude from one stale fetch that the push failed.
  #
  # Phase 2's most expensive lesson, restated: a source grep is NOT evidence
  # that a rule is live. _custom.scss was correct and production had no focus
  # ring for a full day, because nothing ever fetched the served stylesheet.
  # Every deliberate rule this phase writes earns a row here.
  LIVE_CSS="$(mktemp)"
  curl -s --max-time 30 "${SITE}/assets/css/main.css?cb=$(date +%s)" >"$LIVE_CSS" 2>/dev/null
  LIVE_HTML_RESEARCH="$(mktemp)"
  curl -s -L --max-time 30 "${SITE}/research/?cb=$(date +%s)" >"$LIVE_HTML_RESEARCH" 2>/dev/null

  # 31-37 — unlabelled green: the site is already live. A red row here is a
  # deploy that broke a page, not pending work.
  for page in "" academics research further-reading projects activities cv; do
    check "Live      ${SITE}/${page} returns 200" \
      "[ \"\$(curl -s -o /dev/null -w '%{http_code}' -L --max-time 20 '${SITE}/${page}')\" = '200' ]"
  done
  echo

  echo "GROUND-02 — the grain in the stylesheet the CDN actually serves"
  # 38 — whitespace-tolerant, see note (d).
  check "Live      [red until plan 04-04] served main.css declares --paper-texture" \
    'grep -qE -- "--paper-texture:[[:space:]]*url\(" "$LIVE_CSS"'
  # 39-41 — the minifier may regroup a selector list, so these tolerate any
  # rule whose selector contains the element rather than demanding a grouping.
  check "Live      [red until plan 04-04] served main.css: body takes background-image:var(--paper-texture)" \
    'grep -qE -- "body\{[^}]*background-image:[[:space:]]*var\(--paper-texture\)" "$LIVE_CSS"'
  check "Live      [red until plan 04-04] served main.css: .navbar takes background-image:var(--paper-texture)" \
    'grep -qE -- "\.navbar[^{]*\{[^}]*background-image:[[:space:]]*var\(--paper-texture\)" "$LIVE_CSS"'
  check "Live      [red until plan 04-04] served main.css: .card takes background-color:transparent" \
    'grep -qE -- "\.card[^{]*\{[^}]*background-color:[[:space:]]*transparent" "$LIVE_CSS"'
  # 42
  check "Live      [red until plan 04-04] served main.css: .entry-group-title carries border-bottom" \
    'grep -qE -- "\.entry-group-title[^{]*\{[^}]*border-bottom" "$LIVE_CSS"'
  # 43 — the PurgeCSS survival row. Standing live proof the mechanism bites:
  # _custom.scss declares .topic-list and the served main.css contains zero
  # occurrences of it.
  check "Live      [red until plan 04-04] served main.css contains .entry-note AT ALL (PurgeCSS survival)" \
    'grep -q -- "\.entry-note" "$LIVE_CSS"'
  # 44 — the minifier may emit either the CSS2 single-colon or the CSS3
  # double-colon form; accept both.
  check "Live      [red until plan 04-04] served main.css contains .entry-note:before or ::before" \
    'grep -qE -- "\.entry-note::?before" "$LIVE_CSS"'
  # 45 — read the LOCAL value, do not hardcode. Phase 2's rule: a live row
  # compares the served asset against the local source, so it survives 04-02's
  # checkpoint choosing a different hex.
  check "Live      [red until plan 04-04] served main.css --rule-500 equals the local $(rule_500_hex)" \
    '[ -n "$(rule_500_hex)" ] && grep -qE -- "--rule-500:[[:space:]]*$(rule_500_hex)" "$LIVE_CSS"'
  # 46
  check "Live      [red until plan 04-04] served main.css has no background-attachment:fixed" \
    '! grep -qE -- "background-attachment:[[:space:]]*fixed" "$LIVE_CSS"'
  # 47-48 — GROUND-05 against the DEPLOYED markup, not the Liquid source.
  check "Live      [red until plan 04-04] served Research HTML carries <aside class=\"entry-note\">" \
    'grep -qF "<aside class=\"entry-note\">" "$LIVE_HTML_RESEARCH"'
  check "Live      [red until plan 04-04] served Research HTML: the aside appears AFTER its .entry-body" \
    'aside_after_entry_body "$LIVE_HTML_RESEARCH"'
  # 49 — the zero-request promise, checked against what actually shipped.
  check "Live      [red until plan 04-04] neither served CSS nor served HTML requests a texture image file" \
    '! grep -qiE "assets/img/[^\")]*tex" "$LIVE_CSS" && ! grep -qiE "assets/img/[^\"]*tex" "$LIVE_HTML_RESEARCH"'
  echo

  # ---- informational rows, always PASS ------------------------------------
  # 50
  GHP_SHA="$(git ls-remote origin refs/heads/gh-pages 2>/dev/null | cut -f1)"
  check "INFO      origin/gh-pages is at ${GHP_SHA:-<unreadable>}" 'true'

  rm -f "$LIVE_CSS" "$LIVE_HTML_RESEARCH"
  echo
fi

echo "============================================================================="
echo "${CHECKS} checks, ${FAILED} failed"
if [ "$EXPECTED_RED" -gt 0 ]; then
  echo "(${EXPECTED_RED} of those are red-by-design — see the [red until plan 04-NN] labels)"
fi
UNLABELLED=$((FAILED - EXPECTED_RED))
if [ "$UNLABELLED" -gt 0 ]; then
  echo "(${UNLABELLED} UNLABELLED failure(s) — real regressions, not pending work)"
fi

[ "$FAILED" -eq 0 ]

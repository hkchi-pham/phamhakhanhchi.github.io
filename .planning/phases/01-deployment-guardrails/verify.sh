#!/usr/bin/env bash
#
# Phase 1 (Deployment Guardrails) — repeatable verification harness.
#
# Composes every AUTOMATABLE row of 01-RESEARCH.md's "Phase Requirements ->
# Test Map" into one command, so each phase criterion can be re-checked on
# demand instead of being a one-off command someone has to remember.
#
#   bash .planning/phases/01-deployment-guardrails/verify.sh          # static only
#   bash .planning/phases/01-deployment-guardrails/verify.sh --live   # + network block
#
# This is deliberately NOT a test framework, and deliberately NOT wired to an
# npm script: 01-VALIDATION.md forbids a starter-local build/test pipeline.
# It is a flat list of assertions plus a tally.
#
# It does NOT cover the four manual-only rows in 01-VALIDATION.md (the Actions
# run step list, Settings > Pages, Settings > Rules, and a human reading
# docs/DEPLOYMENT.md's prose). Those need a browser and a person.
#
# Exit: 0 only when zero checks failed.

set -uo pipefail

cd "$(git rev-parse --show-toplevel)" || exit 2

LIVE=0
[ "${1:-}" = "--live" ] && LIVE=1

CHECKS=0
FAILED=0
EXPECTED_RED=0

WF=".github/workflows/deploy.yml"

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

# Line number of the first match in deploy.yml, or 0 if absent. 0 (rather than
# an empty string) makes the ordering comparisons fail loudly instead of
# silently comparing nothing.
line_of() {
  local n
  n="$(grep -n -- "$1" "$WF" 2>/dev/null | head -1 | cut -d: -f1)"
  printf '%s' "${n:-0}"
}

# Exercises bin/verify-cname.sh against five synthetic site directories.
# Never touches the real repo-root CNAME: the live custom domain is healthy
# and this guard is regression insurance, not a repair (see 01-02-SUMMARY.md).
cname_fixture_proof() {
  [ -f bin/verify-cname.sh ] || return 1
  local tmp rc=0
  tmp="$(mktemp -d)" || return 1

  mkdir -p "$tmp/good" && printf 'phamhakhanhchi.com\n' >"$tmp/good/CNAME"
  mkdir -p "$tmp/crlf" && printf 'phamhakhanhchi.com\r\n' >"$tmp/crlf/CNAME"
  mkdir -p "$tmp/empty" && : >"$tmp/empty/CNAME"
  mkdir -p "$tmp/wrong" && printf 'example.com\n' >"$tmp/wrong/CNAME"
  mkdir -p "$tmp/absent"

  bash bin/verify-cname.sh "$tmp/good" >/dev/null 2>&1 || rc=1   # expect exit 0
  bash bin/verify-cname.sh "$tmp/crlf" >/dev/null 2>&1 || rc=1   # expect exit 0
  bash bin/verify-cname.sh "$tmp/empty" >/dev/null 2>&1 && rc=1  # expect exit 1
  bash bin/verify-cname.sh "$tmp/wrong" >/dev/null 2>&1 && rc=1  # expect exit 1
  bash bin/verify-cname.sh "$tmp/absent" >/dev/null 2>&1 && rc=1 # expect exit 1

  rm -rf "$tmp"
  return $rc
}

echo "=== Phase 1 — Deployment Guardrails: static checks ==========================="
echo
# ---------------------------------------------------------------------------
# RED-BY-DESIGN ROWS — READ BEFORE "FIXING" ANYTHING
#
# The four SAFE-04 rows below FAIL until plan 01-05 writes docs/DEPLOYMENT.md.
# That is correct and expected. Do NOT delete them to get a clean tally: a
# criterion that is not yet true should be visibly red, not invisible.
#
# Those SAFE-04 greps are a PRESENCE PROXY ONLY. They prove the strings
# "path filter", "CNAME" and "PurgeCSS" appear somewhere in the file. Whether
# the doc actually STATES that a _sass-only revert now redeploys (and did not
# before) is a prose claim no grep can settle. 01-VALIDATION.md lists that as
# manual-only: a human must read §4 end to end.
# ---------------------------------------------------------------------------

echo "SAFE-01 — the deploy trigger is a denylist, and _sass is not on it"
check "SAFE-01  deploy.yml uses a paths-ignore denylist" \
  'grep -q "paths-ignore:" .github/workflows/deploy.yml'
check "SAFE-01  deploy.yml has no paths: allowlist (an all-negative one never fires)" \
  '! grep -qE "^[[:space:]]+paths:" .github/workflows/deploy.yml'
check "SAFE-01  _sass is NOT an ignore entry (SCSS-only commits must deploy)" \
  '! grep -qE "^[[:space:]]+- \"?_sass" .github/workflows/deploy.yml'
echo

echo "SAFE-02 — the CNAME is guarded before the destructive publish"
check "SAFE-02  bin/verify-cname.sh exits 0/0/1/1/1 on good/CRLF/empty/wrong/absent" \
  'cname_fixture_proof'
check "SAFE-02  CNAME gate precedes the deploy action (line $(line_of 'bin/verify-cname.sh') < $(line_of 'JamesIves/github-pages-deploy-action'))" \
  '[ "$(line_of "bin/verify-cname.sh")" -gt 0 ] && [ "$(line_of "bin/verify-cname.sh")" -lt "$(line_of "JamesIves/github-pages-deploy-action")" ]'
check "SAFE-02  live-domain gate follows the deploy action (line $(line_of 'Verify live domain responds') > $(line_of 'JamesIves/github-pages-deploy-action'))" \
  '[ "$(line_of "Verify live domain responds")" -gt "$(line_of "JamesIves/github-pages-deploy-action")" ]'
check "SAFE-02  repo-root CNAME still normalises to phamhakhanhchi.com" \
  '[ -f CNAME ] && [ "$(tr -d "[:space:]" <CNAME)" = "phamhakhanhchi.com" ]'
echo

echo "SAFE-03 — no design PR can be blocked by a check that cannot pass here"
check "SAFE-03  visual-regression.yml no longer exists" \
  'test ! -f .github/workflows/visual-regression.yml'
check "SAFE-03  workflow inventory is exactly broken-links-site.yml deploy.yml prettier.yml" \
  '[ "$(ls .github/workflows/ | grep -E "\.yml$" | sort | tr "\n" " ")" = "broken-links-site.yml deploy.yml prettier.yml " ]'
echo

echo "SAFE-04 — the deploy contract is written down  [all red until plan 05]"
check "SAFE-04  docs/DEPLOYMENT.md exists  [red until plan 05]" \
  'test -f docs/DEPLOYMENT.md'
check "SAFE-04  docs/DEPLOYMENT.md mentions 'path filter' (presence proxy)  [red until plan 05]" \
  'grep -qi "path filter" docs/DEPLOYMENT.md'
check "SAFE-04  docs/DEPLOYMENT.md mentions 'CNAME' (presence proxy)  [red until plan 05]" \
  'grep -qi "cname" docs/DEPLOYMENT.md'
check "SAFE-04  docs/DEPLOYMENT.md mentions 'PurgeCSS' (presence proxy)  [red until plan 05]" \
  'grep -qi "purgecss" docs/DEPLOYMENT.md'
echo

echo "CI hygiene — this phase must not turn prettier.yml red on its way in"
# --end-of-line auto is mandatory locally. core.autocrlf=true makes a bare
# --check report ~99 line-ending-only false failures; CI runs on Linux/LF and
# sees only real ones. Never run `npx prettier . --write` on this checkout.
check "prettier  npx prettier . --check --end-of-line auto exits 0" \
  'npx prettier . --check --end-of-line auto'
echo

if [ "$LIVE" -eq 1 ]; then
  echo "=== Live checks (--live) ====================================================="
  echo
  # RED-BY-DESIGN here too: the --deploy-proof row goes green once plan 01-04
  # pushes the _sass-only marker commit, and the design-00-baseline tag row
  # once plan 01-05 pushes the tag. Leave both visible until then.
  check "SAFE-02  https://phamhakhanhchi.com returns 200" \
    '[ "$(curl -s -o /dev/null -w "%{http_code}" -L --max-time 20 https://phamhakhanhchi.com)" = "200" ]'
  # The cache-buster is mandatory, not decorative: main.css is served with
  # Cache-Control max-age=600 behind a CDN, so a plain fetch can show the
  # PREVIOUS build for ~10 minutes after a successful deploy.
  check "SAFE-01  live main.css contains the --deploy-proof marker  [red until plan 04]" \
    'curl -s --max-time 20 "https://phamhakhanhchi.com/assets/css/main.css?cb=$(date +%s)" | grep -q -- "--deploy-proof"'
  check "SAFE-04  origin carries the design-00-baseline tag  [red until plan 05]" \
    'git ls-remote --tags origin 2>/dev/null | grep -q "design-00-baseline"'
  # Informational, always PASS. This is the value a human records BEFORE a
  # push and compares AFTER it, to see whether a deploy actually fired.
  GHP_SHA="$(git ls-remote origin refs/heads/gh-pages 2>/dev/null | cut -f1)"
  check "INFO     origin/gh-pages is at ${GHP_SHA:-<unreadable>}" 'true'
  echo
fi

echo "============================================================================="
echo "${CHECKS} checks, ${FAILED} failed"
if [ "$EXPECTED_RED" -gt 0 ]; then
  echo "(${EXPECTED_RED} of those are red-by-design — see the [red until plan NN] labels)"
fi

[ "$FAILED" -eq 0 ]

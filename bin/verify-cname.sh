#!/usr/bin/env bash
#
# Assert that a built site directory carries the correct CNAME file.
#
# This is the single source of truth for the CNAME assertion: the deploy
# workflow and any local test call THIS script, so they cannot drift apart.
#
# Why it exists: JamesIves/github-pages-deploy-action rsyncs the build folder
# over gh-pages with --delete. When _site/CNAME is absent the action adds
# --exclude CNAME and the good CNAME on gh-pages survives; the genuinely
# uncovered hazard is a PRESENT-BUT-WRONG _site/CNAME (empty, truncated, or a
# different hostname) being rsynced over the good one. So this checks the
# CONTENTS, not just existence.
#
# The pipeline is currently healthy - this is regression insurance, not a repair.
#
# Usage: bash bin/verify-cname.sh [site-directory]   (default: _site)
# Exit:  0 = CNAME present and correct
#        1 = CNAME missing, empty, or wrong hostname (annotated for Actions)

set -euo pipefail

EXPECTED_HOST="phamhakhanhchi.com"
SITE_DIR="${1:-_site}"
CNAME_FILE="${SITE_DIR}/CNAME"

if [ ! -f "$CNAME_FILE" ]; then
  echo "::error title=CNAME missing - refusing to deploy::_site/CNAME was not produced by the build. Deploying now would hand gh-pages a site with no custom domain. Check that CNAME is still at the repo root and is not listed under exclude: in _config.yml."
  exit 1
fi

# Normalise: strip all whitespace so a CRLF checkout or a trailing newline
# does not fail a byte-for-byte comparison.
ACTUAL_HOST="$(tr -d '[:space:]' < "$CNAME_FILE")"

if [ "$ACTUAL_HOST" != "$EXPECTED_HOST" ]; then
  echo "::error title=CNAME wrong - refusing to deploy::_site/CNAME contains '${ACTUAL_HOST}' but must contain '${EXPECTED_HOST}'. Deploying would overwrite the good CNAME on gh-pages and drop the custom domain."
  exit 1
fi

OK_LINE="CNAME OK (${CNAME_FILE} -> ${EXPECTED_HOST})"
echo "$OK_LINE"
if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  echo "$OK_LINE" >> "$GITHUB_STEP_SUMMARY"
fi

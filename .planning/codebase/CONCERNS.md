# Codebase Concerns

**Analysis Date:** 2026-09-12

## Dependency Management

**jekyll-terser git pin (HIGH):**
- Issue: `Gemfile` line 23 pins jekyll-terser to a git branch without specifying a commit or tag
  ```ruby
  gem 'jekyll-terser', :git => "https://github.com/RobertoJBeltran/jekyll-terser.git"
  ```
- Files: `Gemfile` (line 23)
- Impact: 
  - Rebuilds may pull different versions of the gem without warning
  - Violates CLAUDE.md guidance: "pins should be exact released versions"
  - CI builds become non-deterministic
  - Conflicts with the strict `al_folio_plugins` version pinning elsewhere in Gemfile
- Fix approach: 
  - Use a released gem version or pin to a specific commit hash: `gem 'jekyll-terser', '= 0.x.y'` or `gem 'jekyll-terser', git: "...", ref: "SHA_or_TAG"`
  - Per CLAUDE.md, git pins are meant to be temporary during development only; before committing, revert to a released version

## Incomplete Content

**Placeholder project descriptions (MEDIUM):**
- Issue: Two project pages contain unwritten TODO sections that block project visibility
- Files:
  - `_projects/friendship-web-game.md` (line 9): "TODO — details to come. Worth covering: how the game works, how students use it at school, what you built it with, and whether it has been trialled yet."
  - `_projects/soul-garden.md` (line 9): "TODO — details to come. Worth covering: the problem you saw, who it is for, what the AI actually does, the stack, and where it stands now."
- Impact:
  - Projects render as stubs on the portfolio, reducing credibility
  - Users cannot access project details or links (github/redirect fields are commented out)
  - The projects are marked as importance 1 and 2 but lack substance
- Fix approach:
  - Complete project descriptions covering the outlined topics
  - Uncommment `img`, `github`, and `redirect` front-matter as content is ready
  - Consider setting `nav: false` on incomplete projects to hide them from discovery until ready

## CI Coverage Gaps

**Removed integration tests (MEDIUM):**
- Issue: All seven `test/integration_*.sh` scripts were removed in commit 81e55bd ("Drop the template's integration tests from CI")
- Files: `.github/workflows/unit-tests.yml` (lines 43-50 document the removal)
- Context: Those tests assert against al-folio template demo content (`blog/2022/giscus-comments`, `blog/2015/rtl`, etc.) which this personal site does not include, so the tests were intentionally removed
- Impact:
  - No gated coverage for core Jekyll build functionality (comments, plugin toggles, distill rendering, Bootstrap compat, upgrade CLI, CSS minify, new plugins)
  - Build errors in gem integration layers might only be caught by visual regression tests or broken-link checks
  - Limited safety net for major gem version upgrades
- Note: This is appropriate for a personal portfolio (not a template testing framework), but it represents a trade-off for simplicity
- Improvement path: Add targeted integration tests for features this site uses (e.g., CV rendering with `al_folio_cv`, if distill is enabled, comment systems if enabled)

## Local Override Drift

**Tracked override: assets/css/main.scss (MEDIUM):**
- Issue: One override is tracked in `.al-folio-overrides.yml` but requires manual management during gem updates
- Files:
  - `assets/css/main.scss` (override of `al_folio_core`)
  - `_sass/_custom.scss` (site-specific styles imported by main.scss)
  - `.al-folio-overrides.yml` (drift tracking file)
- Current status (as of 2026-09-10):
  - Upstream SHA256: `437c6c911c596391413e435dc0ea7095e682e85c572c1fd3fff69f9597455b3e` (al_folio_core v1.0.15)
  - Local SHA256: `e51ec6fb5bd4afc4444b1acbabdedbb51e573652e527fcb50c560c52347735ac`
  - Acknowledged: Yes
- Risk:
  - When `al_folio_core` updates, `assets/css/main.scss` may diverge from upstream
  - The `@use "custom";` line must remain at the end of the file for site-specific rules to take precedence
  - Future gem versions could change the file structure, breaking imports
- Safe modification:
  - Only edit `_sass/_custom.scss` for site-specific styles, never `assets/css/main.scss` directly
  - When upgrading gems, run `bundle exec al-folio upgrade overrides audit` and `bundle exec al-folio upgrade overrides diff assets/css/main.scss` to check for drift
  - If upstream changes, merge carefully, preserving the final `@use "custom";` line
  - After any change, run `bundle exec al-folio upgrade overrides accept assets/css/main.scss` to update `.al-folio-overrides.yml`

## Architecture & Design

**Design overhaul in progress (CONTEXT):**
- Issue: Styles in `_sass/_custom.scss` are intentionally minimal
- Files: `_sass/_custom.scss` (lines 1-4, 60-61)
- Context: The comment states "the real design pass replaces this wholesale" — current styles are placeholder/temporary
- Impact:
  - Styles are minimal and deliberately plain, not production-final
  - Background, art style, presentation, typography are marked for redesign
  - This is intentional and documented; not a bug or oversight
- Implication: Design work will likely touch most styles in `_sass/_custom.scss`; planning should account for potential churn in CSS specificity and Tailwind utility class usage

## Configuration

**Silent failure modes (VERIFIED - NO ISSUES):**
1. **Gemfile / config.yml sync**: ✓ Both files have matching al-folio plugin lists (19 plugins each). No risk of features silently disabled.
2. **Baseurl configuration**: ✓ `_config.yml` correctly sets `baseurl:` (empty for custom domain `phamhakhanhchi.com`). No asset/link breakage risk.
3. **Feature flags**: All major features are properly enabled/disabled; no orphaned flags detected.

## Content Quality

**Missing PDF asset (RESOLVED):**
- Issue: CV page previously linked to non-existent `assets/pdf/cv.pdf`
- Files: `_pages/cv.md`
- Status: FIXED — Page includes conditional check (lines 17-20) that only renders download button and PDF viewer if file exists
- Current behavior: Shows fallback message "My CV is going up here shortly" with links to related content sections
- No further action needed; design is correct

**Visual regression suite is inherited template cruft — will block design PRs (HIGH):**
- Issue: Every spec in `test/visual/` hardcodes the upstream demo's `/al-folio/` baseurl and navigates to demo content this personal site does not have.
- Files: `test/visual/interactions.spec.js` (`/al-folio/`, `/al-folio/blog/`, `/al-folio/teaching/`, `/al-folio/repositories/`, `/al-folio/blog/2023/tables/`, …), `test/visual/distill.spec.js` (`al-folio/blog/2021/distill/`)
- Why it matters now: `_config.yml` leaves `baseurl:` blank (custom domain `phamhakhanhchi.com`), so those paths 404. The pages themselves (blog, teaching, repositories, distill posts) are also absent from this site.
- Trigger overlap with design work: `.github/workflows/visual-regression.yml` fires on PRs to `main` touching `_config.yml`, `_pages/**`, `_data/**`, `assets/**` — precisely the files a background/typography/layout redesign changes. Expect this job to fail on every design PR.
- Options: retarget the specs at this site's real routes and root baseurl, or disable/remove `visual-regression.yml` the same way the integration tests were dropped in commit `81e55bd`.

**`unit-tests.yml` no longer runs the integration tests (LOW — intentional):**
- `.github/workflows/unit-tests.yml` is now named "Style contract" and runs only `npm ci` + `npm run lint:style-contract`; a comment at line 43 records that the seven `test/integration_*.sh` scripts were removed because they assert against upstream demo content.
- `test/` now contains only `style_contract.js` and `visual/`. `AGENTS.md` and `CLAUDE.md` still list all seven scripts as runnable — stale inherited documentation.
- Note `test/style_contract.js` (lines 70-71, 99) is itself annotated as applying to the upstream repo rather than a personal site, so the remaining gate is advisory here.

**Stale inherited template documentation (MEDIUM):**
- `AGENTS.md` and `CLAUDE.md` describe the upstream starter, not this site: they assert the effective baseurl is `/al-folio` (it is empty here), that `_sass/` must not exist (it does, legally, as a local override), and that seven integration tests are CI-gated (they are not).
- Any agent that trusts those files without checking `_config.yml` will produce wrong build commands. This already happened during codebase mapping.

## Fragile Areas

**Visual regression baseline (MEDIUM):**
- Issue: Visual regression tests compare against v0.16.3 baseline, which is ~1.5+ years old
- Files: `.github/workflows/visual-regression.yml` (line 65)
- Impact:
  - Large design changes may require baseline bump, which requires careful manual verification
  - Repository includes a worktree of an old version; ensures reproducibility but increases storage/checkout time
- Mitigation: Current workflow explicitly patches the baseline config to disable `repo_trophies` (lines 83-88), showing that baseline drift is known and managed

---

*Concerns audit: 2026-09-12*

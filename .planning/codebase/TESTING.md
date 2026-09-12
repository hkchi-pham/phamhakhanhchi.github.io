# Testing Patterns

**Analysis Date:** 2026-09-12

## Test Framework

**Visual Regression Runner:**
- Framework: Playwright v1.56.1
- Config: `test/visual/playwright.config.js`
- Browsers: Chromium and WebKit
- Assertion library: @playwright/test

**Run Commands:**
```bash
npx playwright install chromium webkit  # One-time setup
npm run test:visual                    # Run visual regression tests
npm run test:visual:update             # Update snapshots after intentional UI change
```

## Test File Organization

**Location:**
- Visual regression tests: `test/visual/` directory
- Test config: `test/visual/playwright.config.js`
- Helper utilities: `test/visual/helpers.js`

**File Structure:**
```
test/
├── visual/
│   ├── playwright.config.js       # Playwright configuration
│   ├── helpers.js                 # Shared test utilities
│   ├── parity.spec.js             # Visual parity tests
│   ├── interactions.spec.js       # Interactive behavior tests
│   └── distill.spec.js            # Distill-specific tests
├── style_contract.js              # Style contract validation
└── integration_*.sh               # DISABLED (template tests, not used by this site)
```

**Naming Convention:**
- Test files: `*.spec.js` (Playwright convention)
- Tests are organized by concern (parity, interactions, distill)

## Playwright Configuration

**File: `test/visual/playwright.config.js`**

**Test Directory:** `test/visual/` (all `.spec.js` files)

**Timeout Settings:**
- Global test timeout: 120 seconds
- Assertion timeout: 10 seconds

**Screenshot Comparison Settings:**
```javascript
toHaveScreenshot: {
  animations: "disabled",      // Disable animations for determinism
  fullPage: true,              // Capture entire page
  maxDiffPixelRatio: 0.02,      // 2% pixel difference threshold
}
```

**Base URL:** `http://127.0.0.1:4000/al-folio`

**Web Server Configuration:**
- Command: `bundle exec jekyll serve --host 127.0.0.1 --port 4000 --quiet`
- Auto-start: Yes (unless `NO_WEBSERVER=1` env var set)
- Reuse existing server: Yes (except in CI)

**Projects (viewport configurations):**

1. **Desktop:**
   - Viewport: 1366 x 1800
   - Tests responsive layout for large screens

2. **Mobile:**
   - Uses iPhone 12 device profile via `@playwright/test/devices`
   - Tests mobile navigation and responsive behavior

## Visual Regression Testing

### Parity Tests (`test/visual/parity.spec.js`)

**Purpose:** Pixel-diff comparison against v0.16.3 baseline to ensure rendering hasn't regressed.

**Setup:**
- Requires `BASELINE_URL` environment variable (e.g., `http://127.0.0.1:4100`)
- Baseline site (v0.16.3) served on port 4100 via separate Jekyll instance
- Candidate site served on port 4000
- Tests skip silently if `BASELINE_URL` is not set

**Test Routes:**
```javascript
const routes = [
  { path: "al-folio/", id: "home" },
  { path: "al-folio/projects/", id: "projects" },
  { path: "al-folio/publications/", id: "publications" },
  { path: "al-folio/repositories/", id: "repositories" },
];
```

**Test Matrix:**
- For each route, tests run in both light and dark themes
- For each theme, tests run on desktop and mobile viewports
- Total: 4 routes × 2 themes × 2 viewports = 16 test cases

**Diff Thresholds (by route/viewport/theme):**
```javascript
// Default thresholds
desktop: 0.04 (4% pixel difference)
mobile: 0.08 (8% pixel difference)

// Custom thresholds (higher variance)
publications mobile: 0.26
repositories desktop dark: 0.07
repositories mobile dark: 0.14  // Raised when trophies disabled
```

**Deterministic Fixtures:**

The helpers stabilize non-deterministic external resources:

1. **Repository Statistics:**
   - URL: `github-stats-extended.vercel.app` (also accepts deprecated `github-readme-stats.vercel.app`)
   - Stub: SVG with "Repository Stats (stub)" text
   - Reason: Stats are fetched from GitHub API and change over time

2. **Repository Trophies:**
   - URL: `github-profile-trophy.vercel.app`
   - Stub: Dark-themed SVG with "Repository Trophies (stub)" text
   - Note: Disabled by default (`repo_trophies.enabled: false`) because free tier now returns HTTP 402

3. **Blocked Domains:**
   ```javascript
   BLOCKED_DOMAINS: [
     "google-analytics.com",
     "plausible.io",
     "badge.dimensions.ai",
     "cartocdn.com",
     "openstreetmap.org",
     "stadiamaps.com",
     "mapbox.com"
   ]
   BLOCKED_HOST_PREFIXES: ["stamen-tiles"]
   ```
   - Reason: Analytics, embeds, and map tiles are non-deterministic or unreliable

### Interaction Tests (`test/visual/interactions.spec.js`)

**Purpose:** Verify interactive features work correctly (not visual diffing).

**Test Examples:**

1. **Publications Abstract Toggle:**
   ```javascript
   test("publications Abs toggle opens and closes", async ({ page }) => {
     await preparePage(page, "light");
     await page.goto("/al-folio/publications/", { waitUntil: "networkidle" });
     await stabilizeVisuals(page);
     
     const absButton = page.getByRole("button", { name: "Abs" }).first();
     const panel = page.locator(".abstract.hidden").first();
     
     await absButton.click();
     await expect(panel).toHaveClass(/open/);
   });
   ```

2. **Publication Popover:**
   - Tests popover display without Bootstrap compatibility layer
   - Verifies `.af-popover` becomes visible on hover

3. **Mobile Navigation:**
   - Skipped on desktop (`test.skip(testInfo.project.name !== "mobile", ...)`)
   - Tests `.navbar-toggler` click expands `.navbar-collapse`

4. **Repositories Page Stats Cards:**
   - Verifies stat card images load (`img[src*="github-stats-extended"]`)
   - Asserts trophy markup absent when disabled (`repo_trophies.enabled: false`)
   - Guards against regression if config default changes

5. **Blog Pagination:**
   - Tests `.af-pagination` renders with Tailwind styling
   - Verifies core styling contract

### Distill Tests (`test/visual/distill.spec.js`)

**Purpose:** Verify Distill article rendering (if used).

## Test Helpers (`test/visual/helpers.js`)

### `preparePage(page, themeSetting)`
- Sets theme in localStorage before page load
- Applies network stubs for deterministic rendering
- Parameters: `page` (Playwright Page), `themeSetting` ("light" or "dark")

### `applyNetworkStubs(page)`
- Routes network requests to block non-deterministic domains
- Intercepts GitHub stat/trophy API calls and returns SVG stubs
- Blocks analytics, map tile providers, and external embeds

### `stabilizeVisuals(page)`
- Disables all animations and transitions (`animation-duration: 0ms`)
- Hides dynamic embeds (Altmetric, Dimensions, Giscus comments, cookie banner)
- Runs before screenshot capture to ensure determinism

### `compareWithBaseline(context, currentPage, route, themeSetting)`
- Captures full-page screenshot from candidate site
- Captures same route from baseline site (via `BASELINE_URL`)
- Compares using `diffRatio()` with pixelmatch
- Returns pixel difference ratio (0 = identical, 1 = completely different)
- Handles oversized pages (> 32760 px) by clipping to viewport

### `diffRatio(actualPng, baselinePng)`
- Uses pixelmatch library with `threshold: 0.1` and `includeAA: false`
- Returns ratio: `changed_pixels / (width × height)`
- Normalizes mismatched dimensions by using minimum of both

## Formatting and Linting

### Prettier Check (`npm run lint:prettier`)

**File: `.github/workflows/prettier.yml`**

- Runs on: Every push and PR to main
- Tool: Prettier v3.8.0
- Config: `.prettierrc` (printWidth: 150, plugin: `@shopify/prettier-plugin-liquid`)
- Failure action: Creates HTML diff artifact for review

### Style Contract (`npm run lint:style-contract`)

**File: `test/style_contract.js`**

- Validates theme pin (`al_folio_core`)
- Validates required plugins in both `Gemfile` and `_config.yml`
- Validates SRI hashes for third-party libraries
- Validates `al_math` gem version pinning
- Rejects forbidden build scripts
- Rejects icon font artifacts

## CI Workflows

### `unit-tests.yml` (Workflow: Style contract)

**Trigger:** Push/PR to main/master/v1.0-dev when:
- `Gemfile`, `Gemfile.lock`, `_config.yml`, `_data/**`, `_pages/**`, `_posts/**`, `_projects/**`
- `assets/**`, `test/**`, `package.json`, `package-lock.json` change

**Status:** 
- ✓ **ACTIVE**
- Runs: Style contract check only
- **DISABLED:** The seven `test/integration_*.sh` scripts were removed because this site deleted the template's demo content (`blog/2022/giscus-comments`, etc.). See comment in `unit-tests.yml` lines 43-47.

**Steps:**
1. Checkout
2. Setup Node.js 20 (with npm cache)
3. Run `npm ci`
4. Run `npm run lint:style-contract`

### `prettier.yml` (Workflow: Prettier code formatter)

**Trigger:** Push/PR to main/master

**Status:** ✓ **ACTIVE**

**Steps:**
1. Checkout
2. Setup Node.js
3. Install Prettier and `@shopify/prettier-plugin-liquid`
4. Check formatting with `npx prettier . --check`
5. If failure: generate HTML diff and upload as artifact
6. If PR failure: dispatch repository event for comment

### `visual-regression.yml` (Workflow: Visual regression checks)

**Trigger:** 
- PR to main/master/v1.0-dev with changes to:
  - `_config.yml`, `_data/**`, `_bibliography/**`, `_pages/**`, `_posts/**`, `_projects/**`
  - `assets/**`, `test/visual/**`, `Gemfile`, `Gemfile.lock`, `package.json`, `package-lock.json`
- OR push to v1.0-dev with same file patterns

**Status:** ✓ **ACTIVE**

**Timeout:** 20 minutes

**Environment Setup:**
1. Checkout candidate (fetch-depth 0 for baseline worktree)
2. Setup Ruby 3.3.5 with bundler cache
3. Setup Node 20 with npm cache
4. Install npm deps with `npm ci`
5. Prepare baseline worktree at `../al-folio-baseline` tag `v0.16.3`
   - Bundles and installs npm deps
   - **Patches config:** Disables `repo_trophies` (enabled in v0.16.3, off by default now)
   - Reason: Trophies now return HTTP 402 (free tier disabled)
6. Install system deps: ImageMagick, Jupyter, nbconvert
7. Install Playwright browsers: chromium, webkit with dependencies

**Test Execution:**
```bash
# Baseline on port 4100, candidate on port 4000
(cd ../al-folio-baseline && bundle exec jekyll serve --port 4100) &
bundle exec jekyll serve --port 4000 &

# Wait for both servers (150 attempts, 2s sleep = 5 min timeout)
# Then run Playwright tests with BASELINE_URL=http://127.0.0.1:4100
npm run test:visual -- --reporter=line
```

**Artifacts:**
- `playwright-report/` — Playwright test report (HTML)
- `/tmp/jekyll-*.log` — Jekyll build logs from both sides

### `update-tocs.yml` (Workflow: Update TOCs)

**Trigger:** Push to main/master when `.md` files in root or `docs/` change

**Status:** ✓ **ACTIVE**

**Steps:**
1. Checkout with full history
2. Setup Node.js
3. Get list of changed `.md` files
4. Run `gh-md-toc` with `--indent 2 --insert --no-backup --hide-footer`
5. Run Prettier to normalize TOC formatting (Prettier and gh-md-toc disagree on escaping)
6. Auto-commit with message "Auto update markdown TOC"

### Other Active Workflows

- `deploy.yml` — Production deployment to gh-pages
- `prettier-html.yml` — HTML formatting checks
- `upgrade-check.yml` — `bundle exec al-folio upgrade audit`
- `axe.yml` — Accessibility checks
- `broken-links-site.yml` — Link validation
- `codeql.yml` — Security analysis

## Local Development Testing

**Before pushing, run locally:**

```bash
bundle install                      # Ruby gems
npm ci                             # npm deps from lockfile

npm run lint:prettier              # Check formatting
npm run lint:style-contract        # Check style contract

bundle exec jekyll build  # Build with correct baseurl

npx playwright install chromium webkit  # One-time: install browsers
npm run test:visual                # Run visual regression tests
npm run test:visual:update         # Update snapshots after intentional change
```

**Full validation sequence (from AGENTS.md):**

```bash
bundle install
npm ci
npm run lint:prettier
npm run lint:style-contract
bundle exec jekyll build
npx playwright install chromium webkit
npm run test:visual
bundle exec al-folio upgrade audit
docker compose up -d
curl -fsS http://127.0.0.1:8080/ >/dev/null
docker compose logs --tail=80
docker compose down
```

## Test Coverage and Gaps

**What's Tested:**
- Visual rendering parity against v0.16.3 baseline (light/dark, desktop/mobile)
- Interactive features (toggles, popovers, navigation)
- Style contract compliance (theme, plugins, SRI, al_math version)
- Code formatting with Prettier
- TOC auto-generation in Markdown
- Accessibility (via axe.yml)
- Broken links (via broken-links-site.yml)

**What's NOT Tested (by design):**
- Unit tests for components (owned by gem repos)
- Integration tests for template demo content (this site has no demo content)
- Backend logic (static site only)
- E2E user flows (visual tests provide this coverage)

**Why 7 integration scripts were disabled:**
- Template tests in `test/integration_*.sh` assert against demo blog posts, categories, and distill articles
- This site deleted those demo posts (`blog/2015/rtl`, `blog/2022/giscus-comments`, etc.)
- Tests would fail because fixture content is gone
- Each test checked specific plugin behavior; this site doesn't need them
- Disabled, not removed, because overrides can re-enable if needed

---

*Testing analysis: 2026-09-12*

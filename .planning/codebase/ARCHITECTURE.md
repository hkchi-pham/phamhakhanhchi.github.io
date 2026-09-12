# Architecture

**Analysis Date:** 2026-09-12

## Pattern Overview

**Overall:** Thin Jekyll starter with gem-delegated runtime

`al-folio` v1.x is a thin Jekyll starter, NOT a full theme. All runtime code (layouts, includes, Sass, Liquid tags, filters, and feature JavaScript) lives in independently versioned gems published under the `al-org-dev` organization and installed via `Gemfile` + `_config.yml` plugin list.

**Key Characteristics:**
- This repo owns only starter wiring (`Gemfile`, `_config.yml`), example content collections, documentation, and cross-gem integration tests
- All layouts come from `al_folio_core` gem (set as `theme: al_folio_core` in `_config.yml`)
- Feature behavior is delegated to specialized gems: `al_folio_cv`, `al_folio_distill`, `al_search`, `al_analytics`, `al_math`, etc.
- Local overrides supported: this site maintains `assets/css/main.scss` (tracked in `.al-folio-overrides.yml`) and `_sass/_custom.scss` for site-specific styling
- **Baseurl is empty (site root).** Unlike the upstream al-folio demo, this is a personal site on a custom domain: `_config.yml` sets `url: https://phamhakhanhchi.com` and leaves `baseurl:` blank, with `CNAME` holding `phamhakhanhchi.com`. The `/al-folio` baseurl described in `AGENTS.md` / `CLAUDE.md` is inherited template documentation and does **not** apply to this checkout.

## Layers

**Content Layer (`_pages`, `_posts`, `_projects`, `_data`):**
- Purpose: Author personal content, data, and configuration
- Location: `_pages/`, `_posts/`, `_projects/`, `_data/`
- Contains: Markdown pages with YAML front matter, Jekyll collections, YAML data files
- Depends on: Layouts from gem themes, filters/tags from gem plugins
- Used by: Jekyll build pipeline to generate HTML pages

**Wiring Layer (`Gemfile`, `_config.yml`, `_data/featured_plugins.yml`):**
- Purpose: Configure gem dependencies, plugin activation, feature flags, and third-party library SRI hashes
- Location: `Gemfile`, `_config.yml`, `_data/featured_plugins.yml`
- Contains: Ruby gem dependencies, Jekyll configuration, plugin lists, feature toggles, library versions
- Depends on: RubyGems registry, al-org-dev gem releases
- Used by: Bundler (Gemfile), Jekyll build (\_config.yml), theme rendering (plugins)

**Runtime Layer (in gems):**
- Purpose: Render pages, apply styles, execute Liquid tags, handle analytics/comments/search
- Location: Provided by `al_folio_core` (layouts/includes/base styles), `al_folio_cv`, `al_folio_distill`, `al_search`, `al_analytics`, `al_comments`, `al_math`, `al_charts`, etc.
- Contains: Liquid templates, JavaScript, CSS/Tailwind (in gems, not here)
- Depends on: This repo's `_config.yml` feature flags and front matter on pages
- Used by: Jekyll renderer; delivered as built HTML + CSS + JS

**Local Override Layer (`assets/css/main.scss`, `_sass/_custom.scss`):**
- Purpose: Shadow gem-owned files for site-specific styling customizations
- Location: `assets/css/main.scss` (copy of gem's file with one added `@use "custom";` line), `_sass/_custom.scss` (site overrides)
- Contains: SCSS/CSS modifications
- Depends on: Gem versions listed in `Gemfile` and `.al-folio-overrides.yml`
- Used by: Jekyll Sass processor to compile final CSS with site customizations winning on specificity

**Documentation & Testing Layer (`docs/`, `test/`):**
- Purpose: Maintain contributor guides, architecture docs, integration tests, visual regression baseline
- Location: `docs/`, `test/integration_*.sh`, `test/visual/`, `test/style_contract.js`
- Contains: Markdown guides, shell test scripts, Playwright visual snapshots
- Depends on: Nothing; docs are read-only, tests run against this repo's output
- Used by: Contributors, CI gates (`unit-tests.yml`, `visual-regression.yml`, `style-contract.yml`)

## Data Flow

**Page Rendering Flow:**

1. Jekyll discovers a page in `_pages/about.md` with `layout: about` front matter
2. Jekyll loads `_config.yml`, finds `theme: al_folio_core` and `plugins: [al_folio_core, al_icons, ...]`
3. For each activated plugin (if feature flag is on), Jekyll calls the plugin's generators
   - `al_folio_core` generator: Ships base CSS (Tailwind-compiled), base JS
   - `al_search` generator: Builds search index from content
   - `al_analytics` generator: Injects analytics script tags (if `analytics:` configured)
   - Other feature generators: Inject feature-specific JS/CSS only when their flag is on
4. Jekyll resolves `layout: about` → loads `_layouts/about.liquid` from `al_folio_core` gem
5. Layout renders page body, calls `{% include "plugins/search.liquid" %}` and other plugin wrappers
6. Plugin wrappers check feature flags in `_config.yml` and page front matter; emit empty string if disabled
7. If enabled, plugin wrappers call custom Liquid tags from sibling gems (e.g., `{% al_search_assets %}` from `al_search` gem)
8. Jekyll processes Sass: reads `assets/css/main.scss` → resolves `@use` imports from gem's `_sass/` → pulls in `_sass/_custom.scss` last (site overrides)
9. Final HTML + CSS + JS delivered to `_site/`

**State Management:**
- Feature state: Stored in `_config.yml` (site-wide flags like `enable_math: true`, `search_enabled: true`) and page front matter (e.g., `tikzjax: true`, `giscus_comments: true`)
- No runtime state management; all state resolves at build time
- Build outputs static HTML/CSS/JS only — no client-side app state

## Key Abstractions

**Plugin Wrapper Pattern (`_includes/plugins/*.liquid` in al_folio_core):**
- Purpose: Delegate feature rendering to sibling gems while handling feature gating
- Examples: `_includes/plugins/search.liquid`, `_includes/plugins/comments.liquid`, `_includes/plugins/math.liquid`
- Pattern: Each wrapper checks if gem is loaded and flag is on; calls the gem's custom Liquid tag only if both are true; otherwise emits empty string
- Why it matters: Features fail silently (see failure modes below) — wrappers enable graceful degradation

**Local Override Convention:**
- Pattern: Site shadows gem-owned files by creating matching paths locally (e.g., `assets/css/main.scss`)
- Tracking: `.al-folio-overrides.yml` records upstream gem, version, SHA256 hashes to detect drift
- Enforcement: `bundle exec al-folio upgrade overrides audit` flags when upstream file changes; `bundle exec al-folio upgrade overrides diff <path>` shows diff; `accept <path>` acknowledges override
- Only for this personal site — the `al-folio` starter repo itself must not contain gem-owned files per stop-sign rule

**Collection-to-Layout Mapping:**
- `_pages/` → `layout: about | page | cv | distill` → `al_folio_core` provides base layouts, `al_folio_cv` provides `layout: cv`, `al_folio_distill` provides `layout: distill`
- `_projects/` → `layout: page` → rendered as project cards on projects page
- `_bibliography/` → processed by `jekyll-scholar` plugin with `bib.liquid` template (from gem)

## Entry Points

**Build Entry Point (`bundle exec jekyll build`):**
- Location: `Gemfile` (defines Ruby gem dependencies) + `_config.yml` (Jekyll configuration)
- Triggers: Developer runs build command, or CI runs `deploy.yml` / `unit-tests.yml`
- Responsibilities:
  1. Bundler resolves `Gemfile` → installs/updates gems
  2. Jekyll reads `_config.yml` → loads plugins in order, applies feature flags
  3. Jekyll discovers collections: `_pages/`, `_posts/`, `_projects/`, `_bibliography/`
  4. Plugins generate assets (CSS, JS indexes, citation badges)
  5. Content renders through theme layouts with Sass processed
  6. Output written to `_site/` (or `docker compose` writes to container-local `/tmp/_site`)

**Docker Entry Point (`bin/entry_point.sh`):**
- Location: `bin/entry_point.sh` (bash script)
- Triggers: `docker compose up -d`
- Responsibilities:
  1. Manage Gemfile.lock (restore if tracked, delete if not)
  2. Ensure bundler dependencies are installed
  3. Start Jekyll serve with:
     - `--destination /tmp/_site` (container-local, not bind-mounted to avoid deadlocks)
     - `--force_polling` (required for Docker on some systems)
     - `--livereload --watch`
  4. Watch `_config.yml` for changes; restart Jekyll if detected (config changes aren't hot-reloaded)
  5. Serve at `http://127.0.0.1:8080/` (note baseurl in path)

**CI Gates:**
- `npm run lint:style-contract` (enforces no gem-owned paths exist here)
- `unit-tests.yml` (style contract + 7 integration tests)
- `visual-regression.yml` (Playwright diffing candidate vs. v0.16.3 baseline)
- `upgrade-check.yml` (runs `bundle exec al-folio upgrade audit`)
- `prettier.yml` (Prettier with `@shopify/prettier-plugin-liquid`)

## Error Handling

**Strategy:** Build-time and runtime feature gating with silent degradation

**Patterns:**

1. **Feature Disabled:** If feature flag is off (in `_config.yml` or page front matter), the plugin wrapper emits empty string — no error, no placeholder. Example: `enable_math: false` → math typesetting tags produce no output.

2. **Gem Not Loaded:** If gem is not in both `Gemfile` AND `_config.yml` plugins list, Jekyll never loads it, and plugin wrappers detect this and emit empty string. Two-step activation required to avoid silent failures from partial edits.

3. **Missing Asset:** If SRI hash is missing for a third-party library, the library is not loaded (security check). Wrappers emit empty string.

4. **Malformed YAML:** Jekyll exits with clear error; build fails.

5. **Missing Layout/Include in Gem:** Jekyll exits with "Liquid Error: undefined layout" or similar. This is rare because all layouts ship in gems.

## Cross-Cutting Concerns

**Logging:** 
- Gem build output logged by Jekyll (verbose flag: `bundle exec jekyll build --trace`)
- CI logs in GitHub Actions workflow files (`.github/workflows/`)
- Docker logs: `docker compose logs --tail=80`

**Validation:**
- Plugin pins must match in `Gemfile` and `_config.yml` (enforced by `npm run lint:style-contract`)
- `al_folio` config contract must be present (enforced by `bundle exec al-folio upgrade audit`)
- No gem-owned paths allowed in starter (enforced by `npm run lint:style-contract`)

**Authentication/Secrets:**
- Credentials stored in environment variables (GitHub Secrets in CI, `.env` local, not committed)
- Analytics provider IDs in `_config.yml` (public; API keys in env vars)
- Giscus repo/category in `_config.yml` (public; access managed by GitHub organization permissions)

**Feature Gating:**
- Two-layer system: site-wide `_config.yml` flags (`enable_math`, `search_enabled`, `enable_darkmode`, etc.) AND per-page front matter (`tikzjax: true`, `giscus_comments: true`)
- Both must be true for feature to render
- Allows experiments (e.g., enable math site-wide but disable on specific pages for performance)

## Local Overrides in This Site

**What's Overridden:**

1. `assets/css/main.scss` — Tracked override in `.al-folio-overrides.yml`
   - Owner: `al_folio_core` v1.0.15
   - Purpose: Main CSS entry point; locally is a copy of gem's file with added `@use "custom";` to import site customizations
   - Last acknowledged: 2026-09-10
   - Current upstream SHA: `437c6c911c596391413e435dc0ea7095e682e85c572c1fd3fff69f9597455b3e`
   - Current local SHA: `e51ec6fb5bd4afc4444b1acbabdedbb51e573652e527fcb50c560c52347735ac` (drift present — downstream has overridden or customized this file)

2. `_sass/_custom.scss` — Tracked in git, but NOT acknowledged in `.al-folio-overrides.yml`
   - Committed to the repo (working tree is clean), yet absent from the override manifest — run `bundle exec al-folio upgrade overrides audit` to register it
   - Note: `_sass/` is a stop-sign path in `AGENTS.md`; that restriction applies to the upstream starter repo only. A personal site built from the template may legally shadow gem-owned Sass (see `docs/ARCHITECTURE.md` → local overrides)
   - Purpose: Site-specific SCSS customizations applied after all gem Sass imports
   - Contains: Custom styles for `.entry`, `.entry-list`, `.subject-list`, typography overrides
   - Scope: Intentionally minimal — only fixes specificity issues and adds basic entry list styling; real design pass should replace wholesale

**Overrides Not Present:**
- `_layouts/` — No local overrides; all layouts come from gems
- `_includes/` — No local overrides; all includes come from gems
- `_scripts/` — Not present (Tailwind v4 ships prebuilt CSS in gem; no local JS build pipeline)
- `assets/tailwind/` — Not present (CSS entry is `assets/css/main.scss`, not Tailwind)
- `tailwind.config.js` — Not present (Tailwind configured in gem)

## Three Silent Failures

**1. Features Fail Silently:**
A feature renders only when:
- Its gem is in both `Gemfile` AND `_config.yml` plugins list, AND
- Its site-wide config flag is on (e.g., `enable_math: true`), AND
- Its page front matter opts in (e.g., page has `tikzjax: true` or layout is `layout: cv`)

If any condition fails, the feature's Liquid tag emits an empty string — no warning, no error, no visual placeholder.

**When debugging a missing feature:**
1. Check `Gemfile` + `_config.yml` plugin list (both must have gem, using underscores in plugin ids)
2. Check site-wide flag in `_config.yml` (e.g., `enable_math`, `search_enabled`)
3. Check page front matter (e.g., `tikzjax: true`, `giscus_comments: true`)
4. Check `third_party_libraries:` block in `_config.yml` for SRI hash (required for CDN-loaded libs)

**2. Gemfile and _config.yml Are Two Lists That Must Agree:**
Plugin activation requires **two edits**:
- `Gemfile`, `group :al_folio_plugins`: `gem 'al_folio_core', '= 1.0.15'`
- `_config.yml`, `plugins:`: `- al_folio_core`

A gem in only one is inert. Adding or removing a plugin means editing both.

**Note:** Repo directories use hyphens (`al-folio-core` in GitHub URLs), but gem/plugin IDs use underscores (`al_folio_core` in Gemfile and `_config.yml`).

**3. Baseurl Is Empty — Site Serves From Root:**
`_config.yml` line 22-23 sets `url: https://phamhakhanhchi.com` and leaves `baseurl:` blank; `CNAME` contains `phamhakhanhchi.com`. All paths (CSS, JS, internal links) resolve from the domain root.

- Plain `bundle exec jekyll build` uses the configured (empty) baseurl → correct
- Passing `--baseurl /al-folio` would **break** this site — that flag belongs to the upstream al-folio demo, which is a GitHub project page at `https://alshedivat.github.io/al-folio/`
- `AGENTS.md` and `CLAUDE.md` still document the `/al-folio` baseurl; treat that as stale inherited template text for this repo
- Dev server is at `http://localhost:4000/`


---

*Architecture analysis: 2026-09-12*

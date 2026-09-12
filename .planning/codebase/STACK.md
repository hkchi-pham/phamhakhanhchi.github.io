# Technology Stack

**Analysis Date:** 2026-09-12

## Languages

**Primary:**
- Ruby 3.3.5 - Jekyll runtime, gem execution, site building
- Liquid - Template language for page rendering (Jekyll standard)

**Secondary:**
- JavaScript (Node 20) - Linting, testing, build tooling
- CSS/SCSS - Styling (compiled and minimized)
- Python 3.13+ - Optional dependencies for Jupyter notebooks and CV rendering

**Markup:**
- Markdown (GFM) - Content authoring (posts, pages, projects)
- YAML - Configuration and data files
- HTML - Template output, static content

## Runtime

**Environment:**
- Ruby 3.3.5 (specified in `.github/workflows/deploy.yml`)
- Node.js 20 (specified in `.github/workflows/deploy.yml`)
- Python 3.13 (specified in `.github/workflows/deploy.yml`)

**Package Managers:**
- Bundler - Ruby gem dependency management (lockfile: `Gemfile.lock`)
- npm - JavaScript/Node dependencies (lockfile: `package-lock.json`)
- pip - Python package management (optional, for `requirements.txt`)

## Frameworks

**Core:**
- Jekyll 4.x - Static site generator
- al-folio v1.x - Portfolio/academic starter kit (thin wrapper, not a theme)

**al-folio Plugin Gems (exact versions from `Gemfile`):**

Core infrastructure:
- `al_folio_core` 1.0.15 - Base layouts, includes, Sass/CSS, Liquid tags, filters
- `al_folio_upgrade` 1.0.3 - Upgrade audit and migration CLI
- `al_folio_bootstrap_compat` 1.0.0 - Legacy Bootstrap compatibility (opt-in, time-boxed through v1.2)
- `al_icons` 1.0.0 - Icon library loading (Font Awesome, Academicons, Scholar Icons)

Feature plugins:
- `al_folio_cv` 1.0.2 - CV rendering from RenderCV YAML/JSONResume
- `al_folio_distill` 1.0.3 - Distill article layouts
- `al_search` 1.0.3 - Search UI (Cmd-K ninja-keys palette)
- `al_analytics` 1.0.2 - Analytics provider integration (GA/Cronitor/Pirsch/OpenPanel)
- `al_comments` 1.0.0 - Comment systems (Giscus/Disqus)
- `al_cookie` 1.0.1 - Cookie consent and consent-mode gating
- `al_math` 1.0.2 - Math typesetting (MathJax, TikZJax, pseudocode.js)
- `al_charts` 1.0.1 - Chart rendering (Mermaid/Chart.js/ECharts/Plotly/Vega/Leaflet/diff2html)
- `al_img_tools` 1.0.3 - Image manipulation (zoom, lightbox, sliders, galleries)
- `al_newsletter` 1.0.0 - Newsletter signup (Loops.so)
- `al_citations` 1.0.1 - Publication citation badges (Google Scholar, Altmetric, Dimensions, Inspire HEP)
- `al_ext_posts` 1.0.3 - External post ingestion from RSS/URLs
- `al_email_protect` 1.0.1 - Email obfuscation and click-to-copy addresses
- `al_marimo` 1.0.0 - marimo notebook embeds
- `al_rtl` 1.0.0 - Right-to-left language support

**Jekyll Core Plugins (from `Gemfile`):**
- `jekyll-3rd-party-libraries` - CDN library management with SRI integrity hashes
- `jekyll-archives-v2` - Blog archive generation (disabled for this site, no blog)
- `jekyll-cache-bust` - Asset cache-busting
- `jekyll-email-protect` - Email address protection
- `jekyll-feed` - RSS feed generation
- `jekyll-get-json` - External JSON data fetching
- `jekyll-imagemagick` - Responsive image generation (requires ImageMagick on PATH)
- `jekyll-jupyter-notebook` - Jupyter notebook rendering (optional Python install)
- `jekyll-link-attributes` - External link attribute injection
- `jekyll-minifier` - HTML/CSS/JS minification (JS delegated to Terser)
- `jekyll-paginate-v2` - Pagination
- `jekyll-regex-replace` - Content regex replacement
- `jekyll-scholar` - BibTeX bibliography processing
- `jekyll-sitemap` - XML sitemap generation
- `jekyll-socials` - Social media link rendering
- `jekyll-tabs` - Tabbed content blocks
- `jekyll-terser` (custom git fork) - JavaScript minification
- `jekyll-toc` - Table of contents generation
- `jekyll-twitter-plugin` - Twitter embed support
- `jemoji` - GitHub emoji support

Support gems:
- `classifier-reborn` 2.3.0 - Content categorization
- `css_parser` 1.22.0 - CSS parsing
- `observer` - Required by jekyll-scholar
- `ostruct` - Required by jekyll-twitter-plugin

**Testing:**
- Playwright ^1.56.1 - Visual regression testing (chromium, webkit)
- Node utilities: `pixelmatch` 7.1.0, `pngjs` 7.0.0 - Image diff testing

**Linting & Formatting:**
- Prettier 3.8.0 - Code formatter
- @shopify/prettier-plugin-liquid 1.10.0 - Liquid template support for Prettier

## Configuration

**Build Config:**
- `_config.yml` - Main Jekyll configuration
  - `al_folio` API contract keys (v1, tailwind style engine, Tailwind 4.1.18)
  - Plugin activation and feature flags
  - Third-party library CDN URLs with SRI integrity hashes (35+ libraries pinned)
  - Jekyll build settings (Kramdown markdown, rouge syntax highlighting)
  - Image responsive settings (ImageMagick enabled, widths: 480/800/1400px, WebP output)
- `Gemfile` - Ruby gem dependencies (must match `plugins:` list in `_config.yml`)
- `.prettierrc` implied by npm scripts - Prettier config (printWidth: 150, @shopify/prettier-plugin-liquid)
- `docker-compose.yml` - Docker development environment (Ruby image: `amirpourmand/al-folio:latest`)

**Tailwind CSS:**
- Style engine: Tailwind v4.1.18
- Entry point: `assets/tailwind/app.css`
- Preflight disabled
- No local `tailwind.config.js` or `assets/tailwind/` allowed in starter (enforced by `npm run lint:style-contract`)

**Build Outputs:**
- Destination: `_site/` (local) or `/tmp/_site` (Docker)
- CSS: Tailwind minified + Sass compressed
- JS: Terser minified
- HTML: jekyll-minifier (HTML compression only, not CSS/JS)

## Platform Requirements

**Development:**
- Git
- Ruby 3.3.5
- Node.js 20
- Python 3.13 (optional, for Jupyter notebooks)
- ImageMagick (optional, for responsive images; requires `convert` on PATH)
- Docker (optional, for containerized development)

**Production:**
- GitHub Pages hosting (custom domain: `phamhakhanhchi.com` via `CNAME`)
- GitHub Actions for CI/CD
- Hosted on GitHub infrastructure

## Build & Serve Commands

**Local development:**
```bash
bundle install                    # Install Ruby gems
npm ci                           # Install JavaScript deps
bundle exec jekyll serve         # Dev server with live reload (http://localhost:4000)
bundle exec jekyll build  # Production-style build
```

**Linting/Formatting:**
```bash
npm run lint:prettier            # Check formatting with Prettier
npm run lint:style-contract      # Enforce starter boundary (no _layouts, _includes, etc)
```

**Testing:**
```bash
npm run test:visual              # Run visual regression tests (Playwright)
npm run test:visual:update       # Update Playwright snapshots after intentional changes
bash test/integration_distill.sh # Run one of seven integration test suites
```

**Optional Python setup:**
```bash
bin/setup-python-deps            # Install Jupyter + nbconvert (user-level, --break-system-packages)
pip3 install -r requirements.txt  # Install all Python deps (nbconvert, pyyaml, rendercv[full], scholarly)
```

**Deployment:**
```bash
npm install -g purgecss          # One-time global install
npm run build                    # Not used (CI runs build via Jekyll)
bin/deploy                       # Manual gh-pages deploy + purgecss + force-push (CI normally deploys)
```

**Docker:**
```bash
docker compose up -d             # Start container (serves from /srv/jekyll, outputs to /tmp/_site)
curl -fsS http://127.0.0.1:8080/  # Verify container (note baseurl)
docker compose down
```

**Upgrade tools:**
```bash
bundle exec al-folio upgrade audit           # Check for breaking changes
bundle exec al-folio upgrade report          # Get migration report
bundle exec al-folio upgrade apply --safe    # Apply deterministic codemods
bundle exec al-folio upgrade overrides audit # Track local file overrides
```

## Key Dependencies (Selected)

**Critical gems:**
- `jekyll` 4.x - Static site generation
- `liquid` 4.0-6.0 - Template engine
- `kramdown` - Markdown processor
- `rouge` - Syntax highlighting
- `bibtex-ruby` 6.2.0 - Bibliography parsing (required by jekyll-scholar)
- `citeproc-ruby` 2.1.8 - Citation formatting

**External data fetching:**
- `feedjira` 4.0.2 - RSS feed parsing (for external posts)
- `httparty` 0.18-1.0 - HTTP client (for external posts)
- `nokogiri` 1.13-2.0 - HTML/XML parsing (multiple uses)

**JavaScript bundling (optional, not currently used):**
- `terser` 1.0+ - JavaScript minification (via jekyll-terser)

**Utility gems:**
- `activesupport` 7.2.3.1 - Core Ruby extensions
- `addressable` 2.9.0 - URI parsing
- `deep_merge` 1.2.2 - Hash operations

---

*Stack analysis: 2026-09-12*

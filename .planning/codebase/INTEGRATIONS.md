# External Integrations

**Analysis Date:** 2026-09-12

## Hosting & Deployment

**GitHub Pages:**
- Domain: `phamhakhanhchi.com` (custom domain via `CNAME` file)
- Deployment method: GitHub Actions workflow (`deploy.yml`)
- Branch trigger: push to `main` or `master` (or manual dispatch)
- Deployment action: JamesIves/github-pages-deploy-action v4
- Build environment: Ubuntu latest
- Output directory: `_site/` (deployed to `gh-pages` branch)

**GitHub Actions CI/CD:**
- Workflow file: `.github/workflows/deploy.yml`
- Triggers: push to main/master, pull_request, workflow_dispatch
- Ruby setup: ruby/setup-ruby v1 with bundler cache
- Python setup: actions/setup-python v5 with pip cache
- Node setup: actions/setup-node v4 with npm cache
- Steps:
  1. Checkout repository
  2. Setup Ruby 3.3.5
  3. Setup Python 3.13
  4. Setup Node 20
  5. Install JS dependencies (`npm ci`)
  6. Update giscus repo config via yaml-update-action (auto-fills `giscus.repo` from `${{ github.repository }}`)
  7. Install system dependencies (ImageMagick via `apt-get`)
  8. Build Jekyll site in production mode
  9. Purge unused CSS with purgecss
  10. Deploy to GitHub Pages (skipped for pull_request events)

**Other CI Workflows (present but not active in this checkout):**
- `axe.yml` - Accessibility testing
- `broken-links-site.yml` - Link validation
- `codeql.yml` - Code security analysis
- `lighthouse-badger.yml` - Performance metrics
- `prettier.yml` - Code formatting enforcement
- `docker-slim.yml` - Lightweight Docker image builds
- `deploy-image.yml`, `deploy-docker-tag.yml` - Docker image publishing (starter-level)

## Data Storage

**No external database or backend:**
- Static site — all content in version control
- Bibliography source: `_bibliography/papers.bib` (BibTeX)
- Content collections: `_pages/`, `_posts/`, `_projects/`
- JSON data: `assets/json/resume.json` (read by jekyll-get-json)
- YAML data files: `_data/socials.yml`, `_data/academics.yml`, `_data/research.yml`, `_data/activities.yml`, `_data/further_reading.yml`

**File Storage:**
- Local filesystem only
- Assets: `assets/img/` (image optimization via ImageMagick)
- PDFs/documents: `assets/pdf/` (referenced in CV, footer)
- Fonts: Via CDN only (no local font serving)

## Content & Data Sources

**Bibliography Management:**
- Tool: jekyll-scholar with BibTeX
- Source: `_bibliography/papers.bib`
- Format: BibTeX entries
- Citation styles: APA (configurable in `_config.yml` via `scholar.style`)

**External Post Ingestion:**
- Plugin: `al_ext_posts`
- Disabled in this checkout (commented out in `_config.yml`)
- Previously could fetch from: RSS feeds (e.g., Medium), Google Blog

**Resume/CV Data:**
- Source: `assets/json/resume.json`
- Processing: jekyll-get-json (reads JSON at build time)
- Rendering: RenderCV integration via `al_folio_cv` gem (for `layout: cv` pages)
- Sections: basics, work, education, publications, projects, volunteer, awards, certificates, skills, languages, interests, references (controlled by `jsonresume:` keys in `_config.yml`)

**Social Media Links:**
- Source: `_data/socials.yml`
- Email: khanhchi.phamha@gmail.com (configured, no external email service)
- Optional integrations (currently disabled/commented): GitHub, LinkedIn, WhatsApp, WeChat QR, Google Scholar, Inspire HEP
- Rendering plugin: jekyll-socials

## Analytics & Monitoring

**Analytics Providers (all disabled in `_config.yml`):**
- Google Analytics: Not configured (env var: `analytics.google`, format: G-XXXXXXXXXX)
- Cronitor RUM: Not configured (env var: `analytics.cronitor`, format: XXXXXXXXX)
- Pirsch Analytics: Not configured (env var: `analytics.pirsch`, 32-char ID)
- Openpanel: Not configured (env var: `analytics.openpanel`, UUID format)
- Cloudflare Web Analytics: Not configured (env var: `analytics.cloudflare`, 32 hex chars)
- Simple Analytics: Disabled (flag: `enable_simple_analytics: false`)

**Search Engine Verification (disabled):**
- Google Search Console: Not configured (env var: `google_site_verification`)
- Bing Webmaster: Not configured (env var: `bing_site_verification`)

**Accessibility & Performance (no external services):**
- Axe accessibility checks run locally in CI (axe.yml)
- Lighthouse performance checks run locally in CI (lighthouse-badger.yml)
- Broken links detection runs locally in CI (broken-links-site.yml)

## Comments & Discussion

**Comments System (disabled but available):**
- Primary: Giscus (modern, GitHub Discussions-based)
  - Config in `_config.yml`: `giscus:` block
  - At build time, auto-updates `giscus.repo` from `${{ github.repository }}`
  - Not enabled: `repo:`, `repo_id:`, and `category_id:` left empty
  - Features when enabled: emoji reactions, dark/light themes, language selection
  
- Fallback: Disqus (legacy)
  - Config in `_config.yml`: `disqus_shortname: al-folio` (template default, not overridden)
  - Requires custom shortname override

**Per-page override:**
- Front matter flag: `giscus_comments: true` to enable on individual pages

## Fonts & Icons

**Icons (All via CDN with SRI integrity hashes, no local copies):**

From `third_party_libraries` in `_config.yml`:
- **Font Awesome** 7.2.0 - CSS from jsDelivr
  - SRI hash: `sha256-MVopmdyC2tYTiJ8wlktf0uh0v4NgT+vNdyVFepi7Q0c=`
  - CDN URL: `https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@{version}/css/all.min.css`
  - Loading: via `al_icons` gem (Liquid tag: `al_icons_styles`)

- **Academicons** 1.9.5 - Academic/research-specific icons
  - SRI hash: `sha256-SzrCOBJbGVFMahewkgjwnApaV2+av1DwMAA+/QGLyZw=`
  - CDN URL: `https://cdn.jsdelivr.net/npm/academicons@{version}/css/academicons.min.css`

- **Scholar Icons** 1.0.3 - Publication/citation icons
  - SRI hash: `sha256-VY3hHVj/hNX3fYG6wtbA6TcKJQl7+FthzGSyIB64klY=`
  - CDN URL: `https://cdn.jsdelivr.net/npm/scholar-icons@{version}/css/scholar-icons.css`

**Google Fonts:**
- URL: `https://fonts.googleapis.com/css?family=Roboto:300,400,500,700|Roboto+Slab:100,300,400,500,700|Material+Icons&display=swap`
- No SRI hash (Google Fonts does not support SRI)

## Math & Visualization Libraries

**Math Rendering (Controlled by `enable_math: true` in `_config.yml`):**
- **MathJax** 3.2.2 - LaTeX/MathML rendering
  - SRI js: `sha256-MASABpB4tYktI2Oitl4t+78w/lyA+D7b/s9GEP0JOGI=`
  - CDN: `https://cdn.jsdelivr.net/npm/mathjax@{version}/es5/tex-mml-chtml.js`
  - Local fonts: Fallback to `output/chtml/fonts/woff-v2/`
  - Loading: via `al_math` gem (Liquid tags: `al_math_styles`, `al_math_scripts`)

- **TikZJax** 1.0.8 - TikZ diagram rendering
  - SRI hash (css): `sha256-p+CQrhSq3dnLHELDcVBFDf4whOor3w8gzLuc/pwRLyQ=`
  - SRI hash (js): `sha256-7SCmUR11IG4MkSoeLUq0pombv7oeV7yZuu7Z82e4Uy4=`
  - CDN: `https://cdn.jsdelivr.net/npm/@planktimerr/tikzjax@{version}/dist/`

- **Pseudocode** 2.4.1 - Algorithm pseudocode rendering
  - SRI hash (css): `sha256-VwMV//xgBPDyRFVSOshhRhzJRDyBmIACniLPpeXNUdc=`
  - SRI hash (js): `sha256-aVkDxqyzrB+ExUsOY9PdyelkDhn/DfrjWu08aVpqNps=`
  - CDN: `https://cdn.jsdelivr.net/npm/pseudocode@{version}/build/`

**Charts & Visualization (Controlled by feature flags on chart front-matter):**
- **Chart.js** 4.4.1 - Canvas-based charts
  - SRI: `sha256-0q+JdOlScWOHcunpUk21uab1jW7C1deBQARHtKMcaB4=`
  
- **ECharts** 5.5.0 - Interactive charts with dark theme support
  - SRI (library): `sha256-QvgynZibb2U53SsVu98NggJXYqwRL7tg3FeyfXvPOUY=`
  - SRI (dark theme): `sha256-sm6Ui9w41++ZCWmIWDLC18a6ki72FQpWDiYTDxEPXwU=`

- **Mermaid** 10.7.0 - Diagram rendering (flowcharts, UML, etc)
  - SRI: `sha256-TtLOdUA8mstPoO6sGvHIGx2ceXrrX4KgIItO06XOn8A=`

- **Plotly.js** 3.0.1 - Interactive 3D plots
  - SRI: `sha256-oy6Be7Eh6eiQFs5M7oXuPxxm9qbJXEtTpfSI93dW16Q=`

- **Vega** 5.27.0 - Grammar of graphics visualization
  - SRI (lib): `sha256-Yot/cfgMMMpFwkp/5azR20Tfkt24PFqQ6IQS+80HIZs=`
  - SRI (map): `sha256-z0x9ICA65dPkZ0JVa9wTImfF6n7AJsKc6WlFE96/wNA=`

- **Vega-Lite** 5.16.3 - Simplified Vega specification
  - SRI (lib): `sha256-TvBvIS5jUN4BSy009usRjNzjI1qRrHPYv7xVLJyjUyw=`
  - SRI (map): `sha256-l2I4D5JC23Ulsu6e3sKVe5AJ+r+DFkzkKnZS8nUGz28=`

- **Vega-Embed** 6.24.0 - Vega visualization embedding
  - SRI (lib): `sha256-FPCJ9JYCC9AZSpvC/t/wHBX7ybueZhIqOMjpWqfl3DU=`
  - SRI (map): `sha256-VBbfSEFYSMdX/rTdGrONEHNP6BprCB7H/LpMMNt/cPA=`

- **Diff2HTML** 3.4.47 - HTML diff rendering
  - SRI (css): `sha256-IMBK4VNZp0ivwefSn51bswdsrhk0HoMTLc2GqFHFBXg=`
  - SRI (js): `sha256-eU2TVHX633T1o/bTQp6iIJByYJEtZThhF9bKz/DcbbY=`

- **Leaflet** 1.9.4 - Interactive maps
  - SRI (css): `sha256-q9ba7o845pMPFU+zcAll8rv+gC+fSovKsOoNQ6cynuQ=`
  - SRI (js): `sha256-MgH13bFTTNqsnuEoqNPBLDaqxjGH+lCpqrukmXc8Ppg=`
  - SRI (js.map): `sha256-YAoQ3FzREN4GmVENMir8vgHHypC0xfSK3CAxTHCqx1M=`

**Image Tools (Plugin: `al_img_tools`):**
- **ImagesLoaded** 5.0.0 - Image loading detection
  - SRI: `sha256-htrLFfZJ6v5udOG+3kNLINIKh2gvoKqwEhHYfTTMICc=`
- **Masonry** 4.2.2 - Cascading grid layout
  - SRI: `sha256-Nn1q/fx0H7SNLZMQ5Hw5JLaTRZp0yILA/FRexe19VdI=`

## UI & Interactive Components

**Bootstrap Table** 1.22.4 (for data tables):
- CSS SRI: `sha256-uRX+PiRTR4ysKFRCykT8HLuRCub26LgXJZym3Yeom1c=`
- JS SRI: `sha256-4rppopQE9POKfukn2kEvhJ9Um25Cf6+IDVkARD0xh78=`
- CDN: `https://cdn.jsdelivr.net/npm/bootstrap-table@{version}/`

**MDB (Material Design Bootstrap)** 4.20.0:
- CSS SRI: `sha256-jpjYvU3G3N6nrrBwXJoVEYI/0zw8htfFnhT9ljN3JJw=`
- JS SRI: `sha256-NdbiivsvWt7VYCt6hYNT3h/th9vSTL4EDWeGs5SN3DA=`
- CDN: `https://cdn.jsdelivr.net/npm/mdbootstrap@{version}/`

**Syntax Highlighting (Local):**
- Rouge with highlight.js CDN styling
- Light theme: `https://cdn.jsdelivr.net/npm/highlight.js@{version}/styles/github.min.css`
- Dark theme: `https://cdn.jsdelivr.net/npm/highlight.js@{version}/styles/github-dark.min.css`

**Table of Contents:**
- **Tocbot** 4.36.4 - Automatic TOC generation
  - SRI (css): `sha256-zTN0r+0OKaIv2xqeNNIYxNk0pWJ6+IqPGc1iDgVzWF0=`
  - SRI (js): `sha256-lo/r+jQ81wWrxdIiiiEeD538z4+dTJTt+leOuAS7GCw=`

**Cookie Consent (GDPR):**
- **Vanilla Cookie Consent** 3.1.0 - opt-in GDPR consent banner (disabled by default)
  - SRI (css): `sha256-ygRrixsQlBByBZiOcJamh7JByO9fP+/l5UPtKNJmRsE=`
  - SRI (js): `sha256-vG4vLmOB/AJbJ6awr7Wg4fxonG+fxAp4cIrbIFTvRXU=`
  - Controlled by: `enable_cookie_consent: false` in `_config.yml`

**Back to Top Button:**
- **Vanilla Back to Top** 7.2.1
  - SRI: `sha256-uMJJ3EoTyfRBoTbR+lrfu1uRQ87RZG8AR3cVNuQVeFg=`
  - Controlled by: `back_to_top: true` in `_config.yml`

**Search UI:**
- Part of `al_search` gem (Cmd-K ninja-keys palette)
- Search index built at build time from content
- No external search service

## Academic Services

**Publication Badges (Configured in `_config.yml`):**

All badges are generated at render time via JavaScript, not pre-rendered:

- **Google Scholar Badge** (enabled)
  - Parameter in BibTeX: `google_scholar_id`
  - URL pattern: `https://scholar.google.com/citations?view_op=view_citation&hl=en&user=YOUR_SCHOLAR_ID&citation_for_view=YOUR_SCHOLAR_ID:CITATION_ID`

- **Altmetric Badge** (enabled)
  - Parameter in BibTeX: `altmetric`
  - Service: Altmetric (https://altmetric.com/)
  - Script: `https://d1wqtxts1xzle7.cloudfront.net/...`

- **Dimensions Badge** (enabled)
  - Parameter in BibTeX: `dimensions`
  - Service: Dimensions (https://www.dimensions.ai/)
  - Script: `https://badge.dimensions.ai/...`

- **Inspire HEP Badge** (available)
  - Parameter in BibTeX: `inspirehep_id`
  - Service: Inspire HEP (https://inspirehep.net/)
  - Use: High-energy physics publications only

**Google Scholar Integration (Optional):**
- Script: `bin/update_scholar_citations.py`
- Dependency: `scholarly` package (in `requirements.txt`)
- Purpose: Fetch citation count from Google Scholar and inject into bibliography
- Not automated in CI (manual run only)

## Google Services

**Google Fonts:**
- URL: `https://fonts.googleapis.com/css?family=Roboto:300,400,500,700|Roboto+Slab:100,300,400,500,700|Material+Icons&display=swap`
- Font families: Roboto (300-700 weights), Roboto Slab, Material Icons
- No SRI hash (Google Fonts doesn't support it)

**Google Analytics (Optional):**
- Measurement ID format: G-XXXXXXXXXX
- Not configured in this checkout
- Config key: `analytics.google`

**Google Search Console (Optional):**
- Verification token format: Site verification code
- Not configured in this checkout
- Config key: `google_site_verification`

## Email & Communication

**Email Address (No external service):**
- Email: khanhchi.phamha@gmail.com (stored in `_data/socials.yml`)
- Protection: Optional (feature flag `protect_email: false` in `_config.yml`)
- When enabled, prevents scraper harvesting and enables click-to-copy via `al_email_protect` gem

**Newsletter (Disabled):**
- Provider: Loops.so
- Config in `_config.yml`: `newsletter.enabled: false`
- When enabled, requires: `newsletter.endpoint` (Loops.so form URL)
- Implementation: Liquid tag `al_newsletter_form` from `al_newsletter` gem

## External Repositories & Resources

**GitHub Integration:**
- Giscus comments reads from same GitHub repository (`${{ github.repository }}`)
- Repository stats from: github-stats-extended.vercel.app (self-hosted or Vercel)
  - Config key: `external_services.github_readme_stats_url`
  - Default: `https://github-stats-extended.vercel.app`
  - Disabled: `repo_trophies.enabled: false`
- GitHub Profile Trophies (available): github-profile-trophy.vercel.app
  - Config key: `external_services.github_profile_trophy_url`
  - Currently disabled (Vercel deployment inactive)

**Open Graph & Schema.org (Disabled):**
- `serve_og_meta: false` - No social media preview cards
- `serve_schema_org: false` - No structured data injection

## Distill Article Support

**Distill Templates:**
- Engine: distillpub-template
- Source: al-org-dev/distill-template#al-folio (custom fork)
- Vendored at build time via `al_folio_distill` gem
- Allows: `layout: distill` on individual posts
- Remote loader disabled: `allow_remote_loader: false`

## Image Processing

**Responsive Images (Configured, requires ImageMagick):**
- Tool: ImageMagick (`convert` command)
- Enabled: `imagemagick.enabled: true` in `_config.yml`
- Input: `assets/img/` (JPG, JPEG, PNG, TIFF, GIF)
- Output formats: WebP (quality 85)
- Widths generated: 480px, 800px, 1400px
- Lazy loading enabled by default

## Environment Configuration

**Required at Build Time:**
- None for basic functionality
- Optional: `JEKYLL_ENV=production` (set by CI automatically)

**Optional Environment Variables (Not currently configured):**
- Google Analytics: None (configured in `_config.yml`)
- Cronitor, Pirsch, Openpanel, Cloudflare: None configured
- Giscus: Auto-filled from `github.repository` during CI build

**Secrets & Credentials:**
- None stored in repository (`.env` not present, not needed)
- No API keys or tokens in version control
- All configuration via public `_config.yml`

## Third-Party Library Cache Policy

**Libraries via CDN with SRI (recommended for external single-file libraries):**
- 35+ libraries from jsDelivr CDN
- Each entry includes integrity hash for tamper detection
- All versions pinned in `third_party_libraries` block in `_config.yml`

**Vendored/Local Assets:**
- None vendored in this starter (enforced by `npm run lint:style-contract`)
- User sites created from this template may legally vendor files locally

---

*Integration audit: 2026-09-12*

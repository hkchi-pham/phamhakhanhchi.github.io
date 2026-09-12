# Coding Conventions

**Analysis Date:** 2026-09-12

## Naming Patterns

**Files:**
- Markdown content: snake_case with leading underscore in collection directories (`_pages/`, `_posts/`, `_projects/`)
- YAML configuration: snake_case (e.g., `_config.yml`, `frontmatter_key`)
- Directory names: lowercase with hyphens (e.g., `_includes`, `_data`, `_layouts`)
- Assets: descriptive lowercase with hyphens (e.g., `publication_preview`, `book_covers`)

**Variables and Keys:**
- YAML front-matter keys: snake_case (e.g., `nav_order`, `selected_papers`, `image_circular`)
- Liquid variables: snake_case (e.g., `forloop.index0`, `site.data`)

**Collections:**
- Directory naming: prefix with underscore (e.g., `_pages/`, `_posts/`, `_projects/`, `_news/`, `_teachings/`, `_books/`)

## Code Style

**Formatting:**
- Tool: Prettier v3.8.0
- Plugin: `@shopify/prettier-plugin-liquid` v1.10.0
- Print width: 150 characters
- Trailing comma: "es5"
- Configuration file: `.prettierrc` at repo root

**Linting:**
- Style contract: `npm run lint:style-contract` (executes `test/style_contract.js`)
- Command to fix: `npx prettier . --write`
- Pre-commit hooks in `.pre-commit-config.yaml`: trailing-whitespace, end-of-file-fixer, check-yaml, check-added-large-files

**Style Contract Enforcement (`test/style_contract.js`):**

The style contract asserts the following boundaries:

1. **Theme Pin:** `_config.yml` must declare `theme: al_folio_core`
2. **Required Plugins:** `_config.yml` must include (as `- al_*` entries under `plugins:`)
   - `al_folio_core`
   - `al_folio_distill`
   - `al_cookie`
   - `al_icons`
   - `al_math`
3. **Third-Party Libraries:** `_config.yml` must define `third_party_libraries` entries:
   - `fontawesome`, `academicons`, `scholar-icons` (with SRI hashes for CSS integrity)
   - `tikzjax`, `tocbot`
4. **al_math Version:** `Gemfile` must pin `al_math` to an exact released version (`= x.y.z`), never a git branch
5. **Forbidden Scripts:** `package.json` must not define `build:css`, `build:tailwind`, or `build:tailwind:watch` (build ownership belongs to gem repos)
6. **Icon Artifacts:** Starter must not own icon runtime artifacts like `assets/fonts/academicons.woff`

**Note:** This site has disabled the forbidden-path check and some integration test requirements (see comment block in `test/style_contract.js` lines 68-108) because this is a personal portfolio, not the template itself.

## Markdown Front-Matter Conventions

### Pages (`_pages/*.md`)
```yaml
layout: about  # or "page"
title: Page Title
permalink: /path/
description: Short description
nav: true  # optional: add to navigation
nav_order: 1  # optional: navigation order
subtitle: >  # optional: for "about" layout
  Multi-line subtitle text
```

**Example:** `_pages/about.md` includes layout-specific options:
- `selected_papers: false` — disable publications section
- `social: true` — enable social links
- `announcements.enabled: false` — disable announcements
- `latest_posts.enabled: false` — disable latest posts
- `profile:` — optional profile image block with `align`, `image`, `image_circular`

### Projects (`_projects/*.md`)
```yaml
layout: page
title: Project Name
description: One-line description
year: YYYY
importance: 1  # or 2: used for display ordering
```

**Optional keys:**
```yaml
img: assets/img/project-image.jpg
github: https://github.com/...
redirect: https://external-url.com
```

### Posts (if used)
```yaml
layout: post
title: Post Title
date: YYYY-MM-DD HH:MM:SS
description: Summary
```

## Asset Organization

**Directory structure under `assets/`:**
- `img/` — images (project screenshots, profile pictures, book covers)
  - `book_covers/` — publication book cover images
  - `publication_preview/` — publication preview images
- `pdf/` — PDF documents
- `video/` — video embeds
- `audio/` — audio files
- `json/` — JSON data files
- `css/` — custom stylesheets (limited: runtime CSS lives in gems)
- `html/` — HTML resources
- `jupyter/` — Jupyter notebook outputs
- `plotly/` — Plotly chart HTML
- `rendercv/` — CV rendering outputs
- `bibliography/` — BibTeX-related assets

**Ignored files** (in `.prettierignore`):
- Source maps (`**/*.map`)
- Minified CSS/JS (`**/*.min.css`, `**/*.min.js`)
- Generated citations (`_data/citations.yml`)
- Demo HTML files (`assets/plotly/demo.html`)
- Lighthouse reports (`lighthouse_results/**`)
- Pre-2015 math post (`_posts/2015-10-20-math.md`)

## Table of Contents Auto-Generation

**Markers:** TOCs are maintained automatically via `update-tocs.yml` workflow. Markdown files must use these markers:

```markdown
<!--ts-->
[TOC is generated here automatically]
<!--te-->
```

**Files with auto-generated TOCs:**
- Root markdown files (checked by CI)
- `docs/` markdown files (checked by CI)

**Workflow details (`update-tocs.yml`):**
- Runs on push to `main`/`master` when `.md` files change
- Uses `gh-md-toc` to generate TOCs with `--indent 2`
- Runs Prettier afterward to normalize formatting (gh-md-toc and Prettier disagree on escaping)
- Auto-commits with message "Auto update markdown TOC"

## Liquid and Template Conventions

**Jekyll collections:**
- All content collections prefixed with underscore and lowercase
- Layouts stored in gem-owned `_layouts/` (this repo may shadow via overrides)
- Includes stored in gem-owned `_includes/` (this repo may shadow via overrides)

**Data files (`_data/`):**
- YAML format
- Snake_case filenames
- Structured hierarchically: e.g., `academics.yml` contains top-level keys like `qualifications`, `competitions`, `subject_attainment`

**Conditional Logic (example from `_pages/academics.md`):**
```liquid
{% assign sections = "qualifications,competitions,subject_attainment" | split: "," %}
{% for key in sections %}
  {% assign entries = site.data.academics[key] %}
  {% if entries and entries.size > 0 %}
    [render section]
  {% endif %}
{% endfor %}
```

## Import Organization

**Gem Imports in `Gemfile` (example structure):**
```ruby
# Core Jekyll
gem 'jekyll'

# Standard plugins
group :jekyll_plugins do
  gem 'jekyll-archives-v2'
  gem 'jekyll-scholar'
  # ... more plugins
end

# Development/external
group :other_plugins do
  gem 'css_parser'
  gem 'observer'
end

# al-folio plugins (versioned group)
group :al_folio_plugins do
  gem 'al_folio_core', '= 1.0.15'
  gem 'al_icons', '= 1.0.0'
  # ... pinned to exact versions
end
```

**Key rule:** Every `al_*` gem in `Gemfile` must also be listed in `_config.yml` under `plugins:` with matching name (hyphens in repo, underscores in `_config.yml`).

## Comments and Documentation

**When to Comment:**
- Complex Liquid logic (data transformations, conditional rendering)
- Non-obvious YAML structure (e.g., nested data files)
- Workarounds and known limitations

**Comment Examples from codebase:**
- `_pages/academics.md`: "Order follows the file, newest first. Liquid sort is unstable, so sorting here reshuffles same-year entries."
- `test/visual/helpers.js`: Detailed explanation of why map tiles are blocked (CDN non-determinism)

**JSDoc/TSDoc:**
- Minimal in this repo (primarily JavaScript in tests)
- Test files include comment blocks explaining test intent

## Code Organization Patterns

**Page Rendering with Data Files:**
- Pages access hierarchical YAML via `site.data.<filename>.<key>`
- Liquid loops iterate over array data structures
- Conditional `{% if entries and entries.size > 0 %}` guards prevent empty sections

**Feature Toggles:**
- Boolean keys in front-matter (e.g., `selected_papers: false`)
- Layout conditionally renders sections based on these flags

## Git and Commit Standards

**Pre-commit hooks enabled:**
- Trailing whitespace removal
- End-of-file fixer
- YAML validation
- Large file detection

**Prettier must pass before commit:**
- Run `npm run lint:prettier` or `npx prettier . --write`
- All Markdown, Liquid, YAML, JSON must conform

**Style contract must pass:**
- Run `npm run lint:style-contract` before push
- Asserts theme, plugins, SRI pins, al_math version

---

*Convention analysis: 2026-09-12*

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

@AGENTS.md

`AGENTS.md` (imported above) is the **authoritative** agent entry point: change routing, the stop sign for gem-owned paths, the three silent failure modes, and the validated command set. Keep it short and ecosystem-neutral. Cross-repo architecture — the wrapper/tag/gem delegation table, feature gating, the v1 config contract, local overrides — lives in [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md); area-to-gem ownership lives in [`docs/BOUNDARIES.md`](docs/BOUNDARIES.md).

**Read those three before editing anything.** Everything below is Claude-specific or longer-form operational detail that does not belong in the short entry point. Do not restate facts from those files here — link to them.

## This fork: the stop sign is disabled

Everything above and below this section describes the upstream al-folio demo. This is a personal site built from that template, and three of the claims it makes are **false here**. Read this before deleting anything as a "contract violation".

- **`_sass/` is this site's own design surface, not a forbidden path.** `test/style_contract.js` carries its forbidden-path loop commented out at lines 68–84, with an in-file explanation; `node test/style_contract.js` passes today with `_sass/` present. (A second block, lines 96–108, is disabled the same way.) `_sass/_tokens.scss` and `_sass/_custom.scss` are deliberate and must not be removed. `_tokens.scss` is the single token file every colour, step and space value comes from; `_custom.scss` holds the site's gem overrides and the `--deploy-proof` deploy canary.
- **Nothing runs that check any more.** `unit-tests.yml`, its only runner, was deleted in Phase 1. The surviving workflows are `deploy.yml`, `prettier.yml` and `broken-links-site.yml` — so the "CI gates and the style contract" and "Validated local command set" lists below name workflows and integration tests that no longer exist.
- **This site's effective baseurl is empty, not `/al-folio`.** Every `--baseurl /al-folio` and `localhost:4000/al-folio/` reference below belongs to the upstream demo. Docker previews serve at `http://127.0.0.1:8080/`.

Authoritative for this site: [`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md), `.planning/PROJECT.md`, `.planning/STATE.md`. The upstream text is kept verbatim as the historical record rather than rewritten — same convention `.planning/STATE.md` records for annotating requirements instead of silently editing them.

## Daily dev loop

```bash
bundle install                                # ruby gems
bundle exec jekyll serve                      # dev server → http://localhost:4000/al-folio/  (NOTE baseurl)
bundle exec jekyll build --baseurl /al-folio  # production-style build to _site/
bash test/integration_distill.sh              # run ONE integration test (any of the seven in test/)
npm run test:visual:update                    # refresh playwright snapshots after intentional UI change
bundle exec al-folio upgrade apply --safe     # deterministic codemods (font-weight-* → font-*, remote→local URLs)
bundle exec al-folio upgrade overrides diff <path>    # then `overrides accept <path>` to acknowledge an override
```

## Optional toolchains

- **Jupyter posts.** `bin/setup-python-deps` installs _only_ `jupyter` and `nbconvert` (via `pip --user --break-system-packages`) for `jekyll-jupyter-notebook`. It does **not** read `requirements.txt`. Missing `jupyter-nbconvert` is warn-and-continue; notebook rendering is skipped.
- **Everything else Python.** [`requirements.txt`](requirements.txt) is the fuller list and must be installed separately (`python3 -m pip install -r requirements.txt`): `rendercv[full]` for CV rendering, `scholarly` for `bin/update_scholar_citations.py`, plus `nbconvert` and `pyyaml`.
- **Responsive images.** `imagemagick.enabled: true` needs ImageMagick `convert` on `PATH`.
- **Manual deploy.** `bin/deploy` is the manual `gh-pages` build + purgecss + force-push path; CI normally deploys. `purgecss` is not a devDependency — install it with `npm install -g purgecss`.

## Docker serving model (v1-specific)

`docker compose up -d` bind-mounts the repo to `/srv/jekyll` and runs `bin/entry_point.sh`, which serves with `--force_polling --destination /tmp/_site`. The build output deliberately goes to **container-local `/tmp/_site`, not the bind-mounted `_site`** — writing `_site` back across the host bind mount caused write deadlocks. The container also `inotifywait`s `_config.yml` and restarts Jekyll on change (config edits aren't hot-reloaded by `--watch`). Verify with the `/al-folio` baseurl: `curl -fsS http://127.0.0.1:8080/al-folio/`. `docker-compose-slim.yml` pulls a prebuilt `:slim` image instead of building locally.

## CI gates and the style contract

`npm run lint:style-contract` (`test/style_contract.js`) is the automated enforcement of the thin-starter boundary and will fail CI if you cross it. Beyond the forbidden paths listed in `AGENTS.md`, it also asserts that `_config.yml` keeps `theme: al_folio_core` and the required plugins, that the `third_party_libraries` SRI pins are present, and that the `al_math` Gemfile pin stays on a released version rather than a git branch.

Other gates:

- `unit-tests.yml` — style contract plus all seven `test/integration_*.sh` scripts (`comments`, `plugin_toggles`, `distill`, `bootstrap_compat`, `upgrade_cli`, `css_minify`, `new_plugins`).
- `visual-regression.yml` — Playwright on chromium + webkit, diffing the candidate build against a `v0.16.3` baseline worktree served on `:4100` via `BASELINE_URL`.
- `upgrade-check.yml` — `bundle exec al-folio upgrade audit`.
- `prettier.yml` — Prettier with `@shopify/prettier-plugin-liquid` and `printWidth: 150`. Run `npm run lint:prettier` before pushing; `npx prettier . --write` fixes.
- `update-tocs.yml` — regenerates `<!--ts-->…<!--te-->` blocks in changed root and `docs/` Markdown files. If you add or rename a heading, expect a follow-up auto-commit on `main`.

## Gem version pins

`Gemfile` pins every `al-*` gem to an exact released version in `group :al_folio_plugins`, and `_config.yml` lists the same gems under `plugins:`. Read the current pins from the `Gemfile` rather than trusting any version quoted in prose — including here. To test a gem fix against this site, repoint the `Gemfile` at a sibling checkout (`path:`, `git:`, or `branch:`) and `bundle install`; see [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md#working-on-a-gem-alongside-the-starter). Revert the pin before committing.

module.exports = {
  content: ["_site/**/*.html", "_site/**/*.js"],
  css: ["_site/assets/css/*.css"],
  output: "_site/assets/css/",
  skippedContentGlobs: ["_site/assets/**/*.html"],
  safelist: [
    "collapse",
    "collapsing",
    "show",
    "dropdown-menu",
    "dropdown-item",
    "table",
    "table-dark",
    "table-hover",
    "table-responsive",
    "af-tooltip",
    "af-popover",
    "font-weight-bold",
    "font-weight-medium",
    "font-weight-lighter",
    // medium-zoom injects these at runtime, so they never appear in the static
    // HTML PurgeCSS scans; without them the zoom overlay's z-index rule is purged
    // and page chrome (scroll-progress bar, ToC) bleeds through a zoomed image.
    "medium-zoom-overlay",
    "medium-zoom-image--opened",
    // PurgeCSS matches this list against SELECTOR NODES, so a pseudo-class
    // must be written WITH its leading colon. ":focus-visible" keeps the
    // site-wide keyboard focus ring declared in _sass/_custom.scss, which has
    // no tag or class node for the default extractor to match and was
    // therefore stripped from production between 2026-09-14 and this commit
    // (the gem's own .af-table-search:focus-visible survived only because
    // that class appears in the built HTML). "focus-visible" WITHOUT the
    // colon does not match and is not a substitute — measured against
    // purgecss 8.0.0. Every future bare pseudo-class rule (:target,
    // :focus-within) needs an entry here or it ships as dead source.
    ":focus-visible",
    // Same class of problem, milder: _custom.scss paints h1..h6 with the
    // heading ink, and PurgeCSS drops h5/h6 from the selector list because no
    // page renders those tags today. Safelisting them means a page that later
    // adds an <h5> gets heading ink without a config change.
    "h5",
    "h6",
  ],
};

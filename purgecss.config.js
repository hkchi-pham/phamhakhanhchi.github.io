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
    // The prose-measure selector list in _sass/_custom.scss names fourteen
    // nodes, three of which appear in NO built page on this site: <ol>,
    // <blockquote> and <h4> (03-RESEARCH Finding 7, a tag census of all seven
    // deployed pages). PurgeCSS prunes unused nodes out of a selector LIST and
    // reports nothing, so without these three the measure rule ships with three
    // of its selectors quietly missing while the source stays correct — the
    // exact failure that cost this project a day when ":focus-visible" was
    // stripped. Standing live proof the mechanism is biting right now:
    // _custom.scss declares .topic-list and the SERVED main.css contains zero
    // occurrences of it. These entries must land in the same commit as the rule
    // that names them.
    //
    // Related luck worth not relying on: pre,code{color:var(--ink-800)} survives
    // today only because the words "pre" and "code" happen to occur in page
    // text and the default extractor matches bare tag selectors against any word
    // token. That is not a rule. Hence explicit entries here rather than a hope.
    "ol",
    "blockquote",
    "h4",
  ],
};

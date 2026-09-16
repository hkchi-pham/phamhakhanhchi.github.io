#!/usr/bin/env node
//
// Google Fonts webfont payload counter. Zero dependencies, Node only.
//
//   node .planning/tools/fontbudget.js "<google fonts css2 url>" --max 153600
//   node .planning/tools/fontbudget.js "<url>" ["<url>" ...] --report-only
//   node .planning/tools/fontbudget.js --selftest
//
//   FONTS_URL="<url>" node .planning/tools/fontbudget.js --max 153600
//   FONTS_URL="<url> <url>" node .planning/tools/fontbudget.js --report-only
//
// ---------------------------------------------------------------------------
// WHY THE FONTS_URL ENVIRONMENT FORM EXISTS - it is not a convenience
//
// A css2 URL naming two families contains "&". On this machine `node` on PATH
// is a Volta SHIM, and the shim re-parses its arguments through cmd.exe, which
// treats "&" as a command separator EVEN INSIDE bash single quotes:
//
//   $ node -e '...' 'https://…/css2?family=A&family=B&display=swap'
//   ["https://…/css2?family=A"]
//   'family' is not recognized as an internal or external command
//
// The tail of the URL is destroyed before Node ever sees it, and the tool
// would then measure one family and report a comfortably-passing total. The
// real node.exe (C:\Program Files\nodejs\node) passes it through intact, so
// this is a shim artefact, not a Node one - but verify.sh cannot know which
// `node` it got. Reading the URL from the ENVIRONMENT sidesteps the argv
// layer entirely: the "&" stays inside a shell variable and is never an
// argument. Positional URLs still work and are preferred where the shell is
// known-good (CI, real node); FONTS_URL is the portable form the harness uses.
// ---------------------------------------------------------------------------
//
// Why this exists: TYPE-05 states a webfont budget, and a budget whose only
// evidence is one person's DevTools Network tab is a budget nobody can
// regress-check. This is the .planning/tools/contrast.js precedent applied to
// bytes: the measurement becomes a command, so a later agent can re-run it
// instead of trusting a number in a document.
//
// Deliberately NOT wired to an npm script and NOT a test framework:
// 01-VALIDATION.md forbids a starter-local build/test pipeline and
// 02-VALIDATION.md carries that forward ("No framework install. No npm
// script. No package.json change."). Plain CommonJS, require('https') only.
//
// ---------------------------------------------------------------------------
// THE USER-AGENT IS LOAD-BEARING - DO NOT MAKE IT A FLAG
//
// Google Fonts content-negotiates on User-Agent. Without a modern browser UA
// BOTH the v1 (css?family=) and v2 (css2?family=) endpoints return
// unsubsetted TrueType with no unicode-range and no subset comments at all
// (03-RESEARCH.md Finding 1, measured 2026-09-16). This script would then
// parse zero blocks and report a total of 0 B - a budget that passes because
// nothing was measured. The UA is baked in as a constant below, and the
// truetype response is detected and treated as a hard error, not as "fits".
// ---------------------------------------------------------------------------
//
// ---------------------------------------------------------------------------
// MEASURED BASELINE - 2026-09-16
//
//   141,232 B over 8 unique files (= 137.9 KiB = 141.2 kB decimal)
//
// for the five locked cuts of Phase 3 - Literata 400 / 600 / 400 italic and
// Be Vietnam Pro 400 / 600 - over the latin + vietnamese subsets only, from:
//
//   https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;600
//     &family=Literata:ital,wght@0,400;0,600;1,400&display=swap
//
// That figure is PINNED TO THE FONT VERSIONS THEN CURRENT: Literata v40 and
// Be Vietnam Pro v12 on fonts.gstatic.com. A later re-run returning a
// materially different number means Google reissued a family, not that this
// tool broke. Record the new number and the new version string; do not edit
// the baseline away.
//
// Two facts inside that total that are easy to get wrong:
//   - Literata 400 and 600 resolve to the SAME variable woff2. Counting it
//     once per weight overstates the payload by ~48 KB, so unique URLs are
//     de-duplicated below and the repeat is shown as "shared".
//   - Be Vietnam Pro has no variable version (wght@400..600 is HTTP 400), so
//     its two cuts really are two files.
// ---------------------------------------------------------------------------

const https = require("https");

// Chrome 120 on Windows. See the block above: this is not configurable, on
// purpose.
const UA =
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36";

// The two subsets the budget is stated over. "latin" carries a-grave and
// a-acute (U+00E0/U+00E1); "vietnamese" carries a-dot-below (U+1EA1) and the
// combining marks. The name "Pham Ha Khanh Chi", set properly, needs both
// files of the same family - 03-RESEARCH Finding 2 - so neither can be
// dropped from the count.
const KEEP_SUBSETS = ["latin", "vietnamese"];

const TIMEOUT_MS = 30000;

// --- network ---------------------------------------------------------------

// GET a URL, following up to `hops` redirects (fonts.gstatic.com issues 302s).
// Resolves with the full body buffer and the byte count summed off the
// response stream - content-length is recorded only to cross-check, never
// trusted as the answer. Rejects loudly on timeout or non-200: a silently low
// total is the one failure mode this tool must never produce.
function get(url, hops) {
  const left = typeof hops === "number" ? hops : 5;
  return new Promise((resolve, reject) => {
    const req = https.get(url, { headers: { "User-Agent": UA, Accept: "*/*" } }, (res) => {
      const code = res.statusCode;
      const loc = res.headers.location;
      if (code >= 300 && code < 400 && loc) {
        res.resume();
        if (left <= 0) return reject(new Error(`too many redirects: ${url}`));
        return resolve(get(new URL(loc, url).toString(), left - 1));
      }
      if (code !== 200) {
        res.resume();
        return reject(new Error(`HTTP ${code} for ${url}`));
      }
      const chunks = [];
      let n = 0;
      res.on("data", (c) => {
        chunks.push(c);
        n += c.length;
      });
      res.on("end", () => {
        const declared = res.headers["content-length"] ? parseInt(res.headers["content-length"], 10) : null;
        resolve({
          url,
          body: Buffer.concat(chunks),
          bytes: n,
          declared,
          mismatch: declared !== null && declared !== n,
        });
      });
      res.on("error", reject);
    });
    req.setTimeout(TIMEOUT_MS, () => {
      req.destroy(new Error(`timeout after ${TIMEOUT_MS}ms: ${url}`));
    });
    req.on("error", reject);
  });
}

// --- parsing ---------------------------------------------------------------

// Split a Google Fonts CSS response into its subset-commented blocks. Each
// comment marks the start of one @font-face rule and runs until the next
// comment (or EOF). Returns one record per block, whether or not it carries a
// woff2 URL, so a caller can see a fallback/math/symbols block that was
// filtered out rather than silently losing it.
function parseBlocks(css) {
  const re = /\/\*\s*([a-z0-9-]+)\s*\*\//g;
  const marks = [];
  let m;
  while ((m = re.exec(css)) !== null) {
    marks.push({ subset: m[1], start: m.index, end: re.lastIndex });
  }
  const blocks = [];
  for (let i = 0; i < marks.length; i++) {
    const body = css.slice(marks[i].end, i + 1 < marks.length ? marks[i + 1].start : css.length);
    const fam = /font-family:\s*['"]([^'"]+)['"]/.exec(body);
    const sty = /font-style:\s*([a-z]+)/.exec(body);
    const wgt = /font-weight:\s*([0-9]+(?:\s+[0-9]+)?)/.exec(body);
    const u = /url\(\s*['"]?(https?:\/\/[^)'"\s]+?\.woff2)['"]?\s*\)/.exec(body);
    blocks.push({
      subset: marks[i].subset,
      family: fam ? fam[1] : "(unknown)",
      style: sty ? sty[1] : "",
      weight: wgt ? wgt[1] : "",
      url: u ? u[1] : null,
    });
  }
  return blocks;
}

// Every url(...) in a stylesheet that ends in .woff2, resolved against the
// stylesheet's own URL. Font Awesome writes url(../webfonts/fa-solid-900.woff2)
// with a ?v= cache tag, so the query and fragment are stripped before the
// extension test. Order-preserving, de-duplicated.
function woff2Refs(css, baseUrl) {
  const re = /url\(\s*['"]?([^)'"]+?)['"]?\s*\)/g;
  const out = [];
  const seen = new Set();
  let m;
  while ((m = re.exec(css)) !== null) {
    const raw = m[1].split("?")[0].split("#")[0];
    if (!raw.toLowerCase().endsWith(".woff2")) continue;
    let abs;
    try {
      abs = new URL(raw, baseUrl).toString();
    } catch (e) {
      continue;
    }
    if (seen.has(abs)) continue;
    seen.add(abs);
    out.push(abs);
  }
  return out;
}

// --- formatting ------------------------------------------------------------

function tail(url) {
  const p = url.split("/");
  return p[p.length - 1];
}

function pad(s, n) {
  const v = String(s);
  return v.length >= n ? v : v + " ".repeat(n - v.length);
}

function padL(s, n) {
  const v = String(s);
  return v.length >= n ? v : " ".repeat(n - v.length) + v;
}

function sizes(n) {
  return `${n} B (${(n / 1024).toFixed(1)} KiB, ${(n / 1000).toFixed(1)} kB)`;
}

// A truetype response is the UA failure signature. Treat it as fatal: parsing
// it yields zero subset blocks, which would otherwise read as "0 B, fits".
function assertSubsetted(css, url) {
  if (/format\(\s*['"]?truetype/.test(css)) {
    console.error("ERROR: the response for");
    console.error(`  ${url}`);
    console.error("carries format('truetype') and no unicode-range - this is the");
    console.error("User-Agent failure signature (03-RESEARCH Finding 1). The UA");
    console.error("constant in this file did not reach Google. Nothing was measured.");
    process.exit(2);
  }
}

// --- modes -----------------------------------------------------------------

async function budget(cssUrl, max) {
  const cssRes = await get(cssUrl);
  const css = cssRes.body.toString("utf8");
  assertSubsetted(css, cssUrl);

  const all = parseBlocks(css);
  const kept = all.filter((b) => KEEP_SUBSETS.includes(b.subset) && b.url);
  if (kept.length === 0) {
    console.error(`ERROR: no ${KEEP_SUBSETS.join("/")} woff2 blocks found in ${cssUrl}`);
    console.error(`       (${all.length} block(s) parsed: ${all.map((b) => b.subset).join(", ") || "none"})`);
    process.exit(2);
  }

  const unique = [];
  const seenUrl = new Set();
  for (const b of kept) {
    if (seenUrl.has(b.url)) continue;
    seenUrl.add(b.url);
    unique.push(b.url);
  }

  const bytesFor = new Map();
  for (const u of unique) {
    const r = await get(u);
    bytesFor.set(u, r.bytes);
    if (r.mismatch) {
      console.error(`WARN: ${tail(u)} content-length ${r.declared} != ${r.bytes} bytes received`);
    }
  }

  console.log(`CSS: ${cssUrl}`);
  console.log(
    `     response body ${cssRes.bytes} B, ${all.length} block(s) parsed, ${kept.length} in ${KEEP_SUBSETS.join("+")}`
  );
  console.log("");
  console.log(`${pad("FAMILY", 18)}${pad("SUBSET", 12)}${pad("CUT", 12)}${padL("BYTES", 9)}  FILE`);

  const counted = new Set();
  let total = 0;
  for (const b of kept) {
    const n = bytesFor.get(b.url);
    const dup = counted.has(b.url);
    if (!dup) {
      counted.add(b.url);
      total += n;
    }
    const cut = `${b.weight}${b.style === "italic" ? " italic" : ""}`.trim();
    console.log(`${pad(b.family, 18)}${pad(b.subset, 12)}${pad(cut, 12)}${padL(dup ? "shared" : n, 9)}  ${tail(b.url)}`);
  }

  console.log("");
  console.log(`TOTAL: ${sizes(total)} over ${unique.length} unique file(s)`);
  console.log(`BUDGET: ${max} B (${(max / 1024).toFixed(1)} KiB)`);
  console.log(`USED: ${((total / max) * 100).toFixed(1)}%`);
  if (total > max) {
    console.log(`OVER BUDGET by ${total - max} B`);
    return 1;
  }
  console.log(`HEADROOM: ${max - total} B`);
  return 0;
}

async function reportOnly(urls) {
  let grand = 0;
  for (const cssUrl of urls) {
    const cssRes = await get(cssUrl);
    const css = cssRes.body.toString("utf8");
    const refs = woff2Refs(css, cssUrl);
    console.log(`CSS: ${cssUrl}`);
    console.log(`     response body ${cssRes.bytes} B, ${refs.length} woff2 reference(s)`);
    let sub = cssRes.bytes;
    for (const u of refs) {
      const r = await get(u);
      sub += r.bytes;
      if (r.mismatch) {
        console.error(`WARN: ${tail(u)} content-length ${r.declared} != ${r.bytes} bytes received`);
      }
      console.log(`     ${padL(r.bytes, 9)} B  ${tail(u)}`);
    }
    console.log(`     subtotal (declared, CSS included): ${sizes(sub)}`);
    console.log("");
    grand += sub;
  }
  console.log(`DECLARED TOTAL: ${sizes(grand)}`);
  console.log("NOTE: declared >= fetched. A browser downloads a subset or icon file only");
  console.log("      when a glyph inside it actually renders on the page, so the figure");
  console.log("      above is the worst case, not what any single page pulls.");
  return 0;
}

// --- selftest --------------------------------------------------------------
//
// The contrast.js precedent: this turns "the parser is correct" into a check
// row rather than a claim. No network. The fixture is a two-block
// latin+vietnamese snippet in which BOTH blocks point at the same woff2 - the
// Literata 400/600 variable-file case, which is the single easiest way to
// overstate the payload by ~48 KB.

const FIXTURE = [
  "/* vietnamese */",
  "@font-face {",
  "  font-family: 'Literata';",
  "  font-style: normal;",
  "  font-weight: 400;",
  "  src: url(https://fonts.gstatic.com/s/literata/v40/SHARED.woff2) format('woff2');",
  "  unicode-range: U+0102-0103, U+1EA0-1EF9, U+20AB;",
  "}",
  "/* latin */",
  "@font-face {",
  "  font-family: 'Literata';",
  "  font-style: normal;",
  "  font-weight: 600;",
  "  src: url(https://fonts.gstatic.com/s/literata/v40/SHARED.woff2) format('woff2');",
  "  unicode-range: U+0000-00FF, U+0131;",
  "}",
].join("\n");

function selftest() {
  let failed = 0;
  const say = (ok, label, got) => {
    if (!ok) failed++;
    console.log(`${ok ? "  PASS" : "  FAIL"}  ${label}${got === undefined ? "" : `  (got: ${got})`}`);
  };

  const blocks = parseBlocks(FIXTURE);
  say(blocks.length === 2, "fixture parses to 2 subset blocks", blocks.length);
  say(blocks[0] && blocks[0].subset === "vietnamese", "block 1 subset is vietnamese", blocks[0] && blocks[0].subset);
  say(blocks[1] && blocks[1].subset === "latin", "block 2 subset is latin", blocks[1] && blocks[1].subset);
  say(
    blocks.every((b) => b.family === "Literata"),
    "both blocks carry font-family Literata",
    blocks.map((b) => b.family).join("/")
  );
  say(
    blocks.every((b) => b.url && b.url.endsWith(".woff2")),
    "both blocks yield a woff2 url",
    blocks.map((b) => (b.url ? tail(b.url) : "none")).join("/")
  );

  const unique = new Set(blocks.map((b) => b.url));
  say(unique.size === 1, "the duplicate woff2 de-duplicates to 1 unique url", unique.size);

  const kept = blocks.filter((b) => KEEP_SUBSETS.includes(b.subset) && b.url);
  say(kept.length === 2, "both fixture blocks survive the latin+vietnamese filter", kept.length);

  // A subset this tool does not budget must be parsed but not counted.
  const extra = parseBlocks(`${FIXTURE}\n/* cyrillic */\n@font-face { src: url(https://x/y.woff2) format('woff2'); }`);
  const extraKept = extra.filter((b) => KEEP_SUBSETS.includes(b.subset) && b.url);
  say(
    extra.length === 3 && extraKept.length === 2,
    "a cyrillic block parses but is filtered out",
    `${extra.length} parsed / ${extraKept.length} kept`
  );

  // The relative-url resolver used by --report-only.
  const refs = woff2Refs(
    '@font-face{src:url("../webfonts/fa-solid-900.woff2?v=7.2.0") format("woff2")}',
    "https://cdn.example/npm/pkg/css/all.min.css"
  );
  say(
    refs.length === 1 && refs[0] === "https://cdn.example/npm/pkg/webfonts/fa-solid-900.woff2",
    "a relative, cache-tagged woff2 ref resolves and de-tags",
    refs.join(",")
  );

  console.log(`${failed === 0 ? "selftest OK" : "selftest FAILED"} - ${failed} failure(s)`);
  return failed === 0 ? 0 : 1;
}

// --- cli -------------------------------------------------------------------

function usage(code) {
  console.log('usage: node .planning/tools/fontbudget.js "<google fonts css2 url>" --max 153600');
  console.log('       node .planning/tools/fontbudget.js "<url>" ["<url>" ...] --report-only');
  console.log("       node .planning/tools/fontbudget.js --selftest");
  console.log("");
  console.log("       FONTS_URL=\"<url>\" node .planning/tools/fontbudget.js --max 153600");
  console.log("         (the portable form - see the FONTS_URL note at the top of this file:");
  console.log("          a cmd.exe node shim eats everything after the first & in argv)");
  process.exit(code);
}

const argv = process.argv.slice(2);

if (argv.includes("--selftest")) {
  process.exit(selftest());
}
if (argv.length === 0 || argv.includes("-h") || argv.includes("--help")) {
  usage(argv.length === 0 ? 1 : 0);
}

const reportMode = argv.includes("--report-only");
let max = null;
const maxAt = argv.indexOf("--max");
if (maxAt !== -1) {
  max = parseInt(argv[maxAt + 1], 10);
  if (!Number.isFinite(max) || max <= 0) {
    console.error("error: --max needs a positive byte count, e.g. --max 153600");
    process.exit(2);
  }
}

let urls = argv.filter((a, i) => !a.startsWith("--") && !(maxAt !== -1 && i === maxAt + 1));

// Environment fallback. Whitespace-separated, so --report-only can take a
// list. See the FONTS_URL note at the top of this file for why this is the
// form verify.sh uses.
if (urls.length === 0 && process.env.FONTS_URL) {
  urls = process.env.FONTS_URL.trim().split(/\s+/).filter(Boolean);
}

if (urls.length === 0) {
  console.error("error: no URL given (pass one as an argument, or set FONTS_URL)");
  usage(2);
}

// A URL that lost its tail to a cmd.exe shim is the failure this tool must
// not measure past: it would fetch one family and report a passing total.
for (const u of urls) {
  if (/[?&]family=/.test(u) && !/(display=|[&])/.test(u.split("family=").slice(1).join(""))) {
    // single family= with no & and no display= - suspicious for a css2 URL
    // built for two families, but legal for a genuinely single-family request.
    // Warn only; the block count printed below is the real evidence.
    console.error(`WARN: ${u} names one family and carries no & - if you expected two, your shell ate it (see FONTS_URL note)`);
  }
}

(async () => {
  if (reportMode) {
    process.exit(await reportOnly(urls));
  }
  if (max === null) {
    console.error("error: budget mode needs --max <bytes> (or use --report-only)");
    usage(2);
  }
  if (urls.length !== 1) {
    console.error("error: budget mode takes exactly one CSS URL");
    process.exit(2);
  }
  process.exit(await budget(urls[0], max));
})().catch((e) => {
  console.error(`ERROR: ${e && e.message ? e.message : e}`);
  console.error("Nothing was measured. This is a hard failure, not a passing budget.");
  process.exit(2);
});

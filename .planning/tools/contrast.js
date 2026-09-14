#!/usr/bin/env node
//
// WCAG 2.x relative luminance + contrast ratio. Zero dependencies, Node only.
//
//   node .planning/tools/contrast.js "#fg" "#bg" ["#fg2" "#bg2" ...]
//   node .planning/tools/contrast.js --selftest
//
// Why this exists: Phase 2's criterion 4 ("each measure at least 4.5:1") and
// criterion 5 ("each colour token carries its measured ratio in a comment")
// would otherwise be hand-work in the DevTools colour picker. There is no
// Ruby, no local Jekyll build and no accessibility CI on this repo, so every
// contrast number in this milestone is self-enforced. This makes it a command.
//
// Deliberately NOT wired to an npm script and NOT a test framework:
// 01-VALIDATION.md forbids a starter-local build/test pipeline, and
// 02-VALIDATION.md carries that convention forward ("No framework install.
// No npm script. No package.json change.").

// Relative luminance, WCAG 2.x definition:
//   sRGB channel -> linear: c/12.92 when c <= 0.03928, else ((c+0.055)/1.055)^2.4
//   L = 0.2126*R + 0.7152*G + 0.0722*B
function lum(hex) {
  const h = String(hex).replace("#", "").trim();
  const v =
    h.length === 3
      ? h
          .split("")
          .map((c) => c + c)
          .join("")
      : h;
  if (!/^[0-9a-fA-F]{6}$/.test(v)) {
    throw new Error(`not a hex colour: ${hex}`);
  }
  const c = [0, 2, 4]
    .map((i) => parseInt(v.substr(i, 2), 16) / 255)
    .map((x) => (x <= 0.03928 ? x / 12.92 : Math.pow((x + 0.055) / 1.055, 2.4)));
  return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2];
}

// Contrast ratio (hi + 0.05) / (lo + 0.05). Order-independent by construction.
function ratio(a, b) {
  const L1 = lum(a);
  const L2 = lum(b);
  const hi = Math.max(L1, L2);
  const lo = Math.min(L1, L2);
  return (hi + 0.05) / (lo + 0.05);
}

function verdict(r) {
  return r >= 4.5 ? "AA-text" : r >= 3 ? "AA-large/non-text" : "FAIL";
}

// The eight figures published in .planning/research/PITFALLS.md and reproduced
// exactly by 02-RESEARCH.md's validation run. If any of these drifts, either
// the luminance maths is wrong or a palette hex was mistyped — both are
// silent failures otherwise.
const SELFTEST = [
  ["#2b2621", "#faf6ee", 13.9, "body ink on paper"],
  ["#1f1b16", "#faf6ee", 15.88, "heading ink on paper"],
  ["#5c5349", "#faf6ee", 6.99, "muted meta ink on paper"],
  ["#6b6259", "#faf6ee", 5.54, "lightest usable ink on paper"],
  ["#1d4ed8", "#faf6ee", 6.22, "accent on paper"],
  ["#9a3412", "#faf6ee", 6.78, "oxblood accent fallback on paper"],
  ["#1d4ed8", "#2b2621", 2.24, "accent on body ink -> underline mandatory"],
  ["#828282", "#faf6ee", 3.57, "gem default text-color-light, must be re-pointed"],
];

const TOLERANCE = 0.01;

function selftest() {
  let failed = 0;
  for (const [fg, bg, expected, note] of SELFTEST) {
    const got = ratio(fg, bg);
    const delta = Math.abs(got - expected);
    const ok = delta <= TOLERANCE;
    if (!ok) failed++;
    console.log(
      `${ok ? "  PASS" : "  FAIL"}  ${fg} on ${bg} = ${got.toFixed(2)}:1  expected ${expected.toFixed(2)}:1  (d=${delta.toFixed(4)})  ${note}`
    );
  }
  console.log(`${SELFTEST.length} pairs, ${failed} failed (tolerance ${TOLERANCE})`);
  return failed === 0 ? 0 : 1;
}

const args = process.argv.slice(2);

if (args.includes("--selftest")) {
  process.exit(selftest());
}

if (args.length === 0 || args.includes("-h") || args.includes("--help")) {
  console.log('usage: node .planning/tools/contrast.js "#fg" "#bg" ["#fg2" "#bg2" ...]');
  console.log("       node .planning/tools/contrast.js --selftest");
  process.exit(args.length === 0 ? 1 : 0);
}

if (args.length % 2 !== 0) {
  console.error(`error: expected colour PAIRS, got ${args.length} argument(s)`);
  process.exit(1);
}

for (let i = 0; i < args.length; i += 2) {
  const r = ratio(args[i], args[i + 1]);
  console.log(`${args[i]} on ${args[i + 1]} = ${r.toFixed(2)}:1  ${verdict(r)}`);
}

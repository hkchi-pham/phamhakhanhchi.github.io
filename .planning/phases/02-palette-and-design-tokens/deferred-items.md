# Deferred items — Phase 2

## From plan 02-02 (2026-09-14)

- **`assets/css/main.scss` is LF on disk while `core.autocrlf=true`, so the
  `.al-folio-overrides.yml` `local_sha256` row is checkout-dependent.**
  `.gitattributes` forces `eol=lf` for `*.sh` only. The hash recorded in
  02-02 (`8a43e85c…`) was computed over the LF working copy on this machine;
  a fresh clone on Windows would check the file out with CRLF and produce a
  different hash, turning that harness row red for a reason that has nothing
  to do with the override being stale. Out of scope for Phase 2 (it changes
  checkout behaviour for every `.scss` in the repo). Fix when convenient by
  adding `*.scss text eol=lf` to `.gitattributes` and re-recording the hash,
  or by having the harness normalise line endings before hashing.

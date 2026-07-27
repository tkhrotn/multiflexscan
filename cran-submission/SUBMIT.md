# CRAN resubmission: multiflexscan 0.1.0

## Files in this folder

| File | Purpose |
|------|---------|
| `multiflexscan_0.1.0.tar.gz` | Source package tarball (`R CMD build`) |
| `cran-comments.md` | Comments for CRAN maintainers (paste into submission form) |

## Changes since previous submission

In response to the CRAN review:

1. Removed redundant "Functions for" from the start of `Description` in `DESCRIPTION`.
2. Unwrapped the example (no longer in `\donttest{}`). The example uses
   `clustersize = 5`, `maxclusters = 3`, `simcount = 99`, `cores = 1`
   and runs in about 1 second during `R CMD check`.

## Pre-submission checklist

- [x] `R CMD build` completed
- [x] `R CMD check --as-cran` — 0 errors, 0 warnings, 1 NOTE (New submission)
- [x] Example timing under 5 s (elapsed ≈ 0.6 s)
- [x] Maintainer email in `DESCRIPTION`: `t.otani@aichi-cc.jp`
- [x] `cran-comments.md` starts with **Resubmission** section

## Submit

1. Open <https://cran.r-project.org/submit.html>
2. Upload **`multiflexscan_0.1.0.tar.gz`** from this folder
3. Paste the **entire** contents of **`cran-comments.md`** into the comments field
   (it begins with `## Resubmission` — keep that first)
4. Use the maintainer email **`t.otani@aichi-cc.jp`** (must match `DESCRIPTION`)
5. Confirm the submission email from CRAN and follow the link within 24 hours

## After submission

- Wait for CRAN's reply before uploading another version (unless asked to fix and resubmit again)
- If accepted, the package usually appears on CRAN within 1–2 days after confirmation

## Regenerate this folder

From the repository root (`multiflexscanpaper/`):

```bash
R CMD build multiflexscan
R CMD check --as-cran multiflexscan_0.1.0.tar.gz
mkdir -p multiflexscan/cran-submission
cp -f multiflexscan_0.1.0.tar.gz multiflexscan/cran-submission/
cp -f multiflexscan/cran-comments.md multiflexscan/cran-submission/
```

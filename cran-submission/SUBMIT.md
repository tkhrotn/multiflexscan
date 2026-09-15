# CRAN submission: multiflexscan 0.2.0

Update of the CRAN package currently at **0.1.0**.

## Files in this folder

| File | Purpose |
|------|---------|
| `multiflexscan_0.2.0.tar.gz` | Source package tarball (`R CMD build`) |
| `cran-comments.md` | Comments for CRAN maintainers (paste into submission form) |

## Pre-submission checklist

- [x] `DESCRIPTION` Version **0.2.0**
- [x] `NEWS.md` documents changes under 0.2.0
- [x] `R CMD build` completed
- [x] `R CMD check --as-cran` (with CRAN incoming) — **0 errors, 0 warnings, 0 notes**
- [x] Example elapsed time ≈ **0.72 s** (under 5 s / 10 s limits)
- [x] Maintainer email matches `DESCRIPTION`: `t.otani@aichi-cc.jp`
- [x] `cran-comments.md` describes the update from 0.1.0

## Submit

1. Open <https://cran.r-project.org/submit.html>
2. Upload **`multiflexscan_0.2.0.tar.gz`** from this folder
3. Paste the **entire** contents of **`cran-comments.md`** into the comments field
4. Use the maintainer email **`t.otani@aichi-cc.jp`** (must match `DESCRIPTION`)
5. Confirm the submission email from CRAN and follow the link within 24 hours

## After submission

- Wait for CRAN's reply before uploading another version (unless asked to fix and resubmit)
- If accepted, the package usually appears on CRAN within 1–2 days after confirmation

## Regenerate this folder

From the repository root (`multiflexscanpaper/`):

```bash
R CMD build multiflexscan
_R_CHECK_CRAN_INCOMING_=TRUE R CMD check --as-cran multiflexscan_0.2.0.tar.gz
mkdir -p multiflexscan/cran-submission
cp -f multiflexscan_0.2.0.tar.gz multiflexscan/cran-submission/
cp -f multiflexscan/cran-comments.md multiflexscan/cran-submission/
```

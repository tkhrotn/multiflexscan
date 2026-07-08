# CRAN submission: multiflexscan 0.1.0

## Files in this folder

| File | Purpose |
|------|---------|
| `multiflexscan_0.1.0.tar.gz` | Source package tarball (`R CMD build`) |
| `cran-comments.md` | Comments for CRAN maintainers (paste into submission form) |

## Pre-submission checklist

- [x] `R CMD build` completed
- [x] `R CMD check --as-cran` — 0 errors, 0 warnings, 1 NOTE (New submission)
- [x] Maintainer email in `DESCRIPTION`: `t.otani@aichi-cc.jp`
- [x] `cran-comments.md` prepared

Optional before submitting:

- [ ] Run [win-builder](https://win-builder.r-project.org/)
- [ ] Run [rhub](https://r-hub.github.io/rhub/) `check_for_cran()`

## Submit

1. Open <https://cran.r-project.org/submit.html>
2. Upload **`multiflexscan_0.1.0.tar.gz`**
3. Paste the contents of **`cran-comments.md`** into the comments field
4. Use the maintainer email **`t.otani@aichi-cc.jp`** (must match `DESCRIPTION`)
5. Confirm the submission email from CRAN and follow the link within 24 hours

## After submission

- Do not upload a new version until CRAN responds (unless asked to fix and resubmit)
- Typical first review takes several days to a few weeks
- If asked to fix issues, update the package, rebuild, and resubmit with updated `cran-comments.md`

## Regenerate this folder

From the package source directory:

```bash
R CMD build .
mkdir -p cran-submission
cp multiflexscan_0.1.0.tar.gz cran-submission/
cp cran-comments.md cran-submission/
```

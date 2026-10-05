## 0.3.0 submission draft

Local update from 0.2.0 to 0.3.0; not yet submitted.

### Test environment and results (2026-10-02)

* Windows 11 x64, R 4.6.1 (ucrt)
* `R CMD check --as-cran --no-manual`, with
  `_R_CHECK_CRAN_INCOMING_REMOTE_=false` after CRAN index requests timed out
* 0 errors | 0 warnings | 0 notes
* PDF manual generation was not included in this check.
* Executable examples, tests, vignette checks, and vignette rebuilding passed.

### Changes

* Added `model_criteria()`, `C_criterion()`, `RDC()`, and a `logLik()` method.
* AIC respects `k`; AIC/BIC support multiple-model comparisons via standard R.
* Tests cover independent Poisson fits, rank deficiency, null-only models,
  S3 dispatch, multiple-model comparisons, and invalid inputs.
* Statistical algorithms are unchanged.
* Added a self-contained workflow vignette and runnable accessor examples.

Before submission, rerun remote incoming checks, confirm the release baseline, check other platforms,
and build and inspect the PDF manual.

---

## Archived notes for the 0.2.0 submission

This is an update from CRAN version 0.1.0 to 0.2.0.

## Test environments

* local macOS (darwin 25.6.0), R 4.6.0
* `R CMD check --as-cran` (including CRAN incoming checks)

## R CMD check results

0 errors | 0 warnings | 0 notes

## Changes since the previous CRAN release (0.1.0)

### Improvements

* Parallel Monte Carlo replications now use **doRNG** (`%dorng%`) for
  independent random streams across workers. A new `seed` argument seeds
  sequential runs via `set.seed()` and parallel runs via `registerDoRNG()`.
* Added accessors `nclusters()`, `pvalue()`, `clusters()`, and `get_setting()`.
* Added S3 methods `as.data.frame()`, `coef()`, `nobs()`, `AIC()`, and `BIC()`
  for `multiflexscan` objects.

### Bug fixes

* Invalid neighbor indices in list-form `nb` are skipped when building the
  adjacency matrix, instead of stopping with an error.
* Null Monte Carlo replications now use the same simulated counts for both
  candidate search and the subsequent GLM / RDC steps (previously the GLM
  always used the observed counts).
* Empty candidate sets no longer error in the cluster p-value loop; null
  replications with no candidates contribute `-Inf` as the maximum scan
  statistic.
* When several values of `K` attain the same maximum RDC, `nclust` is the
  smallest such `K` (`which.max`).

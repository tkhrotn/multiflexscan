## Submission

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

# multiflexscan NEWS

## multiflexscan 0.3.0

* Added a self-contained workflow vignette and runnable examples for the
  result accessors and model-diagnostic methods.
* Added `model_criteria()` to extract all model-selection criteria by cluster
  count, with `selected = TRUE` to return only the selected model.
* Added `C_criterion()` and `RDC()` for the selected model's criteria.
* Added a `logLik()` method returning the selected Poisson model's likelihood,
  effective parameter count, and number of observations without refitting.
* `AIC()` now respects `k`; `AIC()` and `BIC()` support multiple fitted objects
  through the standard R methods. Previously additional arguments were ignored.
* These extraction methods also work with complete saved 0.2.0 objects. The
  cluster search, model selection, and Monte Carlo algorithms are unchanged.

## multiflexscan 0.2.0

### Improvements

* Improved reproducibility of Monte Carlo results under parallel computation
  by using **doRNG** (`%dorng%`), which provides independent random streams
  across workers. A new `seed` argument seeds sequential runs via `set.seed()`
  and parallel runs via `registerDoRNG()`. Using `set.seed()` alone is not
  sufficient when `cores > 1`.
* Added accessors `nclusters()`, `pvalue()`, `clusters()`, and `get_setting()`.
* Added S3 methods `as.data.frame()`, `coef()`, `nobs()`, `AIC()`, and `BIC()`
  for `multiflexscan` objects so that results can be extracted without relying
  on the internal list structure.

### Bug fixes

* When `nb` is supplied as a list, areas whose neighbor indices fall outside
  `[1, nrow(coordinates)]` are skipped when building the adjacency matrix,
  instead of stopping with an error. Such areas are treated as adjacent to
  no other areas.
* Null Monte Carlo replications now use the same simulated counts for both
  candidate search (`runFleXScan`) and the subsequent GLM / RDC steps.
  Previously the GLM always used the observed counts.
* Empty candidate sets no longer error in the cluster p-value loop
  (`seq_along` instead of `1:length`). Null replications with no candidates
  contribute `-Inf` as the maximum scan statistic (instead of `NA`).
* When several values of `K` attain the same maximum RDC, `nclust` is the
  smallest such `K` (`which.max`), yielding a single integer.

## multiflexscan 0.1.0

### Initial release

* Added `multiflexscan()` for detecting multiple spatial disease clusters
  using the information criterion and scan statistic approach of Takahashi
  and Shimadzu (2020), built on `rflexscan::runFleXScan()`.
* Supports flexible and circular scan statistics, original and restricted
  likelihood ratio statistics, and hot-, cold-, and both-type cluster
  scanning.
* Returns candidate clusters, relative difference criterion (RDC) values,
  selected number of clusters, and Monte Carlo p-values for the overall test
  and individual clusters.
* Added S3 methods `print()`, `summary()`, and `plot()` for `multiflexscan`
  objects.
* Added `choropleth()` to map selected clusters on an `sf` object.
* Parallel Monte Carlo replications via `foreach` and `doSNOW`.

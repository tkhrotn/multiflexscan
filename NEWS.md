# multiflexscan NEWS

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

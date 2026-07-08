## R CMD check results

0 errors | 0 warnings | 0 notes

* checking CRAN incoming feasibility ... NOTE (first submission)

## Test environments

* local macOS, R 4.6.0 (2026-07-07)
* `R CMD check --as-cran` — Status: 1 NOTE, 0 WARNINGs, 0 ERRORs
  (New submission only)

## Notes

* First CRAN release (version 0.1.0).
* Depends on `rflexscan` for flexible and circular spatial scan statistics;
  `multiflexscan` adds information-criterion-based selection of the number of
  clusters and a global Monte Carlo p-value for the selected cluster set.
* Suggested package `sf` is required only for `choropleth()` and is checked with
  `requireNamespace()` at runtime.

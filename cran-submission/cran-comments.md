## Resubmission

This is a resubmission. In response to the CRAN review, we have:

* Removed the redundant "Functions for" at the start of the Description field.
* Unwrapped the example (previously in `\donttest{}`) so that it is executed
  during checks. The example now uses small settings
  (`clustersize = 5`, `maxclusters = 3`, `simcount = 99`, `cores = 1`) and
  runs in about 1 second, well under 5 seconds.

## R CMD check results

0 errors | 0 warnings | 1 note

* checking CRAN incoming feasibility ... NOTE (New submission)

## Test environments

* local macOS, R 4.6.0
* `R CMD check --as-cran` — Status: 1 NOTE, 0 WARNINGs, 0 ERRORs
  (New submission only)

## Notes

* First CRAN release (version 0.1.0).
* Depends on `rflexscan` for flexible and circular spatial scan statistics;
  `multiflexscan` adds information-criterion-based selection of the number of
  clusters and a global Monte Carlo p-value for the selected cluster set.
* Suggested packages `sf` and `spdep` are used only in examples or optional
  functions (`choropleth()` uses `sf` with `requireNamespace()` at runtime;
  examples use the `nc.sids` data from `spdep`, as in `rflexscan`).

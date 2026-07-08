## R CMD check results

0 errors | 0 warnings | 0 notes

* checking CRAN incoming feasibility ... NOTE (first submission)

## Test environments

* local macOS, R 4.6.0 (2026-07-08)
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
* Examples are marked `\donttest{}` and use default arguments including
  `simcount = 999`; they may take several minutes if run interactively.

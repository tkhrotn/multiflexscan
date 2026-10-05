#' Number of clusters selected by the information criterion
#'
#' @param object A \code{multiflexscan} object.
#'
#' @return Integer number of selected clusters.
#'
#' @seealso [pvalue()], [clusters()], [get_setting()]
#'
#' @example inst/examples/small-fit.R
#' @examples
#' nclusters(fit)
#' @export
nclusters <- function(object) {
  if (!inherits(object, "multiflexscan")) {
    stop("'object' must inherit from class 'multiflexscan'.", call. = FALSE)
  }
  object$nclust
}


#' Overall Monte Carlo p-value
#'
#' @param object A \code{multiflexscan} object.
#'
#' @return Numeric overall p-value for the multiple-cluster detection test.
#'
#' @seealso [nclusters()], [clusters()]
#'
#' @example inst/examples/small-fit.R
#' @examples
#' pvalue(fit)
#' @export
pvalue <- function(object) {
  if (!inherits(object, "multiflexscan")) {
    stop("'object' must inherit from class 'multiflexscan'.", call. = FALSE)
  }
  object$P
}


#' Cluster summary table
#'
#' Return a data frame of candidate clusters. By default only the clusters
#' selected by the information criterion are returned.
#'
#' @param object A \code{multiflexscan} object.
#' @param selected Logical; if \code{TRUE} (default), return only the selected
#'   clusters. If \code{FALSE}, return all candidate clusters.
#'
#' @return A data frame with columns \code{NumArea}, \code{MaxDist},
#'   \code{Case}, \code{Expected}, \code{RR}, \code{Stats}, and \code{P}.
#'
#' @seealso [nclusters()], [as.data.frame.multiflexscan], [coef.multiflexscan]
#'
#' @example inst/examples/small-fit.R
#' @examples
#' clusters(fit)
#' clusters(fit, selected = FALSE)
#' @export
clusters <- function(object, selected = TRUE) {
  if (!inherits(object, "multiflexscan")) {
    stop("'object' must inherit from class 'multiflexscan'.", call. = FALSE)
  }
  if (length(object$cluster) == 0L) {
    return(data.frame(
      NumArea = integer(),
      MaxDist = numeric(),
      Case = numeric(),
      Expected = numeric(),
      RR = numeric(),
      Stats = numeric(),
      P = numeric()
    ))
  }

  n_area <- vapply(object$cluster, function(i) length(i$area), integer(1))
  max_dist <- vapply(object$cluster, function(i) i$max_dist, numeric(1))
  n_case <- vapply(object$cluster, function(i) i$n_case, numeric(1))
  stats <- vapply(object$cluster, function(i) i$stats, numeric(1))
  pval <- vapply(object$cluster, function(i) i$pval, numeric(1))
  expected <- vapply(object$cluster, function(i) i$expected, numeric(1))
  RR <- vapply(object$cluster, function(i) i$RR, numeric(1))
  tab <- data.frame(
    NumArea = n_area,
    MaxDist = max_dist,
    Case = n_case,
    Expected = expected,
    RR = RR,
    Stats = stats,
    P = pval
  )
  rownames(tab) <- seq_len(nrow(tab))

  if (isTRUE(selected)) {
    k <- nclusters(object)
    if (k <= 0L) {
      return(tab[0, , drop = FALSE])
    }
    tab <- tab[seq_len(k), , drop = FALSE]
  }
  tab
}


#' Analysis settings
#'
#' @param object A \code{multiflexscan} object.
#'
#' @return A list of analysis settings stored in the object.
#'
#' @seealso [nclusters()], [pvalue()]
#'
#' @example inst/examples/small-fit.R
#' @examples
#' get_setting(fit)
#' @export
get_setting <- function(object) {
  if (!inherits(object, "multiflexscan")) {
    stop("'object' must inherit from class 'multiflexscan'.", call. = FALSE)
  }
  object$setting
}


#' Coerce selected clusters to a data frame
#'
#' @param x A \code{multiflexscan} object.
#' @param row.names Optional row names (ignored).
#' @param optional Logical; ignored.
#' @param ... Additional arguments (ignored).
#'
#' @return A data frame of selected clusters (see [clusters()]).
#'
#' @method as.data.frame multiflexscan
#' @example inst/examples/small-fit.R
#' @examples
#' as.data.frame(fit)
#' @export
as.data.frame.multiflexscan <- function(x, row.names = NULL, optional = FALSE,
                                        ...) {
  clusters(x, selected = TRUE)
}


#' Extract selected cluster summaries
#'
#' @inheritParams clusters
#' @param ... Additional arguments (ignored).
#'
#' @return A data frame of selected clusters (see [clusters()]).
#'
#' @method coef multiflexscan
#' @example inst/examples/small-fit.R
#' @examples
#' coef(fit)
#' @export
coef.multiflexscan <- function(object, ...) {
  clusters(object, selected = TRUE)
}


#' Number of regions in the analysis
#'
#' @inheritParams nclusters
#' @param ... Additional arguments (ignored).
#'
#' @return Number of regions (rows) in the input data.
#'
#' @method nobs multiflexscan
#' @example inst/examples/small-fit.R
#' @examples
#' nobs(fit)
#' @export
nobs.multiflexscan <- function(object, ...) {
  nrow(object$input$case)
}


#' AIC and BIC for the selected cluster model
#'
#' @param object A \code{multiflexscan} object.
#' @param ... Optionally, additional fitted model objects for comparison.
#' @param k Numeric penalty per estimated parameter for \code{AIC}.
#'   The default, 2, gives ordinary AIC.
#'
#' @return With one object, the AIC or BIC of the selected \eqn{K}-cluster
#'   model. With multiple objects, a data frame containing \code{df} and
#'   \code{AIC} or \code{BIC}, as in [stats::AIC()].
#' @details These methods delegate to the standard R methods via [logLik()].
#'   AIC and BIC are distinct from the criterion used to select the clusters;
#'   use [C_criterion()] or [RDC()] for that criterion. Comparisons require
#'   models fitted to the same response data with comparable likelihoods.
#' @seealso [model_criteria()], [logLik.multiflexscan]
#'
#' @method AIC multiflexscan
#' @example inst/examples/small-fit.R
#' @examples
#' AIC(fit)
#' BIC(fit)
#' AIC(fit, k = log(nobs(fit)))
#' @export
AIC.multiflexscan <- function(object, ..., k = 2) {
  if (!is.numeric(k) || length(k) != 1L || !is.finite(k)) {
    stop("'k' must be a finite numeric scalar.", call. = FALSE)
  }
  NextMethod()
}


#' @rdname AIC.multiflexscan
#' @method BIC multiflexscan
#' @export
BIC.multiflexscan <- function(object, ...) {
  NextMethod()
}

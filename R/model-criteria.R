#' Extract model-selection criteria
#'
#' Retrieve stored diagnostics without rerunning the analysis.
#'
#' @param object A \code{multiflexscan} object.
#' @param selected Logical scalar. If \code{FALSE} (default), return all
#'   candidate models, including the null model with \eqn{K = 0}. If
#'   \code{TRUE}, return only the model selected by the cluster criterion.
#'
#' @return \code{model_criteria()} returns a data frame with columns \code{K},
#'   \code{neg2logLik}, \code{AIC}, \code{BIC}, \code{C}, and \code{RDC}.
#'   \code{C_criterion()} and \code{RDC()} return the selected model's
#'   corresponding criterion as a numeric scalar.
#' @details The selected model minimizes \code{C} (equivalently maximizes
#'   \code{RDC}); it does not necessarily minimize AIC or BIC. Ties are
#'   resolved in favor of the smallest \eqn{K}. The returned values describe
#'   Poisson models conditional on the candidate regions found by the scan.
#' @seealso [nclusters()], [logLik.multiflexscan], [AIC.multiflexscan]
#' @example inst/examples/small-fit.R
#' @examples
#' criteria <- model_criteria(fit)
#' model_criteria(fit, selected = TRUE)
#' plot(C ~ K, data = criteria, type = "b")
#' C_criterion(fit)
#' RDC(fit)
#' @export
model_criteria <- function(object, selected = FALSE) {
  if (!inherits(object, "multiflexscan")) {
    stop("'object' must inherit from class 'multiflexscan'.", call. = FALSE)
  }
  if (!is.logical(selected) || length(selected) != 1L || is.na(selected)) {
    stop("'selected' must be TRUE or FALSE.", call. = FALSE)
  }
  out <- data.frame(K = seq_along(object$C) - 1L,
                    neg2logLik = object$neg2logLik,
                    AIC = object$AIC, BIC = object$BIC,
                    C = object$C, RDC = object$RDC)
  if (selected) out <- out[out$K == nclusters(object), , drop = FALSE]
  rownames(out) <- NULL
  out
}

#' @rdname model_criteria
#' @export
C_criterion <- function(object) {
  model_criteria(object, selected = TRUE)$C
}

#' @rdname model_criteria
#' @export
RDC <- function(object) {
  model_criteria(object, selected = TRUE)$RDC
}

#' Log-likelihood of the selected cluster model
#'
#' @param object A \code{multiflexscan} object.
#' @param ... Unused; additional arguments are not supported.
#' @return An object of class \code{logLik}, containing the selected Poisson
#'   model's log-likelihood, with attributes \code{df} (effective number of
#'   estimated parameters) and \code{nobs} (number of regions).
#' @details The likelihood includes the Poisson normalizing constants and is
#'   conditional on the candidate regions. No model is refitted. The effective
#'   parameter count is recovered from the stored identity
#'   \eqn{AIC = -2\log L + 2df}; it is not assumed to equal \eqn{K + 1}
#'   when the model matrix is rank deficient. The Poisson dispersion is fixed.
#' @seealso [model_criteria()], [stats::AIC()], [nobs()]
#' @example inst/examples/small-fit.R
#' @examples
#' logLik(fit)
#' -2 * as.numeric(logLik(fit))
#' AIC(fit)
#' BIC(fit)
#' @method logLik multiflexscan
#' @export
logLik.multiflexscan <- function(object, ...) {
  if (length(list(...))) {
    stop("Additional arguments are not supported.", call. = FALSE)
  }
  selected <- model_criteria(object, selected = TRUE)
  # The stored AIC used the fitted GLM's rank, accounting for any aliasing.
  df <- round((selected$AIC - selected$neg2logLik) / 2)
  structure(-selected$neg2logLik / 2, df = df, nobs = nobs(object),
            class = "logLik")
}

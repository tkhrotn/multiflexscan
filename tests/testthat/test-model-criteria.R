# Independent GLM fits provide a reference for likelihoods and penalties.
criterion_fixture <- function(rank_deficient = FALSE) {
  dat <- data.frame(y = c(3, 4, 8, 10, 12, 15), e = rep(5, 6),
                    z = c(0, 0, 0, 1, 1, 1))
  dat$duplicate <- dat$z
  fits <- list(glm(y ~ 1 + offset(log(e)), family = poisson(), data = dat),
               glm(y ~ z + offset(log(e)), family = poisson(), data = dat))
  if (rank_deficient) {
    fits[[3]] <- glm(y ~ z + duplicate + offset(log(e)),
                    family = poisson(), data = dat)
  }
  K <- seq_along(fits) - 1L
  nll <- vapply(fits, function(x) -2 * as.numeric(logLik(x)), numeric(1))
  criterion <- nll + (3 * K + 1) * log(nrow(dat))
  object <- structure(list(
    neg2logLik = nll, AIC = vapply(fits, AIC, numeric(1)),
    BIC = vapply(fits, BIC, numeric(1)), C = criterion,
    RDC = (criterion[1] - criterion) / criterion[1],
    nclust = tail(K, 1), input = list(case = dat[c("y", "e")])
  ), class = "multiflexscan")
  list(object = object, fits = fits)
}

test_that("diagnostics agree with independently fitted Poisson models", {
  fixture <- criterion_fixture()
  fit <- fixture$object
  tab <- model_criteria(fit)
  expect_named(tab, c("K", "neg2logLik", "AIC", "BIC", "C", "RDC"))
  expect_identical(tab$K, 0:1)
  for (K in tab$K) {
    fit$nclust <- K
    reference <- fixture$fits[[K + 1L]]
    expect_s3_class(logLik(fit), "logLik")
    expect_equal(as.numeric(logLik(fit)), as.numeric(logLik(reference)))
    expect_equal(attr(logLik(fit), "df"), attr(logLik(reference), "df"))
    expect_equal(attr(logLik(fit), "nobs"), nobs(reference))
    expect_equal(AIC(fit), AIC(reference))
    expect_equal(BIC(fit), BIC(reference))
    expect_equal(AIC(fit, k = 3), AIC(reference, k = 3))
    expect_equal(AIC(fit, k = log(nobs(fit))), BIC(fit))
    expect_equal(-2 * as.numeric(logLik(fit)), tab$neg2logLik[K + 1L])
    expect_equal(C_criterion(fit), tab$C[K + 1L])
    expect_equal(RDC(fit), tab$RDC[K + 1L])
    expect_equal(model_criteria(fit, TRUE)$K, K)
    expect_equal(nrow(model_criteria(fit, TRUE)), 1L)
  }
})

test_that("effective parameter count handles rank-deficient models", {
  fixture <- criterion_fixture(rank_deficient = TRUE)
  fit <- fixture$object
  reference <- fixture$fits[[3]]
  expect_equal(nclusters(fit), 2)
  expect_equal(attr(logLik(fit), "df"), 2)
  expect_equal(AIC(fit), AIC(reference))
  expect_equal(BIC(fit), BIC(reference))
  expect_equal(AIC(fit, k = 4), AIC(reference, k = 4))
})

test_that("standard multiple-model comparisons preserve values and labels", {
  fixture <- criterion_fixture()
  fit1 <- fixture$object
  fit0 <- fit1
  fit0$nclust <- 0L
  a <- AIC(fit0, fit1, k = 3)
  b <- BIC(fit0, fit1)
  expect_named(a, c("df", "AIC"))
  expect_named(b, c("df", "BIC"))
  expect_identical(rownames(a), c("fit0", "fit1"))
  expect_identical(rownames(b), c("fit0", "fit1"))
  expect_equal(a$AIC, vapply(fixture$fits, AIC, numeric(1), k = 3))
  expect_equal(b$BIC, vapply(fixture$fits, BIC, numeric(1)))
  expect_equal(a$df, c(1, 2))
  mixed <- AIC(fit0, fixture$fits[[2]])
  expect_equal(mixed$AIC, vapply(fixture$fits, AIC, numeric(1)))
})

test_that("null-only fits and invalid arguments are handled explicitly", {
  fit <- criterion_fixture()$object
  for (name in c("neg2logLik", "AIC", "BIC", "C", "RDC")) {
    fit[[name]] <- fit[[name]][1]
  }
  fit$nclust <- 0L
  expect_identical(model_criteria(fit)$K, 0L)
  expect_equal(model_criteria(fit), model_criteria(fit, TRUE))
  expect_equal(RDC(fit), 0)
  expect_equal(attr(logLik(fit), "df"), 1)
  expect_error(model_criteria(list()), "must inherit")
  expect_error(C_criterion(list()), "must inherit")
  expect_error(RDC(list()), "must inherit")
  for (bad in list(NA, NULL, c(TRUE, FALSE), 1, "TRUE")) {
    expect_error(model_criteria(fit, bad), "TRUE or FALSE")
  }
  expect_error(logLik(fit, REML = TRUE), "Additional arguments")
  for (bad in list(NA_real_, Inf, numeric(), c(2, 3), "2")) {
    expect_error(AIC(fit, k = bad), "finite numeric scalar")
  }
})

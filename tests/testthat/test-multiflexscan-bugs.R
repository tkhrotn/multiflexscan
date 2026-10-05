skip_if_not_installed("spdep")

library(spdep)

test_that("null replications yield finite max RDC and valid overall P", {
  data("nc.sids")
  expected <- nc.sids$BIR74 * sum(nc.sids$SID74) / sum(nc.sids$BIR74)

  fit <- multiflexscan(
    x = nc.sids$x, y = nc.sids$y,
    observed = nc.sids$SID74,
    expected = expected,
    name = rownames(nc.sids),
    nb = ncCR85.nb,
    clustersize = 5,
    maxclusters = 3,
    simcount = 9,
    cores = 1,
    verbose = FALSE,
    seed = 42
  )

  expect_true(is.finite(max(fit$RDC)))
  expect_true(is.numeric(fit$P) && length(fit$P) == 1L)
  expect_gte(fit$P, 0)
  expect_lte(fit$P, 1)
  expect_length(fit$nclust, 1L)
  expect_true(is.integer(fit$nclust) || (is.numeric(fit$nclust) && fit$nclust == as.integer(fit$nclust)))

  # Refit each returned candidate model independently to verify diagnostics.
  criteria <- model_criteria(fit)
  dat <- data.frame(observed = nc.sids$SID74, expected = expected)
  for (K in criteria$K) {
    if (K > 0) {
      dat[[paste0("z", K)]] <- as.integer(seq_len(nrow(dat)) %in%
                                           fit$cluster[[K]]$area)
    }
    reference <- glm(observed ~ . - expected, offset = log(expected),
                     family = poisson(), data = dat)
    expect_equal(criteria$neg2logLik[K + 1L], -2 * as.numeric(logLik(reference)))
    expect_equal(criteria$AIC[K + 1L], AIC(reference))
    expect_equal(criteria$BIC[K + 1L], BIC(reference))
    if (K == nclusters(fit)) {
      expect_equal(as.numeric(logLik(fit)), as.numeric(logLik(reference)))
      expect_equal(attr(logLik(fit), "df"), attr(logLik(reference), "df"))
    }
  }
})

test_that("empty candidate sets complete without error", {
  coords <- expand.grid(x = 1:2, y = 1:2)
  obs <- c(5, 5, 5, 5)
  exp <- c(5, 5, 5, 5)
  nb <- cell2nb(2, 2, type = "rook")

  fit <- multiflexscan(
    x = coords$x, y = coords$y,
    observed = obs,
    expected = exp,
    name = as.character(seq_len(4)),
    nb = nb,
    clustersize = 2,
    maxclusters = 2,
    simcount = 5,
    cores = 1,
    verbose = FALSE,
    seed = 1,
    clusterradius = 0.01
  )

  expect_equal(length(fit$cluster), 0L)
  expect_equal(fit$nclust, 0L)
  expect_true(is.finite(fit$P) || fit$P == 1)
  expect_gte(fit$P, 0)
  expect_lte(fit$P, 1)
  expect_identical(model_criteria(fit)$K, 0L)
  expect_equal(attr(logLik(fit), "df"), 1)
  expect_equal(AIC(fit), model_criteria(fit)$AIC)
  expect_equal(BIC(fit), model_criteria(fit)$BIC)
})

test_that("RDC ties select a single smallest K via which.max", {
  # Mirror selection rule: first maximum => smallest K
  RDC <- c(0.1, 0.5, 0.5, 0.2)
  nclust <- which.max(RDC) - 1L
  expect_length(nclust, 1L)
  expect_equal(nclust, 1L)

  coords <- expand.grid(x = 1:2, y = 1:2)
  fit <- multiflexscan(
    x = coords$x, y = coords$y,
    observed = c(10, 5, 5, 5),
    expected = c(5, 5, 5, 5),
    name = as.character(seq_len(4)),
    nb = cell2nb(2, 2, type = "rook"),
    clustersize = 2,
    maxclusters = 2,
    simcount = 5,
    cores = 1,
    verbose = FALSE,
    seed = 7
  )
  expect_length(fit$nclust, 1L)
  expect_true(fit$nclust >= 0L)
})

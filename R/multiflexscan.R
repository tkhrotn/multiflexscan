#' Detecting multiple spatial disease clusters using the information criterion
#' and scan statistic approach
#'
#' This package provides functions for detecting multiple spatial disease
#' clusters based on the information criterion and scan statistic approach
#' by Takahashi and Shimadzu (2020), using the flexible spatial scan statistic
#' (Tango and Takahashi, 2005) or Kulldorff's circular spatial scan statistic
#' (1997) implemented in the rflexscan package (Otani and Takahashi, 2021).
#'
#' @references
#' \itemize{
#'   \item Takahashi K. and Shimadzu H. (2020). Detecting multiple spatial
#'   disease clusters: information criterion and scan statistic approach.
#'   International Journal of Health Geographics 19:33.
#'   \doi{10.1186/s12942-020-00228-y}
#'   \item Tango T. and Takahashi K. (2005). A flexibly shaped spatial scan
#'   statistic for detecting clusters, International Journal of Health
#'   Geographics 4:11.
#'   \item Otani T. and Takahashi K. (2021). Flexible scan statistics for
#'   detecting spatial disease clusters: The rflexscan R package.
#'   Journal of Statistical Software 99:13.
#'   \doi{10.18637/jss.v099.i13}
#'   \item Takahashi K, Yokoyama T and Tango T. (2010). FleXScan v3.1: Software
#'   for the Flexible Scan Statistic. National Institute of Public Health, Japan,
#'   \url{https://sites.google.com/site/flexscansoftware/home}.
#' }
#'
#' @aliases NULL multiflexscan-package
#'
"_PACKAGE"

flexscan.stattype <- c("ORIGINAL", "RESTRICTED")
flexscan.scanmethod <- c("FLEXIBLE", "CIRCULAR")
flexscan.clustertype <- c("HOT", "COLD", "BOTH")

#' Detect multiple spatial clusters using the flexible/circular scan statistic
#'
#' This function analyzes spatial count data using the flexible spatial scan
#' statistic developed by Tango and Takahashi (2005) or Kulldorff's circular
#' spatial scan statistic (1997), and detects multiple disease clusters by
#' selecting the number of clusters with an information criterion.
#'
#' @details
#' Centroid coordinates for each region should be specified by Cartesian
#' coordinates using arguments \code{x} and \code{y}. We recommend transforming
#' latitude and longitude onto an appropriate projected coordinate system before
#' calling this function.
#'
#' The function first obtains non-overlapping candidate clusters by calling
#' \code{rflexscan::runFleXScan()}, then fits a sequence of Poisson generalized
#' linear models with cluster indicators and the expected counts as offsets. The
#' selected number of clusters is the value that maximizes the relative
#' difference criterion (RDC). The global p-value is calculated by Monte Carlo
#' simulation under the null hypothesis of no clustering.
#'
#' The relative difference criterion for a model with \eqn{K} clusters is
#' \deqn{\mathrm{RDC}_K = \frac{C_0 - C_K}{C_0},}
#' where \eqn{C_K} is the information criterion of Takahashi and Shimadzu
#' (2020). The selected number of clusters \code{nclust} is the value of
#' \eqn{K} that maximizes \code{RDC}.
#'
#' Monte Carlo p-values follow the rank-based convention used in
#' \pkg{rflexscan}:
#' \deqn{p = \frac{\mathrm{rank}}{M + 1},}
#' where \eqn{M} is \code{simcount}. The overall p-value \code{P} compares the
#' maximum \code{RDC} from the observed data with maxima from datasets simulated
#' under the null Poisson model. Cluster-level p-values \code{pval} compare each
#' candidate cluster's scan statistic \code{stats} with statistics from the
#' simulated datasets.
#'
#' @param x
#' A vector of X-coordinates.
#'
#' @param y
#' A vector of Y-coordinates.
#'
#' @param observed
#' A vector with the observed number of disease cases.
#'
#' @param expected
#' A vector with the expected number of disease cases under the null hypothesis.
#' This is used with the Poisson model.
#'
#' @param nb
#' A neighbours list or an adjacency matrix. When a list is supplied, element
#' \code{nb[[i]]} gives the indices of regions adjacent to region \code{i}.
#' When a matrix is supplied, non-zero entries indicate adjacency (the diagonal
#' is ignored in the stored result).
#'
#' @param name
#' A vector of names of each area.
#'
#'
#' @param clustertype
#' Type of cluster to be scanned.
#' \describe{
#'   \item{"HOT"}{Hot-spot clusters with elevated risk.}
#'   \item{"COLD"}{Cold-spot clusters with reduced risk.}
#'   \item{"BOTH"}{Hot- and cold-spot clusters simultaneously.}
#' }
#' 
#' @param clustersize
#' Maximum spatial cluster size \eqn{S}, i.e., the maximum number of regions
#' included in a detected cluster.
#'
#' @param clusterradius
#' Upper bound on the spatial radius of candidate scanning windows, in the same
#' units as \code{x} and \code{y}. The default \code{.Machine$double.xmax} 
#' imposes no radius limit. Choose a value consistent with the projected 
#' coordinate system used for \code{x} and \code{y}.
#' 
#' @param maxclusters
#' The maximum number of clusters to be detected.
#'
#' @param stattype
#' Statistic type to be used (case-insensitive).
#' \describe{
#'   \item{"ORIGINAL"}{the likelihood ratio statistic by Kulldorff and
#'   Nagarwalla (1995)}
#'   \item{"RESTRICTED"}{the restricted likelihood ratio statistic by Tango
#'   (2008), with a preset parameter \code{ralpha} for restriction}
#' }
#'
#' @param scanmethod
#' Scanning method to be used (case-insensitive).
#' \describe{
#'   \item{"FLEXIBLE"}{flexible scan statistic by Tango and Takahashi (2005)}
#'   \item{"CIRCULAR"}{circular scan statistic by Kulldorff (1997)}
#' }
#'
#' @param ralpha
#' Threshold parameter of the mid-p-value for the restricted likelihood ratio
#' statistic.
#'
#' @param simcount
#' The number of Monte Carlo replications to calculate a p-value for statistical
#' test.
#'
#' @param verbose
#' Print progress messages.
#'
#' @param cores
#' The number of CPU cores used for Monte Carlo replications.
#'
#' @param parallel_type
#' Type of parallel backend passed to \code{parallel::makeCluster()} when
#' distributing Monte Carlo replications across worker processes (default
#' \code{"PSOCK"}).
#'
#'
#' @return
#' A list of class \code{"multiflexscan"} with the following components:
#' \describe{
#'   \item{call}{The matched call.}
#'   \item{input}{A list with \code{coordinates} (centroid matrix),
#'   \code{case} (data frame of observed and expected counts), and
#'   \code{adj_mat} (binary adjacency matrix with zero diagonal).}
#'   \item{cluster}{A list of candidate clusters returned by
#'   \code{rflexscan::runFleXScan()}, each extended with Monte Carlo
#'   \code{rank} and \code{pval}. Each element contains \code{area} (integer
#'   indices into the input regions), \code{name}, \code{max_dist},
#'   \code{n_case}, \code{expected}, \code{RR}, \code{stats}, \code{pval},
#'   and \code{rank}.}
#'   \item{RDC}{Numeric vector of relative difference criterion values for
#'   \eqn{K = 0, 1, \ldots} clusters.}
#'   \item{neg2logLik, AIC, BIC, C}{Numeric vectors of model-selection
#'   criteria for \eqn{K = 0, 1, \ldots} clusters.}
#'   \item{nclust}{Selected number of clusters (index \eqn{K} with maximum
#'   \code{RDC}).}
#'   \item{P}{Monte Carlo p-value for the overall clustering test.}
#'   \item{rank}{Rank of the observed maximum \code{RDC} among simulated
#'   maxima.}
#'   \item{null_dist}{Numeric vector of maximum \code{RDC} values from Monte
#'   Carlo replications.}
#'   \item{setting}{A list recording analysis settings such as \code{simcount},
#'   \code{maxclusters}, \code{clustersize}, \code{clusterradius},
#'   \code{stattype}, \code{scanmethod}, and \code{clustertype}.}
#' }
#'
#' @seealso [rflexscan::rflexscan], [summary.multiflexscan],
#' [plot.multiflexscan], [choropleth]
#'
#' @examples
#' \donttest{
#' if (requireNamespace("spdep", quietly = TRUE)) {
#'   # load sample data (North Carolina SIDS data)
#'   library(spdep)
#'   data("nc.sids")
#'
#'   # calculate the expected numbers of cases
#'   expected <- nc.sids$BIR74 * sum(nc.sids$SID74) / sum(nc.sids$BIR74)
#'
#'   fit <- multiflexscan(
#'     x = nc.sids$x, y = nc.sids$y,
#'     observed = nc.sids$SID74,
#'     expected = expected,
#'     name = rownames(nc.sids),
#'     nb = ncCR85.nb
#'   )
#'   print(fit)
#'   summary(fit)
#'   plot(fit)
#' }
#' }
#'
#' @references
#'   Tango T. and Takahashi K. (2005). A flexibly shaped spatial scan
#'   statistic for detecting clusters, International Journal of Health
#'   Geographics 4:11.
#'
#'   Kulldorff M. and Nagarwalla N. (1995). Spatial disease clusters:
#'   Detection and Inference. Statistics in Medicine 14:799-810.
#'
#'   Kulldorff M. (1997). A spatial scan statistic. Communications in
#'   Statistics: Theory and Methods, 26:1481-1496.
#'
#'   Tango T. (2008). A spatial scan statistic with a restricted
#'   likelihood ratio. Japanese Journal of Biometrics 29(2):75-95.
#'
#'   Takahashi K. and Shimadzu H. (2020). Detecting multiple spatial
#'   disease clusters: information criterion and scan statistic approach.
#'   International Journal of Health Geographics 19:33.
#'   \doi{10.1186/s12942-020-00228-y}
#'
#'   Otani T. and Takahashi K. (2021). Flexible scan statistics for
#'   detecting spatial disease clusters: The rflexscan R package.
#'   Journal of Statistical Software 99:13.
#'   \doi{10.18637/jss.v099.i13}
#'
#' @importFrom rflexscan runFleXScan
#' @importFrom utils capture.output setTxtProgressBar txtProgressBar
#' @importFrom stats BIC glm logLik poisson rpois symnum
#' @importFrom foreach foreach %dopar%
#' @importFrom doSNOW registerDoSNOW
#' @importFrom parallel makeCluster stopCluster detectCores
#'
#' @export
#'
multiflexscan <- function(x, y,
                          name, observed, expected, nb,
                          clustertype="HOT",
                          clustersize=15,
                          clusterradius=.Machine$double.xmax,
                          maxclusters=10,
                          stattype="ORIGINAL",
                          scanmethod="FLEXIBLE",
                          ralpha=0.2,
                          simcount=999,
                          verbose=FALSE,
                          cores = max(1, parallel::detectCores() - 1),
                          parallel_type = "PSOCK") {
  call <- match.call()
  
  stattype <- match.arg(toupper(stattype), flexscan.stattype)
  scanmethod <- match.arg(toupper(scanmethod), flexscan.scanmethod)
  clustertype <- match.arg(toupper(clustertype), flexscan.clustertype)
  
  # replace space
  name <- gsub(" ", "_", name)
  
  if (!missing(x) && !missing(y)) {
    coordinates <- cbind(x, y)
    latlon <- FALSE
  } else {
    stop("Coordinates are not properly specified.")
  }
  
  if (missing(observed)) {
    stop("Observed numbers of diseases are not specified.")
  }

  if (missing(expected)) {
    stop("Expected numbers of diseases are not specified.")
  }

  input_lengths <- c(length(x),
                     length(y),
                     length(name),
                     length(observed),
                     length(expected))
  if (length(unique(input_lengths)) != 1) {
    stop(
      paste0("The lengths of x, y, name, observed, and expected must be equal.",
             " Actual lengths: x = ", input_lengths[1], ", y = ", input_lengths[2],
             ", name = ", input_lengths[3], ", observed = ", input_lengths[4], 
             ", expected = ", input_lengths[5]))
  }

  if (any(is.na(observed))) {
    stop("NA values found in 'observed'. Please remove or impute missing data.", call. = FALSE)
  }
  if (any(is.na(expected))) {
    stop("NA values found in 'expected'. Please remove or impute missing data.", call. = FALSE)
  }

  case <- cbind(observed, expected)
  colnames(case) <- c("observed", "expected")
  model <- "POISSON"

  if (any(observed < 0)) {
    stop("Negative values found in 'observed'. All observed counts must be non-negative.", call. = FALSE)
  }
  if (any(expected <= 0)) {
    stop("Non-positive values found in 'expected'. All expected counts must be greater than 0.", call. = FALSE)
  }

  row.names(coordinates) <- as.character(name)
  row.names(case) <- as.character(name)

  if (missing(nb)) {
    stop("A neighbours list or an adjacency matrix are not specified.")
  }

  if (maxclusters < 1) {
    stop("'maxclusters' must be at least 1.")
  }
  if (simcount < 1) {
    stop("'simcount' must be at least 1.")
  }
  if (cores < 1) {
    stop("'cores' must be at least 1.")
  }
  limit_cores <- Sys.getenv("_R_CHECK_LIMIT_CORES_", unset = "")
  if (nzchar(limit_cores)) {
    if (tolower(limit_cores) %in% c("true", "default", "warn")) {
      cores <- min(cores, 2L)
    } else {
      cores <- min(cores, as.integer(limit_cores))
    }
  }
  if (clustersize < 1) {
    stop("'clustersize' must be at least 1.")
  }
  
  if (is.matrix(nb)) {
    if (!all(dim(nb) == nrow(coordinates))) {
      stop("When 'nb' is a matrix, its number of rows and columns must match the number of areas.")
    }
    adj_mat <- nb
  } else {
    if (length(nb) != nrow(coordinates)) {
      stop("When 'nb' is a list, its length must match the number of areas.")
    }
    adj_mat <- matrix(0, nrow = nrow(coordinates), ncol = nrow(coordinates))
    for (i in 1:nrow(coordinates)) {
      if (any(nb[[i]] < 1 | nb[[i]] > nrow(coordinates))) {
        stop(
          sprintf(
            "nb[[%d]] contains indices out of bounds [1, %d]: %s",
            i, nrow(coordinates), paste(nb[[i]], collapse = ", ")
          )
        )
      }
      adj_mat[i, nb[[i]]] <- 1
    }
  }
  row.names(adj_mat) <- row.names(coordinates)
  colnames(adj_mat) <- row.names(coordinates)
  diag(adj_mat) <- 2
  
  setting <- list()
  setting$clustersize <- clustersize
  setting$radius <- 6370
  setting$model <- 0
  setting$stattype <- as.integer(stattype == "RESTRICTED")
  setting$scanmethod <- as.integer(scanmethod == "CIRCULAR")
  setting$ralpha <- ralpha
  setting$cartesian <- as.integer(!latlon)
  setting$simcount <- 0
  setting$rantype <- 0
  setting$secondary <- maxclusters - 1
  
  if (toupper(clustertype) == "HOT") {
    setting$clustertype <- 1
  } else if (toupper(clustertype) == "COLD") {
    setting$clustertype <- 2
  } else if (toupper(clustertype) == "BOTH") {
    setting$clustertype <- 3
  }
  
  setting$clusterradius <- clusterradius

  run_replication <- function(i) {
    if (i == 0) {
      capture.output({
        clst <- runFleXScan(setting, case, coordinates, adj_mat)
      })
    } else {
      sim_Observed <- vapply(case[, "expected"], rpois, integer(1), n = 1L)
      sim_case <- case
      sim_case[, "observed"] <- sim_Observed

      # run FleXScan
      capture.output({
        clst <- runFleXScan(setting, sim_case, coordinates, adj_mat)
      })
    }

    # create cluster indicator variables
    if (length(clst) == 0) {
      cas_tmp <- as.data.frame(case)
    } else {
      Z <- sapply(clst, function(clstr) {
        z <- rep(0, nrow(case))
        z[clstr$area] <- 1
        return(z)
      })
      cas_tmp <- cbind(case, as.data.frame(Z))
    }

    neg2logLik <- numeric()
    aic <- numeric()
    bic <- numeric()
    C <- numeric()
    for (K in 0:length(clst)) {
      retval <- glm(
        observed ~ . - expected,
        offset = log(expected),
        family = poisson(link = "log"),
        data = cas_tmp[, 1:(2 + K)]
      )
      neg2logLik <- c(neg2logLik, -2 * logLik(retval))
      aic <- c(aic, retval$aic)
      bic <- c(bic, BIC(retval))
      C <- c(C, -2 * logLik(retval) + (3 * K + 1) * log(nrow(case)))
    }
    RDC <- (C[1] - C) / C[1]

    nclust <- which(RDC == max(RDC)) - 1

    if (i == 0) {
      list(clst, neg2logLik, aic, bic, C, RDC, nclust)
    } else {
      max_stat <- if (length(clst) > 0) clst[[1]]$stats else NA_real_
      list(c(max(RDC), max_stat))
    }
  }

  if (cores == 1L) {
    if (verbose) {
      pb <- txtProgressBar(max = simcount, style = 3)
      on.exit(try(close(pb), silent = TRUE), add = TRUE)
    }
    results <- vector("list", simcount + 1L)
    for (i in 0:simcount) {
      results[[i + 1L]] <- run_replication(i)
      if (verbose) {
        setTxtProgressBar(pb, i)
      }
    }
    if (verbose) {
      close(pb)
    }
    results <- do.call(c, results)
  } else {
    cl <- makeCluster(cores, type = parallel_type)
    on.exit(stopCluster(cl), add = TRUE)
    registerDoSNOW(cl)

    if (verbose) {
      pb <- txtProgressBar(max = simcount, style = 3)
      on.exit(try(close(pb), silent = TRUE), add = TRUE)
      progress <- function(n) setTxtProgressBar(pb, n)
      opts <- list(progress = progress)
    } else {
      opts <- list()
    }

    results <- foreach(
      i = 0:simcount,
      .combine = c,
      .inorder = TRUE,
      .options.snow = opts,
      .packages = "rflexscan"
    ) %dopar% {
      run_replication(i)
    }

    if (verbose) {
      close(pb)
    }
  }
  
  clst <- results[[1]]
  neg2logLik <- results[[2]]
  aic <- results[[3]]
  bic <- results[[4]]
  C <- results[[5]]
  RDC <- results[[6]]
  nclust <- results[[7]]
  
  null <- matrix(unlist(results[8:(simcount + 7)]), nrow = simcount, ncol = 2, byrow = T)
  maxRDC_null <- null[,1]
  maxLambda_null <- null[,2]
  
  for (i in 1:length(clst)) {
    clst[[i]]$rank <- (sum(maxLambda_null >= clst[[i]]$stats) + 1)
    clst[[i]]$pval <- clst[[i]]$rank / (simcount + 1)
  }
  
  rank <- (sum(maxRDC_null >= RDC[nclust + 1]) + 1)
  pval <- rank / (simcount + 1)
  
  colnames(case) <- c("Observed", "Expected")
  
  adj_mat_input <- adj_mat
  diag(adj_mat_input) <- 0
  adj_mat_input <- (adj_mat_input > 0) * 1
  
  setting$simcount <- simcount
  setting$model <- model
  setting$stattype <- stattype
  setting$scanmethod <- scanmethod
  setting$cartesian <- !latlon
  setting$maxclusters <- maxclusters
  setting$cores <- cores
  setting$clustertype <- clustertype
  
  input <- list()
  input$coordinates <- coordinates
  input$case <- case
  input$adj_mat <- adj_mat_input
  
  retval <- list(call = call, input = input, cluster = clst,
                 RDC = RDC, neg2logLik = neg2logLik, AIC = aic, BIC = bic, C = C,
                 nclust = nclust, P = pval, rank = rank, null_dist = maxRDC_null,
                 setting = setting)
  class(retval) <- "multiflexscan"
  
  return(retval)
}


#' Print multiflexscan object
#' 
#' Print method for \code{multiflexscan} objects.
#'
#' @param x
#' A \code{multiflexscan} object to be printed.
#'
#' @param ...
#' Ignored.
#'
#' @return
#' The input object, invisibly.
#'
#' @seealso [multiflexscan], [summary.multiflexscan]
#' 
#' @method print multiflexscan
#' @export
#' 
print.multiflexscan <- function(x, ...) {
  cat("\nCall:\n", paste(deparse(x$call), sep = "\n", collapse = "\n"), 
      "\n\n", sep = "")
  
  cat("Number of clusters selected: ", x$nclust, "\n", sep = "")
  cat("P-value:", x$P, "\n\n")
}


#' Plot method for the \code{multiflexscan} object. The neighborhood graph is
#' drawn with \pkg{igraph}, following \code{plot.rflexscan()}.
#'
#' @param x
#' A \code{multiflexscan} object.
#'
#' @param rank
#' Integer vector specifying the clusters to highlight.
#'
#' @param pval
#' Maximum cluster-level p-value for a candidate cluster to be highlighted.
#'
#' @param vertexsize
#' Size of region centroids in the igraph plot.
#'
#' @param xlab
#' Label of the x-axis.
#'
#' @param ylab
#' Label of the y-axis.
#'
#' @param xlim
#' Limits of the x-axis.
#'
#' @param ylim
#' Limits of the y-axis.
#'
#' @param col
#' Colors used for highlighted clusters.
#'
#' @param frame_color
#' Color used for neighborhood edges and vertex frames not highlighted as
#' clusters.
#'
#' @param vertex_color
#' Color used for region centroids that are not highlighted as clusters.
#'
#' @param ...
#' Additional arguments passed to \code{igraph::plot.igraph()}.
#'
#' @return
#' The input object, invisibly.
#'
#' @seealso [multiflexscan], [choropleth], [rflexscan::plot.rflexscan]
#'
#' @importFrom grDevices palette
#' @method plot multiflexscan
#' @export
#'
plot.multiflexscan <- function(x,
                               rank = 1:x$nclust,
                               pval = 1,
                               vertexsize = max(x$input$coordinates[, 1]) -
                                 min(x$input$coordinates[, 1]),
                               xlab = colnames(x$input$coordinates)[1],
                               ylab = colnames(x$input$coordinates)[2],
                               xlim = c(min(x$input$coordinates[, 1]),
                                        max(x$input$coordinates[, 1])),
                               ylim = c(min(x$input$coordinates[, 2]),
                                        max(x$input$coordinates[, 2])),
                               col = palette(),
                               frame_color = "gray40",
                               vertex_color = "white",
                               ...) {
  adj_mat <- x$input$adj_mat
  diag(adj_mat) <- 0
  plot_mat <- adj_mat * 1
  for (i in seq_along(x$cluster)) {
    area <- x$cluster[[i]]$area
    if (length(area) >= 2L) {
      sub_mat <- plot_mat[area, area, drop = FALSE]
      sub_mat[sub_mat > 0] <- 10L * i
      plot_mat[area, area] <- sub_mat
    }
  }

  g <- igraph::graph_from_adjacency_matrix(
    plot_mat, mode = "undirected", diag = FALSE, weighted = TRUE
  )
  igraph::V(g)$size <- vertexsize
  igraph::V(g)$frame.color <- frame_color
  igraph::V(g)$color <- vertex_color
  igraph::V(g)$label <- ""
  igraph::E(g)$color <- frame_color

  for (i in 1:min(length(col), length(x$cluster))) {
    if (i %in% rank && x$cluster[[i]]$pval <= pval) {
      igraph::V(g)$color[x$cluster[[i]]$area] <- col[i]
      igraph::E(g)$color[igraph::E(g)$weight == 10 * i] <- col[i]
    }
  }

  if (x$setting$cartesian) {
    igraph::plot.igraph(
      g, axes = TRUE,
      layout = as.matrix(x$input$coordinates[, c(1, 2)]),
      rescale = FALSE,
      xlab = xlab, ylab = ylab, xlim = xlim, ylim = ylim, ...
    )
  } else {
    igraph::plot.igraph(
      g, axes = TRUE,
      layout = as.matrix(x$input$coordinates[, c(2, 1)]),
      rescale = FALSE,
      xlab = ylab, ylab = xlab, xlim = ylim, ylim = xlim, ...
    )
  }
  invisible(x)
}


#' Draw a choropleth map of multiflexscan clusters
#'
#' Draw a choropleth map that highlights clusters selected by the information
#' criterion. The order of \code{regions} must match the input order used in
#' \code{multiflexscan()}.
#'
#' @param x
#' A \code{multiflexscan} object.
#'
#' @param regions
#' An \code{sf} object containing the region geometries.
#'
#' @param selected
#' Integer vector specifying the clusters to highlight. By default, the clusters
#' selected by the information criterion are highlighted.
#'
#' @param col
#' Colors used for highlighted clusters.
#'
#' @param background
#' Fill color for regions not in selected clusters.
#'
#' @param border
#' Border color passed to the geometry plot.
#'
#' @param border.lwd
#' Line width for polygon borders. A value smaller than the graphics default
#' is used by default to reduce overlap in dense maps.
#'
#' @param ...
#' Additional arguments passed to the geometry plot.
#'
#' @return
#' The \code{regions} object with an added \code{cluster} column (integer
#' cluster membership, \code{0} for unclustered regions), invisibly.
#'
#' @note Requires the suggested \pkg{sf} package.
#'
#' @seealso [multiflexscan], [plot.multiflexscan]
#'
#' @export
#'
choropleth <- function(x, regions, selected = seq_len(x$nclust),
                       col = grDevices::palette(),
                       background = "grey95", border = "grey80",
                       border.lwd = 0.25, ...) {
  if (!inherits(x, "multiflexscan")) {
    stop("x must be a multiflexscan object.", call. = FALSE)
  }
  if (!requireNamespace("sf", quietly = TRUE)) {
    stop("Package 'sf' is required to draw a choropleth map.", call. = FALSE)
  }
  if (!inherits(regions, "sf")) {
    stop("regions must be an sf object.", call. = FALSE)
  }
  if (nrow(regions) != nrow(x$input$case)) {
    stop("regions must have the same number of rows as the input data.",
         call. = FALSE)
  }

  cluster <- rep(0L, nrow(regions))
  selected <- selected[selected >= 1 & selected <= length(x$cluster)]
  for (j in seq_along(selected)) {
    cluster[x$cluster[[selected[j]]]$area] <- selected[j]
  }

  fill <- rep(background, nrow(regions))
  for (j in seq_along(selected)) {
    fill[cluster == selected[j]] <- col[(j - 1) %% length(col) + 1]
  }

  graphics::plot(sf::st_geometry(regions), col = fill, border = border,
                 lwd = border.lwd, ...)
  regions$cluster <- cluster
  invisible(regions)
}



#' Summarizing multiflexscan results
#'
#' Summary method for \code{multiflexscan} objects.
#'
#' @param object
#' A \code{multiflexscan} object to be summarized.
#'
#' @param ...
#' Ignored.
#'
#' @return
#' A list of class \code{"summary.multiflexscan"} with components
#' \code{call}, \code{total_areas}, \code{total_cases}, \code{cluster}
#' (data frame of per-cluster statistics), \code{RDC}, \code{nclust},
#' \code{P}, and \code{setting}.
#'
#' @seealso [multiflexscan], [print.summary.multiflexscan]
#'
#' @method summary multiflexscan
#' @export
#'
summary.multiflexscan <- function(object, ...) {
  n_cluster <- length(object$cluster)
  total_areas <- nrow(object$input$case)
  total_cases <- sum(object$input$case[,"Observed"])
  
  n_area <- sapply(object$cluster, function(i){length(i$area)})
  max_dist <- sapply(object$cluster, function(i) {i$max_dist})
  n_case <- sapply(object$cluster, function(i) {i$n_case})
  stats <- sapply(object$cluster, function(i) {i$stats})
  pval <- sapply(object$cluster, function(i) {i$pval})
  
  expected <- sapply(object$cluster, function(i) {i$expected})
  RR <- sapply(object$cluster, function(i) {i$RR})
  table <- data.frame(NumArea=n_area, MaxDist=max_dist, Case=n_case,
                      Expected=expected, RR=RR, Stats=stats, P=pval)
  row.names(table) <- 1:n_cluster
  
  retval <- list(call=object$call,
                 total_areas=total_areas, total_cases=total_cases,
                 cluster=table, RDC = object$RDC, nclust = object$nclust, P = object$P,
                 setting=object$setting)
  
  class(retval) <- "summary.multiflexscan"
  return(retval)
}


#' Print summary of multiflexscan results
#'
#' Print summary of \code{multiflexscan} results to the terminal.
#'
#' @param x
#' A \code{summary.multiflexscan} object to be printed.
#'
#' @param ...
#' Ignored.
#'
#' @return
#' The input object, invisibly.
#'
#' @seealso [multiflexscan], [summary.multiflexscan]
#'
#' @method print summary.multiflexscan
#' @export
#'
print.summary.multiflexscan <- function(x, ...) {
  cat("\nCall:\n", paste(deparse(x$call), sep = "\n", collapse = "\n"),
      "\n\n", sep = "")
  
  cat("Clusters:\n")
  signif <- symnum(x$P, corr = FALSE,
                   na = FALSE, cutpoints = c(0, 0.001, 0.01, 0.05, 0.1, 1),
                   symbols = c("***", "**", "*", ".", " "))
  
  dig <- ceiling(log10(x$setting$simcount))
  
  Pm <- rep("", nrow(x$cluster))
  
  if (x$nclust > 0) {
    Pm[x$nclust] <- format(round(x$P, dig), nsmall = dig)
    sig <- rep(" ", nrow(x$cluster))
    sig[x$nclust] <- signif
  } else {
    Pm[1] <- format(round(x$P, dig), nsmall = dig)
    sig <- rep(" ", nrow(x$cluster))
    sig[1] <- signif
  }
  
  table <- data.frame(NumArea = x$cluster$NumArea,
                      MaxDist = round(x$cluster$MaxDist, 3),
                      Case = x$cluster$Case,
                      Expected = round(x$cluster$Expected, 3),
                      RR = round(x$cluster$RR, 3),
                      Stats = round(x$cluster$Stats, 3),
                      Ps = format(round(x$cluster$P, dig), nsmall = dig),
                      Pm = Pm,
                      sig)

  colnames(table)[ncol(table)] <- ""
  out <- capture.output(print(table, quote = FALSE, right = TRUE, print.gap = 2))
  if ((x$nclust + 1) < length(out)) {
    cat(out[1:(x$nclust+1)], sep = "\n")
    cat(paste0(rep("-", nchar(out[1])), collapse = ""), "\n")
    cat(out[(x$nclust+2):length(out)], sep = "\n")
  } else {
    cat(out, sep = "\n")
    cat(paste0(rep("-", nchar(out[1])), collapse = ""), "\n")
  }
  cat("---\nSignif. codes: ", attr(signif, "legend"), "\n\n")
  
  cat("Number of clusters selected:", x$nclust, "\n")
  cat("")
  cat("Limit length of cluster:", x$setting$clustersize, "\n")
  cat("Number of areas:", x$total_areas, "\n")
  cat("Total cases:", x$total_cases, "\n")
  if (x$setting$cartesian) {
    cat("Coordinates: Cartesian\n")
  } else {
    cat("Coordinates: Latitude/Longitude\n")
  }
  cat("Model:", x$setting$model, "\n")
  cat("Scanning method:", x$setting$scanmethod, "\n")
  cat("Statistic type:", x$setting$stattype, "\n\n")
}

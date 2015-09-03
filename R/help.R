# This document includes the help documentation for non-functions (i.e., the package itself and the example datasets).
# The following code is interpreted by roxygen2 into separate .Rd files:


#' This package contains functions that aid in evaluating the performance of a conservation reserve in protecting the
#' suitable habitat of species of conservation interest.
#'
#' \bold{version 0.1.0}:  Contains two functions (\code{sumRaster} and \code{simReserve}) and three example
#' datasets (\code{demo.sdm}, \code{demo.rsv}, and \code{demo.msk}).  Demo of package submitted as supplement to
#' published manuscript.
#'
#' Bug reports or suggestions for the umbrella package should be directed to <jason.d.carlisle@@gmail.com>
#' @title umbrella:  Evaluating Conservation Reserves
#' @docType package
#' @name umbrella
#' @author Jason D. Carlisle, University of Wyoming, <jason.d.carlisle@@gmail.com>
NULL


#' demo.sdm
#'
#' An example species distribution model (SDM)
#'
#' The SDM is coded such that 1 = suitable habitat and 0 = not suitable habitat.
#' @docType data
#' @name demo.sdm
#' @usage data(demo.sdm)
#' @format Formal class RasterLayer
#' @author Jason D. Carlisle, University of Wyoming, <jason.d.carlisle@@gmail.com>
NULL


#' demo.rsv
#'
#' An example reserve (e.g., a protected area created for an umbrella species).
#'
#' @docType data
#' @name demo.rsv
#' @usage data(demo.rsv)
#' @format Formal class SpatialPolygons
#' @author Jason D. Carlisle, University of Wyoming, <jason.d.carlisle@@gmail.com>
NULL


#' demo.msk
#'
#' An example availability mask (i.e., the polygon within which simulated reserves can be placed).
#'
#' @docType data
#' @name demo.msk
#' @usage data(demo.msk)
#' @format Formal class SpatialPolygons
#' @author Jason D. Carlisle, University of Wyoming, <jason.d.carlisle@@gmail.com>
NULL

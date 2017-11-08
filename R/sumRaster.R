
#' Sum of raster within polygon
#'
#' Returns the sum of raster cells within a polygon.  When the raster is coded as a typical SDM (where 1 = suitable habitat
#' and 0 = non-suitable habitat), returns the number of suitable cells within the polygon.
#'
#' The same process can be done with \code{raster::extract}; however, this
#' function (uses \code{raster::mask} and \code{raster::cellStats}) performed faster in a local test using large raster objects.
#'
#' @param rast A raster object of class RasterLayer.
#' @param poly A spatial polygon object of class SpatialPolygons.
#'
#' @return Numeric, sum of raster cells within a polygon.
#' @author Jason D. Carlisle, University of Wyoming, <jason.d.carlisle@@gmail.com>


sumRaster <- function(rast, poly){
  # Mask the raster down to the shape of the polygon
  rmask <- raster::mask(crop(rast, extent(poly)), poly) # subsets to extent of poly and speeds up mask

  # Sum the remaining cells
  rast.sum <- raster::cellStats(rmask, stat='sum', na.rm=TRUE) # this step is much quicker

  return(rast.sum)
}

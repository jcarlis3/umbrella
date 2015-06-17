
#' Simulate randomly sited reserve
#'
#' This function is used to generate a randomly sited reserve, more specifically,
#' an aggregate of multiple reserve units (distinct polygons).
#'
#' The reserve is built by randomly siting circular polygons of the specified size.  The polygons are allowed to overlap.
#' Circles are iteratively added until the specified area is reached, then a smaller circle is trimmed out if
#' the simulated reserve overshot the specified area.  The user can specify a tolerance for how much bigger/smaller
#' than the specified area is acceptable.
#'
#'
#' @param target.poly A polygon within which all simulated reserves are to be contained.  The availability mask.
#' @param buff.width The radius of the randomly sited circles to be used.
#' @param total.area The target size of the simulated reserve.
#' @param wiggle How much bigger/smaller can the simulated reserves be than \code{tota.area}
#' (in same units as \code{tota.area})
#'
#'
#' @return Object of class SpatialPolygons, the simulated reserve.
#'
#'
#' @author Jason D. Carlisle, University of Wyoming, <jason.d.carlisle@@gmail.com>



simReserve <- function(target.poly, buff.width, total.area, wiggle){

  # Given the buffwidth, calc number of (unique) circles needed
  # (if no overlap, but there likely will be), less one.
  start.num <- trunc((total.area / (pi*(buff.width^2))) - 1)

  #Buffer inside target.poly so circles are contained and don't cross boundary
  target.poly.trim <- gBuffer(target.poly, width=-buff.width)
  #plot(demo.sdm); plot(target.poly, col="grey", add=TRUE)
  #plot(target.poly.trim, col="black", add=TRUE)

  # Create simulated protected area using randomly sited circles
  # Because some likely overlap, more than (start.num) will likely be needed
  rand.poly <- spsample(target.poly.trim, n=start.num, type="random", iter=1000)
  rand.poly <- gBuffer(rand.poly, width=buff.width)
  #gArea(rand.poly) / total.area #percent of needed area covered
  #plot(demo.sdm); plot(target.poly, col="grey", add=TRUE); plot(rand.poly, add=TRUE)

  # Append circles one at a time until total area exceeds target total.area
  repeat{
    # Add one more random circle polygon
    p <- spsample(target.poly.trim, n=1, type="random", iter=1000) # select 1 point
    p <- gBuffer(p, width=buff.width) # buffer that point
    p <- spChFIDs(obj=p, x="2") # change ID in order to have unique IDs for rbind
    rand.poly <- rbind(rand.poly, p) # append to the polys we have
    rand.poly <- gUnaryUnion(rand.poly) # dissolve

    # Stop once total area exceeds target size
    if(gArea(rand.poly) >= total.area) break()
  }

  #update plot
  #plot(demo.sdm); plot(target.poly, col="grey", add=TRUE); plot(rand.poly, add=TRUE)

  # Trim rand.poly down to exact size (+/- wiggle room)
  if(gArea(rand.poly) > total.area){

    repeat{
      # Calc how much area to remove
      to.cut <- gArea(rand.poly) - total.area

      # Calc radius of a circle this size
      rad <- sqrt((to.cut/pi))

      # Add one random polygon inside rand.poly (that won't reach outside rand.poly) to erase
      temp <- gBuffer(rand.poly, width=-rad)
      #plot(temp, add=TRUE)
      x <- spsample(temp, n=1, type="random", iter=1000) # select 1 point
      x <- gBuffer(x, width=rad) # buffer that point

      #plot(demo.dsm); plot(target.poly, col="grey", add=TRUE); plot(rand.poly, add=TRUE); plot(x, add=TRUE, col="red")

      # Erase from rand.poly
      rand.poly <- gDifference(spgeom1=rand.poly, spgeom2=x, byid=FALSE)
      #plot(demo.sdm); plot(target.poly, col="grey", add=TRUE); plot(rand.poly, add=TRUE)

      # Stop once areas match close enough
      if(abs(total.area - gArea(rand.poly)) <= wiggle) break()
    }
  }
  return(rand.poly)

  #plot(demo.sdm); plot(target.poly, col="grey", add=TRUE); plot(rand.poly, add=TRUE)

} #end function

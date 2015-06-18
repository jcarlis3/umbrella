#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# Jason D. Carlisle
# Wyoming Cooperative Fish & Wildlife Research Unit, University of Wyoming
# jason.d.carlisle@gmail.com
# Last updated 6/18/2015
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#

# Create demo data for umbrella package

require(sp)
require(raster)
require(rgdal)
require(rgeos)
require(devtools)


# Demo SDM (1 = suitable habitat, 0 = not suitable habitat)
set.seed(12345)
demo.sdm <- raster(nrows=100, ncols=100, xmn=0, xmx=100, ymn=0, ymx=100)
demo.sdm[] <- rbinom(size=1, n=ncell(demo.sdm), prob=0.3)



# Demo reserve
demo.rsv <- gBuffer(SpatialPoints(coords=cbind(c(35, 50, 60), c(70, 65, 40))), width=15)
demo.rsv.area <- gArea(demo.rsv)


# Demo mask polygon
demo.msk <- gBuffer(SpatialPoints(coords=cbind(50, 50)), width=45)



# Plot
plot(demo.sdm)
plot(demo.rsv, add=TRUE, lwd=2, col="orange")
plot(demo.msk, add=TRUE, lwd=3)



# Save to package /data directory as .rda files
use_data(demo.sdm, overwrite=TRUE)
use_data(demo.rsv, overwrite=TRUE)
use_data(demo.msk, overwrite=TRUE)


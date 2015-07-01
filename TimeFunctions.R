
# Test performance of umbrella::sumRaster vs raster::extract
# All system timing was done on the CarlisleMule PC
# 64-bit Windows 7 Enterprise
# Intel Core2 Quad CPU Q9650 processor
# 8 GB RAM

# R        version 3.2.1
# umbrella version 0.1
# sp       version 1.1-1
# rgdal    version 1.0-4
# raster   version 2.3-40

require(rgdal)
require(umbrella)
require(raster)


# For small, demo datasets, umbrella performs ~ 0.01 seconds slower
data(demo.sdm)
data(demo.rsv)

plot(demo.sdm)
plot(demo.rsv, add=TRUE, lwd=4)

system.time(small.umbrella <- umbrella::sumRaster(rast=demo.sdm, poly=demo.rsv))
system.time(small.raster <- raster::extract(x=demo.sdm, y=demo.rsv, fun=sum, na.rm=TRUE))



# For large, real datasets, umbrella performs much faster (umbrella took ~47 min, raster ran 16.5 hours and didn't finish)
sdm <- raster("C:/Users/jcarlis3/Box Sync/Research/Umbrella/Analysis/Ch1_Spatial/ExamplePYRA/AMAEB04010.tif")
plot(sdm)

rsv <- readOGR("C:/Users/jcarlis3/Box Sync/Research/Umbrella/Analysis/Ch1_Spatial/Shapefiles", "cores_simple_wylam")
plot(rsv, add=TRUE)

system.time(big.umbrella <- umbrella::sumRaster(rast=sdm, poly=rsv))  # 2804 seconds (46.7 minutes)
system.time(big.raster <- raster::extract(x=sdm, y=rsv, fun=sum, na.rm=TRUE))  # ran out of memory and stopped after 16.5 hours

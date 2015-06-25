#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# Jason D. Carlisle
# Wyoming Cooperative Fish & Wildlife Research Unit, University of Wyoming
# jason.d.carlisle@gmail.com
# Last updated 6/25/2015
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#



#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# OUTLINE ----------
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# This code is provided as a supplement to (citation) and demonstrates some of the methods used therein.
# This script contains the following five sections:
    # 1) INSTALL REQUIRED PACKAGES
    # 2) READ INPUT DATA
    # 3) CALCULATE OVERLAP STATISTIC
    # 4) SIMULATE RESERVES AND PERFORM MONTE CARLO TEST
    # 5) INTERPRET THE RESULTS
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#



#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# 1) INSTALL REQUIRED PACKAGES ----------
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# This demo was tested using R version 3.2.1, the R package versions indicated below, and Windows 8.1 Pro.

# This demo makes us of a custom R package called "umbrella" created by Jason Carlisle.  This demo will use three
    # datasets (demo.sdm, demo.rsv, and demo.msk) and two functions (sumRaster and simReserve) from the umbrella package.
    # All functions and datasets from umbrella have help documentation associated with them.
    # Bug reports or suggestions for the umbrella package should be directed to <jason.d.carlisle@gmail.com>.

# As of publication, the umbrella package is not on CRAN, but can be installed from a GitHub repository, which will
    # require using the devtools package.  The umbrella package may be further developed after publication, but this demo
    # is current and compatible with umbrella version 0.1.

# Check if devtools is installed.  If yes, load it.  If not, install it from CRAN, then load it.
# Note, ignore any warning message about Rtools; Rtools is not needed for this demo.
# This demo was tested using the following package versions:
    # devtools version 1.8-0
if("devtools" %in% rownames(installed.packages()) == FALSE){
  install.packages("devtools")
}
require(devtools)

# Check if umbrella is installed.  If yes, load it.  If not, install it from GitHub using devtools, then load it.
# umbrella depends on the sp, rgdal, rgeos, and raster packages, and these will also be installed if not already.
# This demo was tested using the following package versions:
    # umbrella version 0.1
    # sp       version 1.1-1
    # rgdal    version 1.0-4
    # rgeos    version 0.3-11
    # raster   version 2.3-40
if("umbrella" %in% rownames(installed.packages()) == FALSE){
  devtools::install_github("jcarlis3/umbrella@master")
}
require(umbrella)
require(sp)
require(rgdal)
require(rgeos)
require(raster)
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#



#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# 2) READ INPUT DATA ----------
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# Read in example data from the umbrella package
data(demo.sdm)
data(demo.rsv)
data(demo.msk)

# Plot example data
plot(demo.sdm)
plot(demo.rsv, add=TRUE, lwd=2, col="orange")
plot(demo.msk, add=TRUE, lwd=3)

# View help documentations for example data
?demo.sdm
?demo.rsv
?demo.msk
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#



#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# 3) CALCULATE OVERLAP STATISTIC ----------
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# Calculate the total number of suitable cells (coded as "1") in the SDM
(suit.total <- raster::cellStats(demo.sdm, sum))

# Issue ?sumRaster to view help documentation for custom sumRaster function
?sumRaster

# Calculate the number of suitable cells contained within the reserve using sumRaster
(suit.protected <- umbrella::sumRaster(rast=demo.sdm, poly=demo.rsv))

# Calculate the observed overlap statistic (the proportion of the suitable habitat contained within the reserve)
(overlap.observed <- suit.protected / suit.total)
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#



#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# 4) SIMULATE RESERVES AND PERFORM MONTE CARLO TEST ----------
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# Issue ?simReserve to view help documentation for custom simReserve function
?simReserve

# Create simulated reserves using custom simReserve function, and calculate the overlap statistic for each
B <- 80  # number of reserves to create
overlap.expected <- rep(NA, B)  # an empty vector to store results in

# Loop through B number of times, repeatedly simulating a reserve and calculating the overlap statistic
for(i in 1:B){
  # Create simulated reserve within demo.msk that mimics the size and configuration of the actual reserve (demo.rsv)
  sim <- umbrella::simReserve(target.poly=demo.msk, buff.width=8, total.area=rgeos::gArea(demo.rsv), wiggle=2)

  # Calculate the number of suitable cells contained within the simulated reserve
  sim.suit.protected <- umbrella::sumRaster(rast=demo.sdm, poly=sim)

  # Calculate the overlap statistic for the simulated reserve
  overlap.expected[i] <- sim.suit.protected / suit.total
}

# Plot the last simulated reserve (yellow) as an example
plot(demo.sdm)
plot(demo.rsv, add=TRUE, lwd=2, col="orange")
plot(demo.msk, add=TRUE, lwd=3)
plot(sim, add=TRUE, lwd=2, col="yellow")


# Plot null model of the overlap statistic (histogram of expected overlap)
hist(overlap.expected, breaks=15, col="grey", main="Histogram of Expected Overlap\n(Null Model)", xlab="Overlap")

# Expected overlap
(exp.mean <- mean(overlap.expected))

# Two-tailed 95% Monte Carlo confidence interval for expected overlap
(exp.lwr <- quantile(overlap.expected, 0.025)[[1]])
(exp.upr <- quantile(overlap.expected, 0.975)[[1]])

# View expected overlap (solid black line) and CI (dashed lines) on plot
abline(v=exp.mean, lwd=3)
abline(v=exp.lwr, lwd=2, lty="dashed")
abline(v=exp.upr, lwd=2, lty="dashed")

# View observed overlap (solid blue line) on plot
abline(v=overlap.observed, lwd=3, col="blue")

# Calculate the difference between observed and expected overlap (with 95% Monte Carlo CI)
(diff <- round((overlap.observed - exp.mean), 4))
(diff.upr <- round((overlap.observed - exp.lwr), 4))
(diff.lwr <- round((overlap.observed - exp.upr), 4))

# Store the results
(results.df <- data.frame(Species="demo.sdm", diff, diff.lwr, diff.upr))
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#



#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# 5) INTERPRET THE RESULTS ----------
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# Print results
print(results.df)

    # If the difference between observed and expected overlap statistics (diff) is positive,
    # the actual umbrella reserve performed better than expected for that background species.

    # If the difference (diff) is negative,
    # the actual umbrella reserve performed worse than expected for that background species.

    # Regardless of the direction of the difference (diff),
    # if the confidence interval for the difference (diff.lwr and diff.upr) overlaps zero,
    # the actual umbrella reserve performed as expected for that background species.

# Note that your results will vary slightly with each run because of the random process that generates simulated reserves.
# You could write simulated reserves to disk (e.g., as an ESRI shapefile with rgdal::writeOGR) to overcome this problem.
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#



#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# END
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#

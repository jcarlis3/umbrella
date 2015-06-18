#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# Jason D. Carlisle
# Wyoming Cooperative Fish & Wildlife Research Unit, University of Wyoming
# jason.d.carlisle@gmail.com
# Last updated 6/18/2015
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#



#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# OUTLINE ----------
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# This code is provided as a supplement to (citation) and demonstrates some of the methods used therein.
# This script contains the following five sections:
    # 1) REQUIRED PACKAGES
    # 2) INPUT DATA
    # 3) CALCULATE OVERLAP STATISTIC
    # 4) SIMULATE RESERVES AND PERFORM MONTE CARLO TEST
    # 5) INTERPRET THE RESULTS
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#



#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# 1) REQUIRED PACKAGES ----------
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# This demo was tested using R version 3.2.0 and Windows 8.1 Pro
# This demo requires the following packages for handling of spatial data and was tested using the following versions
require(sp)      # version 1.1-1
require(rgdal)   # version 0.9-3
require(rgeos)   # version 0.3-11
require(raster)  # version 2.3-40

# Two custom functions and three example datasets are also required for this demo, and these can be installed as
    # the 'umbrella' package created to accompany this demo.  The umbrella package is not currently on CRAN, but can be
    # installed from a GitHub repository (requires the devtools package).  The umbrella package may be further developed
    # after publication, but this demo is current and compatible with umbrella version 0.1.

# Bug reports or suggestions for the umbrella package should be directed to jason.d.carlisle@gmail.com

# Install umbrella package from a GitHub repository (requires devtools package) and load
require(devtools)
devtools::install_github("jcarlis3/umbrella@master")
require(umbrella)  # version 0.1
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#



#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# 2) INPUT DATA ----------
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# Read in example data from the umbrella package
    # demo.sdm:  an example species distribution model (SDM) where 1 = suitable habitat and 0 = not suitable habitat
    # demo.rsv:  an example reserve created for an umbrella species
    # demo.msk:  an example availabilty mask (i.e., the polygon within which simulated reserves can be placed)

data(demo.sdm)
data(demo.rsv)
data(demo.msk)

# Plot example data
plot(demo.sdm)
plot(demo.rsv, add=TRUE, lwd=2, col="orange")
plot(demo.msk, add=TRUE, lwd=3)
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#



#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# 3) CALCULATE OVERLAP STATISTIC ----------
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# Calculate the total number of suitable cells (coded as "1") in the SDM
(suit.total <- cellStats(demo.sdm, sum))

# Calculate the number of suitable cells contained within the reserve
# Issue ?sumRaster to view help documentation for custom sumRaster function
(suit.protected <- umbrella::sumRaster(rast=demo.sdm, poly=demo.rsv))

# Calculate the observed overlap statistic (the proportion of the suitable habitat contained within the reserve)
(overlap.observed <- suit.protected / suit.total)
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#



#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# 4) SIMULATE RESERVES AND PERFORM MONTE CARLO TEST ----------
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# Create simulated reserves and calculate the overlap statistic for each
# Issue ?simReserve to view help documentation for custom simReserve function

B <- 8  # number of reserves to create
overlap.expected <- rep(NA, B)  # an empty vector to store results in

# Loop through B number of times, repeatedly simulating a reserve and calculating the overlap statistic
for(i in 1:B){
  # Create simulated reserve within demo.msk that mimics the size and configuration of the actual reserve (demo.rsv)
  sim <- umbrella::simReserve(target.poly=demo.msk, buff.width=8, total.area=gArea(demo.rsv), wiggle=2)

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
    # if the confidence interval for the difference (diff.upr and diff.lwr) overlaps zero,
    # the actual umbrella reserve performed as expected for that background species.

# Note that your results will vary slightly with each run because of the random process that generates simulated reserves.
# You could write simulated reserves to disk (e.g., as an ESRI shapefile with rgdal::writeOGR) to overcome this problem.
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#



#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# End of demo
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#

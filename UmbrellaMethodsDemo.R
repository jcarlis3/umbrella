#/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# Jason D. Carlisle
# Wyoming Cooperative Fish & Wildlife Research Unit, University of Wyoming
# Western EcoSystems Technology, Inc.
# jcarlisle@west-inc.com
# Last updated 2/2/2018

# This demo was tested using the following:
    # Windows 10 Pro - 64 bit
    # R version 3.4.3
    # RStudio version 1.1.383
    # The R package versions indicated below
#/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#



#/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# OUTLINE ----------
#/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# This code is provided as a supplement to (Carlisle et al. 2018) and demonstrates some of the methods used therein.
# This script contains the following four sections:
    # 1) INSTALL REQUIRED PACKAGES
    # 2) CALCULATE OVERLAP STATISTIC
    # 3) SIMULATE RESERVES AND PERFORM MONTE CARLO TEST
    # 4) INTERPRET THE RESULTS
#/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#



#/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# 1) INSTALL REQUIRED PACKAGES ----------
#/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# This demo makes us of a custom R package called "umbrella" created by Jason Carlisle.  The package website contains
    # source code for umbrella package's functions and other resources (including this script):
    # https://github.com/jcarlis3/umbrella
    # This demo will use three datasets (demo.sdm, demo.rsv, and demo.msk) and two functions (sumRaster and simReserve)
    # from the umbrella package.  All functions and datasets from umbrella have help documentation associated with them.
    # Bug reports or suggestions for the umbrella package should be directed to <jcarlisle@west-inc.com>.

# As of publication, the umbrella package is not on CRAN, but can be installed from a GitHub repository, which will
    # require using the devtools package.  The umbrella package may be further developed after publication, but this demo
    # is current and compatible with umbrella version 0.1.0.

# Check if devtools is installed.  If yes, load it.  If not, install it from CRAN, then load it.
# Note, ignore any warning message about Rtools; Rtools is not needed for this demo.
# This demo was tested using the following package versions:
    # devtools version 1.13.4
if("devtools" %in% rownames(installed.packages()) == FALSE){
  install.packages("devtools")
}
require(devtools)

# Check if umbrella is installed.  If yes, load it.  If not, install it from GitHub using devtools, then load it.
# umbrella depends on the sp, rgdal, rgeos, and raster packages, and these will also be installed if not already.
# This demo was tested using the following package versions:
    # umbrella version 0.1.0
    # sp       version 1.2-7
    # rgdal    version 1.2-16
    # rgeos    version 0.3-26
    # raster   version 2.6-7
if("umbrella" %in% rownames(installed.packages()) == FALSE){
  devtools::install_github("jcarlis3/umbrella@master")
}
require(umbrella)
require(sp)
require(rgdal)
require(rgeos)
require(raster)

# View help documentation for the umbrella package
?umbrella

# View help documentation for umbrella functions
?sumRaster
?simReserve

# View help documentation for umbrella example datasets
?demo.sdm
?demo.rsv
?demo.msk
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#



#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# 2) CALCULATE OVERLAP STATISTIC ----------
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# QUESTION:  What proportion of a species' suitable habitat is protected by the reserve (i.e., the overlap statistic)?

# Read in and plot the example species distribution model (SDM)
    # Green cells are suitable habitat, grey cells are not suitable habitat
data(demo.sdm)
plot(demo.sdm)

# Read in and plot the example reserve (blue polygon)
data(demo.rsv)
plot(demo.rsv, add=TRUE, border="blue", lwd=6)

# Calculate the total number of suitable cells (coded as "1") in the SDM
(suit.total <- raster::cellStats(demo.sdm, sum))

# Calculate the number of suitable cells contained within the reserve using the sumRaster function
(suit.protected <- umbrella::sumRaster(rast=demo.sdm, poly=demo.rsv))

# Calculate the observed overlap statistic (the proportion of the suitable habitat contained within the reserve)
(overlap.observed <- suit.protected / suit.total)
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#



#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# 3) SIMULATE RESERVES AND PERFORM MONTE CARLO TEST ----------
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# QUESTION:  How does the observed overlap compare to what you'd expect given a reserve of that size?

# Read in and plot the example mask of availability (black polygon)
data(demo.msk)
plot(demo.msk, add=TRUE, border="black", lwd=6)

# Loop through B number of times, repeatedly creating a simulated reserve within the specified mask of availability
    # using the simReserve function, and calculate the overlap statistic for each.  Print a progress bar in the console
    # that will update you on the status of the loop.
B <- 40  # number of reserves to create (note, a person should do more than B=40 iterations)
overlap.expected <- rep(NA, B)  # empty vector to store results in
rsv.area <- rgeos::gArea(demo.rsv)  # store size of the actual reserve, to make simulated reserves the same size

pb <- txtProgressBar(min=1, max=B, style=3)  # initiate progress bar
for(i in 1:B){
  # Create simulated reserve within demo.msk that mimics the size and configuration of the actual reserve (demo.rsv)
  sim <- umbrella::simReserve(target.poly=demo.msk, buff.width=15, total.area=rsv.area, wiggle=10)

  # Calculate the number of suitable cells contained within the simulated reserve
  sim.suit.protected <- umbrella::sumRaster(rast=demo.sdm, poly=sim)

  # Calculate the overlap statistic for the simulated reserve
  overlap.expected[i] <- sim.suit.protected / suit.total

  setTxtProgressBar(pb, i)  # update progress bar
}
close(pb)  # close progress bar

# Plot the last simulated reserve for illustration (yellow polygon)
plot(sim, add=TRUE, col="yellow")

# Plot null model of the overlap statistic (histogram of expected overlap)
hist(overlap.expected, col="grey", main="Histogram of Expected Overlap\n(Null Model)", xlab="Overlap")

# Calculate and plot expected overlap (solid black line)
(exp.mean <- mean(overlap.expected))
abline(v=exp.mean, lwd=3)

# Calculate and plot two-tailed 95% Monte Carlo confidence interval for expected overlap (dashed black lines)
(exp.lwr <- quantile(overlap.expected, 0.025)[[1]])
(exp.upr <- quantile(overlap.expected, 0.975)[[1]])
abline(v=exp.lwr, lwd=2, lty="dashed")
abline(v=exp.upr, lwd=2, lty="dashed")

# Plot observed overlap calculated previously (solid blue line)
abline(v=overlap.observed, lwd=3, col="blue")

# Calculate the difference between observed and expected overlap (with 95% Monte Carlo CI) and store results
results.df <- data.frame(Species="demo.sdm",
                         Diff=round((overlap.observed - exp.mean), 4),
                         Diff.CI.lwr=round((overlap.observed - exp.upr), 4),
                         Diff.CI.upr=round((overlap.observed - exp.lwr), 4))
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#



#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# 4) INTERPRET THE RESULTS ----------
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# Print results
print(results.df)

    # If the difference between observed and expected overlap statistics (Diff) is positive,
    # the actual umbrella reserve performed better than expected for that species.

    # If the difference (Diff) is negative,
    # the actual umbrella reserve performed worse than expected for that species.

    # Regardless of the direction of the difference (Diff),
    # if the confidence interval for the difference (Diff.CI.lwr and Diff.CI.upr) overlaps zero,
    # the actual umbrella reserve performed as expected for that species.

# Note that your results will vary slightly with each run because of the random process that generates simulated reserves.
# You could write simulated reserves to disk (e.g., as an ESRI shapefile with rgdal::writeOGR) to overcome this issue.
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#



#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#
# END
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#

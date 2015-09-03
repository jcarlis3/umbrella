
# Jason Carlisle
# 9/3/2015

# There are two methods to calculate the CI from the Monte Carlo test.  They produce the same result, as shown here

# Some example data
overlap.expected <- runif(80)
overlap.observed <- 1.2




# The way CIs are calculated in the example code and the method described in the paper (more straightforward) ----
# This code comes from the MethodsDemo.R script
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
print(results.df)





# The way I calculated the CIs in my analysis ----
# This code is from the OverlapPostProcess_Aug2015.R script
diffvec <- overlap.observed - overlap.expected
hist(diffvec)

(diffmean <- round(mean(diffvec), 4))
(difflow <- round(quantile(diffvec, 0.025), 4))
(diffupp <- round(quantile(diffvec, 0.975), 4))


# They are equivalent

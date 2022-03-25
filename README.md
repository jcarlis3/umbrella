# umbrella
*Evaluating Conservation Reserves*

This package serves as a static repository for code and methods referenced in [Carlisle et al. 2018](https://doi.org/10.1002/jwmg.21460).  Some functions in this package (i.e., `simReserve`) have been further developed as part of the [`ecoinfo`](https://github.com/jcarlis3/ecoinfo) package.

This package contains functions (and example data) that aid in evaluating the performance of a conservation reserve in protecting the suitable habitat of species of conservation interest.  This package was designed specifically to assess conservation reserves created for an umbrella species--hence the name.

**version 0.1.0**: Contains two functions (`sumRaster` and `simReserve`) and three example datasets (`demo.sdm`, `demo.rsv`, and `demo.msk`).

**Tutorial**: See [UmbrellaMethodsDemo.R](https://github.com/jcarlis3/umbrella/blob/master/UmbrellaMethodsDemo.R) in the top-level directory for a tutorial use of the package including example data.  

**Bugs**: Submit bug reports or suggestions as [Issues](https://github.com/jcarlis3/umbrella/issues).

**To install and load `umbrella` in R, run the following (requires the `devtools` package):**
`devtools::install_github("jcarlis3/umbrella@master")`

`require(umbrella)`

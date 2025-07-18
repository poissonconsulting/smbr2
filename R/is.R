#' Is a CmdStan MCMC Analysis
#'
#' Tests whether x is an object of class 'cmdstan_mcmc_analysis'
#'
#' @param x The object to test.
#'
#' @return A flag indicating whether the test was positive.
#' @export
is.cmdstan_mcmc_analysis <- function(x) {
  inherits(x, "cmdstan_mcmc_analysis")
}

#' Is a CmdStan Analysis
#'
#' Tests whether x is an object of class 'cmdstan_analysis'
#'
#' @param x The object to test.
#'
#' @return A flag indicating whether the test was positive.
#' @export
is.cmdstan_analysis <- function(x) {
  inherits(x, "cmdstan_analysis")
}

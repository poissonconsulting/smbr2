#' Is STAN Code
#'
#' Tests whether x is an object of class 'smb2_code'
#'
#' @param x The object to test.
#' @return A flag indicating whether the test was positive.
#' @export
is.smb2_code <- function(x) {
  inherits(x, "smb2_code")
}

#' Is a STAN Model
#'
#' Tests whether x is an object of class 'smb2_model'
#'
#' @param x The object to test.
#'
#' @return A flag indicating whether the test was positive.
#' @export
is.smb2_model <- function(x) {
  inherits(x, "smb2_model")
}

#' Is a STAN Analysis
#'
#' Tests whether x is an object of class 'smb2_analysis'
#'
#' @param x The object to test.
#'
#' @return A flag indicating whether the test was positive.
#' @export
is.smb2_analysis <- function(x) {
  inherits(x, "smb2_analysis")
}

#' Diagnose Analysis Objects
#'
#' @description
#' Generic function for diagnosing analysis objects.
#'
#' See documentation for specific methods:
#' * [diagnose.cmdstan_mcmc_analysis()]
#'
#' @param x An analysis object.
#' @param ... Additional arguments passed to methods.
#'
#' @return Diagnostic output (format depends on the analysis type).
#' @export
diagnose <- function(x, ...) {
  UseMethod("diagnose")
}

#' Diagnose CmdStan MCMC Analysis
#'
#' @description
#' Provides diagnostic information for CmdStan MCMC analysis objects.
#'
#' For more details on diagnostics and how to address issues see:
#' * https://mc-stan.org/docs/cmdstan-guide/diagnose.html
#'
#' @param x A cmdstan_mcmc_analysis object.
#' @param ... Additional arguments (unused).
#'
#' @return Output from CmdStan's diagnostic function.
#' @export
diagnose.cmdstan_mcmc_analysis <- function(x, ...) {
  chk_unused(...)
  chk::chk_is(x$cmdstan_fit, "CmdStanMCMC")

  x <- capture.output(y <- x$cmdstan_fit$cmdstan_diagnose())
  class(y) <- c("cmdstan_diagnostics", class(y))
  y
}

#' Diagnose CmdStan Variational Analysis
#'
#' @description
#' Provides diagnostic information for CmdStan Variational analysis objects.
#'
#' For more details on diagnostics and how to address issues see:
#' * https://mc-stan.org/docs/cmdstan-guide/diagnose.html
#'
#' @param x A cmdstan_variational_analysis object.
#' @param ... Additional arguments (unused).
#'
#' @return Output from CmdStan's diagnostic function.
#' @export
diagnose.cmdstan_variational_analysis <- function(x, ...) {
  chk_unused(...)
  chk::chk_is(x$cmdstan_fit, "CmdStanVB")

  x <- capture.output(y <- x$cmdstan_fit$cmdstan_diagnose())
  class(y) <- c("cmdstan_diagnostics", class(y))
  y
}

#' Diagnose CmdStan Pathfinder Analysis
#'
#' @description
#' Provides diagnostic information for CmdStan Pathfinder analysis objects.
#'
#' For more details on diagnostics and how to address issues see:
#' * https://mc-stan.org/docs/cmdstan-guide/diagnose.html
#'
#' @param x A cmdstan_pathfinder_analysis object.
#' @param ... Additional arguments (unused).
#'
#' @return Output from CmdStan's diagnostic function.
#' @export
diagnose.cmdstan_pathfinder_analysis <- function(x, ...) {
  chk_unused(...)
  chk::chk_is(x$cmdstan_fit, "CmdStanPathfinder")

  x <- capture.output(y <- x$cmdstan_fit$cmdstan_diagnose())
  class(y) <- c("cmdstan_diagnostics", class(y))
  y
}

#' Print Method for CmdStan MCMC Diagnostics
#'
#' @param x A cmdstan_mcmc_diagnostics object.
#' @param ... Additional arguments (currently unused).
#' @export
print.cmdstan_diagnostics <- function(x, ...) {
  chk_unused(...)
  cat(x$stdout)
}

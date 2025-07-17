#' @export
generics::glance

#' Glance at CmdStanR MCMC Analysis
#'
#' Provides a one-row summary of key diagnostics for MCMC analysis results.
#'
#' @param x A `cmdstan_mcmc_analysis` object.
#' @param rhat The R-hat threshold for convergence.
#' @param esr The effective sample size ratio threshold.
#' @param ... Additional arguments (unused).
#'
#' @return A tibble with one row containing:
#' \describe{
#'   \item{n}{Number of observations in the dataset}
#'   \item{K}{Number of parameters}
#'   \item{nchains}{Number of MCMC chains}
#'   \item{niters}{Number of iterations per chain (post-warmup)}
#'   \item{nthin}{Thinning interval}
#'   \item{ess}{Minimum effective sample size across all parameters}
#'   \item{rhat}{Maximum R-hat value across all parameters}
#'   \item{converged}{Logical indicating convergence (TRUE if max R-hat < rhat threshold)}
#'   \item{num_divergent}{Number of divergent transitions across all chains. 
#'     **Problem indicators**: Any value > 0 indicates sampling issues}
#'   \item{max_treedepth}{Number of transitions that hit maximum tree depth.
#'     **Problem indicators**: Values > 0 may indicate inefficient sampling}
#'   \item{ebfmi}{Minimum Energy Bayesian Fraction of Missing Information across chains.
#'     **Problem indicators**: Values < 0.2 indicate poor adaptation/warmup}
#' }
#'
#' @details
#' **Diagnostic interpretation:**
#' - **Divergent transitions**: Should be 0. Any divergent transitions indicate the 
#'   sampler had numerical issues and results may be unreliable.
#' - **Max treedepth**: Should be 0 or very low. High values suggest the sampler 
#'   is working hard and may benefit from increased `adapt_delta`.
#' - **E-BFMI**: Should be > 0.2. Values < 0.2 suggest poor adaptation, often 
#'   requiring longer warmup or model reparameterization.
#'
#' @seealso [embr::glance()], [diagnose()]
#' @export
glance.cmdstan_mcmc_analysis <- function(x, ...) {
  x2 <- x
  class(x2) <- setdiff(class(x), "cmdstan_mcmc_analysis")
  gl <- glance(x2, ...)
  diag_summary <- x$cmdstan_fit$diagnostic_summary()
  gl$num_divergent <- sum(diag_summary$num_divergent)
  gl$max_treedepth <- sum(diag_summary$num_max_treedepth)
  gl$ebfmi <- signif(min(diag_summary$ebfmi), digits = 3)

  gl
}

#' Glance at CmdStanR Pathfinder Analysis
#'
#' Provides a one-row summary of key diagnostics for Pathfinder analysis results.
#'
#' @param x A `cmdstan_pathfinder_analysis` object.
#' @param ... Additional arguments (unused).
#'
#' @return A tibble with one row containing:
#' \describe{
#'   \item{n}{Number of observations in the dataset}
#'   \item{K}{Number of parameters}
#'   \item{converged}{Logical indicating pathfinder convergence}
#'   \item{return_code}{Pathfinder return code.
#'     **Problem indicators**: Non-zero values indicate pathfinder issues}
#' }
#'
#' @details
#' **Diagnostic interpretation:**
#' - **return_code**: Should be 0. Non-zero values indicate pathfinder 
#'   failed to find a good approximation.
#'
#' @seealso [embr::glance()], [diagnose()]
#' @export
glance.cmdstan_pathfinder_analysis <- function(x, ...) {
  chk_unused(...)
  x2 <- x
  class(x2) <- setdiff(class(x), "cmdstan_pathfinder_analysis")
  gl <- glance(x2)
  gl$nchains <- NULL
  gl$niters <- NULL
  gl$nthin <- NULL
  gl$ess <- NULL
  gl$rhat <- NULL
  gl$return_code <- x$cmdstan_fit$return_codes()
  gl$converged <- gl$return_code == 0
  
  gl
}

#' Glance at CmdStanR Optimization Analysis
#'
#' Provides a one-row summary of optimization analysis results.
#'
#' @param x A `cmdstan_optimize_analysis` object.
#' @param ... Additional arguments (unused).
#'
#' @return A tibble with one row containing:
#' \describe{
#'   \item{n}{Number of observations in the dataset}
#'   \item{K}{Number of parameters}
#'   \item{converged}{Logical indicating optimization convergence}
#'   \item{return_code}{Optimization return code.
#'     **Problem indicators**: Non-zero values indicate optimization issues}
#' }
#'
#' @details
#' **Diagnostic interpretation:**
#' - **return_code**: Should be 0. Non-zero values indicate the optimizer 
#'   encountered issues (e.g., 1 = max iterations reached, 2 = convergence issues).
#'
#' @seealso [embr::glance()]
#' @export
glance.cmdstan_optimize_analysis <- function(x, ...) {
  chk_unused(...)
  x2 <- x
  class(x2) <- setdiff(class(x), "cmdstan_optimize_analysis")
  gl <- glance(x2)
  gl$nchains <- NULL
  gl$niters <- NULL
  gl$nthin <- NULL
  gl$ess <- NULL
  gl$rhat <- NULL
  gl$return_code <- x$cmdstan_fit$return_codes()
  gl$converged <- gl$return_code == 0
  
  gl
}

#' Glance at CmdStanR Laplace Analysis
#'
#' Provides a one-row summary of Laplace approximation analysis results.
#'
#' @param x A `cmdstan_laplace_analysis` object.
#' @param ... Additional arguments (unused).
#'
#' @return A tibble with one row containing:
#' \describe{
#'   \item{n}{Number of observations in the dataset}
#'   \item{K}{Number of parameters}
#'   \item{converged}{Logical indicating optimization convergence}
#'   \item{return_code}{Optimization return code for mode finding.
#'     **Problem indicators**: Non-zero values indicate mode-finding issues}
#' }
#'
#' @details
#' **Diagnostic interpretation:**
#' - **return_code**: Should be 0. Non-zero values indicate the optimizer 
#'   failed to find the posterior mode, invalidating the Laplace approximation.
#'
#' @seealso [embr::glance()]
#' @export
glance.cmdstan_laplace_analysis <- function(x, ...) {
  chk_unused(...)
  x2 <- x
  class(x2) <- setdiff(class(x), "cmdstan_laplace_analysis")
  gl <- glance(x2)
  gl$nchains <- NULL
  gl$niters <- NULL
  gl$nthin <- NULL
  gl$ess <- NULL
  gl$rhat <- NULL
  gl$return_code <- x$cmdstan_fit$return_codes()
  gl$converged <- gl$return_code == 0
  
  gl
}

#' Glance at CmdStanR Variational Analysis
#'
#' Provides a one-row summary of variational inference analysis results.
#'
#' @param x A `cmdstan_variational_analysis` object.
#' @param ... Additional arguments (unused).
#'
#' @return A tibble with one row containing:
#' \describe{
#'   \item{n}{Number of observations in the dataset}
#'   \item{K}{Number of parameters}
#'   \item{converged}{Logical indicating ELBO convergence}
#'   \item{return_code}{Optimization return code.
#'     **Problem indicators**: Non-zero values indicate convergence issues}
#' }
#'
#' @details
#' **Diagnostic interpretation:**
#' - **return_code**: Should be 0. Non-zero values indicate the variational 
#'   algorithm failed to converge to a stable ELBO (Evidence Lower BOund).
#'
#' @seealso [embr::glance()], [diagnose()]
#' @export
glance.cmdstan_variational_analysis <- function(x, ...) {
  chk_unused(...)
  x2 <- x
  class(x2) <- setdiff(class(x), "cmdstan_variational_analysis")
  gl <- glance(x2)
  gl$nchains <- NULL
  gl$niters <- NULL
  gl$nthin <- NULL
  gl$ess <- NULL
  gl$rhat <- NULL
  gl$return_code <- x$cmdstan_fit$return_codes()
  gl$converged <- gl$return_code == 0
  
  gl
}

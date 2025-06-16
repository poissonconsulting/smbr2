#' Analyse CmdStanR MCMC Model
#'
#' Internal method for analysing models using CmdStanR's MCMC sampling.
#' This method is dispatched when \code{stan_engine = "cmdstan-mcmc"} in 
#' \code{\link{analyse.mb_model}}.
#'
#' @param model A mb_model to analyse.
#' @param data A data.frame of the data.
#' @param loaded A loaded CmdStanR model object.
#' @inheritParams embr::analyse.mb_model
#' @param iter_warmup A number of the warmup iterations (defaults to niters).
#' @param ... Additional arguments passed to \code{\link[cmdstanr]{sample}}.
#' @return A cmdstan_mcmc_analysis object.
#' @keywords internal
#' @export
analyse1.cmdstan_mcmc_model <- function(model, data, loaded, nchains, niters, nthin, 
                               quiet, glance, parallel, 
                               iter_sampling = niters * nthin,
                               iter_warmup = niters, 
                               # seed = sample.int(.Machine$integer.max, 1),
                               ...) {
  timer <- timer::Timer$new()
  timer$start()

  obj <- list(model = model, data = data)

  data %<>% modify_data(model = model, numericize_factors = TRUE)
  
  inits <- inits(data, model$gen_inits, nchains = nchains)

  monitor <- embr::monitor(model)
  
  parallel_chains <- ifelse(parallel, nchains, 1L)
  
  # warmup iterations are set to equal the number of post-thinning, post-warmup iterations
  sampling_iter <- niters * nthin
  # warmup_iter <- niters
  
  capture_output <- if (quiet) function(x){
   suppressMessages(suppressWarnings(capture.output(x))) 
  }  else {
    identity
  } 
  capture_output(
    cmdstan_fit <- loaded$sample(
      data = data,
      chains = nchains,
      parallel_chains = parallel_chains,
      iter_warmup = iter_warmup,
      # this is post-warmup iterations in cmdstanr
      iter_sampling = sampling_iter,
      thin = nthin,
      seed = seed,
      init = inits,
      show_messages = !quiet,
      show_exceptions = !quiet,
      ...
    )
  )
  
  draws <- cmdstan_fit$draws(variables = monitor, format = "array")

  obj %<>% c(
    cmdstan_fit = list(cmdstan_fit),
    mcmcr = list(as.mcmcr(draws)),
    nthin = nthin
  )

  obj$duration <- timer$elapsed()
  class(obj) <- c("cmdstan_mcmc_analysis", "cmdstan_analysis", "mb_analysis")

  if (glance) print(glance(obj))

  obj
}

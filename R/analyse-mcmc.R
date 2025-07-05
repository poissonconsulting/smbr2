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
#' @param ... Additional arguments passed to \code{\link[cmdstanr]{sample}}.
#' @return A cmdstan_mcmc_analysis object.
#' @keywords internal
#' @export
analyse1.cmdstan_mcmc_model <- function(model, data, loaded, nchains, niters, nthin, 
                               quiet, glance, parallel, 
                               seed, niters_warmup,
                               ...) {
  conflicting_args <- c("iter_sampling", "iter_warmup", "chains", "parallel_chains",
                        "data", "thin",  "show_messages", "show_exceptions")
  
  dots <- list(...)
  conflicts <- intersect(names(dots), conflicting_args)
  if (length(conflicts) > 0) {
    dots[conflicts] <- NULL
    warning("Ignoring arguments passed via '...' that conflict with function parameters: ", 
            paste(conflicts, collapse = ", "))
  }
  
  timer <- timer::Timer$new()
  timer$start()

  obj <- list(model = model, data = data)

  data %<>% modify_data(model = model, numericize_factors = TRUE)
  
  if("init" %in% names(dots)){
    init <- dots$init
    dots$init <- NULL
  } else {
    init <- inits(data, model$gen_inits, nchains = nchains)
  } 
  
  monitor <- embr::monitor(model)
  
  parallel_chains <- ifelse(parallel, nchains, 1L)

  capture_output <- if (quiet) function(x){
   suppressMessages(suppressWarnings(capture.output(x))) 
  }  else {
    identity
  } 
  capture_output(
    cmdstan_fit <- do.call(loaded$sample, c(list(
      data = data,
      chains = nchains,
      parallel_chains = parallel_chains,
      iter_warmup = niters_warmup,
      # this is post-warmup iterations in cmdstanr
      iter_sampling = niters * nthin,
      thin = nthin,
      seed = seed,
      init = init,
      show_messages = !quiet,
      show_exceptions = !quiet
    ), dots))
  )
  
  draws <- cmdstan_fit$draws(variables = monitor, format = "array")

  obj %<>% c(
    cmdstan_fit = list(cmdstan_fit),
    mcmcr = list(as.mcmcr(draws)),
    nthin = nthin
  )

  obj$duration <- timer$elapsed()
  class(obj) <- c("cmdstan_mcmc_analysis", "cmdstan_analysis", "mb_analysis")

  if (glance){
    print(glance(obj))
    print(diagnose(obj))
  } 

  obj
}

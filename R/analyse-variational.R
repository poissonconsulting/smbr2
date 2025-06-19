#' Analyse CmdStanR Variational Model
#'
#' Internal method for analysing models using CmdStanR's variational inference (ADVI).
#' This method is dispatched when \code{stan_engine = "cmdstan-variational"} in 
#' \code{\link{analyse.mb_model}}.
#'
#' @param model A mb_model to analyse.
#' @param data A data.frame of the data.
#' @param loaded A loaded CmdStanR model object.
#' @inheritParams embr::analyse.mb_model
#' @param ... Additional arguments passed to \code{\link[cmdstanr]{variational}}.
#' @return A cmdstan_variational_analysis object.
#' @keywords internal
#' @export
analyse1.cmdstan_variational_model <- function(model, data, loaded, nchains, niters, nthin, 
                                               quiet, glance, parallel, 
                                               seed, niters_warmup,
                                               ...) {
  conflicting_args <- c("data", "show_messages", "show_exceptions", "output_samples", "draws")
  
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
  
  # allow init to be passed via '...' - all parameters must be specified
  if("init" %in% names(dots)){
    init <- dots$init
    dots$init <- NULL
  } else {
    init <- NULL
  }

  monitor <- embr::monitor(model)
  
  capture_output <- if (quiet) function(x){
    suppressMessages(suppressWarnings(capture.output(x))) 
  }  else {
    identity
  } 
  capture_output(
    cmdstan_fit <- do.call(loaded$variational, c(list(
      data = data,
      seed = seed,
      init = init,
      output_samples = niters,
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
  class(obj) <- c("cmdstan_variational_analysis", "cmdstan_analysis", "mb_analysis")
  
  if (glance) print(glance(obj))
  
  obj
}
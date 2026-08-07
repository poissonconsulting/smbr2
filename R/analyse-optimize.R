#' Analyse CmdStanR Optimize Model
#'
#' Internal method for analysing models using CmdStanR's optimization.
#' This method is dispatched when `stan_engine = "cmdstan-optimize"` in
#' [embr::analyse.mb_model()].
#'
#' @param model A mb_model to analyse.
#' @param data A data.frame of the data.
#' @param loaded A loaded CmdStanR model object.
#' @inheritParams embr::analyse.mb_model
#' @param ... Additional arguments passed to [cmdstanr::optimize()].
#' @return A cmdstan_optimize_analysis object.
#' @keywords internal
#' @export
analyse1.cmdstan_optimize_model <- function(
  model,
  data,
  loaded,
  nchains,
  niters,
  nthin,
  quiet,
  glance,
  parallel,
  seed,
  niters_warmup,
  ...
) {
  conflicting_args <- c("data", "show_messages", "show_exceptions")

  dots <- list(...)
  conflicts <- intersect(names(dots), conflicting_args)
  if (length(conflicts) > 0) {
    dots[conflicts] <- NULL
    warning(
      "Ignoring arguments passed via '...' that conflict with function parameters: ",
      paste(conflicts, collapse = ", ")
    )
  }

  timer <- timer::Timer$new()
  timer$start()

  obj <- list(model = model, data = data)

  data %<>% modify_data(model = model, numericize_factors = TRUE)

  # allow init to be passed via '...' - all parameters must be specified
  if ("init" %in% names(dots)) {
    init <- dots$init
    dots$init <- NULL
  } else {
    init <- NULL
  }

  capture_output <- if (quiet) {
    quiet_capture
  } else {
    identity
  }
  capture_output(
    cmdstan_fit <- do.call(
      loaded$optimize,
      c(
        list(
          data = data,
          seed = seed,
          init = init,
          show_messages = !quiet,
          show_exceptions = getOption("mb.show_exceptions", !quiet)
        ),
        dots
      )
    )
  )

  obj %<>%
    c(
      cmdstan_fit = list(cmdstan_fit)
    )

  obj$duration <- timer$elapsed()
  class(obj) <- c(
    "cmdstan_optimize_analysis",
    "cmdstan_analysis",
    "mb_analysis"
  )

  if (glance) {
    print(glance(obj))
  }

  obj
}

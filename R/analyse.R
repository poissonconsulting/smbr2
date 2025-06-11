#' @export
analyse1.smb2_model <- function(model, data, loaded, nchains, niters, nthin, 
                               quiet, glance, parallel, ...) {
  timer <- timer::Timer$new()
  timer$start()

  obj <- list(model = model, data = data)

  data %<>% modify_data(model = model, numericize_factors = TRUE)
  
  inits <- inits(data, model$gen_inits, nchains = nchains)

  monitor <- embr::monitor(model)
  
  parallel_chains <- ifelse(parallel, nchains, 1L)
  
  # warmup iterations are set to equal the number of post-thinning, post-warmup iterations
  sampling_iter <- niters * nthin
  warmup_iter <- niters
  seed <- sample.int(.Machine$integer.max, 1)
  
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
      iter_warmup = warmup_iter,
      # this is post-warmup iterations in cmdstanr
      iter_sampling = sampling_iter,
      thin = nthin,
      seed = seed,
      refresh = 100,
      init = inits,
      show_messages = !quiet,
      show_exceptions = !quiet
    )
  )
  
  draws <- cmdstan_fit$draws(variables = monitor, format = "array")

  obj %<>% c(
    cmdstan_fit = list(cmdstan_fit),
    mcmcr = list(as.mcmcr(draws)),
    nthin = nthin
  )

  obj$duration <- timer$elapsed()
  class(obj) <- c("smb2_analysis", "smb_analysis", "mb_analysis")

  if (glance) print(glance(obj))

  obj
}

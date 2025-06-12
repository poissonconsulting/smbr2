#' @export
load_model.cmdstan_model <- function(x, quiet, ...) {
  chk_flag(quiet)
  
  capture_output <- if (quiet) function(x){
    suppressMessages(suppressWarnings(capture.output(x))) 
  }  else {
    identity
  } 
  
  capture_output(
    stan_model <- cmdstanr::cmdstan_model(stan_file = cmdstanr::write_stan_file(template(x)), 
                                          quiet = TRUE, # always quieten clang etc. compilation msgs
                                          pedantic = !quiet)
  )

  stan_model
}

#' @export
load_model.smb2_model <- function(x, quiet, ...) {
  chk_flag(quiet)

  capture_output <- if (quiet) {
    function(x) suppressWarnings(capture.output(x))
  } else {
    eval
  }
  
  capture_output(
    stan_model <- cmdstanr::cmdstan_model(stan_file = cmdstanr::write_stan_file(template(x)), 
                                          quiet = quiet)
  )

  stan_model
}

#' @keywords internal
#'
#' @section Options:
#' `smbr2` reads the following global options (set via [base::options()],
#' typically in a `.Rprofile`):
#'
#' \describe{
#'   \item{`mb.show_exceptions`}{A flag controlling whether cmdstanr's
#'     `show_exceptions` argument is enabled. When unset, defaults to
#'     `!quiet`. Set to `FALSE` to suppress the "Chain N Exception: ..."
#'     lines that cmdstanr emits even on healthy fits, while keeping the
#'     sampling progress visible.}
#' }
"_PACKAGE"

## usethis namespace: start
#' @import chk embr mcmcr utils term nlist
#' @importFrom broom glance
#' @importFrom coda as.mcmc.list
#' @importFrom magrittr %<>% %>%
#' @importFrom stats sd coef logLik predict update var
## usethis namespace: end
NULL

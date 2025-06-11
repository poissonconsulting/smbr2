#' @method as.mcmc.list stanfit
#' @export
as.mcmc.list.draws_array <- function(x, ...) as.mcmc.list(as.mcmcr(x))

#' @export
as.mcmcr.draws_array <- function(x, ...) {
  x <- as.mcmcr(as_mcmc_list(x))
  x["lp__"] <- NULL
  x
}

# modified from cmdstanr::as_mcmc.list so that monitor can be fed to draws() function beforehand
# https://github.com/stan-dev/cmdstanr/blob/master/R/utils.R
# function expects a draws_array class object 
as_mcmc_list <- function(x){
  n_chain <- dim(x)[2]
  n_iteration <- dim(x)[1]
  class(x) <- 'array'
  mcmc_list <- lapply(seq_len(n_chain), function(chain) {
    x <- x[, chain, ]
    dimnames(x) <- list(iteration = dimnames(x)$iteration,
                        variable  = dimnames(x)$variable)
    attr(x, 'mcpar') <- c(1, n_iteration, 1)
    class(x) <- 'mcmc'
    x
  })
  class(mcmc_list) <- 'mcmc.list'
  mcmc_list
}

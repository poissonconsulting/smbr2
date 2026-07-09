inits <- function(data, gen_inits, nchains) {
  if (identical(gen_inits(data), list())) {
    # default in cmdstan of 2 = uniform(-2,2) in unconstrained space
    return(2)
  }

  inits <- list()
  for (i in 1:nchains) {
    inits[[i]] <- gen_inits(data)
  }
  inits
}

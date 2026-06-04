# Glance at CmdStanR MCMC Analysis

Provides a one-row summary of key diagnostics for MCMC analysis results.

## Usage

``` r
# S3 method for class 'cmdstan_mcmc_analysis'
glance(x, ...)
```

## Arguments

- x:

  A `cmdstan_mcmc_analysis` object.

- ...:

  Additional arguments (unused).

## Value

A tibble with one row containing:

- n:

  Number of observations in the dataset

- K:

  Number of parameters

- nchains:

  Number of MCMC chains

- niters:

  Number of iterations per chain (post-warmup)

- nthin:

  Thinning interval

- converged:

  Logical indicating convergence (TRUE if max R-hat \< rhat threshold)

- num_divergent:

  Number of divergent transitions across all chains. **Problem
  indicators**: Any value \> 0 indicates sampling issues

- max_treedepth:

  Number of transitions that hit maximum tree depth. **Problem
  indicators**: Values \> 0 may indicate inefficient sampling

- ebfmi:

  Minimum Energy Bayesian Fraction of Missing Information across chains.
  **Problem indicators**: Values \< 0.2 indicate poor adaptation/warmup

## Details

**Diagnostic interpretation:**

- **Divergent transitions**: Should be 0. Any divergent transitions
  indicate the sampler had numerical issues and results may be
  unreliable.

- **Max treedepth**: Should be 0 or very low. High values suggest the
  sampler is working hard and may benefit from increased `adapt_delta`.

- **E-BFMI**: Should be \> 0.2. Values \< 0.2 suggest poor adaptation,
  often requiring longer warmup or model reparameterization.

## See also

[`embr::glance()`](https://rdrr.io/pkg/embr/man/reexports.html),
[`diagnose()`](https://poissonconsulting.github.io/smbr/reference/diagnose.md)

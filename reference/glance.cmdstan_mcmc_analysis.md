# Glance at CmdStanR MCMC Analysis

Provides a one-row summary of key diagnostics for MCMC analysis results.

## Usage

``` r
# S3 method for class 'cmdstan_mcmc_analysis'
glance(
  x,
  ...,
  max_perc_divergent = getOption("mb.prop_divergent", 0.002) * 100
)
```

## Arguments

- x:

  A `cmdstan_mcmc_analysis` object.

- ...:

  Additional arguments (unused).

- max_perc_divergent:

  A percentage indicating the maximum number of divergent transitions
  allowed for determining if the model converged. Generally set via
  [`embr::set_analysis_mode()`](https://rdrr.io/pkg/embr/man/set_analysis_mode.html).

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

  Logical indicating convergence. `TRUE` if: `max(rhat)` is less than or
  equal to its threshold, `min(ESS)` is greater than or equal to its
  threshold, and `perc_divergent` is less than or euqal to its
  threshold. Thresholds are determined by the analysis mode set by
  [`embr::set_analysis_mode()`](https://rdrr.io/pkg/embr/man/set_analysis_mode.html).

- perc_divergent:

  Percentage of divergent transitions across all chains. **Problem
  indicators**: Any value \> 0% indicates sampling issues

- perc_max_treedepth:

  Percentage of transitions that hit maximum tree depth. **Problem
  indicators**: Values \> 0% may indicate inefficient sampling

- ebfmi:

  Minimum Energy Bayesian Fraction of Missing Information across chains.
  **Problem indicators**: Values \< 0.2 indicate poor adaptation/warmup

## Details

**Diagnostic interpretation:**

- **Divergent transitions**: Should ideally be 0. Any divergent
  transitions indicate the sampler had numerical issues and results may
  be unreliable.

- **Max treedepth**: Should ideally be 0 or very low. High values
  suggest the sampler is working hard and may benefit from
  reparameterization. Increasing max treedepth is also an option but it
  is generally discouraged since it increases model fitting times
  without addressing the underlying issue. High max treedepth does not
  necessarily indicate convergence issues.

- **E-BFMI**: Should be \> 0.2. Values \< 0.2 suggest poor adaptation,
  often requiring longer warmup or model reparameterization.

However, the sensitivity to problematic diagnostics depends on the
analysis mode set via
[`embr::set_analysis_mode()`](https://rdrr.io/pkg/embr/man/set_analysis_mode.html).
The `'paper'` mode is the only mode that requires divergent transitions
to be 0% – all other modes accept some level of tolerance.

## See also

[`embr::glance()`](https://generics.r-lib.org/reference/glance.html),
[`diagnose()`](https://poissonconsulting.github.io/smbr/reference/diagnose.md)

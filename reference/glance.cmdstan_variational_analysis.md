# Glance at CmdStanR Variational Analysis

Provides a one-row summary of variational inference analysis results.

## Usage

``` r
# S3 method for class 'cmdstan_variational_analysis'
glance(x, ...)
```

## Arguments

- x:

  A `cmdstan_variational_analysis` object.

- ...:

  Additional arguments (unused).

## Value

A tibble with one row containing:

- n:

  Number of observations in the dataset

- K:

  Number of parameters

- converged:

  Logical indicating ELBO convergence

- return_code:

  Optimization return code. **Problem indicators**: Non-zero values
  indicate convergence issues

## Details

**Diagnostic interpretation:**

- **return_code**: Should be 0. Non-zero values indicate the variational
  algorithm failed to converge to a stable ELBO (Evidence Lower BOund).

## See also

[`embr::glance()`](https://generics.r-lib.org/reference/glance.html),
[`diagnose()`](https://poissonconsulting.github.io/smbr/reference/diagnose.md)

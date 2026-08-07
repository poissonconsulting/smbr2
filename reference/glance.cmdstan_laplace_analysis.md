# Glance at CmdStanR Laplace Analysis

Provides a one-row summary of Laplace approximation analysis results.

## Usage

``` r
# S3 method for class 'cmdstan_laplace_analysis'
glance(x, ...)
```

## Arguments

- x:

  A `cmdstan_laplace_analysis` object.

- ...:

  Additional arguments (unused).

## Value

A tibble with one row containing:

- n:

  Number of observations in the dataset

- K:

  Number of parameters

- converged:

  Logical indicating optimization convergence

- return_code:

  Optimization return code for mode finding. **Problem indicators**:
  Non-zero values indicate mode-finding issues

## Details

**Diagnostic interpretation:**

- **return_code**: Should be 0. Non-zero values indicate the optimizer
  failed to find the posterior mode, invalidating the Laplace
  approximation.

## See also

[`embr::glance()`](https://generics.r-lib.org/reference/glance.html)

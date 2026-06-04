# Glance at CmdStanR Optimization Analysis

Provides a one-row summary of optimization analysis results.

## Usage

``` r
# S3 method for class 'cmdstan_optimize_analysis'
glance(x, ...)
```

## Arguments

- x:

  A `cmdstan_optimize_analysis` object.

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

  Optimization return code. **Problem indicators**: Non-zero values
  indicate optimization issues

## Details

**Diagnostic interpretation:**

- **return_code**: Should be 0. Non-zero values indicate the optimizer
  encountered issues (e.g., 1 = max iterations reached, 2 = convergence
  issues).

## See also

[`embr::glance()`](https://rdrr.io/pkg/embr/man/reexports.html)

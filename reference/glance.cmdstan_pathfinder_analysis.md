# Glance at CmdStanR Pathfinder Analysis

Provides a one-row summary of key diagnostics for Pathfinder analysis
results.

## Usage

``` r
# S3 method for class 'cmdstan_pathfinder_analysis'
glance(x, ...)
```

## Arguments

- x:

  A `cmdstan_pathfinder_analysis` object.

- ...:

  Additional arguments (unused).

## Value

A tibble with one row containing:

- n:

  Number of observations in the dataset

- K:

  Number of parameters

- converged:

  Logical indicating pathfinder convergence

- return_code:

  Pathfinder return code. **Problem indicators**: Non-zero values
  indicate pathfinder issues

## Details

**Diagnostic interpretation:**

- **return_code**: Should be 0. Non-zero values indicate pathfinder
  failed to find a good approximation.

## See also

[`embr::glance()`](https://rdrr.io/pkg/embr/man/reexports.html),
[`diagnose()`](https://poissonconsulting.github.io/smbr/reference/diagnose.md)

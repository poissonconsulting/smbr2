<!-- README.md is generated from README.Rmd. Please edit that file -->

# smbr2

<!-- badges: start -->

[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![R-CMD-check](https://github.com/poissonconsulting/smbr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/poissonconsulting/smbr/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/poissonconsulting/smbr/graph/badge.svg)](https://app.codecov.io/gh/poissonconsulting/smbr)
[![License:
MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/license/mit/)
<!-- badges: end -->

## Introduction

`smbr2` (pronounced simber two) is an R package to facilitate analyses
using [`STAN`](http://mc-stan.org) with
[cmdstanr](https://mc-stan.org/cmdstanr/).

`smbr2` was developed as an alternative to
[smbr](https://github.com/poissonconsulting/smbr). It uses
[cmdstanr](https://mc-stan.org/cmdstanr/) instead of
[rstan](https://mc-stan.org/rstan/) as the model-fitting engine.

To begin using `smbr2`, you must install CmdStan by running
`check_cmdstan_toolchain()` and `cmdstanr::install_cmdstan()`. For more
installation instructions see
[here](https://mc-stan.org/cmdstanr/articles/cmdstanr.html).

The motivation for using `cmdstanr` is that it stays up-to-date with the
most recent developments by the Stan dev team (i.e., via
[CmdStan](https://mc-stan.org/docs/cmdstan-guide/)). `smbr2` is able to
incorporate improved functionality such as the new Stan syntax, faster
parallelization, progress communication with parallelization, pedantic
Stan model checking, Stan model diagnostics summary, and model fitting
with alternative engines such as pathfinder, Laplace approximation,
variational inference, and optimization.

Note that some S3 methods for class `smb_model` and `smb_code` are
imported from `smbr`. `smbr` and `smbr2` are part of the
[embr](https://github.com/poissonconsulting/embr) family of packages. To
enable `smbr2` functionality in `embr`, modify the `stan_engine`
argument in `embr::analyse()`,
e.g. `embr::analyse(stan_engine = 'cmdstan-mcmc')`.

**The new Stan syntax must be used.** `smbr2` will fail with old Stan
syntax. If you don’t wish to update an old model, simply leave the
`stan_engine` argument as the default, which will use `smbr` instead.

## Demonstration

    library(bauw)
    library(ggplot2)
    library(magrittr)
    library(embr)
    library(smbr2)

    # define model in Stan language
    model <- model(code = "
      data {
          int nAnnual;
          int nObs;
          array[nObs] int Annual;
          array[nObs] int Pairs;
          array[nObs] real Year;
      }
      parameters {
          vector[nAnnual] bAnnual;
          real log_sAnnual;
          real alpha;
          real beta1;
          real beta2;
          real beta3;
      }
      transformed parameters {
        real sAnnual;
        sAnnual = exp(log_sAnnual);
      }
      model {
          vector[nObs] ePairs;
          log_sAnnual ~ normal(0, 10);
          bAnnual ~ normal(0, sAnnual);
          alpha ~ normal(0, 10);
          beta1 ~ normal(0, 10);
          beta2 ~ normal(0, 10);
          beta3 ~ normal(0, 10);
          for (i in 1:nObs) {
            ePairs[i] = exp(alpha + beta1 * Year[i] + beta2 * Year[i]^2 +
                          beta3 * Year[i]^3 + bAnnual[Annual[i]]);
          }
          target += poisson_lpmf(Pairs | ePairs);
      }
    ")

    # add R code to calculate derived parameters
    model %<>% update_model(new_expr = "
      for (i in 1:length(Pairs)) {
        prediction[i] <- exp(alpha + beta1 * Year[i] + beta2 * Year[i]^2 +
                           beta3 * Year[i]^3 + bAnnual[Annual[i]])
      }
    ")

    # define data types and center year
    model %<>% update_model(
      select_data = list(
        "Pairs" = integer(), "Year*" = integer(),
        Annual = factor()
      ),
      derived = "sAnnual",
      random_effects = list(bAnnual = "Annual")
    )

    data <- bauw::peregrine
    data$Annual <- factor(data$Year)

    set.seed(42)

    # analyse
    analysis <- analyse(model, data = data, seed = 3L, glance = FALSE, stan_engine = "cmdstan-mcmc")

    # analyse pathfinder
    analysis_path <- analyse(model, data = data, seed = 3L, glance = FALSE, stan_engine = "cmdstan-pathfinder")

    # coefficient table
    coef(analysis, simplify = TRUE)
    #> # A tibble: 5 × 5
    #>   term        estimate   lower   upper svalue
    #>   <term>         <dbl>   <dbl>   <dbl>  <dbl>
    #> 1 alpha         4.26    4.18    4.34    9.97 
    #> 2 beta1         1.19    1.06    1.33    9.97 
    #> 3 beta2        -0.0191 -0.0735  0.0401  0.937
    #> 4 beta3        -0.272  -0.345  -0.207   9.97 
    #> 5 log_sAnnual  -2.24   -2.81   -1.80    9.97

    coef(analysis_path, simplify = TRUE)
    #> # A tibble: 5 × 5
    #>   term        estimate   lower   upper svalue
    #>   <term>         <dbl>   <dbl>   <dbl>  <dbl>
    #> 1 alpha        4.25     4.21    4.30     8.97
    #> 2 beta1        1.24     1.17    1.28     8.97
    #> 3 beta2       -0.00877 -0.0531  0.0139   1.60
    #> 4 beta3       -0.298   -0.321  -0.259    8.97
    #> 5 log_sAnnual -2.23    -2.56   -2.10     8.97

    # trace plots
    plot(analysis)

![](tools/README-unnamed-chunk-3-1.png)![](tools/README-unnamed-chunk-3-2.png)

    # make predictions by varying year with other predictors including the random effect of Annual held constant
    year <- predict(analysis, new_data = "Year")
    year_path <- predict(analysis_path, new_data = "Year")

    years <- dplyr::bind_rows(list("mcmc" = year, "pathfinder" = year_path), .id = "engine")

    # plot those predictions
    ggplot(data = years, aes(x = Year, y = estimate)) +
      geom_point(data = bauw::peregrine, aes(y = Pairs)) +
      geom_line(aes(color = engine)) +
      geom_line(aes(y = lower, color = engine), linetype = "dotted") +
      geom_line(aes(y = upper, color = engine), linetype = "dotted") +
      expand_limits(y = 0)

![](tools/README-unnamed-chunk-4-1.png)

## Installation

    # install.packages("devtools")
    remotes::install_github("poissonconsulting/smbr2")

## Citation

    To cite smbr in publications use:

      Chris Muir and Joe Thorley (2018) smbr: Analyses
      Using STAN. doi:
      https://doi.org/10.5281/zenodo.1162382.

    A BibTeX entry for LaTeX users is

      @Misc{,
        author = {Chris Muir and Joe Thorley},
        year = {2018},
        title = {smbr: Analyses Using STAN},
        doi = {https://doi.org/10.5281/zenodo.1162382},
      }

    Please also cite STAN.

## Contribution

Please report any
[issues](https://github.com/poissonconsulting/smbr2/issues).

[Pull requests](https://github.com/poissonconsulting/smbr2/pulls) are
always welcome.

## Code of Conduct

Please note that the smbr project is released with a [Contributor Code
of
Conduct](https://contributor-covenant.org/version/2/0/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

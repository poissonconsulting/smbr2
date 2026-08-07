# smbr2: Facilitates Bayesian Analysis using STAN with CmdStanR

Facilitates Bayesian Analysis using STAN with CmdStanR. This builds on
smbr, which uses rstan.

## Options

`smbr2` reads the following global options (set via
[`base::options()`](https://rdrr.io/r/base/options.html), typically in a
`.Rprofile`):

- `mb.show_exceptions`:

  A flag controlling whether cmdstanr's `show_exceptions` argument is
  enabled. When unset, defaults to `!quiet`. Set to `FALSE` to suppress
  the "Chain N Exception: ..." lines that cmdstanr emits even on healthy
  fits, while keeping the sampling progress visible.

## See also

Useful links:

- <https://github.com/poissonconsulting/smbr2>

- Report bugs at <https://github.com/poissonconsulting/smbr2/issues>

## Author

**Maintainer**: Seb Dalgarno <seb@poissonconsulting.ca>
([ORCID](https://orcid.org/0000-0002-3658-4517))

Authors:

- Seb Dalgarno <seb@poissonconsulting.ca>
  ([ORCID](https://orcid.org/0000-0002-3658-4517))

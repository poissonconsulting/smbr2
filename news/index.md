# Changelog

## smbr2 0.0.0.9001 {2026-08-21}

- Model convergence now depends on effective sample size (ESS) and
  percent of divergent transitions besides \hat R.

## smbr2 0.0.0.9000

- New option `mb.show_exceptions` to suppress cmdstanr’s “Chain N
  Exception:” output independently of `quiet`
  ([\#12](https://github.com/poissonconsulting/smbr2/issues/12)).
- Fixed variational fitting against current cmdstanr: pass `draws`
  instead of the renamed `output_samples` argument.
- Added a `NEWS.md` file to track changes to the package.

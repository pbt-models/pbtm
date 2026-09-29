# Hydrotime model

Fits the hydrotime model, in which the base water potential \\\psi_b(g)
= \psi - \theta_H / t_g\\ is normally distributed across the seed
population:

## Usage

``` r
fit_hydrotime(data, ...)
```

## Arguments

- data:

  A data frame with `GermWP`, `CumTime`, and `CumFraction` columns (see
  [`fit_pbtm()`](https://pbt-models.github.io/pbtm/reference/fit_pbtm.md)).

- ...:

  Further arguments passed on to
  [`fit_pbtm()`](https://pbt-models.github.io/pbtm/reference/fit_pbtm.md),
  such as `max_frac`, `fixed`, `bounds`, `subpops`, or `cols`.

## Value

A `pbtm_fit` object; see
[`fit_pbtm()`](https://pbt-models.github.io/pbtm/reference/fit_pbtm.md).

## Details

\$\$g = \Phi\left(\frac{\psi - \theta_H / t_g -
\psi_b(50)}{\sigma}\right)\$\$

Use data collected at a single temperature.

## Parameters

- `theta_h`: hydrotime constant (MPa-time units).

- `psi_b50`: median base water potential (MPa).

- `sigma`: standard deviation of `psi_b` across the population (MPa).

## See also

Other model fitting functions:
[`fit_aging()`](https://pbt-models.github.io/pbtm/reference/fit_aging.md),
[`fit_hydropriming()`](https://pbt-models.github.io/pbtm/reference/fit_hydropriming.md),
[`fit_hydrothermal_priming()`](https://pbt-models.github.io/pbtm/reference/fit_hydrothermal_priming.md),
[`fit_hydrothermal_time()`](https://pbt-models.github.io/pbtm/reference/fit_hydrothermal_time.md),
[`fit_inhibitor()`](https://pbt-models.github.io/pbtm/reference/fit_inhibitor.md),
[`fit_promoter()`](https://pbt-models.github.io/pbtm/reference/fit_promoter.md),
[`fit_thermal_time()`](https://pbt-models.github.io/pbtm/reference/fit_thermal_time.md)

## Examples

``` r
fit <- fit_hydrotime(hydrotime_data)
fit
#> <pbtm_fit> Hydrotime model
#> 
#> theta_h psi_b50   sigma 
#>   117.2  -1.372  0.1565 
#> 
#> n = 125, pseudo-R2 = 0.9649, AIC = -706.8
autoplot(fit)
```

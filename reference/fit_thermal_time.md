# Thermal time model

Fits the sub-optimal thermal time model, in which the thermal time to
germination of fraction `g`, \\\theta_T(g) = (T - T_b) t_g\\, is
log-normally distributed across the seed population:

## Usage

``` r
fit_thermal_time(data, ...)
```

## Arguments

- data:

  A data frame with `GermTemp`, `CumTime`, and `CumFraction` columns
  (see
  [`fit_pbtm()`](https://pbt-models.github.io/pbtm/reference/fit_pbtm.md)).

- ...:

  Further arguments passed on to
  [`fit_pbtm()`](https://pbt-models.github.io/pbtm/reference/fit_pbtm.md),
  such as `max_frac`, `fixed`, `bounds`, `subpops`, or `cols`.

## Value

A `pbtm_fit` object; see
[`fit_pbtm()`](https://pbt-models.github.io/pbtm/reference/fit_pbtm.md).

## Details

\$\$g = \Phi\left(\frac{\log\_{10}\[(T - T_b)\\ t_g\] -
\log\_{10}\theta\_{T}(50)}{\sigma}\right)\$\$

Use only temperatures at or below the optimum.

## Parameters

- `t_b`: base temperature, below which germination does not occur.

- `theta_t50`: median thermal time (degree-time units).

- `sigma`: standard deviation of `log10(theta_T)` across the population.

## See also

Other model fitting functions:
[`fit_aging()`](https://pbt-models.github.io/pbtm/reference/fit_aging.md),
[`fit_hydropriming()`](https://pbt-models.github.io/pbtm/reference/fit_hydropriming.md),
[`fit_hydrothermal_priming()`](https://pbt-models.github.io/pbtm/reference/fit_hydrothermal_priming.md),
[`fit_hydrothermal_time()`](https://pbt-models.github.io/pbtm/reference/fit_hydrothermal_time.md),
[`fit_hydrotime()`](https://pbt-models.github.io/pbtm/reference/fit_hydrotime.md),
[`fit_inhibitor()`](https://pbt-models.github.io/pbtm/reference/fit_inhibitor.md),
[`fit_promoter()`](https://pbt-models.github.io/pbtm/reference/fit_promoter.md)

## Examples

``` r
fit <- fit_thermal_time(thermal_time_data)
fit
#> <pbtm_fit> Thermal time model
#> 
#>       t_b theta_t50     sigma 
#>     3.648      1419   0.06734 
#> 
#> n = 100, pseudo-R2 = 0.9903, AIC = -686.8
autoplot(fit)

autoplot(fit, type = "normalized")
```

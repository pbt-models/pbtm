# Hydrothermal time model

Fits the hydrothermal time model, combining temperature and water
potential responses. The base water potential \\\psi_b(g) = \psi -
\theta\_{HT} / \[(T - T_b) t_g\]\\ is normally distributed across the
seed population:

## Usage

``` r
fit_hydrothermal_time(data, ...)
```

## Arguments

- data:

  A data frame with `GermWP`, `GermTemp`, `CumTime`, and `CumFraction`
  columns (see
  [`fit_pbtm()`](https://pbt-models.github.io/pbtm/reference/fit_pbtm.md)).

- ...:

  Further arguments passed on to
  [`fit_pbtm()`](https://pbt-models.github.io/pbtm/reference/fit_pbtm.md),
  such as `max_frac`, `fixed`, `bounds`, `subpops`, or `cols`.

## Value

A `pbtm_fit` object; see
[`fit_pbtm()`](https://pbt-models.github.io/pbtm/reference/fit_pbtm.md).

## Details

\$\$g = \Phi\left(\frac{\psi - \theta\_{HT} / \[(T - T_b)\\ t_g\] -
\psi_b(50)}{\sigma}\right)\$\$

## Parameters

- `theta_ht`: hydrothermal time constant (MPa-degree-time units).

- `t_b`: base temperature.

- `psi_b50`: median base water potential (MPa).

- `sigma`: standard deviation of `psi_b` across the population (MPa).

## See also

Other model fitting functions:
[`fit_aging()`](https://pbt-models.github.io/pbtm/reference/fit_aging.md),
[`fit_hydropriming()`](https://pbt-models.github.io/pbtm/reference/fit_hydropriming.md),
[`fit_hydrothermal_priming()`](https://pbt-models.github.io/pbtm/reference/fit_hydrothermal_priming.md),
[`fit_hydrotime()`](https://pbt-models.github.io/pbtm/reference/fit_hydrotime.md),
[`fit_inhibitor()`](https://pbt-models.github.io/pbtm/reference/fit_inhibitor.md),
[`fit_promoter()`](https://pbt-models.github.io/pbtm/reference/fit_promoter.md),
[`fit_thermal_time()`](https://pbt-models.github.io/pbtm/reference/fit_thermal_time.md)

## Examples

``` r
fit <- fit_hydrothermal_time(hydrothermal_time_data)
fit
#> <pbtm_fit> Hydrothermal time model
#> 
#> theta_ht      t_b  psi_b50    sigma 
#>     1456    5.395   -1.162   0.1458 
#> 
#> n = 398, pseudo-R2 = 0.906, AIC = -1843
autoplot(fit)
```

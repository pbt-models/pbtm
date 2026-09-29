# Hydrothermal priming model

Fits the hydrothermal priming model, in which the germination rate after
priming increases linearly with hydrothermal priming time
\\\theta\_{HTP} = (\psi - \psi\_{min})(T - T\_{min}) \times duration\\:

## Usage

``` r
fit_hydrothermal_priming(data, ...)
```

## Arguments

- data:

  A data frame with `TrtID`, `PrimingWP`, `PrimingTemp`,
  `PrimingDuration`, `CumTime`, and `CumFraction` columns, or a table of
  rates with a `GR` column (see
  [`fit_pbtm()`](https://pbt-models.github.io/pbtm/reference/fit_pbtm.md)).

- ...:

  Further arguments passed on to
  [`fit_pbtm()`](https://pbt-models.github.io/pbtm/reference/fit_pbtm.md),
  such as `max_frac`, `fixed`, `bounds`, `subpops`, or `cols`.

## Value

A `pbtm_fit` object; see
[`fit_pbtm()`](https://pbt-models.github.io/pbtm/reference/fit_pbtm.md).

## Details

\$\$GR = GR_i + slope \times (\psi - \psi\_{min})(T - T\_{min}) \times
duration\$\$

## Parameters

- `t_min`: minimum priming temperature with a priming effect.

- `psi_min`: minimum priming water potential with a priming effect
  (MPa).

- `gr_i`: germination rate of unprimed seeds.

- `slope`: increase in germination rate per unit hydrothermal priming
  time.

## See also

Other model fitting functions:
[`fit_aging()`](https://pbt-models.github.io/pbtm/reference/fit_aging.md),
[`fit_hydropriming()`](https://pbt-models.github.io/pbtm/reference/fit_hydropriming.md),
[`fit_hydrothermal_time()`](https://pbt-models.github.io/pbtm/reference/fit_hydrothermal_time.md),
[`fit_hydrotime()`](https://pbt-models.github.io/pbtm/reference/fit_hydrotime.md),
[`fit_inhibitor()`](https://pbt-models.github.io/pbtm/reference/fit_inhibitor.md),
[`fit_promoter()`](https://pbt-models.github.io/pbtm/reference/fit_promoter.md),
[`fit_thermal_time()`](https://pbt-models.github.io/pbtm/reference/fit_thermal_time.md)

## Examples

``` r
fit <- fit_hydrothermal_priming(hydrothermal_priming_data)
fit
#> <pbtm_fit> Hydrothermal priming model
#> 
#>     t_min   psi_min      gr_i     slope 
#>     9.362    -1.463  0.009856 4.157e-05 
#> 
#> n = 36, pseudo-R2 = 0.9561, AIC = -447.7; rates at 50% germination
autoplot(fit)
```

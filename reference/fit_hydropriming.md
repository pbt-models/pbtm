# Hydropriming model

Fits the hydropriming model, in which the germination rate after priming
increases linearly with hydropriming time \\\theta\_{HP} = (\psi -
\psi\_{min}) \times duration\\:

## Usage

``` r
fit_hydropriming(data, ...)
```

## Arguments

- data:

  A data frame with `TrtID`, `PrimingWP`, `PrimingDuration`, `CumTime`,
  and `CumFraction` columns, or a table of rates with a `GR` column (see
  [`fit_pbtm()`](https://pbt-models.github.io/pbtm/reference/fit_pbtm.md)).

- ...:

  Further arguments passed on to
  [`fit_pbtm()`](https://pbt-models.github.io/pbtm/reference/fit_pbtm.md),
  such as `max_frac`, `fixed`, `bounds`, `subpops`, or `cols`.

## Value

A `pbtm_fit` object; see
[`fit_pbtm()`](https://pbt-models.github.io/pbtm/reference/fit_pbtm.md).

## Details

\$\$GR = GR_i + slope \times (\psi - \psi\_{min}) \times duration\$\$

Germination rates are computed from the time courses with
[`germ_speed()`](https://pbt-models.github.io/pbtm/reference/germ_speed.md)
at the fraction given by `speed` (default 0.5, i.e. GR50).

## Parameters

- `psi_min`: minimum priming water potential with a priming effect
  (MPa).

- `gr_i`: germination rate of unprimed seeds.

- `slope`: increase in germination rate per unit hydropriming time (the
  inverse of the hydropriming time constant).

## See also

Other model fitting functions:
[`fit_aging()`](https://pbt-models.github.io/pbtm/reference/fit_aging.md),
[`fit_hydrothermal_priming()`](https://pbt-models.github.io/pbtm/reference/fit_hydrothermal_priming.md),
[`fit_hydrothermal_time()`](https://pbt-models.github.io/pbtm/reference/fit_hydrothermal_time.md),
[`fit_hydrotime()`](https://pbt-models.github.io/pbtm/reference/fit_hydrotime.md),
[`fit_inhibitor()`](https://pbt-models.github.io/pbtm/reference/fit_inhibitor.md),
[`fit_promoter()`](https://pbt-models.github.io/pbtm/reference/fit_promoter.md),
[`fit_thermal_time()`](https://pbt-models.github.io/pbtm/reference/fit_thermal_time.md)

## Examples

``` r
fit <- fit_hydropriming(hydropriming_data)
fit
#> <pbtm_fit> Hydropriming model
#> 
#>   psi_min      gr_i     slope 
#>    -1.437   0.01087 0.0002315 
#> 
#> n = 13, pseudo-R2 = 0.9544, AIC = -150.5; rates at 50% germination
autoplot(fit)
```

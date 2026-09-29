# Promoter model

Fits the germination promoter (e.g. gibberellin) dose-response model, in
which the threshold dose \\p_b(g) = dose - \theta_P / t_g\\ is normally
distributed across the seed population:

## Usage

``` r
fit_promoter(data, ...)
```

## Arguments

- data:

  A data frame with `GermPromoterDosage`, `CumTime`, and `CumFraction`
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

\$\$g = \Phi\left(\frac{dose - \theta_P / t_g -
p_b(50)}{\sigma}\right)\$\$

Dose responses are usually closer to linear on a log scale, so consider
`dose_transform = "log10"`; `dose` is then `log10(GermPromoterDosage)`
and `p_b50` is in log10 units.

## Parameters

- `theta_p`: promoter time constant.

- `p_b50`: median threshold dose.

- `sigma`: standard deviation of the threshold dose across the
  population.

## See also

Other model fitting functions:
[`fit_aging()`](https://pbt-models.github.io/pbtm/reference/fit_aging.md),
[`fit_hydropriming()`](https://pbt-models.github.io/pbtm/reference/fit_hydropriming.md),
[`fit_hydrothermal_priming()`](https://pbt-models.github.io/pbtm/reference/fit_hydrothermal_priming.md),
[`fit_hydrothermal_time()`](https://pbt-models.github.io/pbtm/reference/fit_hydrothermal_time.md),
[`fit_hydrotime()`](https://pbt-models.github.io/pbtm/reference/fit_hydrotime.md),
[`fit_inhibitor()`](https://pbt-models.github.io/pbtm/reference/fit_inhibitor.md),
[`fit_thermal_time()`](https://pbt-models.github.io/pbtm/reference/fit_thermal_time.md)

## Examples

``` r
fit <- fit_promoter(promoter_data, dose_transform = "log10")
fit
#> <pbtm_fit> Promoter model
#> 
#> theta_p   p_b50   sigma 
#>   176.2   0.666   0.528 
#> 
#> n = 57, pseudo-R2 = 0.9526, AIC = -302.1; dose transform = log10
autoplot(fit)
```

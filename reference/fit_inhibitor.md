# Inhibitor model

Fits the germination inhibitor (e.g. abscisic acid) dose-response model,
in which germination declines as dose approaches a normally distributed
inhibitory threshold \\I_b\\:

## Usage

``` r
fit_inhibitor(data, ...)
```

## Arguments

- data:

  A data frame with `GermInhibitorDosage`, `CumTime`, and `CumFraction`
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

\$\$g = 1 - \Phi\left(\frac{dose + \theta_I / t_g -
I_b(50)}{\sigma}\right)\$\$

Consider `dose_transform = "log10"`; `dose` is then
`log10(GermInhibitorDosage)` and `i_b50` is in log10 units.

## Parameters

- `theta_i`: inhibitor time constant.

- `i_b50`: median inhibitory threshold dose.

- `sigma`: standard deviation of the threshold dose across the
  population.

## See also

Other model fitting functions:
[`fit_aging()`](https://pbt-models.github.io/pbtm/reference/fit_aging.md),
[`fit_hydropriming()`](https://pbt-models.github.io/pbtm/reference/fit_hydropriming.md),
[`fit_hydrothermal_priming()`](https://pbt-models.github.io/pbtm/reference/fit_hydrothermal_priming.md),
[`fit_hydrothermal_time()`](https://pbt-models.github.io/pbtm/reference/fit_hydrothermal_time.md),
[`fit_hydrotime()`](https://pbt-models.github.io/pbtm/reference/fit_hydrotime.md),
[`fit_promoter()`](https://pbt-models.github.io/pbtm/reference/fit_promoter.md),
[`fit_thermal_time()`](https://pbt-models.github.io/pbtm/reference/fit_thermal_time.md)

## Examples

``` r
fit <- fit_inhibitor(inhibitor_data, dose_transform = "log10")
fit
#> <pbtm_fit> Inhibitor model
#> 
#> theta_i   i_b50   sigma 
#>   181.4  0.8605  0.5464 
#> 
#> n = 97, pseudo-R2 = 0.939, AIC = -501.5; dose transform = log10
autoplot(fit)
```

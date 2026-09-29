# Aging model

Fits the seed aging model, in which germination declines as aging time
approaches a normally distributed maximum tolerable aging threshold
\\p\_{max}\\:

## Usage

``` r
fit_aging(data, ...)
```

## Arguments

- data:

  A data frame with `AgingTime`, `CumTime`, and `CumFraction` columns
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

\$\$g = 1 - \Phi\left(\frac{aging + \theta_A / t_g -
p\_{max}(50)}{\sigma}\right)\$\$

## Parameters

- `theta_a`: aging time constant.

- `p_max50`: median aging threshold, in the units of `AgingTime`.

- `sigma`: standard deviation of `p_max` across the population.

## See also

Other model fitting functions:
[`fit_hydropriming()`](https://pbt-models.github.io/pbtm/reference/fit_hydropriming.md),
[`fit_hydrothermal_priming()`](https://pbt-models.github.io/pbtm/reference/fit_hydrothermal_priming.md),
[`fit_hydrothermal_time()`](https://pbt-models.github.io/pbtm/reference/fit_hydrothermal_time.md),
[`fit_hydrotime()`](https://pbt-models.github.io/pbtm/reference/fit_hydrotime.md),
[`fit_inhibitor()`](https://pbt-models.github.io/pbtm/reference/fit_inhibitor.md),
[`fit_promoter()`](https://pbt-models.github.io/pbtm/reference/fit_promoter.md),
[`fit_thermal_time()`](https://pbt-models.github.io/pbtm/reference/fit_thermal_time.md)

## Examples

``` r
fit <- fit_aging(aging_data)
fit
#> <pbtm_fit> Aging model
#> 
#> theta_a p_max50   sigma 
#>   272.4   14.24   2.995 
#> 
#> n = 93, pseudo-R2 = 0.9764, AIC = -539.3
autoplot(fit)
```

# Fit a population-based threshold model

`fit_pbtm()` is the general interface for fitting any of the models
listed by
[`pbtm_models()`](https://pbt-models.github.io/pbtm/reference/pbtm_models.md)
with nonlinear least squares
([`stats::nls()`](https://rdrr.io/r/stats/nls.html) with the `"port"`
algorithm, so every parameter is bounded). Each model also has a
convenience wrapper, e.g.
[`fit_thermal_time()`](https://pbt-models.github.io/pbtm/reference/fit_thermal_time.md)
or
[`fit_hydrotime()`](https://pbt-models.github.io/pbtm/reference/fit_hydrotime.md),
that documents its equation and parameters.

## Usage

``` r
fit_pbtm(
  data,
  model,
  max_frac = 1,
  fixed = NULL,
  bounds = NULL,
  subpops = 1,
  max_subpops = 3,
  restarts = 12,
  dose_transform = c("none", "log10"),
  speed = 0.5,
  cols = NULL
)
```

## Arguments

- data:

  A data frame of germination time courses (see *Data*).

- model:

  A model id from
  [`pbtm_models()`](https://pbt-models.github.io/pbtm/reference/pbtm_models.md),
  e.g. `"thermal_time"`.

- max_frac:

  Maximum cumulative fraction (0-1\] that the population can reach; the
  fitted curves plateau here. Use when even the optimal treatment does
  not reach full germination.

- fixed:

  Optional named list or vector of parameter values to hold constant
  instead of estimating, e.g. `list(t_b = 5)`. Single-population fits
  only.

- bounds:

  Optional named list overriding the default parameter bounds, each
  element `c(lower, start, upper)`, e.g. `list(t_b = c(0, 5, 12))`. See
  [`pbtm_models()`](https://pbt-models.github.io/pbtm/reference/pbtm_models.md)
  for the defaults.

- subpops:

  Number of subpopulations to fit (a positive integer), or `"auto"` to
  choose between 1 and `max_subpops` by AIC. `"cdf"` models only.

- max_subpops:

  Largest number of subpopulations tried when `subpops = "auto"`.

- restarts:

  Number of alternative starting values tried for each mixture fit, and
  for a single-population fit that does not converge from the default
  starting values.

- dose_transform:

  Transform applied to the dosage column of the promoter and inhibitor
  models: `"none"` or `"log10"`. With `"log10"`, the median threshold
  (`p_b50` or `i_b50`) is estimated in log10 dose units.

- speed:

  Germination fraction (0-1) at which germination rates are computed for
  the rate models; `0.5` gives GR50.

- cols:

  Optional named character vector mapping template column names to the
  names used in `data`, e.g. `c(GermTemp = "temp", CumTime = "hours")`.

## Value

A `pbtm_fit` object: a list with the model id and label, the estimated
`coefficients`, the names of any `fixed` parameters, the number of
subpopulations `k` and a `components` table (one row per subpopulation
with its weight and parameters), goodness-of-fit `stats` (`n`, `npar`,
`rss`, `aic`, `pseudo_r2` = squared correlation of observed and fitted),
the data used for fitting, and the underlying `nls` object. For
`subpops = "auto"`, `subpop_table` compares the candidate fits. Use
[`coef()`](https://rdrr.io/r/stats/coef.html),
[`predict()`](https://rdrr.io/r/stats/predict.html),
[`fitted()`](https://rdrr.io/r/stats/fitted.values.html),
[`residuals()`](https://rdrr.io/r/stats/residuals.html),
[`summary()`](https://rdrr.io/r/base/summary.html) and
[autoplot()](https://pbt-models.github.io/pbtm/reference/autoplot.pbtm_fit.md)
to work with it.

## Data

Data should follow the column naming of the PBTM template (see
[pbtm_columns](https://pbt-models.github.io/pbtm/reference/pbtm_columns.md)):
one row per observation, with the cumulative time (`CumTime`), the
cumulative germinated fraction (`CumFraction`, 0-1), and the treatment
columns required by the model (e.g. `GermTemp` for thermal time). Use
`cols` to map differently named columns onto the template names.

Rate models (hydropriming and hydrothermal priming) are fit to
germination rates. Pass the raw time-course data (which also needs a
`TrtID` column) and the rates are computed with
[`germ_speed()`](https://pbt-models.github.io/pbtm/reference/germ_speed.md)
at the fraction given by `speed`; alternatively, pass a data frame that
already has a `GR` column.

## Subpopulations

For cumulative (`"cdf"`) models, `subpops > 1` fits a mixture of
distinct seed subpopulations, each with its own copy of the model
parameters, combined with mixing weights that sum to one. Parameters of
subpopulation `j` get the suffix `j` (e.g. `t_b1`, `t_b2`) and the free
mixing fractions are named `w1`, `w2`, ... (stick-breaking: `w1` is the
first subpopulation's share, `w2` the second's share of what remains,
and so on). The mixture is fit from several perturbed starting values
(`restarts`) and the best fit by AIC is kept. `subpops = "auto"` fits 1
to `max_subpops` subpopulations and keeps the one with the lowest AIC.
Mixture fits are often *equifinal* (different parameter sets fit almost
equally well), so treat the component estimates with caution; see
[`vignette("subpopulations", package = "pbtm")`](https://pbt-models.github.io/pbtm/articles/subpopulations.md).

## See also

The per-model wrappers
[`fit_thermal_time()`](https://pbt-models.github.io/pbtm/reference/fit_thermal_time.md),
[`fit_hydrotime()`](https://pbt-models.github.io/pbtm/reference/fit_hydrotime.md),
[`fit_hydrothermal_time()`](https://pbt-models.github.io/pbtm/reference/fit_hydrothermal_time.md),
[`fit_hydropriming()`](https://pbt-models.github.io/pbtm/reference/fit_hydropriming.md),
[`fit_hydrothermal_priming()`](https://pbt-models.github.io/pbtm/reference/fit_hydrothermal_priming.md),
[`fit_aging()`](https://pbt-models.github.io/pbtm/reference/fit_aging.md),
[`fit_promoter()`](https://pbt-models.github.io/pbtm/reference/fit_promoter.md)
and
[`fit_inhibitor()`](https://pbt-models.github.io/pbtm/reference/fit_inhibitor.md).

## Examples

``` r
fit <- fit_pbtm(thermal_time_data, "thermal_time")
fit
#> <pbtm_fit> Thermal time model
#> 
#>       t_b theta_t50     sigma 
#>     3.648      1419   0.06734 
#> 
#> n = 100, pseudo-R2 = 0.9903, AIC = -686.8
coef(fit)
#>          t_b    theta_t50        sigma 
#> 3.648213e+00 1.419267e+03 6.733686e-02 

# hold the base temperature at 5 degrees
fit_pbtm(thermal_time_data, "thermal_time", fixed = list(t_b = 5))
#> <pbtm_fit> Thermal time model
#> 
#>      t_b* theta_t50     sigma 
#>         5      1297   0.07013 
#> (* held fixed)
#> 
#> n = 100, pseudo-R2 = 0.9705, AIC = -581.7
```

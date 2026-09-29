# Changelog

## pbtm 0.3.0

A rewrite that brings the package in line with the PBTM app, whose
models it now implements. **This release is not backwards compatible**:
every function has been renamed or replaced.

### New models and features

- All eight models of the PBTM app:
  [`fit_thermal_time()`](https://pbt-models.github.io/pbtm/reference/fit_thermal_time.md),
  [`fit_hydrotime()`](https://pbt-models.github.io/pbtm/reference/fit_hydrotime.md),
  [`fit_hydrothermal_time()`](https://pbt-models.github.io/pbtm/reference/fit_hydrothermal_time.md),
  [`fit_hydropriming()`](https://pbt-models.github.io/pbtm/reference/fit_hydropriming.md),
  [`fit_hydrothermal_priming()`](https://pbt-models.github.io/pbtm/reference/fit_hydrothermal_priming.md),
  [`fit_aging()`](https://pbt-models.github.io/pbtm/reference/fit_aging.md),
  [`fit_promoter()`](https://pbt-models.github.io/pbtm/reference/fit_promoter.md)
  and
  [`fit_inhibitor()`](https://pbt-models.github.io/pbtm/reference/fit_inhibitor.md),
  plus the general
  [`fit_pbtm()`](https://pbt-models.github.io/pbtm/reference/fit_pbtm.md).
  [`pbtm_models()`](https://pbt-models.github.io/pbtm/reference/pbtm_models.md)
  lists them with their parameters and default bounds.
- Common fitting options for every model: `max_frac`, `fixed`
  parameters, custom `bounds`, and a `cols` mapping for non-template
  column names. Promoter and inhibitor models take
  `dose_transform = "log10"`.
- Subpopulation mixtures for the cumulative models (`subpops = 2`, or
  `subpops = "auto"` to select the number by AIC).
- Fits return a `pbtm_fit` object with
  [`print()`](https://rdrr.io/r/base/print.html),
  [`summary()`](https://rdrr.io/r/base/summary.html),
  [`coef()`](https://rdrr.io/r/stats/coef.html),
  [`predict()`](https://rdrr.io/r/stats/predict.html),
  [`fitted()`](https://rdrr.io/r/stats/fitted.values.html),
  [`residuals()`](https://rdrr.io/r/stats/residuals.html),
  [`nobs()`](https://rdrr.io/r/stats/nobs.html),
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html) and
  [`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html)
  methods.
- Linearized plots:
  [`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html)
  takes `x_scale = "log"` and `y_scale = "probit"` (or `"logit"`), and
  `type = "normalized"` plots all treatments on the model’s normalized
  threshold axis, where they fall on one straight line.
- Warnings when a fit does not converge or an estimate is on a bound. A
  single-population fit that does not converge from the default starting
  values is retried from alternative starting values.
- [`validate_germ_data()`](https://pbt-models.github.io/pbtm/reference/validate_germ_data.md)
  and the `pbtm_columns` table describe and check the data template.
- Example datasets for every model (see
  [`?pbtm_datasets`](https://pbt-models.github.io/pbtm/reference/pbtm_datasets.md)),
  and a vignette for each model.

### Renamed and replaced functions

| 0.2.0 | 0.3.0 |
|----|----|
| `calcTTSubOModel()` | [`fit_thermal_time()`](https://pbt-models.github.io/pbtm/reference/fit_thermal_time.md) |
| `calcHTModel()` | [`fit_hydrotime()`](https://pbt-models.github.io/pbtm/reference/fit_hydrotime.md) |
| `calcHTTModel()` | [`fit_hydrothermal_time()`](https://pbt-models.github.io/pbtm/reference/fit_hydrothermal_time.md) |
| `calcHPModel()` | [`fit_hydropriming()`](https://pbt-models.github.io/pbtm/reference/fit_hydropriming.md) |
| `calcHTPModel()` | [`fit_hydrothermal_priming()`](https://pbt-models.github.io/pbtm/reference/fit_hydrothermal_priming.md) |
| `plotTTSubOModel()`, `plotHTModel()`, `plotHTTModel()`, `plotHPModel()`, `plotHTPModel()` | [`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html) / [`plot()`](https://rdrr.io/r/graphics/plot.default.html) on the fit |
| `plotRawData()` | [`plot_germ_data()`](https://pbt-models.github.io/pbtm/reference/plot_germ_data.md) |
| `calcSpeed()` | [`germ_speed()`](https://pbt-models.github.io/pbtm/reference/germ_speed.md) (long format: `Fraction`, `Time`, `GR` columns) |
| `cleanData()` | [`clean_germ_data()`](https://pbt-models.github.io/pbtm/reference/clean_germ_data.md) |
| `calcCumFrac()` | [`calc_cum_frac()`](https://pbt-models.github.io/pbtm/reference/calc_cum_frac.md) |
| `mergeTrts()` | [`rescale_cum_frac()`](https://pbt-models.github.io/pbtm/reference/rescale_cum_frac.md) |
| `plotRateVsTrt()` | removed; use ggplot2 on [`germ_speed()`](https://pbt-models.github.io/pbtm/reference/germ_speed.md) output |
| `myGermData`, `myPrimingData` | `germination_data`, `hydrothermal_time_data`, `hydrothermal_priming_data`, … |

Other changes:

- Arguments use snake_case (`max_frac` instead of `max.cum.frac`).
  Instead of one argument per column name, columns are mapped with
  `cols`.
- Parameter names follow the app: `t_b`, `theta_t50`, `theta_h`,
  `psi_b50`, `sigma`, and so on. Thermal time is estimated on the raw
  scale (`theta_t50` in degree-hours), not in log10 units as `ThetaT50`
  was.
- Fitting functions no longer print or plot as a side effect, and errors
  are raised as conditions rather than printed.
- Priming models take the germination time courses and compute the rates
  themselves (`speed = 0.5` for GR50); a table with a `GR` column can
  still be supplied directly.

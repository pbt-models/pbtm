# pbtm 0.3.0

A rewrite that brings the package in line with the PBTM app, whose models it
now implements. **This release is not backwards compatible**: every function
has been renamed or replaced.

## New models and features

* All eight models of the PBTM app: `fit_thermal_time()`, `fit_hydrotime()`,
  `fit_hydrothermal_time()`, `fit_hydropriming()`,
  `fit_hydrothermal_priming()`, `fit_aging()`, `fit_promoter()` and
  `fit_inhibitor()`, plus the general `fit_pbtm()`. `pbtm_models()` lists them
  with their parameters and default bounds.
* Common fitting options for every model: `max_frac`, `fixed` parameters,
  custom `bounds`, and a `cols` mapping for non-template column names.
  Promoter and inhibitor models take `dose_transform = "log10"`.
* Subpopulation mixtures for the cumulative models (`subpops = 2`, or
  `subpops = "auto"` to select the number by AIC).
* Fits return a `pbtm_fit` object with `print()`, `summary()`, `coef()`,
  `predict()`, `fitted()`, `residuals()`, `nobs()`, `plot()` and `autoplot()`
  methods.
* Linearized plots: `autoplot()` takes `x_scale = "log"` and
  `y_scale = "probit"` (or `"logit"`), and `type = "normalized"` plots all
  treatments on the model's normalized threshold axis, where they fall on one
  straight line.
* Warnings when a fit does not converge or an estimate is on a bound. A
  single-population fit that does not converge from the default starting
  values is retried from alternative starting values.
* `validate_germ_data()` and the `pbtm_columns` table describe and check the
  data template.
* Example datasets for every model (see `?pbtm_datasets`), and a vignette for
  each model.

## Renamed and replaced functions

| 0.2.0 | 0.3.0 |
|---|---|
| `calcTTSubOModel()` | `fit_thermal_time()` |
| `calcHTModel()` | `fit_hydrotime()` |
| `calcHTTModel()` | `fit_hydrothermal_time()` |
| `calcHPModel()` | `fit_hydropriming()` |
| `calcHTPModel()` | `fit_hydrothermal_priming()` |
| `plotTTSubOModel()`, `plotHTModel()`, `plotHTTModel()`, `plotHPModel()`, `plotHTPModel()` | `autoplot()` / `plot()` on the fit |
| `plotRawData()` | `plot_germ_data()` |
| `calcSpeed()` | `germ_speed()` (long format: `Fraction`, `Time`, `GR` columns) |
| `cleanData()` | `clean_germ_data()` |
| `calcCumFrac()` | `calc_cum_frac()` |
| `mergeTrts()` | `rescale_cum_frac()` |
| `plotRateVsTrt()` | removed; use ggplot2 on `germ_speed()` output |
| `myGermData`, `myPrimingData` | `germination_data`, `hydrothermal_time_data`, `hydrothermal_priming_data`, ... |

Other changes:

* Arguments use snake_case (`max_frac` instead of `max.cum.frac`). Instead of
  one argument per column name, columns are mapped with `cols`.
* Parameter names follow the app: `t_b`, `theta_t50`, `theta_h`, `psi_b50`,
  `sigma`, and so on. Thermal time is estimated on the raw scale (`theta_t50`
  in degree-hours), not in log10 units as `ThetaT50` was.
* Fitting functions no longer print or plot as a side effect, and errors are
  raised as conditions rather than printed.
* Priming models take the germination time courses and compute the rates
  themselves (`speed = 0.5` for GR50); a table with a `GR` column can still be
  supplied directly.

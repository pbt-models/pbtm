# Package index

## Fitting models

Fit a population-based threshold model to germination data.

- [`fit_pbtm()`](https://pbt-models.github.io/pbtm/reference/fit_pbtm.md)
  : Fit a population-based threshold model
- [`fit_aging()`](https://pbt-models.github.io/pbtm/reference/fit_aging.md)
  : Aging model
- [`fit_hydropriming()`](https://pbt-models.github.io/pbtm/reference/fit_hydropriming.md)
  : Hydropriming model
- [`fit_hydrothermal_priming()`](https://pbt-models.github.io/pbtm/reference/fit_hydrothermal_priming.md)
  : Hydrothermal priming model
- [`fit_hydrothermal_time()`](https://pbt-models.github.io/pbtm/reference/fit_hydrothermal_time.md)
  : Hydrothermal time model
- [`fit_hydrotime()`](https://pbt-models.github.io/pbtm/reference/fit_hydrotime.md)
  : Hydrotime model
- [`fit_inhibitor()`](https://pbt-models.github.io/pbtm/reference/fit_inhibitor.md)
  : Inhibitor model
- [`fit_promoter()`](https://pbt-models.github.io/pbtm/reference/fit_promoter.md)
  : Promoter model
- [`fit_thermal_time()`](https://pbt-models.github.io/pbtm/reference/fit_thermal_time.md)
  : Thermal time model
- [`pbtm_models()`](https://pbt-models.github.io/pbtm/reference/pbtm_models.md)
  : Available population-based threshold models

## Working with fitted models

- [`print(`*`<pbtm_fit>`*`)`](https://pbt-models.github.io/pbtm/reference/pbtm_fit-methods.md)
  [`summary(`*`<pbtm_fit>`*`)`](https://pbt-models.github.io/pbtm/reference/pbtm_fit-methods.md)
  [`print(`*`<summary.pbtm_fit>`*`)`](https://pbt-models.github.io/pbtm/reference/pbtm_fit-methods.md)
  [`coef(`*`<pbtm_fit>`*`)`](https://pbt-models.github.io/pbtm/reference/pbtm_fit-methods.md)
  [`fitted(`*`<pbtm_fit>`*`)`](https://pbt-models.github.io/pbtm/reference/pbtm_fit-methods.md)
  [`residuals(`*`<pbtm_fit>`*`)`](https://pbt-models.github.io/pbtm/reference/pbtm_fit-methods.md)
  [`nobs(`*`<pbtm_fit>`*`)`](https://pbt-models.github.io/pbtm/reference/pbtm_fit-methods.md)
  [`predict(`*`<pbtm_fit>`*`)`](https://pbt-models.github.io/pbtm/reference/pbtm_fit-methods.md)
  : Methods for fitted PBTM models
- [`autoplot(`*`<pbtm_fit>`*`)`](https://pbt-models.github.io/pbtm/reference/autoplot.pbtm_fit.md)
  [`plot(`*`<pbtm_fit>`*`)`](https://pbt-models.github.io/pbtm/reference/autoplot.pbtm_fit.md)
  : Plot a fitted PBTM model

## Germination data

Check, clean, summarize, and plot germination time courses.

- [`validate_germ_data()`](https://pbt-models.github.io/pbtm/reference/validate_germ_data.md)
  : Check germination data against the PBTM template
- [`germ_speed()`](https://pbt-models.github.io/pbtm/reference/germ_speed.md)
  : Germination speed and rate
- [`rescale_cum_frac()`](https://pbt-models.github.io/pbtm/reference/rescale_cum_frac.md)
  : Pool germination curves across treatments
- [`clean_germ_data()`](https://pbt-models.github.io/pbtm/reference/clean_germ_data.md)
  : Remove repeated cumulative fractions
- [`calc_cum_frac()`](https://pbt-models.github.io/pbtm/reference/calc_cum_frac.md)
  : Cumulative germination fractions from seed counts
- [`plot_germ_data()`](https://pbt-models.github.io/pbtm/reference/plot_germ_data.md)
  : Plot germination time courses

## Datasets

- [`germination_data`](https://pbt-models.github.io/pbtm/reference/pbtm_datasets.md)
  [`thermal_time_data`](https://pbt-models.github.io/pbtm/reference/pbtm_datasets.md)
  [`thermal_time_subpop_data`](https://pbt-models.github.io/pbtm/reference/pbtm_datasets.md)
  [`hydrotime_data`](https://pbt-models.github.io/pbtm/reference/pbtm_datasets.md)
  [`hydrothermal_time_data`](https://pbt-models.github.io/pbtm/reference/pbtm_datasets.md)
  [`hydropriming_data`](https://pbt-models.github.io/pbtm/reference/pbtm_datasets.md)
  [`hydrothermal_priming_data`](https://pbt-models.github.io/pbtm/reference/pbtm_datasets.md)
  [`aging_data`](https://pbt-models.github.io/pbtm/reference/pbtm_datasets.md)
  [`promoter_data`](https://pbt-models.github.io/pbtm/reference/pbtm_datasets.md)
  [`inhibitor_data`](https://pbt-models.github.io/pbtm/reference/pbtm_datasets.md)
  : Example germination datasets
- [`pbtm_columns`](https://pbt-models.github.io/pbtm/reference/pbtm_columns.md)
  : PBTM data template columns

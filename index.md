# pbtm: population-based threshold models of seed germination

pbtm fits population-based threshold (PBT) models to seed germination
time courses. Each seed has a threshold for a factor such as
temperature, water potential, a hormone, or aging, and thresholds vary
normally across the seed population. Fitting the models estimates the
threshold distribution and the time constant of the response, from which
germination under other conditions can be predicted.

The package implements the models of the [PBTM
app](https://github.com/pbt-models/pbtm-app):

| Model | Function |
|----|----|
| Thermal time | [`fit_thermal_time()`](https://pbt-models.github.io/pbtm/reference/fit_thermal_time.md) |
| Hydrotime | [`fit_hydrotime()`](https://pbt-models.github.io/pbtm/reference/fit_hydrotime.md) |
| Hydrothermal time | [`fit_hydrothermal_time()`](https://pbt-models.github.io/pbtm/reference/fit_hydrothermal_time.md) |
| Hydropriming | [`fit_hydropriming()`](https://pbt-models.github.io/pbtm/reference/fit_hydropriming.md) |
| Hydrothermal priming | [`fit_hydrothermal_priming()`](https://pbt-models.github.io/pbtm/reference/fit_hydrothermal_priming.md) |
| Aging | [`fit_aging()`](https://pbt-models.github.io/pbtm/reference/fit_aging.md) |
| Promoter (e.g. gibberellin) | [`fit_promoter()`](https://pbt-models.github.io/pbtm/reference/fit_promoter.md) |
| Inhibitor (e.g. abscisic acid) | [`fit_inhibitor()`](https://pbt-models.github.io/pbtm/reference/fit_inhibitor.md) |

The cumulative models can also be fit as mixtures of seed subpopulations
(`subpops = 2`, or `"auto"` to choose by AIC). Helpers compute
germination speeds and rates
([`germ_speed()`](https://pbt-models.github.io/pbtm/reference/germ_speed.md)),
pool and clean time courses, and validate data against the PBTM
template.

## Installation

pbtm is not on CRAN. Install it from GitHub:

``` r

# install.packages("remotes")
remotes::install_github("pbt-models/pbtm")
```

## Usage

``` r

library(pbtm)

fit <- fit_thermal_time(thermal_time_data)
fit
#> <pbtm_fit> Thermal time model
#>
#>       t_b theta_t50     sigma
#>     3.648      1419   0.06734
#>
#> n = 100, pseudo-R2 = 0.9903, AIC = -686.8

autoplot(fit)                                        # data and fitted curves
autoplot(fit, x_scale = "log", y_scale = "probit")   # linearized scales
autoplot(fit, type = "normalized")                   # all treatments on one line
```

Start with
[`vignette("pbtm")`](https://pbt-models.github.io/pbtm/articles/pbtm.md),
then see the vignette for each model.

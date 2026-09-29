<!-- badges: start -->
[![R-CMD-check](https://github.com/pbt-models/pbtm/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/pbt-models/pbtm/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

# pbtm: population-based threshold models of seed germination

pbtm fits population-based threshold (PBT) models to seed germination time
courses. Each seed has a threshold for a factor such as temperature, water
potential, a hormone, or aging, and thresholds vary normally across the seed
population. Fitting the models estimates the threshold distribution and the
time constant of the response, from which germination under other conditions
can be predicted.

The package implements the models of the
[PBTM app](https://github.com/pbt-models/pbtm-app):

| Model | Function |
|---|---|
| Thermal time | `fit_thermal_time()` |
| Hydrotime | `fit_hydrotime()` |
| Hydrothermal time | `fit_hydrothermal_time()` |
| Hydropriming | `fit_hydropriming()` |
| Hydrothermal priming | `fit_hydrothermal_priming()` |
| Aging | `fit_aging()` |
| Promoter (e.g. gibberellin) | `fit_promoter()` |
| Inhibitor (e.g. abscisic acid) | `fit_inhibitor()` |

The cumulative models can also be fit as mixtures of seed subpopulations
(`subpops = 2`, or `"auto"` to choose by AIC). Helpers compute germination
speeds and rates (`germ_speed()`), pool and clean time courses, and validate
data against the PBTM template.

## Installation

pbtm is not on CRAN. Install it from GitHub:

```r
# install.packages("remotes")
remotes::install_github("pbt-models/pbtm")
```

## Usage

```r
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

Start with `vignette("pbtm")`, then see the vignette for each model.

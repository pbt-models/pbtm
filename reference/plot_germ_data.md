# Plot germination time courses

Plots raw cumulative germination data, optionally on linearized scales
(see
[`autoplot.pbtm_fit()`](https://pbt-models.github.io/pbtm/reference/autoplot.pbtm_fit.md)).

## Usage

``` r
plot_germ_data(
  data,
  color = NULL,
  shape = NULL,
  group = "TrtID",
  line = TRUE,
  x_scale = c("linear", "log"),
  y_scale = c("linear", "probit", "logit")
)
```

## Arguments

- data:

  A data frame with `CumTime` and `CumFraction` columns.

- color, shape:

  Optional columns mapped to point color and shape.

- group:

  Column identifying each germination curve, used to draw lines.

- line:

  Connect the points of each curve?

- x_scale:

  `"linear"` or `"log"` time axis.

- y_scale:

  `"linear"`, `"probit"`, or `"logit"` fraction axis.

## Value

A ggplot object.

## See also

Other germination data helpers:
[`calc_cum_frac()`](https://pbt-models.github.io/pbtm/reference/calc_cum_frac.md),
[`clean_germ_data()`](https://pbt-models.github.io/pbtm/reference/clean_germ_data.md),
[`germ_speed()`](https://pbt-models.github.io/pbtm/reference/germ_speed.md),
[`pbtm_columns`](https://pbt-models.github.io/pbtm/reference/pbtm_columns.md),
[`rescale_cum_frac()`](https://pbt-models.github.io/pbtm/reference/rescale_cum_frac.md),
[`validate_germ_data()`](https://pbt-models.github.io/pbtm/reference/validate_germ_data.md)

## Examples

``` r
plot_germ_data(germination_data, color = "GermTemp")

plot_germ_data(germination_data, color = "GermTemp", x_scale = "log", y_scale = "probit")
```

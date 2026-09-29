# Remove repeated cumulative fractions

Keeps only the first observation of each cumulative fraction within a
germination curve, dropping later points where germination did not
increase. This is the "cleaned" data option of the PBTM app.

## Usage

``` r
clean_germ_data(data, groups = "TrtID")
```

## Arguments

- data:

  A data frame with `CumTime` and `CumFraction` columns.

- groups:

  Columns identifying each germination curve.

## Value

`data` without the repeated observations.

## See also

Other germination data helpers:
[`calc_cum_frac()`](https://pbt-models.github.io/pbtm/reference/calc_cum_frac.md),
[`germ_speed()`](https://pbt-models.github.io/pbtm/reference/germ_speed.md),
[`pbtm_columns`](https://pbt-models.github.io/pbtm/reference/pbtm_columns.md),
[`plot_germ_data()`](https://pbt-models.github.io/pbtm/reference/plot_germ_data.md),
[`rescale_cum_frac()`](https://pbt-models.github.io/pbtm/reference/rescale_cum_frac.md),
[`validate_germ_data()`](https://pbt-models.github.io/pbtm/reference/validate_germ_data.md)

## Examples

``` r
nrow(thermal_time_data)
#> [1] 100
nrow(clean_germ_data(thermal_time_data))
#> [1] 100
```

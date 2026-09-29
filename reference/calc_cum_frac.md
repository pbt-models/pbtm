# Cumulative germination fractions from seed counts

Converts cumulative counts of germinated seeds into the `CumFraction`
column used throughout pbtm.

## Usage

``` r
calc_cum_frac(data, n_germinated = "nGerminated", n_total = "nTotal")
```

## Arguments

- data:

  A data frame of germination observations.

- n_germinated:

  Column with the cumulative number of germinated seeds.

- n_total:

  Column with the total number of seeds in the treatment.

## Value

`data` with a `CumFraction` column added.

## See also

Other germination data helpers:
[`clean_germ_data()`](https://pbt-models.github.io/pbtm/reference/clean_germ_data.md),
[`germ_speed()`](https://pbt-models.github.io/pbtm/reference/germ_speed.md),
[`pbtm_columns`](https://pbt-models.github.io/pbtm/reference/pbtm_columns.md),
[`plot_germ_data()`](https://pbt-models.github.io/pbtm/reference/plot_germ_data.md),
[`rescale_cum_frac()`](https://pbt-models.github.io/pbtm/reference/rescale_cum_frac.md),
[`validate_germ_data()`](https://pbt-models.github.io/pbtm/reference/validate_germ_data.md)

## Examples

``` r
counts <- data.frame(
  TrtID = 1, CumTime = c(24, 48, 72),
  nGerminated = c(5, 30, 45), nTotal = 50
)
calc_cum_frac(counts)
#>   TrtID CumTime nGerminated nTotal CumFraction
#> 1     1      24           5     50         0.1
#> 2     1      48          30     50         0.6
#> 3     1      72          45     50         0.9
```

# Pool germination curves across treatments

Recomputes cumulative germination fractions after pooling treatments:
the germination increments of every curve (identified by `TrtID`) in a
group are summed at each observation time and re-accumulated. The pooled
curve is scaled to reach the highest final fraction observed in the
group.

## Usage

``` r
rescale_cum_frac(data, groups)
```

## Arguments

- data:

  A data frame with `TrtID`, `CumTime`, and `CumFraction` columns and
  any columns named in `groups`.

- groups:

  Columns to keep; curves sharing the same values of these columns are
  pooled. Use [`character()`](https://rdrr.io/r/base/character.html) to
  pool everything.

## Value

A tibble with the `groups` columns, `CumTime`, and the pooled
`CumFraction`.

## See also

Other germination data helpers:
[`calc_cum_frac()`](https://pbt-models.github.io/pbtm/reference/calc_cum_frac.md),
[`clean_germ_data()`](https://pbt-models.github.io/pbtm/reference/clean_germ_data.md),
[`germ_speed()`](https://pbt-models.github.io/pbtm/reference/germ_speed.md),
[`pbtm_columns`](https://pbt-models.github.io/pbtm/reference/pbtm_columns.md),
[`plot_germ_data()`](https://pbt-models.github.io/pbtm/reference/plot_germ_data.md),
[`validate_germ_data()`](https://pbt-models.github.io/pbtm/reference/validate_germ_data.md)

## Examples

``` r
# pool the replicate treatments at each temperature
rescale_cum_frac(germination_data, groups = "GermTemp")
#> # A tibble: 102 × 3
#>    GermTemp CumTime CumFraction
#>       <dbl>   <dbl>       <dbl>
#>  1       15      95      0.0625
#>  2       15     101      0.0833
#>  3       15     103      0.104 
#>  4       15     106      0.125 
#>  5       15     108      0.167 
#>  6       15     110      0.208 
#>  7       15     112      0.25  
#>  8       15     115      0.281 
#>  9       15     118      0.344 
#> 10       15     120      0.396 
#> # ℹ 92 more rows
```

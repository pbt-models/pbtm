# Germination speed and rate

Interpolates the time for each group of germination curves to reach one
or more germination fractions (e.g. T50, the time to 50% germination)
and the corresponding germination rate (GR = 1 / time).

## Usage

``` r
germ_speed(data, fractions = 0.5, groups = "TrtID", extrapolate = TRUE)
```

## Arguments

- data:

  A data frame with `TrtID`, `CumTime`, and `CumFraction` columns and
  any columns named in `groups`.

- fractions:

  Germination fractions (0-1) to interpolate, e.g. `c(0.1, 0.5, 0.9)`.

- groups:

  Columns defining the groups to summarize. Defaults to each treatment
  (`TrtID`).

- extrapolate:

  What to return for a fraction that a group never reaches (or that
  falls before its first observation). If `TRUE`, the time of the
  closest observation is returned (the behavior of earlier versions of
  pbtm and the PBTM app); if `FALSE`, `NA`.

## Value

A tibble with the `groups` columns plus `Fraction`, `Time`, and `GR`,
one row per group and fraction.

## Details

When `groups` pools several treatments (curves identified by `TrtID`),
the curves are first combined with
[`rescale_cum_frac()`](https://pbt-models.github.io/pbtm/reference/rescale_cum_frac.md),
so the result describes the pooled population.

## See also

Other germination data helpers:
[`calc_cum_frac()`](https://pbt-models.github.io/pbtm/reference/calc_cum_frac.md),
[`clean_germ_data()`](https://pbt-models.github.io/pbtm/reference/clean_germ_data.md),
[`pbtm_columns`](https://pbt-models.github.io/pbtm/reference/pbtm_columns.md),
[`plot_germ_data()`](https://pbt-models.github.io/pbtm/reference/plot_germ_data.md),
[`rescale_cum_frac()`](https://pbt-models.github.io/pbtm/reference/rescale_cum_frac.md),
[`validate_germ_data()`](https://pbt-models.github.io/pbtm/reference/validate_germ_data.md)

## Examples

``` r
germ_speed(germination_data, fractions = c(0.1, 0.5, 0.9))
#> # A tibble: 9 × 4
#>   TrtID Fraction  Time      GR
#>   <dbl>    <dbl> <dbl>   <dbl>
#> 1     1      0.1 103.  0.00975
#> 2     1      0.5 126.  0.00792
#> 3     1      0.9 151.  0.00662
#> 4     4      0.1  73.3 0.0136 
#> 5     4      0.5  87.7 0.0114 
#> 6     4      0.9 102.  0.00982
#> 7     7      0.1  50.9 0.0196 
#> 8     7      0.5  67.6 0.0148 
#> 9     7      0.9  80.9 0.0124 

# pooled across treatments at each temperature
germ_speed(germination_data, 0.5, groups = "GermTemp")
#> # A tibble: 3 × 4
#>   GermTemp Fraction  Time      GR
#>      <dbl>    <dbl> <dbl>   <dbl>
#> 1       15      0.5 126.  0.00792
#> 2       20      0.5  87.7 0.0114 
#> 3       25      0.5  67.6 0.0148 
```

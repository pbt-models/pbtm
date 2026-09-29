# PBTM data template columns

The columns recognized by pbtm, with their meaning, expected type and
valid range, and which models require them. Data can use other column
names if they are mapped with the `cols` argument of
[`fit_pbtm()`](https://pbt-models.github.io/pbtm/reference/fit_pbtm.md).

## Usage

``` r
pbtm_columns
```

## Format

A tibble with one row per template column:

- Column:

  Column name.

- Role:

  `"Factor"` (treatment) or `"Response"`.

- Description, LongDescription, TypeDescription:

  Human-readable descriptions.

- Type:

  `"numeric"` for numeric columns, `NA` otherwise.

- Min, Max:

  Valid range, checked by
  [`validate_germ_data()`](https://pbt-models.github.io/pbtm/reference/validate_germ_data.md).

- germination, thermal_time, ..., inhibitor:

  Whether each model requires the column.

## See also

Other germination data helpers:
[`calc_cum_frac()`](https://pbt-models.github.io/pbtm/reference/calc_cum_frac.md),
[`clean_germ_data()`](https://pbt-models.github.io/pbtm/reference/clean_germ_data.md),
[`germ_speed()`](https://pbt-models.github.io/pbtm/reference/germ_speed.md),
[`plot_germ_data()`](https://pbt-models.github.io/pbtm/reference/plot_germ_data.md),
[`rescale_cum_frac()`](https://pbt-models.github.io/pbtm/reference/rescale_cum_frac.md),
[`validate_germ_data()`](https://pbt-models.github.io/pbtm/reference/validate_germ_data.md)

## Examples

``` r
pbtm_columns[, c("Column", "Description", "Min", "Max")]
#> # A tibble: 12 × 4
#>    Column              Description                       Min   Max
#>    <chr>               <chr>                           <dbl> <dbl>
#>  1 TrtID               Treatment ID                       NA    NA
#>  2 TrtDesc             Treatment description              NA    NA
#>  3 GermTemp            Germination temperature             0   100
#>  4 GermWP              Germination water potential        NA     0
#>  5 PrimingTemp         Priming temperature                 0   100
#>  6 PrimingWP           Priming water potential            NA     0
#>  7 PrimingDuration     Priming duration                    0    NA
#>  8 AgingTime           Aging time                          0    NA
#>  9 GermPromoterDosage  Germination promoter dosage         0    NA
#> 10 GermInhibitorDosage Germination inhibitor dosage        0    NA
#> 11 CumTime             Cumulative time                     0    NA
#> 12 CumFraction         Cumulative germination fraction     0     1
```

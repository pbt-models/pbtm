# Check germination data against the PBTM template

Checks that the columns used by pbtm are present, numeric, and within
the ranges listed in
[pbtm_columns](https://pbt-models.github.io/pbtm/reference/pbtm_columns.md)
(for example, `CumFraction` must be between 0 and 1 and water potentials
must not be positive). Columns that are not part of the template are
ignored.

## Usage

``` r
validate_germ_data(data, model = NULL, cols = NULL)
```

## Arguments

- data:

  A data frame of germination data.

- model:

  Optional model id from
  [`pbtm_models()`](https://pbt-models.github.io/pbtm/reference/pbtm_models.md).
  If supplied, the columns that model requires must be present.

- cols:

  Optional named character vector mapping template column names to the
  names used in `data` (see
  [`fit_pbtm()`](https://pbt-models.github.io/pbtm/reference/fit_pbtm.md)).

## Value

`data` (renamed with `cols`), invisibly. Throws an error listing all
problems found.

## See also

Other germination data helpers:
[`calc_cum_frac()`](https://pbt-models.github.io/pbtm/reference/calc_cum_frac.md),
[`clean_germ_data()`](https://pbt-models.github.io/pbtm/reference/clean_germ_data.md),
[`germ_speed()`](https://pbt-models.github.io/pbtm/reference/germ_speed.md),
[`pbtm_columns`](https://pbt-models.github.io/pbtm/reference/pbtm_columns.md),
[`plot_germ_data()`](https://pbt-models.github.io/pbtm/reference/plot_germ_data.md),
[`rescale_cum_frac()`](https://pbt-models.github.io/pbtm/reference/rescale_cum_frac.md)

## Examples

``` r
validate_germ_data(thermal_time_data, "thermal_time")

bad <- thermal_time_data
bad$CumFraction <- bad$CumFraction * 100
try(validate_germ_data(bad))
#> Error in validate_germ_data(bad) : 
#>   Germination data failed validation.
#> ✖ `CumFraction` has values above 1.
```

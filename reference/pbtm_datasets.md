# Example germination datasets

Germination time courses used in the examples and vignettes, one for
each model. Every dataset follows the PBTM template (see
[pbtm_columns](https://pbt-models.github.io/pbtm/reference/pbtm_columns.md)):
each row is one observation of a germination curve, with the treatment
id (`TrtID`) and description (`TrtDesc`), the treatment conditions, the
cumulative time (`CumTime`, hours), and the cumulative fraction
germinated (`CumFraction`, 0-1).

## Usage

``` r
germination_data

thermal_time_data

thermal_time_subpop_data

hydrotime_data

hydrothermal_time_data

hydropriming_data

hydrothermal_priming_data

aging_data

promoter_data

inhibitor_data
```

## Format

Tibbles with columns `TrtID`, `TrtDesc`, the treatment columns listed
above, `CumTime`, and `CumFraction`.

An object of class `tbl_df` (inherits from `tbl`, `data.frame`) with 100
rows and 5 columns.

An object of class `tbl_df` (inherits from `tbl`, `data.frame`) with 133
rows and 5 columns.

An object of class `tbl_df` (inherits from `tbl`, `data.frame`) with 125
rows and 5 columns.

An object of class `tbl_df` (inherits from `tbl`, `data.frame`) with 398
rows and 6 columns.

An object of class `tbl_df` (inherits from `tbl`, `data.frame`) with 91
rows and 6 columns.

An object of class `tbl_df` (inherits from `tbl`, `data.frame`) with 252
rows and 7 columns.

An object of class `tbl_df` (inherits from `tbl`, `data.frame`) with 93
rows and 5 columns.

An object of class `tbl_df` (inherits from `tbl`, `data.frame`) with 57
rows and 5 columns.

An object of class `tbl_df` (inherits from `tbl`, `data.frame`) with 97
rows and 5 columns.

## Source

Sample datasets of the PBTM app,
<https://github.com/pbt-models/pbtm-app>.

## Details

- `germination_data`: tomato seeds germinated in water at 15, 20 and 25
  °C (`GermTemp`); for germination speed calculations.

- `thermal_time_data`: tomato seeds germinated in water at 15, 20 and 25
  °C (`GermTemp`); for
  [`fit_thermal_time()`](https://pbt-models.github.io/pbtm/reference/fit_thermal_time.md).

- `thermal_time_subpop_data`: germination at 15, 17.5, 20 and 22.5 °C
  (`GermTemp`) of a seed lot combining two subpopulations; for
  [`fit_thermal_time()`](https://pbt-models.github.io/pbtm/reference/fit_thermal_time.md)
  with `subpops`.

- `hydrotime_data`: tomato seeds germinated at 20 °C at 0, -0.25 and
  -0.4 MPa (`GermWP`); for
  [`fit_hydrotime()`](https://pbt-models.github.io/pbtm/reference/fit_hydrotime.md).

- `hydrothermal_time_data`: tomato seeds germinated at 15, 20 and 25 °C
  (`GermTemp`) crossed with 0, -0.25 and -0.4 MPa (`GermWP`); for
  [`fit_hydrothermal_time()`](https://pbt-models.github.io/pbtm/reference/fit_hydrothermal_time.md).

- `hydropriming_data`: germination after priming at 0 to -1.42 MPa
  (`PrimingWP`) for 0 to 148 hours (`PrimingDuration`), including
  unprimed controls; for
  [`fit_hydropriming()`](https://pbt-models.github.io/pbtm/reference/fit_hydropriming.md).

- `hydrothermal_priming_data`: germination after priming at -0.51 to
  -1.42 MPa (`PrimingWP`) and 10 to 15 °C (`PrimingTemp`) for 24 to 148
  hours (`PrimingDuration`); for
  [`fit_hydrothermal_priming()`](https://pbt-models.github.io/pbtm/reference/fit_hydrothermal_priming.md).

- `aging_data`: lettuce seeds after 0, 2, 4 and 6 days of accelerated
  aging (`AgingTime`); for
  [`fit_aging()`](https://pbt-models.github.io/pbtm/reference/fit_aging.md).

- `promoter_data`: tomato seeds germinated with 1, 10 and 100 units of
  gibberellin (`GermPromoterDosage`); for
  [`fit_promoter()`](https://pbt-models.github.io/pbtm/reference/fit_promoter.md).

- `inhibitor_data`: tomato seeds germinated with 0.08 to 10 units of
  abscisic acid (`GermInhibitorDosage`); for
  [`fit_inhibitor()`](https://pbt-models.github.io/pbtm/reference/fit_inhibitor.md).

## Examples

``` r
head(thermal_time_data)
#> # A tibble: 6 × 5
#>   TrtID TrtDesc          GermTemp CumTime CumFraction
#>   <dbl> <chr>               <dbl>   <dbl>       <dbl>
#> 1     1 Tomato-15C-Water       15      95       0.063
#> 2     1 Tomato-15C-Water       15     101       0.083
#> 3     1 Tomato-15C-Water       15     103       0.104
#> 4     1 Tomato-15C-Water       15     106       0.125
#> 5     1 Tomato-15C-Water       15     108       0.167
#> 6     1 Tomato-15C-Water       15     110       0.208
plot_germ_data(thermal_time_data, color = "GermTemp")
```

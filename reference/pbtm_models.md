# Available population-based threshold models

Lists the models that
[`fit_pbtm()`](https://pbt-models.github.io/pbtm/reference/fit_pbtm.md)
can fit, with the data columns each one requires and its parameters and
their default bounds.

## Usage

``` r
pbtm_models(model = NULL)
```

## Arguments

- model:

  Optional model id. If supplied, the full model definition is returned
  instead of the summary table (mainly useful for developers).

## Value

A tibble with one row per model: `model` (the id passed to
[`fit_pbtm()`](https://pbt-models.github.io/pbtm/reference/fit_pbtm.md)),
`label`, `family` (`"cdf"` for cumulative germination models, `"rate"`
for germination-rate models), `factors` (treatment columns required in
addition to `CumTime` and `CumFraction`), `params`, and `bounds` (a list
column of data frames giving `lower`, `start`, and `upper` for each
parameter).

## Examples

``` r
pbtm_models()
#> # A tibble: 8 × 6
#>   model                label                family factors      params    bounds
#>   <chr>                <chr>                <chr>  <named list> <named l> <name>
#> 1 thermal_time         Thermal time         cdf    <chr [1]>    <chr [3]> <df>  
#> 2 hydrotime            Hydrotime            cdf    <chr [1]>    <chr [3]> <df>  
#> 3 hydrothermal_time    Hydrothermal time    cdf    <chr [2]>    <chr [4]> <df>  
#> 4 hydropriming         Hydropriming         rate   <chr [2]>    <chr [3]> <df>  
#> 5 hydrothermal_priming Hydrothermal priming rate   <chr [3]>    <chr [4]> <df>  
#> 6 aging                Aging                cdf    <chr [1]>    <chr [3]> <df>  
#> 7 promoter             Promoter             cdf    <chr [1]>    <chr [3]> <df>  
#> 8 inhibitor            Inhibitor            cdf    <chr [1]>    <chr [3]> <df>  
pbtm_models()$bounds[[1]]
#>       param lower start   upper
#> 1       t_b 0e+00 6e+00 2.0e+01
#> 2 theta_t50 3e+00 1e+03 5.0e+19
#> 3     sigma 5e-04 1e-01 3.5e+01
```

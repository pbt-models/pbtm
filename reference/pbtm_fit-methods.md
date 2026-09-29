# Methods for fitted PBTM models

Standard methods for `pbtm_fit` objects returned by
[`fit_pbtm()`](https://pbt-models.github.io/pbtm/reference/fit_pbtm.md)
and the per-model fitting functions.

## Usage

``` r
# S3 method for class 'pbtm_fit'
print(x, digits = 4, ...)

# S3 method for class 'pbtm_fit'
summary(object, ...)

# S3 method for class 'summary.pbtm_fit'
print(x, digits = 4, ...)

# S3 method for class 'pbtm_fit'
coef(object, ...)

# S3 method for class 'pbtm_fit'
fitted(object, ...)

# S3 method for class 'pbtm_fit'
residuals(object, ...)

# S3 method for class 'pbtm_fit'
nobs(object, ...)

# S3 method for class 'pbtm_fit'
predict(object, newdata = NULL, type = c("response", "normalized"), ...)
```

## Arguments

- digits:

  Number of significant digits to print.

- ...:

  Unused.

- object, x:

  A `pbtm_fit` object.

- newdata:

  Optional data frame with the model's treatment columns (and `CumTime`
  for cumulative models) at which to predict. Defaults to the data used
  for fitting.

- type:

  For [`predict()`](https://rdrr.io/r/stats/predict.html): `"response"`
  returns the predicted cumulative fraction (or germination rate for
  rate models); `"normalized"` returns each observation's position on
  the model's normalized axis (e.g. thermal time, or base water
  potential for hydrotime), which is the x axis of
  `autoplot(type = "normalized")`. Single-population cumulative models
  only.

## Value

[`coef()`](https://rdrr.io/r/stats/coef.html),
[`fitted()`](https://rdrr.io/r/stats/fitted.values.html),
[`residuals()`](https://rdrr.io/r/stats/residuals.html) and
[`predict()`](https://rdrr.io/r/stats/predict.html) return numeric
vectors; [`summary()`](https://rdrr.io/r/base/summary.html) returns a
`summary.pbtm_fit` object with a `coefficients` table (estimates, and
standard errors where they can be computed) and fit statistics.

## Examples

``` r
fit <- fit_hydrotime(hydrotime_data)
coef(fit)
#>     theta_h     psi_b50       sigma 
#> 117.2436812  -1.3718682   0.1564849 
summary(fit)
#> Hydrotime model
#> 
#> Coefficients:
#>         estimate std_error fixed
#> theta_h 117.2437  2.151856 FALSE
#> psi_b50  -1.3719  0.020820 FALSE
#> sigma     0.1565  0.005303 FALSE
#> 
#> n = 125, parameters = 3, RSS = 0.4107, AIC = -706.8, pseudo-R2 = 0.9649
head(predict(fit, type = "normalized"))
#> [1] -1.674910 -1.651319 -1.606078 -1.584374 -1.563249 -1.542680
predict(fit, newdata = data.frame(GermWP = -0.5, CumTime = c(50, 100, 200)))
#> [1] 2.408966e-21 2.738152e-02 9.660307e-01
```

# Fit quietly: tests that care about warnings check them explicitly.
quiet_fit <- function(...) suppressWarnings(fit_pbtm(...))

# Simulate a noisy germination time course from a model's own prediction.
simulate_cdf <- function(model, params, grid, max_frac = 1, sd = 0.005, seed = 1) {
  m <- pbtm_models(model)
  set.seed(seed)
  y <- m$predict(grid, params, max_frac = max_frac)
  grid$CumFraction <- pmin(pmax(y + stats::rnorm(length(y), 0, sd), 0), 1)
  grid
}

builds <- function(p) {
  inherits(p, "ggplot") && !inherits(try(ggplot2::ggplot_build(p), silent = TRUE), "try-error")
}

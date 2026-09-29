test_that("stick-breaking weights form a simplex", {
  expect_equal(mixture_weights(list(), 1), 1)
  w <- mixture_weights(list(w1 = 0.3, w2 = 0.5), 3)
  expect_equal(w, c(0.3, 0.35, 0.35))
  expect_equal(sum(w), 1)
})

test_that("a one-component mixture equals the plain model", {
  m <- pbtm_models("hydrotime")
  p <- list(theta_h = 60, psi_b50 = -1, sigma = 0.2)
  d <- data.frame(GermWP = -0.3, CumTime = c(50, 100, 200))
  expect_equal(mixture_predict(m, d, p, 1, max_frac = 0.9), m$predict(d, p, max_frac = 0.9))
})

test_that("a two-subpopulation mixture is fit to data simulated from one", {
  skip_on_cran()
  m <- pbtm_models("thermal_time")
  grid <- expand.grid(GermTemp = c(12, 16, 20, 24), CumTime = seq(10, 400, by = 5))
  p <- list(t_b1 = 5, theta_t501 = 700, sigma1 = 0.05, t_b2 = 5, theta_t502 = 1600, sigma2 = 0.05, w1 = 0.4)
  set.seed(1)
  grid$CumFraction <- pmin(pmax(mixture_predict(m, grid, p, 2) + rnorm(nrow(grid), 0, 0.005), 0), 1)

  single <- fit_thermal_time(grid)
  mix <- suppressWarnings(fit_thermal_time(grid, subpops = 2))
  expect_equal(mix$k, 2L)
  expect_lt(mix$stats$aic, single$stats$aic)
  expect_gt(mix$stats$pseudo_r2, 0.995)
  expect_equal(sum(mix$components$weight), 1)
  expect_equal(nrow(mix$components), 2)
  # components are identified up to their order
  expect_equal(sort(mix$components$theta_t50), c(700, 1600), tolerance = 0.1)
  expect_equal(sort(mix$components$weight), c(0.4, 0.6), tolerance = 0.1)
})

test_that("auto detection returns a comparison table", {
  skip_on_cran()
  fit <- suppressWarnings(fit_thermal_time(thermal_time_subpop_data, subpops = "auto", max_subpops = 2))
  tbl <- fit$subpop_table
  expect_named(tbl, c("k", "npar", "pseudo_r2", "rss", "aic", "delta_aic"))
  expect_equal(min(tbl$delta_aic), 0)
  expect_equal(fit$k, tbl$k[which.min(tbl$aic)])
  expect_output(print(summary(fit)), "Subpopulation comparison")
})

test_that("mixture fitting does not disturb the caller's random numbers", {
  set.seed(42)
  expected <- runif(3)
  set.seed(42)
  suppressWarnings(fit_thermal_time(thermal_time_subpop_data, subpops = 2, restarts = 2))
  expect_equal(runif(3), expected)
})

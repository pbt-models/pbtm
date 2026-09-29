# Parameter recovery: data simulated from each model with known parameters (plus
# a little noise) should give back those parameters.

recovery_cases <- list(
  thermal_time = list(
    params = list(t_b = 5, theta_t50 = 1000, sigma = 0.08),
    grid = expand.grid(GermTemp = c(12, 16, 20, 24), CumTime = seq(20, 300, by = 5))
  ),
  hydrotime = list(
    params = list(theta_h = 60, psi_b50 = -1, sigma = 0.25),
    grid = expand.grid(GermWP = c(0, -0.3, -0.6), CumTime = seq(5, 400, by = 5))
  ),
  hydrothermal_time = list(
    params = list(theta_ht = 1000, t_b = 8, psi_b50 = -1, sigma = 0.2),
    grid = expand.grid(GermWP = c(0, -0.3, -0.6), GermTemp = c(15, 20, 25), CumTime = seq(10, 800, by = 10))
  ),
  aging = list(
    params = list(theta_a = 200, p_max50 = 20, sigma = 3),
    grid = expand.grid(AgingTime = c(0, 5, 10), CumTime = seq(1, 200, by = 2))
  ),
  promoter = list(
    params = list(theta_p = 100, p_b50 = 2, sigma = 1),
    grid = expand.grid(GermPromoterDosage = c(3, 5, 10), CumTime = seq(1, 300, by = 3))
  ),
  inhibitor = list(
    params = list(theta_i = 100, i_b50 = 10, sigma = 1),
    grid = expand.grid(GermInhibitorDosage = c(1, 3, 5), CumTime = seq(1, 200, by = 2))
  )
)

for (model in names(recovery_cases)) {
  test_that(paste(model, "recovers known parameters"), {
    case <- recovery_cases[[model]]
    data <- simulate_cdf(model, case$params, case$grid)
    fit <- fit_pbtm(data, model)
    expect_s3_class(fit, "pbtm_fit")
    expect_equal(as.list(coef(fit)), case$params, tolerance = 0.05)
    expect_gt(fit$stats$pseudo_r2, 0.99)
    expect_true(fit$converged)
  })
}

test_that("max_frac scales the plateau and is recovered from data that plateaus", {
  case <- recovery_cases$thermal_time
  data <- simulate_cdf("thermal_time", case$params, case$grid, max_frac = 0.8)
  fit <- fit_thermal_time(data, max_frac = 0.8)
  expect_equal(as.list(coef(fit)), case$params, tolerance = 0.05)
  expect_lte(max(fitted(fit)), 0.8)
})

test_that("rate models recover known parameters from a GR table", {
  grid <- expand.grid(PrimingWP = c(-1.5, -1, -0.5), PrimingDuration = c(24, 72, 120))
  grid$GR <- 0.01 + 2e-4 * (grid$PrimingWP + 2) * grid$PrimingDuration
  fit <- fit_hydropriming(grid)
  expect_equal(unname(coef(fit)), c(-2, 0.01, 2e-4), tolerance = 1e-4)
  expect_null(fit$speed)

  grid <- expand.grid(PrimingWP = c(-1.5, -1, -0.5), PrimingTemp = c(10, 15, 20), PrimingDuration = c(24, 72))
  grid$GR <- 0.01 + 1e-5 * (grid$PrimingWP + 2) * (grid$PrimingTemp - 5) * grid$PrimingDuration
  fit <- fit_hydrothermal_priming(grid)
  expect_equal(unname(coef(fit)), c(5, -2, 0.01, 1e-5), tolerance = 1e-3)
})

test_that("rate models compute rates at the requested speed", {
  fit50 <- quiet_fit(hydropriming_data, "hydropriming")
  fit25 <- quiet_fit(hydropriming_data, "hydropriming", speed = 0.25)
  expect_equal(fit50$speed, 0.5)
  expect_equal(unique(fit25$data$Fraction), 0.25)
  # seeds reach 25% sooner than 50%, so rates are higher
  expect_gt(mean(fit25$data$GR), mean(fit50$data$GR))
})

test_that("fixed parameters are held exactly", {
  fit <- fit_thermal_time(thermal_time_data, fixed = list(t_b = 5))
  expect_identical(coef(fit)[["t_b"]], 5)
  expect_equal(fit$fixed, "t_b")
  expect_equal(fit$stats$npar, 2)
  expect_true(summary(fit)$coefficients["t_b", "fixed"])
  # a vector works too
  expect_identical(coef(fit_thermal_time(thermal_time_data, fixed = c(t_b = 5)))[["t_b"]], 5)
})

test_that("bounds can be overridden and are respected", {
  # the unconstrained estimate is ~3.65, so a lower bound of 4 binds
  expect_warning(
    fit <- fit_thermal_time(thermal_time_data, bounds = list(t_b = c(4, 6, 8))),
    "at its bound"
  )
  expect_equal(coef(fit)[["t_b"]], 4)
  expect_equal(fit$at_bound, "t_b")
  expect_error(fit_thermal_time(thermal_time_data, bounds = list(t_b = c(5, 4, 8))), "lower <= start")
  expect_error(fit_thermal_time(thermal_time_data, bounds = list(Tb = c(0, 5, 8))), "must be named")
})

test_that("estimates on a bound produce a warning", {
  expect_warning(fit_promoter(promoter_data), "theta_p")
  expect_true("theta_p" %in% suppressWarnings(fit_promoter(promoter_data))$at_bound)
})

test_that("cols maps differently named columns", {
  renamed <- dplyr::rename(thermal_time_data, temp = GermTemp, hours = CumTime)
  fit <- fit_thermal_time(renamed, cols = c(GermTemp = "temp", CumTime = "hours"))
  expect_equal(coef(fit), coef(fit_thermal_time(thermal_time_data)))
  expect_error(fit_thermal_time(renamed, cols = c(GermTemp = "tmp")), "not in")
})

test_that("invalid input gives informative errors", {
  expect_error(fit_pbtm(thermal_time_data, "thermal"), "must be one of")
  expect_error(fit_pbtm(list(a = 1), "thermal_time"), "must be a data frame")
  expect_error(fit_hydrotime(thermal_time_data), "GermWP")
  expect_error(fit_thermal_time(thermal_time_data, max_frac = 1.5), "max_frac")
  expect_error(fit_thermal_time(thermal_time_data, max_frac = 0), "max_frac")
  expect_error(fit_thermal_time(thermal_time_data, dose_transform = "log10"), "promoter and inhibitor")
  expect_error(fit_thermal_time(thermal_time_data, fixed = list(foo = 1)), "must be named")
  expect_error(fit_thermal_time(thermal_time_data, subpops = 0), "positive whole number")
  expect_error(fit_thermal_time(thermal_time_data, subpops = 2, fixed = list(t_b = 5)), "single-population")
  expect_error(fit_hydropriming(hydropriming_data, subpops = 2), "cumulative germination models")
  expect_error(fit_hydropriming(hydropriming_data, speed = 1.2), "speed")
  bad_dose <- promoter_data
  bad_dose$GermPromoterDosage[1] <- 0
  expect_error(fit_promoter(bad_dose, dose_transform = "log10"), "positive")
})

test_that("incomplete rows are dropped before fitting", {
  data <- thermal_time_data
  data$CumFraction[1:5] <- NA
  fit <- fit_thermal_time(data)
  expect_equal(nobs(fit), nrow(thermal_time_data) - 5)
  # these data once stopped at a false convergence far from the optimum; the
  # restart fallback must still find it
  expect_true(fit$converged)
  expect_equal(coef(fit)[["t_b"]], 3.64, tolerance = 0.01)
})

test_that("pbtm_models lists every model with its bounds", {
  models <- pbtm_models()
  expect_setequal(
    models$model,
    c("thermal_time", "hydrotime", "hydrothermal_time", "hydropriming",
      "hydrothermal_priming", "aging", "promoter", "inhibitor")
  )
  for (i in seq_len(nrow(models))) {
    b <- models$bounds[[i]]
    expect_equal(b$param, models$params[[i]])
    expect_true(all(b$lower <= b$start & b$start <= b$upper))
  }
  expect_s3_class(pbtm_models("hydrotime"), "pbtm_model")
  expect_output(print(pbtm_models("hydrotime")), "Hydrotime")
})

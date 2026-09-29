fit <- fit_hydrotime(hydrotime_data)

test_that("coef, fitted, residuals and nobs are consistent", {
  expect_named(coef(fit), c("theta_h", "psi_b50", "sigma"))
  expect_length(fitted(fit), nrow(hydrotime_data))
  expect_equal(residuals(fit), hydrotime_data$CumFraction - fitted(fit))
  expect_equal(nobs(fit), nrow(hydrotime_data))
  expect_equal(fit$stats$rss, sum(residuals(fit)^2))
})

test_that("predict reproduces fitted values and handles new data", {
  expect_equal(predict(fit), fitted(fit), tolerance = 1e-8)
  new <- data.frame(GermWP = c(0, 0, -0.4), CumTime = c(50, 500, 500))
  pred <- predict(fit, new)
  expect_length(pred, 3)
  expect_true(all(pred >= 0 & pred <= 1))
  expect_gt(pred[2], pred[1])
  expect_error(predict(fit, data.frame(CumTime = 1)), "GermWP")
})

test_that("normalized predictions are the model's threshold axis", {
  p <- as.list(coef(fit))
  expect_equal(
    predict(fit, type = "normalized"),
    hydrotime_data$GermWP - p$theta_h / hydrotime_data$CumTime
  )
  tt <- fit_thermal_time(thermal_time_data)
  expect_equal(
    predict(tt, type = "normalized"),
    (thermal_time_data$GermTemp - coef(tt)[["t_b"]]) * thermal_time_data$CumTime
  )
  rate <- suppressWarnings(fit_hydropriming(hydropriming_data))
  expect_error(predict(rate, type = "normalized"), "single-population")
  expect_length(predict(rate), nrow(rate$data))
})

test_that("print and summary describe the fit", {
  expect_output(print(fit), "Hydrotime model")
  expect_output(print(fit), "pseudo-R2")
  s <- summary(fit)
  expect_s3_class(s, "summary.pbtm_fit")
  expect_equal(rownames(s$coefficients), names(coef(fit)))
  expect_true(all(s$coefficients$std_error > 0))
  expect_output(print(s), "Coefficients")

  fixed <- fit_thermal_time(thermal_time_data, fixed = list(t_b = 5))
  expect_output(print(fixed), "held fixed")
  expect_true(is.na(summary(fixed)$coefficients["t_b", "std_error"]))
})

test_that("mixture fits print their components", {
  skip_on_cran()
  mix <- suppressWarnings(fit_thermal_time(thermal_time_subpop_data, subpops = 2))
  expect_output(print(mix), "2 subpopulations")
  expect_equal(nrow(summary(mix)$components), 2)
})

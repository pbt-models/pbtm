cdf_fits <- suppressWarnings(list(
  thermal_time = fit_thermal_time(thermal_time_data),
  hydrotime = fit_hydrotime(hydrotime_data),
  hydrothermal_time = fit_hydrothermal_time(hydrothermal_time_data),
  aging = fit_aging(aging_data),
  promoter = fit_promoter(promoter_data, dose_transform = "log10"),
  inhibitor = fit_inhibitor(inhibitor_data),
  max_frac = fit_thermal_time(thermal_time_data, max_frac = 0.9)
))

test_that("cumulative model plots build on every scale", {
  for (nm in names(cdf_fits)) {
    f <- cdf_fits[[nm]]
    expect_true(builds(autoplot(f)), info = nm)
    expect_true(builds(suppressMessages(autoplot(f, x_scale = "log", y_scale = "probit"))), info = nm)
    expect_true(builds(suppressMessages(autoplot(f, y_scale = "logit"))), info = nm)
    expect_true(builds(suppressMessages(autoplot(f, type = "normalized"))), info = nm)
    expect_true(builds(suppressMessages(autoplot(f, type = "normalized", y_scale = "linear"))), info = nm)
  }
})

test_that("normalized plots use the model's axis", {
  fit <- cdf_fits$thermal_time
  p <- suppressMessages(autoplot(fit, type = "normalized"))
  expect_true(all(p$data$x %in% predict(fit, type = "normalized")))
  expect_match(p$scales$get_scales("x")$name, "Thermal time")
})

test_that("rate model plots build on linear and log-log scales", {
  for (f in suppressWarnings(list(
    fit_hydropriming(hydropriming_data),
    fit_hydrothermal_priming(hydrothermal_priming_data)
  ))) {
    expect_true(builds(autoplot(f)))
    expect_true(builds(suppressMessages(autoplot(f, x_scale = "log", y_scale = "log"))))
    expect_error(autoplot(f, y_scale = "probit"), "must be one of")
    expect_error(autoplot(f, type = "normalized"), "single-population")
  }
})

test_that("mixture plots build but have no normalized view", {
  skip_on_cran()
  mix <- suppressWarnings(fit_thermal_time(thermal_time_subpop_data, subpops = 2))
  expect_true(builds(autoplot(mix)))
  expect_true(builds(suppressMessages(autoplot(mix, x_scale = "log", y_scale = "probit"))))
  expect_error(autoplot(mix, type = "normalized"), "single-population")
})

test_that("points that cannot be drawn on transformed axes are dropped with a message", {
  expect_message(autoplot(cdf_fits$aging, y_scale = "probit"), "Dropped")
  expect_no_message(autoplot(cdf_fits$aging))
})

test_that("show_params controls the subtitle", {
  expect_match(ggplot2::get_labs(autoplot(cdf_fits$hydrotime))$subtitle, "psi_b50")
  expect_null(ggplot2::get_labs(autoplot(cdf_fits$hydrotime, show_params = FALSE))$subtitle)
})

test_that("plot_germ_data plots raw time courses", {
  expect_true(builds(plot_germ_data(germination_data, color = "GermTemp")))
  expect_true(builds(suppressMessages(
    plot_germ_data(hydrothermal_time_data, color = "GermWP", shape = "GermTemp", x_scale = "log", y_scale = "probit")
  )))
  expect_error(plot_germ_data(germination_data, color = "nope"), "nope")
})

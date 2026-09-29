# Regression tests: fits on the example datasets must reproduce the estimates of
# the PBTM app (pbtm-app, `update` branch, September 2026) that this package
# was ported from. The app rounded coefficients to 6 decimal places, so the
# comparison allows for that rounding (which matters for the small priming
# `slope` estimates).

app_reference <- list(
  thermal_time = c(t_b = 3.648228, theta_t50 = 1419.264922, sigma = 0.067337, pseudo_r2 = 0.9902548074),
  hydrotime = c(theta_h = 117.243681, psi_b50 = -1.371868, sigma = 0.156485, pseudo_r2 = 0.9649416865),
  hydrothermal_time = c(theta_ht = 1455.850763, t_b = 5.394833, psi_b50 = -1.162292, sigma = 0.145843, pseudo_r2 = 0.9060264209),
  aging = c(theta_a = 272.401441, p_max50 = 14.243018, sigma = 2.994916, pseudo_r2 = 0.9763723718),
  promoter_log = c(theta_p = 176.206454, p_b50 = 0.666048, sigma = 0.527951, pseudo_r2 = 0.9525838842),
  inhibitor = c(theta_i = 327.898365, i_b50 = 3.088653, sigma = 1.850583, pseudo_r2 = 0.7607600918),
  inhibitor_log = c(theta_i = 181.417796, i_b50 = 0.86046, sigma = 0.546388, pseudo_r2 = 0.9390108425),
  hydropriming = c(psi_min = -1.436749, gr_i = 0.010868, slope = 0.000232, pseudo_r2 = 0.9543560443),
  hydrothermal_priming = c(t_min = 9.362111, psi_min = -1.462899, gr_i = 0.009856, slope = 4.2e-05, pseudo_r2 = 0.9561153337)
)

expect_matches_reference <- function(fit, ref) {
  params <- ref[names(ref) != "pseudo_r2"]
  est <- coef(fit)[names(params)]
  # within the app's 6-decimal rounding, or 1e-5 relative
  tol <- pmax(1e-6, 1e-5 * abs(params))
  expect_true(all(abs(est - params) <= tol), info = paste(names(params), signif(est, 8), collapse = "; "))
  expect_equal(fit$stats$pseudo_r2, ref[["pseudo_r2"]], tolerance = 1e-5)
}

test_that("cumulative models reproduce the app's estimates", {
  expect_matches_reference(quiet_fit(thermal_time_data, "thermal_time"), app_reference$thermal_time)
  expect_matches_reference(quiet_fit(hydrotime_data, "hydrotime"), app_reference$hydrotime)
  expect_matches_reference(quiet_fit(hydrothermal_time_data, "hydrothermal_time"), app_reference$hydrothermal_time)
  expect_matches_reference(quiet_fit(aging_data, "aging"), app_reference$aging)
  expect_matches_reference(quiet_fit(inhibitor_data, "inhibitor"), app_reference$inhibitor)
})

test_that("dose-transformed models reproduce the app's estimates", {
  expect_matches_reference(
    quiet_fit(promoter_data, "promoter", dose_transform = "log10"),
    app_reference$promoter_log
  )
  expect_matches_reference(
    quiet_fit(inhibitor_data, "inhibitor", dose_transform = "log10"),
    app_reference$inhibitor_log
  )
})

test_that("rate models reproduce the app's estimates", {
  expect_matches_reference(quiet_fit(hydropriming_data, "hydropriming"), app_reference$hydropriming)
  expect_matches_reference(
    quiet_fit(hydrothermal_priming_data, "hydrothermal_priming"),
    app_reference$hydrothermal_priming
  )
})

test_that("germination speeds reproduce the app's table", {
  gs <- germ_speed(germination_data, c(0.1, 0.5, 0.9))
  expect_equal(gs$TrtID, rep(c(1, 4, 7), each = 3))
  expect_equal(
    gs$Time,
    c(102.6, 126.3333333, 151.1, 73.3, 87.75, 101.85, 50.93096236, 67.55988593, 80.89330544),
    tolerance = 1e-8
  )
})

test_that("auto subpopulation detection reproduces the app's comparison", {
  skip_on_cran()
  fit <- quiet_fit(thermal_time_subpop_data, "thermal_time", subpops = "auto")
  expect_equal(fit$k, 2L)
  tbl <- fit$subpop_table
  expect_equal(tbl$k[1:2], 1:2)
  expect_equal(unname(tbl$aic[1]), -715.8460487, tolerance = 1e-5)
  expect_equal(unname(tbl$aic[2]), -820.1811501, tolerance = 1e-4)
})

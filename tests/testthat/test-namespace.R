# testthat attaches pbtm, which hides bugs that only appear when the package is
# used via `pbtm::` without library(pbtm) -- the way the PBTM app uses it. For
# example, lazy-loaded datasets are not visible from inside the namespace, so
# internal code must reach them with `pbtm::`. Run the main entry points in a
# fresh R session that only loads the namespace.

test_that("the main functions work without attaching pbtm", {
  skip_on_cran()
  skip_if_not_installed("callr")
  # the child session loads the *installed* pbtm, which is only guaranteed to
  # be the code under test during R CMD check (and so in CI)
  skip_if_not(testthat::is_checking(), "only meaningful under R CMD check")
  out <- callr::r(function() {
    fit <- pbtm::fit_pbtm(pbtm::thermal_time_data, "thermal_time")
    speeds <- pbtm::germ_speed(pbtm::germination_data, 0.5)
    pbtm::validate_germ_data(pbtm::hydrotime_data, "hydrotime")
    rate <- pbtm::fit_hydropriming(pbtm::hydropriming_data)
    list(
      attached = "package:pbtm" %in% search(),
      coef = stats::coef(fit),
      n_speeds = nrow(speeds),
      rate_class = class(rate)
    )
  })
  expect_false(out$attached)
  expect_named(out$coef, c("t_b", "theta_t50", "sigma"))
  expect_equal(out$n_speeds, 3)
  expect_equal(out$rate_class, "pbtm_fit")
})

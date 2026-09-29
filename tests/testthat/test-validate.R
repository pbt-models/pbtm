test_that("every example dataset passes validation for its model", {
  expect_silent(validate_germ_data(germination_data))
  expect_silent(validate_germ_data(thermal_time_data, "thermal_time"))
  expect_silent(validate_germ_data(thermal_time_subpop_data, "thermal_time"))
  expect_silent(validate_germ_data(hydrotime_data, "hydrotime"))
  expect_silent(validate_germ_data(hydrothermal_time_data, "hydrothermal_time"))
  expect_silent(validate_germ_data(hydropriming_data, "hydropriming"))
  expect_silent(validate_germ_data(hydrothermal_priming_data, "hydrothermal_priming"))
  expect_silent(validate_germ_data(aging_data, "aging"))
  expect_silent(validate_germ_data(promoter_data, "promoter"))
  expect_silent(validate_germ_data(inhibitor_data, "inhibitor"))
})

test_that("validation reports every problem", {
  bad <- hydrotime_data
  bad$CumFraction <- bad$CumFraction * 100
  bad$GermWP <- -bad$GermWP
  err <- expect_error(validate_germ_data(bad), "failed validation")
  expect_match(conditionMessage(err), "CumFraction")
  expect_match(conditionMessage(err), "GermWP")

  bad <- thermal_time_data
  bad$GermTemp <- as.character(bad$GermTemp)
  expect_error(validate_germ_data(bad), "numeric")
  expect_error(validate_germ_data(thermal_time_data, "hydrotime"), "GermWP")
})

test_that("validation applies the column mapping", {
  renamed <- dplyr::rename(thermal_time_data, temp = GermTemp)
  out <- validate_germ_data(renamed, "thermal_time", cols = c(GermTemp = "temp"))
  expect_true("GermTemp" %in% names(out))
})

test_that("pbtm_columns flags each model's required columns", {
  req <- pbtm_columns$Column[pbtm_columns$hydrothermal_time]
  expect_setequal(req, c("TrtID", "GermTemp", "GermWP", "CumTime", "CumFraction"))
})

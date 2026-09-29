curve <- data.frame(
  TrtID = 1,
  CumTime = c(10, 20, 30, 40),
  CumFraction = c(0.2, 0.4, 0.8, 0.8)
)

test_that("germ_speed interpolates times and rates", {
  gs <- germ_speed(curve, c(0.3, 0.6))
  expect_named(gs, c("TrtID", "Fraction", "Time", "GR"))
  expect_equal(gs$Time, c(15, 25))
  expect_equal(gs$GR, 1 / c(15, 25))
  # fractions are sorted and de-duplicated
  expect_equal(germ_speed(curve, c(0.6, 0.3, 0.6))$Fraction, c(0.3, 0.6))
})

test_that("germ_speed extrapolation is controllable", {
  # rule = 2: the last observation's time is returned
  expect_equal(germ_speed(curve, 0.9)$Time, 40)
  expect_equal(nrow(germ_speed(curve, 0.9, extrapolate = FALSE)), 0)
  expect_equal(germ_speed(curve, c(0.5, 0.9), extrapolate = FALSE)$Fraction, 0.5)
})

test_that("germ_speed pools treatments within groups", {
  gs <- germ_speed(germination_data, 0.5, groups = "GermTemp")
  expect_equal(nrow(gs), 3)
  expect_equal(gs$GermTemp, c(15, 20, 25))
  expect_error(germ_speed(curve, 1.5), "fractions")
  expect_error(germ_speed(curve[, -1]), "TrtID")
})

test_that("rescale_cum_frac pools curves up to the group maximum", {
  two <- data.frame(
    TrtID = c(1, 1, 2, 2),
    Trt = "a",
    CumTime = c(10, 20, 10, 20),
    CumFraction = c(0.2, 0.4, 0.4, 0.8)
  )
  pooled <- rescale_cum_frac(two, "Trt")
  expect_equal(pooled$CumTime, c(10, 20))
  # increments 0.6 then 0.6 of 1.2 total, scaled to the maximum of 0.8
  expect_equal(pooled$CumFraction, c(0.4, 0.8))
  # a single curve is unchanged
  expect_equal(rescale_cum_frac(curve, "TrtID")$CumFraction, curve$CumFraction)
})

test_that("clean_germ_data drops repeated fractions", {
  cleaned <- clean_germ_data(curve)
  expect_equal(cleaned$CumTime, c(10, 20, 30))
  expect_equal(nrow(clean_germ_data(promoter_data)), 47)
})

test_that("calc_cum_frac converts counts", {
  counts <- data.frame(TrtID = 1, CumTime = 1:3, nGerminated = c(5, 25, 50), nTotal = 50)
  expect_equal(calc_cum_frac(counts)$CumFraction, c(0.1, 0.5, 1))
  counts$nGerminated[3] <- 60
  expect_warning(calc_cum_frac(counts), "outside 0-1")
  expect_error(calc_cum_frac(counts, n_total = "total"), "total")
})

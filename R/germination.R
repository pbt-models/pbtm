#' Germination speed and rate
#'
#' Interpolates the time for each group of germination curves to reach one or
#' more germination fractions (e.g. T50, the time to 50% germination) and the
#' corresponding germination rate (GR = 1 / time).
#'
#' When `groups` pools several treatments (curves identified by `TrtID`), the
#' curves are first combined with [rescale_cum_frac()], so the result describes
#' the pooled population.
#'
#' @param data A data frame with `TrtID`, `CumTime`, and `CumFraction` columns
#'   and any columns named in `groups`.
#' @param fractions Germination fractions (0-1) to interpolate, e.g.
#'   `c(0.1, 0.5, 0.9)`.
#' @param groups Columns defining the groups to summarize. Defaults to each
#'   treatment (`TrtID`).
#' @param extrapolate What to return for a fraction that a group never reaches
#'   (or that falls before its first observation). If `TRUE`, the time of the
#'   closest observation is returned (the behavior of earlier versions of pbtm
#'   and the PBTM app); if `FALSE`, `NA`.
#' @return A tibble with the `groups` columns plus `Fraction`, `Time`, and `GR`,
#'   one row per group and fraction.
#' @family germination data helpers
#' @export
#' @examples
#' germ_speed(germination_data, fractions = c(0.1, 0.5, 0.9))
#'
#' # pooled across treatments at each temperature
#' germ_speed(germination_data, 0.5, groups = "GermTemp")
germ_speed <- function(data, fractions = 0.5, groups = "TrtID", extrapolate = TRUE) {
  check_data_frame(data)
  check_fraction(fractions, "fractions")
  check_columns(data, unique(c("TrtID", groups, "CumTime", "CumFraction")), "germination speed")
  fractions <- sort(unique(fractions))

  rescale_cum_frac(data, groups) |>
    dplyr::group_by(dplyr::across(dplyr::all_of(groups))) |>
    dplyr::arrange(.data$CumTime, .by_group = TRUE) |>
    dplyr::reframe({
      interp <- stats::approx(
        .data$CumFraction,
        .data$CumTime,
        xout = fractions,
        ties = "ordered",
        rule = if (extrapolate) 2 else 1
      )
      tibble::tibble(Fraction = interp$x, Time = interp$y)
    }) |>
    dplyr::filter(extrapolate | !is.na(.data$Time)) |>
    dplyr::mutate(GR = 1 / .data$Time)
}

#' Pool germination curves across treatments
#'
#' Recomputes cumulative germination fractions after pooling treatments: the
#' germination increments of every curve (identified by `TrtID`) in a group are
#' summed at each observation time and re-accumulated. The pooled curve is
#' scaled to reach the highest final fraction observed in the group.
#'
#' @param data A data frame with `TrtID`, `CumTime`, and `CumFraction` columns
#'   and any columns named in `groups`.
#' @param groups Columns to keep; curves sharing the same values of these
#'   columns are pooled. Use `character()` to pool everything.
#' @return A tibble with the `groups` columns, `CumTime`, and the pooled
#'   `CumFraction`.
#' @family germination data helpers
#' @export
#' @examples
#' # pool the replicate treatments at each temperature
#' rescale_cum_frac(germination_data, groups = "GermTemp")
rescale_cum_frac <- function(data, groups) {
  check_data_frame(data)
  check_columns(data, unique(c("TrtID", groups, "CumTime", "CumFraction")), "pooling curves")
  curve <- union("TrtID", groups)

  data |>
    dplyr::arrange(dplyr::across(dplyr::all_of(curve)), .data$CumTime, .data$CumFraction) |>
    dplyr::mutate(
      FracDiff = .data$CumFraction - dplyr::lag(.data$CumFraction, default = 0),
      .by = dplyr::all_of(curve)
    ) |>
    dplyr::mutate(MaxCumFrac = max(.data$CumFraction), .by = dplyr::all_of(groups)) |>
    dplyr::summarise(
      MaxCumFrac = max(.data$MaxCumFrac),
      FracDiff = sum(.data$FracDiff),
      .by = dplyr::all_of(c(groups, "CumTime"))
    ) |>
    dplyr::arrange(dplyr::across(dplyr::all_of(groups)), .data$CumTime) |>
    dplyr::mutate(
      CumFraction = cumsum(.data$FracDiff) / sum(.data$FracDiff) * .data$MaxCumFrac,
      .by = dplyr::all_of(groups)
    ) |>
    dplyr::select(-"FracDiff", -"MaxCumFrac") |>
    tibble::as_tibble()
}

#' Remove repeated cumulative fractions
#'
#' Keeps only the first observation of each cumulative fraction within a
#' germination curve, dropping later points where germination did not increase.
#' This is the "cleaned" data option of the PBTM app.
#'
#' @param data A data frame with `CumTime` and `CumFraction` columns.
#' @param groups Columns identifying each germination curve.
#' @return `data` without the repeated observations.
#' @family germination data helpers
#' @export
#' @examples
#' nrow(thermal_time_data)
#' nrow(clean_germ_data(thermal_time_data))
clean_germ_data <- function(data, groups = "TrtID") {
  check_data_frame(data)
  check_columns(data, c(groups, "CumTime", "CumFraction"), "cleaning")
  data |>
    dplyr::arrange(dplyr::across(dplyr::all_of(groups)), .data$CumTime) |>
    dplyr::distinct(dplyr::across(dplyr::all_of(c(groups, "CumFraction"))), .keep_all = TRUE)
}

#' Cumulative germination fractions from seed counts
#'
#' Converts cumulative counts of germinated seeds into the `CumFraction` column
#' used throughout pbtm.
#'
#' @param data A data frame of germination observations.
#' @param n_germinated Column with the cumulative number of germinated seeds.
#' @param n_total Column with the total number of seeds in the treatment.
#' @return `data` with a `CumFraction` column added.
#' @family germination data helpers
#' @export
#' @examples
#' counts <- data.frame(
#'   TrtID = 1, CumTime = c(24, 48, 72),
#'   nGerminated = c(5, 30, 45), nTotal = 50
#' )
#' calc_cum_frac(counts)
calc_cum_frac <- function(data, n_germinated = "nGerminated", n_total = "nTotal") {
  check_data_frame(data)
  check_columns(data, c(n_germinated, n_total), "cumulative fractions")
  data$CumFraction <- data[[n_germinated]] / data[[n_total]]
  if (any(data$CumFraction > 1 | data$CumFraction < 0, na.rm = TRUE)) {
    cli::cli_warn("Some cumulative fractions are outside 0-1; check {.field {n_germinated}} and {.field {n_total}}.")
  }
  data
}

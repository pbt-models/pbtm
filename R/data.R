#' Example germination datasets
#'
#' Germination time courses used in the examples and vignettes, one for each
#' model. Every dataset follows the PBTM template (see [pbtm_columns]): each row
#' is one observation of a germination curve, with the treatment id (`TrtID`)
#' and description (`TrtDesc`), the treatment conditions, the cumulative time
#' (`CumTime`, hours), and the cumulative fraction germinated (`CumFraction`,
#' 0-1).
#'
#' * `germination_data`: tomato seeds germinated in water at 15, 20 and 25 °C
#'   (`GermTemp`); for germination speed calculations.
#' * `thermal_time_data`: tomato seeds germinated in water at 15, 20 and 25 °C
#'   (`GermTemp`); for [fit_thermal_time()].
#' * `thermal_time_subpop_data`: germination at 15, 17.5, 20 and 22.5 °C
#'   (`GermTemp`) of a seed lot combining two subpopulations; for
#'   [fit_thermal_time()] with `subpops`.
#' * `hydrotime_data`: tomato seeds germinated at 20 °C at 0, -0.25 and -0.4 MPa
#'   (`GermWP`); for [fit_hydrotime()].
#' * `hydrothermal_time_data`: tomato seeds germinated at 15, 20 and 25 °C
#'   (`GermTemp`) crossed with 0, -0.25 and -0.4 MPa (`GermWP`); for
#'   [fit_hydrothermal_time()].
#' * `hydropriming_data`: germination after priming at 0 to -1.42 MPa
#'   (`PrimingWP`) for 0 to 148 hours (`PrimingDuration`), including unprimed
#'   controls; for [fit_hydropriming()].
#' * `hydrothermal_priming_data`: germination after priming at -0.51 to -1.42 MPa
#'   (`PrimingWP`) and 10 to 15 °C (`PrimingTemp`) for 24 to 148 hours
#'   (`PrimingDuration`); for [fit_hydrothermal_priming()].
#' * `aging_data`: lettuce seeds after 0, 2, 4 and 6 days of accelerated aging
#'   (`AgingTime`); for [fit_aging()].
#' * `promoter_data`: tomato seeds germinated with 1, 10 and 100 units of
#'   gibberellin (`GermPromoterDosage`); for [fit_promoter()].
#' * `inhibitor_data`: tomato seeds germinated with 0.08 to 10 units of abscisic
#'   acid (`GermInhibitorDosage`); for [fit_inhibitor()].
#'
#' @format Tibbles with columns `TrtID`, `TrtDesc`, the treatment columns listed
#'   above, `CumTime`, and `CumFraction`.
#' @source Sample datasets of the PBTM app, <https://github.com/pbt-models/pbtm-app>.
#' @name pbtm_datasets
#' @examples
#' head(thermal_time_data)
#' plot_germ_data(thermal_time_data, color = "GermTemp")
"germination_data"

#' @rdname pbtm_datasets
"thermal_time_data"

#' @rdname pbtm_datasets
"thermal_time_subpop_data"

#' @rdname pbtm_datasets
"hydrotime_data"

#' @rdname pbtm_datasets
"hydrothermal_time_data"

#' @rdname pbtm_datasets
"hydropriming_data"

#' @rdname pbtm_datasets
"hydrothermal_priming_data"

#' @rdname pbtm_datasets
"aging_data"

#' @rdname pbtm_datasets
"promoter_data"

#' @rdname pbtm_datasets
"inhibitor_data"

#' PBTM data template columns
#'
#' The columns recognized by pbtm, with their meaning, expected type and valid
#' range, and which models require them. Data can use other column names if
#' they are mapped with the `cols` argument of [fit_pbtm()].
#'
#' @format A tibble with one row per template column:
#' \describe{
#'   \item{Column}{Column name.}
#'   \item{Role}{`"Factor"` (treatment) or `"Response"`.}
#'   \item{Description, LongDescription, TypeDescription}{Human-readable
#'     descriptions.}
#'   \item{Type}{`"numeric"` for numeric columns, `NA` otherwise.}
#'   \item{Min, Max}{Valid range, checked by [validate_germ_data()].}
#'   \item{germination, thermal_time, ..., inhibitor}{Whether each model
#'     requires the column.}
#' }
#' @family germination data helpers
#' @examples
#' pbtm_columns[, c("Column", "Description", "Min", "Max")]
"pbtm_columns"

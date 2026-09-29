#' Check germination data against the PBTM template
#'
#' Checks that the columns used by pbtm are present, numeric, and within the
#' ranges listed in [pbtm_columns] (for example, `CumFraction` must be between
#' 0 and 1 and water potentials must not be positive). Columns that are not
#' part of the template are ignored.
#'
#' @param data A data frame of germination data.
#' @param model Optional model id from [pbtm_models()]. If supplied, the columns
#'   that model requires must be present.
#' @param cols Optional named character vector mapping template column names to
#'   the names used in `data` (see [fit_pbtm()]).
#' @return `data` (renamed with `cols`), invisibly. Throws an error listing all
#'   problems found.
#' @family germination data helpers
#' @export
#' @examples
#' validate_germ_data(thermal_time_data, "thermal_time")
#'
#' bad <- thermal_time_data
#' bad$CumFraction <- bad$CumFraction * 100
#' try(validate_germ_data(bad))
validate_germ_data <- function(data, model = NULL, cols = NULL) {
  data <- rename_cols(data, cols)
  check_data_frame(data)
  if (!is.null(model)) {
    m <- get_model(model)
    needed <- c(m$factors, "CumTime", "CumFraction")
    if (m$family == "rate") needed <- c("TrtID", needed)
    check_columns(data, needed, m$label)
  }

  spec <- pbtm_columns[pbtm_columns$Type %in% "numeric", ]
  problems <- character()
  for (i in seq_len(nrow(spec))) {
    col <- spec$Column[i]
    if (!col %in% names(data)) next
    x <- data[[col]]
    if (!is.numeric(x)) {
      problems <- c(problems, sprintf("`%s` must be numeric.", col))
      next
    }
    lo <- spec$Min[i]
    hi <- spec$Max[i]
    if (!is.na(lo) && any(x < lo, na.rm = TRUE)) {
      problems <- c(problems, sprintf("`%s` has values below %s.", col, lo))
    }
    if (!is.na(hi) && any(x > hi, na.rm = TRUE)) {
      problems <- c(problems, sprintf("`%s` has values above %s.", col, hi))
    }
  }
  if (length(problems) > 0) {
    cli::cli_abort(c(
      "Germination data failed validation.",
      rlang::set_names(problems, rep("x", length(problems)))
    ))
  }
  invisible(data)
}


# Internal argument checks -----------------------------------------------------

check_data_frame <- function(data, call = rlang::caller_env()) {
  if (!is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a data frame, not {.obj_type_friendly {data}}.", call = call)
  }
}

check_columns <- function(data, needed, what, call = rlang::caller_env()) {
  missing <- setdiff(needed, names(data))
  if (length(missing) > 0) {
    example <- sprintf("cols = c(%s = \"my_column\")", missing[1])
    cli::cli_abort(
      c(
        "{.arg data} is missing {cli::qty(length(missing))}column{?s} {.field {missing}}, required for {what}.",
        i = "Use {.arg cols} to map differently named columns, e.g. {.code {example}}."
      ),
      call = call
    )
  }
  for (col in intersect(needed, c("CumTime", "CumFraction", "GR", pbtm_columns$Column[pbtm_columns$Type %in% "numeric"]))) {
    if (!is.numeric(data[[col]])) {
      cli::cli_abort("Column {.field {col}} must be numeric.", call = call)
    }
  }
}

check_fraction <- function(x, arg, allow_zero = TRUE, call = rlang::caller_env()) {
  ok <- is.numeric(x) && length(x) > 0 && !anyNA(x) && all(x <= 1) &&
    (if (allow_zero) all(x >= 0) else all(x > 0))
  if (!ok) {
    range <- if (allow_zero) "between 0 and 1" else "greater than 0 and at most 1"
    cli::cli_abort("{.arg {arg}} must be {range}.", call = call)
  }
}

#' @noRd
#' @description rename user columns onto template names: cols = c(Template = "user")
rename_cols <- function(data, cols, call = rlang::caller_env()) {
  if (is.null(cols)) {
    return(data)
  }
  check_data_frame(data, call = call)
  if (!is.character(cols) || is.null(names(cols)) || any(names(cols) == "")) {
    cli::cli_abort(
      "{.arg cols} must be a named character vector like {.code c(GermTemp = \"temp\")}.",
      call = call
    )
  }
  missing <- setdiff(cols, names(data))
  if (length(missing) > 0) {
    cli::cli_abort("{cli::qty(length(missing))}Column{?s} {.field {missing}} named in {.arg cols} {?is/are} not in {.arg data}.", call = call)
  }
  dplyr::rename(data, dplyr::all_of(cols))
}

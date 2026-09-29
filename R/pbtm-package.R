#' @keywords internal
"_PACKAGE"

#' @importFrom rlang .data %||%
#' @importFrom ggplot2 autoplot
#' @importFrom stats coef fitted nobs predict residuals
NULL

#' @export
ggplot2::autoplot

# lazy-loaded package data used inside functions
#' @importFrom utils globalVariables
NULL
globalVariables("pbtm_columns")

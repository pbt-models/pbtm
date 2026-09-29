#' Methods for fitted PBTM models
#'
#' Standard methods for `pbtm_fit` objects returned by [fit_pbtm()] and the
#' per-model fitting functions.
#'
#' @param object,x A `pbtm_fit` object.
#' @param newdata Optional data frame with the model's treatment columns (and
#'   `CumTime` for cumulative models) at which to predict. Defaults to the data
#'   used for fitting.
#' @param type For `predict()`: `"response"` returns the predicted cumulative
#'   fraction (or germination rate for rate models); `"normalized"` returns each
#'   observation's position on the model's normalized axis (e.g. thermal time,
#'   or base water potential for hydrotime), which is the x axis of
#'   `autoplot(type = "normalized")`. Single-population cumulative models only.
#' @param digits Number of significant digits to print.
#' @param ... Unused.
#' @return `coef()`, `fitted()`, `residuals()` and `predict()` return numeric
#'   vectors; `summary()` returns a `summary.pbtm_fit` object with a
#'   `coefficients` table (estimates, and standard errors where they can be
#'   computed) and fit statistics.
#' @name pbtm_fit-methods
#' @examples
#' fit <- fit_hydrotime(hydrotime_data)
#' coef(fit)
#' summary(fit)
#' head(predict(fit, type = "normalized"))
#' predict(fit, newdata = data.frame(GermWP = -0.5, CumTime = c(50, 100, 200)))
NULL

#' @rdname pbtm_fit-methods
#' @export
print.pbtm_fit <- function(x, digits = 4, ...) {
  cat(sprintf("<pbtm_fit> %s model", x$label))
  if (x$k > 1) cat(sprintf(" with %d subpopulations", x$k))
  cat("\n\n")
  if (x$k > 1) {
    print(as.data.frame(x$components), digits = digits, row.names = FALSE)
  } else {
    coefs <- vapply(x$coefficients, format_num, "", digits = digits)
    names(coefs) <- ifelse(names(coefs) %in% x$fixed, paste0(names(coefs), "*"), names(coefs))
    print(noquote(coefs), right = TRUE)
  }
  if (length(x$fixed) > 0) cat("(* held fixed)\n")
  notes <- c(
    if (x$max_frac < 1) sprintf("max_frac = %s", x$max_frac),
    if (x$dose_transform != "none") sprintf("dose transform = %s", x$dose_transform),
    if (!is.null(x$speed)) sprintf("rates at %s%% germination", x$speed * 100)
  )
  cat(sprintf(
    "\nn = %d, pseudo-R2 = %s, AIC = %s%s\n",
    x$stats$n,
    signif(x$stats$pseudo_r2, digits),
    signif(x$stats$aic, digits),
    if (length(notes)) paste0("; ", paste(notes, collapse = "; ")) else ""
  ))
  if (!isTRUE(x$converged)) cat("Warning: the fit did not fully converge.\n")
  invisible(x)
}

#' @rdname pbtm_fit-methods
#' @export
summary.pbtm_fit <- function(object, ...) {
  est <- object$coefficients
  se <- rep(NA_real_, length(est))
  names(se) <- names(est)
  sm <- tryCatch(summary(object$nls)$coefficients, error = function(e) NULL)
  if (!is.null(sm)) {
    free <- setdiff(intersect(rownames(sm), names(est)), object$fixed)
    se[free] <- sm[free, "Std. Error"]
  }
  tbl <- data.frame(
    estimate = unname(est),
    std_error = unname(se),
    fixed = names(est) %in% object$fixed,
    row.names = names(est)
  )
  structure(
    list(
      label = object$label,
      k = object$k,
      coefficients = tbl,
      components = object$components,
      stats = object$stats,
      converged = object$converged,
      at_bound = object$at_bound,
      subpop_table = object$subpop_table
    ),
    class = "summary.pbtm_fit"
  )
}

#' @rdname pbtm_fit-methods
#' @export
print.summary.pbtm_fit <- function(x, digits = 4, ...) {
  cat(sprintf("%s model", x$label))
  if (x$k > 1) cat(sprintf(" (%d subpopulations)", x$k))
  cat("\n\nCoefficients:\n")
  print(x$coefficients, digits = digits)
  if (x$k > 1) {
    cat("\nSubpopulations:\n")
    print(as.data.frame(x$components), digits = digits, row.names = FALSE)
  }
  if (!is.null(x$subpop_table)) {
    cat("\nSubpopulation comparison:\n")
    print(as.data.frame(x$subpop_table), digits = digits, row.names = FALSE)
  }
  s <- x$stats
  cat(sprintf(
    "\nn = %d, parameters = %d, RSS = %s, AIC = %s, pseudo-R2 = %s\n",
    s$n, s$npar, signif(s$rss, digits), signif(s$aic, digits), signif(s$pseudo_r2, digits)
  ))
  if (length(x$at_bound) > 0) {
    cat("At a bound:", paste(x$at_bound, collapse = ", "), "\n")
  }
  if (!isTRUE(x$converged)) cat("Warning: the fit did not fully converge.\n")
  invisible(x)
}

#' @rdname pbtm_fit-methods
#' @export
coef.pbtm_fit <- function(object, ...) {
  object$coefficients
}

#' @rdname pbtm_fit-methods
#' @export
fitted.pbtm_fit <- function(object, ...) {
  object$fitted
}

#' @rdname pbtm_fit-methods
#' @export
residuals.pbtm_fit <- function(object, ...) {
  object$data[[object$response]] - object$fitted
}

#' @rdname pbtm_fit-methods
#' @export
nobs.pbtm_fit <- function(object, ...) {
  object$stats$n
}

#' @rdname pbtm_fit-methods
#' @export
predict.pbtm_fit <- function(object, newdata = NULL, type = c("response", "normalized"), ...) {
  type <- rlang::arg_match(type)
  m <- get_model(object$model)
  data <- newdata %||% object$data
  needed <- if (m$family == "cdf") c(m$factors, "CumTime") else m$factors
  check_columns(data, needed, "prediction")
  transform <- fit_transform(object)

  if (type == "normalized") {
    if (m$family != "cdf" || object$k > 1) {
      cli::cli_abort("{.code type = \"normalized\"} is only available for single-population cumulative models.")
    }
    return(normalized_x(m, data, as.list(object$coefficients), transform))
  }
  if (m$family == "rate") {
    return(m$predict(data, as.list(object$coefficients)))
  }
  mixture_predict(m, data, object$coefficients, object$k, object$max_frac, transform)
}

#' @noRd
#' @description format one number on its own scale, so that parameters of very
#'   different magnitudes print readably side by side
format_num <- function(x, digits = 4) {
  sci <- x != 0 && (abs(x) >= 1e6 || abs(x) < 1e-4)
  format(signif(x, digits), scientific = sci, drop0trailing = TRUE)
}

fit_transform <- function(fit) {
  if (identical(fit$dose_transform, "log10")) log10 else identity
}

#' @noRd
#' @description position on the model's normalized axis
normalized_x <- function(m, data, p, transform) {
  f <- m$normalized$x %||% m$threshold
  f(data, p, transform)
}

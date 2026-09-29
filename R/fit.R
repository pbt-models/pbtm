#' Fit a population-based threshold model
#'
#' `fit_pbtm()` is the general interface for fitting any of the models listed
#' by [pbtm_models()] with nonlinear least squares ([stats::nls()] with the
#' `"port"` algorithm, so every parameter is bounded). Each model also has a
#' convenience wrapper, e.g. [fit_thermal_time()] or [fit_hydrotime()], that
#' documents its equation and parameters.
#'
#' @section Data:
#' Data should follow the column naming of the PBTM template (see
#' [pbtm_columns]): one row per observation, with the cumulative time
#' (`CumTime`), the cumulative germinated fraction (`CumFraction`, 0-1), and the
#' treatment columns required by the model (e.g. `GermTemp` for thermal time).
#' Use `cols` to map differently named columns onto the template names.
#'
#' Rate models (hydropriming and hydrothermal priming) are fit to germination
#' rates. Pass the raw time-course data (which also needs a `TrtID` column) and
#' the rates are computed with [germ_speed()] at the fraction given by `speed`;
#' alternatively, pass a data frame that already has a `GR` column.
#'
#' @section Subpopulations:
#' For cumulative (`"cdf"`) models, `subpops > 1` fits a mixture of distinct
#' seed subpopulations, each with its own copy of the model parameters, combined
#' with mixing weights that sum to one. Parameters of subpopulation `j` get the
#' suffix `j` (e.g. `t_b1`, `t_b2`) and the free mixing fractions are named
#' `w1`, `w2`, ... (stick-breaking: `w1` is the first subpopulation's share,
#' `w2` the second's share of what remains, and so on). The mixture is fit from
#' several perturbed starting values (`restarts`) and the best fit by AIC is
#' kept. `subpops = "auto"` fits 1 to `max_subpops` subpopulations and keeps
#' the one with the lowest AIC. Mixture fits are often *equifinal* (different
#' parameter sets fit almost equally well), so treat the component estimates
#' with caution; see `vignette("subpopulations", package = "pbtm")`.
#'
#' @param data A data frame of germination time courses (see *Data*).
#' @param model A model id from [pbtm_models()], e.g. `"thermal_time"`.
#' @param max_frac Maximum cumulative fraction (0-1] that the population can
#'   reach; the fitted curves plateau here. Use when even the optimal treatment
#'   does not reach full germination.
#' @param fixed Optional named list or vector of parameter values to hold
#'   constant instead of estimating, e.g. `list(t_b = 5)`. Single-population
#'   fits only.
#' @param bounds Optional named list overriding the default parameter bounds,
#'   each element `c(lower, start, upper)`, e.g. `list(t_b = c(0, 5, 12))`. See
#'   [pbtm_models()] for the defaults.
#' @param subpops Number of subpopulations to fit (a positive integer), or
#'   `"auto"` to choose between 1 and `max_subpops` by AIC. `"cdf"` models only.
#' @param max_subpops Largest number of subpopulations tried when
#'   `subpops = "auto"`.
#' @param restarts Number of alternative starting values tried for each
#'   mixture fit, and for a single-population fit that does not converge from
#'   the default starting values.
#' @param dose_transform Transform applied to the dosage column of the promoter
#'   and inhibitor models: `"none"` or `"log10"`. With `"log10"`, the median
#'   threshold (`p_b50` or `i_b50`) is estimated in log10 dose units.
#' @param speed Germination fraction (0-1) at which germination rates are
#'   computed for the rate models; `0.5` gives GR50.
#' @param cols Optional named character vector mapping template column names to
#'   the names used in `data`, e.g. `c(GermTemp = "temp", CumTime = "hours")`.
#'
#' @return A `pbtm_fit` object: a list with the model id and label, the
#'   estimated `coefficients`, the names of any `fixed` parameters, the number
#'   of subpopulations `k` and a `components` table (one row per subpopulation
#'   with its weight and parameters), goodness-of-fit `stats` (`n`, `npar`,
#'   `rss`, `aic`, `pseudo_r2` = squared correlation of observed and fitted),
#'   the data used for fitting, and the underlying `nls` object. For
#'   `subpops = "auto"`, `subpop_table` compares the candidate fits. Use
#'   [coef()], [predict()], [fitted()], [residuals()], [summary()] and
#'   [autoplot()][autoplot.pbtm_fit] to work with it.
#' @seealso The per-model wrappers [fit_thermal_time()], [fit_hydrotime()],
#'   [fit_hydrothermal_time()], [fit_hydropriming()],
#'   [fit_hydrothermal_priming()], [fit_aging()], [fit_promoter()] and
#'   [fit_inhibitor()].
#' @export
#' @examples
#' fit <- fit_pbtm(thermal_time_data, "thermal_time")
#' fit
#' coef(fit)
#'
#' # hold the base temperature at 5 degrees
#' fit_pbtm(thermal_time_data, "thermal_time", fixed = list(t_b = 5))
fit_pbtm <- function(
  data,
  model,
  max_frac = 1,
  fixed = NULL,
  bounds = NULL,
  subpops = 1,
  max_subpops = 3,
  restarts = 12,
  dose_transform = c("none", "log10"),
  speed = 0.5,
  cols = NULL
) {
  m <- get_model(model)
  dose_transform <- rlang::arg_match(dose_transform)
  data <- rename_cols(data, cols)
  check_fraction(max_frac, "max_frac", allow_zero = FALSE)

  if (dose_transform != "none" && is.null(m$transform_col)) {
    cli::cli_abort(
      "{.arg dose_transform} only applies to the promoter and inhibitor models."
    )
  }
  transform <- if (dose_transform == "log10") log10 else identity

  # subpopulations
  auto <- identical(subpops, "auto")
  if (!auto) {
    if (!rlang::is_scalar_integerish(subpops) || subpops < 1) {
      cli::cli_abort("{.arg subpops} must be a positive whole number or {.val auto}.")
    }
    subpops <- as.integer(subpops)
  }
  if (m$family == "rate" && (auto || subpops > 1)) {
    cli::cli_abort("Subpopulation mixtures are only available for cumulative germination models.")
  }
  if ((auto || subpops > 1) && length(fixed) > 0) {
    cli::cli_abort("{.arg fixed} parameters are only supported for single-population fits.")
  }

  fit_data <- prepare_fit_data(data, m, speed)
  if (!is.null(m$transform_col) && dose_transform == "log10" &&
    any(fit_data[[m$transform_col]] <= 0)) {
    cli::cli_abort("{.arg dose_transform = \"log10\"} requires all {.field {m$transform_col}} values to be positive.")
  }
  ranges <- resolve_bounds(m, bounds)

  if (auto) {
    det <- detect_subpops(m, fit_data, ranges, max_subpops, max_frac, transform, restarts)
    out <- det$best
  } else if (subpops == 1) {
    resolved <- resolve_params(fixed, ranges)
    pred <- function(d, p) m$predict(d, p, max_frac = max_frac, transform = transform)
    out <- fit_nls_restarts(pred, fit_data, resolved, m$response, restarts)
    if (is.character(out)) {
      cli::cli_abort(c("The {m$label} model failed to fit.", x = out))
    }
    out <- add_fit_stats(out, fit_data[[m$response]], length(resolved$free))
    out$k <- 1L
  } else {
    base <- fit_mixture(m, fit_data, 1L, ranges, NULL, max_frac, transform, restarts)
    out <- fit_mixture(
      m, fit_data, subpops, ranges,
      if (is.character(base)) NULL else base$coefficients,
      max_frac, transform, restarts
    )
    if (is.character(out)) {
      cli::cli_abort(c("The {subpops}-subpopulation {m$label} model failed to fit.", x = out))
    }
  }

  # rates were computed here (rather than supplied as a GR table) only when the
  # time courses were passed in
  speed <- if (m$family == "rate" && "CumFraction" %in% names(data)) speed
  fit <- new_pbtm_fit(out, m, fit_data, max_frac, dose_transform, speed, ranges)
  if (auto) fit$subpop_table <- det$table
  fit$call <- match.call()
  warn_fit_problems(fit)
  fit
}


# Data preparation -------------------------------------------------------------

prepare_fit_data <- function(data, m, speed, call = rlang::caller_env()) {
  check_data_frame(data, call = call)
  if (m$family == "rate") {
    if ("GR" %in% names(data) && !"CumFraction" %in% names(data)) {
      check_columns(data, c(m$factors, "GR"), m$label, call = call)
      return(tidyr::drop_na(data, dplyr::all_of(c(m$factors, "GR"))))
    }
    check_fraction(speed, "speed", allow_zero = FALSE, call = call)
    check_columns(data, c(m$groups, "CumTime", "CumFraction"), m$label, call = call)
    speeds <- germ_speed(data, fractions = speed, groups = m$groups)
    return(speeds[is.finite(speeds$GR), ])
  }
  needed <- c(m$factors, "CumTime", "CumFraction")
  check_columns(data, needed, m$label, call = call)
  data <- tidyr::drop_na(data, dplyr::all_of(needed))
  if (nrow(data) == 0) {
    cli::cli_abort("No complete observations to fit.", call = call)
  }
  data
}

#' @noRd
#' @description default bounds with user overrides; each c(lower, start, upper)
resolve_bounds <- function(m, bounds, call = rlang::caller_env()) {
  ranges <- m$params
  if (is.null(bounds)) {
    return(ranges)
  }
  bad <- setdiff(names(bounds), m$param_names)
  if (is.null(names(bounds)) || length(bad) > 0) {
    cli::cli_abort(
      "{.arg bounds} must be named with parameters of the {m$label} model: {.val {m$param_names}}.",
      call = call
    )
  }
  for (nm in names(bounds)) {
    b <- bounds[[nm]]
    if (!is.numeric(b) || length(b) != 3 || anyNA(b) || !(b[1] <= b[2] && b[2] <= b[3])) {
      cli::cli_abort(
        "{.arg bounds${nm}} must be numeric {.code c(lower, start, upper)} with lower <= start <= upper.",
        call = call
      )
    }
    ranges[[nm]] <- b
  }
  ranges
}

#' @noRd
#' @description combine fixed values and ranges into nls start/lower/upper.
#'   A fixed parameter has lower == start == upper so the port algorithm holds
#'   it constant.
resolve_params <- function(fixed, ranges, call = rlang::caller_env()) {
  fixed <- as.list(fixed)
  fixed <- fixed[!vapply(fixed, function(x) length(x) == 0 || all(is.na(x)), TRUE)]
  bad <- setdiff(names(fixed), names(ranges))
  if (length(fixed) > 0 && (is.null(names(fixed)) || length(bad) > 0)) {
    cli::cli_abort(
      "{.arg fixed} must be named with model parameters: {.val {names(ranges)}}.",
      call = call
    )
  }
  lower <- start <- upper <- list()
  for (p in names(ranges)) {
    if (!is.null(fixed[[p]])) {
      val <- fixed[[p]]
      if (!is.numeric(val) || length(val) != 1) {
        cli::cli_abort("{.arg fixed${p}} must be a single number.", call = call)
      }
      lower[[p]] <- start[[p]] <- upper[[p]] <- val
    } else {
      lower[[p]] <- ranges[[p]][1]
      start[[p]] <- ranges[[p]][2]
      upper[[p]] <- ranges[[p]][3]
    }
  }
  list(
    lower = lower,
    start = start,
    upper = upper,
    fixed = names(fixed),
    free = setdiff(names(ranges), names(fixed))
  )
}


# Fitting core -----------------------------------------------------------------

#' @noRd
#' @description fit a model from a prediction function with nls (port)
#' @param pred function(data, params_list) -> predicted response vector,
#'   already closed over max_frac / transform
#' @return list(nls, coefficients, fitted, converged) or an error message string
fit_nls <- function(pred, data, resolved, response) {
  obs <- data[[response]]
  param_names <- names(resolved$start)

  # nls estimates named scalar parameters, so build a formula whose right-hand
  # side calls a closure that reassembles them into the list pred() expects
  env <- new.env(parent = environment(pred) %||% globalenv())
  env$obs <- obs
  env$.pbtm_pred <- function(...) pred(data, list(...))
  rhs <- sprintf(
    ".pbtm_pred(%s)",
    paste(sprintf("%s = %s", param_names, param_names), collapse = ", ")
  )
  form <- stats::as.formula(paste("obs ~", rhs), env = env)

  model <- tryCatch(
    suppressWarnings(stats::nls(
      formula = form,
      start = resolved$start,
      lower = resolved$lower,
      upper = resolved$upper,
      algorithm = "port",
      control = list(warnOnly = TRUE)
    )),
    error = function(e) conditionMessage(e)
  )
  if (is.character(model)) {
    return(model)
  }

  coefs <- stats::coef(model)
  # held parameters come back from nls unchanged, but use the exact values
  for (p in resolved$fixed) coefs[[p]] <- resolved$start[[p]]
  list(
    nls = model,
    coefficients = coefs[param_names],
    fixed = resolved$fixed,
    fitted = as.numeric(stats::fitted(model)),
    converged = isTRUE(model$convInfo$isConv),
    lower = unlist(resolved$lower),
    upper = unlist(resolved$upper)
  )
}

#' @noRd
#' @description fit from the default start; if that fails or does not
#'   converge (the port algorithm can stop at a "false convergence" far from
#'   the optimum when the start is poor), retry from random starting values
#'   within the bounds and keep the best converged fit
fit_nls_restarts <- function(pred, data, resolved, response, restarts) {
  first <- fit_nls(pred, data, resolved, response)
  if (is.list(first) && first$converged) {
    return(first)
  }
  rss <- function(res) sum((data[[response]] - res$fitted)^2)
  fits <- if (is.list(first)) list(first) else list()
  for (s in seq_len(restarts)) {
    alt <- resolved
    with_seed(2000 + s, {
      for (p in resolved$free) {
        lo <- resolved$lower[[p]]
        hi <- resolved$upper[[p]]
        # sample positive parameters with wide bounds on a log scale
        alt$start[[p]] <- if (lo > 0 && hi / lo > 100) {
          exp(stats::runif(1, log(lo), log(hi)))
        } else {
          stats::runif(1, lo, hi)
        }
      }
    })
    res <- fit_nls(pred, data, alt, response)
    if (is.list(res)) fits[[length(fits) + 1]] <- res
  }
  if (length(fits) == 0) {
    return(first)
  }
  converged <- Filter(function(f) f$converged, fits)
  pool <- if (length(converged) > 0) converged else fits
  pool[[which.min(vapply(pool, rss, numeric(1)))]]
}

#' @noRd
#' @description attach goodness-of-fit statistics. AIC is the Gaussian AIC up
#'   to an additive constant, which is fine for comparing fits to the same data.
add_fit_stats <- function(res, observed, npar) {
  rss <- sum((observed - res$fitted)^2)
  n <- length(observed)
  res$stats <- list(
    n = n,
    npar = npar,
    rss = rss,
    aic = n * log(rss / n) + 2 * (npar + 1),
    pseudo_r2 = suppressWarnings(stats::cor(observed, res$fitted)^2)
  )
  res
}

new_pbtm_fit <- function(res, m, fit_data, max_frac, dose_transform, speed, ranges) {
  k <- res$k
  coefs <- res$coefficients
  structure(
    list(
      model = m$id,
      label = m$label,
      family = m$family,
      coefficients = coefs,
      fixed = res$fixed %||% character(),
      k = k,
      components = component_table(m, coefs, k),
      stats = res$stats,
      converged = res$converged,
      max_frac = max_frac,
      dose_transform = dose_transform,
      speed = speed,
      bounds = ranges,
      at_bound = at_bound(coefs, res$lower, res$upper, res$fixed),
      data = tibble::as_tibble(fit_data),
      response = m$response,
      fitted = res$fitted,
      nls = res$nls,
      subpop_table = NULL
    ),
    class = "pbtm_fit"
  )
}

#' @noRd
#' @description names of free parameters whose estimates sit on a bound
at_bound <- function(coefs, lower, upper, fixed) {
  free <- setdiff(names(coefs), fixed)
  tol <- 1e-6 * pmax(1, abs(coefs[free]))
  hit <- abs(coefs[free] - lower[free]) < tol | abs(coefs[free] - upper[free]) < tol
  free[hit]
}

warn_fit_problems <- function(fit) {
  if (!isTRUE(fit$converged)) {
    cli::cli_warn(c(
      "The {fit$label} fit did not fully converge.",
      i = "Check the fit visually, or adjust {.arg bounds} or {.arg max_frac}."
    ))
  }
  hit <- setdiff(fit$at_bound, grep("^w[0-9]+$", fit$at_bound, value = TRUE))
  if (length(hit) > 0) {
    n <- length(hit)
    cli::cli_warn(c(
      "{.field {hit}} {cli::qty(n)}{?is/are} at {?its/their} bound.",
      i = "The data may not constrain {cli::qty(n)}{?this parameter/these parameters}; consider widening {.arg bounds} or holding {cli::qty(n)}{?it/them} {.arg fixed}."
    ))
  }
}

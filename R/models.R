# Model definitions ------------------------------------------------------------
#
# One definition per population-based threshold model. Everything that differs
# between models lives here; fitting, mixtures, prediction and plotting are
# generic and driven by these definitions.
#
# Two families:
#   "cdf"  - cumulative germination is a (scaled) normal CDF of a threshold
#            variable: CumFraction = max_frac * pnorm(threshold, center, sigma).
#            `threshold(data, p, transform)` returns the threshold variable for
#            each observation and `center(p)` its population median, so the
#            standardized deviate is (threshold - center) / sigma (negated when
#            `lower_tail = FALSE`). This deviate is also the probit of the
#            germinated fraction, which is what the linearized plots show.
#   "rate" - germination rate (GR = 1 / time to a given fraction) is linear in a
#            priming "time" theta: GR = gr_i + slope * theta(data, p).
#
# `params` holds c(lower, start, upper) for each parameter, in fitting order.

new_pbtm_model <- function(
  id,
  label,
  family,
  factors,
  params,
  threshold = NULL,
  center = NULL,
  lower_tail = TRUE,
  theta = NULL,
  normalized = NULL,
  transform_col = NULL,
  subpop_param = NULL,
  plot = list()
) {
  stopifnot(family %in% c("cdf", "rate"))
  if (family == "cdf") {
    stopifnot(is.function(threshold), is.function(center))
    predict <- function(data, p, max_frac = 1, transform = identity) {
      max_frac *
        stats::pnorm(
          threshold(data, p, transform),
          mean = center(p),
          sd = p$sigma,
          lower.tail = lower_tail
        )
    }
  } else {
    stopifnot(is.function(theta))
    predict <- function(data, p, max_frac = 1, transform = identity) {
      p$gr_i + p$slope * theta(data, p)
    }
  }
  structure(
    list(
      id = id,
      label = label,
      family = family,
      factors = factors,
      params = params,
      param_names = names(params),
      predict = predict,
      threshold = threshold,
      center = center,
      lower_tail = lower_tail,
      theta = theta,
      normalized = normalized,
      response = if (family == "rate") "GR" else "CumFraction",
      groups = c("TrtID", factors),
      transform_col = transform_col,
      subpop_param = subpop_param,
      plot = plot
    ),
    class = "pbtm_model"
  )
}

pbtm_model_defs <- list(
  thermal_time = new_pbtm_model(
    id = "thermal_time",
    label = "Thermal time",
    family = "cdf",
    factors = "GermTemp",
    params = list(
      t_b = c(0, 6, 20),
      theta_t50 = c(3, 1000, 5e19),
      # sigma is on the log10 scale, where typical values are ~0.05-0.2
      sigma = c(0.0005, 0.1, 35)
    ),
    # log10 thermal time, log-normally distributed across the population
    threshold = function(data, p, transform = identity) {
      log10((data$GermTemp - p$t_b) * data$CumTime)
    },
    center = function(p) log10(p$theta_t50),
    normalized = list(
      x = function(data, p, transform = identity) {
        (data$GermTemp - p$t_b) * data$CumTime
      },
      log = TRUE,
      label = "Thermal time, (T - T_b) * t"
    ),
    subpop_param = "theta_t50",
    plot = list(
      color = "GermTemp",
      color_label = "Temperature",
      title = "Thermal time model (sub-optimal temperatures)"
    )
  ),

  hydrotime = new_pbtm_model(
    id = "hydrotime",
    label = "Hydrotime",
    family = "cdf",
    factors = "GermWP",
    params = list(
      theta_h = c(1, 60, 1000),
      psi_b50 = c(-5, -0.8, -1e-9),
      sigma = c(1e-4, 0.2, 2)
    ),
    threshold = function(data, p, transform = identity) {
      data$GermWP - p$theta_h / data$CumTime
    },
    center = function(p) p$psi_b50,
    normalized = list(label = "Base water potential, psi - theta_H / t"),
    subpop_param = "psi_b50",
    plot = list(
      color = "GermWP",
      color_label = "Water potential",
      title = "Hydrotime model"
    )
  ),

  hydrothermal_time = new_pbtm_model(
    id = "hydrothermal_time",
    label = "Hydrothermal time",
    family = "cdf",
    factors = c("GermWP", "GermTemp"),
    params = list(
      theta_ht = c(1, 800, 5000),
      t_b = c(0, 1, 15),
      psi_b50 = c(-5, -1, 0),
      sigma = c(1e-4, 0.4, 10)
    ),
    threshold = function(data, p, transform = identity) {
      data$GermWP - p$theta_ht / ((data$GermTemp - p$t_b) * data$CumTime)
    },
    center = function(p) p$psi_b50,
    normalized = list(
      label = "Base water potential, psi - theta_HT / ((T - T_b) * t)"
    ),
    subpop_param = "psi_b50",
    plot = list(
      color = "GermWP",
      color_label = "Water potential",
      shape = "GermTemp",
      shape_label = "Temperature",
      title = "Hydrothermal time model"
    )
  ),

  hydropriming = new_pbtm_model(
    id = "hydropriming",
    label = "Hydropriming",
    family = "rate",
    factors = c("PrimingWP", "PrimingDuration"),
    params = list(
      psi_min = c(-10, -1, -0.5),
      gr_i = c(1e-8, 0.001, 0.1),
      slope = c(1e-8, 0.1, 1)
    ),
    theta = function(data, p) {
      (data$PrimingWP - p$psi_min) * data$PrimingDuration
    },
    plot = list(
      x_label = "Hydropriming time, (psi - psi_min) * duration",
      color = "PrimingWP",
      color_label = "Water potential",
      shape = "PrimingDuration",
      shape_label = "Duration",
      title = "Hydropriming model"
    )
  ),

  hydrothermal_priming = new_pbtm_model(
    id = "hydrothermal_priming",
    label = "Hydrothermal priming",
    family = "rate",
    factors = c("PrimingTemp", "PrimingWP", "PrimingDuration"),
    params = list(
      t_min = c(0.5, 12, 20),
      psi_min = c(-10, -1, -0.5),
      gr_i = c(1e-8, 0.001, 0.1),
      slope = c(1e-8, 0.1, 1)
    ),
    theta = function(data, p) {
      (data$PrimingWP - p$psi_min) *
        (data$PrimingTemp - p$t_min) *
        data$PrimingDuration
    },
    plot = list(
      x_label = "Hydrothermal priming time, (psi - psi_min) * (T - T_min) * duration",
      color = "PrimingWP",
      color_label = "Water potential",
      shape = "PrimingTemp",
      shape_label = "Temperature",
      size = "PrimingDuration",
      size_label = "Duration",
      title = "Hydrothermal priming model"
    )
  ),

  aging = new_pbtm_model(
    id = "aging",
    label = "Aging",
    family = "cdf",
    factors = "AgingTime",
    params = list(
      theta_a = c(1, 100, 1000),
      p_max50 = c(1, 10, 1000),
      sigma = c(0.1, 3, 10)
    ),
    threshold = function(data, p, transform = identity) {
      data$AgingTime + p$theta_a / data$CumTime
    },
    center = function(p) p$p_max50,
    lower_tail = FALSE,
    normalized = list(label = "Aging threshold, aging time + theta_A / t"),
    subpop_param = "p_max50",
    plot = list(
      color = "AgingTime",
      color_label = "Aging time",
      title = "Aging model"
    )
  ),

  promoter = new_pbtm_model(
    id = "promoter",
    label = "Promoter",
    family = "cdf",
    factors = "GermPromoterDosage",
    params = list(
      theta_p = c(1, 200, 1000),
      p_b50 = c(0.05, 5, 1000),
      sigma = c(0.001, 3, 10)
    ),
    threshold = function(data, p, transform = identity) {
      transform(data$GermPromoterDosage) - p$theta_p / data$CumTime
    },
    center = function(p) p$p_b50,
    normalized = list(label = "Promoter threshold, dose - theta_P / t"),
    transform_col = "GermPromoterDosage",
    subpop_param = "p_b50",
    plot = list(
      color = "GermPromoterDosage",
      color_label = "Promoter dosage",
      title = "Promoter model"
    )
  ),

  inhibitor = new_pbtm_model(
    id = "inhibitor",
    label = "Inhibitor",
    family = "cdf",
    factors = "GermInhibitorDosage",
    params = list(
      theta_i = c(1, 100, 1000),
      i_b50 = c(0.05, 10, 1000),
      sigma = c(0.001, 3, 10)
    ),
    threshold = function(data, p, transform = identity) {
      transform(data$GermInhibitorDosage) + p$theta_i / data$CumTime
    },
    center = function(p) p$i_b50,
    lower_tail = FALSE,
    normalized = list(label = "Inhibitor threshold, dose + theta_I / t"),
    transform_col = "GermInhibitorDosage",
    subpop_param = "i_b50",
    plot = list(
      color = "GermInhibitorDosage",
      color_label = "Inhibitor dosage",
      title = "Inhibitor model"
    )
  )
)


#' Available population-based threshold models
#'
#' Lists the models that [fit_pbtm()] can fit, with the data columns each one
#' requires and its parameters and their default bounds.
#'
#' @param model Optional model id. If supplied, the full model definition is
#'   returned instead of the summary table (mainly useful for developers).
#' @return A tibble with one row per model: `model` (the id passed to
#'   [fit_pbtm()]), `label`, `family` (`"cdf"` for cumulative germination
#'   models, `"rate"` for germination-rate models), `factors` (treatment columns
#'   required in addition to `CumTime` and `CumFraction`), `params`, and
#'   `bounds` (a list column of data frames giving `lower`, `start`, and `upper`
#'   for each parameter).
#' @export
#' @examples
#' pbtm_models()
#' pbtm_models()$bounds[[1]]
pbtm_models <- function(model = NULL) {
  if (!is.null(model)) {
    return(get_model(model))
  }
  tibble::tibble(
    model = names(pbtm_model_defs),
    label = vapply(pbtm_model_defs, `[[`, "", "label"),
    family = vapply(pbtm_model_defs, `[[`, "", "family"),
    factors = lapply(pbtm_model_defs, `[[`, "factors"),
    params = lapply(pbtm_model_defs, `[[`, "param_names"),
    bounds = lapply(pbtm_model_defs, function(m) {
      data.frame(
        param = m$param_names,
        lower = vapply(m$params, `[`, 0, 1),
        start = vapply(m$params, `[`, 0, 2),
        upper = vapply(m$params, `[`, 0, 3),
        row.names = NULL
      )
    })
  )
}

get_model <- function(model, call = rlang::caller_env()) {
  if (inherits(model, "pbtm_model")) {
    return(model)
  }
  if (!rlang::is_string(model) || !model %in% names(pbtm_model_defs)) {
    cli::cli_abort(
      c(
        "{.arg model} must be one of {.or {.val {names(pbtm_model_defs)}}}.",
        x = "Got {.val {model}}."
      ),
      call = call
    )
  }
  pbtm_model_defs[[model]]
}

#' @export
print.pbtm_model <- function(x, ...) {
  cat(sprintf("<pbtm_model> %s (%s)\n", x$label, x$family))
  cat("  factors:", paste(x$factors, collapse = ", "), "\n")
  cat("  params: ", paste(x$param_names, collapse = ", "), "\n")
  invisible(x)
}

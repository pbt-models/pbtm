#' Plot a fitted PBTM model
#'
#' Draws the data used to fit a model together with the fitted model, with
#' optional linearizing axis transforms.
#'
#' @section Plot types:
#' * `type = "fit"` (default): for cumulative models, the cumulative fraction
#'   germinated against time, with one fitted curve per treatment level; for
#'   rate models, germination rate against priming time with the fitted line.
#' * `type = "normalized"` (single-population cumulative models only): every
#'   observation is placed on the model's normalized axis (e.g. thermal time
#'   \eqn{(T - T_b)t} for thermal time, or \eqn{\psi - \theta_H/t} for
#'   hydrotime) and the fraction is rescaled by `max_frac`. All treatments then
#'   collapse onto the single population distribution, which is a straight line
#'   on a probit fraction axis. The dashed line marks the population median.
#'
#' @section Linearized scales:
#' The cumulative models are normal (or, for thermal time, log-normal)
#' distributions, so a *probit* fraction axis (`y_scale = "probit"`, the normal
#' quantile of the fraction) straightens them. For thermal time, whose
#' distribution is log-normal in time, combining `x_scale = "log"` with
#' `y_scale = "probit"` makes each temperature's fitted curve an exact straight
#' line; for the other models the fitted curves become close to linear. A
#' `"logit"` fraction axis is also available and looks very similar. Points at
#' 0% or 100% germination (and times of zero on a log axis) cannot be shown on
#' these scales and are dropped with a message. For rate models, `"log"` on
#' both axes gives a log-log plot of rate against priming time.
#'
#' @param object A `pbtm_fit` object.
#' @param type `"fit"` or `"normalized"`; see *Plot types*.
#' @param x_scale `"linear"` or `"log"` (log10) x axis. For `type =
#'   "normalized"` the default is `"log"` for thermal time and `"linear"`
#'   otherwise.
#' @param y_scale `"linear"`, `"probit"`, or `"logit"` fraction axis for
#'   cumulative models; `"linear"` or `"log"` rate axis for rate models. The
#'   default is `"linear"`, or `"probit"` for `type = "normalized"`.
#' @param show_params Show the parameter estimates as a subtitle?
#' @param n Number of points used to draw each fitted curve.
#' @param x A `pbtm_fit` object.
#' @param ... Passed from `plot()` to `autoplot()`.
#' @return A ggplot object.
#' @export
#' @examples
#' fit <- fit_thermal_time(thermal_time_data)
#' autoplot(fit)
#'
#' # log time and probit fraction: each temperature becomes a straight line
#' autoplot(fit, x_scale = "log", y_scale = "probit")
#'
#' # all temperatures collapse onto one line on the normalized axis
#' autoplot(fit, type = "normalized")
autoplot.pbtm_fit <- function(
  object,
  type = c("fit", "normalized"),
  x_scale = NULL,
  y_scale = NULL,
  show_params = TRUE,
  n = 200,
  ...
) {
  type <- rlang::arg_match(type)
  m <- get_model(object$model)
  if (type == "normalized") {
    if (m$family != "cdf" || object$k > 1) {
      cli::cli_abort(c(
        "{.code type = \"normalized\"} is only available for single-population cumulative models.",
        i = "For subpopulation mixtures, try {.code y_scale = \"probit\"} with {.code type = \"fit\"}."
      ))
    }
    x_scale <- x_scale %||% if (isTRUE(m$normalized$log)) "log" else "linear"
    y_scale <- y_scale %||% "probit"
  }
  x_scale <- x_scale %||% "linear"
  x_scale <- rlang::arg_match(x_scale, c("linear", "log"))
  y_choices <- if (m$family == "rate") c("linear", "log") else c("linear", "probit", "logit")
  y_scale <- y_scale %||% "linear"
  y_scale <- rlang::arg_match(y_scale, y_choices)

  plt <- if (m$family == "rate") {
    plot_rate_fit(object, m, x_scale, y_scale, n)
  } else if (type == "normalized") {
    plot_normalized_fit(object, m, x_scale, y_scale, n)
  } else {
    plot_cdf_fit(object, m, x_scale, y_scale, n)
  }
  if (show_params) {
    plt <- plt + ggplot2::labs(subtitle = params_label(object))
  }
  plt
}

#' @rdname autoplot.pbtm_fit
#' @export
plot.pbtm_fit <- function(x, ...) {
  print(autoplot(x, ...))
  invisible(x)
}

#' Plot germination time courses
#'
#' Plots raw cumulative germination data, optionally on linearized scales (see
#' [autoplot.pbtm_fit()]).
#'
#' @param data A data frame with `CumTime` and `CumFraction` columns.
#' @param color,shape Optional columns mapped to point color and shape.
#' @param group Column identifying each germination curve, used to draw lines.
#' @param line Connect the points of each curve?
#' @param x_scale `"linear"` or `"log"` time axis.
#' @param y_scale `"linear"`, `"probit"`, or `"logit"` fraction axis.
#' @return A ggplot object.
#' @family germination data helpers
#' @export
#' @examples
#' plot_germ_data(germination_data, color = "GermTemp")
#' plot_germ_data(germination_data, color = "GermTemp", x_scale = "log", y_scale = "probit")
plot_germ_data <- function(
  data,
  color = NULL,
  shape = NULL,
  group = "TrtID",
  line = TRUE,
  x_scale = c("linear", "log"),
  y_scale = c("linear", "probit", "logit")
) {
  check_data_frame(data)
  x_scale <- rlang::arg_match(x_scale)
  y_scale <- rlang::arg_match(y_scale)
  check_columns(data, c("CumTime", "CumFraction", color, shape, if (line) group), "plotting")

  data <- drop_unplottable(data, "CumTime", "CumFraction", x_scale, y_scale)
  for (col in c(color, shape)) data[[col]] <- as.factor(data[[col]])

  aes_args <- list(x = quote(.data$CumTime), y = quote(.data$CumFraction))
  if (!is.null(color)) aes_args$color <- rlang::expr(.data[[!!color]])
  if (!is.null(shape)) aes_args$shape <- rlang::expr(.data[[!!shape]])
  if (line) aes_args$group <- rlang::expr(.data[[!!group]])

  plt <- ggplot2::ggplot(data, rlang::inject(ggplot2::aes(!!!aes_args))) +
    ggplot2::geom_point(size = 2)
  if (line) plt <- plt + ggplot2::geom_line(alpha = 0.6)
  plt +
    x_axis(x_scale, "Time") +
    fraction_axis(y_scale, "Cumulative germination") +
    ggplot2::labs(color = color, shape = shape) +
    pbtm_theme()
}


# Plot builders ----------------------------------------------------------------

plot_cdf_fit <- function(fit, m, x_scale, y_scale, n) {
  cfg <- m$plot
  df <- factor_columns(fit$data, cfg)
  df <- drop_unplottable(df, "CumTime", "CumFraction", x_scale, y_scale)

  curves <- cdf_curve_data(fit, m, x_scale, n)
  curves <- factor_columns(curves, cfg)
  curves <- drop_unplottable(curves, "CumTime", "pred", x_scale, y_scale, quiet = TRUE)
  line_group <- rlang::expr(interaction(!!!rlang::syms(m$factors)))

  plt <- ggplot2::ggplot(
    df,
    ggplot2::aes(x = .data$CumTime, y = .data$CumFraction, color = .data[[cfg$color]])
  )
  if (fit$max_frac < 1) {
    plt <- plt + ggplot2::geom_hline(yintercept = fit$max_frac, color = "grey50", linetype = "dashed")
  }
  if (!is.null(cfg$shape)) {
    plt <- plt +
      ggplot2::geom_point(ggplot2::aes(shape = .data[[cfg$shape]]), size = 2) +
      ggplot2::geom_line(
        data = curves,
        ggplot2::aes(y = .data$pred, linetype = .data[[cfg$shape]], group = !!line_group)
      )
  } else {
    plt <- plt +
      ggplot2::geom_point(size = 2) +
      ggplot2::geom_line(data = curves, ggplot2::aes(y = .data$pred, group = !!line_group))
  }
  plt +
    x_axis(x_scale, "Time") +
    fraction_axis(y_scale, "Cumulative germination") +
    ggplot2::labs(
      title = fit_title(fit, cfg),
      color = cfg$color_label,
      shape = cfg$shape_label,
      linetype = cfg$shape_label
    ) +
    pbtm_theme()
}

plot_normalized_fit <- function(fit, m, x_scale, y_scale, n) {
  cfg <- m$plot
  p <- as.list(fit$coefficients)
  transform <- fit_transform(fit)
  log_axis <- isTRUE(m$normalized$log)

  df <- fit$data
  df$x <- normalized_x(m, df, p, transform)
  df$y <- df$CumFraction / fit$max_frac
  df <- factor_columns(df, cfg)
  df <- df[is.finite(df$x), ]
  df <- drop_unplottable(df, "x", "y", x_scale, y_scale)

  # the population distribution on the normalized axis: a straight line on a
  # probit axis (thermal time is log-normal, i.e. linear in log10 thermal time)
  rng <- range(df$x)
  xs <- if (x_scale == "log") 10^seq(log10(rng[1]), log10(rng[2]), length.out = n) else seq(rng[1], rng[2], length.out = n)
  q <- if (log_axis) log10(xs) else xs
  line <- data.frame(
    x = xs,
    y = stats::pnorm(q, m$center(p), p$sigma, lower.tail = m$lower_tail)
  )
  line <- drop_unplottable(line, "x", "y", x_scale, y_scale, quiet = TRUE)
  median_x <- if (log_axis) 10^m$center(p) else m$center(p)

  x_label <- m$normalized$label
  if (fit$dose_transform == "log10") x_label <- sub("dose", "log10(dose)", x_label, fixed = TRUE)

  plt <- ggplot2::ggplot(df, ggplot2::aes(x = .data$x, y = .data$y)) +
    ggplot2::geom_vline(xintercept = median_x, color = "grey50", linetype = "dashed") +
    ggplot2::geom_line(data = line, color = "grey20", linewidth = 0.8)
  plt <- if (!is.null(cfg$shape)) {
    plt + ggplot2::geom_point(ggplot2::aes(color = .data[[cfg$color]], shape = .data[[cfg$shape]]), size = 2)
  } else {
    plt + ggplot2::geom_point(ggplot2::aes(color = .data[[cfg$color]]), size = 2)
  }
  plt +
    x_axis(x_scale, x_label) +
    fraction_axis(
      y_scale,
      if (fit$max_frac < 1) "Germination (fraction of max_frac)" else "Cumulative germination"
    ) +
    ggplot2::labs(
      title = paste(fit_title(fit, cfg), "- normalized"),
      color = cfg$color_label,
      shape = cfg$shape_label
    ) +
    pbtm_theme()
}

plot_rate_fit <- function(fit, m, x_scale, y_scale, n) {
  cfg <- m$plot
  p <- as.list(fit$coefficients)
  df <- fit$data
  df$theta <- m$theta(df, p)
  df <- factor_columns(df, cfg)
  df <- drop_unplottable(df, "theta", "GR", x_scale, y_scale)

  rng <- range(c(0, df$theta))
  if (x_scale == "log") rng <- range(df$theta)
  xs <- if (x_scale == "log") 10^seq(log10(rng[1]), log10(rng[2]), length.out = n) else seq(rng[1], rng[2], length.out = n)
  line <- data.frame(theta = xs, GR = p$gr_i + p$slope * xs)
  line <- drop_unplottable(line, "theta", "GR", x_scale, y_scale, quiet = TRUE)

  aes_args <- list(color = rlang::expr(.data[[!!cfg$color]]))
  if (!is.null(cfg$shape)) aes_args$shape <- rlang::expr(.data[[!!cfg$shape]])
  if (!is.null(cfg$size)) aes_args$size <- rlang::expr(.data[[!!cfg$size]])

  plt <- ggplot2::ggplot(df, ggplot2::aes(x = .data$theta, y = .data$GR)) +
    ggplot2::geom_line(data = line, color = "grey20", linewidth = 0.8)
  plt <- if (is.null(cfg$size)) {
    plt + ggplot2::geom_point(rlang::inject(ggplot2::aes(!!!aes_args)), size = 3)
  } else {
    plt + ggplot2::geom_point(rlang::inject(ggplot2::aes(!!!aes_args)))
  }
  rate_label <- if (!is.null(fit$speed)) sprintf("Germination rate (GR%s)", fit$speed * 100) else "Germination rate (GR)"
  plt +
    x_axis(x_scale, cfg$x_label) +
    (if (y_scale == "log") ggplot2::scale_y_log10() else ggplot2::scale_y_continuous()) +
    ggplot2::labs(
      title = cfg$title,
      y = rate_label,
      color = cfg$color_label,
      shape = cfg$shape_label,
      size = cfg$size_label
    ) +
    pbtm_theme()
}


# Helpers ----------------------------------------------------------------------

#' @noRd
#' @description predicted curves over a time grid for each combination of the
#'   model's factor levels
cdf_curve_data <- function(fit, m, x_scale, n) {
  combos <- dplyr::distinct(fit$data, dplyr::across(dplyr::all_of(m$factors)))
  times <- fit$data$CumTime
  tmax <- max(times) * 1.05
  tseq <- if (x_scale == "log") {
    tmin <- min(times[times > 0]) / 1.5
    10^seq(log10(tmin), log10(tmax), length.out = n)
  } else {
    seq(tmax / (n * 10), tmax, length.out = n)
  }
  grid <- tidyr::expand_grid(combos, CumTime = tseq)
  grid$pred <- mixture_predict(m, grid, fit$coefficients, fit$k, fit$max_frac, fit_transform(fit))
  grid
}

#' @noRd
#' @description treat the plotted factor columns as discrete
factor_columns <- function(df, cfg) {
  for (col in unique(c(cfg$color, cfg$shape))) {
    if (col %in% names(df)) df[[col]] <- factor(df[[col]], levels = sort(unique(df[[col]])))
  }
  df
}

#' @noRd
#' @description drop points that cannot be drawn on log / probit / logit axes
drop_unplottable <- function(df, x, y, x_scale, y_scale, quiet = FALSE) {
  keep <- is.finite(df[[x]]) & is.finite(df[[y]])
  if (x_scale == "log") keep <- keep & df[[x]] > 0
  if (y_scale == "log") keep <- keep & df[[y]] > 0
  if (y_scale %in% c("probit", "logit")) {
    # fitted curves are clipped to the visible range so their asymptotic tails
    # do not stretch the transformed axis far beyond the data
    lim <- if (quiet) c(0.005, 0.995) else c(0, 1)
    keep <- keep & df[[y]] > lim[1] & df[[y]] < lim[2]
  }
  dropped <- sum(!keep)
  if (!quiet && dropped > 0 && (x_scale != "linear" || y_scale != "linear")) {
    hint <- if (y_scale %in% c("probit", "logit")) " (e.g. 0% or 100% germination)" else " (zero or negative values)"
    cli::cli_inform("Dropped {dropped} point{?s} that cannot be shown on the {x_scale}/{y_scale} axes{hint}.")
  }
  df[keep, , drop = FALSE]
}

x_axis <- function(scale, label) {
  if (scale == "log") {
    ggplot2::scale_x_log10(name = label)
  } else {
    ggplot2::scale_x_continuous(name = label)
  }
}

fraction_axis <- function(scale, label) {
  breaks <- c(0.01, 0.05, 0.1, 0.25, 0.5, 0.75, 0.9, 0.95, 0.99)
  switch(scale,
    linear = ggplot2::scale_y_continuous(
      name = label,
      labels = scales::label_percent(),
      limits = c(0, NA),
      expand = ggplot2::expansion(mult = c(0, 0.05))
    ),
    probit = ggplot2::scale_y_continuous(
      name = paste(label, "(probit scale)"),
      transform = scales::transform_probit(),
      breaks = breaks,
      labels = scales::label_percent()
    ),
    logit = ggplot2::scale_y_continuous(
      name = paste(label, "(logit scale)"),
      transform = scales::transform_logit(),
      breaks = breaks,
      labels = scales::label_percent()
    )
  )
}

fit_title <- function(fit, cfg) {
  if (fit$k > 1) sprintf("%s (%d subpopulations)", cfg$title, fit$k) else cfg$title
}

params_label <- function(fit) {
  fmt <- function(x) format_num(x, 4)
  # "R" + superscript two, built at runtime to keep the source ASCII
  r2 <- sprintf("R%s = %s", intToUtf8(178), signif(fit$stats$pseudo_r2, 3))
  if (fit$k > 1) {
    w <- paste(sprintf("%.0f%%", fit$components$weight * 100), collapse = " / ")
    return(sprintf("%d subpopulations (%s); %s", fit$k, w, r2))
  }
  coefs <- fit$coefficients
  parts <- sprintf("%s = %s", names(coefs), vapply(coefs, fmt, ""))
  paste(c(parts, r2), collapse = ", ")
}

pbtm_theme <- function() {
  ggplot2::theme_bw() +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      plot.subtitle = ggplot2::element_text(size = 9, color = "grey30")
    )
}

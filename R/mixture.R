# Subpopulation mixtures -------------------------------------------------------
#
# A seed lot may be a blend of distinct subpopulations whose summed germination
# matches the overall time course:
#
#   frac = max_frac * sum_j w_j * Phi_j(...),   sum w_j = 1,  w_j >= 0
#
# Each component j has its own copy of the model parameters. Mixing weights use
# a stick-breaking parameterisation so each free weight stays in (0, 1)
# independently (ideal for nls "port" bounds) while the weights form a valid
# simplex. Because every cdf model exposes predict(data, params), the mixture is
# fully generic.

#' @noRd
#' @description stick-breaking weights from k - 1 free fractions w1..w{k-1}
mixture_weights <- function(p, k) {
  if (k == 1) {
    return(1)
  }
  w <- numeric(k)
  remaining <- 1
  for (j in seq_len(k - 1)) {
    f <- p[[paste0("w", j)]]
    w[j] <- remaining * f
    remaining <- remaining * (1 - f)
  }
  w[k] <- remaining
  w
}

#' @noRd
#' @description one component's parameter list from the flat parameter list
component_params <- function(m, p, j) {
  stats::setNames(
    lapply(m$param_names, function(nm) p[[paste0(nm, j)]]),
    m$param_names
  )
}

#' @noRd
#' @description predicted response for a k-component mixture. For k == 1, `p`
#'   uses the plain parameter names.
mixture_predict <- function(m, data, p, k, max_frac = 1, transform = identity) {
  p <- as.list(p)
  if (k == 1) {
    return(m$predict(data, p[m$param_names], max_frac = max_frac, transform = transform))
  }
  w <- mixture_weights(p, k)
  total <- 0
  for (j in seq_len(k)) {
    total <- total +
      w[j] * m$predict(data, component_params(m, p, j), max_frac = 1, transform = transform)
  }
  max_frac * total
}

#' @noRd
#' @description one row per subpopulation: component, weight, parameters
component_table <- function(m, coefs, k) {
  p <- as.list(coefs)
  rows <- lapply(seq_len(k), function(j) {
    vals <- if (k == 1) p[m$param_names] else component_params(m, p, j)
    tibble::as_tibble(c(list(component = j, weight = mixture_weights(p, k)[j]), vals))
  })
  dplyr::bind_rows(rows)
}

#' @noRd
#' @description run code with a fixed RNG seed without disturbing the caller's
#'   random number stream
with_seed <- function(seed, code) {
  old <- if (exists(".Random.seed", globalenv(), inherits = FALSE)) {
    get(".Random.seed", globalenv(), inherits = FALSE)
  }
  on.exit({
    if (is.null(old)) {
      rm(".Random.seed", envir = globalenv())
    } else {
      assign(".Random.seed", old, envir = globalenv())
    }
  })
  set.seed(seed)
  code
}

#' @noRd
#' @description starting values for a k-component mixture: components are
#'   seeded from the single-population fit, jittered so restarts explore
#'   different basins, and spread along the subpopulation-distinguishing
#'   parameter to break symmetry
mixture_start <- function(m, ranges, k, base, restart) {
  with_seed(1000 + restart, {
    lower <- start <- upper <- list()
    clamp <- function(x, nm) min(max(x, ranges[[nm]][1]), ranges[[nm]][3])
    # a single-population estimate stuck on a bound (e.g. sigma collapsing to
    # its minimum on clearly multimodal data) is a poor seed: every component
    # would start degenerate, so fall back to the default start instead
    base <- as.list(base)
    for (nm in names(base)) {
      rng <- ranges[[paste0(nm, 1)]]
      if (!is.null(rng) && min(abs(base[[nm]] - rng[c(1, 3)])) < 1e-6 * max(1, abs(base[[nm]]))) {
        base[[nm]] <- NULL
      }
    }
    for (nm in names(ranges)) {
      lower[[nm]] <- ranges[[nm]][1]
      start[[nm]] <- ranges[[nm]][2]
      upper[[nm]] <- ranges[[nm]][3]
    }
    for (j in seq_len(k)) {
      for (nm in m$param_names) {
        fn <- paste0(nm, j)
        bval <- if (!is.null(base[[nm]])) base[[nm]] else ranges[[fn]][2]
        start[[fn]] <- clamp(bval * stats::runif(1, 0.6, 1.4), fn)
      }
    }
    sp <- m$subpop_param
    if (!is.null(sp)) {
      bval <- if (!is.null(base[[sp]])) base[[sp]] else ranges[[paste0(sp, 1)]][2]
      for (j in seq_len(k)) {
        mult <- exp((j - (k + 1) / 2) * 0.9 * stats::runif(1, 0.7, 1.3))
        start[[paste0(sp, j)]] <- clamp(bval * mult, paste0(sp, j))
      }
    }
    for (j in seq_len(k - 1)) {
      start[[paste0("w", j)]] <- stats::runif(1, 0.3, 0.7)
    }
    list(lower = lower, start = start, upper = upper, fixed = character(), free = names(ranges))
  })
}

#' @noRd
#' @description fit a k-component mixture (k == 1 is the ordinary single fit)
#' @param ranges single-population bounds (list of c(lower, start, upper))
#' @param base optional named single-population estimates used to seed starts
#' @return a fit list (see fit_nls) with stats and k, or an error string
fit_mixture <- function(m, data, k, ranges, base = NULL, max_frac = 1,
                        transform = identity, restarts = 12) {
  obs <- data[[m$response]]
  if (k == 1) {
    resolved <- resolve_params(NULL, ranges)
    pred <- function(d, p) m$predict(d, p, max_frac = max_frac, transform = transform)
    res <- fit_nls_restarts(pred, data, resolved, m$response, restarts)
    if (is.list(res)) {
      res <- add_fit_stats(res, obs, length(ranges))
      res$k <- 1L
    }
    return(res)
  }

  flat <- list()
  for (j in seq_len(k)) {
    for (nm in m$param_names) flat[[paste0(nm, j)]] <- ranges[[nm]]
  }
  for (j in seq_len(k - 1)) flat[[paste0("w", j)]] <- c(0.01, 0.5, 0.99)

  pred <- function(d, p) mixture_predict(m, d, p, k, max_frac, transform)
  base <- if (!is.null(base)) as.list(base)

  best <- NULL
  for (s in seq_len(restarts)) {
    resolved <- mixture_start(m, flat, k, base, s)
    res <- fit_nls(pred, data, resolved, m$response)
    if (is.list(res)) {
      res <- add_fit_stats(res, obs, length(flat))
      if (is.finite(res$stats$aic) && (is.null(best) || res$stats$aic < best$stats$aic)) {
        best <- res
      }
    }
  }
  if (is.null(best)) {
    return("The mixture model failed to converge; try fewer subpopulations.")
  }
  best$k <- as.integer(k)
  best
}

#' @noRd
#' @description fit k = 1..max_k subpopulations and pick the lowest AIC
detect_subpops <- function(m, data, ranges, max_k = 3, max_frac = 1,
                           transform = identity, restarts = 12) {
  base <- fit_mixture(m, data, 1L, ranges, NULL, max_frac, transform, restarts)
  if (is.character(base)) {
    cli::cli_abort(c("The {m$label} model failed to fit.", x = base), call = NULL)
  }
  fits <- list(`1` = base)
  for (k in seq_len(max_k)[-1]) {
    fits[[as.character(k)]] <- fit_mixture(
      m, data, k, ranges, base$coefficients, max_frac, transform, restarts
    )
  }
  ok <- Filter(is.list, fits)
  tbl <- tibble::tibble(
    k = as.integer(names(ok)),
    npar = vapply(ok, function(r) r$stats$npar, numeric(1)),
    pseudo_r2 = vapply(ok, function(r) r$stats$pseudo_r2, numeric(1)),
    rss = vapply(ok, function(r) r$stats$rss, numeric(1)),
    aic = vapply(ok, function(r) r$stats$aic, numeric(1))
  )
  tbl$delta_aic <- tbl$aic - min(tbl$aic)
  best_k <- tbl$k[which.min(tbl$aic)]
  list(best = fits[[as.character(best_k)]], table = tbl)
}

# Per-model wrappers around fit_pbtm() -----------------------------------------
# Each wrapper exists to give its model a discoverable name and a help page
# with the model equation; all arguments are passed through to fit_pbtm().

#' Thermal time model
#'
#' Fits the sub-optimal thermal time model, in which the thermal time to
#' germination of fraction `g`, \eqn{\theta_T(g) = (T - T_b) t_g}, is
#' log-normally distributed across the seed population:
#'
#' \deqn{g = \Phi\left(\frac{\log_{10}[(T - T_b)\, t_g] - \log_{10}\theta_{T}(50)}{\sigma}\right)}
#'
#' Use only temperatures at or below the optimum.
#'
#' @section Parameters:
#' * `t_b`: base temperature, below which germination does not occur.
#' * `theta_t50`: median thermal time (degree-time units).
#' * `sigma`: standard deviation of `log10(theta_T)` across the population.
#'
#' @param data A data frame with `GermTemp`, `CumTime`, and `CumFraction`
#'   columns (see [fit_pbtm()]).
#' @param ... Further arguments passed on to [fit_pbtm()], such as `max_frac`,
#'   `fixed`, `bounds`, `subpops`, or `cols`.
#' @return A `pbtm_fit` object; see [fit_pbtm()].
#' @family model fitting functions
#' @export
#' @examples
#' fit <- fit_thermal_time(thermal_time_data)
#' fit
#' autoplot(fit)
#' autoplot(fit, type = "normalized")
fit_thermal_time <- function(data, ...) {
  fit_pbtm(data, "thermal_time", ...)
}

#' Hydrotime model
#'
#' Fits the hydrotime model, in which the base water potential
#' \eqn{\psi_b(g) = \psi - \theta_H / t_g} is normally distributed across the
#' seed population:
#'
#' \deqn{g = \Phi\left(\frac{\psi - \theta_H / t_g - \psi_b(50)}{\sigma}\right)}
#'
#' Use data collected at a single temperature.
#'
#' @section Parameters:
#' * `theta_h`: hydrotime constant (MPa-time units).
#' * `psi_b50`: median base water potential (MPa).
#' * `sigma`: standard deviation of `psi_b` across the population (MPa).
#'
#' @param data A data frame with `GermWP`, `CumTime`, and `CumFraction`
#'   columns (see [fit_pbtm()]).
#' @inheritParams fit_thermal_time
#' @return A `pbtm_fit` object; see [fit_pbtm()].
#' @family model fitting functions
#' @export
#' @examples
#' fit <- fit_hydrotime(hydrotime_data)
#' fit
#' autoplot(fit)
fit_hydrotime <- function(data, ...) {
  fit_pbtm(data, "hydrotime", ...)
}

#' Hydrothermal time model
#'
#' Fits the hydrothermal time model, combining temperature and water potential
#' responses. The base water potential
#' \eqn{\psi_b(g) = \psi - \theta_{HT} / [(T - T_b) t_g]} is normally
#' distributed across the seed population:
#'
#' \deqn{g = \Phi\left(\frac{\psi - \theta_{HT} / [(T - T_b)\, t_g] - \psi_b(50)}{\sigma}\right)}
#'
#' @section Parameters:
#' * `theta_ht`: hydrothermal time constant (MPa-degree-time units).
#' * `t_b`: base temperature.
#' * `psi_b50`: median base water potential (MPa).
#' * `sigma`: standard deviation of `psi_b` across the population (MPa).
#'
#' @param data A data frame with `GermWP`, `GermTemp`, `CumTime`, and
#'   `CumFraction` columns (see [fit_pbtm()]).
#' @inheritParams fit_thermal_time
#' @return A `pbtm_fit` object; see [fit_pbtm()].
#' @family model fitting functions
#' @export
#' @examples
#' fit <- fit_hydrothermal_time(hydrothermal_time_data)
#' fit
#' autoplot(fit)
fit_hydrothermal_time <- function(data, ...) {
  fit_pbtm(data, "hydrothermal_time", ...)
}

#' Hydropriming model
#'
#' Fits the hydropriming model, in which the germination rate after priming
#' increases linearly with hydropriming time
#' \eqn{\theta_{HP} = (\psi - \psi_{min}) \times duration}:
#'
#' \deqn{GR = GR_i + slope \times (\psi - \psi_{min}) \times duration}
#'
#' Germination rates are computed from the time courses with [germ_speed()] at
#' the fraction given by `speed` (default 0.5, i.e. GR50).
#'
#' @section Parameters:
#' * `psi_min`: minimum priming water potential with a priming effect (MPa).
#' * `gr_i`: germination rate of unprimed seeds.
#' * `slope`: increase in germination rate per unit hydropriming time
#'   (the inverse of the hydropriming time constant).
#'
#' @param data A data frame with `TrtID`, `PrimingWP`, `PrimingDuration`,
#'   `CumTime`, and `CumFraction` columns, or a table of rates with a `GR`
#'   column (see [fit_pbtm()]).
#' @inheritParams fit_thermal_time
#' @return A `pbtm_fit` object; see [fit_pbtm()].
#' @family model fitting functions
#' @export
#' @examples
#' fit <- fit_hydropriming(hydropriming_data)
#' fit
#' autoplot(fit)
fit_hydropriming <- function(data, ...) {
  fit_pbtm(data, "hydropriming", ...)
}

#' Hydrothermal priming model
#'
#' Fits the hydrothermal priming model, in which the germination rate after
#' priming increases linearly with hydrothermal priming time
#' \eqn{\theta_{HTP} = (\psi - \psi_{min})(T - T_{min}) \times duration}:
#'
#' \deqn{GR = GR_i + slope \times (\psi - \psi_{min})(T - T_{min}) \times duration}
#'
#' @section Parameters:
#' * `t_min`: minimum priming temperature with a priming effect.
#' * `psi_min`: minimum priming water potential with a priming effect (MPa).
#' * `gr_i`: germination rate of unprimed seeds.
#' * `slope`: increase in germination rate per unit hydrothermal priming time.
#'
#' @param data A data frame with `TrtID`, `PrimingWP`, `PrimingTemp`,
#'   `PrimingDuration`, `CumTime`, and `CumFraction` columns, or a table of
#'   rates with a `GR` column (see [fit_pbtm()]).
#' @inheritParams fit_thermal_time
#' @return A `pbtm_fit` object; see [fit_pbtm()].
#' @family model fitting functions
#' @export
#' @examples
#' fit <- fit_hydrothermal_priming(hydrothermal_priming_data)
#' fit
#' autoplot(fit)
fit_hydrothermal_priming <- function(data, ...) {
  fit_pbtm(data, "hydrothermal_priming", ...)
}

#' Aging model
#'
#' Fits the seed aging model, in which germination declines as aging time
#' approaches a normally distributed maximum tolerable aging threshold
#' \eqn{p_{max}}:
#'
#' \deqn{g = 1 - \Phi\left(\frac{aging + \theta_A / t_g - p_{max}(50)}{\sigma}\right)}
#'
#' @section Parameters:
#' * `theta_a`: aging time constant.
#' * `p_max50`: median aging threshold, in the units of `AgingTime`.
#' * `sigma`: standard deviation of `p_max` across the population.
#'
#' @param data A data frame with `AgingTime`, `CumTime`, and `CumFraction`
#'   columns (see [fit_pbtm()]).
#' @inheritParams fit_thermal_time
#' @return A `pbtm_fit` object; see [fit_pbtm()].
#' @family model fitting functions
#' @export
#' @examples
#' fit <- fit_aging(aging_data)
#' fit
#' autoplot(fit)
fit_aging <- function(data, ...) {
  fit_pbtm(data, "aging", ...)
}

#' Promoter model
#'
#' Fits the germination promoter (e.g. gibberellin) dose-response model, in
#' which the threshold dose \eqn{p_b(g) = dose - \theta_P / t_g} is normally
#' distributed across the seed population:
#'
#' \deqn{g = \Phi\left(\frac{dose - \theta_P / t_g - p_b(50)}{\sigma}\right)}
#'
#' Dose responses are usually closer to linear on a log scale, so consider
#' `dose_transform = "log10"`; `dose` is then `log10(GermPromoterDosage)` and
#' `p_b50` is in log10 units.
#'
#' @section Parameters:
#' * `theta_p`: promoter time constant.
#' * `p_b50`: median threshold dose.
#' * `sigma`: standard deviation of the threshold dose across the population.
#'
#' @param data A data frame with `GermPromoterDosage`, `CumTime`, and
#'   `CumFraction` columns (see [fit_pbtm()]).
#' @inheritParams fit_thermal_time
#' @return A `pbtm_fit` object; see [fit_pbtm()].
#' @family model fitting functions
#' @export
#' @examples
#' fit <- fit_promoter(promoter_data, dose_transform = "log10")
#' fit
#' autoplot(fit)
fit_promoter <- function(data, ...) {
  fit_pbtm(data, "promoter", ...)
}

#' Inhibitor model
#'
#' Fits the germination inhibitor (e.g. abscisic acid) dose-response model, in
#' which germination declines as dose approaches a normally distributed
#' inhibitory threshold \eqn{I_b}:
#'
#' \deqn{g = 1 - \Phi\left(\frac{dose + \theta_I / t_g - I_b(50)}{\sigma}\right)}
#'
#' Consider `dose_transform = "log10"`; `dose` is then
#' `log10(GermInhibitorDosage)` and `i_b50` is in log10 units.
#'
#' @section Parameters:
#' * `theta_i`: inhibitor time constant.
#' * `i_b50`: median inhibitory threshold dose.
#' * `sigma`: standard deviation of the threshold dose across the population.
#'
#' @param data A data frame with `GermInhibitorDosage`, `CumTime`, and
#'   `CumFraction` columns (see [fit_pbtm()]).
#' @inheritParams fit_thermal_time
#' @return A `pbtm_fit` object; see [fit_pbtm()].
#' @family model fitting functions
#' @export
#' @examples
#' fit <- fit_inhibitor(inhibitor_data, dose_transform = "log10")
#' fit
#' autoplot(fit)
fit_inhibitor <- function(data, ...) {
  fit_pbtm(data, "inhibitor", ...)
}

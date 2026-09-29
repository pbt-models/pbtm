# Builds the package datasets in data/ from the CSVs in data-raw/.
# The CSVs are the sample datasets of the PBTM app (pbtm-app/data).
# Run from the package root: source("data-raw/datasets.R")

read <- function(name) {
  df <- readr::read_csv(
    file.path("data-raw", paste0(name, ".csv")),
    col_types = readr::cols(TrtDesc = "c", .default = "d"),
    progress = FALSE
  )
  tibble::as_tibble(as.data.frame(df))
}

germination_data <- read("germination_data")
thermal_time_data <- read("thermal_time_data")
thermal_time_subpop_data <- read("thermal_time_subpop_data")
hydrotime_data <- read("hydrotime_data")
hydrothermal_time_data <- read("hydrothermal_time_data")
hydropriming_data <- read("hydropriming_data")
hydrothermal_priming_data <- read("hydrothermal_priming_data")
aging_data <- read("aging_data")
promoter_data <- read("promoter_data")
inhibitor_data <- read("inhibitor_data")

# template column definitions; the model requirement flags are renamed to the
# model ids used by fit_pbtm()
pbtm_columns <- readr::read_csv(
  "data-raw/pbtm_columns.csv",
  col_types = readr::cols(Min = "d", Max = "d", .default = "c"),
  progress = FALSE
)
model_cols <- c(
  Germination = "germination",
  ThermalTime = "thermal_time",
  Hydrotime = "hydrotime",
  HydrothermalTime = "hydrothermal_time",
  Hydropriming = "hydropriming",
  HydrothermalPriming = "hydrothermal_priming",
  Aging = "aging",
  Promoter = "promoter",
  Inhibitor = "inhibitor"
)
pbtm_columns <- pbtm_columns |>
  dplyr::select(
    "Column", "Role", "Description", "LongDescription", "Type",
    "TypeDescription", "Min", "Max", dplyr::all_of(names(model_cols))
  ) |>
  dplyr::rename(dplyr::all_of(setNames(names(model_cols), model_cols))) |>
  dplyr::mutate(
    Type = dplyr::na_if(.data$Type, ""),
    dplyr::across(dplyr::all_of(unname(model_cols)), function(x) x == "T")
  )
pbtm_columns <- tibble::as_tibble(as.data.frame(pbtm_columns))

usethis::use_data(
  germination_data,
  thermal_time_data,
  thermal_time_subpop_data,
  hydrotime_data,
  hydrothermal_time_data,
  hydropriming_data,
  hydrothermal_priming_data,
  aging_data,
  promoter_data,
  inhibitor_data,
  pbtm_columns,
  overwrite = TRUE
)

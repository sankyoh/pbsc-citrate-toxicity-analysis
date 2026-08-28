required_packages <- c("haven", "MASS", "firthb")
missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]
if (length(missing_packages) > 0L) {
  stop(
    "Missing required R packages: ", paste(missing_packages, collapse = ", "),
    ". See README.md for installation instructions."
  )
}
required_versions <- c(haven = "2.5.5", MASS = "7.3-65", firthb = "2.2-1")
installed_versions <- vapply(
  names(required_versions),
  function(package) utils::packageDescription(package)$Version,
  character(1)
)
if (!identical(unname(installed_versions), unname(required_versions))) {
  warning(
    "Validated package versions are ",
    paste(names(required_versions), required_versions, sep = " ", collapse = ", "),
    "; installed versions are ",
    paste(names(installed_versions), installed_versions, sep = " ", collapse = ", "),
    "."
  )
}

data_path <- Sys.getenv(
  "PBSC_DATA_PATH",
  unset = file.path("analysis", "data_clean", "df02_clean.dta")
)
output_dir <- Sys.getenv(
  "PBSC_OUTPUT_DIR",
  unset = file.path("analysis", "output")
)

if (!file.exists(data_path)) {
  stop(
    "Analytic dataset not found: ", data_path,
    ". Set PBSC_DATA_PATH to an authorized compatible df02_clean.dta file."
  )
}
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

d <- as.data.frame(haven::read_dta(data_path))
required_variables <- c(
  "grade_cat2", "combine3", "sex", "age", "height", "weight", "tbv",
  "flow_rate", "inf_rate", "pre_cd34", "time", "acd", "proc_vol",
  "gluconate", "tp", "alb", "i_ca_pre", "i_k_pre", "i_ca_min", "i_k_min"
)
missing_variables <- setdiff(required_variables, names(d))
if (length(missing_variables) > 0L) {
  stop("Required variables are missing: ", paste(missing_variables, collapse = ", "))
}

d$outcome <- as.integer(d$grade_cat2)
d$combine3_f <- factor(
  as.integer(d$combine3),
  levels = c(0L, 1L, 2L),
  labels = c("Neither", "Either alone", "Concurrent")
)
d$sex <- as.numeric(d$sex)
d$age_z <- (as.numeric(d$age) - mean(as.numeric(d$age))) / stats::sd(as.numeric(d$age))
d$tbv_z <- (as.numeric(d$tbv) - mean(as.numeric(d$tbv))) / stats::sd(as.numeric(d$tbv))
d$i_ca_01 <- as.numeric(d$i_ca_min) * 10
d$i_k_01 <- as.numeric(d$i_k_min) * 10

analysis_variables <- c(
  "outcome", "combine3_f", "sex", "age_z", "tbv_z", "i_ca_01", "i_k_01"
)
stopifnot(
  nrow(d) == 42L,
  sum(d$outcome == 1L) == 5L,
  all(d$outcome %in% c(0L, 1L)),
  !anyNA(d[analysis_variables]),
  identical(as.integer(table(d$combine3_f)), c(29L, 8L, 5L)),
  identical(as.integer(table(d$combine3_f, d$outcome)[, "1"]), c(1L, 2L, 2L))
)

p_from_rr_ci <- function(rr, ci_low, ci_high) {
  se <- (log(ci_high) - log(ci_low)) / (2 * stats::qnorm(0.975))
  2 * stats::pnorm(-abs(log(rr) / se))
}

fit_firth <- function(formula, model_label) {
  warnings <- character()
  fit <- withCallingHandlers(
    firthb::firthb(formula, data = d, measure = "RR"),
    warning = function(w) {
      warnings <<- c(warnings, conditionMessage(w))
      invokeRestart("muffleWarning")
    }
  )
  if (length(warnings) > 0L) {
    stop("firthb warning in ", model_label, ": ", paste(unique(warnings), collapse = " | "))
  }
  result <- fit[["firth+improved robust SE"]]
  terms <- colnames(stats::model.matrix(formula, d))
  data.frame(
    model = model_label,
    term = terms,
    rr = result$EstimatedRR,
    ci_low = result$Low95pctCI,
    ci_high = result$Upp95pctCI,
    stringsAsFactors = FALSE
  )
}

assert_close <- function(observed, expected, tolerance = 5e-4, label = "result") {
  if (length(observed) != length(expected) || any(abs(observed - expected) > tolerance)) {
    stop(label, " did not match the validated expected values.")
  }
}

write_result <- function(x, filename) {
  utils::write.csv(
    x,
    file.path(output_dir, filename),
    row.names = FALSE,
    na = "",
    fileEncoding = "UTF-8"
  )
}

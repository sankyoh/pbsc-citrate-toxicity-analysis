source(file.path("analysis", "R", "common.R"))

group_levels <- levels(d$combine3_f)

format_mean_sd <- function(x, digits) {
  if (anyNA(x)) stop("Missing values are not expected in final descriptive tables.")
  round_half_up <- function(value, digits) {
    scale <- 10^digits
    sign(value) * floor(abs(value) * scale + 0.5 + 1e-10) / scale
  }
  sprintf(
    paste0("%.", digits, "f ± %.", digits, "f"),
    round_half_up(mean(as.numeric(x)), digits),
    round_half_up(stats::sd(as.numeric(x)), digits)
  )
}

continuous_row <- function(variable, label, digits) {
  values <- vapply(
    group_levels,
    function(group) format_mean_sd(d[[variable]][d$combine3_f == group], digits),
    character(1)
  )
  data.frame(
    variable = label,
    neither = values[["Neither"]],
    either_alone = values[["Either alone"]],
    concurrent = values[["Concurrent"]],
    stringsAsFactors = FALSE
  )
}

female_row <- function() {
  values <- vapply(group_levels, function(group) {
    x <- d$sex[d$combine3_f == group]
    if (anyNA(x)) stop("Missing sex values are not expected.")
    sprintf("%d (%.1f)", sum(x == 0), 100 * mean(x == 0))
  }, character(1))
  data.frame(
    variable = "Female sex, n (%)",
    neither = values[["Neither"]],
    either_alone = values[["Either alone"]],
    concurrent = values[["Concurrent"]],
    stringsAsFactors = FALSE
  )
}

table1_specs <- list(
  c("age", "Age, years", 1),
  c("height", "Height, cm", 1),
  c("weight", "Body weight, kg", 1),
  c("tbv", "Total blood volume, mL", 0),
  c("pre_cd34", "Pre-apheresis CD34+ count, /uL", 1),
  c("i_ca_pre", "Ionized calcium at the start of apheresis, mmol/L", 2),
  c("i_k_pre", "Ionized potassium at the start of apheresis, mmol/L", 2),
  c("tp", "Total protein, g/dL", 2),
  c("alb", "Albumin, g/dL", 2)
)
table2_specs <- list(
  c("flow_rate", "Maximum blood flow, mL/min", 1),
  c("inf_rate", "ACD-A infusion rate, mL/min", 2),
  c("time", "Processing time, min", 1),
  c("acd", "Total ACD-A volume, mL", 0),
  c("proc_vol", "Processed blood volume, mL", 0),
  c("gluconate", "Calcium gluconate administered, mg", 0)
)

build_rows <- function(specs) {
  do.call(rbind, lapply(specs, function(spec) {
    continuous_row(spec[[1]], spec[[2]], as.integer(spec[[3]]))
  }))
}

table1 <- rbind(female_row(), build_rows(table1_specs))
table2 <- build_rows(table2_specs)

expected_table1 <- c(
  "9 (31.0)|2 (25.0)|4 (80.0)",
  "31.5 ± 11.5|43.6 ± 13.1|49.0 ± 8.0",
  "166.8 ± 9.6|170.8 ± 10.8|159.8 ± 12.0",
  "64.2 ± 12.1|72.3 ± 17.6|59.8 ± 13.5",
  "4261 ± 809|4669 ± 944|3716 ± 941",
  "51.9 ± 30.4|45.0 ± 36.2|30.8 ± 18.8",
  "1.26 ± 0.05|1.23 ± 0.03|1.20 ± 0.04",
  "3.72 ± 0.17|3.88 ± 0.32|3.70 ± 0.19",
  "6.37 ± 0.37|6.59 ± 0.33|6.26 ± 0.44",
  "3.94 ± 0.28|4.01 ± 0.20|3.88 ± 0.33"
)
expected_table2 <- c(
  "68.6 ± 9.7|75.2 ± 11.1|62.8 ± 7.9",
  "1.29 ± 0.13|1.34 ± 0.12|1.40 ± 0.14",
  "214.7 ± 54.4|232.1 ± 59.7|270.8 ± 67.6",
  "1002 ± 290|1246 ± 416|1188 ± 245",
  "11823 ± 3497|14365 ± 4909|13822 ± 3316",
  "7082 ± 1924|8153 ± 2708|9676 ± 3189"
)

observed_table1 <- apply(table1[c("neither", "either_alone", "concurrent")], 1, paste, collapse = "|")
observed_table2 <- apply(table2[c("neither", "either_alone", "concurrent")], 1, paste, collapse = "|")
stopifnot(identical(unname(observed_table1), expected_table1))
stopifnot(identical(unname(observed_table2), expected_table2))

write_result(table1, "table1_descriptive.csv")
write_result(table2, "table2_descriptive.csv")

cat("DESCRIPTIVE_TABLES_COMPLETE=1\n")

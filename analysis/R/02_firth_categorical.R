source(file.path("analysis", "R", "common.R"))

crude <- fit_firth(outcome ~ combine3_f, "Crude")
adjusted <- fit_firth(
  outcome ~ combine3_f + age_z + sex + tbv_z,
  "Adjusted"
)

exposure_terms <- c("combine3_fEither alone", "combine3_fConcurrent")
results <- rbind(crude, adjusted)
results <- results[results$term %in% exposure_terms, ]
results$exposure <- ifelse(
  results$term == "combine3_fEither alone",
  "Either alone vs Neither",
  "Concurrent vs Neither"
)
results$p_value <- p_from_rr_ci(results$rr, results$ci_low, results$ci_high)
results$analysis_role <- ifelse(
  results$model == "Adjusted",
  "Primary revised analysis",
  "Supporting crude revised analysis"
)
results$estimator <- "Firth-type modified Poisson"
results$variance_method <- "Improved robust sandwich variance"
results$p_value_source <- "Wald z test reconstructed from RR and improved robust 95% CI"
results <- results[c(
  "analysis_role", "model", "exposure", "estimator", "variance_method",
  "rr", "ci_low", "ci_high", "p_value", "p_value_source"
)]
results <- results[
  order(match(results$model, c("Crude", "Adjusted")),
        match(results$exposure, c("Either alone vs Neither", "Concurrent vs Neither"))),
]
rownames(results) <- NULL

assert_close(results$rr, c(6.042, 9.667, 4.038, 5.472), label = "Categorical RRs")
assert_close(results$ci_low, c(1.033, 1.744, 0.904, 1.126), label = "Categorical lower CIs")
assert_close(results$ci_high, c(35.322, 53.569, 18.028, 26.590), label = "Categorical upper CIs")
assert_close(results$p_value, c(0.046, 0.009, 0.068, 0.035), tolerance = 5e-4, label = "Categorical p-values")

write_result(results, "table3_firth_categorical.csv")
cat("FIRTH_CATEGORICAL_COMPLETE=1\n")

source(file.path("analysis", "R", "common.R"))

crude <- fit_firth(outcome ~ i_ca_01 + i_k_01, "Crude")
adjusted <- fit_firth(
  outcome ~ i_ca_01 + i_k_01 + age_z + sex + tbv_z,
  "Adjusted"
)

exposure_terms <- c("i_ca_01", "i_k_01")
results <- rbind(crude, adjusted)
results <- results[results$term %in% exposure_terms, ]
results$exposure <- ifelse(
  results$term == "i_ca_01",
  "Minimum ionized calcium per 0.1 mmol/L increase",
  "Minimum ionized potassium per 0.1 mmol/L increase"
)
results$p_value <- p_from_rr_ci(results$rr, results$ci_low, results$ci_high)
results$analysis_role <- "Continuous-exposure sensitivity analysis"
results$estimator <- "Firth-type modified Poisson"
results$variance_method <- "Improved robust sandwich variance"
results$p_value_source <- "Wald z test reconstructed from RR and improved robust 95% CI"
results <- results[c(
  "analysis_role", "model", "exposure", "estimator", "variance_method",
  "rr", "ci_low", "ci_high", "p_value", "p_value_source"
)]
results <- results[
  order(match(results$model, c("Crude", "Adjusted")),
        match(results$exposure, c(
          "Minimum ionized calcium per 0.1 mmol/L increase",
          "Minimum ionized potassium per 0.1 mmol/L increase"
        ))),
]
rownames(results) <- NULL

assert_close(results$rr, c(0.370, 1.134, 0.462, 1.244), label = "Continuous RRs")
assert_close(results$ci_low, c(0.205, 0.667, 0.264, 0.834), label = "Continuous lower CIs")
assert_close(results$ci_high, c(0.668, 1.929, 0.807, 1.855), label = "Continuous upper CIs")
assert_close(results$p_value, c(0.001, 0.641, 0.007, 0.284), tolerance = 2e-3, label = "Continuous p-values")

write_result(results, "table4_firth_continuous.csv")
cat("FIRTH_CONTINUOUS_COMPLETE=1\n")

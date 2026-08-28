scripts <- c(
  file.path("analysis", "R", "01_descriptive_tables.R"),
  file.path("analysis", "R", "02_firth_categorical.R"),
  file.path("analysis", "R", "03_firth_continuous.R")
)

for (script in scripts) {
  cat("Running ", script, "\n", sep = "")
  source(script, local = new.env(parent = globalenv()))
}

output_dir <- Sys.getenv("PBSC_OUTPUT_DIR", unset = file.path("analysis", "output"))
writeLines(
  capture.output(sessionInfo()),
  file.path(output_dir, "sessionInfo.txt"),
  useBytes = TRUE
)

cat("PBSC_R_WORKFLOW_COMPLETE=1\n")

# pbsc-citrate-toxicity-analysis
Statistical analysis for "Concurrent severe hypocalcemia and hypokalemia are associated with clinically significant citrate toxicity during peripheral blood stem cell collection: a secondary analysis of a prospective study"

This repository contains selected Stata do-files produced as part of statistical analysis support for a secondary analysis of a prospective study of healthy peripheral blood stem cell (PBSC) donors.

## Study

**Concurrent severe hypocalcemia and hypokalemia are associated with clinically significant citrate toxicity during peripheral blood stem cell collection: a secondary analysis of a prospective study**

## Analysis overview

The analysis evaluated whether concurrent severe hypocalcemia and hypokalemia during PBSC collection were associated with clinically significant citrate toxicity.

The primary outcome was Grade 2 or higher citrate toxicity. Severe hypocalcemia was defined as minimum ionized calcium level <= 1.0 mmol/L. Hypokalemia was defined as minimum potassium level <= 3.0 mmol/L.

Donors were classified into three groups: no electrolyte decrease, decrease in either electrolyte alone, and concurrent decreases in both electrolytes. Risk ratios were estimated using modified Poisson regression with robust standard errors. Crude and adjusted models were fitted. The adjusted model included age, sex, and total blood volume.

## Files

### `analysis/master.do`

Runs the analysis scripts in order.

### `analysis/000_config.do`

Sets the Stata version, project paths, and common options.

### `analysis/do/010_import.do`

Imports the source Excel file and saves the raw Stata dataset.

### `analysis/do/020_clean.do`

Checks IDs, trims string variables, recodes sex, renames variables, adds labels, checks missingness, and saves the cleaned dataset.

### `analysis/do/030_define_vars.do`

Creates outcome and exposure variables. The main outcome is Grade 2 or higher citrate toxicity. Exposure variables include severe ionized calcium decrease, potassium decrease, and combined electrolyte-decrease groups.

### `analysis/do/040_DesStat.do`

Creates descriptive tables by ionized calcium decrease and potassium decrease using `make_table1.ado`.

### `analysis/do/050_RRanalysis.do`

Runs an earlier modified Poisson regression analysis and sensitivity analyses. This file is retained for documentation.

### `analysis/do/051_RRanalysis260606.do`

Runs the main risk-ratio analysis using the three-level combined electrolyte-decrease variable. It also performs sensitivity analyses using continuous ionized calcium and potassium values in the same model.

### `analysis/ado/make_table1.ado`

Defines a utility command to create descriptive Table 1 outputs using Stata `dtable`.

### `variable_list.md`

Lists variables used in the analysis do-files, including outcome, exposure, adjustment, descriptive, and output variables.

## Notes

- Patient-level data are not included.
- Original file names and potentially identifiable information were masked before public release.
- Some scripts require the original or a compatible de-identified input dataset to run.
- This repository contains Stata do-files from statistical analysis support conducted by Toshiharu Mitsuhashi for the study.
- The do-files are provided for documentation and reproducibility of the statistical support process.

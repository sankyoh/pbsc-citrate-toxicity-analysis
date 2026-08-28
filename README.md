[![DOI](https://zenodo.org/badge/1287104560.svg)](https://doi.org/10.5281/zenodo.21132152)

# PBSC citrate-toxicity analysis

Version 1.1.0 contains the final Stata and R analysis code for the secondary
analysis of citrate toxicity among healthy peripheral blood stem cell donors.
Participant-level data are not included.

## Study

**Concurrent marked hypocalcemia and hypokalemia are associated with clinically
significant citrate toxicity during peripheral blood stem cell collection: a
secondary analysis of a prospective study**

The primary outcome was Grade 2 or higher citrate toxicity. The electrolyte
thresholds were defined post hoc for this exploratory secondary analysis:

- marked hypocalcemia: minimum ionized calcium <=1.0 mmol/L;
- marked hypokalemia: minimum ionized potassium <=3.0 mmol/L.

The three exposure groups were Neither, Either alone, and Concurrent. The
validated analytic dataset contained 42 donors and five outcome events; group
sizes were 29, 8, and 5, with 1, 2, and 2 events, respectively.

## Final analysis hierarchy

1. The primary analysis is the age-, sex-, and total-blood-volume-adjusted
   Firth-type modified Poisson model with the improved robust sandwich variance
   estimator implemented by `firthb`.
2. The crude Firth-type model is a supporting revised analysis.
3. Conventional modified Poisson models with robust standard errors are
   method-sensitivity analyses.
4. The continuous-exposure analysis includes minimum ionized calcium and
   minimum ionized potassium simultaneously. No interaction term is fitted.

The small cohort and five events require cautious interpretation. These files
do not establish a causal potassium effect or a clinical intervention threshold.

## Software

The validated environment was:

- StataNow 19.5/MP, with `version 19.0` declared in the scripts;
- R 4.5.1;
- `firthb` 2.2-1;
- MASS 7.3-65;
- haven 2.5.5.

The complete validated R session record is preserved in
`analysis/R/sessionInfo_reference.txt`.

`firthb` is not included in this repository. Download the authors' version
2.2-1 source archive from:

<https://raw.githubusercontent.com/nomahi/firthb/main/firthb_2.2-1.tar.gz>

Expected SHA-256:

```text
0AA612B4A623AE29235E1466405527BBB85DB8C40D45E88C8C3338FEDD8522B9
```

Install the verified archive with:

```r
install.packages("firthb_2.2-1.tar.gz", repos = NULL, type = "source")
```

`firthb` is distributed by its authors under GPL-3. This repository does not
redistribute that package; the analysis scripts in this repository remain under
the existing MIT license.

## Reproduction

### 1. Provide authorized input data

The private source data are available from the corresponding author upon
reasonable request. Place authorized compatible inputs under `analysis/data_raw`
or set paths as described below. Do not commit data to this repository.

### 2. Stata workflow

Run Stata from the `analysis` directory:

```stata
do master.do
```

This imports and cleans the source data, creates the final outcome and exposure
variables, and runs the conventional modified Poisson method-sensitivity
analyses. The placeholder source workbook name in `010_import.do` must be
replaced locally with the authorized workbook filename.

### 3. R workflow

From the repository root, either place the analytic dataset at
`analysis/data_clean/df02_clean.dta` or set `PBSC_DATA_PATH`. Then run:

```text
Rscript analysis/R/run_all.R
```

Generated CSV files and `sessionInfo.txt` are written to `analysis/output`, or
to the directory set by `PBSC_OUTPUT_DIR`. Generated outputs are intentionally
excluded from the public release.

The R workflow stops unless these checks pass:

- N=42 and events=5;
- group sizes=29/8/5;
- group-specific events=1/2/2;
- no missing values in the model variables;
- reported RR, 95% CI, p-value, and descriptive-table displays agree with the
  validated final results within their stated reporting precision.

Descriptive means and standard deviations use decimal half-up rounding to
reproduce the manuscript table displays. This is stated explicitly because R's
default tie-breaking rule is round-to-even.

## Model details

For numerical stability, age and total blood volume are standardized within the
42-person analytic sample using the sample standard deviation:

```text
age_z = (age - mean(age)) / SD(age)
tbv_z = (TBV - mean(TBV)) / SD(TBV)
```

For the continuous analysis:

```text
iCa_01 = 10 * minimum ionized calcium
iK_01  = 10 * minimum ionized potassium
```

Therefore the continuous RRs are expressed per 0.1 mmol/L increase. `firthb`
does not directly return p-values. Two-sided Wald p-values are reconstructed
from each RR and improved robust 95% CI as follows:

```text
SE = [log(upper CI) - log(lower CI)] / [2 * qnorm(0.975)]
z  = log(RR) / SE
p  = 2 * pnorm(-abs(z))
```

## Released files

- `analysis/master.do`: Stata execution entry point.
- `analysis/000_config.do`: Stata version and relative paths.
- `analysis/do/010_import.do`: private source workbook import.
- `analysis/do/020_clean.do`: cleaning and variable renaming.
- `analysis/do/030_define_final_vars.do`: final outcome and three-group exposure.
- `analysis/do/051_RRanalysis260606.do`: conventional method-sensitivity analyses.
- `analysis/R/01_descriptive_tables.R`: final three-group Tables 1 and 2.
- `analysis/R/02_firth_categorical.R`: categorical Firth-type analysis for Table 3.
- `analysis/R/03_firth_continuous.R`: continuous Firth-type analysis for Table 4.
- `analysis/R/run_all.R`: R execution entry point.
- `analysis/R/sessionInfo_reference.txt`: validated R/package environment.
- `variable_list.md`: required variable definitions.

Superseded exploratory analyses, participant-level data, logs, manuscript and
review files, and generated outputs are not included.

## Citation and license

The DOI badge links to the existing Zenodo concept DOI, which represents all
versions. Cite the version-specific Zenodo DOI when citing the exact code used
for the revised manuscript. The version 1.1.0 DOI will be assigned by Zenodo
after publication and is not guessed in this pre-release tree.

The repository is licensed under the MIT License. See `LICENSE`.

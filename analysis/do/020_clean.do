****************************************************
* 020_clean.do
* Purpose: Prepare an analysis-ready dataset and save it
* * df00.dta -> df01_clean.dta
****************************************************

* 0) Open a log file
cap log close
log using "$LOG\log_020_clean.smcl", replace

* 1) Input and output data files
local read_file  "$RAW\df00.dta"
local write_file "$CLEAN\df01_clean.dta"

use "`read_file'", clear

****************************************************
* 0) ID check
****************************************************

* Check whether patient_id has missing values
// Stop here if missing values are found.
count if missing(patient_id)
assert patient_id!=.

* Check whether patient_id is unique (duplicates would invalidate subsequent analyses)
// Stop here if duplicate IDs are found.
isid patient_id

****************************************************
* 1) Trim string variables
****************************************************
// Remove extra spaces that may have been introduced during data import.
// Convert string variables to numeric variables when possible.
quietly ds, has(type string)
local strings `r(varlist)'
foreach v of local strings {
	replace `v' = strtrim(`v') if !missing(`v')
	cap noisily destring `v', replace
}


****************************************************
* 2) Recode sex
****************************************************
gen byte sex = (性別=="M") if inlist(性別,"F","M")
label define sex 0 "Female" 1 "Male", replace
label values sex sex
label variable sex "性別"
order sex, after(性別)
tab 性別 sex
drop 性別

****************************************************
* 3) Shorten long variable names and add labels
* Variable-renaming rules were reviewed and partially edited.
* De-identified: external reference removed.
****************************************************
rename 年齢             age
rename HT              height
rename BW              weight
rename TBV             tbv

rename 流量            flow_rate
rename 注入率          inf_rate
rename preCD34         pre_cd34
rename 時間            time
rename ACD             acd
rename 処理量          proc_vol
rename Gluconate       gluconate
rename Ca換算          ca_eq
rename TP              tp
rename Alb             alb

rename 血清Ca_前        s_ca_pre
rename 血清Ca_後        s_ca_post
rename 血清Ca_翌日      s_ca_nextday

rename 血清IP_前        s_ip_pre
rename 血清IP_後        s_ip_post
rename sIP低下率        s_ip_drop_pct

rename 血清Na_前        s_na_pre
rename 血清Na_後        s_na_post
rename sNa低下率        s_na_drop_pct

rename 血清K_前         s_k_pre
rename 血清K_後         s_k_post
rename sK低下率         s_k_drop_pct

rename 血清Mg_前        s_mg_pre
rename 血清Mg_後        s_mg_post
rename sMg低下率        s_mg_drop_pct

rename iCa_前           i_ca_pre
rename iCa_後           i_ca_post
rename iCa低下率         i_ca_drop_pct
rename iCa_最低値        i_ca_min

rename iK_前            i_k_pre
rename iK_後            i_k_post
rename iK低下率          i_k_drop_pct
rename iK_最低値         i_k_min

rename 評価項目          grade

rename AV               i_ca_drop_pct_max
rename AW               i_k_drop_pct_max

* --- variable labels (use original long names as labels) ---
label variable patient_id "patient_id"
label variable i_ca_drop_pct_max "最大iCa低下率_最大値"
label variable i_k_drop_pct_max  "最大iK低下率_最大値"
label variable pre_cd34 "pre CD34"

****************************************************
* 4) Labels for Boolean variables
****************************************************
/* Not needed */

****************************************************
* 5) Sanity Check Lv2: Pre-analysis checks
****************************************************
* Check variable types
des

/* Confirm that binary variables are coded as 0/1. Stop otherwise.
su `boolvars' 
foreach v of local boolvars {
	* Assign value labels (0/1)
	assert `v'==0 | `v'==1
} */

* Confirm that sex is also coded as 0/1. Stop otherwise.
assert sex==0 | sex==1

* Age: plausible range 18-120
gen byte age_outlier = (age < 18 | age > 120) if !missing(age)
label variable age_outlier "Age out of plausible range (18-120)"
tab age_outlier, missing
su age if age_outlier == 1


****************************************************
* 6) Summarize missingness
****************************************************
* At this stage, summarize missingness only; do not handle missing values yet.
misstable summarize

/* Create missingness indicators
foreach v in bmi sbp fev1 cv_time {
    gen byte miss_`v' = missing(`v')         // 1 if missing
    label values miss_`v' miss01
    label variable miss_`v' "`v' missingness"
} */

****************************************************
* 7) Save
****************************************************
* Final check
codebook 

compress
label data "Cleaned data"
save "`write_file'", replace

di "=== Clean done ==="

cap log close
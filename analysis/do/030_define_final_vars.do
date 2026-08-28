****************************************************
* 030_define_final_vars.do
* Purpose: Create the final outcome and exposure variables
* df01_clean.dta -> df02_clean.dta
****************************************************

version 19.0

cap log close
log using "$LOG/log_030_define_final_vars.smcl", replace

local read_file  "$CLEAN/df01_clean.dta"
local write_file "$CLEAN/df02_clean.dta"

use "`read_file'", clear

* Primary outcome: Grade 2 or higher citrate toxicity
label define ny 0 "No" 1 "Yes", replace
gen byte grade_cat2 = (grade >= 2) if inrange(grade, 0, 4)
label variable grade_cat2 "Grade 2 or higher citrate toxicity"
label values grade_cat2 ny

* Post hoc marked electrolyte thresholds used in the final analysis
gen byte i_ca_bin = (i_ca_min <= 1.0) if !missing(i_ca_min)
gen byte i_k_bin  = (i_k_min <= 3.0) if !missing(i_k_min)
label variable i_ca_bin "Minimum ionized calcium <=1.0 mmol/L"
label variable i_k_bin  "Minimum ionized potassium <=3.0 mmol/L"

gen byte combine3 = 0 if i_ca_bin == 0 & i_k_bin == 0
replace combine3 = 1 if (i_ca_bin == 1 & i_k_bin == 0) | ///
                        (i_ca_bin == 0 & i_k_bin == 1)
replace combine3 = 2 if i_ca_bin == 1 & i_k_bin == 1
label define combine3 0 "Neither" 1 "Either alone" 2 "Concurrent", replace
label values combine3 combine3

* Final analytic checks
assert inlist(grade_cat2, 0, 1)
assert inlist(i_ca_bin, 0, 1)
assert inlist(i_k_bin, 0, 1)
assert inlist(combine3, 0, 1, 2)
assert !missing(grade_cat2, i_ca_bin, i_k_bin, combine3)
count
assert r(N) == 42
count if grade_cat2 == 1
assert r(N) == 5

compress
label data "Analysis-ready data with final derived variables"
save "`write_file'", replace

di "=== Final variables defined ==="
cap log close

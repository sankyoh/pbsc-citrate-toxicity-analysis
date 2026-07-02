****************************************************
* 030_define_vars.do
* Purpose: Create variables needed for analysis
* * df01_clean.dta -> df02_clean.dta
****************************************************

* 0) Open a log file
cap log close
log using "$LOG\log_030_define_vars.smcl", replace

* 1) Input and output data files
local read_file  "$CLEAN\df01_clean.dta"
local write_file "$CLEAN\df02_clean.dta"

use "`read_file'", clear

****************************************************
* 1) Define outcome variables
****************************************************
label define ny 0 "No" 1 "Yes"
gen grade_cat2 = (grade>=2) if inrange(grade, 0, 4)
gen grade_cat1 = (grade>=1) if inrange(grade, 0, 4)
label variable grade_cat1 "1 if Grade>=1"
label variable grade_cat2 "1 if Grade>=2"
label values   grade_cat1 ny
label values   grade_cat2 ny

****************************************************
* 2) Define exposure variables
****************************************************

label define decline 0 "no decline" 1 "decline"
gen i_ca_bin = (i_ca_min<=1.0) if !missing(i_ca_min)
label variable i_ca_bin "iCa最低値, 低下有無"
label values i_ca_bin decline

gen i_k_bin = (i_k_min<=3.0) if !missing(i_k_min)
label variable i_k_bin "iK最低値, 低下有無"
label values i_k_bin decline

gen     combine4 = 0 if i_ca_bin==0 & i_k_bin==0
replace combine4 = 1 if i_ca_bin==0 & i_k_bin==1
replace combine4 = 2 if i_ca_bin==1 & i_k_bin==0
replace combine4 = 3 if i_ca_bin==1 & i_k_bin==1
label define combine4 0 "no decline" 1 "only k decline" 2 "only ca decline" 3 "both decline"
label values combine4 combine4

gen     combine3 = 0 if  i_ca_bin==0 & i_k_bin==0
replace combine3 = 1 if (i_ca_bin==0 & i_k_bin==1) | i_ca_bin==1 & i_k_bin==0
replace combine3 = 2 if  i_ca_bin==1 & i_k_bin==1
label define combine3 0 "no decline" 1 "one decline" 2 "both decline"
label values combine3 combine3




/* Definitions used in January 2026
su i_ca_min, detail
local iCa_thr = r(p25)
gen seviCa = (i_ca_min <= r(p25)) if !missing(i_ca_min)
label variable seviCa "Severe iCa"
label values seviCa ny

su i_k_min, detail
local iK_thr = r(p25)
gen seviK = (i_k_min <= r(p25)) if !missing(i_k_min)
label variable seviK "Severe iK"
label values seviK ny

su s_mg_drop_pct, detail
gen sevMgdrop = (s_mg_drop_pct >= r(p75)) if !missing(s_mg_drop_pct)
label variable sevMgdrop "Severe Mg drop"
label values sevMgdrop ny

su s_ip_drop_pct, detail
gen sevPdrop = (s_ip_drop_pct >= r(p75)) if !missing(s_ip_drop_pct)
label variable sevPdrop "Severe iP drop"
label values sevPdrop ny

gen sevComp      = seviCa + seviK + sevMgdrop + sevPdrop
forvalues x=1/4 {
	gen sevComp_bin`x' = (sevComp>=`x') if !missing(sevComp)
	label variable sevComp_bin`x' "1 if sevComp >= `x'"
	label values   sevComp_bin`x' ny
}

***** [ADD] Focus only on iCa and iK

gen dualSev = (i_ca_min <= `iCa_thr' & i_k_min <= `iK_thr')  if !missing(i_ca_min, i_k_min)
label variable dualSev "Dual Severe"
label values   dualSev ny

***** [ADD] iCa≤1.0, K≤3.0

gen dualSev2 = (i_ca_min <= 1.0 & i_k_min <= 3.0)  if !missing(i_ca_min, i_k_min)
label variable dualSev2 "Dual Severe, iCa≤1.0, K≤3.0"
label values   dualSev2 ny
*/

****************************************************
* 7) Save
****************************************************
* Final check
codebook 

compress
label data "Cleaned data with derived variables"
save "`write_file'", replace

di "=== Clean done ==="

cap log close
****************************************************
* 050_RRanalysis.do
* Purpose: Estimate risk ratios
* * df02_clean.dta -> RRresults.xlsx
****************************************************

cap log close
log using "$LOG\log_040_RRanalysis.smcl", replace

* 1) Input and output data files
local read_file  "$CLEAN\df02_clean.dta"
local write_file "$OUT\RRresults.xlsx"

use "`read_file'", clear

/***************************************************
a) Fit modified Poisson regression under the following conditions
Exposure  : sevComp_bin2
Outcome   : grade_cat2
Confounder: age sex tbv

b) Sensitivity analysis: change the exposure-variable threshold
Exposure  : sevComp_bin1, sevComp_bin3

c) Sensitivity analysis: analyze each electrolyte as a continuous variable.
Exposure  : i_ca_min, i_k_min, s_mg_drop_pct, s_ip_drop_pct

---

1) Define the postfile
2) Run poisson -> lincom -> obtain the point estimate, lower confidence limit, upper confidence limit, and p-value
3) Write results using post
4) Proceed to the next analysis.
5) postclose

***************************************************/
* 0) Preparation
****************************************************
local covars0             // Adjustment variables for the crude model; intentionally blank
local covars1 age sex tbv // Adjustment variables for the adjusted model



****************************************************
* 1) Prepare the postfile for storing results
****************************************************
tempname memhold
tempfile results

postfile `memhold' ///
	str20 exposure ///
	float cRR cCI_l cCI_u cPv ///
	float aRR aCI_l aCI_u aPv ///
	using "`results'", replace
	
****************************************************
* 2) Run the main analysis
****************************************************

forvalues m = 0/1 {	
	capture noisily poisson grade_cat2 sevComp_bin2 `covars`m'',robust irr
	if !_rc {
		capture noisily lincom sevComp_bin2, eform level(95)
		if !_rc {
			local b`m'   = r(estimate)
			local lb`m'  = r(lb)
			local ub`m'  = r(ub)
			local pv`m'  = r(p)
		}
		else {
			local b`m'   = .
			local se`m'  = .
			local lb`m'  = .
			local ub`m'  = .
		}
	}
 
}
post `memhold' ("sevComp_bin2") ///
		(`b0') (`lb0') (`ub0') (`pv0') ///
		(`b1') (`lb1') (`ub1') (`pv1') 

****************************************************
* 3) Sensitivity analysis: change the exposure-variable threshold
****************************************************
forvalues sev=1(2)3 {
	forvalues m = 0/1 {	
		capture noisily poisson grade_cat2 sevComp_bin`sev' `covars`m'',robust irr
		if !_rc {
			capture noisily lincom sevComp_bin`sev', eform level(95)
			if !_rc {
				local b`m'   = r(estimate)
				local lb`m'  = r(lb)
				local ub`m'  = r(ub)
				local pv`m'  = r(p)
			}
			else {
				local b`m'   = .
				local se`m'  = .
				local lb`m'  = .
				local ub`m'  = .
			}
		}
	 
	}
	post `memhold' ("sevComp_bin`sev'") ///
		(`b0') (`lb0') (`ub0') (`pv0') ///
		(`b1') (`lb1') (`ub1') (`pv1') 
}


****************************************************
* 4) Sensitivity analysis: analyze each electrolyte as a continuous variable.
****************************************************
local contexp i_ca_min i_k_min s_mg_drop_pct s_ip_drop_pct dualSev dualSev2
foreach expv of local contexp {
	forvalues m = 0/1 {	
		capture noisily poisson grade_cat2 `expv' `covars`m'',robust irr
		if !_rc {
			capture noisily lincom `expv', eform level(95)
			if !_rc {
				local b`m'   = r(estimate)
				local lb`m'  = r(lb)
				local ub`m'  = r(ub)
				local pv`m'  = r(p)
			}
			else {
				local b`m'   = .
				local se`m'  = .
				local lb`m'  = .
				local ub`m'  = .
			}
		}
	 
	}
	post `memhold' ("`expv'") ///
		(`b0') (`lb0') (`ub0') (`pv0') ///
		(`b1') (`lb1') (`ub1') (`pv1') 
}




postclose `memhold'

****************************************************
* 5) Output results
****************************************************
use `results', clear
list, sep(0)

export excel using "`write_file'", sheet("Risk Ratio") first(varlabels) replace
exit
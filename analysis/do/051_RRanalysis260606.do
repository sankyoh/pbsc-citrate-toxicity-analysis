****************************************************
* 051_RRanalysis260606.do
* Purpose: Conventional modified Poisson method-sensitivity analyses
* df02_clean.dta -> RRresults_v2.xlsx
****************************************************

version 19.0

cap log close
log using "$LOG\log_051_RRanalysis.smcl", replace

* 1) Input and output data files
local read_file  "$CLEAN\df02_clean.dta"
local write_file "$OUT\RRresults_v2.xlsx"

use "`read_file'", clear

/***************************************************
a) Fit modified Poisson regression under the following conditions
Exposure  : i.combine3
Outcome   : grade_cat2
Confounder: age sex tbv

b) Sensitivity analysis: analyze each electrolyte as a continuous variable.
Exposure  : i_ca_min, i_k_min // Multiply by 10 so that the unit corresponds to 0.1.

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
* 2) Main analysis: 1 vs 0 and 2 vs 0, using combine3 = 0 as the reference
****************************************************

foreach k in 1 2 {

    * Initialize
    local b0  = .
    local lb0 = .
    local ub0 = .
    local pv0 = .

    local b1  = .
    local lb1 = .
    local ub1 = .
    local pv1 = .

    forvalues m = 0/1 {

        /*
        Specify ib0.combine3 to explicitly set combine3 = 0 as the reference category.
        
        */

        capture noisily poisson grade_cat2 ib0.combine3 `covars`m'', robust irr

        if !_rc {
            /*
            Extract the coefficient for `k'.combine3 on the eform scale.
            When k = 1, this corresponds to combine3 = 1 vs 0.
            When k = 2, this corresponds to combine3 = 2 vs 0.
            */

            capture noisily lincom `k'.combine3, eform level(95)

            if !_rc {
                local b`m'  = r(estimate)
                local lb`m' = r(lb)
                local ub`m' = r(ub)
                local pv`m' = r(p)
            }
            else {
                local b`m'  = .
                local lb`m' = .
                local ub`m' = .
                local pv`m' = .
            }
        }
        else {
            local b`m'  = .
            local lb`m' = .
            local ub`m' = .
            local pv`m' = .
        }
    }

    post `memhold' ("combine3: `k' vs 0") ///
        (`b0') (`lb0') (`ub0') (`pv0') ///
        (`b1') (`lb1') (`ub1') (`pv1')
}

****************************************************
* 3) Sensitivity analysis:
*    Include i_ca_min and i_k_min simultaneously as explanatory variables
****************************************************

replace i_ca_min = i_ca_min*10
replace i_k_min  = i_k_min*10

local sens_exp i_ca_min i_k_min

foreach x of local sens_exp {

    * Initialize
    local b0  = .
    local lb0 = .
    local ub0 = .
    local pv0 = .

    local b1  = .
    local lb1 = .
    local ub1 = .
    local pv1 = .

    forvalues m = 0/1 {

        /*
        In the sensitivity analysis, include i_ca_min and i_k_min simultaneously.
        From that model, obtain the risk ratio per 1-unit increase in `x'.
        */

        capture noisily poisson grade_cat2 `sens_exp' `covars`m'', robust irr

        if !_rc {

            capture noisily lincom `x', eform level(95)

            if !_rc {
                local b`m'  = r(estimate)
                local lb`m' = r(lb)
                local ub`m' = r(ub)
                local pv`m' = r(p)
            }
            else {
                local b`m'  = .
                local lb`m' = .
                local ub`m' = .
                local pv`m' = .
            }
        }
        else {
            local b`m'  = .
            local lb`m' = .
            local ub`m' = .
            local pv`m' = .
        }
    }

    post `memhold' ("`x' / 0.1 unit") ///
        (`b0') (`lb0') (`ub0') (`pv0') ///
        (`b1') (`lb1') (`ub1') (`pv1')
}




postclose `memhold'

****************************************************
* 5) Output results
****************************************************
use `results', clear

****************************************************
* 5a) Validate the conventional method-sensitivity results
****************************************************
assert _N == 4
assert exposure == "combine3: 1 vs 0" in 1
assert exposure == "combine3: 2 vs 0" in 2
assert exposure == "i_ca_min / 0.1 unit" in 3
assert exposure == "i_k_min / 0.1 unit" in 4

assert abs(cRR   - 7.250)  < 0.0005 in 1
assert abs(cCI_l - 0.729)  < 0.0005 in 1
assert abs(cCI_u - 72.079) < 0.0005 in 1
assert abs(cPv   - 0.091)  < 0.0005 in 1
assert abs(aRR   - 3.483)  < 0.0005 in 1
assert abs(aCI_l - 0.668)  < 0.0005 in 1
assert abs(aCI_u - 18.167) < 0.0005 in 1
assert abs(aPv   - 0.139)  < 0.0005 in 1

assert abs(cRR   - 11.600)  < 0.0005 in 2
assert abs(cCI_l - 1.245)   < 0.0005 in 2
assert abs(cCI_u - 108.050) < 0.0005 in 2
assert abs(cPv   - 0.031)   < 0.0005 in 2
assert abs(aRR   - 8.483)   < 0.0005 in 2
assert abs(aCI_l - 1.875)   < 0.0005 in 2
assert abs(aCI_u - 38.383)  < 0.0005 in 2
assert abs(aPv   - 0.006)   < 0.0005 in 2

assert abs(cRR   - 0.364) < 0.0005 in 3
assert abs(cCI_l - 0.187) < 0.0005 in 3
assert abs(cCI_u - 0.709) < 0.0005 in 3
assert abs(cPv   - 0.003) < 0.0005 in 3
assert abs(aRR   - 0.426) < 0.0005 in 3
assert abs(aCI_l - 0.223) < 0.0005 in 3
assert abs(aCI_u - 0.816) < 0.0005 in 3
assert abs(aPv   - 0.010) < 0.0005 in 3

assert abs(cRR   - 1.161) < 0.0005 in 4
assert abs(cCI_l - 0.594) < 0.0005 in 4
assert abs(cCI_u - 2.268) < 0.0005 in 4
assert abs(cPv   - 0.662) < 0.0005 in 4
assert abs(aRR   - 1.318) < 0.0005 in 4
assert abs(aCI_l - 0.848) < 0.0005 in 4
assert abs(aCI_u - 2.049) < 0.0005 in 4
assert abs(aPv   - 0.219) < 0.0005 in 4

****************************************************
* 6) Create string columns for a manuscript table
*    Point estimate (95% confidence interval) and p-value
****************************************************

* Crude analysis: point estimate (95% confidence interval)
gen str40 cRR_CI = ""
replace cRR_CI = ///
    strtrim(string(cRR,   "%9.3f")) + " (" + ///
    strtrim(string(cCI_l, "%9.3f")) + " to " + ///
    strtrim(string(cCI_u, "%9.3f")) + ")" ///
    if !missing(cRR, cCI_l, cCI_u)

* Crude analysis: p-value
gen str8 cP = ""
replace cP = "<0.001" if cPv < 0.001 & !missing(cPv)
replace cP = strtrim(string(cPv, "%9.3f")) if cPv >= 0.001 & !missing(cPv)


* Adjusted analysis: point estimate (95% confidence interval)
gen str40 aRR_CI = ""
replace aRR_CI = ///
    strtrim(string(aRR,   "%9.3f")) + " (" + ///
    strtrim(string(aCI_l, "%9.3f")) + " to " + ///
    strtrim(string(aCI_u, "%9.3f")) + ")" ///
    if !missing(aRR, aCI_l, aCI_u)

* Adjusted analysis: p-value
gen str8 aP = ""
replace aP = "<0.001" if aPv < 0.001 & !missing(aPv)
replace aP = strtrim(string(aPv, "%9.3f")) if aPv >= 0.001 & !missing(aPv)


****************************************************
* 7) Display
****************************************************
order exposure cRR_CI cP aRR_CI aP
keep exposure cRR_CI cP aRR_CI aP
list exposure cRR_CI cP aRR_CI aP, noobs abbreviate(30)

export excel using "`write_file'", sheet("Risk Ratio") first(varlabels) replace

log close
exit

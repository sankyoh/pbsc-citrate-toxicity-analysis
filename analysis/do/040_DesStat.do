****************************************************
* 040_DesStat.do
* Purpose: Generate descriptive statistics
* * df02_clean.dta -> Table1.xlsx
****************************************************
* 0) Open a log file
cap log close
log using "$LOG\log_040_DesStat.smcl", replace

* 1) Input and output data files
local read_file  "$CLEAN\df02_clean.dta"
local write_file_ca "${OUT}/Table1_ca.xlsx"
local write_file_k  "${OUT}/Table1_k.xlsx"

use "`read_file'", clear

local catevars sex
local contvars age  height weight tbv flow_rate inf_rate pre_cd34 ///
	time acd proc_vol gluconate ca_eq tp alb

local iqrvars age2  height2 weight2 tbv2 flow_rate2 inf_rate2 pre_cd342 ///
	time2 acd2 proc_vol2 gluconate2 ca_eq2 tp2 alb2
	
* Create an interleaved local macro
local des_vars i.sex

local n_cont : word count `contvars'
local n_iqr  : word count `iqrvars'

if `n_cont' != `n_iqr' {
    di as error "contvars and iqrvars have different numbers of variables."
    exit 198
}

forvalues i = 1/`n_cont' {
    local v1 : word `i' of `contvars'
    local v2 : word `i' of `iqrvars'
    local des_vars `des_vars' `v1' `v2'
}

// di "`des_vars'"


* Create duplicate variables to display median and IQR.
foreach v of local contvars {
	gen `v'2 = `v', after(`v')
}

make_table1 `des_vars', ///
	by(i_ca_bin) ///
	sdvars(`contvars') ///
	iqrvars(`iqrvars') ///
	writefile("`write_file_ca'")

make_table1 `des_vars', ///
	by(i_k_bin) ///
	sdvars(`contvars') ///
	iqrvars(`iqrvars') ///
	writefile("`write_file_k'")
	
log close
exit

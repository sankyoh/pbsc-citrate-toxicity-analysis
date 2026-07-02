****************************************************
* 010_import.do
* Purpose: Import the Excel file and save it as a Stata dataset
* Excel -> df00.dta
****************************************************

* 0) Open a log file
cap log close
log using "$LOG\log_010_import.smcl", replace

* 1) Input and output data files
local read_file  "$RAW\foobar.xlsx"
local write_file "$RAW\df00.dta"
local import_excel_ops "sheet("血清Mg_K追加") cellrange(I3:AW45) clear firstrow"

* 2) Import the Excel file
import excel using "`read_file'", `import_excel_ops'
gen patient_id = _n, before(年齢)

* 3) Sanity Check Lv1: Check whether the imported data are intact

* Variable types and number of rows
describe  // Check whether variable types look reasonable.
count     // Check whether the number of rows is as expected.

* Check for missing patient_id values
count if missing(patient_id) 

* Check for duplicate patient_id values
duplicates report patient_id 

* Briefly check continuous variables
// summarize omitted
	
* Briefly check Boolean/binary variables
// summarize omitted

* At this stage, inspect only.
di "Sanity Check Lv1 completed (no modification applied)"

* 4) Save raw data
compress
label data "RAW data"
save "`write_file'", replace

di "=== Import done ==="

log close
****************************************************
* master.do
* Purpose: Recreate the private analytic dataset and run the conventional
*          modified Poisson method-sensitivity analyses.
****************************************************

version 19.0

* Run this file from the analysis directory.
do 000_config.do

* Private source data -> df00.dta
do ${DO}/010_import.do

* df00.dta -> df01_clean.dta
do ${DO}/020_clean.do

* df01_clean.dta -> df02_clean.dta
do ${DO}/030_define_final_vars.do

* Conventional modified Poisson method-sensitivity analyses
do ${DO}/051_RRanalysis260606.do

di "=== Stata workflow complete ==="

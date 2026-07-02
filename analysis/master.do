****************************************************
* master.do
* Purpose: Run the modules in order
****************************************************

* 0) config
// Place 000_config.do in the same directory as master.do and the project files.
do 000_config.do

* 1) import
// Excel -> df00.dta
do ${DO}\010_import.do

* 2) cleaning
do ${DO}/020_clean.do

* 3) define exposure/outcome variables
do ${DO}/030_define_vars.do

****************************************************

* 4) Descriptive Statistics
do ${DO}/040_DesStat.do

* 5) Composite sevComp_bin2
// do ${DO}/050_RRanalysis.do // 202601

* 5) Risk Ratio
do ${DO}/051_RRanalysis260606.do // 202606


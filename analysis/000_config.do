****************************************************
* 000_config.do
* Purpose: Configure the environment, paths, and common options
****************************************************

* 1) Pin the Stata version
version 19.0

* 2) Prevent output pauses
set more off

* 3) Display formats for results (adjust if needed; usually left commented out)
// set cformat %9.3f
// set pformat %9.3f
// set sformat %9.3f

* 4) Define the project root
display "project directory: " c(pwd)
global PROJ "`c(pwd)'" 

* 5) Store frequently used folders in global macros
global RAW   "${PROJ}`c(dirsep)'data_raw"
global CLEAN "${PROJ}`c(dirsep)'data_clean"
global DO    "${PROJ}`c(dirsep)'do"
global LOG   "${PROJ}`c(dirsep)'log"
global OUT   "${PROJ}`c(dirsep)'output"

* 6) Initialize project-specific ado files here, if any


di "Project root: ${PROJ}"

di "=== Config loaded ==="
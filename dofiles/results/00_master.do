
/*==============================================================================================
Project:			Simulations Results file for MPO. SAR Countries.

Author:				Kelly Y. Montoya (kmontoyamunoz@worldbank.org)
Institution:		World Bank Group - ESAPV

Date:				05/17/2022
Last update: 		3/14/2025
================================================================================================

MASTER.DO

Descrption: Runs all the do-files in the project

==============================================================================================*/

drop _all
frame reset
version 17.0 
*cap net install etime
*cap net install dm31, from(http://www.stata.com/stb/stb26)
etime, start

/*==============================================================================================
 	0 - Globals - Please check these globals carefully 
==============================================================================================*/


* Paths
gl path "C:\Users\wb520054\WBG\SARDATALAB - Documents\Microsimulations\SM2025"
gl data_path "C:\Users\wb520054\OneDrive - WBG\02_SAR Stats Team\Microsimulations\SM2025"
gl avail_data "${path}\_inputs\Data availability by country.xlsx"
gl povmod 	  "\\wurepliprdfs01\gpvfile\gpv\Knowledge_Learning\Pov Projection\Central Team\MFM-allvintages.dta"

* Other globals 
gl country 		"BGD" 	// AFG BGD BTN IND MDV NPL PAK LKA
gl cpi_version 	12
gl min_sim_year 2023 	// Please check this twice - Dynamic stats
gl ppp 			2017	// Change for "yes" / "no" depending on the version

* Poverty and vulnerability thresholds - Change if necessary multiplying the original value by 100
gl pline1 /*190*/ 215
gl pline2 /*320*/ 365
gl pline3 /*550*/ 685
gl prs_gp /*nnn*/ 25


/*==============================================================================================
 	1 - Set up simulated and actual data input files 
==============================================================================================*/


* IMPORTANT: Some countries have data restrictions. Please check the name file and years before running.

* Data availability input
import excel "${avail_data}", sheet("Sheet1") cellrange(A1:G9) clear
qui keep if inlist(A,"Country","${country}")
for any B C D E F G: qui replace X = "0" if X == "ok"
for any B C D E F G: qui replace X = "1" if X == "sim"
qui destring B-G, replace
mkmat B-G, mat(data)

* Output file
gl country_path "${path}/${country}"
gl outfile "${country_path}\Results_${country}.xlsm"

run "01_data.do"
run "02_variables.do"
run "03_static_profiles.do"
run "04_gics.do"
run "05_transition_matrix.do"
run "06_dynamic_profiles.do"
run "07_pop_wdi.do"

* Display running time	
etime


/*==============================================================================================
  - END
==============================================================================================*/

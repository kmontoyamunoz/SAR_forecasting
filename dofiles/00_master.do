 *===========================================================================
* TITLE: Poverty micro-simulations
*===========================================================================
* Created on : Mar 17, 2020
* Last update: Mar 4, 2024
*==========================================================================
* Prepared by: Sergio Olivieri
* E-mail: solivieri@worldbank.org
* Modified by: Kelly Y. Montoya (kmontoyamunoz@worldbank.org)
*===========================================================================
*cap net install etime
etime, start
*===========================================================================
version 17.0

clear all
clear mata
clear matrix
set more off

*===========================================================================
* PATH
*===========================================================================

* NOTE: YOU ONLY NEED TO CHANGE THESE OPTIONS

* MAIN PATH (WHERE ALL YOUR FILES ARE LOCATED)
gl path  "Z:\public\Stats_Team\PLBs\23. Poverty projections simulations\LAC_Inputs_Regional_Microsims\FY2024\03_Microsims_SM2024"

* Globals for secondary general paths
global rootdatalib "S:\Datalib"
gl thedo    "Z:\public\Stats_Team\PLBs\23. Poverty projections simulations\New estimates informality new\dofiles"	// Do-files path

* Globals for country-year identification
** IMPORTANT!!! CHL database changes with the period to estimate
gl ppp17 "yes" 			// Change for "yes" / "no" depending on the version
gl country CHL 			// Country to upload
gl year 2020			// Year to upload - Base year dataset
gl final_year 2026		// Change for last simulated year

* Globals for country-specific paths
gl inputs   "${path}/${country}\Microsimulation_Inputs_${country}.xlsm" // Country's input Excel file
cap mkdir "${path}/${country}\Data"
gl data_out "${path}/${country}\Data"

* Parameters
*gl use_saved_parameters "yes" // Not working yet
global re_scale "no" // Change for "yes"/"no" re-scale using total income
global sector_model 6 // Change for "3" (old model) or "6" (new model) sectors
global random_remittances "no" // Change for "yes" or "no" (neutral distribution) on modelling

*===========================================================================
* select household survey
*===========================================================================

*Open datalib data	

if "${country}" == "DOM" datalib, country(${country}) year(${year}) mod(all) period(q03) clear

else datalib, country(${country}) year(${year}) mod(all) clear

gl survey = upper(r(surveys))
gl master = r(vermast)

/*if "$ppp17" == "yes" {
	merge m:m pais ano using "Z:\public\Stats_Team\FY2022\07_2017PPP\Inputs\mdat\ipc_sedlac_wb_ppp17_dlw.dta", keep(1 3) keepusing(ipc17_sedlac ppp17)
}*/

*===========================================================================
* run programs
*===========================================================================

local files : dir "$thedo\programs" files "*.do"
foreach f of local files{
	dis in yellow "`f'"
	qui: run "$thedo\programs\\`f'"
}

*===========================================================================
* run dofiles
*===========================================================================

* 1.input parameters
	run "$thedo\01_parameters.do"
* 2.prepare variables
	run "$thedo\02_variables.do"
* 3.model labor incomes by groups
	run "$thedo\03_occupation.do"
* 4.model labor incomes by skills
	run "$thedo\04_labor_income.do"
* 5.modeling population growth
	run "$thedo\05_population.do"
* 6.modeling labor activity rate
	run "$thedo\06_activity.do"
* 7.modeling unemployment rate
	run "$thedo\07_unemployment.do"
* 8.modeling changes in employment by sectors
	run "$thedo\08_struct_emp.do"
* 9.modeling labor income by sector
	run "$thedo\09_asign_labor_income.do"	
* 10.income growth by sector
	run "$thedo/$do_income.do"
* 11. total labor incomes
	run "$thedo/11_total_income.do"	
* 12. total non-labor incomes
	run "$thedo\12_assign_nlai.do"
* 13. household income
	run "$thedo\13_household_income.do"
* 14. poverty line adjustment
	run "$thedo\14_prices_consump.do"
* 15. compensation - emergency bonus
    run "$thedo\15_transfers_emergency_bonus.do"
* 16. aumento cobertura BDH
   // do "$thedo\16_transfers_bdh.do"
* 17. results
	run "$thedo\17_labels.do"
* 18. export results back to the Excel	
    run "$thedo\18_results.do"
	sum poor* vuln midd upper [w=fexp_s] if pc_inc_s!=.
	ineqdec0 pc_inc_s [w=fexp_s]
* Mitigation Measures
	if inlist("${country}","BRA","BOL","PAN","COL") run "$thedo/${country}_mm.do"
	if inlist("${country}","CHL") & "${model}"=="2021" run "$thedo/${country}_mm2021.do"

*===========================================================================
* quick summary
*===========================================================================

sum poor* vuln midd upper [w=fexp_s] if pc_inc_s!=.
ineqdec0 pc_inc_s [w=fexp_s]
*	ainequal pc_inc_s [w=fexp_s], all

*===========================================================================
* Display running time	
etime
*===========================================================================
*                                     END
*===========================================================================

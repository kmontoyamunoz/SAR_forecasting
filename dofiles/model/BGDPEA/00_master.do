
/*===================================================================================================
Project:			SAR Poverty micro-simulations
Institution:		World Bank - ESAPV

Authors:			Sergio Olivieri & Kelly Y. Montoya
E-mail:				solivieri@worldbank.org; kmontoyamunoz@worldbank.org
Creation Date:		11/4/2024

Last Modification:	Kelly Y. Montoya (kmontoyamunoz@worldbank.org)
Modification date:  11/21/2024
===================================================================================================*/

cap net install etime
etime, start
version 17.0

clear all
clear mata
clear matrix
set more off

/*===================================================================================================
	1 - MODEL SET-UP
===================================================================================================*/

* NOTE: YOU ONLY NEED TO CHANGE THESE OPTIONS

* Globals for general paths
gl priv_path 	"C:\Users\wb520054\OneDrive - WBG\02_SAR Stats Team\Microsimulations\Regional model"
gl path  		"$priv_path\PEA_BGD"
gl thedo    	"$priv_path\SAR_forecasting\dofiles\model"	// Do-files path

* Globals for country-year identification
gl cpi_version 	11
gl ppp 			2017	// Change for "yes" / "no" depending on the version
gl country 		"BGD" 	// Country to upload
gl year 		2022	// Year to upload - Base year dataset
gl final_year 	2026	// Change for last simulated year

* Globals for country-specific paths
gl inputs   "${path}/${country}\Microsimulation_Inputs_${country}_crisis.xlsm" // Country's input Excel file
cap mkdir 	"${path}/${country}\Data"
gl data_out "${path}/${country}\Data"

* Parameters
gl inc_re_scale 	"no" 	// Change for "yes"/"no" re-scale labor income using gdp
gl cons_re_scale 	"no" 	// Change for "yes"/"no" re-scale final consumption using private consumption
gl sector_model 	6 		// Change for "3" or "6" to change intrasectoral variation
gl rn_int_remitt 	"yes" 	// Change for "yes" or "no" (neutral distribution) on modelling intern. remittances
gl rn_dom_remitt 	"no" 	// Change for "yes" or "no" (neutral distribution) on modelling domestic remittances


/*===================================================================================================
	2 - DATA UPLOAD
===================================================================================================*/

* Support module - CPIs and PPPs
dlw, country(Support) year(2005) type(GMDRAW) surveyid(Support_2005_CPI_v${cpi_version}_M) filename(Final_CPI_PPP_to_be_used.dta)
keep if code == "${country}" & year == ${year}
keep code year cpi${ppp} icp${ppp}
rename code countrycode
tempfile dlwcpi
save `dlwcpi', replace
		
* SARMD modules - IND LBR INC
local modules "IND LBR INC"
foreach m of local modules {
	di in red "`m'"
	dlw, count("${country}") y(${year}) t(sarmd) mod(`m') clear nocpi
	tempfile `m'
	save ``m'', replace	
}
		
* Merge
use `IND'
merge 1:1 hhid pid using `LBR', nogen keep(1 3)
merge 1:1 hhid pid using `INC', nogen keep(1 3)
merge m:1 countrycode year using `dlwcpi', nogen keep(1 3)


/*===================================================================================================
	3 - LOAD PRE-DEFINED PROGRAMS
===================================================================================================*/

local files : dir "$thedo\programs" files "*.do"
foreach f of local files{
	dis in yellow "`f'"
	qui: run "$thedo\programs\\`f'"
}

/*===================================================================================================
	4 - RUN THE MODEL
===================================================================================================*/

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
	run "$thedo\11_total_labor_income.do"	
* 12. total non-labor incomes
	run "$thedo\12_assign_nlai.do"
* 13. household income
	run "$thedo\13_household_income.do"
* 14. relative prices adjustment (food/nonfood)
	*run "$thedo\14_relative_prices.do"
* 15. translating income into consumption
    *run "$thedo\15_income_to_consumption.do"
* 16. output database
	run "$thedo\16_output.do"

	
/*===================================================================================================
	- Quick summary
===================================================================================================*/

*sum poor* [w=fexp_s] if pc_inc_s!=.
*ineqdec0 pc_inc_s [w=fexp_s]


/*===================================================================================================
	- Display running time
===================================================================================================*/

etime


/*===================================================================================================
	- END
===================================================================================================*/

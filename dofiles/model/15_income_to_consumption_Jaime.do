
/*===================================================================================================
Project:			SAR Poverty micro-simulations - Matching income to consumption ratio
Institution:		World Bank - ESAPV

Author:				Kelly Montoya
E-mail:				kmontoyamunoz@worldbank.org
Creation Date:		12/10/2024

Last Modification:	Kelly Y. Montoya (kmontoyamunoz@worldbank.org)
Modification date:  12/10/2024
===================================================================================================*/


/*===================================================================================================
	1 - SETTING MATCHING VARIABLES
===================================================================================================*/

* Renaming
rename (weight    skilled      occupation      sect_main      ipcf_ppp		welfare_ppp) ///
       (fexp_base skilled_base occupation_base sect_main_base pc_inc_base	welfare_base)
	     
* Private cosumption growth
loc r = rowsof(growth_macro_data)
gen growth_cons = growth_macro_data[`r',1]

* Ventiles
xtile vtile = welfare_base [w = fexp_base] if h_head == 1, nq(20)

* Sample
gen hh_sample = 1 if !mi(region) & !mi(vtile) & !mi(age) & !mi(urban) & !mi(fexp_base) & !mi(h_size) & h_head == 1

* Compute household-level weights
gen h_fexp_base = fexp_base * h_size if h_head == 1
gen h_fexp_s 	= fexp_s 	* h_size if h_head == 1

* Original income/consumption ratio
gen orig_ratio = pc_inc_base / welfare_base


/*===================================================================================================
	2 - MATCHING
===================================================================================================*/

save "${data_out}\simulated.dta", replace

cd "${data_out}"

shell "C:\Program Files\R\R-4.3.0\bin\R.exe" --vanilla <"${priv_path}\SAR_forecasting\dofiles\model\propensity_cons_matching_resc.R"

use "${data_out}\matching_output.dta", clear

* New ratio
gen new_ratio = ratio if abs((orig_ratio - ratio)/orig_ratio) <= 0.2
replace new_ratio = orig_ratio if new_ratio == .
	
* Save new ratio
keep idh new_ratio
tempfile ratio
save `ratio', replace
	
* Merge with original simulated database
use "${data_out}\simulated.dta", clear
merge m:1 idh using `ratio'


/*===================================================================================================
	- END
===================================================================================================*/

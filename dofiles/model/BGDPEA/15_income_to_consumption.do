
/*===================================================================================================
Project:			SAR Poverty micro-simulations - Household income
Institution:		World Bank - ESAPV

Authors:			Jaime Fernandez & Kelly Montoya
E-mail:				kmontoyamunoz@worldbank.org
Creation Date:		11/21/2024

Last Modification:	Kelly Y. Montoya (kmontoyamunoz@worldbank.org)
Modification date:  11/21/2024
===================================================================================================*/


/*===================================================================================================
	1 - SETTING MATCHING VARIABLES
===================================================================================================*/

* Ventiles
xtile vtile = welfare_ppp [w = weight] if h_head == 1, nq(20)

* Sample
gen hh_sample = 1 if !mi(region) & !mi(vtile) & !mi(age) & !mi(urban) & !mi(weight) & !mi(h_size) & h_head == 1

* Original income/consumption ratio
gen orig_ratio = pc_inc_base / welfare_ppp

* Donation classes
gen class = group(region vtile urban)



qui shell "C:/Program Files/R/R-4.2.1/bin/R.exe" --vanilla <"${path}/Dofiles/transitions.R"

/*===================================================================================================
	- END
===================================================================================================*/
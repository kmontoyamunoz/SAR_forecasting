
/*===================================================================================================
Project:			SAR Poverty micro-simulations - Household simulated consumption
Institution:		World Bank - ESAPV

Author:				Kelly Montoya
E-mail:				kmontoyamunoz@worldbank.org
Creation Date:		12/10/2024

Last Modification:	Kelly Y. Montoya (kmontoyamunoz@worldbank.org)
Modification date:  12/11/2024
===================================================================================================*/

* New cosumption
gen welfare_s = pc_inc_s / new_ratio
replace welfare_s = welfare_base * (1 + growth_cons) if new_ratio <= 0

* Rescaling using macro private consumption
if "$cons_re_scale" == "yes" {

	sum welfare_base [aw = h_fexp_base]
	loc base = r(mean)
	sum welfare_s [aw=h_fexp_s]
	loc sim = r(mean)

	replace welfare_s = welfare_s * ((`base' * (1 + growth_cons)) / `sim')

}


/*===================================================================================================
	- END
===================================================================================================*/


/*===================================================================================================
Project:			SAR Poverty micro-simulations - Renaming and labels
Institution:		World Bank - ESAPV

Authors:			Sergio Olivieri & Kelly Y. Montoya
E-mail:				solivieri@worldbank.org; kmontoyamunoz@worldbank.org
Creation Date:		03/17/2020

Last Modification:	Kelly Y. Montoya (kmontoyamunoz@worldbank.org)
Modification date:  11/21/2024
===================================================================================================*/


/*===================================================================================================
	1 - Renaming
===================================================================================================*/

rename (weight    skilled      occupation      sect_main      ipcf_ppp) ///
       (fexp_base skilled_base occupation_base sect_main_base pc_inc_base)
	   

# delimit;
local var "
hhid 
pid 
fexp_base 
fexp_s 
age
male 
h_head
urban 
region 
h_size
occupation_base 
occupation_s 
sect_main_base 
sect_main_s
skilled_base
skilled_s
pc_inc_base
pc_inc_s
"
;
# delimit cr
order `var'

/*===================================================================================================
	2 - Labelling
===================================================================================================*/

label var occupation_base	"occupation status -baseline"
label var occupation_s		"occupation status -simulated"
label var sect_main_base	"economic sector -baseline"
label var sect_main_s		"economic sector -simulated"
label var skilled_base		"skills level -baseline"
label var skilled_s			"skills level -simulated"
label var pc_inc_base		"per capita family income -baseline"
label var pc_inc_s			"per capita family income -simulated"

* compress
compress


/*===================================================================================================
	3 - Poverty and Inequality Measures
===================================================================================================*/

/* Poverty lines

gen time_factor = 365/12

if $ppp = 2011 {
	
	pl1 = 1.9 * time_factor
	pl2 = 3.2 * time_factor
	pl3 = 5.5 * time_factor
}

else {
	
	pl1 = 2.15 * time_factor
	pl2 = 3.65 * time_factor
	pl3 = 6.85 * time_factor
}

* Poverty rates
capture matrix pov1
matrix pov1=(0,0)
matrix pov2=(0,0)
matrix pov3=(0,0)
matrix gini1=(0,0)

apoverty pc_inc_s [w=fexp_s] if pc_inc_s!=., varpl(pl1) h igr gen(poor1)
matrix pov1=pov1\(`r(head_1)',`r(wnbp)')

apoverty pc_inc_s [w=fexp_s] if pc_inc_s!=., varpl(pl2) h igr gen(poor2)
matrix pov2=pov2\(`r(head_1)',`r(wnbp)')

apoverty pc_inc_s [w=fexp_s] if pc_inc_s!=., varpl(pl3) h igr gen(poor3)
matrix pov3=pov3\(`r(head_1)', `r(wnbp)')

ainequal pc_inc_s [w=fexp_s]
matrix gini1=gini1\(`r(gini_1)', 0)

matrix all_p = pov1, pov2, pov3, gini1
matrix list all_p

*/
/*===================================================================================================
	4 - Saving the resulting database
===================================================================================================*/

save "${data_out}/${country}_${model}_${sector_model}s_dom_${rn_dom_remitt}_int_${rn_int_remitt}_inc_${inc_re_scale}_cons_${cons_re_scale}.dta", replace


/*===================================================================================================
	- END
===================================================================================================*/

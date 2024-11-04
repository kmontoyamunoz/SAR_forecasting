*===========================================================================
* TITLE: 18 - export results to Excel 
*===========================================================================
* Prepared by: Sergio Olivieri
* E-mail: solivieri@worldbank.org
*===========================================================================
* Created on : Nov 17, 2021
* Last update: Aug 11, 2022
*===========================================================================
* Updated by: Flavia Sacco Capurro
* Adapted the ECU version to the full project.

* Updated by: Kelly Y. Montoya and Cicero Braga
* Added Estimating vulnerability measures
* Added tables for income and labor market outputs
* Added vulnerability and up lines for 2017 PPP
* Added differentiation in poverty_gini sheet by year
* Changed vuln and middle class lines, change paths, muttes putexcel.

* Updated by: Cicero Braga
* Included saving with mm for BRA
*===========================================================================

*===========================================================================

* Estimating vulnerability measures


if "$ppp17" == "no" {

	gen vuln=1 if pc_inc_s>(5.5*365/12) & pc_inc_s<=(13*365/12) & pc_inc_s!=.
	replace vuln=0 if vuln!=1 & pc_inc_s!=.

	gen middle_class=1 if pc_inc_s>(13*365/12) & pc_inc_s<=(70*365/12) & pc_inc_s!=.
	replace middle_class=0 if middle_class!=1 & pc_inc_s!=.

	gen upper_class=1 if pc_inc_s>(70*365/12) & pc_inc_s!=.
	replace upper_class =0 if upper_class!=1 & pc_inc_s!=.

	* Estimating poverty rates
	capture matrix pov1
	matrix pov1=(0,0)
	matrix pov2=(0,0)
	matrix pov3=(0,0)
	matrix vuln=(0,0)
	matrix middle_class=(0,0)
	matrix upper_class=(0,0)
	matrix gini1=(0,0)


	apoverty pc_inc_s [w=fexp_s] if pc_inc_s!=., varpl(lp_550usd_s) h igr gen(poor550)
	matrix pov1=pov1\(`r(head_1)',`r(wnbp)')

	apoverty pc_inc_s [w=fexp_s] if pc_inc_s!=., varpl(lp_320usd_s) h igr gen(poor320)
	matrix pov2=pov2\(`r(head_1)',`r(wnbp)')

	apoverty pc_inc_s [w=fexp_s] if pc_inc_s!=., varpl(lp_190usd_s) h igr gen(poor190)
	matrix pov3=pov3\(`r(head_1)', `r(wnbp)')

	sum vuln [w=fexp_s]
	matrix vuln=vuln\(r(mean)*100, r(sum_w))

	sum middle_class [w=fexp_s]
	matrix middle_class=middle_class\(r(mean)*100, r(sum_w))

	sum upper_class [w=fexp_s]
	matrix upper_class=upper_class\(r(mean)*100, r(sum_w))

	ainequal pc_inc_s  [w=fexp_s]
	matrix gini1=gini1\(`r(gini_1)', 0)


	matrix all_p=pov3, pov2, pov1, vuln, middle_class, upper_class, gini1
	matrix list all_p

	*putexcel set "$inputs", sheet(poverty_gini_${model}) modify
	*putexcel a1=matrix(all_p) 


	* Saving the resulting database
*	if "${country}" == "BRA" & mm ==1 {
*		save "${path}\results/${country}_${model}_model_${sector_model}_${re_scale}_wgt_${weights}_mm.dta", replace
*	}
*	else{
	save "${data_out}/${country}_${model}_model_${sector_model}_${re_scale}_wgt_${weights}.dta", replace
*	}
	
}


else {
	
	cap drop vuln middle_class upper_class

	gen vuln=1 if pc_inc_s>(6.85*365/12) & pc_inc_s<=(14*365/12) & pc_inc_s!=.
	replace vuln=0 if vuln!=1 & pc_inc_s!=.

	gen middle_class=1 if pc_inc_s>(14*365/12) & pc_inc_s<=(81*365/12) & pc_inc_s!=.
	replace middle_class=0 if middle_class!=1 & pc_inc_s!=.

	gen upper_class=1 if pc_inc_s>(81*365/12) & pc_inc_s!=.
	replace upper_class =0 if upper_class!=1 & pc_inc_s!=.

	* Estimating poverty rates
	capture matrix pov1
	matrix pov1=(0,0)
	matrix pov2=(0,0)
	matrix pov3=(0,0)
	matrix vuln=(0,0)
	matrix middle_class=(0,0)
	matrix upper_class=(0,0)
	matrix gini1=(0,0)


	apoverty pc_inc_s [w=fexp_s] if pc_inc_s!=., varpl(lp_685usd_s) h igr gen(poor685)
	matrix pov1=pov1\(`r(head_1)',`r(wnbp)')

	apoverty pc_inc_s [w=fexp_s] if pc_inc_s!=., varpl(lp_365usd_s) h igr gen(poor365)
	matrix pov2=pov2\(`r(head_1)',`r(wnbp)')

	apoverty pc_inc_s [w=fexp_s] if pc_inc_s!=., varpl(lp_215usd_s) h igr gen(poor215)
	matrix pov3=pov3\(`r(head_1)', `r(wnbp)')

	sum vuln [w=fexp_s]
	matrix vuln=vuln\(r(mean)*100, r(sum_w))

	sum middle_class [w=fexp_s]
	matrix middle_class=middle_class\(r(mean)*100, r(sum_w))

	sum upper_class [w=fexp_s]
	matrix upper_class=upper_class\(r(mean)*100, r(sum_w))

	ainequal pc_inc_s  [w=fexp_s]
	matrix gini1=gini1\(`r(gini_1)', 0)


	matrix all_p=pov3, pov2, pov1, vuln, middle_class, upper_class, gini1
	matrix list all_p

	*putexcel set "$inputs", sheet(poverty_gini_${model}) modify
	*putexcel a1=matrix(all_p) 


	* Saving the resulting database
*	if "${country}" == "BRA" & mm==1 {
*		save "${path}\results/${country}_${model}_model_${sector_model}_${re_scale}_wgt_${weights}_ppp17_mm.dta", replace
*	}
*	else{
	save "${data_out}/${country}_${model}_model_${sector_model}_${re_scale}_wgt_${weights}_ppp17.dta", replace
*	}
}

*******************
* Results tables
*******************
/*
local scenarios base s
foreach i of local scenarios {
	
	* total population 
	sum fexp_`i'
	mat pop_`i' = r(sum)/1000 // thousands

	* pet
	gen pet_`i' = (inrange(occupation_`i',0,7))
	sum pet_`i' if pet_`i' ==1 [iw=fexp_`i']
	mat pet_`i' = r(sum) / 1000 // thousands

	* participation rate
	gen pea_`i' = (inrange(occupation_`i',1,7) )
	replace  pea_`i' = . if pet_`i' !=1
	sum pea_`i' [iw=fexp_`i']
	mat tpg_`i' = r(mean)

	* unemployment rate
	gen u1_`i' = occupation_`i'==1
	replace  u1_`i' = . if pea_`i' !=1
	sum u1_`i' [iw=fexp_`i']
	mat u1_`i' = r(mean)

	* informality rates
	tabstat informal_`i' [aw=fexp_`i'], by(sect_main_`i') save
	tabstatmat   I_`i'
	mat rowe     I_`i' = .
	mat rownames I_`i' = .

	* average incomes
	clonevar sect_`i' = occupation_`i'
	replace  sect_`i' = . if inlist(sect_`i',0,1) 
	tabstat lai_`i' [aw=fexp_`i'] , by(sect_`i') save
	tabstatmat   W_`i'
	mat rowe     W_`i' = .
	mat rownames W_`i' = .

	cap drop pet_`i'
	cap drop pea_`i'
	cap drop u1_`i'
	cap drop sect_`i'

	mat LM_`i' = pop_`i' \ pet_`i' \ tpg_`i' \ u1_`i' \ I_`i' \ W_`i'

}

mat all = LM_base, LM_s

mat rownames all  = "pop" "pet" "tgp" "unemp" "inf_rate-agr" "inf_rate-ind" "inf_rate-ser" "inf_rate" "agr-fml" "agr-inf" "ind-fml" "ind-inf" "ser-fml" "ser-inf" "total" 
mat colnames all  = "base" "simulation"
putexcel set "$inputs", sheet("re-scaling_${re_scale}_${model}") modify
putexcel B1 = matrix(all), names

*/


*===========================================================================
*                                     END
*===========================================================================

*=============================================================================
* TITLE: 03 - Modelling labor status by education skills 
*=============================================================================
* Prepared by: Sergio Olivieri
* E-mail: solivieri@worldbank.org
*=============================================================================
* Created on : Mar 17, 2020
* Last update: Aug 16, 2023 Kelly Y. Montoya
*=============================================================================

*=============================================================================
* independet variables
*=============================================================================

if inlist(pais_ocaux,"bol","gtm","GTM","bra","cri", "pry", "hnd") {
	cap drop region 
	encode region_survey, gen(region)
}

if inlist(pais_ocaux, "hnd", "HND") {
	cap drop region 
	rename region_survey region
}

if inlist(pais_ocaux,"NIC","nic") {
	cap drop region 
	rename region_survey region
}

if inlist(pais_ocaux,"arg","per","PER","slv","SLV","col","COL","ury") {
	cap drop region 
	encode region_survey, gen(region)
}

if inlist(pais_ocaux,"ecu","ECU") {
	cap drop region 
	encode region_est1, gen(region)
}

if inlist(pais_ocaux,"CHL","chl") {
    cap drop region
	encode region_survey, gen(region)
}

if inlist(pais_ocaux, "mex","DOM","dom","pan") {
	encode region_est1, gen(region)
}


loc mnl_rhs           c.edad##c.edad urbano ib0.male#ibn.jefe#ib0.married
loc mnl_rhs `mnl_rhs' remitt_any depen oth_pub ib0.male#ibn.educ_lev asiste
loc mnl_rhs `mnl_rhs' ib1.region

* skill levels
levelsof skill, loc(numb_skills)

foreach skill of numlist `numb_skills' {

	sum occupation if skill == `skill' 
	loc base = r(min)
    	
	* Parameters
	*if "$use_saved_parameters" == "no" {
		mlogit occupation `mnl_rhs'  [aw = pondera] if skill == `skill' & sample ==1, baseoutcome(`base')
		/*capture mkdir "${data}\models/${country}_${year}"
		estimates save "${data}\models/${country}_${year}\Status_skill_`skill'.dta", replace
	}
	else {
		estimates use "${data}\models/${country}_${year}\Status_skill_`skill'.dta"
		estimates esample: occupation `mnl_rhs' [aw = pondera] if
       skill == `skill' & sample ==1, baseoutcome(`base')

	}*/

	*=========================================================================
	* residuals
	*=========================================================================
	
	levelsof occupation if skill == `skill', local(occ_cat) 
	loc rvarlist
	
	foreach sect of numlist `occ_cat' {
	loc rvarlist "`rvarlist' U`sect'_`skill'"
	}
	
	set seed 23081985
	simchoiceres `rvarlist' if skill == `skill', total
}

*=============================================================================
*										END
*=============================================================================

*===========================================================================
* TITLE: Prepare variables
*===========================================================================
* Prepared by: Sergio Olivieri
* E-mail: solivieri@worldbank.org
*===========================================================================
* Created on : Mar 17, 2020
* Last update: Feb 14, 2023 Kelly Y. Montoya
* 				March 1, 2023 - Cicero Braga - adjust informality for ARG
*===========================================================================

*===========================================================================
* Be careful: check by-one-bye
*===========================================================================

clonevar emplyd     = ocupado if ipcf_ppp17 != .
clonevar unemplyd   = desocupa   if ipcf_ppp17 != .
gen      male       = (hombre==1)


* age sample
gen sample = 1 if inrange(edad,15,64)

*===========================================================================
* IMPORTANT: Informality definition change among countries!!!
*===========================================================================

cap drop informal


** BOL, BRA, CHL, COL, CRI, DOM, ECU, HND, SLV, PAN, PRY, PER, URY, NIC, GTM - Workers who do NOT receive a pension
if inlist(pais_ocaux,"bol","chl","col","cri","dom","ecu") {
	gen informal = djubila == 0 if djubila != .
	replace informal = . if sample != 1 | emplyd != 1 | !inrange(relab,1,4)
} // Close loop list
	
	
if inlist(pais_ocaux,"hnd","slv","pan","pry","per","ury","nic","gtm") {
	gen informal = djubila == 0 if djubila != .
	replace informal = . if sample != 1 | emplyd != 1 | !inrange(relab,1,4)
} // Close loop list


** BOL, BRA, CHL, COL, CRI, DOM, ECU, HND, SLV, PAN, PRY, PER, URY, NIC, GTM - Workers who do NOT receive a pension
if inlist(pais_ocaux,"BOL","CHL","COL","CRI","DOM","ECU") {
	gen informal = djubila == 0 if djubila != .
	replace informal = . if sample != 1 | emplyd != 1 | !inrange(relab,1,4)
} // Close loop list
	
	
if inlist(pais_ocaux,"HND","SLV","PAN","PRY","PER","URY","NIC","GTM") {
	gen informal = djubila == 0 if djubila != .
	replace informal = . if sample != 1 | emplyd != 1 | !inrange(relab,1,4)
} // Close loop list
	
	
** MEX - Team's definition
if inlist(pais_ocaux,"mex","MEX") {
	run "$thedo\02_1_informality_MEX.do"
	replace informal = . if sample != 1 | emplyd != 1 | !inrange(relab,1,4)
}


** BRA - Definition from BRA PE (based on dofiles for transfers)	
if inlist(pais_ocaux,"bra", "BRA") {
	gen formalbr = 0 if vd4002 == 1
	replace formalbr = 1 if vd4009 == 1 | vd4009 == 3 | vd4009 == 5 | vd4009 == 7 
	replace formalbr = 1 if  ( vd4009 == 8 | vd4009 == 9 ) & /*v4019 == 1 &*/ vd4012 == 1 
	gen informal = formalbr == 0 if djubila != .
	replace informal = . if sample != 1 | emplyd != 1 | !inrange(relab,1,4)
}
	
	
** ARG, HTI - Workers who do NOT receive a pension. For self-employed: workers who have NOT completed tertiary education
if inlist(pais_ocaux,"arg","hti","ARG","HTI") {
	gen informal =  djubila == 0 if djubila != .
	replace informal = 0 if informal == . & inlist(relab,1,3,4)
	replace informal = 1 if inlist(relab,1,3,4) & nivel != 6
	replace informal = . if sample != 1 | emplyd != 1 | !inrange(relab,1,4)
} // Close loop list


*===========================================================================
* PPP adjustment factor
*===========================================================================

gen factor_ppp11=(ipc11_sedlac/ipc_sedlac)/(ppp11*conversion)

foreach incomevar in ila ijubi itranp itrane icap inla_otro inla renta_imp ipcf itf ip inp {
cap drop `incomevar'_ppp11
gen `incomevar'_ppp11=`incomevar'*factor_ppp11
}


* PPP 2017 adjustment factor
if "$ppp17" == "yes" {
	gen factor_ppp17=(ipc17_sedlac/ipc_sedlac)/(ppp17*conversion)
	
	foreach incomevar in ila ijubi itranp itrane icap inla_otro inla renta_imp ipcf itf ip inp {
		cap drop `incomevar'_ppp17
		gen `incomevar'_ppp17=`incomevar'*factor_ppp17
	}
}


if $national == 0 {
	
	if "$ppp17" == "no" {

		*Make sure this is total family income
		clonevar  h_inc       = itf_ppp11
		clonevar lai_m        = ip_ppp11 if cohi == 1
		clonevar lai_s        = inp_ppp11 if cohi == 1
		clonevar lai_orig     = ila_ppp11 if cohi == 1
	}
	
	else {
		*Make sure this is total family income
		clonevar  h_inc       = itf_ppp17
		clonevar lai_m        = ip_ppp17 if cohi == 1
		clonevar lai_s        = inp_ppp17 if cohi == 1
		clonevar lai_orig     = ila_ppp17 if cohi == 1
	}
}


*===========================================================================
* Labor market variables
*===========================================================================

* Occupation by economic sector and informal status

*Generate the three economic sectors variable

if inlist(pais_ocaux,"PRY","pry")  {
	recode sector (1=1 "Agriculture") (2 3 4 =2 "Industry") (5 6 7 8 9 10 =3 "Services") , gen(sect_main)
	replace sect_main = . if ipcf_ppp17 == .
	*recode sector_s (1 2 =1 "Agriculture") (3 4 5 6 =2 "Industry") (7 8 9 10 11 12 13 14 15 16 17 =3 "Services") , gen(sect_secu) // KM: PRY doesn't have sector_s but it could be created. I leave this here in case they add it later in the harmonization.
} // PRY doesn't have available the variable sector1d from 2014 on.

else {
	recode sector1d (1 2 =1 "Agriculture") (3 4 5 6 =2 "Industry") (7 8 9 10 11 12 13 14 15 16 17 =3 "Services") , gen(sect_main)
	replace sect_main = . if ipcf_ppp17 == .
	
	if inlist(pais_ocaux,"cri","CRI","CHL","chl","MEX", "mex") {
	    gen sect_secu = .
	}
	
	else {
		recode sector1d_s (1 2 =1 "Agriculture") (3 4 5 6 =2 "Industry") (7 8 9 10 11 12 13 14 15 16 17 =3 "Services") , gen(sect_secu)
		replace sect_secu = . if ipcf_ppp17 == .
	}
}


* primary activity
gen     sect_main6 = .
replace sect_main6 = 1 if  sect_main == 1 & emplyd == 1 & informal == 0
replace sect_main6 = 2 if  sect_main == 1 & emplyd == 1 & informal == 1
replace sect_main6 = 3 if  sect_main == 2 & emplyd == 1 & informal == 0
replace sect_main6 = 4 if  sect_main == 2 & emplyd == 1 & informal == 1
replace sect_main6 = 5 if  sect_main == 3 & emplyd == 1 & informal == 0
replace sect_main6 = 6 if  sect_main == 3 & emplyd == 1 & informal == 1
label var sect_main6 "main economic sector" 

* secondary activity
gen     sect_secu6 = .
replace sect_secu6 = 1 if  sect_secu == 1 & emplyd == 1 & informal == 0
replace sect_secu6 = 2 if  sect_secu == 1 & emplyd == 1 & informal == 1
replace sect_secu6 = 3 if  sect_secu == 2 & emplyd == 1 & informal == 0
replace sect_secu6 = 4 if  sect_secu == 2 & emplyd == 1 & informal == 1
replace sect_secu6 = 5 if  sect_secu == 3 & emplyd == 1 & informal == 0
replace sect_secu6 = 6 if  sect_secu == 3 & emplyd == 1 & informal == 1
label var sect_secu6  "secondary economic sector" 

label def sectors         ///
1 "agriculture-formal"   ///
2 "agriculture-informal" ///
3 "industry-formal"   ///
4 "industry-informal" ///
5 "services-formal"   ///
6 "services-informal", replace
label values sect_main6 sect_secu6 sectors

* labor relationship
gen salaried = relab==2 if emplyd==1
gen self_emp = inlist(relab,1,3) if emplyd==1 
gen unpaid = relab==4 if emplyd==1
gen salaried2 = relab_s==2 if emplyd==1
gen self_emp2  = inlist(relab_s,1,3) if emplyd==1
gen unpaid2    = relab_s==4 if emplyd==1

* primary activity
gen     labor_rel = 1 if salaried == 1
replace labor_rel = 2 if self_emp == 1
replace labor_rel = 3 if unpaid   == 1
replace labor_rel = 4 if unemplyd == 1
label var labor_rel "labor relation-primary job"

* secondary activity
gen     labor_rel2 = 1 if salaried2 == 1
replace labor_rel2 = 2 if self_emp2 == 1
replace labor_rel2 = 3 if unpaid2   == 1
label var labor_rel2 "labor relation-secondary job"

label def lab_rel ///
1 "salaried"   ///
2 "self-employd" ///
3 "unpaid" ///
4 "unemployed" ,replace
label values labor_rel labor_rel2 lab_rel

* public job_status
/* IMPORTANT: This isn't accounting for not salaried public workers
 grupo_lab = 3  is  relab==2 & empresa==3
*/
gen     public_job = 0 if emplyd ==1
replace public_job = 1 if emplyd == 1 & grupo_lab==3

note: by definiton the public job is part of formal services sector

replace sect_main  = 3 if !inlist(sect_main, 3) & public_job ==1 & sect_main!= .
replace sect_main6 = 5 if !inlist(sect_main6,5) & public_job ==1 & sect_main6 != .

*===========================================================================
* Checking income variables
*===========================================================================

* labor incomes
egen    tot_lai = rowtotal(lai_m lai_s), missing
replace tot_lai = lai_s if lai_m < 0
replace tot_lai = . if lai_orig == .
if abs(tot_lai - lai_orig) > 1 & abs(tot_lai - lai_orig) != . di in red "WARNING: Please check variables definition. tot_lai is different from lai_orig."
drop lai_orig

* total household labor incomes
egen     h_lai  = sum(tot_lai) if hogarsec != 1, by(id) missing

* Household size
clonevar h_size= miembros

* Non-labor incomes
if "$ppp17" == "no" {
	gen capital_ppp11  = icap_ppp11 
	gen pensions_ppp11 = ijubi_ppp11
	gen otherinla_ppp11 = inla_otro_ppp11
	gen remesas_ppp11  = itranp_ppp11
	gen transfers_ppp11 = itrane_ppp11
}

else{
	gen capital_ppp17  = icap_ppp17
	gen pensions_ppp17 = ijubi_ppp17
	gen otherinla_ppp17 = inla_otro_ppp17
	gen remesas_ppp17  = itranp_ppp17
	gen transfers_ppp17 = itrane_ppp17
}

if $national == 0 { 
	
	if "$ppp17" == "no" {
		note: Se incluye alquiler imputado
		replace renta_imp_ppp11 = renta_imp_ppp11 / h_size
		local var "remesas_ppp11 pensions_ppp11 capital_ppp11 renta_imp_ppp11 otherinla_ppp11 transfers_ppp11"
		foreach x of local var {
		egen     h_`x' = sum(`x') if hogarsec != 1, by(id) missing
		replace  h_`x' = . if h_`x' == 0	
		}
	}
	else {
		note: Se incluye alquiler imputado
		replace renta_imp_ppp17 = renta_imp_ppp17 / h_size
		local var "remesas_ppp17 pensions_ppp17 capital_ppp17 renta_imp_ppp17 otherinla_ppp17 transfers_ppp17"
		foreach x of local var {
		egen     h_`x' = sum(`x') if hogarsec != 1, by(id) missing
		replace  h_`x' = . if h_`x' == 0	
		}
	}
} 

rename h_capital_ppp h_capital 
rename h_pensions_ppp h_pensions
rename h_remesas_ppp h_remesas 
rename h_otherinla_ppp h_otherinla
rename h_transfers_ppp h_transfers
rename h_renta_imp_ppp h_renta_imp

* household income
egen mm = rowtotal(h_lai h_remesas h_pensions h_capital h_renta_imp h_otherinla h_transfers), missing

gen  resid = h_inc - mm
replace resid = 0 if resid < 0
drop mm

egen h_nlai = rowtotal(h_remesas h_pensions h_capital h_renta_imp h_otherinla h_transfers resid), missing

* at household level 
local var "h_remesas h_pensions h_capital h_renta_imp h_otherinla h_nlai h_transfers resid"

foreach x of local var {
replace  `x' = . if jefe != 1
}
replace h_nlai   = . if h_nlai == 0


/*==========================================================================
* II. INDEPENDENT VARIABLES
*=========================================================================== 
	gender:			    male 
	experience:		    age
	experience2:		age2
	education dummies:	none and infantil
						primary
						secundary
						superior
	household head:		h_head
	marital status:		married
	regional dummies:   region	
	remittances:		    remitt_any
	other memb public job:	oth_pub
	dependency:		        depen
	others perception:	    perce
========================================================================= */
	
* education level (aggregate primary and none)
//replace educ_lev = 1 if educ_lev  ==0 
	
gen educ_level = nivel
replace educ_lev = 1 if educ_lev ==0

* marital status
gen married = (casado==1)

* remittances domestic or abroad
cap drop aux*
//gen	       aux  = 1 if (remesas > 0 & remesas !=.)

if "$ppp17" == "no" gen aux  = 1 if (remesas_ppp11 >0 & remesas_ppp11!=.)
else gen aux  = 1 if (remesas_ppp17 >0 & remesas_ppp17!=.)
replace	   aux  = 0 if  aux ==. 
egen       remitt_any = max(aux), by(id)
label var  remitt_any "[=1] if household receives remittances"

* other member with public salaried job
cap drop aux*
egen aux       = total(public_job), by(id)
gen     oth_pub = sign(aux - public_job)
replace oth_pub = sign(aux) if missing(public_job)
lab var oth_pub "[=1] if other member with public job"

* dependency ratio
cap drop aux*
cap drop depen
egen aux = total((edad < 15 | edad > 64)), by(id)
gen       depen = aux/h_size 
label var depen "potential dependency"

* log mail labor income
gen ln_lai_m = ln(lai_m)

*===========================================================================
* I. DEPENDENT VARIABLES
*===========================================================================

gen active         = (pea==1) if pea!=.

gen     occupation = .
replace occupation = 0 if  active     == 0          	
replace occupation = 1 if  unemplyd   == 1	    	  	
replace occupation = 2 if  sect_main == 1 & emplyd == 1 & informal == 0
replace occupation = 3 if  sect_main == 1 & emplyd == 1 & informal == 1
replace occupation = 4 if  sect_main == 2 & emplyd == 1 & informal == 0
replace occupation = 5 if  sect_main == 2 & emplyd == 1 & informal == 1
replace occupation = 6 if  sect_main == 3 & emplyd == 1 & informal == 0
replace occupation = 7 if  sect_main == 3 & emplyd == 1 & informal == 1
label var occupation "occupation status"

label define occup ///
0 "inactive" /// 
1 "unempl"   ///
2 "agr-fml"  /// 
3 "agr-inf" ///
4 "ind-fml" ///
5 "ind-inf" ///
6 "ser-fml"  ///
7 "ser-inf", replace 
label values occupation occup
	
*===========================================================================
* Setting up sample 
*===========================================================================

//local var "ln_lai_m sect_main6 sect_main sect_secu6 sect_secu occupation"

local var "ln_lai_m sect_main6 sect_main occupation"

foreach x of varlist `var' {
    replace `x' = . if sample != 1
}

* education variables
gen     sample_1 = 1 if educ_lev <  4 &  sample == 1 
lab var sample_1 "low educated"
gen     sample_2 = 1 if educ_lev >= 4 &  sample == 1 
lab var sample_2 "high educated"

gen     skill = 1 if sample_1 == 1
replace skill = 2 if sample_2 == 1

*===========================================================================
*                                     END
*===========================================================================
/*========================================================================
Project:			Simulations Results file for MPO.
Institution:		World Bank - ELCPV

Author:				Kelly Y. Montoya (kmontoyamunoz@worldbank.org)
Creation Date:		05/17/2022

Last Modification:	Kelly Y. Montoya (kmontoyamunoz@worldbank.org)
Modification date: 	02/28/2024
========================================================================*/

drop _all
*cap net install etime
*cap net install dm31, from(http://www.stata.com/stb/stb26)
etime, start

*************************************************************************
* 0 - Globals - Please check these globals carefully 
*************************************************************************

* Paths
gl rootdatalib "S:\Datalib"
gl path "Z:\public\Stats_Team\PLBs\23. Poverty projections simulations\LAC_Inputs_Regional_Microsims\FY2024\03_Microsims_SM2024"
gl path_out "Z:\public\Stats_Team\PLBs\23. Poverty projections simulations\New estimates informality new\out\MPO"
gl path_mpo "Z:\public\Stats_Team\PLBs\23. Poverty projections simulations\LAC_Inputs_Regional_Microsims\FY2024\03_Microsims_SM2024"
gl avail_data "Z:\public\Stats_Team\PLBs\23. Poverty projections simulations\New estimates informality new\Data availability by country.xlsx"

* Poverty and vulnerability thresholds - Change if necessary multiplying the original value by 100
gl min_povline /*190*/ 215
gl mid_povline /*320*/ 365
gl max_povline /*550*/ 685
gl vuln_line /*1300*/ 1400
gl midc_line /*7000*/ 8100

* Countries 
gl countries "CHL" // ARG BOL BRA CHL COL CRI DOM ECU MEX PRY PER URY"

* Minimum simulated year to include in dynamic stats
gl min_sim_year = 2023 // Please check this twice - Dynamic stats

* Countries names
qui wbopendata, indicator(SP.POP.TOTL) year(2019) projection clear
*use "Z:\public\Stats_Team\PLBs\23. Poverty projections simulations\LAC_Inputs_Regional_Microsims\FY2023\04_Microsims_SM2023\Pov_LAC_micro.dta", clear

keep countrycode countryname
duplicates drop
tempfile countriesnames
qui save `countriesnames', replace


foreach country of global countries {
    
	************************************************************************
	* 1 - Set up simulated and actual data input files  
	************************************************************************

	* IMPORTANT: Some countries have data restrictions. Please check the name file and years before running.
	
	* 1.1 - Data availability input
	**********************************
	import excel "${avail_data}", sheet("Sheet1") cellrange(A1:G18) clear
	qui keep if inlist(A,"Country","`country'")
	for any B C D E F G: qui replace X = "0" if X == "ok"
	for any B C D E F G: qui replace X = "1" if X == "sim"
	qui destring B-G, replace
	mkmat B-G, mat(data)
	
	
	* 1.2 - Output file
	**********************
	gl country_path "${path}/`country'"
	gl outfile "${country_path}\Results_`country'.xlsm"
	
	
	* 1.3 - Temporary file
	*************************
	clear
	tempfile `country'
	
	
	* 1.4 - Uploading the data for each year
	*************************************
	loc col_years = colsof(data)
	forvalues i = 1/`col_years' {
	    
		local year = data[1,`i']
	    
		** 1.4.1 - Actual data
		*************************
		if data[2,`i'] == 0 {
		    
			if "`country'" == "DOM" qui datalib, country("`country'") year(`year') period(q03) mod(all) clear
			
			else qui datalib, country("`country'") year(`year') mod(all) clear
			
			* Check
			if !_rc di in red "`country' `year' loaded from datalib"
			if _rc {
				di in red "`country' `year' NOT loaded from datalib"
				continue
			}
			
			cap gen ano_ocaux = `year'
			
			* Preparing variables
			if "`country'" == "MEX" qui keep pais_ocaux ano_ocaux id pid pondera hombre urbano edad jefe nivel miembros ipcf_ppp17 lp_*usd_* ila_ppp17 icap ijubi inla_otro itranp itrane ipc17_sedlac ipc_sedlac ppp17 conversion djubila ocupado relab sector1d pea desocupa ila renta_imp ipcf itf ip inp cohi hogarsec relab_s folioviv foliohog numren medtrab_* clas_emp_1* pres_* subor_1 tipocontr_* ingreso* segvol_* indep_* inst_* segsoc
			else if "`country'" == "BRA" qui keep pais_ocaux ano_ocaux id pid pondera hombre urbano edad jefe nivel miembros ipcf_ppp17 lp_*usd_* ila_ppp17 icap ijubi inla_otro itranp itrane ipc17_sedlac ipc_sedlac ppp17 conversion djubila ocupado relab sector1d pea desocupa ila renta_imp ipcf itf ip inp cohi hogarsec relab_s vd4002 vd4009 vd4012
			
			else qui keep pais_ocaux ano_ocaux id pid pondera hombre urbano edad jefe nivel miembros ipcf_ppp17 lp_*usd_* ila_ppp17 icap ijubi inla_otro itranp itrane ipc17_sedlac ipc_sedlac ppp17 conversion djubila ocupado relab sector1d sector pea desocupa ila renta_imp ipcf itf ip inp cohi hogarsec relab_s
			
			cap keep if ipcf_ppp17!=.
			
			** year
			qui ren ano_ocaux year
			
			
			** sample
			qui gen sample = 1 if inrange(edad,15,64)
			
			
			** weight
			qui ren pondera fexp_s
			
			
			** h_size
			qui clonevar h_size = miembros
			
			
			** depen
			cap drop aux*
			cap drop depen
			qui egen aux = total((edad < 15 | edad > 64)), by(id)
			qui gen depen = aux/h_size 
			
			
			** pc_inc_s
			ren ipcf_ppp17 pc_inc_s
			
			
			** poverty and vulnerability
			qui for any ${max_povline} ${mid_povline} ${min_povline} : gen poorX1 = pc_inc_s <= lp_Xusd_ppp if pc_inc_s != .
			qui gen vuln = 1 if pc_inc_s > (${max_povline} * 365 / 1200) & pc_inc_s <= (${vuln_line} * 365 / 1200) & pc_inc_s != .
			qui replace vuln=0 if vuln!=1 & pc_inc_s!=.
			qui gen middle_class = 1 if pc_inc_s > (${vuln_line} * 365 / 1200) & pc_inc_s <= (${midc_line} * 365 / 1200) & pc_inc_s != .
			qui replace middle_class = 0 if middle_class != 1 & pc_inc_s != .
			qui gen upper_class = 1 if pc_inc_s > (${midc_line} * 365 / 1200) & pc_inc_s != .
			qui replace upper_class = 0 if upper_class != 1 & pc_inc_s != .
			
			
			** informality: Informality definition change among countries!!!
			cap drop informal
			
			*** BOL, CHL, COL, CRI, DOM, ECU, HND, SLV, PAN, PRY, PER, URY, NIC, GTM - Workers who do NOT receive a pension
			if inlist(pais_ocaux,"bol","chl","col","COL","cri","dom","ecu") {
				qui gen informal = djubila == 0 if djubila != .
				qui replace informal = . if sample != 1 | ocupado != 1 | !inrange(relab,1,4)
			} // Close loop list
			
			if inlist(pais_ocaux,"hnd","slv","pan","pry","per","ury","nic","gtm") {
				qui gen informal = djubila == 0 if djubila != .
				qui replace informal = . if sample != 1 | ocupado != 1 | !inrange(relab,1,4)
			} // Close loop list
			
			if inlist(pais_ocaux,"HND","SLV","PAN","PRY","PER","URY","NIC","GTM") {
				qui gen informal = djubila == 0 if djubila != .
				qui replace informal = . if sample != 1 | ocupado != 1 | !inrange(relab,1,4)
			} // Close loop list
				
			*** MEX - Team's definition
			if inlist(pais_ocaux,"mex","MEX") {
				run "Z:\public\Stats_Team\PLBs\23. Poverty projections simulations\New estimates informality new\dofiles\02_1_informality_MEX_results.do"
				qui replace informal = . if sample != 1 | ocupado != 1 | !inrange(relab,1,4)
			}
			
			*** BRA - Definition from BRA PE (based on dofiles for transfers)
			if inlist(pais_ocaux,"bra", "BRA") {
				qui gen formalbr = 0 if vd4002 == 1
				qui replace formalbr = 1 if vd4009 == 1 | vd4009 == 3 | vd4009 == 5 | vd4009 == 7 
				qui replace formalbr = 1 if  ( vd4009 == 8 | vd4009 == 9 ) & /*v4019 == 1 &*/ vd4012 == 1 
				qui gen informal = formalbr == 0 if djubila != .
				qui replace informal = . if sample != 1 | ocupado != 1 | !inrange(relab,1,4)
			}
				
			** ARG, HTI - Workers who do NOT receive a pension. For self-employed: workers who have NOT completed tertiary education
			if inlist(pais_ocaux,"arg","hti","ARG","HTI") {
				qui gen informal =  djubila == 0 if djubila != .
				qui replace informal = 0 if informal == . & relab == 3
				qui replace informal = 1 if relab == 3 & nivel != 6
				qui replace informal = . if sample != 1 | ocupado != 1 | !inrange(relab,1,4)
			} // Close loop list
			
			
			** economic sector
			if inlist(pais_ocaux,"PRY","pry") qui recode sector (1=1 "Agriculture") (2 3 4 =2 "Industry") (5 6 7 8 9 10 =3 "Services") , gen(sect_main)
			else qui recode sector1d (1 2 =1 "Agriculture") (3 4 5 6 =2 "Industry") (7 8 9 10 11 12 13 14 15 16 17 =3 "Services") , gen(sect_main)
			
			
			** occupation_s
			qui gen active         = (pea==1)
			qui clonevar unemplyd   = desocupa if active==1
			qui clonevar emplyd_s     = ocupado  
			qui gen     occupation_s = .
			qui replace occupation_s = 0 if  active     == 0 
			qui replace occupation_s = 1 if  unemplyd   == 1  	
			qui replace occupation_s = 2 if  sect_main == 1 & emplyd_s == 1 & informal == 0
			qui replace occupation_s = 3 if  sect_main == 1 & emplyd_s == 1 & informal == 1
			qui replace occupation_s = 4 if  sect_main == 2 & emplyd_s == 1 & informal == 0
			qui replace occupation_s = 5 if  sect_main == 2 & emplyd_s == 1 & informal == 1
			qui replace occupation_s = 6 if  sect_main == 3 & emplyd_s == 1 & informal == 0
			qui replace occupation_s = 7 if  sect_main == 3 & emplyd_s == 1 & informal == 1
			
			
			** convert income variables to ppp17
			qui gen factor_ppp17=(ipc17_sedlac/ipc_sedlac)/(ppp17*conversion)
			foreach incomevar in ila ijubi itranp itrane icap inla_otro renta_imp ipcf itf ip inp {
				cap drop `incomevar'_ppp17
				qui gen `incomevar'_ppp17=`incomevar'*factor_ppp17
				}
				
			** lai_s
			qui clonevar lai_m_s = ip_ppp17 if cohi == 1
			qui clonevar lai_s_s = inp_ppp17 if cohi == 1
			qui egen tot_lai_s = rowtotal(lai_m_s lai_s_s), missing
			qui replace tot_lai_s = lai_s if lai_m < 0
			
			** non-labor income
			qui gen capital_ppp17  = icap_ppp17
			qui gen pensions_ppp17 = ijubi_ppp17
			qui gen otherinla_ppp17 = inla_otro_ppp17
			qui gen remesas_ppp17  = itranp_ppp17
			qui gen transfers_ppp17 = itrane_ppp17
			qui replace renta_imp_ppp17 = renta_imp_ppp17 / h_size
			
			local var "remesas_ppp17 pensions_ppp17 capital_ppp17 renta_imp_ppp17 otherinla_ppp17 transfers_ppp17"
			foreach x of local var {
				qui egen     h_`x' = sum(`x') if hogarsec != 1, by(id) //missing
				*qui replace  h_`x' = . if h_`x' == 0
			}
			
			rename h_capital_ppp h_capital_s 
			rename h_pensions_ppp h_pensions_s
			rename h_remesas_ppp h_remesas_s 
			rename h_otherinla_ppp h_otherinla_s
			rename h_transfers_ppp h_transfers_s
			rename h_renta_imp_ppp h_renta_imp_s

			** labor_rel
			qui gen salaried = relab==2 if emplyd_s==1
			qui gen self_emp = inlist(relab,1,3) if emplyd_s==1 
			qui gen unpaid = relab==4 if emplyd_s==1
			qui gen salaried2 = relab_s==2 if emplyd_s==1
			qui gen self_emp2  = inlist(relab_s,1,3) if emplyd_s==1
			qui gen unpaid2    = relab_s==4 if emplyd_s==1
			
			qui gen     labor_rel = 1 if salaried == 1
			qui replace labor_rel = 2 if self_emp == 1
			qui replace labor_rel = 3 if unpaid   == 1
			qui replace labor_rel = 4 if unemplyd == 1
			
			* Saving temporal database
			qui compress
			if `year' == data[1,1] qui save ``country'', replace
			else {
				qui append using ``country''
				qui save ``country'', replace
			}
		    
		}
		
		
		** 1.4.2 - Simulated data
		****************************
		if data[2,`i'] == 1 {
			
			if ("`country'" == "HND" & inlist(`year',2020,2021,2022)) use "${path}\HND\Data\HND_`year'_model_6_yes_wgt_0_ppp17.dta", clear
			
			else if ("`country'" == "PAN") {
				
				if `year' == 2020 use "${path}\PAN\Data\PAN_`year'_model_6_yes_wgt_0_mm_ppp17.dta", clear
				else use "${path}\PAN\Data\PAN_`year'_model_6_no_wgt_0_mm_ppp17.dta", clear
			}
			
			else if ("`country'" == "CHL" & `year' == 2021) use "${path}\CHL\Data\CHL_`year'_model_6_no_wgt_0_mm_ppp17.dta", clear
			
			else if ("`country'" == "BRA") use "${path}\BRA\Data\BRA_`year'_model_6_no_wgt_0_mm_ppp17.dta", clear
			
			else if ("`country'" == "BOL") use "${path}\BOL\Data\v4\BOL_`year'_model_3_yes_wgt_0_mm_ppp17.dta", clear
			
			else if ("`country'" == "COL") use "${path}\COL\Data\COL_`year'_model_6_no_wgt_0_mm_ppp17.dta", clear
			
			else if ("`country'" == "URY" & `year' == 2023) use "${path}\URY\Data\URY_`year'_model_6_no_wgt_0_ppp17.dta", clear
				
			else qui use "${country_path}\Data/`country'_`year'_model_6_no_wgt_0_ppp17.dta", clear

			di in red "`country' `year' loaded from simulations"
			
			* Preparing variables
			qui gen year = `year'
			keep year id pid fexp_* sample hombre urbano edad jefe nivel h_size depen pea emplyd_s pc_inc_* lp_*usd_* poor*1 vuln middle_class upper_class occupation_* lai_m_s lai_s_s tot_lai_* h_transfers* h_remesas* h_pensions* h_otherinla* h_capital* h_renta_imp* labor_rel
			
			cap keep if pc_inc_s!=.
			
			
			* Adjusting non-labor income to make it comparable
			local nonlabor "transfers remesas pensions capital otherinla renta_imp"
			foreach nli of local nonlabor  {
				qui bysort year id: egen aux_`nli' = sum(h_`nli'_s) if jefe != ., m
				qui replace h_`nli'_s = aux_`nli' 
				drop  aux_`nli' 
			}
			
			* Saving temporal database
			qui compress
			if `year' == data[1,1] qui save ``country'', replace
			else {
				qui append using ``country''
				qui save ``country'', replace
			}
		}
	}
	

	************************************************************************
	* 2 - General variables for tables 
	************************************************************************

	* Total population
	qui gen total = 1


	* Income gap
	*** This is necessary for the sheet Poverty and Inequality
	cap drop lp_*usd_s
	qui for any ${max_povline} ${mid_povline} ${min_povline} ${vuln_line} ${midc_line} : gen lp_Xusd_s = X * (365/1200)
	
	qui for any ${max_povline} ${mid_povline} ${min_povline} : gen gap_X = (lp_Xusd_s - pc_inc_s) / lp_Xusd_s * 100 if poorX1 == 1
	qui for any ${max_povline} ${mid_povline} ${min_povline} : replace gap_X = 0 if poorX1 == 0
	
	qui gen gap_vuln = (lp_${vuln_line}usd_s - pc_inc_s) / lp_${vuln_line}usd_s * 100 if vuln == 1
	qui replace gap_vuln = 0 if vuln == 0
			
			
	* Market structure
	*** This part creates the Labor Market variables necessary for Labor market summary stats. You can add more variables here.
	qui replace occupation_s = . if pc_inc_s == . 
	cap ren pea pea_old
	qui gen population = 1
	qui cap gen pea = .
	qui replace pea = occupation_s != 0 if sample == 1 & occupation_s !=.
	qui replace pea = 1 if sample == 1 & emplyd_s ==1
	qui gen participation = occupation_s != 0 if sample == 1 & occupation_s !=.
	qui replace participation = 1 if sample == 1 & emplyd_s ==1
	qui gen inactive = pea == 0 if sample == 1 & pea !=.
	qui gen unemployed = occupation_s == 1 if sample == 1 & pea == 1

	qui gen employed = !inlist(occupation_s,0,1) if sample == 1 & occupation_s !=.
	qui replace employed = 1 if sample == 1 & emplyd_s ==1

	*qui gen sal = labor_rel == 1 if employed == 1 & !inlist(labor_rel,4,.)
	*qui gen self = labor_rel == 2 if employed == 1 & !inlist(labor_rel,4,.)
	*qui gen unpd = labor_rel == 3 if employed == 1 & !inlist(labor_rel,4,.)
		
	qui gen emp_agr = inlist(occupation_s,2,3) if sample == 1 & employed == 1
	qui gen emp_ind = inlist(occupation_s,4,5) if sample == 1 & employed == 1
	qui gen emp_ser = inlist(occupation_s,6,7) if sample == 1 & employed == 1

	cap drop informal
	qui gen informal = inlist(occupation_s,3,5,7) if sample == 1 & employed== 1
	qui gen agr_infor = occupation_s == 3 if sample == 1 & emp_agr == 1
	qui gen ind_infor = occupation_s == 5 if sample == 1 & emp_ind == 1
	qui gen ser_infor = occupation_s == 7 if sample == 1 & emp_ser == 1

	qui gen inc = lai_m_s if employed == 1
	qui gen inc_for = lai_m_s if informal == 0
	qui gen inc_infor = lai_m_s if informal == 1

	qui gen inc_agr = lai_m_s if emp_agr == 1
	qui gen inc_ind = lai_m_s if emp_ind == 1
	qui gen inc_ser = lai_m_s if emp_ser == 1

	qui gen inc_agr_for = lai_m_s if informal == 0 & emp_agr == 1
	qui gen inc_agr_infor = lai_m_s if informal == 1 & emp_agr == 1
	qui gen inc_ind_for = lai_m_s if informal == 0 & emp_ind == 1
	qui gen inc_ind_infor = lai_m_s if informal == 1 & emp_ind == 1
	qui gen inc_ser_for = lai_m_s if informal == 0 & emp_ser == 1
	qui gen inc_ser_infor = lai_m_s if informal == 1 & emp_ser == 1


	* Population Disaggregations
	*** For now, the disaggregations correspond to Gender, Area, Age Range, and Education level. You can create more disaggregations and add them in the loop.
			
	cap qui gen female = hombre == 0
	cap qui gen male = hombre == 1
			
	cap qui gen urban = urbano == 1
	cap qui gen rural = urbano == 0
			
	cap qui gen age014 = inrange(edad,0,14)
	cap qui gen age1524 = inrange(edad,15,24)
	cap qui gen age2534 = inrange(edad,25,34)
	cap qui gen age3544 = inrange(edad,35,44)
	cap qui gen age4554 = inrange(edad,45,54)
	cap qui gen age5564 = inrange(edad,55,64)
	cap qui gen age65p = edad > 64 if edad != .
			
	cap qui gen unskilled = nivel < 4 if nivel != .
	cap qui gen skilled = nivel >= 4 if nivel != .
			
	foreach var of varlist female male urban rural age1524 age2534 age3544 age4554 age5564 skilled unskilled {
		qui gen pop_`var' = total if `var' == 1
	}
				
					
	* Per capita income
	*** This section calculate all source of income at the per capita level. Sources of income included: Total family income, Labor income, Non-labor income, Public transfers, Private transfers, Pensions, Capital, Other non-labor income.
			
	qui bysort year id: egen h_lai_s = sum(tot_lai_s) if jefe != . , m 
	qui gen pc_lai_s = h_lai_s / h_size
	replace pc_lai_s = . if pc_inc_s == .
	replace pc_lai_s = 0 if pc_inc_s != . & pc_lai_s == .

	for any transfers remesas pensions capital otherinla renta_imp: qui gen pc_X_s = h_X_s / h_size if jefe != .
	
	qui egen h_nlai_s = rowtotal(h_transfers_s h_remesas_s h_pensions_s h_capital_s h_otherinla_s h_renta_imp_s) if jefe != . , m
	qui gen pc_nlai_s = h_nlai_s / h_size
	qui replace pc_nlai_s = . if pc_inc_s == .
	qui replace pc_nlai_s = 0 if pc_inc_s != . & pc_nlai_s == .
	
	for any transfers remesas pensions capital otherinla renta_imp: qui replace pc_X_s = 0 if pc_X_s == . & pc_nlai_s != .
				
	qui gen pc_pubtr_s = pc_transfers_s
	qui gen pc_privttr_s = pc_remesas_s
			
			
	* Inequality 
	*** This section calculates inequality measures.
	qui gen gini = ""
	qui gen theil = ""

	loc init = data[1,1]
	loc end = `init' + 5

	forvalues a = `init'/ `end' {
		qui ainequal pc_inc_s [w=fexp_s] if year == `a'
		qui replace gini = r(gini_1)  if year == `a'
		qui replace theil = r(theil_1)  if year == `a'
	}
			
	qui destring gini theil, replace


	* Save for future reference
	tempfile processed
	qui save `processed', replace

	************************************************************************
	* 3 - Static Profiles
	************************************************************************

	** This section calculate profiles for populations according to poverty and vulnerability status. You can add more variables or more detailed status here.

	* 3.1 - Variables for each profile
	*************************************
	local categories poor${max_povline}1 poor${mid_povline}1 poor${min_povline}1 vuln middle_class upper_class total
	foreach kind of local categories {
				
		qui gen pop_`kind' = 1 if `kind' == 1
		qui gen urban_`kind' = urbano if `kind' == 1
		qui gen h_size_`kind' = h_size if `kind' == 1
		qui gen dependency_`kind' = depen if `kind' == 1
		qui gen ti_`kind' = pc_inc_s if `kind' == 1
		qui gen li_`kind' = pc_lai_s if `kind' == 1
		qui gen nli_`kind' = pc_nlai_s if `kind' == 1
		qui gen age014_`kind' = age014 if `kind' == 1
		qui gen age1524_`kind' = age1524 if `kind' == 1
		qui gen age2534_`kind' = age2534 if `kind' == 1
		qui gen age3544_`kind' = age3544 if `kind' == 1
		qui gen age4554_`kind' = age4554 if `kind' == 1
		qui gen age5564_`kind' = age5564 if `kind' == 1
		qui gen age65p_`kind' = age65p if `kind' == 1
		qui gen male_`kind' = hombre if `kind' == 1
		qui gen female_`kind' = !hombre if `kind' == 1
		qui gen inac_`kind' = inactive if `kind' == 1
		qui gen emp_`kind' = employed if `kind' == 1
		qui gen unemp_`kind' = unemployed if `kind' == 1
		*qui gen emp_agr_`kind' = emp_agr if `kind' == 1
		*qui gen emp_ind_`kind' = emp_ind if `kind' == 1
		*qui gen emp_ser_`kind' = emp_ser if `kind' == 1
		*qui gen sal_`kind' = sal if `kind' == 1
		*qui gen self_`kind' = self if `kind' == 1
		*qui gen unpd_`kind' = unpd if `kind' == 1
		qui gen inf_`kind' = informal if `kind' == 1
		qui gen skilled_`kind' = skilled if `kind' == 1
		qui gen unskilled_`kind' = unskilled if `kind' == 1
		*qui gen income_`kind' = pc_inc_s if `kind' == 1
		qui gen pub_transf_`kind' = pc_pubtr_s if `kind' == 1
		qui gen priv_transf_`kind' = pc_privttr_s if `kind' == 1
		qui gen pensions_`kind' = pc_pensions_s if `kind' == 1
		qui gen capital_`kind' = pc_capital_s if `kind' == 1
		qui gen othernli_`kind' = pc_otherinla_s if `kind' == 1 
		qui gen renta_imp_`kind' = pc_renta_imp_s if `kind' == 1 
	}
	
	* Restriction for upper class no transfers
	qui replace pub_transf_upper_class = 0 if upper_class == 1
		
	* 3.2 - Descriptive data collapse
	************************************
	*** Collapse data information for the sheet "descriptives". This data is saved as a temporary file that will be merge with dynamic profiles later. This atage also saves information for MPO team.
			
	preserve

	* Descriptives
	qui collapse (sum) pop* pea* (mean) pc_inc_s pc_lai_s pc_nlai_s pc_pubtr_s pc_privttr_s pc_pensions_s pc_capital_s pc_otherinla_s pc_renta_imp_s poor*1 vuln middle_class upper_class gini theil urban_* h_size_* ti_* li_* nli_* /*hhead_**/ /*income_**/ gap_* participation* unemployed* employed* emp_* informal* agr_* ind_* ser_* inc* pub_transf_* priv_transf_* pensions_* capital_* othernli_* age*_* dependency_* male_* female_* skilled_* unskilled_* unemp_* inf_* inac* /*sal* self* unpd**/ [fw = fexp_s], by(year)
	qui xpose, clear varname
	ren _varname indicator
	qui order indicator
	qui replace indicator = "_year" if indicator == "year"
	sort indicator
	foreach var of varlist v1-v6 {
	   rename `var' y_`=`var'[1]'
	}
	qui drop if indicator == "_year"
	tempfile descriptives
	qui save `descriptives', replace

	* Output for MPO team
	keep if inlist(indicator,"poor${min_povline}1","poor${mid_povline}1","poor${max_povline}1","vuln","middle_class","upper_class","gini")
	qui gen countrycode = "`country'"
	order countrycode
	tempfile mpo
	qui save `mpo', replace
	use "${path_out}\poverty_LAC.dta", clear
	qui drop if countrycode == "`country'"
	qui append using `mpo'
	sort countrycode indicator
	qui save "${path_out}\poverty_LAC.dta", replace
	
	qui reshape long y_, i(countrycode indicator) j(year)
	keep if inlist(indicator,"poor2151","poor3651","poor6851")
	qui replace indicator = "1" if indicator == "poor2151"
	qui replace indicator = "2" if indicator == "poor3651"
	qui replace indicator = "3" if indicator == "poor6851"
	destring indicator, replace
	qui reshape wide y_, i(countrycode year) j(indicator)
	ren y_* PovertyRate*
	qui gen region = "LAC"
	qui merge m:1 countrycode using `countriesnames', keep(1 3) nogenerate
	order countrycode region countryname year PovertyRate1 PovertyRate2 PovertyRate3
	la var year "Poverty line in PPP$ (per capita per day)"
	la var PovertyRate1 "1 PovertyRate"
	la var PovertyRate2 "2 PovertyRate"
	la var PovertyRate3 "3 PovertyRate"
	for any 1 2 3: qui replace PovertyRateX = PovertyRateX * 100
	qui compress
	qui save "${path_mpo}\Pov_LAC_micro.dta", replace
	restore
		
			
	************************************************************************
	* 4 - GICs
	************************************************************************

	* 4.1 - Calculating percentiles
	**********************************
	qui gen pctile_all = .
	qui gen pctile_urban = .
	qui gen pctile_rural = .
	qui gen ann_inc_s = pc_inc_s /* * 12 */

	forvalues a = `init' / `end' {
		qui xtile pctile_`a' = ann_inc_s [w=fexp_s] if year == `a', nq(100)
		qui xtile pctile_urban_`a' = ann_inc_s [w=fexp_s] if year == `a' & urban == 1, nq(100)
		if "`country'" != "ARG" qui xtile pctile_rural_`a' = ann_inc_s [w=fexp_s] if year == `a' & rural == 1, nq(100)
		else gen pctile_rural_`a' = 0 if year == `a' & rural == 1

		qui replace pctile_all = pctile_`a' if year == `a'
		qui replace pctile_urban = pctile_urban_`a' if year == `a'
		qui replace pctile_rural = pctile_rural_`a' if year == `a'
		drop pctile_`a' pctile_urban_`a' pctile_rural_`a'
	}

	* 4.2 - Mean income by percentile, national-level
	****************************************************
	preserve
	qui collapse ann_inc_s [fw=fexp_s], by(year pctile_all)
	qui drop if pctile_all == .
	qui reshape wide ann_inc_s, i(pctile_all) j(year)

	loc sec_year = `init' + 1
	forvalues a = `sec_year' / `end' {
		loc previous = `a' - 1
		qui gen r_`a' = (ann_inc_s`a' / ann_inc_s`previous' - 1) * 100
	}

	qui export excel using "${outfile}", sheet(GICs) firstrow(variables) sheetreplace
	restore


	* 4.3 - Mean income by percentile, urban area
	************************************************
	preserve
	qui collapse ann_inc_s [fw=fexp_s], by(year pctile_urban)
	qui drop if pctile_urban == .
	qui reshape wide ann_inc_s, i(pctile_urban) j(year)

	forvalues a = `sec_year' / `end' {
		loc previous = `a' - 1
		qui gen r_`a' = (ann_inc_s`a' / ann_inc_s`previous' - 1) * 100
	}

	qui export excel using "${outfile}", sheet(GICs_urban) firstrow(variables) sheetreplace
	restore

	* 4.4 - Mean income by percentile, rural area
	************************************************
	if "`country'" != "ARG" {
		preserve
		qui collapse ann_inc_s [fw=fexp_s], by(year pctile_rural)
		qui drop if pctile_rural == .
		qui reshape wide ann_inc_s, i(pctile_rural) j(year)

		forvalues a = `sec_year' / `end' {
			loc previous = `a' - 1
			qui gen r_`a' = (ann_inc_s`a' / ann_inc_s`previous' - 1) * 100
		}

		qui export excel using "${outfile}", sheet(GICs_rural) firstrow(variables) sheetreplace
		restore
	}


	************************************************************************
	* 5 - Transition matrix
	************************************************************************

	* 5.1 - Keep only simulated data
	***********************************
	qui gen simulation = .
	forvalues a = 1/6 {
		loc simulated = data[2,`a']
		qui replace simulation = `simulated' if year == data[1,`a']
	}

	qui drop if simulation == 0
	qui drop if year < ${min_sim_year}

	* 5.2 - Reshape data to calculate transitions
	************************************************
	keep year id pid total fexp_base fexp_s pc_inc_base poor*1 vuln middle_class upper_class
	tab year
	sca n_sim_years = r(r)
	levelsof year, matrow(sim_years)
	qui reshape wide total fexp_s poor*1 vuln middle_class upper_class, i(id pid fexp_base pc_inc_base) j(year)

	* 5.3 - Baseline poverty and vulnerability
	*********************************************
	for any ${min_povline} ${mid_povline} ${max_povline} : qui gen poorX1_base = pc_inc_base <= X * (365/1200) if pc_inc_base != .
	qui gen vuln_base = 1 if pc_inc_base > (${max_povline} * 365 / 1200) & pc_inc_base <= (${vuln_line} * 365 / 1200)
	replace vuln_base =0 if vuln_base != 1 & pc_inc_base != .
	qui gen middle_class_base = 1 if pc_inc_base > (${vuln_line} * 365 / 1200) & pc_inc_base <= (${midc_line} * 365 / 1200)
	qui replace middle_class_base = 0 if middle_class_base != 1 & pc_inc_base != .
	qui gen upper_class_base = 1 if pc_inc_base > (${midc_line} * 365 / 1200) & pc_inc_base != .
	qui replace upper_class_base = 0 if upper_class_base != 1 & pc_inc_base != .
				

	* 5.4 - First simulated year
	*******************************
	loc init = sim_years[1,1]
	di `init'

	* Categories base year
	qui gen prev_cat_`init' = ""
	qui replace prev_cat_`init' = "Poor" if poor${max_povline}1_base == 1
	qui replace prev_cat_`init' = "Vulnerable" if vuln_base == 1 & prev_cat_`init' == ""
	qui replace prev_cat_`init' = "Middle Class" if middle_class_base == 1 & prev_cat_`init' == ""
	qui replace prev_cat_`init' = "Upper Class" if upper_class_base == 1 & prev_cat_`init' == ""

	* Collapse and save in temporary file
	preserve 
	ren *`init' *
	qui collapse (sum) poor${max_povline}1 vuln middle_class upper_class [iw=fexp_s], by(prev_cat_)
	qui gen year = `init'
	qui drop if prev_cat_ == ""
	tempfile matrix_`init'
	qui save `matrix_`init'', replace
	restore

	* 5.5 - The other simulated years
	************************************
	loc end = sim_years[n_sim_years,1]
	di `end'
	loc second = `init' + 1

	forvalues a = `second' / `end' {
		
		loc previous = `a' - 1
		
		* Categories previous year
		qui gen prev_cat_`a' = ""
		qui replace prev_cat_`a' = "Poor" if poor${max_povline}1`previous' == 1
		qui replace prev_cat_`a' = "Vulnerable" if vuln`previous' == 1 & prev_cat_`a' == ""
		qui replace prev_cat_`a' = "Middle Class" if middle_class`previous' == 1 & prev_cat_`a' == ""
		qui replace prev_cat_`a' = "Upper Class" if upper_class`previous' == 1 & prev_cat_`a' == ""
		
		* Collapse and save in temporary file
		preserve 
		ren *`a' *
		qui collapse (sum) poor${max_povline}1 vuln middle_class upper_class [iw=fexp_s], by(prev_cat_)
		qui gen year = `a'
		qui drop if prev_cat_ == ""
		tempfile matrix_`a'
		qui save `matrix_`a'', replace
		restore
		
	}


	* 5.6 - Join the data and export
	***********************************

	use `matrix_`init'', clear
	forvalues a = `second' / `end' {
		qui append using `matrix_`a''
	}

	order year
	qui export excel using "${outfile}", sheet(matrix_categories) firstrow(variables) sheetreplace


	************************************************************************
	* 6 - Dynamic profiles
	************************************************************************

	use `processed', clear


	* 6.1 - Keep only simulated data
	***********************************
	gen simulation = .
	forvalues a = 1/6 {
		loc simulated = data[2,`a']
		replace simulation = `simulated' if year == data[1,`a']
	}

	drop if simulation == 0
	drop if year < ${min_sim_year}


	* 6.2 - Reshape
	******************
	* Reshape data to calculate inter-annual changes. Please make sure you include here all the variables you will need.
	keep year id pid fexp_* sample hombre urbano edad jefe skilled unskilled age* h_size depen pc_inc_* lp_*usd_* poor*1 vuln middle_class upper_class tot_lai_* pc_*_s participation* employed* unemployed* informal*
	cap drop pc_inc_s_nomm

	qui reshape wide participation unemployed employed informal *_s poor* vuln middle_class upper_class, i(id pid) j(year)
		

	* 6.3 - Changes in poverty and vulnerability status
	******************************************************

	loc init = sim_years[1,1]
	di `init'


	* Categories first simulated year
	qui gen total`init' = 1

	qui gen old_poor_`init' = pc_inc_base <= ${max_povline} * (365/1200) if pc_inc_base != .
	qui gen old_vuln_`init' = pc_inc_base > (${max_povline} * 365 / 1200) & pc_inc_base <= (${vuln_line} * 365 / 1200) if pc_inc_base != .
	qui gen old_middle_class_`init' =  pc_inc_base > (${vuln_line} * 365 / 1200) & pc_inc_base <= (${midc_line} * 365 / 1200) if pc_inc_base != .
	qui gen old_upper_class_`init' =  pc_inc_base > (${midc_line} * 365 / 1200) if pc_inc_base != .

	qui gen new_inpov`init' = poor${max_povline}1`init' == 1 & old_poor_`init' == 0
	qui gen always_inpov`init' = poor${max_povline}1`init' == 1 & old_poor_`init' == 1
	qui gen new_invul`init' = vuln`init' == 1 & old_vuln_`init' == 0
	qui gen always_invul`init' = vuln`init' == 1 & old_vuln_`init' == 1
	qui gen new_inmc`init' = middle_class`init' == 1 & old_middle_class_`init' == 0
	qui gen always_inmc`init' = middle_class`init' == 1 & old_middle_class_`init' == 1
	qui gen new_inuc`init' = upper_class`init' == 1 & old_upper_class_`init' == 0
	qui gen always_inuc`init' = upper_class`init' == 1 & old_upper_class_`init' == 1


	* Categories for the other simulated years
	loc end = sim_years[n_sim_years,1]
	loc second = `init' + 1

	forvalues a = `second' / `end' {
		
		loc prev = `a' - 1
		
		qui gen total`a' = 1
		
		qui gen new_inpov`a' = poor${max_povline}1`a' == 1 & poor${max_povline}1`prev' == 0
		qui gen always_inpov`a' = poor${max_povline}1`a' == 1 & poor${max_povline}1`prev' == 1
		qui gen new_invul`a' = vuln`a' == 1 & vuln`prev' == 0
		qui gen always_invul`a' = vuln`a' == 1 & vuln`prev' == 1
		qui gen new_inmc`a' = middle_class`a' == 1 & middle_class`prev' == 0
		qui gen always_inmc`a' = middle_class`a' == 1 & middle_class`prev' == 1
		qui gen new_inuc`a' = upper_class`a' == 1 & upper_class`prev' == 0
		qui gen always_inuc`a' = upper_class`a' == 1 & upper_class`prev' == 1
	}


	* Profiles
	forvalues i = `init' / `end' {
		
		local categories new_inpov always_inpov new_invul always_invul new_inmc always_inmc new_inuc always_inuc total
		foreach kind of local categories {
					
			qui gen pop_`kind'`i' = 1 if `kind'`i' == 1
			qui gen urban_`kind'`i' = urbano if `kind'`i' == 1
			qui gen h_size_`kind'`i' = h_size if `kind'`i' == 1
			qui gen dependency_`kind'`i' = depen if `kind'`i' == 1
			qui gen ti_`kind'`i' = pc_inc_s`i' if `kind'`i' == 1
			qui gen li_`kind'`i' = pc_lai_s`i' if `kind'`i' == 1
			qui gen nli_`kind'`i' = pc_nlai_s`i' if `kind'`i' == 1
			qui gen hhead_age_`kind'`i' = edad if `kind'`i' == 1 & jefe == 1
			qui gen hhead_male_`kind'`i' = hombre if `kind'`i' == 1 & jefe == 1
			qui gen hhead_emp_`kind'`i' = employed`i' if `kind'`i' == 1 & jefe == 1
			qui gen hhead_unemp_`kind'`i' = unemployed`i' if `kind'`i' == 1 & jefe == 1
			qui gen hhead_inf_`kind'`i' = informal`i' if `kind'`i' == 1 & jefe == 1
			qui gen hhead_skilled_`kind'`i' = skilled if `kind'`i' == 1 & jefe == 1
			qui gen hhead_unskilled_`kind'`i' = unskilled if `kind'`i' == 1 & jefe == 1
			qui gen age014_`kind'`i' = age014 if `kind'`i' == 1
			qui gen age1524_`kind'`i' = age1524 if `kind'`i' == 1
			qui gen age2534_`kind'`i' = age2534 if `kind'`i' == 1
			qui gen age3544_`kind'`i' = age3544 if `kind'`i' == 1
			qui gen age4554_`kind'`i' = age4554 if `kind'`i' == 1
			qui gen age5564_`kind'`i' = age5564 if `kind'`i' == 1
			qui gen age65p_`kind'`i' = age65p if `kind'`i' == 1
			qui gen male_`kind'`i' = hombre if `kind'`i' == 1
			qui gen female_`kind'`i' = !hombre if `kind'`i' == 1
			qui gen emp_`kind'`i' = employed`i' if `kind'`i' == 1
			qui gen unemp_`kind'`i' = unemployed`i' if `kind'`i' == 1
			qui gen inf_`kind'`i' = informal`i' if `kind'`i' == 1
			qui gen skilled_`kind'`i' = skilled if `kind'`i' == 1
			qui gen unskilled_`kind'`i' = unskilled if `kind'`i' == 1
			qui gen pub_transf_`kind'`i' = pc_pubtr_s`i' if `kind'`i' == 1
			qui gen priv_transf_`kind'`i' = pc_privttr_s`i' if `kind'`i' == 1
			qui gen pensions_`kind'`i' = pc_pensions_s`i' if `kind'`i' == 1
			qui gen capital_`kind'`i' = pc_capital_s`i' if `kind'`i' == 1
			qui gen otherinla_`kind'`i' = pc_otherinla_s`i' if `kind'`i' == 1 
			qui gen renta_imp_`kind'`i' = pc_renta_imp_s`i' if `kind'`i' == 1 
		}
		
		* Restriction for upper class no transfers
		qui replace pub_transf_new_inuc`i' = 0 if new_inuc`i' == 1
		qui replace pub_transf_always_inuc`i' = 0 if always_inuc`i' == 1
		
		
		* Data collapse
		
		preserve
		qui collapse (sum) pop* /*participation**/ (mean) pc_inc_s* pc_lai_s* pc_nlai_s* pc_pubtr_s* pc_privttr_s* urban_* h_size_* ti_* li_* nli_* hhead_* participation* unemployed* employed* emp_* informal* /*agr_* ind_* ser_* inc_**/ pub_transf_* priv_transf_* age*_* dependency_* male_* female_* skilled_* unskilled_* unemp_* inf_* [fw = fexp_s`i']
		keep *`i'
		ren *`i' *
		qui xpose, clear varname
		ren (v1 _varname) (y_`i' indicator)
		qui order indicator
		sort indicator
		tempfile results_`i'
		qui save `results_`i'', replace
		restore
	}


	* Merge the collapsed data
	use `results_`init'', clear

	forvalues a = `second' / `end' {
		qui merge 1:1 indicator using `results_`a'', nogenerate
	}

	tempfile dynamics
	qui save `dynamics', replace

	use `descriptives', clear
	append using `dynamics'

	sort indicator
	duplicates tag indicator, gen(tag)
	egen nmis=rmiss2(y_*)
	drop if tag == 1 & nmis != 0
	drop tag nmis
	qui export excel using "${outfile}", sheet(descriptives) firstrow(variables) sheetreplace
}

**************************************************************************
* Display running time	
etime
**************************************************************************

**************************************************************************
* END
**************************************************************************

 
/*===================================================================================================
Project:			SAR Poverty Neutral Distribution using GDP and Private Consumption
Institution:		World Bank - ESAPV

Author:				Kelly Y. Montoya
E-mail:				kmontoyamunoz@worldbank.org
Creation Date:		12/16/2024

Last Modification:	Kelly Y. Montoya (kmontoyamunoz@worldbank.org)
Modification date:  12/16/2024
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
gl path  		"$priv_path\exercises"

* Globals for country-year identification
gl cpi_version 	11
gl ppp 			2017	// Change for "yes" / "no" depending on the version
gl country 		"LKA" 	// Country to upload
gl base_y 		2016	// Year to upload - Base year dataset
gl projection	2019	// Year to project

* Globals for country-specific paths
gl inputs   "${path}/${country}\Microsimulation_Inputs_${country}.xlsm" // Country's input Excel file
cap mkdir 	"${path}/${country}\Data"
gl data_out "${path}/${country}\Data"


/*===================================================================================================
	2 - DATA SARMD
===================================================================================================*/

* Support module - CPIs and PPPs
dlw, country(Support) year(2005) type(GMDRAW) surveyid(Support_2005_CPI_v${cpi_version}_M) filename(Final_CPI_PPP_to_be_used.dta)
keep if code == "${country}" & year == ${base_y}
keep code year cpi${ppp} icp${ppp}
rename code countrycode
tempfile dlwcpi
save `dlwcpi', replace
		
* SARMD modules - IND LBR INC
if "${country}" == "BGD" & ${base_y} == 2016 ///
	 dlw, count("${country}") y(${base_y}) t(sarmd) filename(BGD_2016_HIES_v01_M_v07_A_SARMD_IND.dta) clear nocpi

else if "${country}" == "LKA" & inlist(${base_y},2009,2012) ///
	 dlw, count("${country}") y(${base_y}) t(sarmd) filename(LKA_${base_y}_HIES_v01_M_v06_A_SARMD_IND.dta) clear nocpi

else dlw, count("${country}") y(${base_y}) t(sarmd) clear nocpi

* Rename weight
cap gen weight = wgt

* Keep only necessary variables
keep countrycode hhid pid year welfare weight
		
* Merge
merge m:1 countrycode year using `dlwcpi', nogen keep(1 3)


/*===================================================================================================
	3 - DATA MFMOD
===================================================================================================*/

preserve

	use "$path\_inputs\inputs_mpo_gdp.dta", clear
	
	* GDP base year
	gen pc_gdp = gdpconstant / pop
	sum pc_gdp if year == $base_y & countrycode == "$country"
	sca gdp_base = r(mean)
	
	* GDP projected year
	sum pc_gdp if year == $projection & countrycode == "$country"
	sca gdp_proj = r(mean)
	
	* Growth rate
	sca gdp_grth = gdp_proj / gdp_base - 1 
	
	* PC consumption base year
	gen pc_cons = privconstant / pop
	sum pc_cons if year == $base_y & countrycode == "$country"
	sca cons_base = r(mean) 
	
	* PC consumption projected year
	sum pc_cons if year == $projection & countrycode == "$country"
	sca cons_proj = r(mean) 
	
	* Growth rate
	sca cons_grth = cons_proj / cons_base - 1 

restore


/*===================================================================================================
	4 - SIMULATION
===================================================================================================*/

* Convert welfare to real terms
cap drop welfare_ppp
gen welfare_ppp = welfare / cpi$ppp / icp$ppp

* Pass through variables
gen low 	= 0.70
gen med 	= 0.87
gen high 	= 1.00

* New welfare levels
for any low med high : gen welfare_gdp_X = welfare_ppp * (1 + (gdp_grth * X))
for any low med high : gen welfare_cons_X = welfare_ppp * (1 + (cons_grth * X))


/*===================================================================================================
	5 - POVERTY RESULTS
===================================================================================================*/


* Poverty lines
gen time_factor = 365/12

gen pl1 = 2.15 * time_factor
gen pl2 = 3.65 * time_factor
gen pl3 = 6.85 * time_factor

* Poverty rates
loc pts low med high 
loc measures gdp cons

foreach pt of local pts {
	
	foreach measure of local measures {
	
		apoverty welfare_`measure'_`pt' [aw = weight] if welfare_`measure'_`pt' != ., varpl(pl1) h igr gen(poor_`measure'_`pt'_1)
		apoverty welfare_`measure'_`pt' [aw = weight] if welfare_`measure'_`pt' != ., varpl(pl2) h igr gen(poor_`measure'_`pt'_2)
		apoverty welfare_`measure'_`pt' [aw = weight] if welfare_`measure'_`pt' != ., varpl(pl3) h igr gen(poor_`measure'_`pt'_3)
		
		ainequal welfare_`measure'_`pt' [aw = weight]

	
	}
}


/*===================================================================================================
	- Display running time
===================================================================================================*/

etime


/*===================================================================================================
	- END
===================================================================================================*/

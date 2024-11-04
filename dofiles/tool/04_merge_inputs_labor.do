
/*========================================================================
Project:			Microsimulations Inputs - Unified
Institution:		World Bank - ELCPV

Author:				Kelly Y. Montoya (kmontoyamunoz@worldbank.org)
Creation Date:		02/15/2024

Last Modification:	Kelly Y. Montoya (kmontoyamunoz@worldbank.org)
Modification date:  02/15/2024
========================================================================*/

drop _all

**************************************************************************
* 	0 - SETTING
**************************************************************************

* Set up postfile for results
tempname mypost
tempfile myresults
postfile `mypost' str12(Country) Year str40(Indicator) Value using `myresults', replace

*************************************************************************
* 	1 - DATA
*************************************************************************

use "$path\input-labor-sedlac.dta", clear
gen Source = "SEDLAC"
append using "$path\input-labor-microsimulated.dta"
replace Source = "Microsims" if Source == ""

* Quick checks
ta Country
ta Year
ta Country Year
ta Indicator

duplicates report Country Year Indicator

*************************************************************************
* 	2 - SAVING
*************************************************************************

if r(unique_value) != r(N) {
    di in red "Duplicates in the database"
	break
}

else {
    
	di in red "No duplicates in the database"
	
	sort Country Year Indicator
	
	export excel using "$path_mpo/$input_master", sheet("input-labor") sheetreplace firstrow(variables)
	if $mpo_share {
		export excel using "$path_share\input_MASTER.xlsx", sheet("input-labor") sheetreplace firstrow(variables)
		}
}
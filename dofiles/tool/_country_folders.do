
/*========================================================================
Project:			Country-folders' creation
Institution:		World Bank - ELCPV

Author:				Kelly Y. Montoya (kmontoyamunoz@worldbank.org)
Creation Date:		07/05/2024

Last Modification:	Kelly Y. Montoya (kmontoyamunoz@worldbank.org)
Modification date: 	07/05/2024
========================================================================*/

* NOTE: This dofile creates empty country folders in the two round folders' for MPOs microsimulations.

drop _all

* Globals
gl mpo_version 	"FY2025\01_Microsims_AM2024" 					// Folder name in Z disk
gl mpo_ver_sh	"FY2025\01_Microsims_AM2024"					// Folder name in Sharepoint
gl sharep_path	"C:\Users\wb520054\WBG\Knowledge ELCPV - WB Group - General\Regional LAC STATS\LAC_Inputs_Regional_Microsims"							// Change for your personal sharepoint path
gl countries	"ARG BOL BRA CHL COL CRI DOM ECU SLV GTM HND MEX NIC PAN PRY PER URY" 

foreach country of local countries {
	
	*Z disk
	cap mkdir 	"Z:\public\Stats_Team\PLBs\23. Poverty projections simulations\LAC_Inputs_Regional_Microsims/${mpo_version}/`country'"
	
	* Sharepoint
	cap mkdir 	"${sharep_path}/${mpo_version}/`country'"
	
}



cd "C:\Users\wb520054\OneDrive - WBG\02_SAR Stats Team\Microsimulations\AM2024\Data"

use "Crisis\basesim_2024", clear

* Employment - million
*ta active [iw=wgt] if sample == 1 & active == 1
*ta occupation [iw=wgt] if sample == 1

ta active_s [iw=fexp_s] if sample == 1 & active_s == 1
ta emplyd_s [iw=fexp_s] if sample == 1 & active_s == 1
ta occupation_s [iw=fexp_s] if sample == 1

* Employment - distribution
*sum active [iw=wgt] if sample == 1
*sum unemplyd [iw=wgt] if sample == 1
*gen employment_r = occupation != .
*replace employment_r = 0 if inlist(occupation,0,1)
*sum employment_r [iw=wgt] if sample == 1
*ta occupation [iw=wgt] if sample == 1 & !inlist(occupation,0,1,.)

sum active_s [iw=fexp_s] if sample == 1
gen employment_r_s = occupation_s != .
replace employment_r_s = 0 if inlist(occupation_s,0,1)
sum employment_r_s [iw=fexp_s] if sample == 1
sum unemplyd_s [iw=fexp_s] if sample == 1
ta occupation_s [iw=fexp_s] if sample == 1 & !inlist(occupation_s,0,1,.)

* Labor Income
*sum tot_lai [iw=wgt] if sample == 1 & !inlist(occupation,0,1,.)
*bysort occupation: sum tot_lai [iw=wgt] if sample == 1 & !inlist(occupation,0,1,.)
*sum tot_lai [iw=wgt] if sample == 1 & inlist(occupation,3,4) // Industry
*sum tot_lai [iw=wgt] if sample == 1 & inlist(occupation,5,6,7) // Industry

sum tot_lai_s [iw=fexp_s] if sample == 1 & !inlist(occupation_s,0,1,.)
bysort occupation_s: sum tot_lai_s [iw=fexp_s] if sample == 1 & !inlist(occupation_s,0,1,.)
sum tot_lai_s [iw=fexp_s] if sample == 1 & inlist(occupation_s,3,4) // Industry
sum tot_lai_s [iw=fexp_s] if sample == 1 & inlist(occupation_s,5,6,7) // Industry


cd "C:\Users\wb520054\OneDrive - WBG\02_SAR Stats Team\Microsimulations\Regional model\PEA_BGD\BGD\Data"

*use "BGD_2024_6s_dom_no_int_yes_inc_no_cons_no", clear
use "Crisis\BGD_2027_6s_dom_no_int_yes_inc_no_cons_no", clear

* Employment - million
*ta active [iw=wgt] if sample == 1 & active == 1
*ta occupation [iw=wgt] if sample == 1

ta sample [iw=fexp_s] if sample == 1
ta active_s [iw=fexp_s] if sample == 1 & active_s == 1
ta emplyd_s [iw=fexp_s] if sample == 1 & active_s == 1
ta occupation_s [iw=fexp_s] if sample == 1

* Employment - distribution
*sum active [iw=wgt] if sample == 1
*sum unemplyd [iw=wgt] if sample == 1
*gen employment_r = occupation != .
*replace employment_r = 0 if inlist(occupation,0,1)
*sum employment_r [iw=wgt] if sample == 1
*ta occupation [iw=wgt] if sample == 1 & !inlist(occupation,0,1,.)

sum active_s [iw=fexp_s] if sample == 1
gen employment_r_s = occupation_s != .
replace employment_r_s = 0 if inlist(occupation_s,0,1)
sum employment_r_s [iw=fexp_s] if sample == 1
sum unemplyd_s [iw=fexp_s] if sample == 1
ta occupation_s [iw=fexp_s] if sample == 1 & !inlist(occupation_s,0,1,.)

* Labor Income
*sum tot_lai [iw=wgt] if sample == 1 & !inlist(occupation,0,1,.)
*bysort occupation: sum tot_lai [iw=wgt] if sample == 1 & !inlist(occupation,0,1,.)
*sum tot_lai [iw=wgt] if sample == 1 & inlist(occupation,3,4) // Industry
*sum tot_lai [iw=wgt] if sample == 1 & inlist(occupation,5,6,7) // Industry

sum lai_m_s [iw=fexp_s] if sample == 1 & !inlist(occupation_s,0,1,.)
bysort occupation_s: sum lai_m_s [iw=fexp_s] if sample == 1 & !inlist(occupation_s,0,1,.)
sum lai_m_s [iw=fexp_s] if sample == 1 & inlist(occupation_s,2,4,6) // High Skilled
sum lai_m_s [iw=fexp_s] if sample == 1 & inlist(occupation_s,3,5,7) // Low Skilled




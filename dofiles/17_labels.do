*===========================================================================
* TITLE: 17 - labels
*===========================================================================
* Prepared by: Sergio Olivieri
* E-mail: solivieri@worldbank.org
*===========================================================================
* Created on : Jan 11, 2021
* Last update: May 2, 2022
*===========================================================================
* Prepared by: Roberto Castillo A.
* E-mail: robertocastillo@worldbank.org

* Modified by: Kelly Y. Montoya
* Modification: 04/29/2022 Added more variables
*				05/02/2022 Added ppp17
*===========================================================================

*===========================================================================

rename (pondera      informal      occupation      sect_main      ) ///
       (fexp_base informal_base occupation_base sect_main_base )
	   
if "$ppp17" == "no" rename (lai_m lp_550usd_ppp lp_190usd_ppp lp_320usd_ppp)  (lai_base lp_550usd_base lp_190usd_base lp_320usd_base)
else rename (lai_m lp_685usd_ppp lp_365usd_ppp lp_215usd_ppp)  (lai_base lp_685usd_base lp_365usd_base lp_215usd_base)
  
//if $national == 1 {
//rename pc_inc  pc_inc_base
//}

if $national == 0 {
if "$ppp17" == "no" rename ipcf_ppp11  pc_inc_base
else rename ipcf_ppp17  pc_inc_base
}

if "$ppp17" == "no" {
	# delimit;
	local var "
	id pid 
	fexp_base 	  fexp_s 
	edad hombre jefe urbano region raza estado_civil miembros
	 relab ip ii
	informal_base informal_s 
	occupation_base occupation_s 
	sect_main_base sect_main_s 
	lai_m lai_m_s
	lai_base lai_s
	pc_inc_base pc_inc_s pc_inc_bn_s 
	lp_550usd_base lp_550usd_ppp_s 
	lp_190usd_base lp_190usd_ppp_s
	lp_320usd_base lp_320usd_ppp_s
	"
	;
	# delimit cr
	order `var'
	*keep `var'

	rename lp_550usd_ppp_s lp_550usd_s
	rename lp_190usd_ppp_s lp_190usd_s  
	rename lp_320usd_ppp_s lp_320usd_s
}

else {
	# delimit;
	local var "
	id pid 
	fexp_base 	  fexp_s 
	edad hombre jefe urbano region raza estado_civil miembros
	 relab ip ii
	informal_base informal_s 
	occupation_base occupation_s 
	sect_main_base sect_main_s 
	lai_m lai_m_s
	lai_base lai_s
	pc_inc_base pc_inc_s pc_inc_bn_s 
	lp_685usd_base lp_685usd_ppp_s 
	lp_365usd_base lp_365usd_ppp_s
	lp_215usd_base lp_215usd_ppp_s
	"
	;
	# delimit cr
	order `var'
	*keep `var'

	rename lp_685usd_ppp_s lp_685usd_s
	rename lp_365usd_ppp_s lp_365usd_s  
	rename lp_215usd_ppp_s lp_215usd_s
}
*===========================================================================
* labels

label var occupation_base "occupation status -baseline"
label var occupation_s    "occupation status -$scenario"
label var sect_main_base "economic sector -baseline"
label var sect_main_s	 "economic sector -$scenario"
label var informal_s     "informal status -$scenario"
label var lai_m		 	 "labor income main activity -baseline"
label var lai_m_s		 "labor income main activity -$scenario"
label var lai_base		 "labor income -baseline"
label var lai_s			 "labor income -$scenario"
label var pc_inc_base    "per capita income -baseline"
label var pc_inc_s       "per capita income -$scenario"
label var pc_inc_bn_s    "per capita income bonus -$scenario"
cap label var lp_550usd_s  "moderate poverty line -$scenario"
cap label var lp_190usd_s   "extreme  poverty line -$scenario"
cap label var lp_685usd_s  "moderate poverty line -$scenario"
cap label var lp_215usd_s   "extreme  poverty line -$scenario"

* compress
compress
*===========================================================================
*                                     END
*===========================================================================

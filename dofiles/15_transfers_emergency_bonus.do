*===========================================================================
* TITLE: Transfer programs
*===========================================================================
* Prepared by: Sergio Olivieri
* E-mail: solivieri@worldbank.org
*===========================================================================
* Created on : Mar 17, 2020
* Last update: Jan 04, 2021
*===========================================================================

*===========================================================================
* Criteria to select beneficiaries - Emergency bonus
*============================================================================

if $bonus == 1 {

* 1.- HH is poor 
gen crt1 = 1 if pc_inc_s < lp_moderada_s

* 2.- HH does not receive BDH
capture drop aux
egen aux = sum(cct), by(id)
gen crt2 = 1 if inlist(aux,.,0)

* 3.- At least one household member is informal worker
capture drop aux
egen aux = sum(informal_s), by(id)
gen crt3 = 1 if aux > 0 & aux < .

* 4: HH income less than Family Vital Basket 
gen crt4 = 1 if h_inc_s < 502 & h_inc_s !=.

* Elegibility
gen   eleg = 1 if crt1 == 1 & crt2 == 1 & crt3 == 1 & h_head == 1

drop crt*

*===========================================================================
* Maximum impact on poverty headcount
*===========================================================================

* gap of poverty
capture drop aux
gen gap = abs(pc_inc_s - lp_moderada_s) if  eleg == 1
* sort - los mas cercanos a linea de pobreza
sort eleg gap, stable
* number of households
gen m = sum(fexp_s) if jefe == 1
* number of persons who receive BDH
gen cct2 = 1 if cct > 0 & cct < .
sum cct2 [aw = fexp_s]

*===========================================================================
* Phases
*===========================================================================

* 1st phase : habilitados 400.019; efectivamente cobraron 377.452
gl b_phase1 = (377452/1029818)
* number of persons who receive BDH
sum cct2 [aw = fexp_s]
* asignar bono
gen phase1 = 1 if m <= r(sum)* $b_phase1 & jefe == 1 & eleg == 1
* transferencia per capita
capture drop aux
gen aux = (120/12)/h_size if phase1 == 1
egen bono_f1 = sum(aux), by(id)

* 2nd phase : habilitados 549.986; efectivamente cobraron 366.769
gl b_phase2 = (366769/1029818)
* number of persons who receive BDH
sum cct2 [aw = fexp_s]
* asignar bono
gen phase2 = 1 if (m > r(sum)* $b_phase1 ) &  (m <= r(sum)*( $b_phase1 + $b_phase2 ) ) & jefe == 1 & eleg == 1
* transferencia per capita
capture drop aux
gen aux = (120/12)/h_size if phase2 == 1
egen bono_f2 = sum(aux), by(id)

*==========================================================================
* total bonus 
egen bonus_x = rowtotal(bono_f1 bono_f2), missing 

* nuevo ingreso per capita del hogar
egen    pc_inc_bn_s = rowtotal(pc_inc_s bono_f1 bono_f2), missing
replace pc_inc_bn_s = . if pc_inc_s == .

drop gap m cct2 phase* aux
}

if $bonus == 0 {
	gen bonus_x = .
	gen pc_inc_bn_s = pc_inc_s
}


*===========================================================================
*                                     END
*===========================================================================

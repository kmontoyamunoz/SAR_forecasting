
		
* SARMD modules - IND LBR INC
cap dlw, count("BGD") y(2022) t(sarlab) clear 
	if !_rc {
		di in red "BGD 2022 loaded in datalibweb"
		tempfile BGD
		save `BGD', replace
	}
	if _rc {
		di in red "BGD 2022 NOT loaded in datalibweb"
		continue
	}		
	
* Merge
use `BGD'
merge m:1 countrycode year using `dlwcpi', nogen keep(1 3)


* CPIs from Inflation Database, DEC
* https://www.worldbank.org/en/research/brief/inflation-database
copy https://thedocs.worldbank.org/en/doc/1ad246272dbbc437c74323719506aa0c-0350012021/related/Inflation-data.zip Inflation-data.zip 
unzipfile Inflation-data.zip 

local files "ccpi_a ccpi_m ccpi_q def_a def_q ecpi_a ecpi_m ecpi_q fcpi_a fcpi_m fcpi_q hcpi_a hcpi_m hcpi_q ppi_a ppi_m ppi_q"
foreach f of local files {
	copy "`f'.dta" "C:\Users\wb520054\OneDrive - WBG\02_SAR Stats Team\Microsimulations\Regional model\CPIs/`f'.dta", replace
	erase "`f'.dta"
}

use "C:\Users\wb520054\OneDrive - WBG\02_SAR Stats Team\Microsimulations\Regional model\CPIs\hcpi_m.dta", clear
ren *, lower
ta code
drop imf indicator seriesname datasource country note
sort code 
destring _*, replace force
reshape long _, i(code) j(period)
ren _ cpi

gen year = floor(period/100)
gen month = mod(period, 100)
drop period

bysort code year: egen yearly_cpi = mean(cpi)
bysort code: egen aux = mean(cpi) if year == 2017
bysort code: egen cpi_2017 = mean(aux)
gen cpi2017 = yearly_cpi/cpi_2017
drop aux
compress

keep if code == "BGD"

* Dlw support module - PPPs
preserve
cap dlw, country(Support) year(2005) type(GMDRAW) surveyid(Support_2005_CPI_v${cpi_version}_M) filename(Final_CPI_PPP_to_be_used.dta)
keep if code == "BGD"
keep code year icp2017
sum icp2017
scalar ppp = r(mean)
restore

gen ppp2017 = ppp 


gen     cpi = .

if `y'==2010 {
replace cpi = 1

/* La LFS en 2015 se relevó en mayo 
   96.409 es el CPI de abril de 2015 */

gen     wage_nc_real = .
replace wage_nc_real = wage_nc * 4.3 / cpi    if s4_9==1 | s4_9==7 | s4_9==8 | s4_9==9 

/* se multiplica por 4.3 porque es el ingreso semanal*/
}

if `y'==2016 {
replace cpi = 1.618970938

/* La LFS en 2016 se relevó entre julio de 2016 y junio de 2017 
   156.0833692 es el CPI promedio entre junio de 2016 y mayo de 2017 */

gen     wage_nc_real = .
replace wage_nc_real = wage_nc / cpi    if q49==4 | q49==5 | q49==7
}

if `y'==2022 {
replace cpi = 2.223547421

/* La LFS en 2022 se relevó entre enero de 2022 y diciembre de 2022 
    214.3699833 es el CPI promedio entre diciembre de 2021 y noviembre de 2022 */

gen     wage_nc_real = .
replace wage_nc_real = wage_nc / cpi    if mj_05==1
}



/*
Are We Moving Towards A Low-Carbon Energy-Efficient Economy?
A Decomposition of Energy-Related CO2 Emissions in Spain and EU28, 1995-2017
20. Energy efficiency decomposition
Darío Serrano Puente (2020)

Last update: November 11th, 2020
*/

********************************************************************************
// 0. Preamble
********************************************************************************
clear all
set more off
timer clear 1
timer on 1

// Define input/output directories
// global basePath "X:\Dga_EI\AEstructural\Climate change\Low Carbon Energy Efficiency"
global basePath "W:\AMICRO\Darío\Climate Change\Low Carbon Energy Efficiency"
global figurePath "$basePath\Figures"
global dataPath "$basePath\Data"
global codePath "$basePath\Codes"
global tablePath "$basePath\Tables"
global LaTeXPath "$basePath\Paper\Figures"

grstyle init
grstyle set plain, horizontal grid
grstyle set legend 11, inside nobox


********************************************************************************
// 1. Import data for Sectoral RE for Spain
********************************************************************************
// 1.1 Economy-wide RE estimates by product and sector
import excel "$dataPath\Review Rebound Effect Estimates.xlsx", sheet("Arocena et al. for paper") firstrow clear
// Correct for bias - Guerra & Sancho (2010)
/*
foreach var in AGRI IND_EEI IND_FBT IND_TL IND_WWP ///
IND_PPP IND_CPC IND_NMM IND_BM IND_MAC IND_TE IND_OI ///
IND_CON CPS HH TRA {
replace `var' = `var' + (-0.3092*`var' + 0.28895)
}
*/
save "$dataPath\Intermediate.dta", replace

// 1.2 FEC
use "$dataPath\FEC_by_Sector_Eurostat_ODYSSEE.dta", clear
gen product_g = ""
replace product_g = "Coal" if inlist(product_group_code,1,2,3,4)
replace product_g = "Crude" if product_id == 18
replace product_g = "Refining" if product_id >= 19 & product_id <= 39
replace product_g = "Gas" if product_id == 40
replace product_g = "Electricity" if product_id == 63
drop if product_g == ""
// Generate total by energy product group for RE estimates
local product `" "Coal" "Crude" "Refining" "Electricity" "Gas" "'
foreach var in FEC_TOT FEC_AGRI FEC_IND_EEI FEC_IND_FBT FEC_IND_TL FEC_IND_WWP ///
FEC_IND_PPP FEC_IND_CPC FEC_IND_NMM FEC_IND_BM FEC_IND_MAC FEC_IND_TE FEC_IND_OI ///
FEC_IND_CON FEC_IND FEC_CPS FEC_HH FEC_TRA{
bysort year geo product_g: egen `var'_aux = total(`var')
replace `var' = `var'_aux
drop `var'_aux
}
// Sintetize dataset
drop if geo != "ES"
duplicates drop year geo product_g, force
keep FEC_TOT FEC_AGRI FEC_IND_EEI FEC_IND_FBT FEC_IND_TL FEC_IND_WWP ///
FEC_IND_PPP FEC_IND_CPC FEC_IND_NMM FEC_IND_BM FEC_IND_MAC FEC_IND_TE FEC_IND_OI ///
FEC_IND_CON FEC_IND FEC_CPS FEC_HH FEC_TRA year product_g 

// 1.2 Merge
merge m:1 product_g using "$dataPath\Intermediate.dta"
drop _merge
erase "$dataPath\Intermediate.dta"

********************************************************************************
// 2. Calculate Sectoral and Total RE estimates for Spain
********************************************************************************
foreach var in AGRI IND_EEI IND_FBT IND_TL IND_WWP ///
IND_PPP IND_CPC IND_NMM IND_BM IND_MAC IND_TE IND_OI ///
IND_CON CPS HH TRA {
gen RE_`var' = `var'
// replace RE_`var' = 0 if FEC_`var' == 0
// Adjust FEC with no FEC for parts with no RE estimate
replace FEC_`var' = 0 if RE_`var' == .
// Complete RE series
replace RE_`var' = 0 if RE_`var' == .
}
// Generate FEC Industry total
drop FEC_IND
gen FEC_IND = FEC_IND_EEI + FEC_IND_FBT + FEC_IND_TL + FEC_IND_WWP + ///
FEC_IND_PPP + FEC_IND_CPC + FEC_IND_NMM + FEC_IND_BM + FEC_IND_MAC + ///
FEC_IND_TE + FEC_IND_OI + FEC_IND_CON
// Generate FEC Total
drop FEC_TOT
gen FEC_TOT = FEC_AGRI + FEC_IND + FEC_CPS + FEC_HH + FEC_TRA
// Generate totals of all products
foreach var in FEC_TOT FEC_AGRI FEC_IND_EEI FEC_IND_FBT FEC_IND_TL FEC_IND_WWP ///
FEC_IND_PPP FEC_IND_CPC FEC_IND_NMM FEC_IND_BM FEC_IND_MAC FEC_IND_TE FEC_IND_OI ///
FEC_IND_CON FEC_IND FEC_CPS FEC_HH FEC_TRA{
bysort year: egen `var'_Tot = total(`var')
}
// Generate RE estimates for industry by energy product
gen RE_IND = 0
foreach var in IND_EEI IND_FBT IND_TL IND_WWP IND_PPP IND_CPC IND_NMM IND_BM ///
IND_MAC IND_TE IND_OI IND_CON{
replace RE_IND = RE_IND + FEC_`var'*RE_`var'
}
replace RE_IND = RE_IND/FEC_IND
replace RE_IND = 0 if FEC_IND == 0
// Generate RE estimates for total by energy product
gen RE_TOT = 0
foreach var in AGRI IND CPS HH TRA{
replace RE_TOT = RE_TOT + FEC_`var'*RE_`var'
}
replace RE_TOT = RE_TOT/FEC_TOT
replace RE_TOT = 0 if FEC_TOT == 0
// Generate RE estimates for each sector group (but for all energy types)
foreach var in TOT AGRI IND CPS HH TRA{
bysort year: asgen RE_`var'_Tot = RE_`var', w(FEC_`var')
}
// Keep total RE
duplicates drop year, force
keep year RE*Tot
save "$dataPath\RE_Estimates_Sectoral_Spain.dta", replace

********************************************************************************
// 3. EE Decomposition for Spain by sector
********************************************************************************
import excel "$tablePath\RE_table.xlsx", sheet("Evolution Eff & FEC") firstrow clear
keep if geo == "ES"
keep year EFF*
merge 1:1 year using "$dataPath\RE_Estimates_Sectoral_Spain.dta"
drop _merge
// Generate changes and time series
keep if inlist(year,1995,2007,2017)
sort year
egen time_id = group(year)
tset time_id
foreach sec in AGRI IND CPS HH TRA{
foreach var in EFF_`sec'_app_1995 EFF_`sec'_odex_1995{
gen delta_`var' = `var' - L.`var'
}
}
foreach var in AGRI IND CPS HH TRA{
gen delta_RE_`var' = - RE_`var'_Tot*delta_EFF_`var'_odex_1995
gen delta_Infra_`var' = delta_EFF_`var'_app_1995 - delta_EFF_`var'_odex_1995 - delta_RE_`var'
// gen check_`var' = delta_EFF_`var'_app_1995 - delta_EFF_`var'_odex_1995 - delta_RE_`var' - delta_Infra_`var'
}
// Export to Excel
keep year delta*
export excel using "$tablePath\RE_table.xlsx", sheet("Contributions Eff") sheetmodify firstrow(variables)

********************************************************************************
// 4. Import data for Total RE for Spain and EU
********************************************************************************
// 4.1 Economy-wide RE estimates by country/region
import excel "$dataPath\Review Rebound Effect Estimates.xlsx", sheet("Adetutu et al. (2016) for paper") firstrow clear
keep if year >= 1995
save "$dataPath\Intermediate.dta", replace

********************************************************************************
// 5. Total EE Decomposition for Spain and EU
********************************************************************************
import excel "$tablePath\RE_table.xlsx", sheet("Evolution Eff & FEC") firstrow clear
replace geo = "EU" if geo == "EU28"
merge 1:1 year geo using "$dataPath\Intermediate.dta"
drop _merge
erase "$dataPath\Intermediate.dta"
// Generate changes and time series
sort geo year
egen geo_id = group(geo)
egen time_id = group(year)
xtset geo_id time_id
foreach var in EFF_TOT_app_1995 EFF_TOT_odex_1995{
gen delta_`var' = `var' - L.`var'
}
gen delta_RE = - RE_TOT_Tot*delta_EFF_TOT_odex_1995
gen delta_Infra = delta_EFF_TOT_app_1995 - delta_EFF_TOT_odex_1995 - delta_RE
// gen check = delta_EFF_TOT_app_1995 - delta_EFF_TOT_odex_1995 - delta_RE - delta_Infra

********************************************************************************
// 6. Compute Additive Evolution and Figures
********************************************************************************
rename (delta_EFF_TOT_app_1995 delta_EFF_TOT_odex_1995 delta_RE delta_Infra) ///
(d_app d_tech d_re d_oth)
sort geo year
foreach var in d_app d_tech d_re d_oth{
gen cum_`var' = 0
replace cum_`var' = EFF_TOT_app_1995 if year == 1995
}
forvalues y = 1996(1)2017{
foreach var in d_app d_tech d_re d_oth{
replace cum_`var' = cum_`var'[_n-1] + `var'[_n] if year == `y'
}
}
foreach var in d_app d_tech d_re d_oth{
gen base_`var' = cum_`var' if year == 1995
bysort geo: replace base_`var' = base_`var'[1]
gen cum_`var'_index = cum_`var'/base_`var'*100
drop base*
}
// Figures
sort geo year
local geo `" "EU" "ES" "'
foreach g of local geo{
qui twoway (line cum_d_app_index year if geo == "`g'", lcolor("0 64 129") lwidth(medthick) lpattern("---")) ///
(line cum_d_tech_index year if geo == "`g'", lcolor("26 140 255") lwidth(medthick)) ///
(line cum_d_re_index year if geo == "`g'", lcolor("218 108 122") lwidth(medthick)) ///
(line cum_d_oth_index year if geo == "`g'", lcolor("255 190 93") lwidth(medthick)), ///
xtitle("", size(medium)) ylabel(75 100 125 150, labsize(medlarge)) ytitle("Index (base 1995)", size(medium)) xlabel(1995 1998 2001 2004 2007 2010 2013 2017, labsize(medlarge)) ///
yline(100, lcolor(black) lwidth(medium) lpattern("--")) ///
plotregion(fcolor(white) lcolor(black)) graphregion(fcolor(white) ifcolor(white) color(white) icolor(white)) bgcolor(white) ///
legend(order(1 "Apparent EE" 2 "Technical EE" 3 "Rebound effect" 4 "Other factors") rows(2) region(lstyle(none)) size(medlarge) region(lwidth(none)))
graph export "$LaTeXPath\EE_decomp_`g'.pdf", as (pdf) replace
}





timer off 1
timer list 1
dis "Computing time of routine 1: " round(r(t1)/60, 0.1) " minutes"

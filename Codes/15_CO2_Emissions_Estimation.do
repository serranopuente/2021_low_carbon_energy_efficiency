/*
Are We Moving Towards A Low-Carbon Energy-Efficient Economy?
A Decomposition of Energy-Related CO2 Emissions in Spain and EU28, 1995-2017
15. Estimation of CO2 emissions
Darío Serrano Puente (2020)

Last update: April 19th, 2020
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
// Install if not yet installed
/*
ssc install spmap
ssc install shp2dta
ssc install mif2dta
*/
grstyle init
grstyle set plain, horizontal grid

********************************************************************************
// 1. Create panel
********************************************************************************
// Emission factor data
use "$dataPath\Energy_Balances_Eurostat_IPCC_Emission_Factor.dta", clear
keep year geo product product_code product_id product_group product_group_code NCV ox_fraction CO2_emission_factor CC
// Final energy consumption data
merge m:m year geo product_id using "$dataPath\FEC_by_Sector_Eurostat_ODYSSEE.dta"
drop  if _merge == 1 // i.e. drop totals (aggregates with no group code) and 2018 data
drop _merge
// Leontief inverse (input-output table)
merge m:m year geo product_id using "$dataPath\Leontief_Inverse_Input-Output.dta"
drop _merge
replace associate = product_id if associate == .
foreach var in NCV ox_fraction CO2_emission_factor CC{
bysort year geo associate: egen aux = max(`var')
replace `var' = aux if duplicated == 1
drop aux
}
// Transpose CO2 factor to facilitate later calculus of CO2 emissions
qui levelsof product_id, local(prod)
foreach p of local prod{
qui:{
gen CO2_`p' = CO2_emission_factor*41.868 if product_id == `p' // Note that 1 KTOE is 41.868 TJ
egen aux_`p' = max(CO2_`p') // Factor does not change between regions and years
replace CO2_`p' = aux_`p'
drop aux_`p'
}
}
// Adjust space heating and air conditioning consumption in services and households
merge m:1 year geo using "$dataPath\HDD_CDD_Eurostat.dta"
drop if _merge == 2 // Year 2018 in the HDD data
drop _merge
foreach var in CPS HH{
replace FEC_`var'_SH = FEC_`var'_SH*(HDD/HDD_ref)
replace FEC_`var'_AC = FEC_`var'_AC*(CDD/CDD_ref)
}
replace FEC_CPS = (FEC_CPS_SH + FEC_CPS_HW + FEC_CPS_COOK + FEC_CPS_AC + FEC_CPS_LIGHT)
replace FEC_HH = (FEC_HH_SH + FEC_HH_HW + FEC_HH_COOK + FEC_HH_AC + FEC_HH_LIGHT)
replace FEC_ECO = (FEC_AGRI + FEC_IND + FEC_CPS)
replace FEC_TOT = (FEC_ECO + FEC_HH + FEC_TRA)
drop HDD* CDD*
sort year geo product_id

********************************************************************************
// 2. Generate KPEQ and KC for each fuel, year and region 
// KPEQ is the primary energy quantity conversion factor of each fuel
// KC is the primary CO2 emission factor of energy expressed in PEQ form
// KC_SQ is thep rimary CO2 emission factor of energy expressed in SQ form
********************************************************************************
foreach p of local prod{
gen KC_intermediate_`p' = (L_`p'/KPEQ)*CO2_`p'
}
egen KC = rowtotal(KC_intermediate_*)
label var KC "Primary CO2 emission factor of energy expressed in PEQ form; Kg-CO2/KTOE"
foreach p of local prod{
gen KC_SQ_intermediate_`p' = L_`p'*CO2_`p'
}
egen KC_SQ = rowtotal(KC_SQ_intermediate_*)
// KC_SQ must be the same of KPEQ*KC in total
gen KPEQ_KC = KPEQ*KC
gen check = KPEQ_KC - KC_SQ
sum check
drop check CO2* KC_intermediate*
// 2.1 Tables with KPEQ in 1995, 2007 and 2017
preserve
drop if year != 1995 & year != 2007 & year != 2017
foreach j of local prod{
gen share_`j' = L_`j'/KPEQ
replace share_`j' = 0 if share_`j' == .
}
qui levelsof product_group_code, local(group)
foreach g of local group{
gen share_group_`g' = 0
qui levelsof product_id if product_group_code == `g', local(prod)
foreach p of local prod{
replace share_group_`g' = share_group_`g' + share_`p'
}
}
gen share_oth = share_group_2 + share_group_3 + share_group_4 + share_group_8 + share_group_10 + share_group_11
rename (share_group_1 share_group_5 share_group_6 share_group_7 share_group_9) (share_fos share_oil share_ng share_ren share_nuc)
gen PEQ = KPEQ*FEC_TOT
keep if inlist(product_id, 63,62,32,26,40,47)
generate neg = - product_id
sort geo neg year
keep year geo product KPEQ share_fos share_oil share_ng share_ren share_nuc share_oth
order year geo product KPEQ share_fos share_oil share_ng share_ren share_nuc share_oth
export excel using "$tablePath\KPEQ_table.xlsx", sheet("Stata Output") sheetmodify firstrow(variables)
restore

********************************************************************************
// 3. Estimate primary energy requirements and energy-related CO2 emissions
********************************************************************************
// 3.1 Estimate primary energy requirements
preserve
foreach var in INTMARB INTAVI NRG_E DL FC_NE FC_E STATDIFF NET_EXP_BAL FD FEC_TOT ///
FEC_ECO FEC_AGRI_AF FEC_AGRI_FISH FEC_AGRI FEC_IND_EEI FEC_IND_FBT FEC_IND_TL ///
FEC_IND_WWP FEC_IND_PPP FEC_IND_CPC FEC_IND_NMM FEC_IND_BM FEC_IND_MAC FEC_IND_TE ///
FEC_IND_OI FEC_IND_CON FEC_IND FEC_CPS FEC_CPS_SH FEC_CPS_HW FEC_CPS_COOK FEC_CPS_AC ///
FEC_CPS_LIGHT FEC_HH FEC_HH_SH FEC_HH_HW FEC_HH_COOK FEC_HH_AC FEC_HH_LIGHT ///
FEC_TRA FEC_TRA_PASS FEC_TRA_FR FEC_TRA_PASS_ROAD FEC_TRA_FR_ROAD FEC_TRA_PASS_RAIL ///
FEC_TRA_FR_RAIL FEC_TRA_PASS_AVI FEC_TRA_FR_NAVI FEC_TRA_FR_PIPE{
gen PEQ_`var' = KPEQ*`var'
bysort year geo: egen PEQ_`var'_Tot = total(PEQ_`var')
}
gen PEQ_TES = PEQ_NRG_E + PEQ_DL + PEQ_FC_NE + PEQ_FC_E
gen PEQ_TES_Tot = PEQ_NRG_E_Tot + PEQ_DL_Tot + PEQ_FC_NE_Tot + PEQ_FC_E_Tot
// Figure Requirements
gen aux = PEQ_TES_Tot if year == 1995
bysort geo: egen base = max(aux)
gen PEQ_TES_Tot_index = PEQ_TES_Tot / base *100
sort geo year
drop aux
qui twoway (line PEQ_TES_Tot_ind year if geo == "ES" & product_id == 1, mcolor("163 41 56") lwidth(medthick)) ///
(line PEQ_TES_Tot_ind year if geo == "EU28" & product_id == 1, mcolor("0 64 129") lwidth(medthick) lpattern("---")), ///
ytitle("Index (base 1995)",size(medium) margin(vsmall)) xtitle("", margin(medium) size(vsmall)) xlabel(, labgap(*3) angle(0) noticks labsize(medium)) ylabel(,labsize(medium)) ///
xline(2007, lcolor(black) lwidth(medium) lpattern("--")) ///
legend(order(1 "Spain" 2 "EU28") rows(1) ring(1) position(6) region(lstyle(none)) size(medium) region(lwidth(none))) ///
plotregion(fcolor(white) lcolor(black)) graphregion(fcolor(white) ifcolor(white) color(white) icolor(white)) bgcolor(white) 
graph export "$LaTeXPath\peq_evo.pdf", as (pdf) replace
drop if year != 1995 & year != 2007 & year != 2017
qui levelsof product_group_code, local(group)
foreach g of local group{
bysort year geo: egen aux = total(PEQ_TES) if product_group_code == `g'
bysort year geo: egen PEQ_TES_`g' = max(aux)
drop aux
}
keep year geo PEQ*Tot PEQ_TES_1 - PEQ_TES_11
duplicates drop year geo, force
export excel using "$tablePath\PEQ_Table.xlsx", sheet("Stata Output") sheetmodify firstrow(variables)
restore
// 3.2 Estimate energy-related CO2 emissions of end-use sectors
foreach var in TOT ECO AGRI_AF AGRI_FISH AGRI IND_EEI ///
IND_FBT IND_TL IND_WWP IND_PPP IND_CPC IND_NMM ///
IND_BM IND_MAC IND_TE IND_OI IND_CON IND CPS ///
CPS_SH CPS_HW CPS_COOK CPS_AC CPS_LIGHT HH HH_SH ///
HH_HW HH_COOK HH_AC HH_LIGHT TRA TRA_PASS TRA_FR ///
TRA_PASS_ROAD TRA_FR_ROAD TRA_PASS_RAIL TRA_FR_RAIL ///
TRA_PASS_AVI TRA_FR_NAVI TRA_FR_PIPE{
bysort year geo: gen CO2_`var' = (FEC_`var'*KPEQ*KC)/1000000000
label var CO2_`var' "Energy-related CO2 emissions by fuel - `var'; Tg C02"
bysort year geo: egen CO2_`var'_Tot = total(CO2_`var')
label var CO2_`var'_Tot "Total Energy-related CO2 emissions - `var'; Tg C02"
}
foreach var in INTMARB INTAVI NRG_E DL FC_NE FC_E STATDIFF NET_EXP_BAL FD{
bysort year geo: gen CO2_`var' = (`var'*KPEQ*KC)/1000000000
label var CO2_`var' "Energy-related CO2 emissions by fuel - `var'; Tg C02"
bysort year geo: egen CO2_`var'_Tot = total(CO2_`var')
label var CO2_`var'_Tot "Total Energy-related CO2 emissions - `var'; Tg C02"
}
preserve
drop if year != 1995 & year != 2017
qui levelsof product_group_code, local(group)
foreach g of local group{
bysort year geo: egen aux = total(CO2_TOT) if product_group_code == `g'
bysort year geo: egen CO2_TOT_`g' = max(aux)
drop aux
}
keep year geo CO2*Tot CO2_TOT_1 - CO2_TOT_11
duplicates drop year geo, force
sort geo year
export excel using "$tablePath\C_Table.xlsx", sheet("Stata Output") sheetmodify firstrow(variables)
restore
// Check total emissions is the same as the sum of sectors
gen check = CO2_TOT - (CO2_ECO + CO2_HH + CO2_TRA)
sum check
drop check
// 3.3 Tables with KC and KC_SQ in 1995 and 2017
preserve
drop if year != 1995 & year != 2017
qui levelsof product_id, local(prod)
foreach j of local prod{
gen share_`j' = KC_SQ_intermediate_`j'/KC_SQ
replace share_`j' = 0 if share_`j' == .
}
qui levelsof product_group_code, local(group)
foreach g of local group{
gen share_group_`g' = 0
qui levelsof product_id if product_group_code == `g', local(prod)
foreach p of local prod{
replace share_group_`g' = share_group_`g' + share_`p'
}
}
gen share_oth = share_group_2 + share_group_3 + share_group_4 + share_group_8 + share_group_10 + share_group_11
rename (share_group_1 share_group_5 share_group_6 share_group_7 share_group_9) (share_fos share_oil share_ng share_ren share_nuc)
keep if inlist(product_id, 63,62,32,26,40,47)
generate neg = - product_id
sort geo neg year 
replace KC = KC/1000000
replace KC_SQ = KC_SQ/1000000
keep year geo product KC KC_SQ share_fos share_oil share_ng share_ren share_nuc share_oth
order year geo product KC KC_SQ share_fos share_oil share_ng share_ren share_nuc share_oth
export excel using "$tablePath\KC_table.xlsx", sheet("Stata Output") sheetmodify firstrow(variables)
restore
drop if duplicated == 1
drop duplicated associate

// Figure Emissions
preserve
duplicates drop year geo, force
gen aux = CO2_TOT_Tot if year == 1995
bysort geo: egen base = max(aux)
gen CO2_TOT_Tot_index = CO2_TOT_Tot / base *100
sort geo year
qui twoway (line CO2_TOT_Tot_ind year if geo == "ES", mcolor("163 41 56") lwidth(medthick)) ///
(line CO2_TOT_Tot_ind year if geo == "EU28", mcolor("0 64 129") lwidth(medthick) lpattern("---")), ///
ytitle("Index (base 1995)",size(medium) margin(vsmall)) xtitle("", margin(medium) size(vsmall)) xlabel(1995 1998 2001 2004 2007 2010 2013 2017, labgap(*3) angle(0) noticks labsize(medium)) ylabel(,labsize(medium)) ///
xline(2007, lcolor(black) lwidth(medium) lpattern("--")) yline(100, lcolor(black) lwidth(medium) lpattern("--")) ///
legend(order(1 "Spain" 2 "EU28") rows(1) ring(1) position(6) region(lstyle(none)) size(medium) region(lwidth(none))) ///
plotregion(fcolor(white) lcolor(black)) graphregion(fcolor(white) ifcolor(white) color(white) icolor(white)) bgcolor(white) 
graph export "$LaTeXPath\emissions_evo.pdf", as (pdf) replace
restore

********************************************************************************
// 4. Save FEC and CO2 estimates
********************************************************************************
keep year geo product* KPEQ KC CO2*
order year geo product* KPEQ KC CO2*
sort year geo product_id
save "$dataPath\Estimates_Energy-Related_CO2.dta", replace


timer off 1
timer list 1
dis "Computing time of routine 1: " round(r(t1)/60, 0.1) " minutes"

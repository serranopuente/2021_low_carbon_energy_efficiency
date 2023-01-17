/*
Are We Moving Towards A Low-Carbon Energy-Efficient Economy?
A Decomposition of Energy-Related CO2 Emissions in Spain and EU28, 1995-2017
07. Panel Production Volume Indexes - Eurostat
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
global basePath "C:\Users\Pc\Google Drive\Research\Climate Change\Low Carbon Energy Efficiency"
global figurePath "$basePath\Figures"
global dataPath "$basePath\Data"
global codePath "$basePath\Codes"
global tablePath "$basePath\Tables"
global LaTeXPath "$basePath\Paper\Figures"

********************************************************************************
// 1. Download raw data and reshape to have year geo on the left and 
// magnitudes on the top
********************************************************************************
// Production in industry - annual data
eurostatuse sts_inpr_a, noflags long geo(EU28 ES) start(1995) keepdim(CA;PROD;I15) clear
// Clean database
drop geo_label unit_label unit s_adj_label s_adj indic_bt_label indic_bt
rename (time nace_r2_label nace_r2) (year nace nace_code)
// Years and countries in rows and balance variables in columns
levelsof nace_code, local(variables)
foreach k of local variables{
preserve
keep if nace_code == "`k'"
gen firstpart = substr(nace_code,1, strpos(nace_code, "-")-1)
gen lastpart = substr(nace_code, strpos(nace_code, "-") + 1, .)
gen new = firstpart + lastpart
local label_name = nace[1]
local name = new[1]
rename sts_inpr_a `name'
label var `name' "Volume Index Production - `label_name' - 2015=100, calendar adjusted data"
drop nace* *part new
save "$dataPath\Intermediate_`k'.dta", replace
restore
}
keep year geo
duplicates drop year geo, force
order year geo
foreach k of local variables{
merge 1:1 year geo using "$dataPath\Intermediate_`k'.dta"
drop _merge
erase "$dataPath\Intermediate_`k'.dta"
}
save "$dataPath\Intermediate_Ind.dta", replace

********************************************************************************
// 2. Include construction
********************************************************************************
// Production in construction - annual data
eurostatuse sts_copr_a, noflags long geo(EU28 ES) start(1995) keepdim(CA;PROD;I15) clear
// Clean database
drop geo_label unit_label unit s_adj_label s_adj indic_bt_label indic_bt
rename (time nace_r2_label nace_r2) (year nace nace_code)
// Years and countries in rows and balance variables in columns
levelsof nace_code, local(variables)
foreach k of local variables{
preserve
keep if nace_code == "`k'"
gen firstpart = substr(nace_code,1, strpos(nace_code, "-")-1)
gen lastpart = substr(nace_code, strpos(nace_code, "-") + 1, .)
gen new = firstpart + lastpart
local label_name = nace[1]
local name = new[1]
rename sts_copr_a `name'
label var `name' "Volume Index Production - `label_name' - 2015=100, calendar adjusted data"
drop nace* *part new
save "$dataPath\Intermediate_`k'.dta", replace
restore
}
keep year geo
duplicates drop year geo, force
order year geo
foreach k of local variables{
merge 1:1 year geo using "$dataPath\Intermediate_`k'.dta"
drop _merge
erase "$dataPath\Intermediate_`k'.dta"
}
save "$dataPath\Intermediate_Con.dta", replace

********************************************************************************
// 3. Merge all intermediate datasets (one dataset per magnitude)
********************************************************************************
use "$dataPath\Intermediate_Ind.dta", clear
merge 1:1 year geo using "$dataPath\Intermediate_Con.dta"
erase "$dataPath\Intermediate_Ind.dta"
erase "$dataPath\Intermediate_Con.dta"
drop _merge

********************************************************************************
// 4. Keep just relevant variables for analysis
********************************************************************************
keep year geo B C10C12 C10_C11 C10 C11 C12 C13C15 C16 C17 C18 C19 C20_C21 C22 C23 C24 ///
C25 C26 C27 C28 C29_C30 C31 C32 D F
// Save intermediate Dataset
save "$dataPath\Intermediate.dta", replace

********************************************************************************
// 5. Identify the gaps prior to 2018 and fill them out
********************************************************************************
// 5.1 Download GVA data to observe trends of the magnitudes and use it as weight
// to fill gaps in PVI data
// National accounts aggregates by industry (up to NACE A*64)
eurostatuse nama_10_a64, noflags long geo(EU28 ES) start(1995) keepdim(B1G; CLV15_MEUR) clear
// Clean database
drop unit unit_label geo_label na_item_label na_item
rename (time nace_r2_label nace_r2) (year nace nace_code)
// Years and countries in rows and balance variables in columns
levelsof nace_code, local(variables)
foreach k of local variables{
preserve
keep if nace_code == "`k'"
gen firstpart = substr(nace_code,1, strpos(nace_code, "-")-1)
gen lastpart = substr(nace_code, strpos(nace_code, "-") + 1, .)
gen new = firstpart + lastpart
local label_name = nace[1]
local name = new[1]
rename nama_10_a64 `name'
label var `name' "GVA - `label_name'"
drop nace* *part new
save "$dataPath\Intermediate_`k'.dta", replace
restore
}
// Merge all intermediate datasets (one dataset per magnitude)
keep year geo
duplicates drop year geo, force
order year geo
foreach k of local variables{
merge 1:1 year geo using "$dataPath\Intermediate_`k'.dta"
drop _merge
erase "$dataPath\Intermediate_`k'.dta"
}
// Keep just relevant variables for later classification
keep year geo B C10C12 C13C15 C16 C17 C18 C19 C20 C21 C22 C23 C24 ///
C25 C26 C27 C28 C29_C30 C31_C32 D F
// Fill gaps, update magnitudes with same GDP growth of the region
merge 1:1 year geo using "$dataPath\GDP_Eurostat.dta"
drop _merge
sort geo year
gen update_coeff = 1 if year < 2018
replace update_coeff = update_coeff + GDP_rate if C20 == . & C21 == . & C26 == . & C28 == . & C31_C32 == . & year < 2018
egen geo_id = group(geo)
xtset geo_id year
replace C20 = L.C20*update_coeff if C20 == . & year < 2018
replace C21 = L.C21*update_coeff if C21 == . & year < 2018
replace C26 = L.C26*update_coeff if C26 == . & year < 2018
replace C28 = L.C28*update_coeff if C28 == . & year < 2018
replace C31_C32 = L.C31_C32*update_coeff if C31_C32 == . & year < 2018
drop GDP GDP_rate update_coeff geo_id
// Rename variables
foreach var in B C10C12 C13C15 C16 C17 C18 C19 C20 C21 C22 C23 C24 ///
C25 C26 C27 C28 C29_C30 C31_C32 D F{
rename `var' GVA_`var'
}
// Gen aggregate
gen GVA_C20_C21 = GVA_C20 + GVA_C21
drop GVA_C20 GVA_C21
// Merge with PVI
merge 1:1 year geo using "$dataPath\Intermediate.dta"
drop _merge
erase "$dataPath\Intermediate.dta"
sort geo year
// 5.2 There is no data for C12 in Spain, therefore the C10C12 value is just the mean between C10 and C11
replace C10C12 = (C10 + C11)/2 if geo == "ES"
drop C10 C11 C12 C10_C11
// 5.3 Generate C31_C32 PVI with the mean between C31 and C32
gen C31_C32 = (C31 + C32)/2
drop C31 C32
// 5.4 Rest of variables with gaps are replaced in their missing values by the trend
// Backward trend: F in Spain from 1995 to 1999, F and C31 in EU28 for 1995, and B, C16, C18, and D for EU28 from 1995 to 1997
// Gen growth rate of PVI
egen geo_id = group(geo)
egen time_id = group(year)
gen time_id_aux = 25 - time_id // Invert order of time to get correct linear trend backwards
xtset geo_id time_id_aux
foreach var in B C10C12 C13C15 C16 C17 C18 C19 C20_C21 C22 C23 C24 ///
C25 C26 C27 C28 C29_C30 C31_C32 D F{
gen rate_`var' = (`var' - L.`var')/L.`var'
gen update_coeff_`var' = 0
}
// Get update coefficient (linear trend)
levelsof geo, local(countries)
foreach c of local countries{
foreach var in B C10C12 C13C15 C16 C17 C18 C19 C20_C21 C22 C23 C24 ///
C25 C26 C27 C28 C29_C30 C31_C32 D F{
reg rate_`var' time_id if geo == "`c'"
mat A=e(b)
scalar trend=A[1,1]
replace update_coeff_`var' = trend if geo == "`c'"
}
}
// Replace missing data with linear long-run trend of PVI
foreach var in B C10C12 C13C15 C16 C17 C18 C19 C20_C21 C22 C23 C24 ///
C25 C26 C27 C28 C29_C30 C31_C32 D F{
replace `var' = L.`var'*(1+update_coeff_`var') if `var' == .
}
keep year geo B C10C12 C13C15 C16 C17 C18 C19 C20_C21 C22 C23 C24 ///
C25 C26 C27 C28 C29_C30 C31_C32 D F GVA*

********************************************************************************
// 6. Aggregate for paper-sectoral classification (weighted avergae, by GVA)
********************************************************************************
gen GVA_IND_EEI = GVA_B + GVA_C19 + GVA_D
gen PVI_IND_EEI = (B*GVA_B + C19*GVA_C19 + D*GVA_D)/GVA_IND_EEI
label var PVI_IND_EEI "Industry - Energy sector and extractive industries - PVI"
gen PVI_IND_FBT = C10C12
label var PVI_IND_FBT "Industry - Food, breverages and tobacco - PVI"
gen PVI_IND_TL = C13C15
label var PVI_IND_TL "Industry - Textile and leather - PVI"
gen PVI_IND_WWP = C16
label var PVI_IND_WWP "Industry - Wood and wood products - PVI"
gen GVA_IND_PPP = GVA_C17 + GVA_C18
gen PVI_IND_PPP = (C17*GVA_C17 + C18*GVA_C18)/GVA_IND_PPP
label var PVI_IND_PPP "Industry - Paper, pulp and printing - PVI"
gen PVI_IND_CPC = C20_C21
label var PVI_IND_CPC "Industry - Chemical and petrochemical - PVI"
gen PVI_IND_NMM = C23
label var PVI_IND_NMM "Industry - Non-metallic minerals - PVI"
gen PVI_IND_BM = C24
label var PVI_IND_BM "Industry - Basic metals - PVI"
gen GVA_IND_MAC = GVA_C25 + GVA_C26 + GVA_C27 + GVA_C28
gen PVI_IND_MAC = (C25*GVA_C25 + C26*GVA_C26 + C27*GVA_C27 + C28*GVA_C28)/GVA_IND_MAC
label var PVI_IND_MAC "Industry - Machinery - PVI"
gen PVI_IND_TE = C29_C30
label var PVI_IND_TE "Industry - Transport equipement - PVI"
gen GVA_IND_OI = GVA_C22 + GVA_C31_C32
gen PVI_IND_OI = (C22*GVA_C22 + C31_C32*GVA_C31_C32)/GVA_IND_OI
label var PVI_IND_OI "Industry - Other industries - PVI"
gen PVI_IND_CON = F
label var PVI_IND_CON "Construction - PVI"

********************************************************************************
// 7. Order and save PVI data
********************************************************************************
// Order variables
keep year geo PVI_IND*
order year geo PVI_IND*
sort geo year
save "$dataPath\PVI_Eurostat.dta", replace


timer off 1
timer list 1
dis "Computing time of routine 1: " round(r(t1)/60, 0.1) " minutes"

/*
Are We Moving Towards A Low-Carbon Energy-Efficient Economy?
A Decomposition of Energy-Related CO2 Emissions in Spain and EU28, 1995-2017
04. Panel Macroeconomic Aggregates (GVA) - Eurostat
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

********************************************************************************
// 2. Merge all intermediate datasets (one dataset per magnitude)
********************************************************************************
keep year geo
duplicates drop year geo, force
order year geo
foreach k of local variables{
merge 1:1 year geo using "$dataPath\Intermediate_`k'.dta"
drop _merge
erase "$dataPath\Intermediate_`k'.dta"
}

********************************************************************************
// 3. Fill the gaps in GVA data
********************************************************************************
// 3.1 Keep just relevant variables for later classification
keep year geo TOTAL A01 A02 A03 B C19 D C10C12 C13C15 C16 C17 C18 C20 C21 C23 C24 ///
C25 C26 C27 C28 C29_C30 C22 C31_C32 F C33 E G H I J K L M N O P Q R S U T

// 3.2 Identify the gaps prior to 2018 and fill them out
sort geo year
// Spain has data for every period until 2017
// EA19 & EU28 - C20, C21, C26, C28, C31_C32 from 2015 onwards
// To fill these gaps, update magnitudes with same GDP growth of the region
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

********************************************************************************
// 4. Aggregate for paper-sectoral classification
********************************************************************************
gen GVA_AGRI_AF = A01 + A02
label var GVA_AGRI_AF "Agriculture - Agriculture and forestry - GVA"
gen GVA_AGRI_FISH = A03
label var GVA_AGRI_FISH "Agriculture - Fishing - GVA"
gen GVA_IND_EEI = B + C19 + D
label var GVA_IND_EEI "Industry - Energy sector and extractive industries - GVA"
gen GVA_IND_FBT = C10C12
label var GVA_IND_FBT "Industry - Food, breverages and tobacco - GVA"
gen GVA_IND_TL = C13C15
label var GVA_IND_TL "Industry - Textile and leather - GVA"
gen GVA_IND_WWP = C16
label var GVA_IND_WWP "Industry - Wood and wood products - GVA"
gen GVA_IND_PPP = C17 + C18
label var GVA_IND_PPP "Industry - Paper, pulp and printing - GVA"
gen GVA_IND_CPC = C20 + C21
label var GVA_IND_CPC "Industry - Chemical and petrochemical - GVA"
gen GVA_IND_NMM = C23
label var GVA_IND_NMM "Industry - Non-metallic minerals - GVA"
gen GVA_IND_BM = C24
label var GVA_IND_BM "Industry - Basic metals - GVA"
gen GVA_IND_MAC = C25 + C26 + C27 + C28
label var GVA_IND_MAC "Industry - Machinery - GVA"
gen GVA_IND_TE = C29_C30
label var GVA_IND_TE "Industry - Transport equipement - GVA"
gen GVA_IND_OI = C22 + C31_C32
label var GVA_IND_OI "Industry - Other industries - GVA"
gen GVA_IND_CON = F
label var GVA_IND_CON "Industry - Construction - GVA"
gen GVA_CPS = C33 + E + G + H + I + J + K + L + M + N + O + P + Q + R + S + U
label var GVA_CPS "Commercial and public services - GVA"
gen GVA_HH = T
label var GVA_HH "Households as employers / for own use - GVA"

********************************************************************************
// 5. Order and save GVA data
********************************************************************************
// Order variables
keep year geo GVA_AGRI* GVA_IND* GVA_CPS GVA_HH
order year geo GVA_AGRI* GVA_IND* GVA_CPS GVA_HH
sort geo year
save "$dataPath\GVA_Eurostat.dta", replace


timer off 1
timer list 1
dis "Computing time of routine 1: " round(r(t1)/60, 0.1) " minutes"

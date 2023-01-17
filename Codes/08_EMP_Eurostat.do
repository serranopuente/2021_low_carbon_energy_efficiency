/*
Are We Moving Towards A Low-Carbon Energy-Efficient Economy?
A Decomposition of Energy-Related CO2 Emissions in Spain and EU28, 1995-2017
08. Panel Employment by NACE (GVA) - Eurostat
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
// National accounts of employment by industry (up to NACE A*64)
eurostatuse nama_10_a64_e, noflags long geo(EU28 ES) start(1995) keepdim(C33 E G H I J K L M N O P Q R S U; EMP_DC;THS_PER) clear
// Clean database
keep geo time nace_r2 nace_r2_label nama_10_a64_e 
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
rename nama_10_a64_e `name'
label var `name' "Total employment domestic concept - `label_name' - Thousand persons"
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
sort geo year
save "$dataPath\Intermediate.dta", replace

********************************************************************************
// 3. Fill the gaps in EMP data with GVA evolution
********************************************************************************
// 3.1 Import data on GVA
// National accounts aggregates by industry (up to NACE A*64)
eurostatuse nama_10_a64, noflags long geo(EU28 ES) start(1995) keepdim(C33 E G H I J K L M N O P Q R S U; B1G; CLV15_MEUR) clear
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
// Rename variables
foreach var in C33 E G H I J K L M N O P Q R S U{
rename `var' GVA_`var'
}
// Merge with EMP data
merge 1:1 year geo using "$dataPath\Intermediate.dta"
drop _merge
erase "$dataPath\Intermediate.dta"
// 3.2 The gaps in the data are the years 1995 to 1999 in the EU28
// Update them with the growth rate of GVA
sort geo year
egen geo_id = group(geo)
egen time_id = group(year)
gen time_id_aux = 25 - time_id // Invert order of time to get correct linear trend backwards
xtset geo_id time_id_aux
foreach var in C33 E G H I J K L M N O P Q R S U{
gen rate_`var' = (GVA_`var' - L.GVA_`var')/L.GVA_`var'
replace `var' = L.`var'*(1+rate_`var') if `var' == .
}
replace U = 0 if year <= 1999 & geo == "EU28"
// 3.3 Keep just relevant variables
keep year geo C33 E G H I J K L M N O P Q R S U
sort geo year

********************************************************************************
// 4. Aggregate for paper-sectoral classification
********************************************************************************
gen EMP_CPS = C33 + E + G + H + I + J + K + L + M + N + O + P + Q + R + S + U
label var EMP_CPS "Total employment domestic concept - CPS - Thousand persons"

********************************************************************************
// 5. Order and save GVA data
********************************************************************************
// Order variables
keep year geo EMP_CPS
sort geo year
save "$dataPath\EMP_CPS_Eurostat.dta", replace


timer off 1
timer list 1
dis "Computing time of routine 1: " round(r(t1)/60, 0.1) " minutes"

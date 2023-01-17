/*
Are We Moving Towards A Low-Carbon Energy-Efficient Economy?
A Decomposition of Energy-Related CO2 Emissions in Spain and EU28, 1995-2017
09. Panel Heating Degree Days (HDD) and Cooling Degree Days (CDD) - Eurostat
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
// Cooling and heating degree days by country - annual data
eurostatuse nrg_chdd_a, noflags long geo(EU28 ES) start(1995) clear
// Clean database
drop unit unit_label geo_label
rename (time) (year)
// Years and countries in rows and balance variables in columns
levelsof indic_nrg, local(variables)
foreach k of local variables{
preserve
keep if indic_nrg == "`k'"
gen firstpart = substr(indic_nrg,1, strpos(indic_nrg, "-")-1)
gen lastpart = substr(indic_nrg, strpos(indic_nrg, "-") + 1, .)
gen new = firstpart + lastpart
local label_name = indic_nrg_label[1]
local name = new[1]
rename nrg_chdd_a `name'
label var `name' "`label_name' Index"
drop indic* *part new
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
// 3. Generate reference index (period 1995 to 2017)
********************************************************************************
foreach var in HDD CDD{
bysort geo: egen `var'_ref = mean(`var') if year <= 2017
label var `var'_ref "`var' - Reference Index (1995-2017)"
}

********************************************************************************
// 4. Order and save data
********************************************************************************
// Order variables
order year geo HDD* CDD*
sort geo year
save "$dataPath\HDD_CDD_Eurostat.dta", replace


timer off 1
timer list 1
dis "Computing time of routine 1: " round(r(t1)/60, 0.1) " minutes"

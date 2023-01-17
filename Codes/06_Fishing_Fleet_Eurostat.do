/*
Are We Moving Towards A Low-Carbon Energy-Efficient Economy?
A Decomposition of Energy-Related CO2 Emissions in Spain and EU28, 1995-2017
06. Panel Fishing fleet - Eurostat
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
// 1. Download raw data and reshape to have year geo
// on the left and magnitudes on the top
********************************************************************************
// Fishing fleet by type of gear and engine power
eurostatuse fish_fleet_gp, noflags long start(1995) clear 
// Select just relevant data
keep if unit == "GT" & eng_pow == "TOTAL" & gear == "TOTAL"
rename (time fish_fleet_gp) (year FF)
keep geo year FF
label var FF "Fishing Fleet - Gross Tonnage"
// Gen growth rate of FF
egen geo_id = group(geo)
egen time_id = group(year)
gen time_id_aux = 25 - time_id // Invert order of time to get correct linear trend backwards
xtset geo_id time_id_aux
gen rate = (FF - L.FF)/L.FF
gen update_coeff = 0
levelsof geo, local(countries)
foreach c of local countries{
reg rate time_id if geo == "`c'"
mat A=e(b)
scalar trend=A[1,1]
replace update_coeff = trend if geo == "`c'"
}
// Replace missing data with linear long-run trend
replace FF = L.FF*(1+update_coeff) if FF == .
gen new_rate = (FF - L.FF)/L.FF
// twoway (line new_rate year) (line rate year), by(geo)
keep geo year FF
sort geo year

********************************************************************************
// 2. Generate totals for EA19 and EU28
********************************************************************************
// 2.1 EU28
set obs `=_N + 24' // Augment number of observations in 24 (from 1995 to 2018)
local a = 23 // data for 24 years
forv j=1995(1)2018{
replace year = `j' if _n == _N - `a'
local a = `a' - 1
}
replace geo = "EU28" if geo == ""
gen EU_28 = 0
replace EU_28 = 1 if inlist(geo, "AT","BE","BG","CY","CZ","DK","EE","FI")
replace EU_28 = 1 if inlist(geo, "FR","DE","EL","HU","IE","IT","LT","LV") 
replace EU_28 = 1 if inlist(geo, "LU","MT","NL","PL","PT","RO","SK","SI")
replace EU_28 = 1 if inlist(geo, "HR","ES","SE","UK")
replace FF = 0 if EU_28 == 0
bysort year: egen aux = total(FF)
replace FF = aux if geo == "EU28"
// 2.2 EA19
set obs `=_N + 24' // Augment number of observations in 24 (from 1995 to 2018)
local a = 23 // data for 24 years
forv j=1995(1)2018{
replace year = `j' if _n == _N - `a'
local a = `a' - 1
}
replace geo = "EA19" if geo == ""
gen EA_19 = 0
replace EA_19 = 1 if inlist(geo, "AT","BE","CY","EE","FI")
replace EA_19 = 1 if inlist(geo, "FR","DE","EL","IE","IT","LT","LV") 
replace EA_19 = 1 if inlist(geo, "LU","MT","NL","PT","SK","SI","ES")
bysort year: egen aux2 = total(FF) if EA_19 == 1
bysort year: egen aux3 = max(aux2)
replace FF = aux3 if geo == "EA19"
drop aux* EU_28 EA_19

********************************************************************************
// 3. Clean, order, and save
********************************************************************************
keep if geo == "ES" | geo == "EU28"
keep geo year FF
sort geo year
save "$dataPath\FF_Eurostat.dta", replace


timer off 1
timer list 1
dis "Computing time of routine 1: " round(r(t1)/60, 0.1) " minutes"

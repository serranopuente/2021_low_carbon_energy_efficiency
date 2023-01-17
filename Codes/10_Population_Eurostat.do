/*
Are We Moving Towards A Low-Carbon Energy-Efficient Economy?
A Decomposition of Energy-Related CO2 Emissions in Spain and EU28, 1995-2017
10. Panel Population - Eurostat
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
// Population on 1 January by age and sex
eurostatuse demo_pjan, noflags long geo(EU28 ES) start(1995) keepdim(TOTAL;T) clear
// Clean database
keep demo_pjan time geo
rename (time) (year)
rename demo_pjan POP
// Data is for January 1st, then use the data of each year for the previous year
sort geo year
egen geo_id = group(geo)
egen time_id = group(year)
xtset geo_id time_id
replace POP = F.POP
label var POP "Population"

********************************************************************************
// 2. Order and save data
********************************************************************************
// Order variables
keep year geo POP
order year geo POP
sort geo year
save "$dataPath\Population_Eurostat.dta", replace


timer off 1
timer list 1
dis "Computing time of routine 1: " round(r(t1)/60, 0.1) " minutes"

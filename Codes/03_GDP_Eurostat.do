/*
Are We Moving Towards A Low-Carbon Energy-Efficient Economy?
A Decomposition of Energy-Related CO2 Emissions in Spain and EU28, 1995-2017
03. Panel GDP - Eurostat
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
// GDP - Chain linked volumes, base 2015
eurostatuse nama_10_gdp, noflags long geo(EU28 ES) start(1995) keepdim(B1GQ; CLV15_MEUR) clear
rename (time nama_10_gdp) (year GDP)
// Label variable
label var GDP "GDP in chain linked volumes (base 2015)"
// Clean database
keep year geo GDP

********************************************************************************
// 2. Generate annual growth
********************************************************************************
egen geo_id = group(geo)
xtset geo_id year
gen GDP_rate = (GDP - L.GDP)/L.GDP
drop geo_id

********************************************************************************
// 3. Order and save PPP data
********************************************************************************
// Order variables
sort geo year
save "$dataPath\GDP_Eurostat.dta", replace


timer off 1
timer list 1
dis "Computing time of routine 1: " round(r(t1)/60, 0.1) " minutes"

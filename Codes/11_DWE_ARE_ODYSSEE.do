/*
Are We Moving Towards A Low-Carbon Energy-Efficient Economy?
A Decomposition of Energy-Related CO2 Emissions in Spain and EU28, 1995-2017
11. Panel Number of dwellings and average floor area of dwellings - ODYSSEE
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
// 1. Import data
********************************************************************************
use "$dataPath\ODYSSEE.dta", clear

********************************************************************************
// 2. Order and save data
********************************************************************************
// Order variables
keep year geo DWE ARE
order year geo DWE ARE
sort geo year
save "$dataPath\DWE_ARE_ODYSSEE.dta", replace


timer off 1
timer list 1
dis "Computing time of routine 1: " round(r(t1)/60, 0.1) " minutes"

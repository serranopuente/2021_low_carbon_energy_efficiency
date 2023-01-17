/*
Are We Moving Towards A Low-Carbon Energy-Efficient Economy?
A Decomposition of Energy-Related CO2 Emissions in Spain and EU28, 1995-2017
02. Panel Purchasing Power Parity (PPP) - Eurostat
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
// Purchasing power parities (PPPs) - EU28 = 1
eurostatuse prc_ppp_ind, noflags long geo(EU28 ES) start(1995) keepdim(GDP; PPP_EU28) clear
rename (time prc_ppp_ind) (year PPP)
// Label variable
local name = na_item_label[1]
label var PPP "`name'"
// Clean database
drop geo_label ppp_cat_label ppp_cat na_item na_item_label

********************************************************************************
// 2. Order and save PPP data
********************************************************************************
// Order variables
sort geo year
save "$dataPath\PPP_Eurostat.dta", replace


timer off 1
timer list 1
dis "Computing time of routine 1: " round(r(t1)/60, 0.1) " minutes"

/*
Are We Moving Towards A Low-Carbon Energy-Efficient Economy?
A Decomposition of Energy-Related CO2 Emissions in Spain and EU28, 1995-2017
12. Panel transport activity data (PKM and TKM) - ODYSSEE
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
// 1. Include TKM data of pipeline transport (only data that is not reported in ODYSSEE)
********************************************************************************
// 1.1 Pipeline TKM for Spain is complete from Eurostat data
eurostatuse pipe_go_tonkms, noflags long geo(ES) start(1995) keepdim(TOTAL; NAT; MIO_TKM) clear
keep time geo pipe_go_tonkms
rename (time pipe_go_tonkms) (year TKM_PIPE)
replace TKM_PIPE = TKM_PIPE/1000 // Billion TKM in order to be comparable with ODYSSEE data
// 1.2 Pipeline TKM for EU28 is not available neither can be constructed from Eurostat data,
// then use de data from the European Pocketbook 2017 on transport
// Note than we only have data points, not complete series, but due to low variability it is useful
set obs `=scalar(_N+24)'
replace geo = "EU28" if geo == ""
local a = 23 // data for 24 years
forv j=1995(1)2018{
replace year = `j' if _n == _N - `a' & geo == "EU28"
local a = `a' - 1
}
// Manually include data for EU28
replace TKM_PIPE = 114.9 if year == 1995 & geo == "EU28"
replace TKM_PIPE = 119.3 if year == 1996 & geo == "EU28"
replace TKM_PIPE = 118.9 if year == 1997 & geo == "EU28"
replace TKM_PIPE = 126.3 if year == 1998 & geo == "EU28"
replace TKM_PIPE = 127.1 if year == 1999 & geo == "EU28"
replace TKM_PIPE = 127.1 if year == 2000 & geo == "EU28"
replace TKM_PIPE = 133.9 if year == 2001 & geo == "EU28"
replace TKM_PIPE = 129.7 if year == 2002 & geo == "EU28"
replace TKM_PIPE = 131.7 if year == 2003 & geo == "EU28"
replace TKM_PIPE = 133.3 if year == 2004 & geo == "EU28"
replace TKM_PIPE = 137.6 if year == 2005 & geo == "EU28"
replace TKM_PIPE = 136.6 if year == 2006 & geo == "EU28"
replace TKM_PIPE = 128.5 if year == 2007 & geo == "EU28"
replace TKM_PIPE = 124.9 if year == 2008 & geo == "EU28"
replace TKM_PIPE = 121.8 if year == 2009 & geo == "EU28"
replace TKM_PIPE = 121.1 if year == 2010 & geo == "EU28"
replace TKM_PIPE = 118.4 if year == 2011 & geo == "EU28"
replace TKM_PIPE = 114.9 if year == 2012 & geo == "EU28"
replace TKM_PIPE = 112.2 if year == 2013 & geo == "EU28"
replace TKM_PIPE = 111.3 if year == 2014 & geo == "EU28"
replace TKM_PIPE = 115.2 if year == 2015 & geo == "EU28"
// Interpolate missing data of EU28
ipolate TKM_PIPE year if geo == "EU28", generate(aux) epolate
replace TKM_PIPE = aux if geo == "EU28" & TKM_PIPE == .
// Label
label var TKM_PIPE "Oil pipeline traffic; Gtkm; Eurostat"

********************************************************************************
// 2. Merge with rest of PKM/TKM ODYSSEE DATA
********************************************************************************
merge 1:1 year geo using "$dataPath\ODYSSEE.dta"
keep year geo PKM* TKM*
rename PKM_AVI_Dom PKM_AVI
// 2.1 Generate new total of TKM (adding pipeline TKM)
replace TKM = TKM + TKM_PIPE

********************************************************************************
// 3. Order and save data
********************************************************************************
order year geo PKM* TKM*
sort geo year
save "$dataPath\PKM_TKM_ODYSSEE.dta", replace


timer off 1
timer list 1
dis "Computing time of routine 1: " round(r(t1)/60, 0.1) " minutes"

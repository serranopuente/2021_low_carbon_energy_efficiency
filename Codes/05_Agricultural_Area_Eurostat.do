/*
Are We Moving Towards A Low-Carbon Energy-Efficient Economy?
A Decomposition of Energy-Related CO2 Emissions in Spain and EU28, 1995-2017
05. Panel Agricultural aread + wooded land - Eurostat
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
// 1. Utilised agricultural area - Download raw data and reshape to have year geo
// on the left and magnitudes on the top
********************************************************************************
// 1.1 Farmland: number of farms and areas by size of farm (UAA) and NUTS 2 regions (up to 2005, note that 2005 and 2007 must be also included in next dataset)
eurostatuse ef_lu_ovcropaa, noflags long geo(AT BE BG CH CY CZ DE DK EE EL ES FI ///
FR HU IE IT LT LU LV MT NL NO PL PT RO SE SI SK UK) start(1995) keepdim(TOTAL;AGRAREA;HA) clear // Select just countries, not sub-regions
// Clean database
drop unit unit_label variable_label variable agrarea_label agrarea geo_label
rename (time ef_lu_ovcropaa) (year UAA)
label var UAA "Utilised agricultural area - HA"
save "$dataPath\Intermediate.dta", replace
// 1.2 Farm indicators by agricultural area, type of farm, standard output, legal form and NUTS 2 regions (from 2005 onwards, note that 2005 and 2007 must be also included in next dataset)
eurostatuse ef_m_farmleg, noflags long geo (AT BE BG CH CY CZ DE DK EE EL ES FI ///
FR HR HU IE	IS IT LT LU LV ME MT NL NO PL PT RO SE SI SK UK) start(2005) keepdim(TOTAL;TOTAL;TOTAL;TOTAL;UAA_HA) clear // Select just countries, not sub-regions
// Clean database
keep if so_eur == "TOTAL" & agrarea == "TOTAL" & leg_form == "TOTAL" & farmtype == "TOTAL"
rename (time ef_m_farmleg) (year UAA_2)
keep geo year UAA_2
label var UAA_2 "Utilised agricultural area - HA"
// 1.3 Merge both datasets
merge 1:1 geo year using "$dataPath\Intermediate.dta"
drop _merge
erase "$dataPath\Intermediate.dta"
// 1.4 Check overlapping magnitudes and generate one UAA
gen check = UAA - UAA_2 if year == 2005 | year == 2007
gen aux = UAA if inlist(year, 1995,1997,2000,2003)
replace aux = UAA_2 if inlist(year, 2005,2007,2010,2013,2016)
replace UAA = aux
drop aux UAA_2 check
// 1.5 Repalce missing data with next update of data
egen geo_id = group(geo)
egen time_id = group(year)
xtset geo_id time_id
// Next update of data
replace UAA = F.UAA if UAA == . // With next update (F1)
replace UAA = L.UAA if UAA == . // With previous update (L1) if next update is also not available
replace UAA = F2.UAA if UAA == . // Next update of data (F2) if previous next update (F1) also not available
replace UAA = F.UAA if UAA == . // Again, once the next update is already filled
drop geo_id time_id
// 1.6 Generate and store EU28 and EA19 totals and store them as a row per year
// 1.6.1 EU28
set obs `=_N + 9' // Augment number of observations in 9 (1995, 1997, 2000, 2003, 2005, 2007, 2010, 2013, 2016)
replace year = 1995 if _n == _N - 8
replace year = 1997 if _n == _N - 7
replace year = 2000 if _n == _N - 6
replace year = 2003 if _n == _N - 5
replace year = 2005 if _n == _N - 4
replace year = 2007 if _n == _N - 3
replace year = 2010 if _n == _N - 2
replace year = 2013 if _n == _N - 1
replace year = 2016 if _n == _N
replace geo = "EU28" if geo == ""
gen EU_28 = 0
replace EU_28 = 1 if inlist(geo, "AT","BE","BG","CY","CZ","DK","EE","FI")
replace EU_28 = 1 if inlist(geo, "FR","DE","EL","HU","IE","IT","LT","LV") 
replace EU_28 = 1 if inlist(geo, "LU","MT","NL","PL","PT","RO","SK","SI")
replace EU_28 = 1 if inlist(geo, "HR","ES","SE","UK")
replace UAA = 0 if EU_28 == 0
bysort year: egen aux = total(UAA)
replace UAA = aux if geo == "EU28"
// 1.6.2 EA19
set obs `=_N + 9' // Augment number of observations in 9 (1995, 1997, 2000, 2003, 2005, 2007, 2010, 2013, 2016)
replace year = 1995 if _n == _N - 8
replace year = 1997 if _n == _N - 7
replace year = 2000 if _n == _N - 6
replace year = 2003 if _n == _N - 5
replace year = 2005 if _n == _N - 4
replace year = 2007 if _n == _N - 3
replace year = 2010 if _n == _N - 2
replace year = 2013 if _n == _N - 1
replace year = 2016 if _n == _N
replace geo = "EA19" if geo == ""
gen EA_19 = 0
replace EA_19 = 1 if inlist(geo, "AT","BE","CY","EE","FI")
replace EA_19 = 1 if inlist(geo, "FR","DE","EL","IE","IT","LT","LV") 
replace EA_19 = 1 if inlist(geo, "LU","MT","NL","PT","SK","SI","ES")
bysort year: egen aux2 = total(UAA) if EA_19 == 1
bysort year: egen aux3 = max(aux2)
replace UAA = aux3 if geo == "EA19"
drop aux* EU_28 EA_19
// 1.7 Clean data and complete time series
keep if geo == "EA19" | geo == "ES" | geo == "EU28"
sort geo year
foreach y in 1996 1998 1999 2001 2002 2004 2006 2008 2009 2011 2012 2014 2015 2017 2018{
foreach g in "EA19" "ES" "EU28"{
set obs `=_N + 1'
replace year = `y' if _n == _N
replace geo = "`g'" if _n == _N
}
}
sort geo year
egen geo_id = group(geo)
egen time_id = group(year)
xtset geo_id time_id
// Replace missing values with closest update
replace UAA = F.UAA if UAA == . // With next update (F1)
replace UAA = L.UAA if UAA == . // With previous update (L1) if next update is also not available
drop geo_id time_id
// Put data in thousand hectares to be consistent with forest data
replace UAA = UAA/1000
label var UAA "Utilised agricultural area - thousand HA"
save "$dataPath\Intermediate_agr_area.dta", replace

********************************************************************************
// 2. Wooded land - Download raw data and reshape to have year geo
// on the left and magnitudes on the top
********************************************************************************
// Farmland: number of farms and areas by size of farm (UAA) and NUTS 2 regions (up to 2005, note that 2005 and 2007 must be also included in next dataset)
eurostatuse for_area, noflags long start(1990) keepdim(FOWL;THS_HA) clear
// Clean database
rename (time for_area) (year WL)
keep geo year WL
label var WL "Forest and other wooded land - thousand HA"
// Replace missing data with closest update
sort geo year
egen geo_id = group(geo)
egen time_id = group(year)
xtset geo_id time_id
replace WL = F.WL if WL == . // With next update (F1)
replace WL = L.WL if WL == . // With previous update (L1) if next update is also not available
replace WL = F.WL if WL == . // With next update (F1), once next update is already updated
replace WL = F.WL if WL == . // Again, with next update (F1), once next update is already updated
drop geo_id time_id
// Gen totals for EA19
set obs `=_N + 5' // Augment number of observations in 9 (1990, 2000, 2005, 2010, 2015)
replace year = 1990 if _n == _N - 4
replace year = 2000 if _n == _N - 3
replace year = 2005 if _n == _N - 2
replace year = 2010 if _n == _N - 1
replace year = 2015 if _n == _N
replace geo = "EA19" if geo == ""
gen EA_19 = 0
replace EA_19 = 1 if inlist(geo, "AT","BE","CY","EE","FI")
replace EA_19 = 1 if inlist(geo, "FR","DE","EL","IE","IT","LT","LV") 
replace EA_19 = 1 if inlist(geo, "LU","MT","NL","PT","SK","SI","ES")
bysort year: egen aux = total(WL) if EA_19 == 1
bysort year: egen aux2 = max(aux)
replace WL = aux2 if geo == "EA19"
drop aux* EA_19
// Clean data and complete time series
keep if geo == "EA19" | geo == "ES" | geo == "EU28"
sort geo year
foreach y in 1991 1992 1993 1994 1995 1996 1997 1998 1999 2001 2002 2003 2004 2006 2007 2008 2009 2011 2012 2013 2014 2016 2017 2018{
foreach g in "EA19" "ES" "EU28"{
set obs `=_N + 1'
replace year = `y' if _n == _N
replace geo = "`g'" if _n == _N
}
}
sort geo year
egen geo_id = group(geo)
egen time_id = group(year)
xtset geo_id time_id
foreach y in 1990 2000 2005 2010 2015{
bysort geo: gen WL_`y' = WL if year == `y'
bysort geo: egen aux_`y' = max(WL_`y')
}
replace WL = aux_1990 if WL == . & year <= 1997
replace WL = aux_2000 if WL == . & year > 1997 & year <= 2003
replace WL = aux_2005 if WL == . & year > 2003 & year <= 2007
replace WL = aux_2010 if WL == . & year > 2007 & year <= 2013
replace WL = aux_2015 if WL == . & year > 2013
drop WL_* aux* geo_id time_id

********************************************************************************
// 3. Merge both agricultural and forest area data
********************************************************************************
merge 1:1 geo year using "$dataPath\Intermediate_agr_area.dta"
drop _merge
erase "$dataPath\Intermediate_agr_area.dta"

********************************************************************************
// 4. Clean, order, and save
********************************************************************************
drop if year < 1995
gen AA = WL + UAA
keep if geo == "ES" | geo == "EU28"
label var AA "Agricultural Area (UAA + FOWL) - thousand HA"
keep geo year AA
sort geo year
save "$dataPath\AA_Eurostat.dta", replace


timer off 1
timer list 1
dis "Computing time of routine 1: " round(r(t1)/60, 0.1) " minutes"

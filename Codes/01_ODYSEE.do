/*
Are We Moving Towards A Low-Carbon Energy-Efficient Economy?
A Decomposition of Energy-Related CO2 Emissions in Spain and EU28, 1995-2017
01. Panel ODYSSEE
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
// 1. Import raw data and clean it
********************************************************************************
// The raw data is downloaded in 6 .csv files to facilitate the downloading process
// Here we create individual intermediate datasets per variable
foreach dataset in macro industry transport households services co2{
import delimited "$dataPath\ODYSSEE\export_enerdata_`dataset'.csv", varnames(2) clear
gen label = title + "; " + unit + "; " + sourcecode
rename (itemcode isocode) (var geo)
drop unit sourcecode note title
replace value = "" if value == "n.a."
destring value, replace
levelsof var, local(variables)
foreach k of local variables{
preserve
keep if var == "`k'"
local name = var[1]
rename value `name'
local label_name = label[1]
label var `name' "`label_name'"
drop var label
save "$dataPath\Intermediate_`k'.dta", replace
restore
}
// Merge all intermediate individual datasets in one intermediate dataset
keep year geo
duplicates drop year geo, force
order year geo
foreach k of local variables{
merge 1:1 year geo using "$dataPath\Intermediate_`k'.dta"
drop _merge
erase "$dataPath\Intermediate_`k'.dta"
}
save "$dataPath\Intermediate_`dataset'.dta", replace
}
// Merge everything in one general main dataset
keep year geo
duplicates drop year geo, force
order year geo
foreach dataset in macro industry transport households services co2{
merge 1:1 year geo using "$dataPath\Intermediate_`dataset'.dta"
drop _merge
erase "$dataPath\Intermediate_`dataset'.dta"
}
// Keep relevant regions, order, and save
keep if geo == "ES" | geo == "EU28"
sort geo year
save "$dataPath\ODYSSEE.dta", replace

********************************************************************************
// 2. Table with definition of variables
********************************************************************************
/*
foreach dataset in macro industry transport households services co2{
import delimited "$dataPath\ODYSSEE\export_enerdata_`dataset'.csv", varnames(2) clear
rename (itemcode title) (var label)
keep var label
duplicates drop var label, force
export excel using "$dataPath\ODYSSEE\Variable_List_ODYSSEE.xlsx", sheet("`dataset' - STATA") sheetmodify firstrow(variables)
}
*/

********************************************************************************
// 3. Select just relevant variables for analysis from ODYSSEE
********************************************************************************
use "$dataPath\ODYSSEE.dta", clear
drop if year < 1995 | year > 2017
keep year geo ///
esscfrou gzlcfrou gplcfrou gnacfrou enccfrou glecfrou glgcfrou toccfrou /// // Final consumption - Transport - Road Transport
esscfvpc gzlcfvpc gplcfvpc gnacfvpc glecfvpc glgcfvpc enccfvpc toccfvpc /// // Final consumption - Transport - Cars
esscfmot /// // Final consumption - Transport - Motorcycles
esscfbus gzlcfbus gplcfbus gnacfbus /// // Final consumption - Transport - Buses
esscfcamvlr gzlcfcamvlr gplcfcamvlr glecfcamvlr glgcfcamvlr gnacfcamvlr enccfcamvlr toccfcamvlr /// // Final consumption - Transport - Trucks & light vehicles
gzlcffer folcffer elccffer toccffer /// // Final consumption - Transport - Rail transport
toccfferpas toccffermch /// // Final consumption - Transport - Rail transport of pass. and goods
pkm pkmfertot pkmrou pkmavd pasair /// // Passenger-Km
tkmfer tkmflv tkm tkmrou /// // Tonnes-Km
cmscfter petcfter gazcfter vapcfter enccfter elccfter toccfter /// // Final consumption - Services
cmscfterchf petcfterchf gazcfterchf vapcfterchf elccfterchf toccfterchf /// // Final consumption - Services - Space heating
petcfterecs cmscfterecs gazcfterecs vapcfterecs elccfterecs toccfterecs /// // Final consumption - Services - Hot water
petcftercui gazcftercui elccftercui toccftercui /// // Final consumption - Services - Cooking
elccftercli elccfterlgt /// // Final consumption - Services - Air conditioning and lighting
nbrlpr surlog /// Number of permanently occupied dwellings and total floor area of dwellings
cmscfres petcfres gazcfres vapcfres enccfres elccfres toccfres /// // Final consumption - Residential sector
cmscfreschf petcfreschf gazcfreschf vapcfreschf enccfreschf elccfreschf toccfreschf /// // Final consumption - Residential sector - Space heating
cmscfresecs petcfresecs gazcfresecs vapcfresecs enccfresecs elccfresecs toccfresecs /// // Final consumption - Residential sector - Hot water
cmscfrescui petcfrescui gazcfrescui elccfrescui enccfrescui toccfrescui /// // Final consumption - Residential sector - Cooking
elccfrescli /// // Final consumption - Residential sector - Air conditioning
elccfresels	/// // Final consumption - Residential sector - Electrical appliances and lighting

********************************************************************************
// 4. Rename variables to build ODYSSEE balances
********************************************************************************
// 4.1 Final consumption - Transport - Road Transport
rename (esscfrou gzlcfrou gplcfrou gnacfrou enccfrou glecfrou glgcfrou toccfrou) (ROAD_Oil_Gasoline ROAD_Oil_Diesel ROAD_Oil_LPG ROAD_Gas_NGV ROAD_Ren_Biof ROAD_Ren_Bioeth ROAD_Ren__Biodies ROAD_Tot)
gen ROAD_Gas = ROAD_Gas_NGV
gen ROAD_Oil = ROAD_Oil_Gasoline + ROAD_Oil_Diesel + ROAD_Oil_LPG
gen ROAD_Ren = ROAD_Ren_Biof
// 4.2 Final consumption - Transport - Road - Cars
rename (esscfvpc gzlcfvpc gplcfvpc gnacfvpc glecfvpc glgcfvpc enccfvpc toccfvpc) (CARS_Oil_Gasoline CARS_Oil_Diesel CARS_Oil_LPG CARS_Gas_NGV CARS_Ren_Bioeth CARS_Ren_Biodies CARS_Ren_Biof CARS_Tot)
gen CARS_Gas = CARS_Gas_NGV
gen CARS_Oil = CARS_Oil_Gasoline + CARS_Oil_Diesel + CARS_Oil_LPG
gen CARS_Ren = CARS_Ren_Biof
// 4.3 Final consumption - Transport - Road - Motorcycles
rename esscfmot MOT_Tot
gen MOT_Oil_Gasoline = MOT_Tot
gen MOT_Oil = MOT_Oil_Gasoline
// 4.4 Final consumption - Transport - Road - Buses
rename (esscfbus gzlcfbus gplcfbus gnacfbus) (BUS_Oil_Gasoline BUS_Oil_Diesel BUS_Oil_LPG BUS_Gas_NGV)
gen BUS_Gas = BUS_Gas_NGV
gen BUS_Oil = BUS_Oil_Gasoline + BUS_Oil_Diesel + BUS_Oil_LPG
gen BUS_Tot = BUS_Oil // BUS_Gas_NGV is 0
// 4.5 Final consumption - Transport - Trucks & light vehicles
rename (esscfcamvlr gzlcfcamvlr gplcfcamvlr glecfcamvlr glgcfcamvlr gnacfcamvlr enccfcamvlr toccfcamvlr) (TLV_Oil_Gasoline TLV_Oil_Diesel TLV_Oil_LPG TLV_Ren_Bioeth TLV_Ren_Biodies TLV_Gas_NGV TLV_Ren_Biof TLV_Tot)
gen TLV_Ren = TLV_Ren_Biof
gen TLV_Gas = TLV_Gas_NGV
gen TLV_Oil = TLV_Oil_Gasoline + TLV_Oil_Diesel + TLV_Oil_LPG
// 4.6 Final consumption - Transport - Rail transport
rename (gzlcffer folcffer elccffer toccffer) (RAIL_Oil_Diesel RAIL_Oil_FO RAIL_Ele RAIL_Tot)
gen RAIL_Oil = RAIL_Oil_Diesel + RAIL_Oil_FO
// 4.7 Final consumption - Transport - Rail transport of pass. and goods
rename (toccfferpas toccffermch) (RAIL_PASS_Tot RAIL_FR_Tot)
// 4.8 Passenger-Km            
rename (pkm pkmfertot pkmrou pkmavd) (PKM PKM_RAIL PKM_ROAD PKM_AVI_Dom)
// 4.9 Tonnes-Km
rename (tkmfer tkmflv tkm tkmrou) (TKM_RAIL TKM_NAVI TKM TKM_ROAD)
// 4.10 Final consumption - Services
rename (cmscfter petcfter gazcfter vapcfter enccfter elccfter toccfter) (SER_TOT_Coal SER_TOT_Oil SER_TOT_Gas SER_TOT_Heat SER_TOT_Ren_Wood SER_TOT_Ele SER_TOT_Tot)
gen SER_TOT_Ren = SER_TOT_Ren_Wood
// 4.11 Final consumption - Services - Space heating
rename (cmscfterchf petcfterchf gazcfterchf vapcfterchf elccfterchf toccfterchf) (SER_SH_Coal SER_SH_Oil SER_SH_Gas SER_SH_Heat SER_SH_Ele SER_SH_Tot)
// 4.12 Final consumption - Services - Hot water
rename (petcfterecs cmscfterecs gazcfterecs vapcfterecs elccfterecs toccfterecs) (SER_HW_Oil SER_HW_Coal SER_HW_Gas SER_HW_Heat SER_HW_Ele SER_HW_Tot)
// 4.13 Final consumption - Services - Cooking
rename (petcftercui gazcftercui elccftercui toccftercui) (SER_COOK_Oil SER_COOK_Gas SER_COOK_Ele SER_COOK_Tot)
// 4.14 Final consumption - Services - Air conditioning and lighting
rename (elccftercli elccfterlgt) (SER_AC_Ele SER_LIGHT_Ele)
gen SER_AC_Tot = SER_AC_Ele
gen SER_LIGHT_Tot = SER_LIGHT_Ele
// 4.15 Number of permanently occupied dwellings and total floor area of dwellings
rename (nbrlpr surlog) (DWE AREA)
// 4.16 Final consumption - Residential sector
rename (cmscfres petcfres gazcfres vapcfres enccfres elccfres toccfres) (HH_TOT_Coal HH_TOT_Oil HH_TOT_Gas HH_TOT_Heat HH_TOT_Ren_Wood HH_TOT_Ele HH_TOT_Tot)
gen HH_TOT_Ren = HH_TOT_Ren_Wood
// 4.17 Final consumption - Residential sector - Space heating
rename (cmscfreschf petcfreschf gazcfreschf vapcfreschf enccfreschf elccfreschf toccfreschf) (HH_SH_Coal HH_SH_Oil HH_SH_Gas HH_SH_Heat HH_SH_Ren_Wood HH_SH_Ele HH_SH_Tot)
gen HH_SH_Ren = HH_SH_Ren_Wood
// 4.18 Final consumption - Residential sector - Hot water
rename (cmscfresecs petcfresecs gazcfresecs vapcfresecs enccfresecs elccfresecs toccfresecs) (HH_HW_Coal HH_HW_Oil HH_HW_Gas HH_HW_Heat HH_HW_Ren_Wood HH_HW_Ele HH_HW_Tot)
gen HH_HW_Ren = HH_HW_Ren_Wood
// 4.19 Final consumption - Residential sector - Cooking
rename (cmscfrescui petcfrescui gazcfrescui elccfrescui enccfrescui toccfrescui) (HH_COOK_Coal HH_COOK_Oil HH_COOK_Gas HH_COOK_Ele HH_COOK_Ren_Wood HH_COOK_Tot)
gen HH_COOK_Ren = HH_COOK_Ren_Wood
// 4.20 Final consumption - Residential sector - Air conditioning
rename elccfrescli HH_AC_Ele
gen HH_AC_Tot = HH_AC_Ele
// 4.21 Final consumption - Residential sector - Electrical appliances and lighting
rename elccfresels HH_LIGHT_Ele
gen HH_LIGHT_Tot = HH_LIGHT_Ele
// 4.22 Order
order year geo ROAD* CARS* MOT* BUS* TLV* RAIL* PKM* TKM* ///
SER_TOT* SER_SH* SER_HW* SER_COOK* SER_AC* SER_LIGHT* ///
DWE AREA HH_TOT* HH_SH* HH_HW* HH_COOK* HH_AC* HH_LIGHT*

********************************************************************************
// 5. Replace missing values for EU28 with upwards and backwards linear trends
********************************************************************************
// 5.1 Bioethanol and biodiesel for cars and trucks & light vehicles for EU28 for 2016 and 2017
// For EU28, there is data for biofuels for each period, then split this biofuel data between bioethanol and biodiesel following the trend of the biofuel total
egen geo_id = group(geo)
egen time_id = group(year)
xtset geo_id time_id // Set order for upwards trend
foreach var in TLV_Ren_Biof CARS_Ren_Biof{
gen rate_`var' = (`var' - L.`var')/L.`var' if geo == "EU28"
}
foreach var in TLV_Ren_Bioeth TLV_Ren_Biodies{
replace `var' = L.`var'*(1+rate_TLV_Ren_Biof) if `var' == . & geo == "EU28"
}
foreach var in CARS_Ren_Bioeth CARS_Ren_Biodies{
replace `var' = L.`var'*(1+rate_CARS_Ren_Biof) if `var' == . & geo == "EU28"
}
drop *_id rate*
// 5.2 Final consumption in services by end-use missing for EU28 between 1995 and 1999 and 2016 and 2017
// Replace the first part with backward trend (between 1995 and 1999) of the total consumption services (which is complete for whole period)
egen geo_id = group(geo)
egen time_id = group(year)
gen time_id_aux = 24 - time_id // Invert order of time to get correct linear trend backwards
xtset geo_id time_id_aux
foreach var in Tot Coal Oil Ele Gas Heat{
gen rate_`var' = (SER_TOT_`var' - L.SER_TOT_`var')/L.SER_TOT_`var' if geo == "EU28"
}
foreach var in SH HW COOK AC LIGHT{
replace SER_`var'_Tot = L.SER_`var'_Tot*(1+rate_Tot) if SER_`var'_Tot == . & geo == "EU28"
}
foreach var in SH HW{
replace SER_`var'_Coal = L.SER_`var'_Coal*(1+rate_Coal) if SER_`var'_Coal == . & geo == "EU28"
}
foreach var in SH HW COOK{
replace SER_`var'_Oil = L.SER_`var'_Oil*(1+rate_Oil) if SER_`var'_Oil == . & geo == "EU28"
}
foreach var in SH HW COOK{
replace SER_`var'_Gas = L.SER_`var'_Gas*(1+rate_Gas) if SER_`var'_Gas == . & geo == "EU28"
}
foreach var in SH HW{
replace SER_`var'_Heat = L.SER_`var'_Heat*(1+rate_Heat) if SER_`var'_Heat == . & geo == "EU28"
}
foreach var in SH HW COOK AC LIGHT{
replace SER_`var'_Ele = L.SER_`var'_Ele*(1+rate_Ele) if SER_`var'_Ele == . & geo == "EU28"
}
drop *_id rate*
// Replace the first part with upward trend (2016 and 2017) of the total consumption services (which is complete for whole period)
egen geo_id = group(geo)
egen time_id = group(year)
xtset geo_id time_id // Set order for upwards trend
foreach var in Tot Coal Oil Ele Gas Heat{
gen rate_`var' = (SER_TOT_`var' - L.SER_TOT_`var')/L.SER_TOT_`var' if geo == "EU28"
}
foreach var in SH HW COOK AC LIGHT{
replace SER_`var'_Tot = L.SER_`var'_Tot*(1+rate_Tot) if SER_`var'_Tot == . & geo == "EU28"
}
foreach var in SH HW{
replace SER_`var'_Coal = L.SER_`var'_Coal*(1+rate_Coal) if SER_`var'_Coal == . & geo == "EU28"
}
foreach var in SH HW COOK{
replace SER_`var'_Oil = L.SER_`var'_Oil*(1+rate_Oil) if SER_`var'_Oil == . & geo == "EU28"
}
foreach var in SH HW COOK{
replace SER_`var'_Gas = L.SER_`var'_Gas*(1+rate_Gas) if SER_`var'_Gas == . & geo == "EU28"
}
foreach var in SH HW{
replace SER_`var'_Heat = L.SER_`var'_Heat*(1+rate_Heat) if SER_`var'_Heat == . & geo == "EU28"
}
foreach var in SH HW COOK AC LIGHT{
replace SER_`var'_Ele = L.SER_`var'_Ele*(1+rate_Ele) if SER_`var'_Ele == . & geo == "EU28"
}
drop *_id rate*

********************************************************************************
// 6. Generate shares
********************************************************************************
// 6.1 Shares of rail transport
gen RAIL_PASS = RAIL_PASS_Tot / (RAIL_PASS_Tot + RAIL_FR_Tot)
gen RAIL_FR = RAIL_FR_Tot / (RAIL_PASS_Tot + RAIL_FR_Tot)
gen check1 = 1 - (RAIL_PASS + RAIL_FR)
sum check1
// 6.2 Shares of road transport
gen ROAD_PASS = (CARS_Tot + MOT_Tot + BUS_Tot)/(CARS_Tot + MOT_Tot + BUS_Tot + TLV_Tot) 
gen ROAD_FR = TLV_Tot/(CARS_Tot + MOT_Tot + BUS_Tot + TLV_Tot) 
// 6.2.1 Oil products
gen ROAD_PASS_Oil_Gasoline = (CARS_Oil_Gasoline + MOT_Oil_Gasoline + BUS_Oil_Gasoline)/(CARS_Oil_Gasoline + MOT_Oil_Gasoline + BUS_Oil_Gasoline + TLV_Oil_Gasoline) 
gen ROAD_FR_Oil_Gasoline = TLV_Oil_Gasoline/(CARS_Oil_Gasoline + MOT_Oil_Gasoline + BUS_Oil_Gasoline + TLV_Oil_Gasoline)
gen check2 = 1 - (ROAD_PASS_Oil_Gasoline + ROAD_FR_Oil_Gasoline)
gen ROAD_PASS_Oil_Diesel = (CARS_Oil_Diesel + BUS_Oil_Diesel)/(CARS_Oil_Diesel + BUS_Oil_Diesel + TLV_Oil_Diesel) 
gen ROAD_FR_Oil_Diesel = TLV_Oil_Diesel/(CARS_Oil_Diesel + BUS_Oil_Diesel + TLV_Oil_Diesel)
gen check3 = 1 - (ROAD_PASS_Oil_Diesel + ROAD_FR_Oil_Diesel)
gen ROAD_PASS_Oil_LPG = (CARS_Oil_LPG + BUS_Oil_LPG)/(CARS_Oil_LPG + BUS_Oil_LPG + TLV_Oil_LPG) 
gen ROAD_FR_Oil_LPG = TLV_Oil_LPG/(CARS_Oil_LPG + BUS_Oil_LPG + TLV_Oil_LPG)
gen check4 = 1 - (ROAD_PASS_Oil_LPG + ROAD_FR_Oil_LPG)
gen ROAD_PASS_Oil = (CARS_Oil + MOT_Oil + BUS_Oil)/(CARS_Oil + MOT_Oil + BUS_Oil + TLV_Oil) 
gen ROAD_FR_Oil = TLV_Oil/(CARS_Oil + MOT_Oil + BUS_Oil + TLV_Oil)
gen check5 = 1 - (ROAD_PASS_Oil + ROAD_FR_Oil)
// 6.2.2 Gas products (Just for cars)
gen ROAD_PASS_Gas = 1
gen ROAD_FR_Gas = 0
// No need to split because we assume it is all for passengers in road transport
// 6.2.3 Renewable products - Biofuels
// In Spain everything is for passenger transport
// Bioethanol consumption of trucks & light vehicles for Spain is missing for every year, but replace with 0 because biofuel is 0 for Spain
replace TLV_Ren_Bioeth = 0 if geo == "ES"
// Biodiesel consumption of trucks & light vehicles for Spain is missing for every year, but replace with 0 because biofuel is 0 for Spain
replace TLV_Ren_Biodies = 0 if geo == "ES"
// Biodiesel consumption of cars for Spain between 1995 and 1999 is 0 because biofuel of cars is 0
replace CARS_Ren_Biodies = 0 if geo == "ES" & year <= 1999 // Biofuel is 0 for Spain
gen ROAD_PASS_Ren_Bioeth = (CARS_Ren_Bioeth)/(CARS_Ren_Bioeth + TLV_Ren_Bioeth)
replace ROAD_PASS_Ren_Bioeth = 1 if geo == "ES" & ROAD_PASS_Ren_Bioeth == .
gen ROAD_FR_Ren_Bioeth = TLV_Ren_Bioeth/(CARS_Ren_Bioeth + TLV_Ren_Bioeth) 
replace ROAD_FR_Ren_Bioeth = 0 if geo == "ES" & ROAD_FR_Ren_Bioeth == .
gen check6 = 1 - (ROAD_PASS_Ren_Bioeth + ROAD_FR_Ren_Bioeth)
gen ROAD_PASS_Ren_Biodies = (CARS_Ren_Biodies)/(CARS_Ren_Biodies + TLV_Ren_Biodies)
replace ROAD_PASS_Ren_Biodies = 1 if geo == "ES" & ROAD_PASS_Ren_Biodies == .
gen ROAD_FR_Ren_Biodies = TLV_Ren_Biodies/(CARS_Ren_Biodies + TLV_Ren_Biodies)
replace ROAD_FR_Ren_Biodies = 0 if geo == "ES" & ROAD_FR_Ren_Biodies == .
gen check7 = 1 - (ROAD_PASS_Ren_Biodies + ROAD_FR_Ren_Biodies)
gen ROAD_PASS_Ren_Biof = (CARS_Ren_Biof)/(CARS_Ren_Biof + TLV_Ren_Biof)
replace ROAD_PASS_Ren_Biof = 1 if geo == "ES" & ROAD_PASS_Ren_Biof == .
gen ROAD_FR_Ren_Biof = TLV_Ren_Biof/(CARS_Ren_Biof + TLV_Ren_Biof)
replace ROAD_FR_Ren_Biof = 0 if geo == "ES" & ROAD_FR_Ren_Biof == .
gen check8 = 1 - (ROAD_PASS_Ren_Biof + ROAD_FR_Ren_Biof)
// 6.3 Shares of services by end-use
gen SERV_SH = SER_SH_Tot/(SER_SH_Tot + SER_HW_Tot + SER_COOK_Tot)
gen SERV_SH_Coal = SER_SH_Coal / (SER_SH_Coal + SER_HW_Coal)
gen SERV_SH_Oil = SER_SH_Oil / (SER_SH_Oil + SER_HW_Oil + SER_COOK_Oil)
gen SERV_SH_Gas = SER_SH_Gas / (SER_SH_Gas + SER_HW_Gas + SER_COOK_Gas)
gen SERV_SH_Heat = SER_SH_Heat / (SER_SH_Heat + SER_HW_Heat)
gen SERV_SH_Ele = SER_SH_Ele / (SER_SH_Ele + SER_HW_Ele + SER_COOK_Ele + SER_AC_Ele + SER_LIGHT_Ele)
gen SERV_HW = SER_HW_Tot/(SER_SH_Tot + SER_HW_Tot + SER_COOK_Tot)
gen SERV_HW_Coal = SER_HW_Coal / (SER_SH_Coal + SER_HW_Coal)
gen SERV_HW_Oil = SER_HW_Oil / (SER_SH_Oil + SER_HW_Oil + SER_COOK_Oil)
gen SERV_HW_Gas = SER_HW_Gas / (SER_SH_Gas + SER_HW_Gas + SER_COOK_Gas)
gen SERV_HW_Heat = SER_HW_Heat / (SER_SH_Heat + SER_HW_Heat)
gen SERV_HW_Ele = SER_HW_Ele / (SER_SH_Ele + SER_HW_Ele + SER_COOK_Ele + SER_AC_Ele + SER_LIGHT_Ele)
gen SERV_COOK = SER_COOK_Tot/(SER_SH_Tot + SER_HW_Tot + SER_COOK_Tot)
gen SERV_COOK_Oil = SER_COOK_Oil / (SER_SH_Oil + SER_HW_Oil + SER_COOK_Oil)
gen SERV_COOK_Gas = SER_COOK_Gas / (SER_SH_Gas + SER_HW_Gas + SER_COOK_Gas)
gen SERV_COOK_Ele = SER_COOK_Ele / (SER_SH_Ele + SER_HW_Ele + SER_COOK_Ele + SER_AC_Ele + SER_LIGHT_Ele)
gen SERV_AC_Ele = SER_AC_Ele / (SER_SH_Ele + SER_HW_Ele + SER_COOK_Ele + SER_AC_Ele + SER_LIGHT_Ele)
gen SERV_LIGHT_Ele = SER_LIGHT_Ele / (SER_SH_Ele + SER_HW_Ele + SER_COOK_Ele + SER_AC_Ele + SER_LIGHT_Ele)
gen check9 = 1 - (SERV_SH + SERV_HW + SERV_COOK)
// Coal is almost 0 for Spain for last years in the balances, but not completetly 0, then use the last observation for the rest of period
replace SERV_SH_Coal = 0.99 if SER_TOT_Coal == 0 & geo == "ES"
replace SERV_HW_Coal = 0.01 if SER_TOT_Coal == 0 & geo == "ES"
gen check10 = 1 - (SERV_SH_Coal + SERV_HW_Coal)
gen check11 = 1 - (SERV_SH_Oil + SERV_HW_Oil + SERV_COOK_Oil)
gen check12 = 1 - (SERV_SH_Gas + SERV_HW_Gas + SERV_COOK_Gas)
replace SERV_SH_Heat = 0 if SER_TOT_Heat == 0 & geo == "ES"
replace SERV_HW_Heat = 0 if SER_TOT_Heat == 0 & geo == "ES"
gen check13 = 1 - (SERV_SH_Heat + SERV_HW_Heat)
gen check14 = 1 - (SERV_SH_Ele + SERV_HW_Ele + SERV_COOK_Ele + SERV_AC_Ele + SERV_LIGHT_Ele)
// 6.4 Shares of households by end-use
gen HHs_SH = HH_SH_Tot/(HH_SH_Tot + HH_HW_Tot + HH_COOK_Tot)
gen HHs_SH_Coal = HH_SH_Coal / (HH_SH_Coal + HH_HW_Coal + HH_COOK_Coal)
gen HHs_SH_Oil = HH_SH_Oil / (HH_SH_Oil + HH_HW_Oil + HH_COOK_Oil)
gen HHs_SH_Gas = HH_SH_Gas / (HH_SH_Gas + HH_HW_Gas + HH_COOK_Gas)
gen HHs_SH_Heat = HH_SH_Heat / (HH_SH_Heat + HH_HW_Heat)
gen HHs_SH_Ren = HH_SH_Ren / (HH_SH_Ren + HH_HW_Ren + HH_COOK_Ren)
gen HHs_SH_Ele = HH_SH_Ele / (HH_SH_Ele + HH_HW_Ele + HH_COOK_Ele + HH_AC_Ele + HH_LIGHT_Ele)
gen HHs_HW = HH_HW_Tot/(HH_SH_Tot + HH_HW_Tot + HH_COOK_Tot)
gen HHs_HW_Coal = HH_HW_Coal / (HH_SH_Coal + HH_HW_Coal + HH_COOK_Coal)
gen HHs_HW_Oil = HH_HW_Oil / (HH_SH_Oil + HH_HW_Oil + HH_COOK_Oil)
gen HHs_HW_Gas = HH_HW_Gas / (HH_SH_Gas + HH_HW_Gas + HH_COOK_Gas)
gen HHs_HW_Heat = HH_HW_Heat / (HH_SH_Heat + HH_HW_Heat)
gen HHs_HW_Ren = HH_HW_Ren / (HH_SH_Ren + HH_HW_Ren + HH_COOK_Ren)
gen HHs_HW_Ele = HH_HW_Ele / (HH_SH_Ele + HH_HW_Ele + HH_COOK_Ele + HH_AC_Ele + HH_LIGHT_Ele)
gen HHs_COOK = HH_COOK_Tot/(HH_SH_Tot + HH_HW_Tot + HH_COOK_Tot)
gen HHs_COOK_Coal = HH_COOK_Coal / (HH_SH_Coal + HH_HW_Coal + HH_COOK_Coal)
gen HHs_COOK_Oil = HH_COOK_Oil / (HH_SH_Oil + HH_HW_Oil + HH_COOK_Oil)
gen HHs_COOK_Gas = HH_COOK_Gas / (HH_SH_Gas + HH_HW_Gas + HH_COOK_Gas)
gen HHs_COOK_Ren = HH_COOK_Ren / (HH_SH_Ren + HH_HW_Ren + HH_COOK_Ren)
gen HHs_COOK_Ele = HH_COOK_Ele / (HH_SH_Ele + HH_HW_Ele + HH_COOK_Ele + HH_AC_Ele + HH_LIGHT_Ele)
gen HHs_AC_Ele = HH_AC_Ele / (HH_SH_Ele + HH_HW_Ele + HH_COOK_Ele + HH_AC_Ele + HH_LIGHT_Ele)
gen HHs_LIGHT_Ele = HH_LIGHT_Ele / (HH_SH_Ele + HH_HW_Ele + HH_COOK_Ele + HH_AC_Ele + HH_LIGHT_Ele)
gen check15 = 1 - (HHs_SH + HHs_HW + HHs_COOK + HHs_AC + HHs_LIGHT)
gen check16 = 1 - (HHs_SH_Coal + HHs_HW_Coal + HHs_COOK_Coal)
gen check17 = 1 - (HHs_SH_Oil + HHs_HW_Oil + HHs_COOK_Oil)
gen check18 = 1 - (HHs_SH_Gas + HHs_HW_Gas + HHs_COOK_Gas)
replace HHs_SH_Heat = 0 if geo == "ES"
replace HHs_HW_Heat = 0 if geo == "ES"
gen check19 = 1 - (HHs_SH_Heat + HHs_HW_Heat)
gen check20 = 1 - (HHs_SH_Ren + HHs_HW_Ren + HHs_COOK_Ren)
gen check21 = 1 - (HHs_SH_Ele + HHs_HW_Ele + HHs_COOK_Ele + HHs_AC_Ele + HHs_LIGHT_Ele)

********************************************************************************
// 7. Order and save ODYSSEE relevant data
********************************************************************************
keep year geo RAIL_PASS RAIL_FR ROAD_PASS ROAD_PASS_Oil_Gasoline ROAD_FR_Oil_Gasoline ROAD_PASS_Oil_Diesel ///
ROAD_FR_Oil_Diesel ROAD_PASS_Oil_LPG ROAD_FR ROAD_FR_Oil_LPG ROAD_PASS_Oil ROAD_FR_Oil ROAD_PASS_Gas ROAD_FR_Gas ROAD_PASS_Ren_Bioeth ///
ROAD_FR_Ren_Bioeth ROAD_PASS_Ren_Biodies ROAD_FR_Ren_Biodies ROAD_PASS_Ren_Biof ROAD_FR_Ren_Biof ///
SERV* HHs* PKM* TKM* DWE AREA
order year geo RAIL_PASS RAIL_FR ROAD_PASS ROAD_PASS_Oil_Gasoline ROAD_FR_Oil_Gasoline ROAD_PASS_Oil_Diesel ///
ROAD_FR_Oil_Diesel ROAD_PASS_Oil_LPG ROAD_FR ROAD_FR_Oil_LPG ROAD_PASS_Oil ROAD_FR_Oil ROAD_PASS_Gas ROAD_FR_Gas ROAD_PASS_Ren_Bioeth ///
ROAD_FR_Ren_Bioeth ROAD_PASS_Ren_Biodies ROAD_FR_Ren_Biodies ROAD_PASS_Ren_Biof ROAD_FR_Ren_Biof ///
SERV* HHs* PKM* TKM* DWE AREA
sort geo year
save "$dataPath\ODYSSEE.dta", replace

timer off 1
timer list 1
dis "Computing time of routine 1: " round(r(t1)/60, 0.1) " minutes"

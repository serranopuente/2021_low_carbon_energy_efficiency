/*
Are We Moving Towards A Low-Carbon Energy-Efficient Economy?
A Decomposition of Energy-Related CO2 Emissions in Spain and EU28, 1995-2017
18. Energy services rebound effect
Darío Serrano Puente (2020)

Last update: November 11th, 2020
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
global basePath "W:\AMICRO\Darío\Climate Change\Low Carbon Energy Efficiency"
global figurePath "$basePath\Figures"
global dataPath "$basePath\Data"
global codePath "$basePath\Codes"
global tablePath "$basePath\Tables"
global LaTeXPath "$basePath\Paper\Figures"

grstyle init
grstyle set plain, horizontal grid
grstyle set legend 11, inside nobox

********************************************************************************
// 1. Create panel with all variables needed
********************************************************************************
// 1.1 Energy-related CO2 estimated emissions, KPEQ, KC, and FEC
use "$dataPath\Estimates_Energy-Related_CO2.dta", clear
merge 1:1 year geo product_id using "$dataPath\FEC_by_Sector_Eurostat_ODYSSEE.dta"
drop _merge
// 1.2 Population
merge m:1 year geo using "$dataPath\Population_Eurostat.dta"
drop if _merge == 2 // Years 2018 and 2019 in the population data
drop _merge
// 1.3 GVA
merge m:1 year geo using "$dataPath\GVA_Eurostat.dta"
drop if _merge == 2 // Years 2018 and 2019 in the GVA data
drop _merge
// 1.3.1 Generate subtotals and totals
gen GVA_AGRI = GVA_AGRI_AF + GVA_AGRI_FISH
label var GVA_AGRI "Agriculture - GVA"
gen GVA_IND = GVA_IND_EEI + GVA_IND_FBT + GVA_IND_TL + GVA_IND_WWP + GVA_IND_PPP + ///
GVA_IND_CPC + GVA_IND_NMM + GVA_IND_BM + GVA_IND_MAC + GVA_IND_TE + GVA_IND_OI + GVA_IND_CON
label var GVA_IND "Industry - GVA"
gen GVA_TOT = GVA_AGRI + GVA_IND + GVA_CPS // Note that we de not include GVA of households as employers
label var GVA_TOT "Total (no HH as eployers) - GVA"
// 1.3.2 Include GDP for comparison with GVA
merge m:1 year geo using "$dataPath\GDP_Eurostat.dta"
drop if _merge == 2 // Years 2018 and 2019 in the GDP data
drop _merge
gen check = GVA_TOT + GVA_HH - GDP
sum check 
drop check GDP_rate 
// 1.4 PPP (Purchasing Power Parity)
merge m:1 year geo using "$dataPath\PPP_Eurostat.dta"
drop if _merge == 2 // Year 2018 in the PPP data
drop _merge
// 1.5 AA (Agricultural Area)
merge m:1 year geo using "$dataPath\AA_Eurostat.dta"
drop if _merge == 2 // Year 2018 in the AA data
drop _merge
// 1.6 FF (Fishing Fleet)
merge m:1 year geo using "$dataPath\FF_Eurostat.dta"
drop if _merge == 2 // Year 2018 in the FF data
drop _merge
// 1.7 PVI (Production Volume Index)
merge m:1 year geo using "$dataPath\PVI_Eurostat.dta"
drop if _merge == 2 // Years 2018 and 2019 in the PVI data
drop _merge
// 1.8 Employment of Services
merge m:1 year geo using "$dataPath\EMP_CPS_Eurostat.dta"
drop if _merge == 2 // Years 2018 and 2019 in the employment data
drop _merge
// 1.9 Heating / Cooling degree days (HDD/CDD)
merge m:1 year geo using "$dataPath\HDD_CDD_Eurostat.dta"
drop if _merge == 2 // Year 2018 in the HDD data
drop _merge
// 1.10 Number od dwellings and average floor area of dwelling (DWE and ARE)
merge m:1 year geo using "$dataPath\DWE_ARE_ODYSSEE.dta"
drop _merge
// 1.11 Passenger- and Tonne-Kilometers (TKM and PKM)
merge m:1 year geo using "$dataPath\PKM_TKM_ODYSSEE.dta"
drop if _merge == 2 // Year 2018 in the PKM/TKM data
drop _merge
// 1.12 FEC - Generate totals of each subsector
foreach var in FEC_TOT FEC_ECO FEC_AGRI_AF FEC_AGRI_FISH FEC_AGRI FEC_IND_EEI ///
FEC_IND_FBT FEC_IND_TL FEC_IND_WWP FEC_IND_PPP FEC_IND_CPC FEC_IND_NMM FEC_IND_BM ///
FEC_IND_MAC FEC_IND_TE FEC_IND_OI FEC_IND_CON FEC_IND FEC_CPS FEC_CPS_SH FEC_CPS_HW ///
FEC_CPS_COOK FEC_CPS_AC FEC_CPS_LIGHT FEC_HH FEC_HH_SH FEC_HH_HW FEC_HH_COOK FEC_HH_AC ///
FEC_HH_LIGHT FEC_TRA FEC_TRA_PASS FEC_TRA_FR FEC_TRA_PASS_ROAD FEC_TRA_FR_ROAD ///
FEC_TRA_PASS_RAIL FEC_TRA_FR_RAIL FEC_TRA_PASS_AVI FEC_TRA_FR_NAVI FEC_TRA_FR_PIPE{
bysort year geo: egen `var'_Tot = total(`var')
label var `var'_Tot "Total `var'"
}
// 1.13 Keep one observation per region&year and relevant variables
duplicates drop geo year, force

********************************************************************************
// 2. Small Value Strategy (Ang & Choi, 1997) - Replace 0 values with 10^(-20)
********************************************************************************
foreach var in FEC_TOT FEC_ECO FEC_AGRI_AF FEC_AGRI_FISH FEC_AGRI FEC_IND_EEI ///
FEC_IND_FBT FEC_IND_TL FEC_IND_WWP FEC_IND_PPP FEC_IND_CPC FEC_IND_NMM FEC_IND_BM ///
FEC_IND_MAC FEC_IND_TE FEC_IND_OI FEC_IND_CON FEC_IND FEC_CPS FEC_CPS_SH FEC_CPS_HW ///
FEC_CPS_COOK FEC_CPS_AC FEC_CPS_LIGHT FEC_HH FEC_HH_SH FEC_HH_HW FEC_HH_COOK FEC_HH_AC ///
FEC_HH_LIGHT FEC_TRA FEC_TRA_PASS FEC_TRA_FR FEC_TRA_PASS_ROAD FEC_TRA_FR_ROAD ///
FEC_TRA_PASS_RAIL FEC_TRA_FR_RAIL FEC_TRA_PASS_AVI FEC_TRA_FR_NAVI FEC_TRA_FR_PIPE ///
KPEQ KC CO2_TOT CO2_TOT_Tot CO2_ECO CO2_ECO_Tot CO2_AGRI_AF CO2_AGRI_AF_Tot ///
CO2_AGRI_FISH CO2_AGRI_FISH_Tot CO2_AGRI CO2_AGRI_Tot CO2_IND_EEI CO2_IND_EEI_Tot ///
CO2_IND_FBT CO2_IND_FBT_Tot CO2_IND_TL CO2_IND_TL_Tot CO2_IND_WWP CO2_IND_WWP_Tot ///
CO2_IND_PPP CO2_IND_PPP_Tot CO2_IND_CPC CO2_IND_CPC_Tot CO2_IND_NMM CO2_IND_NMM_Tot ///
CO2_IND_BM CO2_IND_BM_Tot CO2_IND_MAC CO2_IND_MAC_Tot CO2_IND_TE CO2_IND_TE_Tot ///
CO2_IND_OI CO2_IND_OI_Tot CO2_IND_CON CO2_IND_CON_Tot CO2_IND CO2_IND_Tot CO2_CPS ///
CO2_CPS_Tot CO2_CPS_SH CO2_CPS_SH_Tot CO2_CPS_HW CO2_CPS_HW_Tot CO2_CPS_COOK ///
CO2_CPS_COOK_Tot CO2_CPS_AC CO2_CPS_AC_Tot CO2_CPS_LIGHT CO2_CPS_LIGHT_Tot ///
CO2_HH CO2_HH_Tot CO2_HH_SH CO2_HH_SH_Tot CO2_HH_HW CO2_HH_HW_Tot CO2_HH_COOK ///
CO2_HH_COOK_Tot CO2_HH_AC CO2_HH_AC_Tot CO2_HH_LIGHT CO2_HH_LIGHT_Tot CO2_TRA ///
CO2_TRA_Tot CO2_TRA_PASS CO2_TRA_PASS_Tot CO2_TRA_FR CO2_TRA_FR_Tot CO2_TRA_PASS_ROAD ///
CO2_TRA_PASS_ROAD_Tot CO2_TRA_FR_ROAD CO2_TRA_FR_ROAD_Tot CO2_TRA_PASS_RAIL ///
CO2_TRA_PASS_RAIL_Tot CO2_TRA_FR_RAIL CO2_TRA_FR_RAIL_Tot CO2_TRA_PASS_AVI ///
CO2_TRA_PASS_AVI_Tot CO2_TRA_FR_NAVI CO2_TRA_FR_NAVI_Tot CO2_TRA_FR_PIPE ///
CO2_TRA_FR_PIPE_Tot POP GVA_AGRI_AF GVA_AGRI_FISH GVA_IND_EEI GVA_IND_FBT ///
GVA_IND_TL GVA_IND_WWP GVA_IND_PPP GVA_IND_CPC GVA_IND_NMM GVA_IND_BM GVA_IND_MAC ///
GVA_IND_TE GVA_IND_OI GVA_IND_CON GVA_CPS GVA_HH GVA_AGRI GVA_IND GVA_TOT GDP ///
PPP AA FF PVI_IND_EEI PVI_IND_FBT PVI_IND_TL PVI_IND_WWP PVI_IND_PPP PVI_IND_CPC ///
PVI_IND_NMM PVI_IND_BM PVI_IND_MAC PVI_IND_TE PVI_IND_OI PVI_IND_CON EMP_CPS HDD ///
HDD_ref CDD CDD_ref DWE AREA PKM PKM_AVI PKM_RAIL PKM_ROAD TKM_PIPE TKM TKM_RAIL ///
TKM_NAVI TKM_ROAD FEC_TOT_Tot FEC_ECO_Tot FEC_AGRI_AF_Tot FEC_AGRI_FISH_Tot ///
FEC_AGRI_Tot FEC_IND_EEI_Tot FEC_IND_FBT_Tot FEC_IND_TL_Tot FEC_IND_WWP_Tot ///
FEC_IND_PPP_Tot FEC_IND_CPC_Tot FEC_IND_NMM_Tot FEC_IND_BM_Tot FEC_IND_MAC_Tot ///
FEC_IND_TE_Tot FEC_IND_OI_Tot FEC_IND_CON_Tot FEC_IND_Tot FEC_CPS_Tot FEC_CPS_SH_Tot ///
FEC_CPS_HW_Tot FEC_CPS_COOK_Tot FEC_CPS_AC_Tot FEC_CPS_LIGHT_Tot FEC_HH_Tot ///
FEC_HH_SH_Tot FEC_HH_HW_Tot FEC_HH_COOK_Tot FEC_HH_AC_Tot FEC_HH_LIGHT_Tot ///
FEC_TRA_Tot FEC_TRA_PASS_Tot FEC_TRA_FR_Tot FEC_TRA_PASS_ROAD_Tot FEC_TRA_FR_ROAD_Tot ///
FEC_TRA_PASS_RAIL_Tot FEC_TRA_FR_RAIL_Tot FEC_TRA_PASS_AVI_Tot FEC_TRA_FR_NAVI_Tot ///
FEC_TRA_FR_PIPE_Tot{
replace `var' = 10^(-20) if `var' == 0
}

********************************************************************************
// 3. Generate apparent energy efficiency measures
********************************************************************************
// Apparent
foreach var in AGRI_AF{
gen EFF_`var'_app = 1/(FEC_`var'_Tot/AA)
}
foreach var in AGRI_FISH{
gen EFF_`var'_app = 1/(FEC_`var'_Tot/FF)
}
foreach var in IND_EEI IND_FBT IND_TL IND_WWP IND_PPP IND_CPC IND_NMM IND_BM ///
IND_MAC IND_TE IND_OI IND_CON{
gen EFF_`var'_app = 1/(FEC_`var'_Tot/PVI_`var')
}
foreach var in CPS{
gen EFF_`var'_app = 1/(FEC_CPS_Tot/EMP_CPS)
}
foreach var in HH_SH{
gen EFF_`var'_app = 1/(FEC_`var'_Tot/(AREA*DWE))
}
foreach var in HH_HW HH_COOK HH_AC HH_LIGHT{
gen EFF_`var'_app = 1/(FEC_`var'_Tot/DWE)
}
foreach var in ROAD RAIL AVI{
gen EFF_TRA_PASS_`var'_app = 1/(FEC_TRA_PASS_`var'_Tot/PKM_`var')
}
foreach var in ROAD RAIL NAVI PIPE{
gen EFF_TRA_FR_`var'_app = 1/(FEC_TRA_FR_`var'_Tot/TKM_`var')
}

********************************************************************************
// 4. Calculate energy consumption and energy efficiency indexes
********************************************************************************
sort geo year
// Generate variables in index base 1995 and 2007
foreach var in AGRI_AF AGRI_FISH IND_EEI IND_FBT IND_TL IND_WWP IND_PPP IND_CPC ///
IND_NMM IND_BM IND_MAC IND_TE IND_OI IND_CON CPS HH_SH HH_HW HH_COOK HH_AC ///
HH_LIGHT TRA_PASS_ROAD TRA_PASS_RAIL TRA_PASS_AVI TRA_FR_ROAD TRA_FR_RAIL ///
TRA_FR_NAVI TRA_FR_PIPE{
// 4.1 Apparent efficiency index
gen base1_EFF_`var'_app = EFF_`var'_app if year == 1995
bysort geo: egen aux = mean(base1_EFF_`var'_app)
replace base1_EFF_`var'_app = aux
gen EFF_`var'_app_1995 = EFF_`var'_app/base1_EFF_`var'_app
drop aux
gen base2_EFF_`var'_app = EFF_`var'_app if year == 2007
bysort geo: egen aux = mean(base2_EFF_`var'_app)
replace base2_EFF_`var'_app = aux
gen EFF_`var'_app_2007 = EFF_`var'_app/base2_EFF_`var'_app
drop aux
// 4.2 Final energy consumption index
gen base1_FEC_`var' = FEC_`var'_Tot if year == 1995
bysort geo: egen aux = mean(base1_FEC_`var')
replace base1_FEC_`var' = aux
gen FEC_`var'_1995 = FEC_`var'_Tot/base1_FEC_`var'
drop aux
gen base2_FEC_`var' = FEC_`var'_Tot if year == 2007
bysort geo: egen aux = mean(base2_FEC_`var')
replace base2_FEC_`var' = aux
gen FEC_`var'_2007 = FEC_`var'_Tot/base2_FEC_`var'
drop aux
}
// 4.3 Technical energy efficiency index (ODEX ODYSSEE methodology)
// Mantain specific consumption constant if negative energy savings (difference between unit consumption)
egen geo_id = group(geo)
egen time_id = group(year)
xtset geo_id time_id
// Generate unit consumption for analysis, i.e. if difference between UCs is negative, replace FEC by L.FEC
foreach var in AGRI_AF{
gen UC_`var' = FEC_`var'_Tot/AA
gen diff_`var' = UC_`var' - L.UC_`var'
gen UC_`var'_aux = L.FEC_`var'_Tot/AA if diff_`var' > 0
}
foreach var in AGRI_FISH{
gen UC_`var' = FEC_`var'_Tot/FF
gen diff_`var' = UC_`var' - L.UC_`var'
gen UC_`var'_aux = L.FEC_`var'_Tot/FF if diff_`var' > 0
}
foreach var in IND_EEI IND_FBT IND_TL IND_WWP IND_PPP IND_CPC IND_NMM IND_BM ///
IND_MAC IND_TE IND_OI IND_CON{
gen UC_`var' = FEC_`var'_Tot/PVI_`var'
gen diff_`var' = UC_`var' - L.UC_`var'
gen UC_`var'_aux = L.FEC_`var'_Tot/PVI_`var' if diff_`var' > 0
}
foreach var in CPS{
gen UC_`var' = FEC_`var'_Tot/EMP_`var'
gen diff_`var' = UC_`var' - L.UC_`var'
gen UC_`var'_aux = L.FEC_`var'_Tot/EMP_`var' if diff_`var' > 0
}
foreach var in HH_SH{
gen UC_`var' = FEC_`var'_Tot/(AREA*DWE)
gen diff_`var' = UC_`var' - L.UC_`var'
gen UC_`var'_aux = L.FEC_`var'_Tot/(AREA*DWE) if diff_`var' > 0
}
foreach var in HH_HW HH_COOK HH_AC HH_LIGHT{
gen UC_`var' = FEC_`var'_Tot/DWE
gen diff_`var' = UC_`var' - L.UC_`var'
gen UC_`var'_aux = L.FEC_`var'_Tot/DWE if diff_`var' > 0
}
foreach var in ROAD RAIL AVI{
gen UC_TRA_PASS_`var' = FEC_TRA_PASS_`var'_Tot/PKM_`var'
gen diff_TRA_PASS_`var' = UC_TRA_PASS_`var' - L.UC_TRA_PASS_`var'
gen UC_TRA_PASS_`var'_aux = L.FEC_TRA_PASS_`var'_Tot/PKM_`var' if diff_TRA_PASS_`var' > 0
}
foreach var in ROAD RAIL NAVI PIPE{
gen UC_TRA_FR_`var' = FEC_TRA_FR_`var'_Tot/TKM_`var'
gen diff_TRA_FR_`var' = UC_TRA_FR_`var' - L.UC_TRA_FR_`var'
gen UC_TRA_FR_`var'_aux = L.FEC_TRA_FR_`var'_Tot/TKM_`var' if diff_TRA_FR_`var' > 0
}
// Generate technical/ODEX efficiency index
foreach var in AGRI_AF{
gen EFF_`var'_odex_1995 = 100 if year == 1995
forvalues y = 1996(1)2017{
replace EFF_`var'_odex_1995 = L.EFF_`var'_odex_1995*(FEC_`var'_Tot/(FEC_`var'_Tot + AA*(L.UC_`var' - UC_`var'))) if diff_`var' < 0 & year == `y'
replace EFF_`var'_odex_1995 = L.EFF_`var'_odex_1995*(FEC_`var'_Tot/(FEC_`var'_Tot + AA*(0))) if diff_`var' >= 0 & year == `y'
}
}
foreach var in AGRI_FISH{
gen EFF_`var'_odex_1995 = 100 if year == 1995
forvalues y = 1996(1)2017{
replace EFF_`var'_odex_1995 = L.EFF_`var'_odex_1995*(FEC_`var'_Tot/(FEC_`var'_Tot + FF*(L.UC_`var' - UC_`var'))) if diff_`var' < 0 & year == `y'
replace EFF_`var'_odex_1995 = L.EFF_`var'_odex_1995*(FEC_`var'_Tot/(FEC_`var'_Tot + FF*(0))) if diff_`var' >= 0 & year == `y'
}
}
foreach var in IND_EEI IND_FBT IND_TL IND_WWP IND_PPP IND_CPC IND_NMM IND_BM ///
IND_MAC IND_TE IND_OI IND_CON{
gen EFF_`var'_odex_1995 = 100 if year == 1995
forvalues y = 1996(1)2017{
replace EFF_`var'_odex_1995 = L.EFF_`var'_odex_1995*(FEC_`var'_Tot/(FEC_`var'_Tot + PVI_`var'*(L.UC_`var' - UC_`var'))) if diff_`var' < 0 & year == `y'
replace EFF_`var'_odex_1995 = L.EFF_`var'_odex_1995*(FEC_`var'_Tot/(FEC_`var'_Tot + PVI_`var'*(0))) if diff_`var' >= 0 & year == `y'
}
}
foreach var in CPS{
gen EFF_`var'_odex_1995 = 100 if year == 1995
forvalues y = 1996(1)2017{
replace EFF_`var'_odex_1995 = L.EFF_`var'_odex_1995*(FEC_`var'_Tot/(FEC_`var'_Tot + EMP_`var'*(L.UC_`var' - UC_`var'))) if diff_`var' < 0 & year == `y'
replace EFF_`var'_odex_1995 = L.EFF_`var'_odex_1995*(FEC_`var'_Tot/(FEC_`var'_Tot + EMP_`var'*(0))) if diff_`var' >= 0 & year == `y'
}
}
foreach var in HH_SH{
gen EFF_`var'_odex_1995 = 100 if year == 1995
forvalues y = 1996(1)2017{
replace EFF_`var'_odex_1995 = L.EFF_`var'_odex_1995*(FEC_`var'_Tot/(FEC_`var'_Tot + (AREA*DWE)*(L.UC_`var' - UC_`var'))) if diff_`var' < 0 & year == `y'
replace EFF_`var'_odex_1995 = L.EFF_`var'_odex_1995*(FEC_`var'_Tot/(FEC_`var'_Tot + (AREA*DWE)*(0))) if diff_`var' >= 0 & year == `y'
}
}
foreach var in HH_HW HH_COOK HH_AC HH_LIGHT{
gen EFF_`var'_odex_1995 = 100 if year == 1995
forvalues y = 1996(1)2017{
replace EFF_`var'_odex_1995 = L.EFF_`var'_odex_1995*(FEC_`var'_Tot/(FEC_`var'_Tot + DWE*(L.UC_`var' - UC_`var'))) if diff_`var' < 0 & year == `y'
replace EFF_`var'_odex_1995 = L.EFF_`var'_odex_1995*(FEC_`var'_Tot/(FEC_`var'_Tot + DWE*(0))) if diff_`var' >= 0 & year == `y'
}
}
foreach var in ROAD RAIL AVI{
gen EFF_TRA_PASS_`var'_odex_1995 = 100 if year == 1995
forvalues y = 1996(1)2017{
replace EFF_TRA_PASS_`var'_odex_1995 = L.EFF_TRA_PASS_`var'_odex_1995*(FEC_TRA_PASS_`var'_Tot/(FEC_TRA_PASS_`var'_Tot + PKM_`var'*(L.UC_TRA_PASS_`var' - UC_TRA_PASS_`var'))) if diff_TRA_PASS_`var' < 0 & year == `y'
replace EFF_TRA_PASS_`var'_odex_1995 = L.EFF_TRA_PASS_`var'_odex_1995*(FEC_TRA_PASS_`var'_Tot/(FEC_TRA_PASS_`var'_Tot + PKM_`var'*(0))) if diff_TRA_PASS_`var' >= 0 & year == `y'
}
}
foreach var in ROAD RAIL NAVI PIPE{
gen EFF_TRA_FR_`var'_odex_1995 = 100 if year == 1995
forvalues y = 1996(1)2017{
replace EFF_TRA_FR_`var'_odex_1995 = L.EFF_TRA_FR_`var'_odex_1995*(FEC_TRA_FR_`var'_Tot/(FEC_TRA_FR_`var'_Tot + TKM_`var'*(L.UC_TRA_FR_`var' - UC_TRA_FR_`var'))) if diff_TRA_FR_`var' < 0 & year == `y'
replace EFF_TRA_FR_`var'_odex_1995 = L.EFF_TRA_FR_`var'_odex_1995*(FEC_TRA_FR_`var'_Tot/(FEC_TRA_FR_`var'_Tot + TKM_`var'*(0))) if diff_TRA_FR_`var' >= 0 & year == `y'
}
}
// Generate Apparent Efficiency Totals by 5-Sector
foreach y in 1995 2007{
gen EFF_AGRI_app_`y' =  (EFF_AGRI_AF_app_`y'*FEC_AGRI_AF_Tot + EFF_AGRI_FISH_app_`y'*FEC_AGRI_FISH_Tot)/FEC_AGRI_Tot
}
foreach y in 1995 2007{
gen EFF_IND_app_`y' =  (EFF_IND_EEI_app_`y'*FEC_IND_EEI_Tot + EFF_IND_FBT_app_`y'*FEC_IND_FBT_Tot + ///
EFF_IND_TL_app_`y'*FEC_IND_TL_Tot + EFF_IND_WWP_app_`y'*FEC_IND_WWP_Tot + EFF_IND_PPP_app_`y'*FEC_IND_PPP_Tot + ///
EFF_IND_CPC_app_`y'*FEC_IND_CPC_Tot + EFF_IND_NMM_app_`y'*FEC_IND_NMM_Tot + EFF_IND_BM_app_`y'*FEC_IND_BM_Tot + ///
EFF_IND_MAC_app_`y'*FEC_IND_MAC_Tot + EFF_IND_TE_app_`y'*FEC_IND_TE_Tot + EFF_IND_OI_app_`y'*FEC_IND_OI_Tot + ///
EFF_IND_CON_app_`y'*FEC_IND_CON_Tot)/FEC_IND_Tot
}
foreach y in 1995 2007{
gen EFF_HH_app_`y' =  (EFF_HH_SH_app_`y'*FEC_HH_SH_Tot + EFF_HH_HW_app_`y'*FEC_HH_HW_Tot + ///
EFF_HH_COOK_app_`y'*FEC_HH_COOK_Tot + EFF_HH_AC_app_`y'*FEC_HH_AC_Tot + EFF_HH_LIGHT_app_`y'*FEC_HH_LIGHT_Tot)/FEC_HH_Tot
}
foreach y in 1995 2007{
gen EFF_TRA_app_`y' =  (EFF_TRA_PASS_ROAD_app_`y'*FEC_TRA_PASS_ROAD_Tot + EFF_TRA_PASS_RAIL_app_`y'*FEC_TRA_PASS_RAIL_Tot + ///
EFF_TRA_PASS_AVI_app_`y'*FEC_TRA_PASS_AVI_Tot + EFF_TRA_FR_ROAD_app_`y'*FEC_TRA_FR_ROAD_Tot + EFF_TRA_FR_RAIL_app_`y'*FEC_TRA_FR_RAIL_Tot + ///
EFF_TRA_FR_NAVI_app_`y'*FEC_TRA_FR_NAVI_Tot + EFF_TRA_FR_PIPE_app_`y'*FEC_TRA_FR_PIPE_Tot)/FEC_TRA_Tot
}
// Generate Apparent Efficiency Total
foreach y in 1995 2007{
gen EFF_TOT_app_`y' =  (EFF_IND_app_`y'*FEC_IND_Tot + EFF_AGRI_app_`y'*FEC_AGRI_Tot + ///
EFF_CPS_app_`y'*FEC_CPS_Tot + EFF_HH_app_`y'*FEC_HH_Tot + EFF_TRA_app_`y'*FEC_TRA_Tot)/FEC_TOT_Tot
}
// Generate Technical Efficiency Totals by 5-Sector
xtset geo_id time_id
foreach y in 1995{
gen EFF_AGRI_odex_`y' =  (EFF_AGRI_AF_odex_`y'*FEC_AGRI_AF_Tot + EFF_AGRI_FISH_odex_`y'*FEC_AGRI_FISH_Tot)/FEC_AGRI_Tot if year == 1995
forvalues j = 1996(1)2017{
replace EFF_AGRI_odex_`y' = L.EFF_AGRI_odex_`y'*((EFF_AGRI_AF_odex_`y'/L.EFF_AGRI_AF_odex_`y'*FEC_AGRI_AF_Tot + EFF_AGRI_FISH_odex_`y'/L.EFF_AGRI_FISH_odex_`y'*FEC_AGRI_FISH_Tot)/FEC_AGRI_Tot) if year == `j'
}
}
foreach y in 1995{
gen EFF_IND_odex_`y' =  (EFF_IND_EEI_odex_`y'*FEC_IND_EEI_Tot + EFF_IND_FBT_odex_`y'*FEC_IND_FBT_Tot + ///
EFF_IND_TL_odex_`y'*FEC_IND_TL_Tot + EFF_IND_WWP_odex_`y'*FEC_IND_WWP_Tot + EFF_IND_PPP_odex_`y'*FEC_IND_PPP_Tot + ///
EFF_IND_CPC_odex_`y'*FEC_IND_CPC_Tot + EFF_IND_NMM_odex_`y'*FEC_IND_NMM_Tot + EFF_IND_BM_odex_`y'*FEC_IND_BM_Tot + ///
EFF_IND_MAC_odex_`y'*FEC_IND_MAC_Tot + EFF_IND_TE_odex_`y'*FEC_IND_TE_Tot + EFF_IND_OI_odex_`y'*FEC_IND_OI_Tot + ///
EFF_IND_CON_odex_`y'*FEC_IND_CON_Tot)/FEC_IND_Tot if year == 1995
forvalues j = 1996(1)2017{
replace EFF_IND_odex_`y' =  L.EFF_IND_odex_`y'*((EFF_IND_EEI_odex_`y'/L.EFF_IND_EEI_odex_`y'*FEC_IND_EEI_Tot + EFF_IND_FBT_odex_`y'/L.EFF_IND_FBT_odex_`y'*FEC_IND_FBT_Tot + ///
EFF_IND_TL_odex_`y'/L.EFF_IND_TL_odex_`y'*FEC_IND_TL_Tot + EFF_IND_WWP_odex_`y'/L.EFF_IND_WWP_odex_`y'*FEC_IND_WWP_Tot + EFF_IND_PPP_odex_`y'/L.EFF_IND_PPP_odex_`y'*FEC_IND_PPP_Tot + ///
EFF_IND_CPC_odex_`y'/L.EFF_IND_CPC_odex_`y'*FEC_IND_CPC_Tot + EFF_IND_NMM_odex_`y'/L.EFF_IND_NMM_odex_`y'*FEC_IND_NMM_Tot + EFF_IND_BM_odex_`y'/L.EFF_IND_BM_odex_`y'*FEC_IND_BM_Tot + ///
EFF_IND_MAC_odex_`y'/L.EFF_IND_MAC_odex_`y'*FEC_IND_MAC_Tot + EFF_IND_TE_odex_`y'/L.EFF_IND_TE_odex_`y'*FEC_IND_TE_Tot + EFF_IND_OI_odex_`y'/L.EFF_IND_OI_odex_`y'*FEC_IND_OI_Tot + ///
EFF_IND_CON_odex_`y'/L.EFF_IND_CON_odex_`y'*FEC_IND_CON_Tot)/FEC_IND_Tot) if year == `j'
}
}
foreach y in 1995{
gen EFF_HH_odex_`y' =  (EFF_HH_SH_odex_`y'*FEC_HH_SH_Tot + EFF_HH_HW_odex_`y'*FEC_HH_HW_Tot + ///
EFF_HH_COOK_odex_`y'*FEC_HH_COOK_Tot + EFF_HH_AC_odex_`y'*FEC_HH_AC_Tot + EFF_HH_LIGHT_odex_`y'*FEC_HH_LIGHT_Tot)/FEC_HH_Tot if year == 1995
forvalues j = 1996(1)2017{
replace EFF_HH_odex_`y' =  L.EFF_HH_odex_`y'*((EFF_HH_SH_odex_`y'/L.EFF_HH_SH_odex_`y'*FEC_HH_SH_Tot + EFF_HH_HW_odex_`y'/L.EFF_HH_HW_odex_`y'*FEC_HH_HW_Tot + ///
EFF_HH_COOK_odex_`y'/L.EFF_HH_COOK_odex_`y'*FEC_HH_COOK_Tot + EFF_HH_AC_odex_`y'/L.EFF_HH_AC_odex_`y'*FEC_HH_AC_Tot + EFF_HH_LIGHT_odex_`y'/L.EFF_HH_LIGHT_odex_`y'*FEC_HH_LIGHT_Tot)/FEC_HH_Tot) if year == `j'
}
}
foreach y in 1995{
gen EFF_TRA_odex_`y' =  (EFF_TRA_PASS_ROAD_odex_`y'*FEC_TRA_PASS_ROAD_Tot + EFF_TRA_PASS_RAIL_odex_`y'*FEC_TRA_PASS_RAIL_Tot + ///
EFF_TRA_PASS_AVI_odex_`y'*FEC_TRA_PASS_AVI_Tot + EFF_TRA_FR_ROAD_odex_`y'*FEC_TRA_FR_ROAD_Tot + EFF_TRA_FR_RAIL_odex_`y'*FEC_TRA_FR_RAIL_Tot + ///
EFF_TRA_FR_NAVI_odex_`y'*FEC_TRA_FR_NAVI_Tot + EFF_TRA_FR_PIPE_odex_`y'*FEC_TRA_FR_PIPE_Tot)/FEC_TRA_Tot if year == 1995
forvalues j = 1996(1)2017{
replace EFF_TRA_odex_`y' =  L.EFF_TRA_odex_`y'*((EFF_TRA_PASS_ROAD_odex_`y'/L.EFF_TRA_PASS_ROAD_odex_`y'*FEC_TRA_PASS_ROAD_Tot + EFF_TRA_PASS_RAIL_odex_`y'/L.EFF_TRA_PASS_RAIL_odex_`y'*FEC_TRA_PASS_RAIL_Tot + ///
EFF_TRA_PASS_AVI_odex_`y'/L.EFF_TRA_PASS_AVI_odex_`y'*FEC_TRA_PASS_AVI_Tot + EFF_TRA_FR_ROAD_odex_`y'/L.EFF_TRA_FR_ROAD_odex_`y'*FEC_TRA_FR_ROAD_Tot + EFF_TRA_FR_RAIL_odex_`y'/L.EFF_TRA_FR_RAIL_odex_`y'*FEC_TRA_FR_RAIL_Tot + ///
EFF_TRA_FR_NAVI_odex_`y'/L.EFF_TRA_FR_NAVI_odex_`y'*FEC_TRA_FR_NAVI_Tot + EFF_TRA_FR_PIPE_odex_`y'/L.EFF_TRA_FR_PIPE_odex_`y'*FEC_TRA_FR_PIPE_Tot)/FEC_TRA_Tot) if year == `j'
}
}
// Generate Technical Efficiency Total
foreach y in 1995{
gen EFF_TOT_odex_`y' =  (EFF_IND_odex_`y'*FEC_IND_Tot + EFF_AGRI_odex_`y'*FEC_AGRI_Tot + ///
EFF_CPS_odex_`y'*FEC_CPS_Tot + EFF_HH_odex_`y'*FEC_HH_Tot + EFF_TRA_odex_`y'*FEC_TRA_Tot)/FEC_TOT_Tot if year == 1995
forvalues j = 1996(1)2017{
replace EFF_TOT_odex_`y' =  L.EFF_TOT_odex_`y'*((EFF_IND_odex_`y'/L.EFF_IND_odex_`y'*FEC_IND_Tot + EFF_AGRI_odex_`y'/L.EFF_AGRI_odex_`y'*FEC_AGRI_Tot + ///
EFF_CPS_odex_`y'/L.EFF_CPS_odex_`y'*FEC_CPS_Tot + EFF_HH_odex_`y'/L.EFF_HH_odex_`y'*FEC_HH_Tot + EFF_TRA_odex_`y'/L.EFF_TRA_odex_`y'*FEC_TRA_Tot)/FEC_TOT_Tot) if year == `j'
}
}
// Technical base 2007
foreach var in TOT AGRI IND HH TRA AGRI_AF AGRI_FISH IND_EEI IND_FBT IND_TL IND_WWP IND_PPP IND_CPC ///
IND_NMM IND_BM IND_MAC IND_TE IND_OI IND_CON CPS HH_SH HH_HW HH_COOK HH_AC ///
HH_LIGHT TRA_PASS_ROAD TRA_PASS_RAIL TRA_PASS_AVI TRA_FR_ROAD TRA_FR_RAIL ///
TRA_FR_NAVI TRA_FR_PIPE{
replace EFF_`var'_odex_1995 = 1+(1 - EFF_`var'_odex_1995/100)
gen base2_EFF_`var'_odex = EFF_`var'_odex_1995 if year == 2007
bysort geo: egen aux = mean(base2_EFF_`var'_odex)
replace base2_EFF_`var'_odex = aux
gen EFF_`var'_odex_2007 = EFF_`var'_odex_1995/base2_EFF_`var'_odex
drop aux
}
// Generate Consumption Totals
foreach var in TOT AGRI IND HH TRA{
gen base1_FEC_`var' = FEC_`var'_Tot if year == 1995
bysort geo: egen aux = mean(base1_FEC_`var')
replace base1_FEC_`var' = aux
gen FEC_`var'_1995 = FEC_`var'_Tot/base1_FEC_`var'
drop aux
gen base2_FEC_`var' = FEC_`var'_Tot if year == 2007
bysort geo: egen aux = mean(base2_FEC_`var')
replace base2_FEC_`var' = aux
gen FEC_`var'_2007 = FEC_`var'_Tot/base2_FEC_`var'
drop aux
}

// Keep relevant variables
sort geo year

********************************************************************************
// 5. Compute the average annual change in both periods
********************************************************************************
foreach var in TOT AGRI IND HH TRA ///
AGRI_AF AGRI_FISH IND_EEI IND_FBT IND_TL IND_WWP IND_PPP IND_CPC ///
IND_NMM IND_BM IND_MAC IND_TE IND_OI IND_CON CPS HH_SH HH_HW HH_COOK HH_AC ///
HH_LIGHT TRA_PASS_ROAD TRA_PASS_RAIL TRA_PASS_AVI TRA_FR_ROAD TRA_FR_RAIL TRA_FR_NAVI TRA_FR_PIPE{
gen AC_FEC_`var'_1995 = 0
gen AC_FEC_`var'_2007 = 0
gen AC_EFF_`var'_odex_1995 = 0
gen AC_EFF_`var'_odex_2007 = 0
foreach g in 1 2{
// First period
reg FEC_`var'_1995 time_id if geo_id == `g' & year <= 2007
mat A=e(b)
scalar AC=A[1,1]
replace AC_FEC_`var'_1995 = AC if geo_id == `g' & year <= 2007
bysort geo: egen aux = mean(AC_FEC_`var'_1995)
replace AC_FEC_`var'_1995 = aux
drop aux
reg EFF_`var'_odex_1995 time_id if geo_id == `g' & year <= 2007
mat A=e(b)
scalar AC=A[1,1]
replace AC_EFF_`var'_odex_1995 = AC if geo_id == `g' & year <= 2007
bysort geo: egen aux = mean(AC_EFF_`var'_odex_1995)
replace AC_EFF_`var'_odex_1995 = aux
drop aux
// Second period
reg FEC_`var'_2007 time_id if geo_id == `g' & year >= 2007
mat A=e(b)
scalar AC=A[1,1]
replace AC_FEC_`var'_2007 = AC if geo_id == `g' & year >= 2007
bysort geo: egen aux = mean(AC_FEC_`var'_2007)
replace AC_FEC_`var'_2007 = aux
drop aux
reg EFF_`var'_odex_2007 time_id if geo_id == `g' & year >= 2007
mat A=e(b)
scalar AC=A[1,1]
replace AC_EFF_`var'_odex_2007 = AC if geo_id == `g' & year >= 2007
bysort geo: egen aux = mean(AC_EFF_`var'_odex_2007)
replace AC_EFF_`var'_odex_2007 = aux
drop aux
}
}
// Export evolution of Efficieny and FEC for Totals and figures
preserve
keep year geo FEC_TOT_1995 FEC_AGRI_1995 FEC_IND_1995 FEC_CPS_1995 FEC_HH_1995 FEC_TRA_1995 ///
EFF_TOT_app_1995 EFF_AGRI_app_1995 EFF_IND_app_1995 EFF_CPS_app_1995 EFF_HH_app_1995 EFF_TRA_app_1995 ///
EFF_TOT_odex_1995 EFF_AGRI_odex_1995 EFF_IND_odex_1995 EFF_CPS_odex_1995 EFF_HH_odex_1995 EFF_TRA_odex_1995
foreach var in TOT AGRI IND CPS HH TRA{
replace FEC_`var'_1995 = FEC_`var'_1995*100
foreach t in app odex{
replace EFF_`var'_`t'_1995 = EFF_`var'_`t'_1995*100
}
}
export excel using "$tablePath\RE_table.xlsx", sheet("Evolution Eff & FEC") sheetmodify firstrow(variables)
egen geo_id = group(geo)
egen time_id = group(year)
// Figures
local geo `" "ES" "EU28" "'
foreach g of local geo{
foreach var in AGRI IND CPS HH TRA{
tssmooth ma fit1 = FEC_`var'_1995 if geo == "`g'", window(3)
tssmooth ma fit2 = EFF_`var'_app_1995 if geo == "`g'", window(3)
tssmooth ma fit3 = EFF_`var'_odex_1995 if geo == "`g'", window(3)
qui twoway (line fit1 year if geo == "`g'", lcolor("0 64 129") lwidth(medthick)) ///
(scatter FEC_`var'_1995 year if geo == "`g'", mcolor("0 64 129 %20") msize(medsmall)) ///
(line fit2 year if geo == "`g'", lcolor("163 41 56") lwidth(medthick)) ///
(scatter EFF_`var'_app_1995 year if geo == "`g'", mcolor("163 41 56 %20") msize(medsmall) lpattern("---")) ///
(line fit3 year if geo == "`g'", lcolor("255 190 93") lwidth(medthick)) ///
(scatter EFF_`var'_odex_1995 year if geo == "`g'", mcolor("255 190 93 %20") msize(medsmall) lpattern("---")), ///
xtitle("", size(medium)) ylabel(, labsize(medlarge)) ytitle("Index (base 1995)", size(medium)) xlabel(1995 1998 2001 2004 2007 2010 2013 2017, labsize(medlarge)) ///
yline(100, lcolor(black) lwidth(medium) lpattern("--")) xline(2007, lcolor(black) lwidth(medium) lpattern("--")) ///
plotregion(fcolor(white) lcolor(black)) graphregion(fcolor(white) ifcolor(white) color(white) icolor(white)) bgcolor(white) ///
leg(off)
drop fit*
graph export "$figurePath\Evo_`var'_`g'.pdf", as (pdf) replace
}
}
local geo `" "ES" "'
foreach g of local geo{
foreach var in TOT{
tssmooth ma fit1 = FEC_`var'_1995 if geo == "`g'", window(3)
tssmooth ma fit2 = EFF_`var'_app_1995 if geo == "`g'", window(3)
tssmooth ma fit3 = EFF_`var'_odex_1995 if geo == "`g'", window(3)
qui twoway (line fit1 year if geo == "`g'", lcolor("0 64 129") lwidth(medthick)) ///
(scatter FEC_`var'_1995 year if geo == "`g'", mcolor("0 64 129 %20") msize(medsmall)) ///
(line fit2 year if geo == "`g'", lcolor("163 41 56") lwidth(medthick)) ///
(scatter EFF_`var'_app_1995 year if geo == "`g'", mcolor("163 41 56 %20") msize(medsmall) lpattern("---")) ///
(line fit3 year if geo == "`g'", lcolor("255 190 93") lwidth(medthick)) ///
(scatter EFF_`var'_odex_1995 year if geo == "`g'", mcolor("255 190 93 %20") msize(medsmall) lpattern("---")), ///
xtitle("", size(medium)) ylabel(, labsize(medlarge)) ytitle("Index (base 1995)", size(medium)) xlabel(1995 1998 2001 2004 2007 2010 2013 2017, labsize(medlarge)) ///
yline(100, lcolor(black) lwidth(medium) lpattern("--")) xline(2007, lcolor(black) lwidth(medium) lpattern("--")) ///
plotregion(fcolor(white) lcolor(black)) graphregion(fcolor(white) ifcolor(white) color(white) icolor(white)) bgcolor(white) ///
legend(order(1 "End-Use Energy Consumption" 3 "Apparent End-Use Efficiency" 5 "Technical End-Use Efficiency") rows(3) region(lstyle(none)) size(medlarge) region(lwidth(none)))
drop fit*
graph export "$figurePath\Evo_`var'_`g'.pdf", as (pdf) replace
}
}
local geo `" "EU28" "'
foreach g of local geo{
foreach var in TOT{
tssmooth ma fit1 = FEC_`var'_1995 if geo == "`g'", window(3)
tssmooth ma fit2 = EFF_`var'_app_1995 if geo == "`g'", window(3)
tssmooth ma fit3 = EFF_`var'_odex_1995 if geo == "`g'", window(3)
qui twoway (line fit1 year if geo == "`g'", lcolor("0 64 129") lwidth(medthick)) ///
(scatter FEC_`var'_1995 year if geo == "`g'", mcolor("0 64 129 %20") msize(medsmall)) ///
(line fit2 year if geo == "`g'", lcolor("163 41 56") lwidth(medthick)) ///
(scatter EFF_`var'_app_1995 year if geo == "`g'", mcolor("163 41 56 %20") msize(medsmall) lpattern("---")) ///
(line fit3 year if geo == "`g'", lcolor("255 190 93") lwidth(medthick)) ///
(scatter EFF_`var'_odex_1995 year if geo == "`g'", mcolor("255 190 93 %20") msize(medsmall) lpattern("---")), ///
xtitle("", size(medium)) ylabel(, labsize(medlarge)) ytitle("Index (base 1995)", size(medium)) xlabel(1995 1998 2001 2004 2007 2010 2013 2017, labsize(medlarge)) ///
yline(100, lcolor(black) lwidth(medium) lpattern("--")) xline(2007, lcolor(black) lwidth(medium) lpattern("--")) ///
plotregion(fcolor(white) lcolor(black)) graphregion(fcolor(white) ifcolor(white) color(white) icolor(white)) bgcolor(white) ///
legend(order(1 "End-Use Energy Consumption" 3 "End-Use Energy Efficiency" 5 "Technical End-Use Efficiency") rows(3) region(lstyle(none)) size(medlarge) region(lwidth(none)))
drop fit*
graph export "$figurePath\Evo_`var'_`g'.pdf", as (pdf) replace
}
}
restore
// Keep relevant years and calculate first and last value
keep if year == 2007 | year == 2017
foreach var in TOT AGRI IND HH TRA ///
AGRI_AF AGRI_FISH IND_EEI IND_FBT IND_TL IND_WWP IND_PPP IND_CPC ///
IND_NMM IND_BM IND_MAC IND_TE IND_OI IND_CON CPS HH_SH HH_HW HH_COOK HH_AC ///
HH_LIGHT TRA_PASS_ROAD TRA_PASS_RAIL TRA_PASS_AVI TRA_FR_ROAD TRA_FR_RAIL TRA_FR_NAVI TRA_FR_PIPE{
gen FEC_`var'_proj_2007 = 1 + AC_FEC_`var'_1995
gen EFF_`var'_proj_2007 = 1 + AC_EFF_`var'_odex_1995
gen FEC_`var'_proj_2017 = 1 + AC_FEC_`var'_2007
gen EFF_`var'_proj_2017 = 1 + AC_EFF_`var'_odex_2007
}

********************************************************************************
// 6. Calculate rebound effect
********************************************************************************
// How to deal with ln(1)=0 - It makes this approach invalid
foreach var in TOT AGRI IND HH TRA ///
AGRI_AF AGRI_FISH IND_EEI IND_FBT IND_TL IND_WWP IND_PPP IND_CPC ///
IND_NMM IND_BM IND_MAC IND_TE IND_OI IND_CON CPS HH_SH HH_HW HH_COOK HH_AC ///
HH_LIGHT TRA_PASS_ROAD TRA_PASS_RAIL TRA_PASS_AVI TRA_FR_ROAD TRA_FR_RAIL TRA_FR_NAVI TRA_FR_PIPE{
gen RE_`var' = 1 + (ln(FEC_`var'_proj_2007)/ln(EFF_`var'_proj_2007)) if year == 2007
replace RE_`var' = 1 + (ln(FEC_`var'_proj_2017)/ln(EFF_`var'_proj_2017)) if year == 2017
}

keep year geo RE* FEC*Tot
export excel using "$tablePath\RE_table.xlsx", sheet("RE") sheetmodify firstrow(variables)



timer off 1
timer list 1
dis "Computing time of routine 1: " round(r(t1)/60, 0.1) " minutes"

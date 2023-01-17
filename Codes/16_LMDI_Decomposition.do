/*
Are We Moving Towards A Low-Carbon Energy-Efficient Economy?
A Decomposition of Energy-Related CO2 Emissions in Spain and EU28, 1995-2017
16. LMDI decomposition of energy-related CO2 emissions
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
global basePath "W:\AMICRO\Darío\Climate Change\Low Carbon Energy Efficiency"
global figurePath "$basePath\Figures"
global dataPath "$basePath\Data"
global codePath "$basePath\Codes"
global tablePath "$basePath\Tables"
global LaTeXPath "$basePath\Paper\Figures"

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
save "$dataPath\Intermediate_aux.dta", replace

********************************************************************************
// 3. LMDI Decomposition - Annual change (Total)
********************************************************************************
// 1 := change_tot 
// 2 := change_95_17
// 3 := change_95_07
// 4 := change_07_17

foreach change in 1 2 3 4{
foreach g in "ES" "EU28"{
use "$dataPath\Intermediate_aux.dta", clear
keep if geo == "`g'"
if `change' == 1{
	// Keep every year
}
if `change' == 2{
keep if year == 1995 | year == 2017
}
if `change' == 3{
keep if year == 1995 | year == 2007
}
if `change' == 4{
keep if year == 2007 | year == 2017
}
egen year_id = group(year)
xtset product_id year_id
// 3.1 Create logarithmic mean for LMDI decomposition by fuel
foreach var in AGRI_AF AGRI_FISH IND_EEI IND_FBT ///
IND_TL IND_WWP IND_PPP IND_CPC IND_NMM IND_BM IND_MAC ///
IND_TE IND_OI IND_CON CPS_SH CPS_HW CPS_COOK ///
CPS_AC CPS_LIGHT HH_SH HH_HW HH_COOK HH_AC HH_LIGHT ///
TRA_PASS_ROAD TRA_FR_ROAD TRA_PASS_RAIL ///
TRA_FR_RAIL TRA_PASS_AVI TRA_FR_NAVI TRA_FR_PIPE{
gen W_`var' = (CO2_`var' - L.CO2_`var')/(ln(CO2_`var') - ln(L.CO2_`var'))
replace W_`var' = 0 if W_`var' == .
label var W_`var' "Logarithmic mean for LMDI - `var'"
}
// 3.2 Primary carbon dioxide emission factor effect by fuel
gen aux = ln(KC/L.KC)
foreach var in AGRI_AF AGRI_FISH IND_EEI IND_FBT ///
IND_TL IND_WWP IND_PPP IND_CPC IND_NMM IND_BM IND_MAC ///
IND_TE IND_OI IND_CON CPS_SH CPS_HW CPS_COOK ///
CPS_AC CPS_LIGHT HH_SH HH_HW HH_COOK HH_AC HH_LIGHT ///
TRA_PASS_ROAD TRA_FR_ROAD TRA_PASS_RAIL ///
TRA_FR_RAIL TRA_PASS_AVI TRA_FR_NAVI TRA_FR_PIPE{
gen delta_emi_`var' = W_`var'*aux
label var delta_emi_`var' "Annual change - primary CO2 emission factor - `var'"
}
drop aux
// 3.3 Primary energy quantity convereted factor effect by fuel
gen aux = ln(KPEQ/L.KPEQ)
foreach var in AGRI_AF AGRI_FISH IND_EEI IND_FBT ///
IND_TL IND_WWP IND_PPP IND_CPC IND_NMM IND_BM IND_MAC ///
IND_TE IND_OI IND_CON CPS_SH CPS_HW CPS_COOK ///
CPS_AC CPS_LIGHT HH_SH HH_HW HH_COOK HH_AC HH_LIGHT ///
TRA_PASS_ROAD TRA_FR_ROAD TRA_PASS_RAIL ///
TRA_FR_RAIL TRA_PASS_AVI TRA_FR_NAVI TRA_FR_PIPE{
gen delta_peq_`var' = W_`var'*aux
label var delta_peq_`var' "Annual change - Primary energy quantity factor - `var'"
}
drop aux
// 3.4 Final energy mix effect
foreach var in AGRI_AF AGRI_FISH IND_EEI IND_FBT ///
IND_TL IND_WWP IND_PPP IND_CPC IND_NMM IND_BM IND_MAC ///
IND_TE IND_OI IND_CON CPS_SH CPS_HW CPS_COOK ///
CPS_AC CPS_LIGHT HH_SH HH_HW HH_COOK HH_AC HH_LIGHT ///
TRA_PASS_ROAD TRA_FR_ROAD TRA_PASS_RAIL ///
TRA_FR_RAIL TRA_PASS_AVI TRA_FR_NAVI TRA_FR_PIPE{
gen aux1 = FEC_`var'/FEC_`var'_Tot
gen aux2 = ln(aux1/L.aux1)
gen delta_mix_`var' = W_`var'*aux2
label var delta_mix_`var' "Annual change - Energy mix effect - `var'"
drop aux*
}
// 3.5 Weather/climate effect
gen aux1 = HDD/HDD_ref
gen aux2 = CDD/CDD_ref
foreach var in CPS_SH HH_SH{
gen aux3 = ln(aux1/L.aux1)
gen delta_cli_`var' = W_`var'*aux3
label var delta_cli_`var' "Annual change - Weather effect - `var'"
drop aux3
}
foreach var in CPS_AC HH_AC{
gen aux4 = ln(aux2/L.aux2)
gen delta_cli_`var' = W_`var'*aux4
label var delta_cli_`var' "Annual change - Weather effect - `var'"
drop aux4
}
foreach var in AGRI_AF AGRI_FISH IND_EEI IND_FBT ///
IND_TL IND_WWP IND_PPP IND_CPC IND_NMM IND_BM IND_MAC ///
IND_TE IND_OI IND_CON CPS_HW CPS_COOK CPS_LIGHT HH_HW HH_COOK HH_LIGHT ///
TRA_PASS_ROAD TRA_FR_ROAD TRA_PASS_RAIL ///
TRA_FR_RAIL TRA_PASS_AVI TRA_FR_NAVI TRA_FR_PIPE{
gen delta_cli_`var' = 0*ln(aux2/L.aux2)
label var delta_cli_`var' "Annual change - Weather effect - `var'"
}
drop aux*
// 3.6 Use in services effect
foreach var in CPS_SH CPS_HW CPS_COOK CPS_AC CPS_LIGHT{
gen aux1 = FEC_`var'_Tot/FEC_CPS_Tot
gen aux2 = ln(aux1/L.aux1)
gen delta_use_`var' = W_`var'*aux2
label var delta_use_`var' "Annual change - Use effect - `var'"
drop aux*
}
gen aux = 1
foreach var in AGRI_AF AGRI_FISH IND_EEI IND_FBT ///
IND_TL IND_WWP IND_PPP IND_CPC IND_NMM IND_BM IND_MAC ///
IND_TE IND_OI IND_CON HH_SH HH_HW HH_COOK HH_AC HH_LIGHT ///
TRA_PASS_ROAD TRA_FR_ROAD TRA_PASS_RAIL ///
TRA_FR_RAIL TRA_PASS_AVI TRA_FR_NAVI TRA_FR_PIPE{
gen delta_use_`var' = 0*ln(aux/L.aux)
label var delta_use_`var' "Annual change - Use effect - `var'"
}
drop aux
// 3.7 Energy efficiency effect
foreach var in AGRI_AF{
gen aux1 = FEC_`var'_Tot/AA
gen aux2 = ln(aux1/L.aux1)
gen delta_eff_`var' = W_`var'*aux2
label var delta_eff_`var' "Annual change - Energy efficiency effect - `var'"
drop aux*
}
foreach var in AGRI_FISH{
gen aux1 = FEC_`var'_Tot/FF
gen aux2 = ln(aux1/L.aux1)
gen delta_eff_`var' = W_`var'*aux2
label var delta_eff_`var' "Annual change - Energy efficiency effect - `var'"
drop aux*
}
foreach var in IND_EEI IND_FBT IND_TL IND_WWP IND_PPP IND_CPC IND_NMM IND_BM ///
IND_MAC IND_TE IND_OI IND_CON{
gen aux1 = FEC_`var'_Tot/PVI_`var'
gen aux2 = ln(aux1/L.aux1)
gen delta_eff_`var' = W_`var'*aux2
label var delta_eff_`var' "Annual change - Energy efficiency effect - `var'"
drop aux*
}
foreach var in CPS_SH CPS_HW CPS_COOK CPS_AC CPS_LIGHT{
gen aux1 = FEC_CPS_Tot/EMP_CPS
gen aux2 = ln(aux1/L.aux1)
gen delta_eff_`var' = W_`var'*aux2
label var delta_eff_`var' "Annual change - Energy efficiency effect - `var'"
drop aux*
}
foreach var in HH_SH{
gen aux1 = FEC_`var'_Tot/(AREA*DWE)
gen aux2 = ln(aux1/L.aux1)
gen delta_eff_`var' = W_`var'*aux2
label var delta_eff_`var' "Annual change - Energy efficiency effect - `var'"
drop aux*
}
foreach var in HH_HW HH_COOK HH_AC HH_LIGHT{
gen aux1 = FEC_`var'_Tot/DWE
gen aux2 = ln(aux1/L.aux1)
gen delta_eff_`var' = W_`var'*aux2
label var delta_eff_`var' "Annual change - Energy efficiency effect - `var'"
drop aux*
}
foreach var in ROAD RAIL AVI{
gen aux1 = FEC_TRA_PASS_`var'_Tot/PKM_`var'
gen aux2 = ln(aux1/L.aux1)
gen delta_eff_TRA_PASS_`var' = W_TRA_PASS_`var'*aux2
label var delta_eff_TRA_PASS_`var' "Annual change - Energy efficiency effect - `var'"
drop aux*
}
foreach var in ROAD RAIL NAVI PIPE{
gen aux1 = FEC_TRA_FR_`var'_Tot/TKM_`var'
gen aux2 = ln(aux1/L.aux1)
gen delta_eff_TRA_FR_`var' = W_TRA_FR_`var'*aux2
label var delta_eff_TRA_FR_`var' "Annual change - Energy efficiency effect - `var'"
drop aux*
}
// 3.8 Output relation to GVA
foreach var in AGRI_AF{
gen aux1 = AA/(GVA_`var'*PPP)
gen aux2 = ln(aux1/L.aux1)
gen delta_out_`var' = W_`var'*aux2
label var delta_out_`var' "Annual change - Output-GVA relation effect - `var'"
drop aux*
}
foreach var in AGRI_FISH{
gen aux1 = FF/(GVA_`var'*PPP)
gen aux2 = ln(aux1/L.aux1)
gen delta_out_`var' = W_`var'*aux2
label var delta_out_`var' "Annual change - Output-GVA relation effect - `var'"
drop aux*
}
foreach var in IND_EEI IND_FBT IND_TL IND_WWP IND_PPP IND_CPC IND_NMM IND_BM ///
IND_MAC IND_TE IND_OI IND_CON{
gen aux1 = PVI_`var'/(GVA_`var'*PPP)
gen aux2 = ln(aux1/L.aux1)
gen delta_out_`var' = W_`var'*aux2
label var delta_out_`var' "Annual change - Output-GVA relation effect - `var'"
drop aux*
}
foreach var in CPS_SH CPS_HW CPS_COOK CPS_AC CPS_LIGHT{
gen aux1 = EMP_CPS/(GVA_CPS*PPP)
gen aux2 = ln(aux1/L.aux1)
gen delta_out_`var' = W_`var'*aux2
label var delta_out_`var' "Annual change - Output-GVA relation effect - `var'"
drop aux*
}
gen aux = 1
foreach var in HH_SH HH_HW HH_COOK HH_AC HH_LIGHT ///
TRA_PASS_ROAD TRA_FR_ROAD TRA_PASS_RAIL ///
TRA_FR_RAIL TRA_PASS_AVI TRA_FR_NAVI TRA_FR_PIPE{
gen delta_out_`var' = 0*ln(aux/L.aux)
label var delta_out_`var' "Annual change - Output-GVA relation effect - `var'"
}
drop aux
// 3.9 Intra-structural effect
foreach var in AGRI_AF AGRI_FISH{
gen aux1 = (GVA_`var'*PPP)/(GVA_AGRI*PPP)
gen aux2 = ln(aux1/L.aux1)
gen delta_intr_`var' = W_`var'*aux2
label var delta_intr_`var' "Annual change - Intra-structural effect - `var'"
drop aux*
}
foreach var in IND_EEI IND_FBT IND_TL IND_WWP IND_PPP IND_CPC IND_NMM IND_BM ///
IND_MAC IND_TE IND_OI IND_CON{
gen aux1 = (GVA_`var'*PPP)/(GVA_IND*PPP)
gen aux2 = ln(aux1/L.aux1)
gen delta_intr_`var' = W_`var'*aux2
label var delta_intr_`var' "Annual change - Intra-structural effect - `var'"
drop aux*
}
gen aux = 1
foreach var in CPS_SH CPS_HW CPS_COOK CPS_AC CPS_LIGHT HH_SH HH_HW HH_COOK HH_AC ///
HH_LIGHT TRA_PASS_ROAD TRA_FR_ROAD TRA_PASS_RAIL TRA_FR_RAIL TRA_PASS_AVI ///
TRA_FR_NAVI TRA_FR_PIPE{
gen delta_intr_`var' = 0*ln(aux/L.aux)
label var delta_intr_`var' "Annual change - Intra-structural effect - `var'"
}
drop aux
// 3.10 Structural effect
foreach var in AGRI_AF AGRI_FISH{
gen aux1 = (GVA_AGRI*PPP)/(GVA_TOT*PPP)
gen aux2 = ln(aux1/L.aux1)
gen delta_str_`var' = W_`var'*aux2
label var delta_str_`var' "Annual change - Structural effect - `var'"
drop aux*
}
foreach var in IND_EEI IND_FBT IND_TL IND_WWP IND_PPP IND_CPC IND_NMM IND_BM ///
IND_MAC IND_TE IND_OI IND_CON{
gen aux1 = (GVA_IND*PPP)/(GVA_TOT*PPP)
gen aux2 = ln(aux1/L.aux1)
gen delta_str_`var' = W_`var'*aux2
label var delta_str_`var' "Annual change - Structural effect - `var'"
drop aux*
}
foreach var in CPS_SH CPS_HW CPS_COOK CPS_AC CPS_LIGHT{
gen aux1 = (GVA_CPS*PPP)/(GVA_TOT*PPP)
gen aux2 = ln(aux1/L.aux1)
gen delta_str_`var' = W_`var'*aux2
label var delta_str_`var' "Annual change - Structural effect - `var'"
drop aux*
}
foreach var in ROAD RAIL AVI{
gen aux1 = PKM_`var'/PKM
gen aux2 = ln(aux1/L.aux1)
gen delta_str_TRA_PASS_`var' = W_TRA_PASS_`var'*aux2
label var delta_str_TRA_PASS_`var' "Annual change - Structural effect - `var'"
drop aux*
}
foreach var in ROAD RAIL NAVI PIPE{
gen aux1 = TKM_`var'/TKM
gen aux2 = ln(aux1/L.aux1)
gen delta_str_TRA_FR_`var' = W_TRA_FR_`var'*aux2
label var delta_str_TRA_FR_`var' "Annual change - Structural effect - `var'"
drop aux*
}
gen aux = 1
foreach var in HH_SH HH_HW HH_COOK HH_AC HH_LIGHT{
gen delta_str_`var' = 0*ln(aux/L.aux)
label var delta_str_`var' "Annual change - Structural effect - `var'"
}
drop aux
// 3.11 Comfort effect
foreach var in HH_SH{
gen aux1 = (AREA*DWE)/DWE
gen aux2 = ln(aux1/L.aux1)
gen delta_com_`var' = W_`var'*aux2
label var delta_com_`var' "Annual change - Comfort effect - `var'"
drop aux*
}
gen aux = 1
foreach var in AGRI_AF AGRI_FISH IND_EEI IND_FBT IND_TL IND_WWP IND_PPP IND_CPC ///
IND_NMM IND_BM IND_MAC IND_TE IND_OI IND_CON CPS_SH CPS_HW CPS_COOK CPS_AC ///
CPS_LIGHT HH_HW HH_COOK HH_AC HH_LIGHT TRA_PASS_ROAD TRA_FR_ROAD TRA_PASS_RAIL ///
TRA_FR_RAIL TRA_PASS_AVI TRA_FR_NAVI TRA_FR_PIPE{
gen delta_com_`var' = 0*ln(aux/L.aux)
label var delta_com_`var' "Annual change - Comfort effect - `var'"
}
drop aux
// 3.12 Social factors effect
foreach var in HH_SH HH_HW HH_COOK HH_AC HH_LIGHT{
gen aux1 = DWE/POP
gen aux2 = ln(aux1/L.aux1)
gen delta_soc_`var' = W_`var'*aux2
label var delta_soc_`var' "Annual change - Social factors effect - `var'"
drop aux*
}
foreach var in ROAD RAIL AVI{
gen aux1 = PKM/POP
gen aux2 = ln(aux1/L.aux1)
gen delta_soc_TRA_PASS_`var' = W_TRA_PASS_`var'*aux2
label var delta_soc_TRA_PASS_`var' "Annual change - Social factors effect - `var'"
drop aux*
}
foreach var in ROAD RAIL NAVI PIPE{
gen aux1 = TKM/POP
gen aux2 = ln(aux1/L.aux1)
gen delta_soc_TRA_FR_`var' = W_TRA_FR_`var'*aux2
label var delta_soc_TRA_FR_`var' "Annual change - Social factors effect - `var'"
drop aux*
}
gen aux = 1
foreach var in AGRI_AF AGRI_FISH IND_EEI IND_FBT IND_TL IND_WWP IND_PPP IND_CPC ///
IND_NMM IND_BM IND_MAC IND_TE IND_OI IND_CON CPS_SH CPS_HW CPS_COOK CPS_AC CPS_LIGHT{
gen delta_soc_`var' = 0*ln(aux/L.aux)
label var delta_soc_`var' "Annual change - Social factors effect - `var'"
}
drop aux
// 3.13 Income-per-capita effect
foreach var in AGRI_AF AGRI_FISH IND_EEI IND_FBT IND_TL IND_WWP IND_PPP IND_CPC ///
IND_NMM IND_BM IND_MAC IND_TE IND_OI IND_CON CPS_SH CPS_HW CPS_COOK CPS_AC CPS_LIGHT{
gen aux1 = (GVA_TOT*PPP)/POP
gen aux2 = ln(aux1/L.aux1)
gen delta_inc_`var' = W_`var'*aux2
label var delta_inc_`var' "Annual change - Income-per-capita effect - `var'"
drop aux*
}
gen aux = 1
foreach var in HH_SH HH_HW HH_COOK HH_AC HH_LIGHT TRA_PASS_ROAD TRA_FR_ROAD TRA_PASS_RAIL ///
TRA_FR_RAIL TRA_PASS_AVI TRA_FR_NAVI TRA_FR_PIPE{
gen delta_inc_`var' = 0*ln(aux/L.aux)
label var delta_inc_`var' "Annual change - Income-per-capita effect - `var'"
}
drop aux
// 3.14 Population effect
foreach var in AGRI_AF AGRI_FISH IND_EEI IND_FBT IND_TL IND_WWP IND_PPP IND_CPC ///
IND_NMM IND_BM IND_MAC IND_TE IND_OI IND_CON CPS_SH CPS_HW CPS_COOK CPS_AC ///
CPS_LIGHT HH_SH HH_HW HH_COOK HH_AC HH_LIGHT TRA_PASS_ROAD TRA_FR_ROAD TRA_PASS_RAIL ///
TRA_FR_RAIL TRA_PASS_AVI TRA_FR_NAVI TRA_FR_PIPE{
gen aux1 = POP
gen aux2 = ln(aux1/L.aux1)
gen delta_pop_`var' = W_`var'*aux2
label var delta_pop_`var' "Annual change - Population effect - `var'"
drop aux*
}
// 3.15 Summation over fuels
foreach var in AGRI_AF AGRI_FISH IND_EEI IND_FBT IND_TL IND_WWP IND_PPP IND_CPC ///
IND_NMM IND_BM IND_MAC IND_TE IND_OI IND_CON CPS_SH CPS_HW CPS_COOK CPS_AC ///
CPS_LIGHT HH_SH HH_HW HH_COOK HH_AC HH_LIGHT TRA_PASS_ROAD TRA_FR_ROAD TRA_PASS_RAIL ///
TRA_FR_RAIL TRA_PASS_AVI TRA_FR_NAVI TRA_FR_PIPE{
foreach f in pop inc soc com str intr out eff use cli mix peq emi{
bysort year: egen delta_`f'_`var'_Tot = total(delta_`f'_`var')
}
}
duplicates drop year, force
// 3.16 Generate decomposition table per subsector/end-use
tset year_id
foreach var in AGRI_AF AGRI_FISH IND_EEI IND_FBT IND_TL IND_WWP IND_PPP IND_CPC ///
IND_NMM IND_BM IND_MAC IND_TE IND_OI IND_CON CPS_SH CPS_HW CPS_COOK CPS_AC ///
CPS_LIGHT HH_SH HH_HW HH_COOK HH_AC HH_LIGHT TRA_PASS_ROAD TRA_FR_ROAD TRA_PASS_RAIL ///
TRA_FR_RAIL TRA_PASS_AVI TRA_FR_NAVI TRA_FR_PIPE{
preserve
foreach f in pop inc soc com str intr out eff use cli mix peq emi{
gen delta_`f' = delta_`f'_`var'_Tot
}
gen delta_CO2_actual = CO2_`var'_Tot - L.CO2_`var'_Tot
label var delta_CO2_actual "Annual change in CO2 - Actual"
gen delta_CO2_decomp = 0
label var delta_CO2_decomp "Annual change in CO2 - Decomposition"
foreach f in pop inc soc com str intr out eff use cli mix peq emi{
replace delta_CO2_decomp = delta_CO2_decomp + delta_`f'
}
gen diff = (delta_CO2_actual - delta_CO2_decomp)/delta_CO2_actual
label var diff "Difference between actual and decomposition annual change in CO2"
label var delta_pop "Annual change from population"
label var delta_inc "Annual change from income-per-capita"
label var delta_soc "Annual change from social factors"
label var delta_com "Annual change from comfort"
label var delta_str "Annual change from structural effects"
label var delta_intr "Annual change from intra-structural effects"
label var delta_out "Annual change from structural change in energy intensity"
label var delta_eff "Annual change from energy efficiency"
label var delta_use "Annual change from changes in energy uses in services"
label var delta_cli "Annual change from weather effects"
label var delta_mix "Annual change from final energy consumption mix"
label var delta_peq "Annual change from primary energy requirements"
label var delta_emi "Annual change from primary CO2 emmision factor"
// Save intermediate dataset
gen sector = "`var'"
keep year geo sector delta_CO2_actual delta_CO2_decomp delta_pop delta_inc delta_soc ///
delta_com delta_str delta_intr delta_out delta_eff delta_use delta_cli delta_mix ///
delta_peq delta_emi diff
order year geo sector delta_CO2_actual delta_CO2_decomp delta_pop delta_inc delta_soc ///
delta_com delta_str delta_intr delta_out delta_eff delta_use delta_cli delta_mix ///
delta_peq delta_emi diff
save "$dataPath\Intermediate_`var'.dta",replace
restore
}
// 3.17 Summation over sectors to generate totals per sector and absolute total
// 3.17.1 Agriculture
preserve
foreach f in pop inc soc com str intr out eff use cli mix peq emi{
gen delta_`f' = 0
foreach var in AGRI_AF AGRI_FISH{
replace delta_`f' = delta_`f' + delta_`f'_`var'_Tot
}
}
label var delta_pop "Annual change from population"
label var delta_inc "Annual change from income-per-capita"
label var delta_soc "Annual change from social factors"
label var delta_com "Annual change from comfort"
label var delta_str "Annual change from structural effects"
label var delta_intr "Annual change from intra-structural effects"
label var delta_out "Annual change from structural change in energy intensity"
label var delta_eff "Annual change from energy efficiency"
label var delta_use "Annual change from changes in energy uses in services"
label var delta_cli "Annual change from weather effects"
label var delta_mix "Annual change from final energy consumption mix"
label var delta_peq "Annual change from primary energy requirements"
label var delta_emi "Annual change from primary CO2 emmision factor"
gen delta_CO2_actual = CO2_AGRI_Tot - L.CO2_AGRI_Tot
label var delta_CO2_actual "Annual change in CO2 - Actual"
gen delta_CO2_decomp = 0
foreach f in pop inc soc com str intr out eff use cli mix peq emi{
replace delta_CO2_decomp = delta_CO2_decomp + delta_`f'
}
label var delta_CO2_decomp "Annual change in CO2 - Decomposition"
gen diff = (delta_CO2_actual - delta_CO2_decomp)/delta_CO2_actual
label var diff "Difference between actual and decomposition annual change in CO2"
// Save intermediate dataset
gen sector = "AGRI"
keep year geo sector delta_CO2_actual delta_CO2_decomp delta_pop delta_inc delta_soc ///
delta_com delta_str delta_intr delta_out delta_eff delta_use delta_cli delta_mix ///
delta_peq delta_emi diff
order year geo sector delta_CO2_actual delta_CO2_decomp delta_pop delta_inc delta_soc ///
delta_com delta_str delta_intr delta_out delta_eff delta_use delta_cli delta_mix ///
delta_peq delta_emi diff
save "$dataPath\Intermediate_AGRI.dta",replace
restore
// 3.17.2 Industry
preserve
foreach f in pop inc soc com str intr out eff use cli mix peq emi{
gen delta_`f' = 0
foreach var in IND_EEI IND_FBT IND_TL IND_WWP IND_PPP IND_CPC ///
IND_NMM IND_BM IND_MAC IND_TE IND_OI IND_CON{
replace delta_`f' = delta_`f' + delta_`f'_`var'_Tot
}
}
label var delta_pop "Annual change from population"
label var delta_inc "Annual change from income-per-capita"
label var delta_soc "Annual change from social factors"
label var delta_com "Annual change from comfort"
label var delta_str "Annual change from structural effects"
label var delta_intr "Annual change from intra-structural effects"
label var delta_out "Annual change from structural change in energy intensity"
label var delta_eff "Annual change from energy efficiency"
label var delta_use "Annual change from changes in energy uses in services"
label var delta_cli "Annual change from weather effects"
label var delta_mix "Annual change from final energy consumption mix"
label var delta_peq "Annual change from primary energy requirements"
label var delta_emi "Annual change from primary CO2 emmision factor"
gen delta_CO2_actual = CO2_IND_Tot - L.CO2_IND_Tot
label var delta_CO2_actual "Annual change in CO2 - Actual"
gen delta_CO2_decomp = 0
foreach f in pop inc soc com str intr out eff use cli mix peq emi{
replace delta_CO2_decomp = delta_CO2_decomp + delta_`f'
}
label var delta_CO2_decomp "Annual change in CO2 - Decomposition"
gen diff = (delta_CO2_actual - delta_CO2_decomp)/delta_CO2_actual
label var diff "Difference between actual and decomposition annual change in CO2"
// Save intermediate dataset
gen sector = "IND"
keep year geo sector delta_CO2_actual delta_CO2_decomp delta_pop delta_inc delta_soc ///
delta_com delta_str delta_intr delta_out delta_eff delta_use delta_cli delta_mix ///
delta_peq delta_emi diff
order year geo sector delta_CO2_actual delta_CO2_decomp delta_pop delta_inc delta_soc ///
delta_com delta_str delta_intr delta_out delta_eff delta_use delta_cli delta_mix ///
delta_peq delta_emi diff
save "$dataPath\Intermediate_IND.dta",replace
restore
// 3.17.3 Commercial & public services
preserve
foreach f in pop inc soc com str intr out eff use cli mix peq emi{
gen delta_`f' = 0
foreach var in CPS_SH CPS_HW CPS_COOK CPS_AC CPS_LIGHT{
replace delta_`f' = delta_`f' + delta_`f'_`var'_Tot
}
}
label var delta_pop "Annual change from population"
label var delta_inc "Annual change from income-per-capita"
label var delta_soc "Annual change from social factors"
label var delta_com "Annual change from comfort"
label var delta_str "Annual change from structural effects"
label var delta_intr "Annual change from intra-structural effects"
label var delta_out "Annual change from structural change in energy intensity"
label var delta_eff "Annual change from energy efficiency"
label var delta_use "Annual change from changes in energy uses in services"
label var delta_cli "Annual change from weather effects"
label var delta_mix "Annual change from final energy consumption mix"
label var delta_peq "Annual change from primary energy requirements"
label var delta_emi "Annual change from primary CO2 emmision factor"
gen delta_CO2_actual = CO2_CPS_Tot - L.CO2_CPS_Tot
label var delta_CO2_actual "Annual change in CO2 - Actual"
gen delta_CO2_decomp = 0
foreach f in pop inc soc com str intr out eff use cli mix peq emi{
replace delta_CO2_decomp = delta_CO2_decomp + delta_`f'
}
label var delta_CO2_decomp "Annual change in CO2 - Decomposition"
gen diff = (delta_CO2_actual - delta_CO2_decomp)/delta_CO2_actual
label var diff "Difference between actual and decomposition annual change in CO2"
// Save intermediate dataset
gen sector = "CPS"
keep year geo sector delta_CO2_actual delta_CO2_decomp delta_pop delta_inc delta_soc ///
delta_com delta_str delta_intr delta_out delta_eff delta_use delta_cli delta_mix ///
delta_peq delta_emi diff
order year geo sector delta_CO2_actual delta_CO2_decomp delta_pop delta_inc delta_soc ///
delta_com delta_str delta_intr delta_out delta_eff delta_use delta_cli delta_mix ///
delta_peq delta_emi diff
save "$dataPath\Intermediate_CPS.dta",replace
restore
// 3.17.4 Economic/Business sectors
preserve
foreach f in pop inc soc com str intr out eff use cli mix peq emi{
gen delta_`f' = 0
foreach var in AGRI_AF AGRI_FISH IND_EEI IND_FBT IND_TL IND_WWP IND_PPP IND_CPC ///
IND_NMM IND_BM IND_MAC IND_TE IND_OI IND_CON CPS_SH CPS_HW CPS_COOK CPS_AC CPS_LIGHT{
replace delta_`f' = delta_`f' + delta_`f'_`var'_Tot
}
}
label var delta_pop "Annual change from population"
label var delta_inc "Annual change from income-per-capita"
label var delta_soc "Annual change from social factors"
label var delta_com "Annual change from comfort"
label var delta_str "Annual change from structural effects"
label var delta_intr "Annual change from intra-structural effects"
label var delta_out "Annual change from structural change in energy intensity"
label var delta_eff "Annual change from energy efficiency"
label var delta_use "Annual change from changes in energy uses in services"
label var delta_cli "Annual change from weather effects"
label var delta_mix "Annual change from final energy consumption mix"
label var delta_peq "Annual change from primary energy requirements"
label var delta_emi "Annual change from primary CO2 emmision factor"
gen delta_CO2_actual = CO2_ECO_Tot - L.CO2_ECO_Tot
label var delta_CO2_actual "Annual change in CO2 - Actual"
gen delta_CO2_decomp = 0
foreach f in pop inc soc com str intr out eff use cli mix peq emi{
replace delta_CO2_decomp = delta_CO2_decomp + delta_`f'
}
label var delta_CO2_decomp "Annual change in CO2 - Decomposition"
gen diff = (delta_CO2_actual - delta_CO2_decomp)/delta_CO2_actual
label var diff "Difference between actual and decomposition annual change in CO2"
// Save intermediate dataset
gen sector = "ECO"
keep year geo sector delta_CO2_actual delta_CO2_decomp delta_pop delta_inc delta_soc ///
delta_com delta_str delta_intr delta_out delta_eff delta_use delta_cli delta_mix ///
delta_peq delta_emi diff
order year geo sector delta_CO2_actual delta_CO2_decomp delta_pop delta_inc delta_soc ///
delta_com delta_str delta_intr delta_out delta_eff delta_use delta_cli delta_mix ///
delta_peq delta_emi diff
save "$dataPath\Intermediate_ECO.dta",replace
restore
// 3.17.5 Households
preserve
foreach f in pop inc soc com str intr out eff use cli mix peq emi{
gen delta_`f' = 0
foreach var in HH_SH HH_HW HH_COOK HH_AC HH_LIGHT{
replace delta_`f' = delta_`f' + delta_`f'_`var'_Tot
}
}
label var delta_pop "Annual change from population"
label var delta_inc "Annual change from income-per-capita"
label var delta_soc "Annual change from social factors"
label var delta_com "Annual change from comfort"
label var delta_str "Annual change from structural effects"
label var delta_intr "Annual change from intra-structural effects"
label var delta_out "Annual change from structural change in energy intensity"
label var delta_eff "Annual change from energy efficiency"
label var delta_use "Annual change from changes in energy uses in services"
label var delta_cli "Annual change from weather effects"
label var delta_mix "Annual change from final energy consumption mix"
label var delta_peq "Annual change from primary energy requirements"
label var delta_emi "Annual change from primary CO2 emmision factor"
gen delta_CO2_actual = CO2_HH_Tot - L.CO2_HH_Tot
label var delta_CO2_actual "Annual change in CO2 - Actual"
gen delta_CO2_decomp = 0
foreach f in pop inc soc com str intr out eff use cli mix peq emi{
replace delta_CO2_decomp = delta_CO2_decomp + delta_`f'
}
label var delta_CO2_decomp "Annual change in CO2 - Decomposition"
gen diff = (delta_CO2_actual - delta_CO2_decomp)/delta_CO2_actual
label var diff "Difference between actual and decomposition annual change in CO2"
// Save intermediate dataset
gen sector = "HH"
keep year geo sector delta_CO2_actual delta_CO2_decomp delta_pop delta_inc delta_soc ///
delta_com delta_str delta_intr delta_out delta_eff delta_use delta_cli delta_mix ///
delta_peq delta_emi diff
order year geo sector delta_CO2_actual delta_CO2_decomp delta_pop delta_inc delta_soc ///
delta_com delta_str delta_intr delta_out delta_eff delta_use delta_cli delta_mix ///
delta_peq delta_emi diff
save "$dataPath\Intermediate_HH.dta",replace
restore
// 3.17.6 Passenger transport
preserve
foreach f in pop inc soc com str intr out eff use cli mix peq emi{
gen delta_`f' = 0
foreach var in TRA_PASS_ROAD TRA_PASS_RAIL TRA_PASS_AVI{
replace delta_`f' = delta_`f' + delta_`f'_`var'_Tot
}
}
label var delta_pop "Annual change from population"
label var delta_inc "Annual change from income-per-capita"
label var delta_soc "Annual change from social factors"
label var delta_com "Annual change from comfort"
label var delta_str "Annual change from structural effects"
label var delta_intr "Annual change from intra-structural effects"
label var delta_out "Annual change from structural change in energy intensity"
label var delta_eff "Annual change from energy efficiency"
label var delta_use "Annual change from changes in energy uses in services"
label var delta_cli "Annual change from weather effects"
label var delta_mix "Annual change from final energy consumption mix"
label var delta_peq "Annual change from primary energy requirements"
label var delta_emi "Annual change from primary CO2 emmision factor"
gen delta_CO2_actual = CO2_TRA_PASS_Tot - L.CO2_TRA_PASS_Tot
label var delta_CO2_actual "Annual change in CO2 - Actual"
gen delta_CO2_decomp = 0
foreach f in pop inc soc com str intr out eff use cli mix peq emi{
replace delta_CO2_decomp = delta_CO2_decomp + delta_`f'
}
label var delta_CO2_decomp "Annual change in CO2 - Decomposition"
gen diff = (delta_CO2_actual - delta_CO2_decomp)/delta_CO2_actual
label var diff "Difference between actual and decomposition annual change in CO2"
// Save intermediate dataset
gen sector = "TRA_PASS"
keep year geo sector delta_CO2_actual delta_CO2_decomp delta_pop delta_inc delta_soc ///
delta_com delta_str delta_intr delta_out delta_eff delta_use delta_cli delta_mix ///
delta_peq delta_emi diff
order year geo sector delta_CO2_actual delta_CO2_decomp delta_pop delta_inc delta_soc ///
delta_com delta_str delta_intr delta_out delta_eff delta_use delta_cli delta_mix ///
delta_peq delta_emi diff
save "$dataPath\Intermediate_TRA_PASS.dta",replace
restore
// 3.17.7 Freight transport
preserve
foreach f in pop inc soc com str intr out eff use cli mix peq emi{
gen delta_`f' = 0
foreach var in TRA_FR_ROAD TRA_FR_RAIL TRA_FR_NAVI TRA_FR_PIPE{
replace delta_`f' = delta_`f' + delta_`f'_`var'_Tot
}
}
label var delta_pop "Annual change from population"
label var delta_inc "Annual change from income-per-capita"
label var delta_soc "Annual change from social factors"
label var delta_com "Annual change from comfort"
label var delta_str "Annual change from structural effects"
label var delta_intr "Annual change from intra-structural effects"
label var delta_out "Annual change from structural change in energy intensity"
label var delta_eff "Annual change from energy efficiency"
label var delta_use "Annual change from changes in energy uses in services"
label var delta_cli "Annual change from weather effects"
label var delta_mix "Annual change from final energy consumption mix"
label var delta_peq "Annual change from primary energy requirements"
label var delta_emi "Annual change from primary CO2 emmision factor"
gen delta_CO2_actual = CO2_TRA_FR_Tot - L.CO2_TRA_FR_Tot
label var delta_CO2_actual "Annual change in CO2 - Actual"
gen delta_CO2_decomp = 0
foreach f in pop inc soc com str intr out eff use cli mix peq emi{
replace delta_CO2_decomp = delta_CO2_decomp + delta_`f'
}
label var delta_CO2_decomp "Annual change in CO2 - Decomposition"
gen diff = (delta_CO2_actual - delta_CO2_decomp)/delta_CO2_actual
label var diff "Difference between actual and decomposition annual change in CO2"
// Save intermediate dataset
gen sector = "TRA_FR"
keep year geo sector delta_CO2_actual delta_CO2_decomp delta_pop delta_inc delta_soc ///
delta_com delta_str delta_intr delta_out delta_eff delta_use delta_cli delta_mix ///
delta_peq delta_emi diff
order year geo sector delta_CO2_actual delta_CO2_decomp delta_pop delta_inc delta_soc ///
delta_com delta_str delta_intr delta_out delta_eff delta_use delta_cli delta_mix ///
delta_peq delta_emi diff
save "$dataPath\Intermediate_TRA_FR.dta",replace
restore
// 3.17.8 Transport
preserve
foreach f in pop inc soc com str intr out eff use cli mix peq emi{
gen delta_`f' = 0
foreach var in TRA_PASS_ROAD TRA_FR_ROAD TRA_PASS_RAIL ///
TRA_FR_RAIL TRA_PASS_AVI TRA_FR_NAVI TRA_FR_PIPE{
replace delta_`f' = delta_`f' + delta_`f'_`var'_Tot
}
}
label var delta_pop "Annual change from population"
label var delta_inc "Annual change from income-per-capita"
label var delta_soc "Annual change from social factors"
label var delta_com "Annual change from comfort"
label var delta_str "Annual change from structural effects"
label var delta_intr "Annual change from intra-structural effects"
label var delta_out "Annual change from structural change in energy intensity"
label var delta_eff "Annual change from energy efficiency"
label var delta_use "Annual change from changes in energy uses in services"
label var delta_cli "Annual change from weather effects"
label var delta_mix "Annual change from final energy consumption mix"
label var delta_peq "Annual change from primary energy requirements"
label var delta_emi "Annual change from primary CO2 emmision factor"
gen delta_CO2_actual = CO2_TRA_Tot - L.CO2_TRA_Tot
label var delta_CO2_actual "Annual change in CO2 - Actual"
gen delta_CO2_decomp = 0
foreach f in pop inc soc com str intr out eff use cli mix peq emi{
replace delta_CO2_decomp = delta_CO2_decomp + delta_`f'
}
label var delta_CO2_decomp "Annual change in CO2 - Decomposition"
gen diff = (delta_CO2_actual - delta_CO2_decomp)/delta_CO2_actual
label var diff "Difference between actual and decomposition annual change in CO2"
// Save intermediate dataset
gen sector = "TRA"
keep year geo sector delta_CO2_actual delta_CO2_decomp delta_pop delta_inc delta_soc ///
delta_com delta_str delta_intr delta_out delta_eff delta_use delta_cli delta_mix ///
delta_peq delta_emi diff
order year geo sector delta_CO2_actual delta_CO2_decomp delta_pop delta_inc delta_soc ///
delta_com delta_str delta_intr delta_out delta_eff delta_use delta_cli delta_mix ///
delta_peq delta_emi diff
save "$dataPath\Intermediate_TRA.dta",replace
restore
// 3.17.9 Total
preserve
foreach f in pop inc soc com str intr out eff use cli mix peq emi{
gen delta_`f' = 0
foreach var in AGRI_AF AGRI_FISH IND_EEI IND_FBT IND_TL IND_WWP IND_PPP IND_CPC ///
IND_NMM IND_BM IND_MAC IND_TE IND_OI IND_CON CPS_SH CPS_HW CPS_COOK CPS_AC ///
CPS_LIGHT HH_SH HH_HW HH_COOK HH_AC HH_LIGHT TRA_PASS_ROAD TRA_FR_ROAD TRA_PASS_RAIL ///
TRA_FR_RAIL TRA_PASS_AVI TRA_FR_NAVI TRA_FR_PIPE{
replace delta_`f' = delta_`f' + delta_`f'_`var'_Tot
}
}
label var delta_pop "Annual change from population"
label var delta_inc "Annual change from income-per-capita"
label var delta_soc "Annual change from social factors"
label var delta_com "Annual change from comfort"
label var delta_str "Annual change from structural effects"
label var delta_intr "Annual change from intra-structural effects"
label var delta_out "Annual change from structural change in energy intensity"
label var delta_eff "Annual change from energy efficiency"
label var delta_use "Annual change from changes in energy uses in services"
label var delta_cli "Annual change from weather effects"
label var delta_mix "Annual change from final energy consumption mix"
label var delta_peq "Annual change from primary energy requirements"
label var delta_emi "Annual change from primary CO2 emmision factor"
gen delta_CO2_actual = CO2_TOT_Tot - L.CO2_TOT_Tot
label var delta_CO2_actual "Annual change in CO2 - Actual"
gen delta_CO2_decomp = 0
foreach f in pop inc soc com str intr out eff use cli mix peq emi{
replace delta_CO2_decomp = delta_CO2_decomp + delta_`f'
}
label var delta_CO2_decomp "Annual change in CO2 - Decomposition"
gen diff = (delta_CO2_actual - delta_CO2_decomp)/delta_CO2_actual
label var diff "Difference between actual and decomposition annual change in CO2"
// Save intermediate dataset
gen sector = "TOT"
keep year geo sector delta_CO2_actual delta_CO2_decomp delta_pop delta_inc delta_soc ///
delta_com delta_str delta_intr delta_out delta_eff delta_use delta_cli delta_mix ///
delta_peq delta_emi diff
order year geo sector delta_CO2_actual delta_CO2_decomp delta_pop delta_inc delta_soc ///
delta_com delta_str delta_intr delta_out delta_eff delta_use delta_cli delta_mix ///
delta_peq delta_emi diff
save "$dataPath\Intermediate_TOT.dta",replace
restore
// 3.18 Append all tables to create general LMDI decomposition table by region
use "$dataPath\Intermediate_TOT.dta", clear
erase "$dataPath\Intermediate_TOT.dta"
foreach var in ECO AGRI AGRI_AF AGRI_FISH IND IND_EEI IND_FBT IND_TL IND_WWP IND_PPP IND_CPC ///
IND_NMM IND_BM IND_MAC IND_TE IND_OI IND_CON CPS CPS_SH CPS_HW CPS_COOK CPS_AC ///
CPS_LIGHT HH HH_SH HH_HW HH_COOK HH_AC HH_LIGHT TRA TRA_PASS TRA_PASS_ROAD TRA_PASS_RAIL ///
TRA_PASS_AVI TRA_FR TRA_FR_ROAD  TRA_FR_RAIL TRA_FR_NAVI TRA_FR_PIPE{
append using "$dataPath\Intermediate_`var'.dta"
erase "$dataPath\Intermediate_`var'.dta"
}
// 3.19 Save dataset of the region
save "$dataPath\Intermediate_`g'.dta", replace
}
// 3.20 Append all tables to create general LMDI decomposition table with every region
use  "$dataPath\Intermediate_ES.dta", clear
append using "$dataPath\Intermediate_EU28.dta"
erase "$dataPath\Intermediate_ES.dta"
erase "$dataPath\Intermediate_EU28.dta"

// 3.21 Save table in Excel
if `change' == 1{
drop if year == 1995
export excel using "$tablePath\CO2_decomp.xlsx", sheet("Total") sheetmodify firstrow(variables)
}
if `change' == 2{
drop if year == 1995
export excel using "$tablePath\CO2_decomp.xlsx", sheet("95-17") sheetmodify firstrow(variables)
}
if `change' == 3{
drop if year == 1995
export excel using "$tablePath\CO2_decomp.xlsx", sheet("95-07") sheetmodify firstrow(variables)
}
if `change' == 4{
drop if year == 2007
export excel using "$tablePath\CO2_decomp.xlsx", sheet("07-17") sheetmodify firstrow(variables)
}
}
erase "$dataPath\Intermediate_aux.dta"

timer off 1
timer list 1
dis "Computing time of routine 1: " round(r(t1)/60, 0.1) " minutes"

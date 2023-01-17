/*
Are We Moving Towards A Low-Carbon Energy-Efficient Economy?
A Decomposition of Energy-Related CO2 Emissions in Spain and EU28, 1995-2017
14. Input-Output - Leontief Inverse from Eurostat Energy Balances
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
// 1. Import Energy Balances
********************************************************************************
use "$dataPath\Energy_Balances_Eurostat_IPCC_Emission_Factor.dta", clear
// Keep just relevant variables
drop if product_group_code == .
drop if year > 2017
// Drop aggregations and other variables not needed
drop NRGSUP GIC GAE GIC20202030 PEC20202030 NRG_EHG_E NRG_CM_E NRG_OIL_NG_E ///
NRG_PF_E NRG_CO_E NRG_BKBPB_E NRG_GW_E NRG_BF_E NRG_PR_E NRG_NI_E NRG_CL_E ///
NRG_LNG_E NRG_BIOG_E NRG_GTL_E NRG_CPP_E NRG_NSP_E AFC FEC20202030 NRG_NE ///
FC_IND_NE FC_TRA_NE FC_OTH_NE FC_IND_E FC_IND_IS_E FC_IND_CPC_E FC_IND_NFM_E ///
FC_IND_NMM_E FC_IND_TE_E FC_IND_MAC_E FC_IND_MQ_E FC_IND_FBT_E FC_IND_PPP_E ///
FC_IND_WP_E FC_IND_CON_E FC_IND_TL_E FC_IND_NSP_E FC_TRA_E FC_TRA_RAIL_E ///
FC_TRA_ROAD_E FC_TRA_DAVI_E FC_TRA_DNAVI_E FC_TRA_PIPE_E FC_TRA_NSP_E FC_OTH_E ///
FC_OTH_CP_E FC_OTH_HH_E FC_OTH_AF_E FC_OTH_FISH_E FC_OTH_NSP_E GEP GEP_MAPE ///
GEP_MAPCHP GEP_APE GEP_APCHP GHP GHP_MAPCHP GHP_MAPH GHP_APCHP GHP_APH ///
TI_NE TI_NRG_FC_IND_NE TI_EHG_E TO_EHG TI_RPI_E TO_RPI
// Replace missing values with zeros
foreach var in PPRD RCV_RCY IMP EXP STK_CHG INTMARB INTAVI TI_E TI_EHG_MAPE_E ///
TI_EHG_MAPCHP_E TI_EHG_MAPH_E TI_EHG_APE_E TI_EHG_APCHP_E TI_EHG_APH_E TI_EHG_EDHP ///
TI_EHG_EB TI_EHG_EPS TI_EHG_DHEP TI_CO_E TI_BF_E TI_GW_E TI_RPI_RI_E TI_RPI_BPI_E ///
TI_RPI_PT_E TI_RPI_IT_E TI_RPI_DU_E TI_RPI_PII_E TI_PF_E TI_BKBPB_E TI_CL_E TI_BNG_E ///
TI_LBB_E TI_CPP_E TI_GTL_E TI_NSP_E TO TO_EHG_MAPE TO_EHG_MAPCHP TO_EHG_MAPH /// 
TO_EHG_APE TO_EHG_APCHP TO_EHG_APH TO_EHG_EDHP TO_EHG_EB TO_EHG_PH TO_EHG_OTH ///
TO_CO TO_BF TO_GW TO_RPI_RO TO_RPI_BKFLOW TO_RPI_PT TO_RPI_IT TO_RPI_PPR TO_RPI_PIR ///
TO_PF TO_BKBPB TO_CL TO_BNG TO_LBB TO_CPP TO_GTL TO_NSP NRG_E DL FC_NE FC_E STATDIFF{
replace `var' = 0 if `var' == .
}
// Generate variable to identify energy type
gen product_type = 1 // Primary sources (could be used in FC)
replace product_type = 2 if inlist(product_id, 6,7,8,9,10,11,12,13,14,16,20) // Secondary sources
replace product_type = 2 if inlist(product_id, 23,24,25,26,27,28,29,30,31,32) // Secondary sources
replace product_type = 2 if inlist(product_id, 33,34,35,36,37,38,39,48,52,54,56,62,63) // Secondary sources
label var product_type "Primary (or also secondary) (1), Secondary (2)"
// Generate import balance
gen IMP_BAL = IMP - EXP
label var IMP_BAL "Import balance (Imports - Exports)"
gen NET_IMP_BAL = 0
replace NET_IMP_BAL = IMP_BAL if IMP_BAL > 0
label var NET_IMP_BAL "Positive net import balance"
gen NET_EXP_BAL = 0
replace NET_EXP_BAL = - IMP_BAL if IMP_BAL < 0
label var NET_EXP_BAL "Positive net export balance"

********************************************************************************
// 2. Match transformation input and output variables
********************************************************************************
// Electricity & heat generation - Main activity producer electricity only
rename (TI_EHG_MAPE_E TO_EHG_MAPE) (TI_MAPE TO_MAPE)
// Electricity & heat generation - Main activity producer CHP
rename (TI_EHG_MAPCHP_E TO_EHG_MAPCHP) (TI_MAPCHP TO_MAPCHP)
// Electricity & heat generation - Main activity producer heat only
rename (TI_EHG_MAPH_E TO_EHG_MAPH) (TI_MAPH TO_MAPH)
// Electricity & heat generation - Autoproducer electricity only 
rename (TI_EHG_APE_E TO_EHG_APE) (TI_APE TO_APE)
// Electricity & heat generation - Autoproducer CHP
rename (TI_EHG_APCHP_E TO_EHG_APCHP) (TI_APCHP TO_APCHP)
// Electricity & heat generation - Autoproducer heat only
rename (TI_EHG_APH_E TO_EHG_APH) (TI_APH TO_APH)
// Electricity & heat generation - Electrically driven heat pumps
rename (TI_EHG_EDHP	TO_EHG_EDHP) (TI_EDHP TO_EDHP)
// Electricity & heat generation - Electric boilers
rename (TI_EHG_EB TO_EHG_EB) (TI_EB TO_EB)
// Electricity & heat generation - Electricity for pumped hydro storage
rename (TI_EHG_EPS TO_EHG_PH) (TI_PH TO_PH)
// Electricity & heat generation - Derived heat for electricity production & other
rename (TI_EHG_DHEP TO_EHG_OTH) (TI_DHEP TO_DHEP)
// Coke ovens
rename (TI_CO_E TO_CO) (TI_CO TO_CO)
// Blast furnaces
rename (TI_BF_E TO_BF) (TI_BF TO_BF)
// Gas works
rename (TI_GW_E TO_GW) (TI_GW TO_GW)
// Refineries & petrochemical industry - Refinery intake / output
rename (TI_RPI_RI_E TO_RPI_RO) (TI_RIO TO_RIO)
// Refineries & petrochemical industry - Backflows from petrochemical industry
rename (TI_RPI_BPI_E TO_RPI_BKFLOW) (TI_BPI TO_BPI)
// Refineries & petrochemical industry - Products transferred
rename (TI_RPI_PT_E TO_RPI_PT) (TI_PT TO_PT)
// Refineries & petrochemical industry - Interproduct transfers
rename (TI_RPI_IT_E TO_RPI_IT) (TI_IT TO_IT)
// Refineries & petrochemical industry - Primary product receipts / direct use
rename (TI_RPI_DU_E TO_RPI_PPR) (TI_DU TO_DU)
// Refineries & petrochemical industry - Petrochemical industry intake / returns
rename (TI_RPI_PII_E TO_RPI_PIR) (TI_PIR TO_PIR)
// Patent fuel plants
rename (TI_PF_E TO_PF) (TI_PF TO_PF)
// BKB & PB plants
rename (TI_BKBPB_E TO_BKBPB) (TI_BKBPB TO_BKBPB)
// Coal liquefaction plants
rename (TI_CL_E TO_CL) (TI_CL TO_CL)
// Blended in natural gas
rename (TI_BNG_E TO_BNG) (TI_BNG TO_BNG)
// Liquid biofuels blended
rename (TI_LBB_E TO_LBB) (TI_LBB TO_LBB)
// Charcoal production plants
rename (TI_CPP_E TO_CPP) (TI_CPP TO_CPP)
// Gas-to-liquids plants
rename (TI_GTL_E TO_GTL) (TI_GTL TO_GTL)
// Not elsewhere specified 
rename (TI_NSP_E TO_NSP) (TI_NSP TO_NSP)
// Replace missing values with 0
foreach var in MAPE MAPCHP MAPH APE APCHP APH EDHP EB PH DHEP CO BF GW RIO BPI ///
PT IT DU PIR PF BKBPB CL BNG LBB CPP GTL NSP{
replace TI_`var' = 0 if TI_`var' == .
replace TO_`var' = 0 if TO_`var' == .
}

********************************************************************************
// 3. Generate new products with postive import balances of secondary products
// of electricity and derived oil products
********************************************************************************
// 3.1 Identify energy secondary products with positive import balance for the whole period in both regions
bysort product_id: egen aux = total(NET_IMP_BAL) if product_type == 2
gen dum_NET_IMP_BAL_SEC = 0 if aux == 0 & aux != .
replace dum_NET_IMP_BAL_SEC = 1 if aux > 0 & aux != .
label var dum_NET_IMP_BAL_SEC "Seconday product with postive net import balance yes (1)"
gen duplicated = 0
label var duplicated "Duplicate (or only-import version) of econdary product (1)"
gen associate = .
label var associate "Associate secondary product ID"
drop aux
// 3.2 Append new duplicated secondary products
save "$dataPath\Intermediate.dta", replace
keep if product_type == 2 & dum_NET_IMP_BAL_SEC == 1
sort year geo product_id
replace associate = product_id
bysort year geo: replace product_id = _n
replace product_id = 63 + product_id
replace product = "Net import balance - " + product
replace duplicated = 1
foreach var in PPRD RCV_RCY IMP EXP STK_CHG INTMARB INTAVI TI_E TI_MAPE TI_MAPCHP ///
TI_MAPH TI_APE TI_APCHP TI_APH TI_EDHP TI_EB TI_PH TI_DHEP TI_CO TI_BF TI_GW ///
TI_RIO TI_BPI TI_PT TI_IT TI_DU TI_PIR TI_PF TI_BKBPB TI_CL TI_BNG TI_LBB TI_CPP ///
TI_GTL TI_NSP TO TO_MAPE TO_MAPCHP TO_MAPH TO_APE TO_APCHP TO_APH TO_EDHP TO_EB ///
TO_PH TO_DHEP TO_CO TO_BF TO_GW TO_RIO TO_BPI TO_PT TO_IT TO_DU TO_PIR TO_PF ///
TO_BKBPB TO_CL TO_BNG TO_LBB TO_CPP TO_GTL TO_NSP NRG_E DL FC_NE FC_E STATDIFF ///
NET_EXP_BAL{
replace `var' = 0
}
replace IMP_BAL = NET_IMP_BAL
append using "$dataPath\Intermediate.dta"
erase "$dataPath\Intermediate.dta"
sort year geo product_id

********************************************************************************
// 4. Compute proportion produced by each producer to each different product in each year and region
********************************************************************************
// 4.1 Generate totals per industry in each year and region
foreach var in MAPE MAPCHP MAPH APE APCHP APH EDHP EB PH DHEP CO BF GW RIO BPI ///
PT IT DU PIR PF BKBPB CL BNG LBB CPP GTL NSP{
qui:{
bysort year geo: egen TO_`var'_total = total(TO_`var')
}
}
// 4.2 Generate totals per industry in each year and region and by product
sort year geo product
levelsof product_id, local(prod)
foreach var in MAPE MAPCHP MAPH APE APCHP APH EDHP EB PH DHEP CO BF GW RIO BPI ///
PT IT DU PIR PF BKBPB CL BNG LBB CPP GTL NSP{
foreach p of local prod{
qui:{
bysort year geo: egen TO_`var'_`p' = total(TO_`var') if product_id == `p'
}
}
}
foreach var in MAPE MAPCHP MAPH APE APCHP APH EDHP EB PH DHEP CO BF GW RIO BPI ///
PT IT DU PIR PF BKBPB CL BNG LBB CPP GTL NSP{
foreach p of local prod{
qui:{
bysort year geo: egen aux_`p' = max(TO_`var'_`p')
replace TO_`var'_`p' = aux_`p'
drop aux_`p'
}
}
}
// 4.3 Generate proportion dedicated to each product by transformation industry
// This would indicate the weight in the output
foreach var in MAPE MAPCHP MAPH APE APCHP APH EDHP EB PH DHEP CO BF GW RIO BPI ///
PT IT DU PIR PF BKBPB CL BNG LBB CPP GTL NSP{
foreach p of local prod{
qui:{
replace TO_`var'_`p' = TO_`var'_`p'/TO_`var'_total
replace TO_`var'_`p' = 0 if TO_`var'_`p' == .
}
}
}
drop *total

********************************************************************************
// 5. Multiply input of each transformation sector by the output weights of each
// transformation sector, then sum up the inputs to produce each energy product
********************************************************************************
// 5.1 Compute input of each transformation sector corresponding to each output product
foreach var in MAPE MAPCHP MAPH APE APCHP APH EDHP EB PH DHEP CO BF GW RIO BPI ///
PT IT DU PIR PF BKBPB CL BNG LBB CPP GTL NSP{
foreach p of local prod{
qui:{
gen TI_`var'_`p' = TI_`var'*TO_`var'_`p'
}
}
}
// 5.2 Sum up the inputs necessary to produce each output product (Intermediate demand)
foreach p of local prod{
gen ID_`p' = TI_MAPE_`p' + TI_MAPCHP_`p' + TI_MAPH_`p' + TI_APE_`p' + TI_APCHP_`p' + ///
TI_APH_`p' + TI_EDHP_`p' + TI_EB_`p' + TI_PH_`p' + TI_DHEP_`p' + TI_CO_`p' + TI_BF_`p' + ///
TI_GW_`p' + TI_RIO_`p' + TI_BPI_`p' + TI_PT_`p' + TI_IT_`p' + TI_DU_`p' + TI_PIR_`p' + ///
TI_PF_`p' + TI_BKBPB_`p' + TI_CL_`p' + TI_BNG_`p' + TI_LBB_`p' + TI_CPP_`p' + TI_GTL_`p' + TI_NSP_`p'
}
// 5.3 Replace intermediate demand of secondary products coming from positive net import balance
levelsof associate, local(prod_dup)
foreach p of local prod_dup{
replace ID_`p' = NET_IMP_BAL if associate == `p'
}

********************************************************************************
// 6. Generate totals of supply and demand sides
********************************************************************************
// 6.1 Generate energy needs from supply side
gen E_NEEDS_SUP = PPRD + NET_IMP_BAL + RCV_RCY + STK_CHG + TO
label var E_NEEDS_SUP "Energy needs - supply side"
// 6.2 Generate total consumption of energy (or energy needs from demand side)
// Intermediate demand (sum of intermediate demands for production of other products
gen ID = 0
foreach p of local prod{
replace ID = ID + ID_`p'
}
label var ID "Intermediate demand"
// Total demand
gen E_NEEDS_DEM = ID + NRG_E + FC_NE + FC_E + INTMARB + INTAVI + DL + STATDIFF + NET_EXP_BAL
label var E_NEEDS_DEM "Energy needs - demand side"
// Final demand (total demand - intermediate demand)
gen FD = E_NEEDS_DEM - ID
gen DIFF_E_NEEDS = E_NEEDS_SUP - E_NEEDS_DEM
label var DIFF_E_NEEDS "Difference between energy needs from supply side to demand side"
// Derive difference to statistical differences (but it is due to missreporting of some TI-TO, but irrelevant)
replace STATDIFF = STATDIFF + DIFF_E_NEEDS
replace E_NEEDS_DEM = ID + NRG_E + FC_NE + FC_E + INTMARB + INTAVI + DL + STATDIFF + NET_EXP_BAL
replace FD = E_NEEDS_DEM - ID
replace DIFF_E_NEEDS = E_NEEDS_SUP - E_NEEDS_DEM
sort year geo product_id
// 6.3 Keep just relevant variables 
keep year geo product* ID* FD PPRD RCV_RCY STK_CHG INTMARB INTAVI TO NRG_E DL FC_NE ///
FC_E STATDIFF NET_IMP_BAL NET_EXP_BAL dum_NET_IMP_BAL_SEC duplicated associate ///
E_NEEDS_SUP ID E_NEEDS_DEM FD
order year geo product* dum_NET_IMP_BAL_SEC duplicated associate PPRD TO RCV_RCY STK_CHG NET_IMP_BAL E_NEEDS_SUP ID* ID INTMARB INTAVI TO NRG_E DL FC_NE FC_E STATDIFF NET_EXP_BAL FD E_NEEDS_DEM
sort year geo product_id
// 6.4 Save input-output establishment
save "$dataPath\Establishment_Input-Output.dta", replace

********************************************************************************
// 7. Generate direct consumption efficiency
********************************************************************************
rename E_NEEDS_DEM Q
// Note that ID_1 + ID_2 + ... ID_63 + FD = Q
// Then, AQ + FD = Q. Therefore, A_1 = ID_1/Q
foreach p of local prod{
qui:{
bysort year geo: egen Q_`p' = total(Q) if product_id == `p'
bysort year geo: egen aux_Q_`p' = max(Q_`p')
replace Q_`p' = aux_Q_`p'
drop aux_Q_`p'
}
}
foreach p of local prod{
qui:{
gen A_`p' = ID_`p'/Q_`p'
replace A_`p' = 0 if A_`p' == .
}
}

********************************************************************************
// 8. Generate identity matrix and matrix (I-A)
********************************************************************************
// Note that Q = (I-A)^(-1)FD
// Then Q = L'FD. L' is tbe Leontief inverse matrix, whose coefficients indicates 
// the total unit of energy i that should be produced in the transformation sector
// to provide one unit of energy j for end-use.
// 7.1 Generate identity matrix
foreach p of local prod{
qui:{
gen I_`p' = 0
replace I_`p' = 1 if product_id == `p'
}
}
// 8.2 Generate intermediate datasets with calculated inverse
bysort year geo: egen aux = count(product_id)
scalar N = aux
drop aux
levelsof year, local(years)
levelsof geo, local(regions)
foreach y of local years{
foreach g of local regions{
preserve
keep if geo == "`g'" & year == `y'
sort year geo product_id
// Create matrix
mkmat A_1 - A_`=scalar(N)', matrix(A)
mkmat I_1 - I_`=scalar(N)', matrix(I)

matrix I_A = I-A
matrix L_prime = inv(I_A)
// Invert to facilitate later estimation of emissions
matrix L = (L_prime)'
svmat double L, names(L_)
save "$dataPath\Intermediate_`g'_`y'", replace
restore
}
}
// 8.3 Merge all intermediate datasets
keep if geo == "" // Keep nothing
foreach y of local years{
foreach g of local regions{
append using "$dataPath\Intermediate_`g'_`y'.dta"
erase "$dataPath\Intermediate_`g'_`y'.dta"
}
}
foreach p of local prod{
qui:{
replace L_`p' = 0 if L_`p' < 0
}
}
// 8.4 Drop secondary energy types in columns to avoid double accounting
levelsof product_id if product_type == 2 & duplicated == 0, local(sec)
foreach p of local sec{
replace L_`p' = 0
}
// 8.6 Calculate KPEQ
egen KPEQ = rowtotal(L_*)
label var KPEQ "Primary energy quantity conversion factor"
// 8.7 Keep just relevant variables
rename Q E_NEEDS_DEM
keep year geo product* L* KPEQ PPRD TO RCV_RCY STK_CHG NET_IMP_BAL E_NEEDS_SUP ID* ID INTMARB INTAVI TO NRG_E DL FC_NE FC_E STATDIFF NET_EXP_BAL FD E_NEEDS_DEM duplicated associate
order year geo product* L* KPEQ PPRD TO RCV_RCY STK_CHG NET_IMP_BAL E_NEEDS_SUP ID* ID INTMARB INTAVI TO NRG_E DL FC_NE FC_E STATDIFF NET_EXP_BAL FD E_NEEDS_DEM duplicated associate
sort year geo product_id

********************************************************************************
// 9. Save Leontief inverse matrix
********************************************************************************
save "$dataPath\Leontief_Inverse_Input-Output.dta", replace


timer off 1
timer list 1
dis "Computing time of routine 1: " round(r(t1)/60, 0.1) " minutes"


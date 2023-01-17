/*
Are We Moving Towards A Low-Carbon Energy-Efficient Economy?
A Decomposition of Energy-Related CO2 Emissions in Spain and EU28, 1995-2017
13. Panel Final Energy Consumption - Eurostat + ODYSSEE shares
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
// 1. Import data from Eurostat Energy Balances
********************************************************************************
use "$dataPath\Energy_Balances_Eurostat_IPCC_Emission_Factor.dta", clear
// Keep just relevant variables
drop if product_group_code == .
drop if year > 2017
keep year geo product* NRG_E FC_E FC_IND_E FC_IND_IS_E FC_IND_CPC_E FC_IND_NFM_E FC_IND_NMM_E ///
FC_IND_TE_E FC_IND_MAC_E FC_IND_MQ_E FC_IND_FBT_E FC_IND_PPP_E FC_IND_WP_E ///
FC_IND_CON_E FC_IND_TL_E FC_IND_NSP_E FC_TRA_E FC_TRA_RAIL_E FC_TRA_ROAD_E ///
FC_TRA_DAVI_E FC_TRA_DNAVI_E FC_TRA_PIPE_E FC_TRA_NSP_E FC_OTH_E FC_OTH_CP_E ///
FC_OTH_HH_E FC_OTH_AF_E FC_OTH_FISH_E FC_OTH_NSP_E
foreach var in NRG_E FC_E FC_IND_E FC_IND_IS_E FC_IND_CPC_E FC_IND_NFM_E FC_IND_NMM_E ///
FC_IND_TE_E FC_IND_MAC_E FC_IND_MQ_E FC_IND_FBT_E FC_IND_PPP_E FC_IND_WP_E ///
FC_IND_CON_E FC_IND_TL_E FC_IND_NSP_E FC_TRA_E FC_TRA_RAIL_E FC_TRA_ROAD_E ///
FC_TRA_DAVI_E FC_TRA_DNAVI_E FC_TRA_PIPE_E FC_TRA_NSP_E FC_OTH_E FC_OTH_CP_E ///
FC_OTH_HH_E FC_OTH_AF_E FC_OTH_FISH_E FC_OTH_NSP_E{
replace `var' = 0 if `var' == .
}

********************************************************************************
// 2. Aggregate consumption to get magnitudes of analysis by sector
********************************************************************************
// 2.1 Agriculture
gen FEC_AGRI_AF = FC_OTH_AF_E
label var FEC_AGRI_AF "Agriculture - Agriculture and forestry - FEC"
gen FEC_AGRI_FISH = FC_OTH_FISH_E
label var FEC_AGRI_FISH "Agriculture - Fishing - FEC"
egen FEC_AGRI = rowtotal(FEC_AGRI*)
label var FEC_AGRI "Agriculture - FEC"
gen check0 = FC_OTH_AF_E + FC_OTH_FISH_E - FEC_AGRI
// 2.2 Industry
gen FEC_IND_EEI = NRG_E + FC_IND_MQ_E
label var FEC_IND_EEI "Industry - Energy sector and extractive industries - FEC"
gen FEC_IND_FBT = FC_IND_FBT_E
label var FEC_IND_FBT "Industry - Food, breverages and tobacco - FEC"
gen FEC_IND_TL = FC_IND_TL_E
label var FEC_IND_TL "Industry - Textile and leather - FEC"
gen FEC_IND_WWP = FC_IND_WP_E
label var FEC_IND_WWP "Industry - Wood and wood products - FEC"
gen FEC_IND_PPP = FC_IND_PPP_E
label var FEC_IND_PPP "Industry - Paper, pulp and printing - FEC"
gen FEC_IND_CPC = FC_IND_CPC_E
label var FEC_IND_CPC "Industry - Chemical and petrochemical - FEC"
gen FEC_IND_NMM = FC_IND_NMM_E
label var FEC_IND_NMM "Industry - Non-metallic minerals - FEC"
gen FEC_IND_BM = FC_IND_IS_E + FC_IND_NFM_E
label var FEC_IND_BM "Industry - Basic metals - FEC"
gen FEC_IND_MAC = FC_IND_MAC_E
label var FEC_IND_MAC "Industry - Machinery - FEC"
gen FEC_IND_TE = FC_IND_TE_E
label var FEC_IND_TE "Industry - Transport equipement - FEC"
gen FEC_IND_OI = FC_IND_NSP_E
label var FEC_IND_OI "Industry - Other industries - FEC"
gen FEC_IND_CON = FC_IND_CON_E
label var FEC_IND_CON "Industry - Construction - FEC"
egen FEC_IND = rowtotal(FEC_IND*)
label var FEC_IND "Industry - FEC"
// 2.3 Commercial and public services
gen FEC_CPS = FC_OTH_CP_E + FC_OTH_NSP_E
label var FEC_CPS "Commercial and public services - FEC"
gen FEC_ECO = FEC_AGRI + FEC_IND + FEC_CPS
label var FEC_ECO "Economic / Business sectors - FEC"
// Distribute it to end-uses with end-use shares from ODYSSEE
merge m:m year geo using "$dataPath\ODYSSEE.dta"
drop _merge
// 2.3.1 Space heating
gen FEC_CPS_SH = FEC_CPS*SERV_SH_Coal if product_group_code == 1 | product_group_code == 3
replace FEC_CPS_SH = FEC_CPS*SERV_SH_Oil if product_group_code == 4 | product_group_code == 5
replace FEC_CPS_SH = FEC_CPS*SERV_SH_Gas if product_group_code == 2 | product_group_code == 6
replace FEC_CPS_SH = FEC_CPS*SERV_SH_Heat if product_group_code == 9 | product_group_code == 10
replace FEC_CPS_SH = FEC_CPS*SERV_SH_Ele if product_group_code == 11
replace FEC_CPS_SH = FEC_CPS*SERV_SH if product_group_code == 7| product_group_code == 8
label var FEC_CPS_SH "Commercial and public services - Space heating - FEC"
// 2.3.2 Hot water
gen FEC_CPS_HW = FEC_CPS*SERV_HW_Coal if product_group_code == 1 | product_group_code == 3
replace FEC_CPS_HW = FEC_CPS*SERV_HW_Oil if product_group_code == 4 | product_group_code == 5
replace FEC_CPS_HW = FEC_CPS*SERV_HW_Gas if product_group_code == 2 | product_group_code == 6
replace FEC_CPS_HW = FEC_CPS*SERV_HW_Heat if product_group_code == 9 | product_group_code == 10
replace FEC_CPS_HW = FEC_CPS*SERV_HW_Ele if product_group_code == 11
replace FEC_CPS_HW = FEC_CPS*SERV_HW if product_group_code == 7| product_group_code == 8
label var FEC_CPS_HW "Commercial and public services - Hot water - FEC"
// 2.3.3 Cooking
gen FEC_CPS_COOK = FEC_CPS*SERV_COOK_Oil if product_group_code == 4 | product_group_code == 5
replace FEC_CPS_COOK = FEC_CPS*SERV_COOK_Gas if product_group_code == 2 | product_group_code == 6
replace FEC_CPS_COOK = FEC_CPS*SERV_COOK_Ele if product_group_code == 11
replace FEC_CPS_COOK = FEC_CPS*SERV_COOK if product_group_code == 7| product_group_code == 8
replace FEC_CPS_COOK = 0 if FEC_CPS_COOK == .
label var FEC_CPS_COOK "Commercial and public services - Cooking - FEC"
// 2.3.4 Air conditioning/cooling
gen FEC_CPS_AC = FEC_CPS*SERV_AC_Ele if product_group_code == 11
replace FEC_CPS_AC = 0 if FEC_CPS_AC == .
label var FEC_CPS_AC "Commercial and public services - Air conditioning - FEC"
// 2.3.5 Lighting/Electric Appliances
gen FEC_CPS_LIGHT = FEC_CPS*SERV_LIGHT_Ele if product_group_code == 11
replace FEC_CPS_LIGHT = 0 if FEC_CPS_LIGHT == .
label var FEC_CPS_LIGHT "Commercial and public services - Lighting / Electric appliances - FEC"
// 2.3.6 Check total of services
gen check1 = FEC_CPS - (FEC_CPS_SH + FEC_CPS_HW + FEC_CPS_COOK + FEC_CPS_AC + FEC_CPS_LIGHT)
// 2.4 Households
gen FEC_HH = FC_OTH_HH_E
label var FEC_HH "Households as employers / for own use - FEC"
// Distribute it to end-uses with end-use shares from ODYSSEE
merge m:m year geo using "$dataPath\ODYSSEE.dta"
drop _merge
// 2.4.1 Space heating
gen FEC_HH_SH = FEC_HH*HHs_SH_Coal if product_group_code == 1 | product_group_code == 3
replace FEC_HH_SH = FEC_HH*HHs_SH_Oil if product_group_code == 4 | product_group_code == 5
replace FEC_HH_SH = FEC_HH*HHs_SH_Gas if product_group_code == 2 | product_group_code == 6
replace FEC_HH_SH = FEC_HH*HHs_SH_Heat if product_group_code == 9 | product_group_code == 10
replace FEC_HH_SH = FEC_HH*HHs_SH_Ele if product_group_code == 11
replace FEC_HH_SH = FEC_HH*HHs_SH_Ren if product_group_code == 7
replace FEC_HH_SH = FEC_HH*HHs_SH if product_group_code == 8
label var FEC_HH_SH "Households - Space heating - FEC"
// 2.4.2 Hot water
gen FEC_HH_HW = FEC_HH*HHs_HW_Coal if product_group_code == 1 | product_group_code == 3
replace FEC_HH_HW = FEC_HH*HHs_HW_Oil if product_group_code == 4 | product_group_code == 5
replace FEC_HH_HW = FEC_HH*HHs_HW_Gas if product_group_code == 2 | product_group_code == 6
replace FEC_HH_HW = FEC_HH*HHs_HW_Heat if product_group_code == 9 | product_group_code == 10
replace FEC_HH_HW = FEC_HH*HHs_HW_Ele if product_group_code == 11
replace FEC_HH_HW = FEC_HH*HHs_HW_Ren if product_group_code == 7
replace FEC_HH_HW = FEC_HH*HHs_HW if product_group_code == 8
label var FEC_HH_HW "Households - Hot water - FEC"
// 2.4.3 Cooking
gen FEC_HH_COOK = FEC_HH*HHs_COOK_Coal if product_group_code == 1 | product_group_code == 3
replace FEC_HH_COOK = FEC_HH*HHs_COOK_Oil if product_group_code == 4 | product_group_code == 5
replace FEC_HH_COOK = FEC_HH*HHs_COOK_Gas if product_group_code == 2 | product_group_code == 6
replace FEC_HH_COOK = FEC_HH*HHs_COOK_Ele if product_group_code == 11
replace FEC_HH_COOK = FEC_HH*HHs_COOK_Ren if product_group_code == 7
replace FEC_HH_COOK = FEC_HH*HHs_COOK if product_group_code == 8
replace FEC_HH_COOK = 0 if FEC_HH_COOK == .
label var FEC_HH_COOK "Households - Cooking - FEC"
// 2.4.4 Air conditioning/cooling
gen FEC_HH_AC = FEC_HH*HHs_AC_Ele if product_group_code == 11
replace FEC_HH_AC = 0 if FEC_HH_AC == .
label var FEC_HH_AC "Households - Air conditioning - FEC"
// 2.4.5 Lighting/Electric Appliances
gen FEC_HH_LIGHT = FEC_HH*HHs_LIGHT_Ele if product_group_code == 11
replace FEC_HH_LIGHT = 0 if FEC_HH_LIGHT == .
label var FEC_HH_LIGHT "Households - Lighting / Electric appliances - FEC"
// 2.4.6 Check total of households
gen check2 = FEC_HH - (FEC_HH_SH + FEC_HH_HW + FEC_HH_COOK + FEC_HH_AC + FEC_HH_LIGHT)
// 2.5 Transport
gen FEC_TRA = FC_TRA_E
label var FEC_TRA "Transport - FEC"
// Distribute it to end-uses with modal split shares from ODYSSEE
gen FEC_TRA_PASS = .
label var FEC_TRA_PASS "Transport - Passenger - FEC"
gen FEC_TRA_FR = .
label var FEC_TRA_FR "Transport - Freight - FEC"
// Note that navigation, and pipeline transport are freight transport by definition
// Note that domestic aviation + other is passenger transport by definition
// Then, just road and rail transport must be split into passenger or freight
// 2.5.1 Road transport
gen FEC_TRA_PASS_ROAD = FC_TRA_ROAD_E*ROAD_PASS_Oil_Gasoline if product_id == 26
replace FEC_TRA_PASS_ROAD = FC_TRA_ROAD_E*ROAD_PASS_Oil_Diesel if product_id == 32
replace FEC_TRA_PASS_ROAD = FC_TRA_ROAD_E*ROAD_PASS_Oil_LPG if product_id == 25
replace FEC_TRA_PASS_ROAD = FC_TRA_ROAD_E*ROAD_PASS_Oil if product_group_code == 5 & product_id != 25 & product_id != 26 & product_id != 32
replace FEC_TRA_PASS_ROAD = FC_TRA_ROAD_E*ROAD_PASS_Gas if product_group_code == 6
replace FEC_TRA_PASS_ROAD = FC_TRA_ROAD_E*ROAD_PASS_Ren_Bioeth if product_id == 51 | product_id == 52
replace FEC_TRA_PASS_ROAD = FC_TRA_ROAD_E*ROAD_PASS_Ren_Biodies if product_id == 53 | product_id == 54
replace FEC_TRA_PASS_ROAD = FC_TRA_ROAD_E*ROAD_PASS_Ren_Biof if product_group_code == 7 & product_id != 53 & product_id != 54
replace FEC_TRA_PASS_ROAD = FC_TRA_ROAD_E*ROAD_PASS if inlist(product_group_code, 1, 2, 3, 4, 8, 9, 10, 11)
label var FEC_TRA_PASS_ROAD "Transport - Passenger - Road - FEC"
gen FEC_TRA_FR_ROAD = FC_TRA_ROAD_E*ROAD_FR_Oil_Gasoline if product_id == 26
replace FEC_TRA_FR_ROAD = FC_TRA_ROAD_E*ROAD_FR_Oil_Diesel if product_id == 32
replace FEC_TRA_FR_ROAD = FC_TRA_ROAD_E*ROAD_FR_Oil_LPG if product_id == 25
replace FEC_TRA_FR_ROAD = FC_TRA_ROAD_E*ROAD_FR_Oil if product_group_code == 5 & product_id != 25 & product_id != 26 & product_id != 32
replace FEC_TRA_FR_ROAD = FC_TRA_ROAD_E*ROAD_FR_Gas if product_group_code == 6
replace FEC_TRA_FR_ROAD = FC_TRA_ROAD_E*ROAD_FR_Ren_Bioeth if product_id == 51 | product_id == 52
replace FEC_TRA_FR_ROAD = FC_TRA_ROAD_E*ROAD_FR_Ren_Biodies if product_id == 53 | product_id == 54
replace FEC_TRA_FR_ROAD = FC_TRA_ROAD_E*ROAD_FR_Ren_Biof if product_group_code == 7 & product_id != 53 & product_id != 54
replace FEC_TRA_FR_ROAD = FC_TRA_ROAD_E*ROAD_FR if inlist(product_group_code, 1, 2, 3, 4, 8, 9, 10, 11)
label var FEC_TRA_FR_ROAD "Transport - Freight - Road - FEC"
gen check3 = FC_TRA_ROAD_E - (FEC_TRA_FR_ROAD + FEC_TRA_PASS_ROAD)
// 2.5.2 Rail transport
gen FEC_TRA_PASS_RAIL = FC_TRA_RAIL_E*RAIL_PASS
label var FEC_TRA_PASS_RAIL "Transport - Passenger - Rail - FEC"
gen FEC_TRA_FR_RAIL = FC_TRA_RAIL_E*RAIL_FR
label var FEC_TRA_FR_RAIL "Transport - Freight - Rail - FEC"
gen check4 = FC_TRA_RAIL_E - (FEC_TRA_PASS_RAIL + FEC_TRA_FR_RAIL)
// 2.5.3 Generate totals of passengers and freight
gen FEC_TRA_PASS_AVI = FC_TRA_DAVI_E + FC_TRA_NSP_E
label var FEC_TRA_PASS_AVI "Transport - Passenger - Aviation - FEC"
replace FEC_TRA_PASS = FEC_TRA_PASS_ROAD + FEC_TRA_PASS_RAIL + FEC_TRA_PASS_AVI
gen FEC_TRA_FR_NAVI = FC_TRA_DNAVI_E
label var FEC_TRA_FR_NAVI "Transport - Passenger - Navigation - FEC"
gen FEC_TRA_FR_PIPE = FC_TRA_PIPE_E
label var FEC_TRA_FR_PIPE "Transport - Passenger - Pipeline - FEC"
replace FEC_TRA_FR = FEC_TRA_FR_ROAD + FEC_TRA_FR_RAIL + FEC_TRA_FR_NAVI + FEC_TRA_FR_PIPE
gen check5 = FC_TRA_E - (FEC_TRA_PASS + FEC_TRA_FR)
// 2.6 Generate Totals
gen FEC_TOT = FEC_ECO + FEC_HH + FEC_TRA
label var FEC_TOT "Total - FEC"
gen check6 = FC_IND_E + NRG_E - FEC_IND // The difference here is Ambient heat (product with no association in disaggregation of industry)
gen check8 = FC_OTH_E - (FEC_CPS + FEC_HH + FEC_AGRI)
gen check9 = FC_E - (FC_IND_E +  FC_TRA_E + FC_OTH_E)
sum check*

********************************************************************************
// 2. Order and save data
********************************************************************************
// Order variables
keep year geo product* FEC_TOT FEC_ECO FEC_AGRI* FEC_IND* FEC_CPS* FEC_HH* FEC_TRA*
order year geo product* FEC_TOT FEC_ECO FEC_AGRI* FEC_IND* FEC_CPS* FEC_HH* FEC_TRA*
sort geo year product_group_code product_id
save "$dataPath\FEC_by_Sector_Eurostat_ODYSSEE.dta", replace


timer off 1
timer list 1
dis "Computing time of routine 1: " round(r(t1)/60, 0.1) " minutes"

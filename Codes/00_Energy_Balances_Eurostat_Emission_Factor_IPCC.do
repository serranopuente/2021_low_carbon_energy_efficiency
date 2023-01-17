/*
Are We Moving Towards A Low-Carbon Energy-Efficient Economy?
A Decomposition of Energy-Related CO2 Emissions in Spain and EU28, 1995-2017
00. Panel Energy Balances Eurostat + Panel IPCC (Emission factors)
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
// BLOCK A: Eurostat Energy Balances
********************************************************************************

********************************************************************************
// 1. Download raw data and reshape to have year geo and fuels on the left and 
// magnitudes on the top
********************************************************************************
// Complete Eurostat Energy Balances
eurostatuse nrg_bal_c, noflags long geo(EU28 ES) start(1995) keepdim(KTOE) clear
// Clean database
drop unit unit_label geo_label
rename (time siec_label siec) (year product product_code)
// Years and countries in rows and balance variables in columns
levelsof nrg_bal, local(variables)
foreach k of local variables{
preserve
keep if nrg_bal == "`k'"
gen firstpart = substr(nrg_bal,1, strpos(nrg_bal, "-")-1)
gen lastpart = substr(nrg_bal, strpos(nrg_bal, "-") + 1, .)
gen new = firstpart + lastpart
local label_name = nrg_bal_label[1]
local name = new[1]
rename nrg_bal_c `name'
label var `name' "`label_name'"
drop nrg_bal* *part new
save "$dataPath\Intermediate_`k'.dta", replace
restore
}

********************************************************************************
// 2. Merge all intermediate datasets (one dataset per magnitude)
********************************************************************************
keep year geo product product_code
duplicates drop year geo product product_code, force
order year geo product
foreach k of local variables{
merge 1:1 year geo product product_code using "$dataPath\Intermediate_`k'.dta"
drop _merge
erase "$dataPath\Intermediate_`k'.dta"
}
// Order variables in the balance order
order year geo product product_code PPRD RCV_RCY IMP EXP STK_CHG GAE INTMARB GIC INTAVI NRGSUP GIC20202030 PEC20202030 ///
TI_E TI_EHG_E TI_EHG_MAPE_E TI_EHG_MAPCHP_E TI_EHG_MAPH_E TI_EHG_APE_E ///
TI_EHG_APCHP_E TI_EHG_APH_E TI_EHG_EDHP TI_EHG_EB TI_EHG_EPS TI_EHG_DHEP TI_CO_E TI_BF_E ///
TI_GW_E TI_RPI_E TI_RPI_RI_E TI_RPI_BPI_E TI_RPI_PT_E TI_RPI_IT_E TI_RPI_DU_E TI_RPI_PII_E ///
TI_PF_E TI_BKBPB_E TI_CL_E TI_BNG_E TI_LBB_E TI_CPP_E TI_GTL_E TI_NSP_E TO TO_EHG ///
TO_EHG_MAPE TO_EHG_MAPCHP TO_EHG_MAPH TO_EHG_APE TO_EHG_APCHP TO_EHG_APH TO_EHG_EDHP ///
TO_EHG_EB TO_EHG_PH TO_EHG_OTH TO_CO TO_BF TO_GW TO_RPI TO_RPI_RO TO_RPI_BKFLOW ///
TO_RPI_PT TO_RPI_IT TO_RPI_PPR TO_RPI_PIR TO_PF TO_BKBPB TO_CL TO_BNG TO_LBB TO_CPP ///
TO_GTL TO_NSP NRG_E NRG_EHG_E NRG_CM_E NRG_OIL_NG_E NRG_PF_E NRG_CO_E NRG_BKBPB_E ///
NRG_GW_E NRG_BF_E NRG_PR_E NRG_NI_E NRG_CL_E NRG_LNG_E NRG_BIOG_E NRG_GTL_E NRG_CPP_E ///
NRG_NSP_E DL AFC FEC20202030 FC_NE TI_NRG_FC_IND_NE TI_NE NRG_NE FC_IND_NE FC_TRA_NE FC_OTH_NE ///
FC_E FC_IND_E FC_IND_IS_E FC_IND_CPC_E FC_IND_NFM_E FC_IND_NMM_E FC_IND_TE_E FC_IND_MAC_E ///
FC_IND_MQ_E FC_IND_FBT_E FC_IND_PPP_E FC_IND_WP_E FC_IND_CON_E FC_IND_TL_E FC_IND_NSP_E ///
FC_TRA_E FC_TRA_RAIL_E FC_TRA_ROAD_E FC_TRA_DAVI_E FC_TRA_DNAVI_E FC_TRA_PIPE_E FC_TRA_NSP_E ///
FC_OTH_E FC_OTH_CP_E FC_OTH_HH_E FC_OTH_AF_E FC_OTH_FISH_E FC_OTH_NSP_E STATDIFF GEP ///
GEP_MAPE GEP_MAPCHP GEP_APE GEP_APCHP GHP GHP_MAPCHP GHP_MAPH GHP_APCHP GHP_APH

********************************************************************************
// 3. Check consistency of the balance dataset
********************************************************************************
gen check1 = GAE - (PPRD + RCV_RCY + IMP - EXP + STK_CHG)
gen check2 = NRGSUP - (GAE - INTMARB - INTAVI)
gen check3 = GIC - (GAE - INTMARB)
gen check4 = TI_E - (TI_EHG_E + TI_CO_E + TI_BF_E + TI_GW_E + TI_RPI_E + TI_PF_E + ///
TI_BKBPB_E + TI_CL_E + TI_BNG_E + TI_LBB_E + TI_CPP_E + TI_GTL_E + TI_NSP_E)
gen check5 = TI_EHG_E - (TI_EHG_MAPE_E + TI_EHG_MAPCHP_E + TI_EHG_MAPH_E + TI_EHG_APE_E + ///
TI_EHG_APCHP_E + TI_EHG_APH_E + TI_EHG_EDHP + TI_EHG_EB + TI_EHG_EPS + TI_EHG_DHEP)
gen check6 = TI_RPI_E - (TI_RPI_RI_E + TI_RPI_BPI_E + TI_RPI_PT_E + TI_RPI_IT_E + ///
TI_RPI_DU_E + TI_RPI_PII_E)
gen check7 = TO - (TO_EHG + TO_CO + TO_BF + TO_GW + TO_RPI + TO_PF + TO_BKBPB + TO_CL + ///
TO_BNG + TO_LBB + TO_CPP + TO_GTL + TO_NSP)
gen check8 = TO_EHG - (TO_EHG_MAPE + TO_EHG_MAPCHP + TO_EHG_MAPH + TO_EHG_APE + ///
TO_EHG_APCHP + TO_EHG_APH + TO_EHG_EDHP + TO_EHG_EB + TO_EHG_PH + TO_EHG_OTH)
gen check9 = TO_RPI - (TO_RPI_RO + TO_RPI_BKFLOW + TO_RPI_PT + TO_RPI_IT + TO_RPI_PPR + ///
TO_RPI_PIR)
gen check10 = NRG_E - (NRG_EHG_E + NRG_CM_E + NRG_OIL_NG_E + NRG_PF_E + NRG_CO_E + ///
NRG_BKBPB_E + NRG_GW_E + NRG_BF_E + NRG_PR_E + NRG_NI_E + NRG_CL_E + NRG_LNG_E + ///
NRG_BIOG_E + NRG_GTL_E + NRG_CPP_E + NRG_NSP_E)
gen check11 = AFC - (NRGSUP - TI_E + TO - NRG_E - DL)
gen check12 = FC_NE - (TI_NRG_FC_IND_NE + FC_TRA_NE + FC_OTH_NE)
gen check13 = TI_NRG_FC_IND_NE - (TI_NE + NRG_NE + FC_IND_NE)
gen check14 = FC_E - (FC_IND_E + FC_TRA_E + FC_OTH_E)
gen check15 = FC_IND_E - (FC_IND_IS_E + FC_IND_CPC_E + FC_IND_NFM_E + FC_IND_NMM_E + ///
FC_IND_TE_E + FC_IND_MAC_E + FC_IND_MQ_E + FC_IND_FBT_E + FC_IND_PPP_E + FC_IND_WP_E + ///
FC_IND_CON_E + FC_IND_TL_E + FC_IND_NSP_E) // Industry aggregate for TOTAL and RA000
// also incluldes RA600, which is not attributed to any specific category within the industrial sector.
gen check16 = FC_TRA_E - (FC_TRA_RAIL_E + FC_TRA_ROAD_E + FC_TRA_DAVI_E + FC_TRA_DNAVI_E + ///
FC_TRA_PIPE_E + FC_TRA_NSP_E)
gen check17 = FC_OTH_E - (FC_OTH_CP_E + FC_OTH_HH_E + FC_OTH_AF_E + FC_OTH_FISH_E + ///
FC_OTH_NSP_E)
gen check18 = STATDIFF -(AFC - FC_NE - FC_E)
gen check19 = GEP - (GEP_MAPE + GEP_MAPCHP + GEP_APE + GEP_APCHP)
gen check20 = GHP - (GHP_MAPCHP + GHP_MAPH + GHP_APCHP + GHP_APH)
// Display checks
sum check*
sum check* if geo == "ES" | geo == "EU28" | geo == "EA19"
drop check*

********************************************************************************
// 4. Product ID and groups (for this article)
********************************************************************************
// 4.1 Product ID
gen product_id = .
local i = 1
foreach code in "C0110" "C0121" "C0129" "C0210" "C0220" "C0320" "C0311" "C0312" "C0340" "C0330" ///
"C0360" "C0350" "C0371" "C0379" ///
"P1100" "P1200" ///
"S2000" ///
"O4100_TOT" "O4200" "O4300" "O4400X4410" "O4500" "O4610" "O4620" "O4630" "O4652XR5210B" "O4651" "O4653" "O4661XR5230B" "O4669" "O4640" "O4671XR5220B" "O4680" "O4691" "O4692" "O4695" "O4694" "O4693" "O4699" ///
"G3000" ///
"RA100" "RA500" "RA300" "RA420" "RA410" "RA200" "R5110-5150_W6000RI" "R5160" "R5300" "W6210" "R5210P" "R5210B" "R5220P" "R5220B" "R5230P" "R5230B" "R5290" "RA600" ///
"W6100" "W6220" ///
"N900H" ///
"H8000" ///
"E7000" {
replace product_id = `i' if product_code == "`code'"
local i = `i' + 1
}
// 4.2 Product group
gen product_group = ""
gen product_group_code = .
replace product_group = "Solid fossil fuels" if product_id <= 10
replace product_group_code = 1 if product_group == "Solid fossil fuels"
replace product_group = "Manufactured gases" if product_id > 10 & product_id <= 14
replace product_group_code = 2 if product_group == "Manufactured gases"
replace product_group = "Peat and peat products" if product_id > 14 & product_id <= 16	
replace product_group_code = 3 if product_group == "Peat and peat products"
replace product_group = "Oil shale and oil sands" if product_id == 17
replace product_group_code = 4 if product_group == "Oil shale and oil sands"
replace product_group = "Oil and petroleum products" if product_id > 17 & product_id <= 39	
replace product_group_code = 5 if product_group == "Oil and petroleum products"
replace product_group = "Natural gas" if product_id == 40
replace product_group_code = 6 if product_group == "Natural gas"
replace product_group = "Renewables and biofuels" if product_id > 40 & product_id <= 58	
replace product_group_code = 7 if product_group == "Renewables and biofuels"
replace product_group = "Non-renewable waste" if product_id > 58 & product_id <= 60	
replace product_group_code = 8 if product_group == "Non-renewable waste"
replace product_group = "Nuclear heat" if product_id == 61
replace product_group_code = 9 if product_group == "Nuclear heat"
replace product_group = "Heat" if product_id == 62
replace product_group_code = 10 if product_group == "Heat"
replace product_group = "Electricity" if product_id == 63
replace product_group_code = 11 if product_group == "Electricity"

// Save dataset with complete balance
order year geo product product_code product_id product_group product_group_code
sort year geo product_group_code product_id
save "$dataPath\Energy_Balances_Eurostat.dta", replace

********************************************************************************
// BLOCK B: IPCC Emission Factors
********************************************************************************

********************************************************************************
// 1. Import raw data and clean it
********************************************************************************
// The raw data is downloaded in .xls Excel format and converted to .txt format manually
// Otherwise, Stata cannot deal to import the .xls file
import delimited "$dataPath\IPCC and Other - Emissions\output.txt", delimiter("") varnames(1) clear
// Clean
drop if efid == ""
keep ipcc2006sourcesinkcategory fuel2006 gas description unit value typeofparameter
rename (ipcc2006sourcesinkcategory fuel2006 description) (category fuel var)
gen category_code = substr(category,1,1)
destring category_code, replace
keep if category_code == 1 // Just energy-related emission factors
drop if gas != "CARBON DIOXIDE" // Keep just factors associated with CO2
drop if fuel == "" // Keep just factors associated with fuel type
keep if typeofparameter == "2006 IPCC default " // Just default parameters of IPCC 2006 Guidelines
keep if unit == "TJ/Gg " | unit == "fraction " | unit == "kg/TJ " // Keep NCV, fraction oxidized and carbon emission factor
duplicates drop fuel unit, force
keep fuel var unit value
destring value, replace
gen aux = .
replace aux = 1 if unit == "TJ/Gg "
replace aux = 2 if unit == "fraction "
replace aux = 3 if unit == "kg/TJ "
keep fuel value aux
reshape wide value, i(fuel) j(aux)
rename value1 NCV
label var NCV "Net Calorific Value; TJ/Gg"
rename value2 ox_fraction
label var ox_fraction 	
rename value3 CO2_emission_factor
label var CO2_emission_factor "CO2 Effective Emission Factor; kg/TJ"
gen CC = CO2_emission_factor / (ox_fraction*44/12*1000)
label var CC "Carbon Content; kg/GJ"

********************************************************************************
// 2. Prepare data to match Eurostat Energy Balances
********************************************************************************
// "Oil Shale and Tar Sands" and "Shale Oil" have different emission factors here,
// but are the same category in Eurostat, then calculate the mean of these 2
// for the Eurostat category "Oil shale and oil sands"
sum CC if fuel == "Oil Shale and Tar Sands " | fuel == "Shale Oil "
gen aux = r(mean)
replace CC = aux if fuel == "Oil Shale and Tar Sands " | fuel == "Shale Oil "
replace fuel = "Oil shale and oil sands" if fuel == "Oil Shale and Tar Sands " | fuel == "Shale Oil "
duplicates drop fuel, force
drop aux

// "Wood/Wood Waste", "Other Primary Solid Biomass", and "Sulphite lyes (Black liquor)"
// have different emission factors here, but are the same category in Eurostat, then
// calculate the mean of these 3 for the Eurostat category "Primary solid biofuels"
sum CC if fuel == "Wood/Wood Waste " | fuel == "Sulphite Lyes (Black Liquor) " | fuel == "Other Primary Solid Biomass "
gen aux = r(mean)
replace CC = aux if fuel == "Wood/Wood Waste " | fuel == "Sulphite Lyes (Black Liquor) " | fuel == "Other Primary Solid Biomass "
replace fuel = "Primary solid biofuels" if fuel == "Wood/Wood Waste " | fuel == "Sulphite Lyes (Black Liquor) " | fuel == "Other Primary Solid Biomass "
duplicates drop fuel, force
drop aux

// Match categories of fuels with Eurostat product_code
gen product_code = "" 
replace product_code = "C0110"	if fuel == "Anthracite " 
replace product_code = "O4651"	if fuel == "Aviation Gasoline "
replace product_code = "R5220P"	if fuel == "Biodiesels "
replace product_code = "R5210P"	if fuel == "Biogasoline "
replace product_code = "O4695"	if fuel == "Bitumen "
replace product_code = "C0371"	if fuel == "Blast Furnace Gas "
replace product_code = "C0330"	if fuel == "Brown Coal Briquettes "
replace product_code = "R5160"	if fuel == "Charcoal "
replace product_code = "C0340"	if fuel == "Coal Tar "
replace product_code = "C0311"	if fuel == "Coke Oven Coke and Lignite Coke "
replace product_code = "C0350"	if fuel == "Coke Oven Gas "
replace product_code = "C0121"	if fuel == "Coking Coal "
replace product_code = "O4100_TOT"	if fuel == "Crude Oil "
replace product_code = "O4671XR5220B"	if fuel == "Diesel Oil "
replace product_code = "O4620"	if fuel == "Ethane "
replace product_code = "C0312"	if fuel == "Gas Coke "
replace product_code = "O4671XR5220B"	if fuel == "Gas Oil "
replace product_code = "C0360"	if fuel == "Gas Works Gas "
replace product_code = "W6100"	if fuel == "Industrial Wastes "
replace product_code = "O4653"	if fuel == "Jet Gasoline "
replace product_code = "O4661XR5230B"	if fuel == "Jet Kerosene "
replace product_code = "C0379"	if fuel == "Landfill Gas "
replace product_code = "C0220"	if fuel == "Lignite "
replace product_code = "O4630"	if fuel == "Liquefied Petroleum Gases "
replace product_code = "O4692"	if fuel == "Lubricants "
replace product_code = "O4652XR5210B"	if fuel == "Motor Gasoline "
replace product_code = "W6210"	if fuel == "Municipal Wastes (biomass fraction) "
replace product_code = "W6220"	if fuel == "Municipal Wastes (non-biomass fraction) "
replace product_code = "O4640"	if fuel == "Naphtha "
replace product_code = "O4200"	if fuel == "Natural Gas Liquids (NGLs) "
replace product_code = "G3000"	if fuel == "Natural Gas "
replace product_code = "S2000"	if fuel == "Oil shale and oil sands"
replace product_code = "O4500"	if fuel == "Orimulsion "
replace product_code = "R5300"	if fuel == "Other Biogas "
replace product_code = "C0129"	if fuel == "Other Bituminous Coal "
replace product_code = "O4669"	if fuel == "Other Kerosene "
replace product_code = "R5290"	if fuel == "Other Liquid Biofuels "
replace product_code = "O4699"	if fuel == "Other Petroleum Products "
replace product_code = "O4400X4410"	if fuel == "Oxygen Steel Furnace Gas "
replace product_code = "C0320"	if fuel == "Patent Fuel "
replace product_code = "P1100"	if fuel == "Peat "
replace product_code = "O4694"	if fuel == "Petroleum Coke "
replace product_code = "O4300"	if fuel == "Refinery Feedstocks "
replace product_code = "O4610"	if fuel == "Refinery Gas "
replace product_code = "O4680"	if fuel == "Residual Fuel Oil "
replace product_code = "R5300"	if fuel == "Sludge Gas "
replace product_code = "C0210"	if fuel == "Sub-Bituminous Coal "
replace product_code = "" if fuel == "Waste Oils "
replace product_code = "O4693"	if fuel == "Waxes "
replace product_code = "O4691"	if fuel == "White Spirit & SBP "
replace product_code = "R5110-5150_W6000RI"	if fuel == "Primary solid biofuels"

// Peat Products
set obs `=scalar(_N+1)'
replace product_code = "P1200" if _n == _N
replace fuel = "Peat products "	if _n == _N
gen aux_NCV = NCV if product_code == "P1100"
egen aux_1_NCV = max(aux_NCV)
replace NCV = aux_1_NCV if product_code == "P1200"
gen aux_ox_fraction = ox_fraction if product_code == "P1100"
egen aux_1_ox_fraction = max(aux_ox_fraction)
replace ox_fraction = aux_1_ox_fraction if product_code == "P1200"
gen aux_CO2_emission_factor = CO2_emission_factor if product_code == "P1100"
egen aux_1_CO2_emission_factor = max(aux_CO2_emission_factor)
replace CO2_emission_factor = aux_1_CO2_emission_factor if product_code == "P1200"
gen aux_CC = CC if product_code == "P1100"
egen aux_1_CC = max(aux_CC)
replace CC = aux_1_CC if product_code == "P1200"
drop aux*

// Pure bio jet kerosene is assumed to be like pure bio gasoline /diesel
set obs `=scalar(_N+1)'
replace product_code = "R5230P" if _n == _N
replace fuel = "Pure bio jet kerosene "	if _n == _N
gen aux_NCV = NCV if product_code == "R5220P"
egen aux_1_NCV = max(aux_NCV)
replace NCV = aux_1_NCV if product_code == "R5230P"
gen aux_ox_fraction = ox_fraction if product_code == "R5210P"
egen aux_1_ox_fraction = max(aux_ox_fraction)
replace ox_fraction = aux_1_ox_fraction if product_code == "R5230P"
gen aux_CO2_emission_factor = CO2_emission_factor if product_code == "R5210P"
egen aux_1_CO2_emission_factor = max(aux_CO2_emission_factor)
replace CO2_emission_factor = aux_1_CO2_emission_factor if product_code == "R5230P"
gen aux_CC = CC if product_code == "R5210P"
egen aux_1_CC = max(aux_CC)
replace CC = aux_1_CC if product_code == "R5230P"
drop aux*

// Blended biofuels (Normally the fraction of biofuels in the mix is between 25% and 2%, we will use a mix of 10% in this analysis for simplification)
// Blended biogasoline
set obs `=scalar(_N+1)'
replace product_code = "R5210B" if _n == _N
replace fuel = "Blended biogasoline "	if _n == _N
gen aux_NCV = NCV if product_code == "R5210P"
egen aux_1_NCV = max(aux_NCV)
gen aux_2_NCV = NCV if product_code == "O4652XR5210B"
egen aux_3_NCV = max(aux_2_NCV)
replace NCV = 0.1*aux_1_NCV + 0.9*aux_3_NCV if product_code == "R5210B"
gen aux_ox_fraction = ox_fraction if product_code == "R5210P"
egen aux_1_ox_fraction = max(aux_ox_fraction)
gen aux_2_ox_fraction = ox_fraction if product_code == "O4652XR5210B"
egen aux_3_ox_fraction = max(aux_2_ox_fraction)
replace ox_fraction = 0.1*aux_1_ox_fraction + 0.9*aux_3_ox_fraction if product_code == "R5210B"
gen aux_CO2_emission_factor = CO2_emission_factor if product_code == "R5210P"
egen aux_1_CO2_emission_factor = max(aux_CO2_emission_factor)
gen aux_2_CO2_emission_factor = CO2_emission_factor if product_code == "O4652XR5210B"
egen aux_3_CO2_emission_factor = max(aux_2_CO2_emission_factor)
replace CO2_emission_factor = 0.1*aux_1_CO2_emission_factor + 0.9*aux_3_CO2_emission_factor if product_code == "R5210B"
gen aux_CC = CC if product_code == "R5210P"
egen aux_1_CC = max(aux_CC)
gen aux_2_CC = CC if product_code == "O4652XR5210B"
egen aux_3_CC = max(aux_2_CC)
replace CC = 0.1*aux_1_CC + 0.9*aux_3_CC if product_code == "R5210B"
drop aux*

// Blended biodiesel
set obs `=scalar(_N+1)'
replace product_code = "R5220B" if _n == _N
replace fuel = "Blended biodiesels "	if _n == _N
gen aux_NCV = NCV if product_code == "R5220P"
egen aux_1_NCV = max(aux_NCV)
gen aux_2_NCV = NCV if product_code == "O4671XR5220B"
egen aux_3_NCV = max(aux_2_NCV)
replace NCV = 0.1*aux_1_NCV + 0.9*aux_3_NCV if product_code == "R5220B"
gen aux_ox_fraction = ox_fraction if product_code == "R5220P"
egen aux_1_ox_fraction = max(aux_ox_fraction)
gen aux_2_ox_fraction = ox_fraction if product_code == "O4671XR5220B"
egen aux_3_ox_fraction = max(aux_2_ox_fraction)
replace ox_fraction = 0.1*aux_1_ox_fraction + 0.9*aux_3_ox_fraction if product_code == "R5220B"
gen aux_CO2_emission_factor = CO2_emission_factor if product_code == "R5220P"
egen aux_1_CO2_emission_factor = max(aux_CO2_emission_factor)
gen aux_2_CO2_emission_factor = CO2_emission_factor if product_code == "O4671XR5220B"
egen aux_3_CO2_emission_factor = max(aux_2_CO2_emission_factor)
replace CO2_emission_factor = 0.1*aux_1_CO2_emission_factor + 0.9*aux_3_CO2_emission_factor if product_code == "R5220B"
gen aux_CC = CC if product_code == "R5220P"
egen aux_1_CC = max(aux_CC)
gen aux_2_CC = CC if product_code == "O4671XR5220B"
egen aux_3_CC = max(aux_2_CC)
replace CC = 0.1*aux_1_CC + 0.9*aux_3_CC if product_code == "R5220B"
drop aux*

// Blended bio jet kerosene
set obs `=scalar(_N+1)'
replace product_code = "R5230B" if _n == _N
replace fuel = "Blended bio jet kerosene "	if _n == _N
gen aux_NCV = NCV if product_code == "R5230P"
egen aux_1_NCV = max(aux_NCV)
gen aux_2_NCV = NCV if product_code == "O4661XR5230B"
egen aux_3_NCV = max(aux_2_NCV)
replace NCV = 0.1*aux_1_NCV + 0.9*aux_3_NCV if product_code == "R5230B"
gen aux_ox_fraction = ox_fraction if product_code == "R5230P"
egen aux_1_ox_fraction = max(aux_ox_fraction)
gen aux_2_ox_fraction = ox_fraction if product_code == "O4661XR5230B"
egen aux_3_ox_fraction = max(aux_2_ox_fraction)
replace ox_fraction = 0.1*aux_1_ox_fraction + 0.9*aux_3_ox_fraction if product_code == "R5230B"
gen aux_CO2_emission_factor = CO2_emission_factor if product_code == "R5230P"
egen aux_1_CO2_emission_factor = max(aux_CO2_emission_factor)
gen aux_2_CO2_emission_factor = CO2_emission_factor if product_code == "O4661XR5230B"
egen aux_3_CO2_emission_factor = max(aux_2_CO2_emission_factor)
replace CO2_emission_factor = 0.1*aux_1_CO2_emission_factor + 0.9*aux_3_CO2_emission_factor if product_code == "R5230B"
gen aux_CC = CC if product_code == "R5230P"
egen aux_1_CC = max(aux_CC)
gen aux_2_CC = CC if product_code == "O4661XR5230B"
egen aux_3_CC = max(aux_2_CC)
replace CC = 0.1*aux_1_CC + 0.9*aux_3_CC if product_code == "R5230B"
drop aux*

// Drop category with no match
drop if product_code == ""

// Save
rename fuel product_IPCC
save "$dataPath\IPCC_Emission_Factors.dta", replace

********************************************************************************
// BLOCK C: Match Eurostat Energy Balances and IPCC Emission Factors
********************************************************************************
use "$dataPath\Energy_Balances_Eurostat.dta", clear
merge m:m product_code using "$dataPath\IPCC_Emission_Factors.dta"
drop _merge
replace CC = 0 if product_IPCC == "" & product_id != .
replace CO2_emission_factor = 0 if product_IPCC == "" & product_id != .
// Save dataset with complete balance with emission factors
order year geo product product_code product_id product_group product_group_code NCV ox_fraction CO2_emission_factor CC
sort year geo product_group_code product_id
drop product_IPCC
save "$dataPath\Energy_Balances_Eurostat_IPCC_Emission_Factor.dta", replace
erase "$dataPath\Energy_Balances_Eurostat.dta"
erase "$dataPath\IPCC_Emission_Factors.dta"


timer off 1
timer list 1
dis "Computing time of routine 1: " round(r(t1)/60, 0.1) " minutes"

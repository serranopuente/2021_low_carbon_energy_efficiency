/*
Are We Moving Towards A Low-Carbon Energy-Efficient Economy?
A Decomposition of Energy-Related CO2 Emissions in Spain and EU28, 1995-2017
19. Figure of Total Annual LMDI decomposition of energy-related CO2 emissions
Darío Serrano Puente (2020)

Last update: November 12th, 2020
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
// grstyle set legend 11, inside nobox

********************************************************************************
// 1. Import data
********************************************************************************
// 1.1 Energy-related CO2 estimated emissions, KPEQ, KC, and FEC
use "$dataPath\Estimates_Energy-Related_CO2.dta", clear
keep year geo CO2_TOT_Tot
duplicates drop year geo, force
sort geo year
save "$dataPath\Intermediate.dta", replace
// 1.2 Decomposition results
import excel "$tablePath\CO2_decomp.xlsx", sheet("Total") firstrow clear
keep if sector == "TOT"
merge 1:1 year geo using "$dataPath\Intermediate.dta"
drop _merge
erase "$dataPath\Intermediate.dta"

********************************************************************************
// 2. Compute Additive Evolution
********************************************************************************
sort geo year
foreach var in delta_CO2_actual delta_CO2_decomp delta_pop delta_inc delta_soc ///
delta_com delta_str delta_intr delta_out delta_eff delta_use delta_cli delta_mix ///
delta_peq delta_emi{
gen cum_`var' = 0
replace cum_`var' = CO2_TOT_Tot if year == 1995
}
foreach var in delta_agri delta_ind delta_ind_eei delta_cps delta_hh delta_hh_sh ///
delta_tra_pass delta_tra_fr{
gen cum_`var'_sec = 0
replace cum_`var'_sec = CO2_TOT_Tot if year == 1995
}
forvalues y = 1996(1)2017{
foreach var in delta_CO2_actual delta_CO2_decomp delta_pop delta_inc delta_soc ///
delta_com delta_str delta_intr delta_out delta_eff delta_use delta_cli delta_mix ///
delta_peq delta_emi{
replace cum_`var' = cum_`var'[_n-1] + `var'[_n] if year == `y'
}
}
forvalues y = 1996(1)2017{
foreach var in delta_agri delta_ind delta_ind_eei delta_cps delta_hh delta_hh_sh ///
delta_tra_pass delta_tra_fr{
replace cum_`var'_sec = cum_`var'_sec[_n-1] + `var'[_n] if year == `y'
}
}
foreach var in delta_CO2_actual delta_CO2_decomp delta_pop delta_inc delta_soc ///
delta_com delta_str delta_intr delta_out delta_eff delta_use delta_cli delta_mix ///
delta_peq delta_emi{
gen base_`var' = cum_`var' if year == 1995
bysort geo: replace base_`var' = base_`var'[1]
gen cum_`var'_index = cum_`var'/base_`var'*100
drop base*
}
foreach var in delta_agri delta_ind delta_ind_eei delta_cps delta_hh delta_hh_sh ///
delta_tra_pass delta_tra_fr{
gen base_`var' = cum_`var'_sec if year == 1995
bysort geo: replace base_`var' = base_`var'[1]
gen cum_`var'_index = cum_`var'_sec/base_`var'*100
drop base*
}

********************************************************************************
// 3. Figure
********************************************************************************
keep year geo cum*index
sort geo year
local geo `" "EU28" "ES" "'
foreach g of local geo{
// A
qui twoway (line cum_delta_CO2_actual_index year if geo == "`g'", lcolor("0 64 129") lwidth(medthick) lpattern("---")) ///
(line cum_delta_pop_index year if geo == "`g'", lcolor("218 108 122") lwidth(medthick)) ///
(line cum_delta_inc_index year if geo == "`g'", lcolor("255 190 93") lwidth(medthick)) ///
(line cum_delta_soc_index year if geo == "`g'", lcolor("26 140 255") lwidth(medthick)) ///
(line cum_delta_com_index year if geo == "`g'", lcolor("145 218 145") lwidth(medthick)) ///
(line cum_delta_cli_index year if geo == "`g'", lcolor("183 143 117") lwidth(medthick)), ///
xtitle("", size(medium)) ylabel(80 100 140 120 160, labsize(medlarge)) ytitle("Index (base 1995)", size(medium)) xlabel(1995 1998 2001 2004 2007 2010 2013 2017, labsize(medlarge)) ///
yline(100, lcolor(black) lwidth(medium) lpattern("--")) xline(2007, lcolor(black) lwidth(medium) lpattern("--")) ///
plotregion(fcolor(white) lcolor(black)) graphregion(fcolor(white) ifcolor(white) color(white) icolor(white)) bgcolor(white) ///
legend(order(1 "Actual" 2 "Population" 3 "Income per capita" 4 "Social factors" 5 "Comfort factors" 6 "Weather") rows(3) region(lstyle(none)) size(medlarge) region(lwidth(none)))
graph export "$LaTeXPath\Evo_decomp_`g'_1.pdf", as (pdf) replace
// B
qui twoway (line cum_delta_CO2_actual_index year if geo == "`g'", lcolor("0 64 129") lwidth(medthick) lpattern("---")) ///
(line cum_delta_str_index year if geo == "`g'", lcolor("218 108 122") lwidth(medthick)) ///
(line cum_delta_intr_index year if geo == "`g'", lcolor("255 190 93") lwidth(medthick)) ///
(line cum_delta_out_index year if geo == "`g'", lcolor("26 140 255") lwidth(medthick)) ///
(line cum_delta_eff_index year if geo == "`g'", lcolor("145 218 145") lwidth(medthick)), ///
xtitle("", size(medium)) ylabel(80 100 140 120 160, labsize(medlarge)) ytitle("Index (base 1995)", size(medium)) xlabel(1995 1998 2001 2004 2007 2010 2013 2017, labsize(medlarge)) ///
yline(100, lcolor(black) lwidth(medium) lpattern("--")) xline(2007, lcolor(black) lwidth(medium) lpattern("--")) ///
plotregion(fcolor(white) lcolor(black)) graphregion(fcolor(white) ifcolor(white) color(white) icolor(white)) bgcolor(white) ///
legend(order(1 "Actual" 2 "Structure" 3 "Intra-structure" 4 "Monetary-to-physical" 5 "End-use efficiency") rows(3) region(lstyle(none)) size(medlarge) region(lwidth(none)))
graph export "$LaTeXPath\Evo_decomp_`g'_2.pdf", as (pdf) replace
// C
qui twoway (line cum_delta_CO2_actual_index year if geo == "`g'", lcolor("0 64 129") lwidth(medthick) lpattern("---")) ///
(line cum_delta_use_index year if geo == "`g'", lcolor("218 108 122") lwidth(medthick)) ///
(line cum_delta_mix_index year if geo == "`g'", lcolor("255 190 93") lwidth(medthick)) ///
(line cum_delta_peq_index year if geo == "`g'", lcolor("26 140 255") lwidth(medthick)) ///
(line cum_delta_emi_index year if geo == "`g'", lcolor("145 218 145") lwidth(medthick)), ///
xtitle("", size(medium)) ylabel(80 100 140 120 160, labsize(medlarge)) ytitle("Index (base 1995)", size(medium)) xlabel(1995 1998 2001 2004 2007 2010 2013 2017, labsize(medlarge)) ///
yline(100, lcolor(black) lwidth(medium) lpattern("--")) xline(2007, lcolor(black) lwidth(medium) lpattern("--")) ///
plotregion(fcolor(white) lcolor(black)) graphregion(fcolor(white) ifcolor(white) color(white) icolor(white)) bgcolor(white) ///
legend(order(1 "Actual" 2 "End-use type shifts" 3 "Final energy mix" 4 "Efficiency of transf." 5 "Primary low-carbon sources") rows(3) region(lstyle(none)) size(medlarge) region(lwidth(none)))
graph export "$LaTeXPath\Evo_decomp_`g'_3.pdf", as (pdf) replace
// Sectors
qui twoway (line cum_delta_CO2_actual_index year if geo == "`g'", lcolor("0 64 129") lwidth(medthick) lpattern("---")) ///
(line cum_delta_agri_index year if geo == "`g'", lcolor("218 108 122") lwidth(medthick)) ///
(line cum_delta_ind_index year if geo == "`g'", lcolor("255 190 93") lwidth(medthick)) ///
(line cum_delta_cps_index year if geo == "`g'", lcolor("26 140 255") lwidth(medthick)) ///
(line cum_delta_hh_index year if geo == "`g'", lcolor("145 218 145") lwidth(medthick)) ///
(line cum_delta_tra_pass_index year if geo == "`g'", lcolor("59 255 245") lwidth(medthick)) ///
(line cum_delta_tra_fr_index year if geo == "`g'", lcolor("183 143 117") lwidth(medthick)), ///
xtitle("", size(medium)) ylabel(80 100 140 120 160, labsize(medlarge)) ytitle("Index (base 1995)", size(medium)) xlabel(1995 1998 2001 2004 2007 2010 2013 2017, labsize(medlarge)) ///
yline(100, lcolor(black) lwidth(medium) lpattern("--")) xline(2007, lcolor(black) lwidth(medium) lpattern("--")) ///
plotregion(fcolor(white) lcolor(black)) graphregion(fcolor(white) ifcolor(white) color(white) icolor(white)) bgcolor(white) ///
legend(order(1 "Actual" 2 "Agriculture" 3 "Industry" 4 "Services" 5 "Households" 6 "Passenger transp." 7 "Freight transp.") rows(4) region(lstyle(none)) size(medlarge) region(lwidth(none)))
graph export "$LaTeXPath\Evo_decomp_`g'_sec.pdf", as (pdf) replace
}


timer off 1
timer list 1
dis "Computing time of routine 1: " round(r(t1)/60, 0.1) " minutes"

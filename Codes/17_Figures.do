/*
Are We Moving Towards A Low-Carbon Energy-Efficient Economy?
A Decomposition of Energy-Related CO2 Emissions in Spain and EU28, 1995-2017
17. Figure Targets
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
// Install if not yet installed
/*
ssc install spmap
ssc install shp2dta
ssc install mif2dta
*/
grstyle init
grstyle set plain, horizontal grid

********************************************************************************
// 1. Targets
********************************************************************************
import excel "$dataPath\Targets 2020\Targets2020.xlsx", sheet("Sheet1") firstrow clear
foreach var in ghg primary{
gen cump_`var' = 100 - (`var' - `var'_target)/`var'_target*100
}
foreach var in share{
gen cump_`var' = 100 - (`var'_target - `var')/`var'_target*100
}
// 2.1 Greenhouse gas emissions
qui twoway (line cump_ghg year if geo == "Spain" & year >= 2005, mcolor("163 41 56") lwidth(thick)) ///
(line cump_ghg year if geo == "EU28" & year >= 2005, mcolor("0 64 129") lwidth(thick) lpattern("---")), ///
ytitle("% of Target Compliance",size(vlarge) margin(vsmall)) xtitle("", margin(medium) size(vsmall)) xlabel(2005 2007 2009 2011 2013 2015 2017, labgap(*3) angle(0) noticks labsize(vlarge)) ylabel(40 60 80 100 120,labsize(vlarge)) ///
yline(100, lcolor(black) lwidth(medium) lpattern("--")) leg(off) ///
plotregion(fcolor(white) lcolor(black)) graphregion(fcolor(white) ifcolor(white) color(white) icolor(white)) bgcolor(white) 
graph export "$LaTeXPath\Target_ghg_cump.pdf", as (pdf) replace
// 2.2 Primary energy
qui twoway (line cump_primary year if geo == "Spain" & year >= 2005, mcolor("163 41 56") lwidth(thick)) ///
(line cump_primary year if geo == "EU28" & year >= 2005, mcolor("0 64 129") lwidth(thick) lpattern("---")), ///
ytitle("",size(large) margin(vsmall)) xtitle("", margin(medium) size(vsmall)) xlabel(2005 2007 2009 2011 2013 2015 2017, labgap(*3) angle(0) noticks labsize(vlarge)) ylabel(40 60 80 100 120,labsize(vlarge)) ///
yline(100, lcolor(black) lwidth(medium) lpattern("--")) ///
legend(order(1 "Spain" 2 "EU28") rows(1) ring(0) position(6) region(lstyle(none)) size(vlarge) region(lwidth(none))) ///
plotregion(fcolor(white) lcolor(black)) graphregion(fcolor(white) ifcolor(white) color(white) icolor(white)) bgcolor(white) 
graph export "$LaTeXPath\Target_primary_cump.pdf", as (pdf) replace
// 2.3 Primary energy
qui twoway (line cump_share year if geo == "Spain" & year >= 2005, mcolor("163 41 56") lwidth(thick)) ///
(line cump_share year if geo == "EU28" & year >= 2005, mcolor("0 64 129") lwidth(thick) lpattern("---")), ///
ytitle("",size(large) margin(vsmall)) xtitle("", margin(medium) size(vsmall)) xlabel(2005 2007 2009 2011 2013 2015 2017, labgap(*3) angle(0) noticks labsize(vlarge)) ylabel(40 60 80 100 120,labsize(vlarge)) ///
yline(100, lcolor(black) lwidth(medium) lpattern("--")) leg(off) ///
plotregion(fcolor(white) lcolor(black)) graphregion(fcolor(white) ifcolor(white) color(white) icolor(white)) bgcolor(white) 
graph export "$LaTeXPath\Target_share_cump.pdf", as (pdf) replace

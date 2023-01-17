/*
Are We Moving Towards A Low-Carbon Energy-Efficient Economy?
A Decomposition of Energy-Related CO2 Emissions in Spain and EU28, 1995-2017
Refresh all do-files.
Darío Serrano Puente (2020)

Last update: May 29th, 2020
*/


********************************************************************************
// 0. Preamble
********************************************************************************
clear all
set more off

// Define input/output directories
// global basePath "X:\Dga_EI\AEstructural\Climate change\Low Carbon Energy Efficiency"
global basePath "C:\Users\Pc\Google Drive\Research\Climate Change\Low Carbon Energy Efficiency"
global figurePath "$basePath\Figures"
global dataPath "$basePath\Data"
global codePath "$basePath\Codes"
global tablePath "$basePath\Tables"
global LaTeXPath "$basePath\Paper\Figures"

// Change working directory
cd "$codePath"

********************************************************************************
// 1. Execute all do-files contained in the Code subfolder
********************************************************************************
timer clear 1
timer on 1
local files : dir "$codePath" files "*.do"
local i = 1
foreach file in `files' {
  if `i' == 1{
	cls
	dis "Initializing codes for 'Are We Moving Towards A Low-Carbon Energy-Efficient Economy?' - Darío Serrano Puente (2020)"
  }
  
  dis "Running `file'. Do-file `i' out of 18"
  qui do "`file'"
  // dis "Computing time of routine `i': " round(r(t1)/60, 0.1) " minutes"
  // Return to working directory
  qui cd "$codePath"
    if `i' == 17{
	dis "End of 'Are We Moving Towards A Low-Carbon Energy-Efficient Economy?' - Darío Serrano Puente (2020)"
  }
    qui local i = `i' + 1
}



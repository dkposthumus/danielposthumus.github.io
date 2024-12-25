/*
capture log close
log using 02_graphics, replace text
*/

/*
  program:    	02_graphics.do
  task:			To create basic time-series graphics.
  
  project:		Bond Yield Decomposition - Dynamic Term Structural Models (DTSM), Approaches and 
				Challenges
  author:     	Daniel_Posthumus \ 21Jan2024
*/

version 17
clear all
set linesize 80
macro drop _all

****************************************************************************************Set Global Macros              ****************************************************************************************
global workspace "~/danielposthumus.github.io/_portfolio/dtsm-review_2024"
	global graphics "$workspace/graphics"
	global code "$workspace/code"
	global data "$workspace/data"
****************************************************************************************Create Basic Time-Series Graph       ****************************************************************************************
* Let's begin by ensuring we run our data_import do-file first:
cd $code
	do 01_data_import
* Now let's import the updated master data.
cd $data
	use master, clear
cd $graphics
* First, let's just plot a basic time-series with all of our term premia:
tsline fit_prem_01 fit_prem_03 fit_prem_05 fit_prem_10, ytitle("Percent") xtitle("") tlabel(, format(%tdCY)) legend(label(1 "1-Year") label(2 "3-Year") label(3 "5-Year") label(4 "10-Year"))
	graph export term_premia.png, replace
* Next, let's plot the decomposition of our 3-year bond, incorporating 3 time-series: 1) the basic yield, 2) the expected short rate, and the term premium.: 
tsline _3_yr eshort_03 fit_prem_03, ytitle("Percent") xtitle("") tlabel(, format(%tdCY)) legend(label(1 "3-Year Treasury Bond Yield") label(2 "Expected 3-Year Short Rate") label(3 "3-Year Term Premium"))
	graph export 03_decomp.png, replace
* Now let's do the same thing for the 10-year bond:
tsline _10_yr eshort_10 fit_prem_10, ytitle("Percent") xtitle("") tlabel(, format(%tdCY)) legend(label(1 "10-Year Treasury Bond Yield") label(2 "Expected 10-Year Short Rate") label(3 "10-Year Term Premium"))
	graph export 10_decomp.png, replace
/*
log close
exit
*/
	
	
	
	
	
	
	
	
	
	
	
	
/*
capture log close
log using 01_sum_graph, replace text
*/

/*
  program:    	01_sum_graph.do
  task:			Create summary graphs introducing data nd motivating the project.
  
  project:		The Pass-Through of Changes in Monetary Policy to Borrowing Costs
  author:     	Daniel_Posthumus \ 10Jan2024
*/

version 17
clear all
set linesize 80
macro drop _all

*******************************************************************************************Set Global Macros              *******************************************************************************************

global project "~/danielposthumus.github.io/_portfolio/pass-through_2022"
global code "$project/code"
global data "$project/data"
global output "$project"

*******************************************************************************************Create basic time-series graphs         *******************************************************************************************

cd $data 
use master_daily, clear

local begin_year = 1995
local end_year = 2022
	keep if inrange(year,`begin_year',`end_year')

tsline corp_aaa mort30 _3_yr _10_yr shadow_rate, tlabel(, format(%tdCY)) title("Interest Rates") ytitle("Percent") xtitle("Time") legend(label(1 "Corporate Bond (aaa)") label(2 "30-Year Mortgage") label(3 "3-Year Treasury") label(4 "10-Year Treasury") label(5 "Shadow Fed Funds")) tline(420 753)
	graph export "$output/all_rates.png", replace

preserve 

	foreach v in corp_aaa mort30 _3_yr _10_yr shadow_rate {
			regress `v' date
			predict `v'_fit, xb
		gen `v'_detrend = `v' - `v'_fit
	}	
	tsline corp_aaa_detrend mort30_detrend _3_yr_detrend _10_yr_detrend shadow_rate_detrend, tlabel(, format(%tdCY)) title("Detrended Interest Rates") ytitle("Percent") xtitle("Time") legend(label(1 "Corporate Bond (aaa)") label(2 "30-Year Mortgage") label(3 "3-Year Treasury") label(4 "10-Year Treasury") label(5 "Shadow Fed Funds")) tline(420 753)
		graph export "$output/detrend.png", replace
restore

graph matrix news_shock shock_e_effr target path, title("Monetary Policy Shocks") ms(p)

twoway line shadow_rate date || bar path date || bar target date, xtitle("Time") ytitle("Percent") title("Shadow Fed Funds and" "Monetary Policy Shocks") legend(label(1 "Shadow Rate") label(2 "Rate Path Shocks") label(3 "Target Rate Shocks")) xlabel(, format(%tdCY))
	graph export "$output/shocks_time.png", replace
	
	twoway line shadow_rate date || bar target date
	
	
tsline fed_funds _3_month _5_yr bank_loan, title("Four Indicators of US Financial Economy") tlabel(, format(%tdCY)) ytitle("Percent") xtitle("Time") legend(label(1 "Lower Fed Funds") label(2 "3-Month Treasury") label(3 "5-Year Treasury") label(4 "Bank Loan Rate")) tline(420 753)
	graph export "$output/svar_intro.png", replace
	
preserve 

	foreach v in fed_funds _3_month _5_yr bank_loan {
		regress `v' date
		predict `v'_fit, xb
		gen `v'_detrend = `v' - `v'_fit 
	}
	tsline fed_funds_detrend _3_month_detrend _5_yr_detrend bank_loan_detrend, title("Detrended Sub-Market Rates") tlabel(, format(%tdCY)) ytitle("Percent") xtitle("Time") legend(label(1 "Lower Fed Funds") label(2 "3-Month Treasury") label(3 "5-Year Treasury") label(4 "Bank Loan Rate")) tline(420 753)
		graph export "$output/svar_detrend.png", replace
	qui tsline fed_funds _3_month _5_yr bank_loan fed_funds_fit _3_month_fit _5_yr_fit bank_loan_fit
restore
	
*******************************************************************************************Create Scatterplots          *******************************************************************************************

graph matrix shadow_rate _10_yr corp_aaa mort30, title("Borrowing Costs") ms(p)
	graph export "$output/matrix_graph.png", replace

	



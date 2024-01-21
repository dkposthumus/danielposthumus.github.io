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
global project "~/danielposthumus.github.io/_portfolio/pass-through_2024"
	global code "$project/code"
	global data "$project/data"
	global output "$project/graphics"
*******************************************************************************************Create basic time-series graphs for OLS analysis         *******************************************************************************************
cd $data 
use master_daily, clear
* Let's begin by restricting our time-values based on our selected sample, from 1995 to 2022 -- due to the availability of our selected data. 
local begin_year = 1995
local end_year = 2022
	keep if inrange(year,`begin_year',`end_year')
* Let's begin with a basic graph portraying the time-series patterns of our core borrowing costs of interest -- 1) corporate bond yields, 2) 30-year mortgage rates, 3) 3-year treasury bond yields, and 4) 10-year treasury bond yields.
tsline corp_aaa mort30 _3_yr _10_yr shadow_rate, tlabel(, format(%tdCY)) title("Borrowing Costs Over Time") ytitle("Percent") xtitle("") legend(label(1 "Corporate Bond (aaa)") label(2 "30-Year Mortgage") label(3 "3-Year Treasury") label(4 "10-Year Treasury") label(5 "Shadow Fed Funds") size(small)) tline(420 753)
	graph export "$output/all_rates.png", replace
preserve 
* From this time-series, we immediately notice a pre-COVID long-term downward trend of borrowing costs--reflecting a common idea in economics of the long-term decrease in the 'natural interest rate'. We want to then create a basic linear trend--by regressing date on each interest rate--and detrend by subracting actualy values from the values predicted by this basic linear regression.
	foreach v in corp_aaa mort30 _3_yr _10_yr shadow_rate {
			regress `v' date
			predict `v'_fit, xb
		gen `v'_detrend = `v' - `v'_fit
	}	
* Now let's plot these de-trended data.
	tsline corp_aaa_detrend mort30_detrend _3_yr_detrend _10_yr_detrend shadow_rate_detrend, tlabel(, format(%tdCY)) title("Detrended Interest Rates") ytitle("Percent") xtitle("") legend(label(1 "Corporate Bond (aaa)") label(2 "30-Year Mortgage") label(3 "3-Year Treasury") label(4 "10-Year Treasury") label(5 "Shadow Fed Funds") size(small)) tline(420 753)
			* Just as we expected--there is MORE stationarity in our data now, although 
			* it's clearly not entirely stationary.
		graph export "$output/detrend.png", replace
restore
* Next, let's create a total graph, which will contain the following elements: 1) a time-series line of the shadow rate, 2) a vertical bar graph of monetary policy rate path shocks, and 3) a vertical bar graph of monetary policy target rate shocks.
twoway line shadow_rate date || bar path date || bar target date, xtitle("") ytitle("Percent") title("Shadow Fed Funds and" "Monetary Policy Shocks") legend(label(1 "Shadow Rate") label(2 "Rate Path Shocks") label(3 "Target Rate Shocks") size(small)) xlabel(, format(%tdCY))
	graph export "$output/shocks_time.png", replace
*******************************************************************************************Create basic time-series graphs for VAR Methods         *******************************************************************************************
* We also want to prepare graphs for the section of the paper about our Structural VAR model -- so, to begin, let's prepare a basic time-series capturing our four sub-market rates of interest: 1) the federal funds rate, 2) the 3-month US Treasury Bill yield, 3) the 5-year US Treasury Bond yield, and 4) the bank loan interest rate. 
tsline fed_funds _3_month _5_yr bank_loan, title("Four Indicators of the US Financial Economy") tlabel(, format(%tdCY)) ytitle("Percent") xtitle("") legend(label(1 "Lower Fed Funds") label(2 "3-Month Treasury") label(3 "5-Year Treasury") label(4 "Bank Loan Rate") size(small)) tline(420 753)
	graph export "$output/svar_intro.png", replace
* Let's repeat the same loop we ran for our OLS analysis, this time creating de-trended observations of these four sub-market rates.
preserve 
	foreach v in fed_funds _3_month _5_yr bank_loan {
		regress `v' date
		predict `v'_fit, xb
		gen `v'_detrend = `v' - `v'_fit 
	}
* Now let's plot these detrended values over time in a basic time-series graph.
	tsline fed_funds_detrend _3_month_detrend _5_yr_detrend bank_loan_detrend, title("Detrended Sub-Market Rates") tlabel(, format(%tdCY)) ytitle("Percent") xtitle("") legend(label(1 "Lower Fed Funds") label(2 "3-Month Treasury") label(3 "5-Year Treasury") label(4 "Bank Loan Rate") size(small)) tline(420 753)
		graph export "$output/svar_detrend.png", replace
restore
*******************************************************************************************Create Scatterplots          *******************************************************************************************
* To begin, let's create a basic scatterplot matrix of our borrowing costs of interest to parse out any general correlations. Before plotting these scatterplots, let's do a quick preserve/restore w/re-labeling our variables concisely for graphing purposes.
preserve 
	label var shadow_rate "Shadow Rate"
	label var _10_yr "Treasury 10-Year Yield"
	label var corp_aaa "Corp. Bond Yield"
	label var mort30 "30-Yr Mortgage Rate"
		graph matrix shadow_rate _10_yr corp_aaa mort30, title("Correlations Between Borrowing Costs") ms(p) half
			graph export "$output/matrix_graph.png", replace
restore 
* In our data we also have four time-series of monetary policy shocks -- let's try to figure out the relationship between these shocks by graphing a basic matrix scatterplot. Let's run a quick preserve/restore so we can label our variables concisely:
preserve 
	label var news_shock "News Shock"
	label var shock_e_effr "EFFR Shock"
	label var target "Target Rate Shock"
	label var path "Rate Path Shock"
		graph matrix news_shock shock_e_effr target path, title("Correlations Between Different" "Monetary Policy Shocks") ms(p) half
restore

	
/*
log close
exit
*/


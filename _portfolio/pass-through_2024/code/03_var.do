/*
capture log close
log using 03_var, replace text
*/

/*
  program:    	03_var.do
  task:			To run vector auto-regression (VAR) and structural VARs for project.
  
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
global output $project

*******************************************************************************************Create basic time-series graphs         *******************************************************************************************

cd $data
use master_monthly, clear

keep date fed_funds _3_month _5_yr bank_loan target path shadow_rate

local begin_time = 420
local end_time = 753
	keep if inrange(date,`begin_time',`end_time')

	foreach v in fed_funds _3_month _5_yr bank_loan {
		regress `v' date
		predict `v'_fit, xb
		gen `v'_detrend = `v' - `v'_fit 
		gen `v'_chg = D.`v'
	}
	
	collect clear
collect: varsoc _5_yr_chg _3_month_chg bank_loan_chg fed_funds_chg
collect layout (rowname[r2 r3 r4 r1]) (colname[AIC SBIC LL LR])
collect label levels rowname r1 "k = 4" r2 "k = 1" r3 "k = 2" r4 "k = 3", replace
collect style cell colname, nformat(%7.3f)
collect title "Specification of the VAR"
collect preview
collect export "$output/var_specification.tex", tableonly replace


qui ac fed_funds_chg, title("Fed Funds (Diff) Auto-Correlation Plot") name(fed_funds_diff) ytitle("")
qui ac _3_month_chg, title("3-Month T-Bill (Diff) Auto-Correlation Plot") name(_3_month_diff) ytitle("")
qui ac _5_yr_chg, title("5-Year T-Bond (Diff) Auto-Correlation Plot") name(_5_yr_diff) ytitle("")
qui ac bank_loan_chg, title("Bank Loan (Diff) Auto-Correlation Plot") name(bank_loan_diff) ytitle("")
	graph combine fed_funds_diff _3_month_diff _5_yr_diff bank_loan_diff
		graph export "$output/var_ac_diff.png", replace
	
qui ac fed_funds, title("Fed Funds Auto-Correlation Plot") name(fed_funds) ytitle("")
qui ac _3_month, title("3-Month T-Bill Auto-Correlation Plot") name(_3_month) ytitle("")
qui ac _5_yr, title("5-Year T-Bond Auto-Correlation Plot") name(_5_yr) ytitle("")
qui ac bank_loan, title("Bank Loan Auto-Correlation Plot") name(bank_loan) ytitle("")
	graph combine fed_funds _3_month _5_yr bank_loan
		graph export "$output/var_ac.png", replace
	
	
var fed_funds_chg _3_month_chg _5_yr_chg bank_loan_chg, lags(2)
		irf create myirf, set(myirfs, replace)
	irf graph cirf
		graph export "$output/var_basic.png", replace
	
* Estimation of Wold Causal Chain
collect clear
collect: dfactor (_3_month _5_yr bank_loan = fed_funds, ar(2) arstructure(ltriangular)) 
collect layout (coleq#colname) (result[_r_b _r_se _r_p])
collect style cell result, nformat(%7.3f)
collect title "Wold Causal Chain Estimation Results"
	collect label levels drop coleq colname
collect preview
	collect export "$output/wold_estimates.tex", tableonly replace

	* Run SVAR with matrix of estimations identified by wold estimates output
matrix A = (1,0,0,0\-0.949,1,0,0\-0.426,0.167,1,0\-0.265,0.091,-0.137,1)
	svar fed_funds _3_month _5_yr bank_loan, aeq(A)
							irf set, clear
		irf create irf_svar, set(irf_svars, replace)
	irf graph cirf
		graph export "$output/svar_irf.png", replace
	
	* Now run the same process, but for shocks

	* Generate shock variable
		local _3_month "3-Month T-Bills"
		local bank_loan "Bank Loans"
		local fed_funds "Federal Funds"
		local _5_yr "5-Year T-Bonds"
	foreach v in _3_month _5_yr bank_loan fed_funds {
		collect clear
		collect: varsoc `v'_chg
		collect layout (rowname[r2 r3 r4 r1]) (colname[AIC SBIC LL LR])
		collect label levels rowname r1 "k = 4" r2 "k = 1" r3 "k = 2" r4 "k = 3", replace
		collect style cell colname, nformat(%7.3f)
		collect title "Specification of the VAR ``v''"
		collect preview
		collect export "$output/`v'_test.tex", tableonly replace
	}
	foreach v in _3_month bank_loan {
		var `v'_chg, lags(3)
			predict _var`v'_chg, xb
				gen `v'_shock = `v'_chg - _var`v'_chg
	}

	var fed_funds_chg, lags(3)
			predict _var_fed_funds_chg, xb
				gen fed_funds_shock = fed_funds_chg - _var_fed_funds_chg
	
	var _5_yr_chg, lags(1)
		predict _var_5_yr_chg, xb
			gen _5_yr_shock = _5_yr_chg - _var_5_yr_chg
	
	collect clear
	foreach v in fed_funds _3_month _5_yr bank_loan {
		collect: dfuller `v'_detrend, lags(2)
		collect: dfuller `v'_chg, lags(2)
		collect: dfuller `v'_shock
	}
	collect layout (cmdset) (result[Zt p])
		collect title "Dickey-Fuller Stationarity Test Results"
		collect style cell result, nformat(%7.2f)
		collect label levels cmdset 1 "Fed Funds" 2 "\quad Fed Funds (Diff)" 3 "\quad Fed Funds (Shock)" 4 "3-Month T-Bill" 5 "\quad 3-Month T-Bill (Diff)" 6 "\quad 3-Month T-Bill (Shock)" 7 "5-Year Bond" 8 "\quad 5-Year Bond (Diff)" 9 "\quad 5-Year Bond (Shock)" 10 "Bank Loan" 11 "\quad Bank Loan (Diff)" 12 "\quad Bank Loan (Shock)", replace
		collect label levels result Zt "Test Statistic" p "P-Value", replace
		collect preview
		collect export "$output/stationarity_test.tex", replace tableonly
	
	
	local _3_month_shock "3-Month T-Bills"
	local bank_loan_shock "Bank Loans"
	local fed_funds_shock "Federal Funds"
	local _5_yr_shock "5-Year T-Bonds"
	
tsline _3_month_shock bank_loan_shock fed_funds_shock _5_yr_shock
	foreach v in _3_month_shock bank_loan_shock fed_funds_shock _5_yr_shock {
	tsline `v', tlabel(, format(%tmCY)) name(`v', replace) ytitle("") title("``v''")
	}
	graph combine _3_month_shock bank_loan_shock _5_yr_shock fed_funds_shock, title("Rate Shocks")
		graph export "$output/shock_tsline.png", replace
		
	tsline fed_funds_shock fed_funds, title("Fed Funds, Shocks vs. Observed") ytitle("Percent") xtitle("Date") tlabel(, format(%tmCY)) legend(label(1 "Shock") label(2 "Observed"))
		graph export "$output/shock_obs.png", replace
		
	* Estimation of Wold Causal Chain w/shock variables
collect clear
collect: dfactor (_3_month_shock _5_yr_shock bank_loan_shock = fed_funds_shock, ar(2) arstructure(ltriangular)) 
matrix list e(b)
	local alpha e(b)[1,7]
		di `alpha'
	local beta e(b)[1,9]
		di `beta'
	local phi e(b)[1,2]
		di `phi'
	local rho e(b)[1,11]
		di `rho'
	local mu e(b)[1,4]
		di `mu'
	local gamma e(b)[1,5]
		di `gamma'
collect layout (coleq#colname) (result[_r_b _r_se _r_p])
collect style cell result, nformat(%7.3f)
collect title "Wold Causal Chain Estimation Results - Shocks"
	collect label levels drop coleq colname
collect preview
	collect export "$output/wold_estimates_shocks.tex", tableonly replace
matrix A = (1,0,0,0\-`alpha',1,0,0\-`beta',-`phi',1,0\-`rho',-`mu',-`gamma',1)
	svar fed_funds _3_month _5_yr bank_loan, aeq(A)
					irf set, clear
		irf create irf_svar_shock, set(irf_svar_shocks, replace)
	irf graph cirf, irf(irf_svar_shock)
		graph export "$output/irf_svar_shock.png", replace
	
tsline target fed_funds_shock, ytitle("Percent") xtitle("Date") tlabel(, format(%tmCY)) legend(label(1 "Acosta (2022) Shock")  label(2 "VAR-Generated Shock")) title("VAR-Generated Rate Shocks" "and Acosta (2022) Shocks")
	graph export "$output/shock_comparison.png", replace
	
/*
log close
exit
*/
	







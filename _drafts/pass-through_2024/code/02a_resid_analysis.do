/*
capture log close
log using 02a_resid_analysis, replace text
*/

/*
  program:    	02a_resid_analysis.do
  task:			To analyze residuals of basic regression specifications.
  
  project:		The Pass-Through of Changes in Monetary Policy to Borrowing Costs"
  author:     	Daniel_Posthumus \ 22Jan2024
*/

version 17
clear all
set linesize 80
macro drop _all

****************************************************************************************Set Global Macros              ****************************************************************************************
global project "~/danielposthumus.github.io/_portfolio/pass-through_2024"
	global code "$project/code"
	global data "$project/data"
	global output "$project/graphics"
****************************************************************************************Generate de-trended variables           ****************************************************************************************
cd $data
use master_monthly, clear
	* Let's begin w/restricting our sample -- we're only interested in keeping 
	* observations from 1995 to 2022:
		local begin_time = 420
		local end_time = 753
			keep if inrange(date,`begin_time',`end_time')
				* Let's then drop observations w/missing date values:
					drop if date == .
* Let's create a basic trend line by regressing the borrowing rates on date, and then detrended observations by subtracting the actual observations from the trend.
	foreach v in corp_aaa mort30 _3_yr _10_yr _3_month {
		regress `v' date 
			predict `v'_fit, xb
		gen `v'_detrend = `v' - `v'_fit
	}	
****************************************************************************************Residual plotting        ****************************************************************************************
* Before executing our regressions, let's create a local capturing the macro controls in use:
local macro_ctrls pce_infl lfpr housing_own_rate gdp_g unemployment vix_chg
* Let's run our basic regression specification from earlier, throwing in a lagged borrowing cost as an explanatory variable.
* Before doing so, let's set locals for graph labeling purposes:
	local _3_month "3-Month T-Bill"
	local _3_yr "3-Year T-Bond"
	local _10_yr "10-Year T-Bond"
	local mort30 "30-Year Mortgage"
	local corp_aaa "Corporate Bond"
foreach v in _3_month _3_yr _10_yr mort30 corp_aaa {
	qui regress `v'_detrend shadow_rate `macro_ctrls'
	predict `v'_hat_normal, xb
		label var `v'_hat_normal "``v'' (detrended predicted)"
	gen `v'_resid_normal = `v' - `v'_hat_normal
	hist `v'_resid_normal, percent name(`v'_resid_hist) nodraw xtitle("``v'' Residuals") normal
		label var `v'_resid_normal "``v'' residual"
}
graph combine _3_month_resid_hist _3_yr_resid_hist _10_yr_resid_hist mort30_resid_hist corp_aaa_resid_hist, title("Distributions of Residuals," "for Shadow Rate Regressions")
	graph export "$output/resid_normal_hist.png", replace
* Now let's plot a basic residual/explanatory variable plot (there should be no correlation):
foreach v in _3_month _3_yr _10_yr mort30 corp_aaa {
	tw (scatter shadow_rate `v'_detrend, msymbol(p)) (lfit shadow_rate `v'_detrend, lcolor(green) lwidth(thick)), xtitle("``v'' Residuals") ytitle("Shadow Rate") nodraw name(`v'_resid_scatter) yline(0) legend(off)
}
graph combine _3_month_resid_scatter _3_yr_resid_scatter _10_yr_resid_scatter mort30_resid_scatter corp_aaa_resid_scatter, title("Detrended Borrowing Cost Residuals," "And Shadow Rate")
	graph export "$output/resid_scatter.png", replace








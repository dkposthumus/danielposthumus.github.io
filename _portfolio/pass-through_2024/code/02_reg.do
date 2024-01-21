/*
capture log close
log using 03_reg, replace text
*/

/*
  program:    	02_reg.do
  task:			Run regression analyses for pass-through project.
  
  project:		The Pass-Through of Changes in Monetary Policy to Borrowing Costs"
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

*******************************************************************************************Run most basic regression analysis            *******************************************************************************************

cd $data
use master_monthly, clear

local begin_time = 420
local end_time = 753
	keep if inrange(date,`begin_time',`end_time')
	drop if date == .

	foreach v in corp_aaa mort30 _3_yr _10_yr {
		regress `v' date 
			predict `v'_fit, xb
		gen `v'_detrend = `v' - `v'_fit
	}	

collect clear
foreach v in _3_yr _10_yr mort30 corp_aaa {
	collect _r_b _r_se _r_p e(N), tag(model[`v']): qui regress `v' shadow_rate
	collect _r_b _r_se _r_p e(N), tag(model[`v'_macro]): qui regress `v' shadow_rate pce_infl lfpr housing_own_rate gdp_g unemployment vix_chg
		collect _r_b _r_se _r_p e(N), tag(model[`v'_detrend]): qui regress `v'_detrend shadow_rate
		collect _r_b _r_se _r_p e(N), tag(model[`v'_macro_detrend]): qui regress `v'_detrend shadow_rate pce_infl lfpr housing_own_rate gdp_g unemployment vix_chg
	foreach c in news_shock target path shock_e_effr {
		collect _r_b _r_se _r_p e(N), tag (model[`v'_macro]): qui regress d.`v' `c' d.pce_infl d.lfpr d.housing_own_rate gdp_g d.unemployment vix_chg
	}
}
collect layout  (model) (colname[shadow_rate target path]#result[_r_b])
collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach(_r_b)
		collect label levels colname shadow_rate "shadow rate", replace
		collect label levels model _3_yr "3-Year Treasury" _3_yr_macro "\quad 3-Year (Macro Controls)"  _10_yr "10-Year Treasury" _10_yr_macro "\quad 10-Year Treasury (Macro Controls)" mort30 "30-Year Mortgage" mort30_macro "\quad 30-Year Mortgage (Macro Controls)" corp_aaa "Corp. Bond" corp_aaa_macro "\quad Corp. Bond (Macro Controls)" _3_yr_detrend "3-Year Treasury (Detrended)" _3_yr_macro_detrend "\quad 3-Year Treasury (Detrended, Macro Controls)" _10_yr_detrend "10-Year Treasury (Detrended)" _10_yr_macro_detrend "\quad 10-Year Treasury (Detrended, Macro Controls)" mort30_detrend "\quad 30-Year Mortgage (Detrended)" mort30_macro_detrend "30-Year Mortgage (Detrended, Macro Controls)" corp_aaa_detrend "Corp. Bond (Detrended)" corp_aaa_macro_detrend "\quad Corp. Bond (Detrended, Macro Controls)", replace
		collect label levels colname shadow_rate "Shadow Rate" target "Target" path "Path", replace 
		collect label levels result _r_b " ", replace
		collect title "Basic Regression Results"
collect style cell result, nformat(%7.3f)
collect preview
	collect export "$output/reg_table.tex", replace tableonly
e
* Let's check our auto-correlations for our dependent variables:
* Create plots of auto-correlations
ac _3_month, title("3-Month T-Bill" "Auto-Correlations") name(_3_month_ac) lags(20)
pac _3_month, title("3-Month T-Bill" "Partial Auto-Correlations") name(_3_month_pac) lags(20)
	graph combine _3_month_pac _3_month_ac 
		graph export "$output/ac_3_month.png", replace
ac D._3_month, title("3-Month T-Bill" "First-Diff Auto-Correlations") name(d3_month_ac, replace) lags(20) 
pac D._3_month, title("3-Month T-Bill" "First-Diff Partial Auto-Correlations") name(d3_month_pac, replace) lags(20) 
	graph combine d3_month_pac d3_month_ac 
		graph export "$output/ac_d3_month.png", replace
ac _3_yr, title("3-Year T-Bond" "Auto-Correlations") name(_3_yr_ac) lags(20)
pac _3_yr, title("3-Year T-Bond" "Partial Auto-Correlations") name(_3_yr_pac) lags(20)
	graph combine _3_yr_pac _3_yr_ac 
		graph export "$output/ac_3_yr.png", replace
ac D._3_yr, title("3-Year T-Bond" "First-Diff Auto-Correlations") name(d3_yr_ac) lags(20)
pac D._3_yr, title("3-Year T-Bond" "First-Diff Partial Auto-Correlations") name(d3_yr_pac) lags(20)
	graph combine d3_yr_pac d3_yr_ac 
		graph export "$output/ac_d3_yr.png", replace
ac _10_yr, title("10-Year T-Bond" "Auto-Correlations") name(_10_yr_ac) lags(20)
pac _10_yr, title("10-year T-Bond" "Partial Auto-Correlations") name(_10_yr_pac) lags(20)
	graph combine _10_yr_pac _10_yr_ac 
		graph export "$output/ac_10_yr.png", replace
ac D._10_yr, title("10-Year T-Bond" "First-Diff Auto-Correlations") name(d10_yr_ac) lags(20)
pac D._10_yr, title("10-year T-Bond" "First-Diff Partial Auto-Correlations") name(d10_yr_pac) lags(20)
	graph combine d10_yr_pac d10_yr_ac 
		graph export "$output/ac_d10_yr.png", replace

/*
* Some playing around with smoothing 
tssmooth nl smooth_10 = _10_yr, smoother(3rssh)
	gen resid_10 = _10_yr - smooth_10
tssmooth nl smooth_3 = _3_yr, smoother(3rssh)
	gen resid_3 = _3_yr - smooth_3
			tsline resid_10 fund_change
			tsline resid_3 fund_change
				scatter resid_3 fund_change
				scatter resid_10 fund_change
regress resid_10 fund_change
regress resid_3 fund_change
	*/
* Then, let's run our regression using our daily data, for non-ZLB data:
eststo clear
local basic effr L6.effr lfpr gdp_g pce_infl
foreach v in _3_month _3_yr _10_yr mort30 corp_aaa libor_6 {
	eststo: qui regress `v' L.`v' `basic' if lower_fed_funds != 0
	predict `v'_hat_normal, xb
		label var `v'_hat_normal "`v' (predicted, effr)"
	gen `v'_resid_normal = `v' - `v'_hat_normal
	qui hist `v'_resid_normal, name(`v'_resid_hist)
		label var `v'_resid_normal "residual of `v'"
}
graph combine _3_month_resid_hist _3_yr_resid_hist _10_yr_resid_hist mort30_resid_hist corp_aaa_resid_hist libor_6_resid_hist, title("Distributions of Residuals" "EFFR Specification")
	graph export "$output/resid_normal_hist.png", replace
collect clear
collect: qui table, stat(mean  _3_month_resid _3_yr_resid _10_yr_resid mort30_resid corp_aaa_resid libor_6_resid) stat(sd _3_month_resid _3_yr_resid _10_yr_resid mort30_resid corp_aaa_resid libor_6_resid)
collect layout (var) (result[mean sd])
collect title "Summary Statistics of Residuals, EFFR Specification"
collect style cell result, nformat(%6.3f)
collect preview
collect export "$output/normal_residual_sum.tex", replace tableonly
collect export "$output/normal_residual_sum.docx", replace as(docx)

esttab using "$output/basic_reg.tex", ar2 replace compress width(\hsize) booktabs
esttab using "$output/basic_reg.rtf", ar2 not replace compress

eststo clear
foreach v in _3_month_spr _3_yr_spr mort30_spr corp_aaa_spr libor_6_spr {
	eststo: qui regress `v' L.`v' `basic' if lower_fed_funds != 0 
}
esttab using "$output/spread_reg.tex", ar2 replace width(\hsize) booktabs
esttab using "$output/spread_reg.rtf", ar2 not replace

eststo clear
local real effr_real L6.effr_real lfpr gdp_g pce_infl
foreach v in _3_month_real _3_yr_real _10_yr_real mort30_real corp_aaa_real libor_6_real {
	eststo: qui regress `v' L.`v' `real' if lower_fed_funds != 0
}
esttab using "$output/real_reg.tex", ar2 replace width(\hsize)

eststo clear
local shadow shadow_rate L6.shadow_rate lfpr gdp_g pce_infl
foreach v in _3_month _3_yr _10_yr mort30 corp_aaa libor_6 {
	eststo: qui regress `v' L.`v' `shadow'
	predict `v'_hat_shadow, xb
		label var `v'_hat_shadow "`v' (predicted, shadow_rate)"
	gen `v'_resid_shadow = `v' - `v'_hat_shadow
	tsline `v' `v'_hat_shadow `v'_hat_normal
		graph export "$output/`v'_prediction.png", replace
	scatter `v'_resid_shadow `v'_resid_normal, name(`v'_scatter)
	qui hist `v'_resid_shadow, name(`v'_resid_hist_sh)
		label var `v'_resid_shadow "shadow rate residual of `v'"
}
esttab using "$output/basic_reg_shadow.tex", ar2 replace width(\hsize) booktabs
esttab using "$output/basic_reg_shadow.rtf", ar2 not replace

graph combine _3_month_resid_hist_sh _3_yr_resid_hist_sh _10_yr_resid_hist_sh mort30_resid_hist_sh corp_aaa_resid_hist_sh libor_6_resid_hist_sh, title("Distributions of Residuals" "Shadow Rate Specification")
	graph export "$output/resid_hist_sh.png", replace
collect clear
collect: qui table, stat(mean  _3_month_resid_shadow _3_yr_resid_shadow _10_yr_resid_shadow mort30_resid_shadow corp_aaa_resid_shadow libor_6_resid_shadow) stat(sd _3_month_resid_shadow _3_yr_resid_shadow _10_yr_resid_shadow mort30_resid_shadow corp_aaa_resid_shadow libor_6_resid_shadow)
collect layout (var) (result[mean sd])
collect title "Summary Statistics of Residuals, Shadow Rate Specification"
collect style cell result, nformat(%6.3f)
collect preview
collect export "$output/shadow_residual_sum.tex", replace tableonly
collect export "$output/shadow_residual_sum.docx", replace as(docx)

graph combine _3_month_scatter _3_yr_scatter _10_yr_scatter mort30_scatter corp_aaa_scatter libor_6_scatter, title("Residuals, Shadow vs. EFFR Specification") 
	graph export "$output/resid_scatter.png", replace

eststo clear
foreach v in _3_month_spr _3_yr_spr mort30_spr corp_aaa_spr libor_6_spr {
	eststo: qui regress `v' L.`v' `shadow'
}
esttab using "$output/spread_reg_shadow.tex", ar2 replace width(\hsize) booktabs
esttab using "$output/spread_reg_shadow.rtf", ar2 replace width(\hsize) booktabs


eststo clear
local real_shadow shadow_rate_real L6.shadow_rate_real lfpr gdp_g pce_infl
foreach v in _3_month_real _3_yr_real _10_yr_real mort30_real corp_aaa_real libor_6_real {
	eststo: qui regress `v' L.`v' `shadow'
}
esttab using "$output/real_reg_shadow.tex", ar2 replace width(\hsize) booktabs
esttab using "$output/real_reg_shadow.rtf", not ar2 replace
eststo clear

/*
log close
exit
*/












/*
capture log close
log using 02_reg, replace text
*/

/*
  program:    	02_reg.do
  task:			Run regression analyses for pass-through project.
  
  project:		The Pass-Through of Changes in Monetary Policy to Borrowing Costs"
  author:     	Daniel_Posthumus \ 21Jan2024
*/

version 17
clear all
set linesize 80
macro drop _all

***************************************************************************************Set Global Macros              ***************************************************************************************
global project "~/danielposthumus.github.io/_portfolio/pass-through_2024"
	global code "$project/code"
	global data "$project/data"
	global output "$project/graphics"
***************************************************************************************Generate de-trended variables           ***************************************************************************************
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
***************************************************************************************Create basic regression tables          ***************************************************************************************
* Before executing our regressions, let's create a local capturing the macro controls in use:
local macro_ctrls pce_infl lfpr housing_own_rate gdp_g unemployment vix_chg
* Now let's run FULL specifications, varying the implementation/use of macro controls and detrended data.
collect clear
foreach v in _3_yr _10_yr mort30 corp_aaa {
	collect _r_b _r_se _r_p e(N), tag(model[`v']): qui regress `v' shadow_rate
	collect _r_b _r_se _r_p e(N), tag(model[`v'_macro]): qui regress `v' shadow_rate pce_infl lfpr housing_own_rate gdp_g unemployment vix_chg
		collect _r_b _r_se _r_p e(N), tag(model[`v'_detrend]): qui regress `v'_detrend shadow_rate
		collect _r_b _r_se _r_p e(N), tag(model[`v'_macro_detrend]): qui regress `v'_detrend shadow_rate `macro_ctrls'
	foreach c in news_shock target path shock_e_effr {
		collect _r_b _r_se _r_p e(N), tag (model[`v'_macro]): qui regress d.`v' `c' d.pce_infl d.lfpr d.housing_own_rate gdp_g d.unemployment vix_chg
	}
}
collect layout  (model#result[_r_b _r_se]) (colname[shadow_rate target path])
* Here, I denote every stylistic command -- in general, my tables are stylized this way and I won't repeat this exercise for all table commands.
			/* First, since this is a regression table, I want significance stars. I 
			follow conventional practice in assigning three stars to 99% confidence, 
			two stars to 95% confidence, and one star to 90% confidence. */
		collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach(_r_b) shownote
			/* Next, I want to simplify the names of my variables. In general, for 
			variable names in tables, I only want to capitalize the very first 
			letter. I also add the term \quad into some variable labels since 
			LaTeX--the program to which I'm exporting this table interprets these in 
			its local environment as spaces. */
		collect label levels model _3_yr "3-Year treasury" _3_yr_macro "\quad 3-Year treasury (macro controls)"  _10_yr "10-Year treasury" _10_yr_macro "\quad 10-Year treasury (Macro Controls)" mort30 "30-Year mortgage" mort30_macro "\quad 30-Year mortgage (Macro Controls)" corp_aaa "Corp. bond" corp_aaa_macro "\quad Corp. bond (macro controls)" _3_yr_detrend "3-Year treasury (detrended)" _3_yr_macro_detrend "\quad 3-Year treasury (detrended, macro controls)" _10_yr_detrend "10-Year treasury (detrended)" _10_yr_macro_detrend "\quad 10-Year treasury (detrended, macro controls)" mort30_detrend "\quad 30-Year mortgage (detrended)" mort30_macro_detrend "30-Year mortgage (detrended, macro controls)" corp_aaa_detrend "Corp. bond (detrended)" corp_aaa_macro_detrend "\quad Corp. bond (detrended, macro controls)", replace
			/* Next, I want to simplify my column header names.*/
		collect label levels colname shadow_rate "Shadow rate" target "Target shocks" path "Path shocks", replace 
			/* I don't want to see headers denoting the coefficient and standard 
			error (it's obvious which is which since I'm putting the standard errors 
			in parentheses), so I hide their level labels.*/
		collect style header result[_r_b _r_se], level(hide)
			/* Next, I want to limit my results to 3 digits past the decimal, and 
			center their cells. */
		collect style cell result[_r_b _r_se], nformat(%7.3f) halign(center)
			/* I also want to put my standard errors in parentheses:*/
		collect style cell result[_r_se], sformat("(%s)")
			/* Finally, let's give it our title.*/
		collect title "Basic Regression Results"
collect preview
/* We're ready to export our table to LaTeX: remember that we have to use the tableonly option to ensure that we can integrate the table into a broader document LaTeX.*/
	collect export "$output/appendix_reg_table.tex", replace tableonly
* This table has too much detail; now let's run a basic OLS regression for just: 1) shadow rate coefficient and 2) macro controls + detrended:
collect clear
	foreach v in _3_month _3_yr _10_yr mort30 corp_aaa {
		collect, tag(model[`v']): qui regress `v'_detrend shadow_rate `macro_ctrls'
	}
collect layout (colname[shadow_rate `macro_ctrls']#result[_r_b _r_se] result[N r2_a]) (model)
* Now that we have our basic table, let's style it the way we want to.
	collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach(_r_b) shownote
	collect style cell result, halign(center)
	collect style cell result[_r_b _r_se r2_a], nformat(%7.3f)
	collect style cell result[_r_se], sformat("(%s)")
	collect style header result[_r_b _r_se], level(hide)
	collect label levels colname L "Lagged borrowing cost" shadow_rate "Shadow rate" pce_infl "Core PCE" lfpr "Labor force participation" housing_own_rate "Home ownership rate" gdp_g "Real GDP growth" unemployment "Unemployment rate" vix_chg "VIX Index (% chg)", replace
	collect label levels model _3_month "3-Month" _3_yr "3-Year" _10_yr "10-Year" mort30 "30-Year mortgage" corp_aaa "Corporate bond"
	collect style cell model, halign(center)
	collect title "Macroeconomic Factors' Relationship with Detrended Borrowing Costs"
collect preview
	collect export "$output/reg_table.tex", replace tableonly

/*
log close
exit
*/












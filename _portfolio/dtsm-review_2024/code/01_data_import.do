/*
capture log close
log using 01_data_import, replace text
*/

/*
  program:    	01_data_import.do
  task:			To import and clean data from CSV format.
  
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
****************************************************************************************Import Kim and Wright (2005) Data             ****************************************************************************************
* First, let's import and clean our CSV data:
cd "$data/raw"
	import delimited using kim_wright.csv, varnames(11)
* I'm only keeping the variables in my CSV file that I'm using in my analysis: the fitted rate, the instantaneous rate, the short rate, the fitted yield, and the term premium--all for for only the 1-year, for 3-year, for 5-year, and for 10-year. Let's use a loop to drop all unnecessary variables:
foreach n in 02 04 06 07 08 09 {
	drop threeff`n'00b threefftp`n'00b threefy`n'00b threefytp`n'00b
}
* Then let's rename our next variables (and generate the expected short rate via basic subraction) using a loop:
foreach n in 01 03 05 10 {
	rename (threeff`n'00b threefftp`n'00b threefy`n'00b threefytp`n'00b) (fit_rate_`n' inst_rate_`n' fit_yield_`n' fit_prem_`n')
	foreach v in fit_rate_`n' inst_rate_`n' fit_yield_`n' fit_prem_`n' {
			replace `v' = "" if `v' == "NA" | `v' == "#VALUE!"
				destring `v', replace
	}
		* The expected short rate is the difference between the fitted and 
		* instantanous rates, so we can generate it with basic subtraction. 
		* However, first we have to de-string:
		gen eshort_`n' = fit_rate_`n' - inst_rate_`n'
}
* let's clean and set our date variable, using the substring command:
gen year = substr(date,1,4)
gen month = substr(date,6,2)
gen day = substr(date,9,2)
	destring year month day, replace
		drop date
	gen date=mdy(month, day, year)
	format date %td
* Now we have our cleaned data in .dta format; before saving, let's label the variables we kept to keep them in order. 
foreach n in 01 03 05 10 {
		label var fit_rate_`n' "fitted instantaneous forward rate `n' years hence"
		label var inst_rate_`n' "instantaneous forward term premium `n' years hence"
		label var eshort_`n' "expected short rate `n' years hence (fit_rate - inst_rate)"
		label var fit_yield_`n' "fitted yield on `n' year zero coupon bond"
		label var fit_prem_`n' "term premium of `n' year zero coupon bond"
}
		label var date "date"
* Let's save our data in .dta format:
cd $data
	save kim_wright_clean, replace
****************************************************************************************Import Daily US Treasury Bond Yield Data             ****************************************************************************************
* Now let's supplement this mater data with time-series of daily treasury yield rates, which we also have to briefly clean and import from the delimited format:
cd "$data/raw"
	import delimited using daily_treasury, varnames(1) clear
		tempfile daily_treasury
		save `daily_treasury'
	import delimited using daily_treasury2022, varnames(1) clear
		tempfile daily_treasury1
		append using `daily_treasury'
		save `daily_treasury1'
	import delimited using daily_treasury2023, varnames(1) clear
		append using `daily_treasury1'
rename (mo v3 v4 v5 v6 yr v8 v9 v10 v11 v12 v13 v14) (_1_month _2_month _3_month _4_month _6_month _1_yr _2_yr _3_yr _5_yr _7_yr _10_yr _20_yr _30_yr)
* These labels are very self-explanatory, so we're just going to create crude labels using the following loop:
ds _1_month _2_month _3_month _4_month _6_month _1_yr _2_yr _3_yr _5_yr _7_yr _10_yr _20_yr _30_yr
	foreach v in `r(varlist)' {
		label var `v' "US Treasury `v' yield"
	}
* We're not interested in ALL these variables, however; so let's just keep the ones we want for our analysis: the 3-month treasury bill, the 3-year treasury bond, and the 10-year treasury bond.
keep date _3_month _3_yr _10_yr
* Now, finally, let's clean and declare our time variable.
	gen year = substr(date,1,4)
	gen month = substr(date,6,2)
	gen day = substr(date,9,2)
		destring day month year, replace ignore(/)
			drop date
gen date = mdy(month, day, year)
	tsset date
		format date %td
			label var date "Date"
cd $data
	save daily_treasury_clean, replace
****************************************************************************************Merge Data Into Master Dataset           ****************************************************************************************
* Now let's merge this clean .dta file with our master_clean dta_file
	merge 1:1 date using kim_wright_clean
		* Obviously we only want to keep the observations for dates that are in BOTH 
		* datasets to ensure our analyses are complete.
		keep if _merge == 3
		drop _merge
			* Let's just re-declare our date variable:
				tsset date
* Now let's save our data:
	compress
save master, replace	
/*
log close
exit
*/
	
	
	
	
	
	
	
	
	
	
	
	
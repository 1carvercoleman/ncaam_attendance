
* Change directory to data
cd "PUT DATA PATH HERE"

use "ncaam_analysis_data.dta", clear

*Adjust scaling of attendance so it is increase in 10%

destring people, replace ignore(",")
destring attendance, replace ignore("NA")
replace people = people / 1000
replace attendance = attendance * 0.05
replace trank = trank / 100
tab game_date, gen(date_id)
destring home_fg, replace force
destring home_three, replace force
destring home_ft, replace force
destring home_rebound, replace force
destring home_o_rebound, replace force
destring home_d_rebound, replace force
destring home_assists, replace force
destring home_steals, replace force
destring home_blocks, replace force
destring home_turnovers, replace force
destring home_fouls, replace force
destring home_t_fouls, replace force
destring home_f_fouls, replace force
destring away_fg, replace force
destring away_three, replace force
destring away_ft, replace force
destring away_rebound, replace force
destring away_o_rebound, replace force
destring away_d_rebound, replace force
destring away_assists, replace force
destring away_steals, replace force
destring away_blocks, replace force
destring away_turnovers, replace force
destring away_fouls, replace force
destring away_t_fouls, replace force
destring away_f_fouls, replace force
gen fg = home_fg - away_fg
gen three = home_three - away_three
gen ft = home_ft - away_ft
gen rebound = home_rebound - away_rebound
gen o_rebound = home_o_rebound - away_o_rebound
gen d_rebound = home_d_rebound - away_d_rebound
gen assists = home_assists - away_assists
gen steals = home_steals - away_steals
gen blocks = home_blocks - away_blocks
gen turnovers = home_turnovers - away_turnovers 
gen fouls = home_fouls - away_fouls
gen t_fouls = home_t_fouls - away_t_fouls
gen f_fouls =  home_f_fouls - away_f_fouls
drop if mi(fg)
drop if mi(attendance)
drop if mi(people)

* Basic OLS regressions

preserve
drop if year == 2020
reg home_wins people trank_diff, robust cluster(home_team_name)
reg home_wins people trank_diff away_id*, robust cluster(home_team_name)
reg home_wins people trank_diff date_id*, robust cluster(home_team_name)
reg point_diff people trank_diff, robust cluster(home_team_name)
reg point_diff people trank_diff away_id*, robust cluster(home_team_name)
reg point_diff people trank_diff date_id*, robust cluster(home_team_name)
restore

preserve
drop if year != 2020
reg home_wins people trank_diff, robust cluster(home_team_name)
reg home_wins people trank_diff away_id*, robust cluster(home_team_name)
reg home_wins people trank_diff date_id*, robust cluster(home_team_name)
reg point_diff people trank_diff, robust cluster(home_team_name)
reg point_diff people trank_diff away_id*, robust cluster(home_team_name)
reg point_diff people trank_diff date_id*, robust cluster(home_team_name)
restore







* Do 2 week cases per population
use "ncaam_analysis_data.dta", clear
destring people, replace ignore(",")
destring attendance, replace ignore("NA")
replace people = people / 1000
replace attendance = attendance * 0.05
*replace attendance = attendance * 0.1
replace trank_diff = trank_diff / 100
merge m:1 county state using "ncaam_covid_cases_week.dta"
drop if _merge == 2
drop _merge
drop if year != 2020
gen case_date = substr(date, 1, 4) + "-" + substr(date, 5, 2) + "-" + substr(date, 7, 2)
drop date
gen date = date(case_date, "YMD")
tab date, gen(date_id)
gen monthly_cases_pop = monthly_cases / population
replace monthly_cases_pop = monthly_cases_pop *100
*replace monthly_cases_pop = monthly_cases_pop *1000
destring home_fg, replace force
destring home_three, replace force
destring home_ft, replace force
destring home_rebound, replace force
destring home_o_rebound, replace force
destring home_d_rebound, replace force
destring home_assists, replace force
destring home_steals, replace force
destring home_blocks, replace force
destring home_turnovers, replace force
destring home_fouls, replace force
destring home_t_fouls, replace force
destring home_f_fouls, replace force
destring away_fg, replace force
destring away_three, replace force
destring away_ft, replace force
destring away_rebound, replace force
destring away_o_rebound, replace force
destring away_d_rebound, replace force
destring away_assists, replace force
destring away_steals, replace force
destring away_blocks, replace force
destring away_turnovers, replace force
destring away_fouls, replace force
destring away_t_fouls, replace force
destring away_f_fouls, replace force
gen fg = home_fg - away_fg
gen three = home_three - away_three
gen ft = home_ft - away_ft
gen rebound = home_rebound - away_rebound
gen o_rebound = home_o_rebound - away_o_rebound
gen d_rebound = home_d_rebound - away_d_rebound
gen assists = home_assists - away_assists
gen steals = home_steals - away_steals
gen blocks = home_blocks - away_blocks
gen turnovers = home_turnovers - away_turnovers 
gen fouls = home_fouls - away_fouls
gen t_fouls = home_t_fouls - away_t_fouls
gen f_fouls =  home_f_fouls - away_f_fouls
drop if mi(fg)
drop if mi(attendance)


* Standardize all variables
foreach var of varlist trank_diff monthly_cases_pop people home_fg home_three home_ft home_rebound home_assists home_steals home_blocks home_turnovers home_fouls home_t_fouls away_fg away_three away_ft away_rebound away_assists away_steals away_blocks away_turnovers away_fouls away_t_fouls {
	qui sum `var'
	generate `var'_sd = (`var' - r(mean) ) / r(sd)
	replace `var' = `var'_sd
}



* Basic IV regressions
reg people monthly_cases_pop trank_diff away_id*, robust
predict yhat
reg home_wins yhat trank_diff away_id*, robust


drop yhat
reg people monthly_cases_pop trank_diff date_id*, robust cluster(home_team)
predict yhat
reg home_wins yhat trank_diff date_id*, robust cluster(home_team)

drop yhat
reg people monthly_cases_pop trank_diff, robust cluster(home_team)
predict yhat
reg point_diff yhat trank_diff, robust cluster(home_team)

drop yhat
reg people monthly_cases_pop trank_diff away_id*, robust cluster(home_team)
predict yhat
reg point_diff yhat trank_diff away_id*, robust cluster(home_team)

drop yhat
reg people monthly_cases_pop trank_diff date_id*, robust cluster(home_team)
predict yhat
reg point_diff yhat trank_diff date_id*, robust cluster(home_team)






* Basic team statistic IV regressions
capture erase info.dta
local outcome home_fg home_three home_ft home_rebound home_assists home_steals home_blocks home_turnovers home_fouls home_t_fouls away_fg away_three away_ft away_rebound away_assists away_steals away_blocks away_turnovers away_fouls away_t_fouls
tempname hdle
postfile `hdle' str15 y_hat b_yhat se_yhat p_yhat using info
qui foreach var in `outcome'{
	
	reg people monthly_cases_pop trank_diff, robust cluster(home_team)
	predict yhat
	reg `var' yhat trank_diff, robust cluster(home_team)
	post `hdle' ("`var'") (_b[yhat]) (_se[yhat]) (2 * ttail(e(df_r), abs(_b[yhat]/_se[yhat])))
	drop yhat
}	
	
	reg people monthly_cases_pop trank_diff away_id*, robust cluster(home_team)
	predict yhat
	reg `var' yhat trank_diff away_id*, robust cluster(home_team)
	post `hdle' ("`var'") (_b[yhat]) (_se[yhat]) (2 * ttail(e(df_r), abs(_b[yhat]/_se[yhat])))
	drop yhat

	reg people monthly_cases_pop trank_diff date_id*, robust cluster(home_team)
	predict yhat
	reg `var' yhat trank_diff date_id*, robust cluster(home_team)
 	post `hdle' ("`var'") (_b[yhat]) (_se[yhat]) (2 * ttail(e(df_r), abs(_b[yhat]/_se[yhat])))
	drop yhat
}
postclose `hdle'
preserve
use info, clear
export delimited "coefficients_figure_2.csv", replace
restore


*Reduced Form
capture erase info.dta
local outcome home_fg home_three home_ft home_rebound home_assists home_steals home_blocks home_turnovers home_fouls home_t_fouls away_fg away_three away_ft away_rebound away_assists away_steals away_blocks away_turnovers away_fouls away_t_fouls
tempname hdle
postfile `hdle' str15 y_hat b_yhat se_yhat p_yhat using info
qui foreach var in `outcome'{

	reg `var' monthly_cases_pop trank_diff, robust cluster(home_team)
	post `hdle' ("`var'") (_b[monthly_cases_pop]) (_se[monthly_cases_pop]) (2 * ttail(e(df_r), abs(_b[monthly_cases_pop]/_se[monthly_cases_pop])))
}
	reg `var' monthly_cases_pop trank_diff away_id*, robust cluster(home_team)
	post `hdle' ("`var'") (_b[monthly_cases_pop]) (_se[monthly_cases_pop]) (2 * ttail(e(df_r), abs(_b[monthly_cases_pop]/_se[monthly_cases_pop])))


	reg `var' monthly_cases_pop trank_diff date_id*, robust cluster(home_team)
 	post `hdle' ("`var'") (_b[monthly_cases_pop]) (_se[monthly_cases_pop]) (2 * ttail(e(df_r), abs(_b[monthly_cases_pop]/_se[monthly_cases_pop])))
}
postclose `hdle'
preserve
use info, clear
export delimited "coefficients_figure_3.csv", replace

restore


cd Box

*Random Forest
preserve
keep attendance people trank_diff game_ids date_id* home_wins point_diff monthly_cases_pop home_fg home_three home_ft home_rebound home_assists home_steals home_blocks home_turnovers home_fouls home_t_fouls away_fg away_three away_ft away_rebound away_assists away_steals away_blocks away_turnovers away_fouls away_t_fouls
export delimited ncaa_ML_date.csv, replace
restore

preserve
keep attendance people trank_diff game_ids away_id* home_wins point_diff monthly_cases_pop home_fg home_three home_ft home_rebound home_assists home_steals home_blocks home_turnovers home_fouls home_t_fouls away_fg away_three away_ft away_rebound away_assists away_steals away_blocks away_turnovers away_fouls away_t_fouls
export delimited ncaa_ML_away.csv, replace
restore

* Run python file to get ncaa_ML_away_output and ncaa_ML_date_output
preserve
import delimited ncaa_ML_away_output.csv, clear
save ncaa_ML_away_output, replace
import delimited ncaa_ML_date_output.csv, clear
save ncaa_ML_date_output, replace
restore

preserve
keep game_ids home_team home_wins point_diff home_fg home_three home_ft home_rebound home_assists home_steals home_blocks home_turnovers home_fouls home_t_fouls away_fg away_three away_ft away_rebound away_assists away_steals away_blocks away_turnovers away_fouls away_t_fouls
merge 1:1 game_ids using ncaa_ML_away_output
reg home_wins_tilda people_tilda monthly_cases_pop_tilda , robust cluster(home_team)
reg home_wins_tilda people_tilda monthly_cases_pop_tilda monthly_cases_pop_2_tilda monthly_cases_pop_3_tilda monthly_cases_pop_4_tilda, robust cluster(home_team)
reg point_diff_tilda people_tilda monthly_cases_pop_tilda monthly_cases_pop_2_tilda monthly_cases_pop_3_tilda monthly_cases_pop_4_tilda, robust cluster(home_team)
reg away_turnovers_tilda people_tilda monthly_cases_pop_tilda monthly_cases_pop_2_tilda monthly_cases_pop_3_tilda monthly_cases_pop_4_tilda, robust cluster(home_team)


*Random Forest
capture erase info.dta
local outcome home_fg home_three home_ft home_rebound home_assists home_steals home_blocks home_turnovers home_fouls home_t_fouls away_fg away_three away_ft away_rebound away_assists away_steals away_blocks away_turnovers away_fouls away_t_fouls
tempname hdle
postfile `hdle' str15 y_hat b_yhat se_yhat p_yhat using info
qui foreach var in `outcome'{
	reg `var' people_hat trank_diff away_id*, robust cluster(home_team)
	post `hdle' ("`var'") (_b[people_hat]) (_se[people_hat]) (2 * ttail(e(df_r), abs(_b[people_hat]/_se[people_hat])))
}
postclose `hdle'
use info, clear
export delimited "coefficients_away_new.csv", replace
restore

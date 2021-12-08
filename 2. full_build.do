*Build full attendance dataset
*Author: Carver Coleman

*Change directory to data
cd "ENTER PATH TO DATA"

*Read in all datasets
import delimited ncaam_extra_county_states.csv, clear
save ncaam_extra_county_states, replace

import delimited MTeamSpellings.csv, clear
rename teamid TeamID
save MTeamSpellings, replace

import delimited Cities.csv, clear
rename cityid CityID
save Cities

import delimited MTeams.csv, clear
rename teamid TeamID
save MTeams

import delimited ncaam_city_to_county.csv, clear
rename state_id home_team_state
rename city home_team_city
bysort home_team_city home_team_state: egen flag=max(population)
keep if population==flag
drop flag
save ncaam_city_to_county.dta, replace

import delimited "us-counties.csv", clear
replace date = subinstr(date, "-", "",.)
save ncaam_covid_cases.dta

*This will clean trank
import delimited ncaam_trank_17.csv, clear
keep trank team_name
drop if mi(trank)
replace team_name = lower(team_name)
rename team_name teamnamespelling
merge m:1 teamnamespelling using MTeamSpellings
drop if _merge != 3
gen year = 2017
drop teamnamespelling _merge
save ncaam_trank_17.dta, replace

* 2018
import delimited ncaam_trank_18.csv, clear
keep trank team_name
drop if mi(trank)
replace team_name = lower(team_name)
rename team_name teamnamespelling
merge m:1 teamnamespelling using MTeamSpellings
drop if _merge != 3
gen year = 2018
drop teamnamespelling _merge
save ncaam_trank_18.dta, replace

*2019
import delimited ncaam_trank_19.csv, clear
keep trank team_name
drop if mi(trank)
replace team_name = lower(team_name)
rename team_name teamnamespelling
merge m:1 teamnamespelling using MTeamSpellings
drop if _merge != 3
gen year = 2019
drop teamnamespelling _merge
save ncaam_trank_19.dta, replace

*2020
import delimited ncaam_trank_20.csv, clear
keep trank team_name
drop if mi(trank)
replace team_name = lower(team_name)
rename team_name teamnamespelling
merge m:1 teamnamespelling using MTeamSpellings
drop if _merge != 3
gen year = 2020
drop teamnamespelling _merge
save ncaam_trank_20.dta, replace

import delimited MGameCities.csv, clear
drop if season != 2020
gen counter = 1
collapse (sum) counter, by(wteamid cityid)
bysort wteamid: egen flag=max(counter)
keep if counter==flag
drop flag
rename wteamid TeamID
save w_team_city_crosswalk, replace
import delimited MGameCities.csv, clear
drop if season != 2020
gen counter = 1
collapse (sum) counter, by(lteamid cityid)
bysort lteamid: egen flag=max(counter)
keep if counter==flag
drop flag
rename lteamid TeamID
save l_team_city_crosswalk, replace
append using w_team_city_crosswalk
sort TeamID cityid
quietly by TeamID cityid: gen dup = cond(_N==1,0,_n)
drop if dup > 1
bysort TeamID: egen flag=max(counter)
keep if counter==flag
drop dup flag
rename cityid CityID
merge m:1 CityID using Cities
drop if _merge == 2
drop _merge
merge m:1 TeamID using MTeams
drop if _merge == 2
drop _merge
* I'll now manually go through and choose the cities that best match the teams
sort TeamID
quietly by TeamID: gen dup = cond(_N==1,0,_n)
sort TeamID dup
* export delimited create_team_crosswalk.csv
* Now read it in
import delimited create_team_crosswalk.csv, clear
drop counter firstd1season lastd1season dup
rename teamname team_name
rename teamid TeamID
save team_to_city_crosswalk, replace


* Read in data
import delimited ncaam_final_data_17.csv, clear
gen year = 2017
* I'm merging team spellings
gen away_team_name = substr(away_team, 1, strrpos(away_team, " ") - 1)
gen home_team_name = substr(home_team, 1, strrpos(home_team, " ") - 1)
* Rename away as teamnamespelling
rename away_team_name teamnamespelling
replace teamnamespelling = lower(teamnamespelling)
replace teamnamespelling = "miami (fl)" if teamnamespelling == "miami"
replace teamnamespelling = "san jose state" if teamnamespelling == "san josé state"
merge m:1 teamnamespelling using MTeamSpellings
* This will drop quite a few, but looking at them none of them are significant schools
drop if _merge != 3
drop _merge
* Now merge ranks
merge m:1 year TeamID using ncaam_trank_17.dta
drop if _merge == 2
drop _merge
drop if mi(trank)
merge m:1 TeamID using team_to_city_crosswalk
drop if _merge == 2
rename teamnamespelling away_team_name
rename TeamID away_team_id
rename cityid away_team_city_id
rename city away_team_city
rename state away_team_state
rename trank away_trank
drop team_name _merge
* Now do the same for home team
rename home_team_name teamnamespelling
replace teamnamespelling = lower(teamnamespelling)
replace teamnamespelling = "miami (fl)" if teamnamespelling == "miami"
replace teamnamespelling = "san jose state" if teamnamespelling == "san josé state"
merge m:1 teamnamespelling using MTeamSpellings
drop if _merge != 3
drop _merge
* Now merge ranks
merge m:1 year TeamID using ncaam_trank_17.dta
drop if _merge == 2
drop _merge
drop if mi(trank)
merge m:1 TeamID using team_to_city_crosswalk
drop if _merge == 2
rename teamnamespelling home_team_name
rename TeamID home_team_id
rename cityid home_team_city_id
rename city home_team_city
rename state home_team_state
rename trank home_trank
drop team_name _merge
save ncaam_final_data_17.dta, replace


import delimited ncaam_final_data_18.csv, clear
gen year = 2018
* I'm merging team spellings
gen away_team_name = substr(away_team, 1, strrpos(away_team, " ") - 1)
gen home_team_name = substr(home_team, 1, strrpos(home_team, " ") - 1)
* Rename away as teamnamespelling
rename away_team_name teamnamespelling
replace teamnamespelling = lower(teamnamespelling)
replace teamnamespelling = "miami (fl)" if teamnamespelling == "miami"
replace teamnamespelling = "san jose state" if teamnamespelling == "san josé state"
merge m:1 teamnamespelling using MTeamSpellings
* This will drop quite a few, but looking at them none of them are significant schools
drop if _merge != 3
drop _merge
* Now merge ranks
merge m:1 year TeamID using ncaam_trank_18.dta
drop if _merge == 2
drop _merge
drop if mi(trank)
merge m:1 TeamID using team_to_city_crosswalk
drop if _merge == 2
rename teamnamespelling away_team_name
rename TeamID away_team_id
rename cityid away_team_city_id
rename city away_team_city
rename state away_team_state
rename trank away_trank
drop team_name _merge
* Now do the same for home team
rename home_team_name teamnamespelling
replace teamnamespelling = lower(teamnamespelling)
replace teamnamespelling = "miami (fl)" if teamnamespelling == "miami"
replace teamnamespelling = "san jose state" if teamnamespelling == "san josé state"
merge m:1 teamnamespelling using MTeamSpellings
drop if _merge != 3
drop _merge
* Now merge ranks
merge m:1 year TeamID using ncaam_trank_18.dta
drop if _merge == 2
drop _merge
drop if mi(trank)
merge m:1 TeamID using team_to_city_crosswalk
drop if _merge == 2
rename teamnamespelling home_team_name
rename TeamID home_team_id
rename cityid home_team_city_id
rename city home_team_city
rename state home_team_state
rename trank home_trank
drop team_name _merge
save ncaam_final_data_18.dta, replace


import delimited ncaam_final_data_19.csv, clear
gen year = 2019
* I'm merging team spellings
gen away_team_name = substr(away_team, 1, strrpos(away_team, " ") - 1)
gen home_team_name = substr(home_team, 1, strrpos(home_team, " ") - 1)
* Rename away as teamnamespelling
rename away_team_name teamnamespelling
replace teamnamespelling = lower(teamnamespelling)
replace teamnamespelling = "miami (fl)" if teamnamespelling == "miami"
replace teamnamespelling = "san jose state" if teamnamespelling == "san josé state"
merge m:1 teamnamespelling using MTeamSpellings
* This will drop quite a few, but looking at them none of them are significant schools
drop if _merge != 3
drop _merge
* Now merge ranks
merge m:1 year TeamID using "ncaam_trank_19.dta"
drop if _merge == 2
drop _merge
drop if mi(trank)
merge m:1 TeamID using team_to_city_crosswalk
drop if _merge == 2
rename teamnamespelling away_team_name
rename TeamID away_team_id
rename cityid away_team_city_id
rename city away_team_city
rename state away_team_state
rename trank away_trank
drop team_name _merge
* Now do the same for home team
rename home_team_name teamnamespelling
replace teamnamespelling = lower(teamnamespelling)
replace teamnamespelling = "miami (fl)" if teamnamespelling == "miami"
replace teamnamespelling = "san jose state" if teamnamespelling == "san josé state"
merge m:1 teamnamespelling using MTeamSpellings
drop if _merge != 3
drop _merge
* Now merge ranks
merge m:1 year TeamID using "ncaam_trank_19.dta"
drop if _merge == 2
drop _merge
drop if mi(trank)
merge m:1 TeamID using team_to_city_crosswalk
drop if _merge == 2
rename teamnamespelling home_team_name
rename TeamID home_team_id
rename cityid home_team_city_id
rename city home_team_city
rename state home_team_state
rename trank home_trank
drop team_name _merge
save "ncaam_final_data_19.dta", replace


import delimited ncaam_final_data_20.csv, clear
gen year = 2020
* I'm merging team spellings
gen away_team_name = substr(away_team, 1, strrpos(away_team, " ") - 1)
gen home_team_name = substr(home_team, 1, strrpos(home_team, " ") - 1)
* Rename away as teamnamespelling
rename away_team_name teamnamespelling
replace teamnamespelling = lower(teamnamespelling)
replace teamnamespelling = "miami (fl)" if teamnamespelling == "miami"
replace teamnamespelling = "san jose state" if teamnamespelling == "san josé state"
merge m:1 teamnamespelling using MTeamSpellings
* This will drop quite a few, but looking at them none of them are significant schools
drop if _merge != 3
drop _merge
* Now merge ranks
merge m:1 year TeamID using "ncaam_trank_20.dta"
drop if _merge == 2
drop _merge
drop if mi(trank)
merge m:1 TeamID using team_to_city_crosswalk
drop if _merge == 2
rename teamnamespelling away_team_name
rename TeamID away_team_id
rename cityid away_team_city_id
rename city away_team_city
rename state away_team_state
rename trank away_trank
drop team_name _merge
* Now do the same for home team
rename home_team_name teamnamespelling
replace teamnamespelling = lower(teamnamespelling)
replace teamnamespelling = "miami (fl)" if teamnamespelling == "miami"
replace teamnamespelling = "san jose state" if teamnamespelling == "san josé state"
merge m:1 teamnamespelling using MTeamSpellings
drop if _merge != 3
drop _merge
* Now merge ranks
merge m:1 year TeamID using "ncaam_trank_20.dta"
drop if _merge == 2
drop _merge
drop if mi(trank)
merge m:1 TeamID using Cteam_to_city_crosswalk
drop if _merge == 2
rename teamnamespelling home_team_name
rename TeamID home_team_id
rename cityid home_team_city_id
rename city home_team_city
rename state home_team_state
rename trank home_trank
drop team_name _merge
save "ncaam_final_data_20.dta", replace


use "ncaam_final_data_17.dta", clear
*Append all of them here
append using "ncaam_final_data_18.dta"
append using "ncaam_final_data_19.dta"
append using "ncaam_final_data_20.dta"


merge m:1 home_team_city home_team_state using "ncaam_city_to_county.dta"
drop if _merge == 2
drop _merge
rename county_name county
rename state_name state

tostring date, replace
replace county = "New York City" if state == "New York" & (county == "New York" | county == "Bronx" | county == "Kings" | county == "Richmond")
replace county = "Charlottesville city" if state == "Virginia" & county == "Charlottesville"
replace county = "Hampton city" if state == "Virginia" & county == "Hampton"
replace county = "Harrisonburg city" if state == "Virginia" & county == "Harrisonburg"
replace county = "Lexington city" if state == "Virginia" & county == "Lexington"
replace county = "Lynchburg city" if state == "Virginia" & county == "Lynchburg"
replace county = "Norfolk city" if state == "Virginia" & county == "Norfolk"
replace county = "Radford city" if state == "Virginia" & county == "Radford"
replace county = "Williamsburg city" if state == "Virginia" & county == "Williamsburg"


replace population = 730395 if home_team_name == "air force"
replace population = 32213 if home_team_name == "alcorn state"
replace population = 741096 if home_team_name == "bellarmine"
replace population = 138115 if home_team_name == "dixie state"
replace population = 741096 if home_team_name == "louisville"
replace population = 162385 if home_team_name == "penn state"
replace population = 825062 if home_team_name == "rutgers"
replace population = 37890 if home_team_name == "tarleton"
replace population = 152691 if home_team_name == "uconn"

replace county = "El Paso" if home_team_name == "air force"
replace county = "Claiborne" if home_team_name == "alcorn state"
replace county = "Jefferson" if home_team_name == "bellarmine"
replace county = "Washington" if home_team_name == "dixie state"
replace county = "Jefferson" if home_team_name == "louisville"
replace county = "Centre" if home_team_name == "penn state"
replace county = "Middlesex" if home_team_name == "rutgers"
replace county = "Erath" if home_team_name == "tarleton"
replace county = "Tolland" if home_team_name == "uconn"

replace state = "Colorado" if home_team_name == "air force"
replace state = "Mississippi" if home_team_name == "alcorn state"
replace state = "Kentucky" if home_team_name == "bellarmine"
replace state = "Utah" if home_team_name == "dixie state"
replace state = "Kentucky" if home_team_name == "louisville"
replace state = "Pennsylvania" if home_team_name == "penn state"
replace state = "New Jersey" if home_team_name == "rutgers"
replace state = "Texas" if home_team_name == "tarleton"
replace state = "Connecticut" if home_team_name == "uconn"


gen trank_diff = away_trank - home_trank

merge m:1 date county state using "ncaam_covid_cases.dta"
drop if _merge == 2
drop _merge

*drop if attendance == "NA"
*destring attendance, replace
drop if mi(attendance)
gen game_date = date(date, "YMD")
tab home_team, gen(home_id)
tab away_team, gen(away_id)
tab year, gen(year_id)

gen is_ot = 0
replace is_ot = 1 if strpos(score, "(")
replace score = substr(score, 1, strpos(score, "(") - 2) if is_ot == 1
gen winner_score = substr(score, strpos(score, " ") + 1, strrpos(score, ",") - strpos(score, " ") - 1)
gen loser_score = substr(score, strrpos(score, " ") + 1, 3)
destring winner_score, replace
drop if mi(winner_score)
destring loser_score, replace
gen point_diff = winner_score - loser_score if home_wins == 1
replace point_diff = loser_score - winner_score if home_wins == 0

save "ncaam_analysis_data.dta", replace








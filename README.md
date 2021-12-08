# ncaam_attendance

This dataset contains percent attendance for most games in the NCAAM 2020-21 season. Of the 3,784 games played in non-neutral locations, this dataset contains 3,056 games (1,412 have information on attendance). Roughly 700 games were dropped due to several discrepancies with team names, city of stadium, and county. Some additional variables include date, away team, home team, score, and county where the game was played. Data was scraped from the ESPN website, and additional data was used from the following sources:
* March Machine Learning Mania 2021 Kaggle Competition (https://www.kaggle.com/c/ncaam-march-mania-2021/data)
* U.S. Cities to County Crosswalk via simplemaps.com (https://simplemaps.com/data/us-cities)
* COVID-19 Cases via NYT (https://github.com/nytimes/covid-19-data/tree/master/rolling-averages)
* T-Rank data via Bart Torvik's T-Rank Website (https://barttorvik.com/trankpure21.php)

# Steps to build and analyze data
The build occurs in two steps:
1. Run "1. get_ncaam_data.R" to scrape the ESPN website.
2. Run the STATA do file "2. full_build.do" to compile the game data with other datasets. You must download the "us-counties.csv" from the NYT github repo and copy it into the data folder.

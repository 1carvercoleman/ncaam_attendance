library(rvest)
library(stringr)
library(magrittr)

clean_vector <- function(input_vector) {
  return(input_vector[input_vector != ""])
}

CatchupPause <- function(Secs){
  Sys.sleep(Secs) #pause to let connection work
  closeAllConnections()
  gc()
}

###############################################################################
########################### Loop through all years ############################
###############################################################################
years <- c("17", "18", "19", "20")

for (t in 1:length(years)) {
  days <- read.csv(paste0("C:/Users/carverjc/Box/data/ncaam_dates_", years[t], ".csv"), header = FALSE)[,1]
  days <- str_remove(days, "-")
  days <- str_remove(days, "-")
  
  start <- 1
  
  for(i in start:length(days)) {
    scrape_url <- paste0("https://www.espn.com/mens-college-basketball/schedule/_/date/", as.character(days[i]) , "/group/50")
    
    print(days[i])
    
    while (TRUE) {
      tryCatch({
        my_html <- read_html(scrape_url)
        break
      }, 
      error = function(cond) {
        message("Error")
        CatchupPause(3)
        return(NA)
      },
      warning = function(cond) {
        message("Warning")
        CatchupPause(3)
        return(NA)
      },
      finally = {}
      )
    }
    
    full_table <-  my_html %>% 
      html_table(fill = TRUE)
    full_table <- full_table[[1]]
    full_table <- full_table[,1:3]
    if (nrow(full_table) != 1) {
      colnames(full_table) <- c("away_team", "home_team", "score")
      
      is_neutral <- my_html %>%
        html_nodes("table") %>% 
        html_nodes("tr") %>%
        html_nodes("td") %>% 
        html_nodes("div") %>%
        html_attr("data-home-text")
      full_table$is_neutral <- is_neutral[!is.na(is_neutral)] == "vs"
      
      # Get url for game details
      scraped <- my_html %>%
        html_nodes("table") %>% 
        html_nodes("tr") %>%
        html_nodes("td") %>% 
        html_nodes("a") %>%
        html_attr("href")
      
      # Clean url vector
      game_ids <- c()
      for(j in 1:length(scraped)) {
        if(grepl("gameId", scraped[j])) {
          game_ids <- append(game_ids, scraped[j])
        }
      }
      
      full_table <- cbind(full_table, game_ids)
      
      # Add Date
      full_table$date <- days[i]
      # Drop neutral locations
      #full_table <- full_table[!full_table$is_neutral,]
      # Drop canceled games
      full_table <- full_table[!grepl("Canceled", full_table$score),]
      # Drop postponed games
      full_table <- full_table[!grepl("Postponed", full_table$score),]
      # Drop uncontested games
      full_table <- full_table[!grepl("Uncontested", full_table$score),]
      
      if (i == 1L) {
        final_data <- full_table
      } else {
        # Append to final_data
        final_data <- rbind(final_data, full_table)
      }
    }
  }
  
  # Determine if home teach won
  final_data$Home_ABR <- substr(final_data$home_team, as.integer(regexpr("\\ [^\\ ]*$", final_data$home_team)) + 1, nchar(final_data$home_team))
  final_data$Away_ABR <- substr(final_data$away_team, as.integer(regexpr("\\ [^\\ ]*$", final_data$away_team)) + 1, nchar(final_data$away_team))
  final_data$Winner_ABR <- substr(final_data$score, 1, as.integer(regexpr("\\ [^\\ ]*", final_data$score)) - 1)
  temp_v <- substr(final_data$score, as.integer(regexpr("\\,[^\\,]*", final_data$score)) + 2, nchar(final_data$score))
  final_data$Loser_ABR <- substr(temp_v, 1, as.integer(regexpr("\\ [^\\ ]*", temp_v)) - 1)
  final_data$Home_wins <- ifelse(final_data$Home_ABR == final_data$Winner_ABR, 1, 0)
  final_data$Attendance <- ""
  final_data$People <- ""
  final_data$home_fg <- ""
  final_data$away_fg <- ""
  final_data$home_three <- ""
  final_data$away_three <- ""
  final_data$home_ft <- ""
  final_data$away_ft <- ""
  final_data$home_rebound <- ""
  final_data$away_rebound <- ""
  final_data$home_o_rebound <- ""
  final_data$away_o_rebound <- ""
  final_data$home_d_rebound <- ""
  final_data$away_d_rebound <- ""
  final_data$home_assists <- ""
  final_data$away_assists <- ""
  final_data$home_steals <- ""
  final_data$away_steals <- ""
  final_data$home_blocks <- ""
  final_data$away_blocks <- ""
  final_data$home_turnovers <- ""
  final_data$away_turnovers <- ""
  final_data$home_fouls <- ""
  final_data$away_fouls <- ""
  final_data$home_t_fouls <- ""
  final_data$away_t_fouls <- ""
  final_data$home_f_fouls <- ""
  final_data$away_f_fouls <- ""
  
  row.names(final_data) <- 1:nrow(final_data)
  
  start <- 1
  
  for(i in start:nrow(final_data)) {
    
    print(i)
    
    scrape_url <- paste0("https://www.espn.com", final_data$game_ids[i])
    scraped <- character(0)
    
    # Scrape percent attendance and turnovers
    
    while (TRUE) {
      tryCatch({
        my_url <- read_html(scrape_url)
        break
      },
      error = function(cond) {
        message("Error")
        CatchupPause(1)
        return(NA)
      },
      warning = function(cond) {
        message("Warning")
        CatchupPause(1)
        return(NA)
      },
      finally = {}
      )
    }
    scraped <- my_url %>%
      html_nodes(".percentage") %>%
      html_text()
    
    if(length(scraped) != 0L) {
      scraped <- str_remove(scraped, "%")
      final_data$Attendance[i] <- scraped
    } else {
      final_data$Attendance[i] <- ""
    }
    
    attendance <- my_url %>%
      html_nodes(".capacity") %>%
      html_text()
    
    attendance <- attendance[grepl("Attendance", attendance)]
    
    if(length(attendance) != 0L) {
      attendance <- str_remove(attendance, "Attendance: ")
      final_data$People[i] <- attendance
    } else {
      final_data$People[i] <- ""
    }
    
    scrape_url <- paste0("https://www.espn.com", gsub("game/_/gameId/", "matchup?gameId=", final_data$game_ids[i]))
    
    while (TRUE) {
      tryCatch({
        my_url <- read_html(scrape_url)
        break
      },
      error = function(cond) {
        message("Error")
        CatchupPause(1)
        return(NA)
      },
      warning = function(cond) {
        message("Warning")
        CatchupPause(1)
        return(NA)
      },
      finally = {}
      )
    }
    
    mytable <- my_url %>%
      html_table()
    
    if(length(mytable) <= 1) {
      next
    }
    
    mytable <- mytable[[2]]
    
    final_data$home_fg[i] <- as.numeric(as.character(mytable[(mytable[,1] == "Field Goal %"), 3]))
    final_data$away_fg[i] <- as.numeric(as.character(mytable[(mytable[,1] == "Field Goal %"), 2]))
    
    final_data$home_three[i] <- as.numeric(as.character(mytable[(mytable[,1] == "Three Point %"), 3]))
    final_data$away_three[i] <- as.numeric(as.character(mytable[(mytable[,1] == "Three Point %"), 2]))
    
    final_data$home_ft[i] <- as.numeric(as.character(mytable[(mytable[,1] == "Free Throw %"), 3]))
    final_data$away_ft[i] <- as.numeric(as.character(mytable[(mytable[,1] == "Free Throw %"), 2]))
    
    final_data$home_rebound[i] <- as.numeric(as.character(mytable[(mytable[,1] == "Rebounds"), 3]))
    final_data$away_rebound[i] <- as.numeric(as.character(mytable[(mytable[,1] == "Rebounds"), 2]))
    
    final_data$home_o_rebound[i] <- as.numeric(as.character(mytable[(mytable[,1] == "Offensive Rebounds"), 3]))
    final_data$away_o_rebound[i] <- as.numeric(as.character(mytable[(mytable[,1] == "Offensive Rebounds"), 2]))
    
    final_data$home_d_rebound[i] <- as.numeric(as.character(mytable[(mytable[,1] == "Defensive Rebounds"), 3]))
    final_data$away_d_rebound[i] <- as.numeric(as.character(mytable[(mytable[,1] == "Defensive Rebounds"), 2]))
    
    final_data$home_assists[i] <- as.numeric(as.character(mytable[(mytable[,1] == "Assists"), 3]))
    final_data$away_assists[i] <- as.numeric(as.character(mytable[(mytable[,1] == "Assists"), 2]))
    
    final_data$home_steals[i] <- as.numeric(as.character(mytable[(mytable[,1] == "Steals"), 3]))
    final_data$away_steals[i] <- as.numeric(as.character(mytable[(mytable[,1] == "Steals"), 2]))
    
    final_data$home_blocks[i] <- as.numeric(as.character(mytable[(mytable[,1] == "Blocks"), 3]))
    final_data$away_blocks[i] <- as.numeric(as.character(mytable[(mytable[,1] == "Blocks"), 2]))
    
    final_data$home_turnovers[i] <- as.numeric(as.character(mytable[(mytable[,1] == "Total Turnovers"), 3]))
    final_data$away_turnovers[i] <- as.numeric(as.character(mytable[(mytable[,1] == "Total Turnovers"), 2]))
    
    final_data$home_fouls[i] <- as.numeric(as.character(mytable[(mytable[,1] == "Fouls"), 3]))
    final_data$away_fouls[i] <- as.numeric(as.character(mytable[(mytable[,1] == "Fouls"), 2]))
    
    final_data$home_t_fouls[i] <- as.numeric(as.character(mytable[(mytable[,1] == "Technical Fouls"), 3]))
    final_data$away_t_fouls[i] <- as.numeric(as.character(mytable[(mytable[,1] == "Technical Fouls"), 2]))
    
    final_data$home_f_fouls[i] <- as.numeric(as.character(mytable[(mytable[,1] == "Flagrant Fouls"), 3]))
    final_data$away_f_fouls[i] <- as.numeric(as.character(mytable[(mytable[,1] == "Flagrant Fouls"), 2]))
  }
  
  # Remove "#"
  
  final_data$away_is_ranked <- grepl("#", final_data$away_team)
  final_data$home_is_ranked <- grepl("#", final_data$home_team)
  
  for (i in 1:nrow(final_data)) {
    if(final_data$away_is_ranked[i]) {
      final_data$away_team[i] <- substr(final_data$away_team[i], as.integer(regexpr("\\ [^\\ ]*", final_data$away_team[i])) + 1, nchar(final_data$away_team[i]))
    }
    
    if(final_data$home_is_ranked[i]) {
      final_data$home_team[i] <- substr(final_data$home_team[i], as.integer(regexpr("\\ [^\\ ]*", final_data$home_team[i])) + 1, nchar(final_data$home_team[i]))
    }
  }
  
  
  write.csv(final_data, paste0("C:/Users/carverjc/Box/data/ncaam_final_data_include_neutral_", years[t], ".csv"), row.names = FALSE)
  
}
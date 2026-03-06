# import packages and db_connect script
library(tidyverse)
library(janitor)
source("R/db_connect.R")

# 1. Read the CSV Skiping the first row which is just category labels 
raw_csv <- read_csv("data/Thika Rangers Spring 2024 Stats.csv", skip = 1) %>%
  clean_names() # Makes column names into snake case

# 2. Connect to Neon
con <- get_neon_connection()

# 3. Create and Upload the Table
# We call it 'raw_game_stats'
dbWriteTable(con, "raw_game_stats", raw_csv, overwrite = TRUE)

# 4. Close connection
dbDisconnect(con)
print("Democratization Successful: CSV is now in Neon Postgres!")




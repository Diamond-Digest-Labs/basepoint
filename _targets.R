# import packages
library(targets)
library(tarchetypes)

# Set the global options for the pipeline
tar_option_set(
  packages = c("dplyr", "readr", "janitor", "stringr", "tidyr", "purrr")
)

# Load the logic script from our R/ folder
tar_source("R/tidy_data.R")

list(
  #Track the raw CSV file from gamechanger app 
  tar_target(
    raw_data_file,
    "data/raw/Thika Rangers Spring 2024 Stats.csv",
    format = "file"
  ),
  
  #Ingest: Read the raw CSV into R without headers
  tar_target(
    raw_data,
    read_csv(raw_data_file, col_names = FALSE, show_col_types = FALSE)
  ),
  
  #Process step
  tar_target(
    cleaned_data,
    process_basepoint_data(raw_data)
  ),
  tar_target(
    db_status,
    push_to_neon(cleaned_data)
  )
)







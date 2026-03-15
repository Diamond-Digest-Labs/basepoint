#import packages
library(tidyverse)
library(stringr)
library(janitor)

process_basepoint_data <- function(df) {
  
  #--- GLOSSARY EXTRACTION using dplyr & stringr packages---
  # We find the row index where "Glossary" appears. 
  glossary_idx <- which(df[[1]] == "Glossary")
  glossary_row <- as.character(df[glossary_idx, ])

  # We use stringr package to split "GP=Games played" into "GP"
  extracted_headers <- map_chr(glossary_row, function(x) {
    if (is.na(x) || x == "Glossary") return(NA)
    if (str_detect(x, "=")) {
      return(str_split_fixed(x, "=", 2)[1, 1])
    }
    return(x)
  })

  # fix for the first three columns (Number, Last, First) 
  extracted_headers[1] <- "jersey_number"
  extracted_headers[2] <- "last_name"
  extracted_headers[3] <- "first_name"

  # ---SLICING & NAMING using dplyr package---
  # We remove the headers at the top (rows 1-2) and the Glossary at the bottom.
  # We then filter out the "Totals" row to keep only individual player data.
  df_clean <- df |>
    slice(3:(glossary_idx - 1)) |>
    set_names(extracted_headers) |>
    clean_names() |> 
    filter(!is.na(last_name) & last_name != "Totals")

  # ---SMART TYPE CONVERSION dplyr & tidyr packages ---
  # This is the "Meritocracy" logic. Convert types based on the Glossary keys from our raw data
  
  df_final <- df_clean |>
    # Handle "—" and empty strings
    mutate(across(everything(), ~na_if(as.character(.), "—"))) |>
    mutate(across(everything(), ~na_if(., ""))) |>
    
    # Convert columns ending in 'pct' or '%' to decimals
    mutate(across(
      .cols = matches("pct|percent|_p$"), 
      .fns = ~as.numeric(str_remove(., "%")) / 100
    )) |>
    
    # Convert standard baseball metrics to numeric types
    mutate(across(
      .cols = any_of(c("avg", "obp", "slg", "ops", "era", "whip", "babip", 
                       "baa", "pa_bb", "bb_k", "ps_pa", "ab_hr")),
      .fns = as.numeric
    )) |>
    
    # Convert volume stats to integers
    mutate(across(
      .cols = any_of(c("gp", "pa", "ab", "h", "x1b", "x2b", "x3b", "hr", 
                       "rbi", "r", "bb", "so", "k", "sb", "cs", "bf", "w", "l")),
      .fns = as.integer
    )) |>
    
    # INNINGS: handling for IP metric (Innings Pitched) 1.1 -> 1.33
    mutate(
      ip = as.numeric(ip),
      ip_total = floor(ip) + (ip %% 1 * 10 / 3)
    )

  return(df_final)
}










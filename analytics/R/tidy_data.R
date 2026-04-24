#import packages
library(tidyverse)
library(stringr)
library(janitor)

library(tidyverse)
library(stringr)
library(janitor)

process_basepoint_data <- function(df) {
  
  # --- GLOSSARY EXTRACTION ---
  glossary_idx <- which(df[[1]] == "Glossary")
  # Use unlist to ensure we have a clean vector for renaming
  glossary_row <- unlist(df[glossary_idx, ]) |> as.character()

  extracted_headers <- map_chr(glossary_row, function(x) {
    if (is.na(x) || x == "Glossary") return(NA)
    if (str_detect(x, "=")) {
      return(str_split_fixed(x, "=", 2)[1, 1])
    }
    return(x)
  })

  extracted_headers[1:3] <- c("jersey_number", "last_name", "first_name")

  # --- CLEANING & TYPE CONVERSION ---
  df_final <- df |>
    slice(3:(glossary_idx - 1)) |>
    set_names(extracted_headers) |>
    clean_names() |> 
    filter(!is.na(last_name) & last_name != "Totals") |>
    
    # Handle "—" and empty strings immediately
    mutate(across(everything(), ~na_if(as.character(.), "—"))) |>
    mutate(across(everything(), ~na_if(., ""))) |>
    
    # Convert percentages
    mutate(across(matches("pct|percent|_p$"), ~as.numeric(str_remove(., "%")) / 100)) |>
    
    # Convert standard metrics
    mutate(across(any_of(c("avg", "obp", "slg", "ops", "era", "whip", "babip", "baa")), as.numeric)) |>
    
    # Convert volume stats to integers
    mutate(across(any_of(c("gp", "pa", "ab", "h", "hr", "rbi", "r", "bb", "so", "k")), as.integer)) |>
    
    # INNINGS: ensure IP is numeric and clean
    mutate(
      ip = as.numeric(replace_na(as.character(ip), "0")),
      ip_total = floor(ip) + (ip %% 1 * 10 / 3)
    )

  return(df_final)
}
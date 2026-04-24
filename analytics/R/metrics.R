library(tidyverse)
library(tibble)

calculate_sabermetrics <- function(data) {
  # 1. Force to tibble and start a clean, linear pipe
  data |> 
    as_tibble() |>
    # 2. Convert to numeric (Step 1 of the main pipe)
    mutate(across(c(h, hr, ab, so, sf, bb, hbp, ip), ~as.numeric(as.character(unlist(.))))) |>
    
    # 3. Replace NA with 0 (Step 2 of the main pipe)
    mutate(across(c(h, hr, ab, so, sf, bb, hbp, ip), ~replace_na(., 0))) |>
    
    # 4. Calculate Sabermetrics (Step 3 of the main pipe)
    mutate(
      # BABIP: (H - HR) / (AB - K - HR + SF)
      babip = (h - hr) / (ab - so - hr + sf),

      # FIP: ((13*HR) + (3*(BB+HBP)) - (2*K)) / IP + 3.10
      fip = ((13 * hr) + (3 * (bb + hbp)) - (2 * so)) / ip + 3.10 
    ) |> 
    
    # 5. Final Cleanup
    # Using if_else and is.finite is safer than ifelse + is.infinite
    mutate(across(where(is.numeric), ~ if_else(is.finite(.), ., 0)))
}


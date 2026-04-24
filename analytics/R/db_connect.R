library(DBI)
library(RPostgres)

get_neon_connection <- function() {
  if (file.exists(".env")) {
    lines <- readLines(".env", warn = FALSE)
    for (line in lines) {
      if (line != "" && !startsWith(line, "#")) {
        parts <- strsplit(line, "=")[[1]]
        if (length(parts) == 2) {
          key <- trimws(parts[1])
          val <- trimws(parts[2])
          # Inject directly into R's system envs
          do.call(Sys.setenv, setNames(list(val), key))
        }
      }
    }
  } else {
    stop("CRITICAL: .env file not found in: ", getwd())
  }

  # 2. Safety Check
  host <- Sys.getenv("NEON_HOST")
  if (host == "") {
    stop("CRITICAL: NEON_HOST is blank. Check your .env file formatting (Key=Value).")
  }

  # 3. Connection
  dbConnect(
    RPostgres::Postgres(),
    host     = host,
    dbname   = Sys.getenv("NEON_DB"),
    user     = Sys.getenv("NEON_USER"),
    password = Sys.getenv("NEON_PASS"),
    port     = as.numeric(Sys.getenv("NEON_PORT")),
    sslmode  = "require"
  )
}

push_to_neon <- function(data) {
  #get the connection
  con <- get_neon_connection()

  # safety check 
  on.exit(dbDisconnect(con))

  #db table
  dbWriteTable(
    conn = con,
    name = "basepoint",
    value = data,
    overwrite = TRUE,
    row.names = FALSE
  )

  return(paste("Success: pipeline data synced at", Sys.time()))

}






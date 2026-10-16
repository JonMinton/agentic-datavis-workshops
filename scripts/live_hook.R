# Claude Code hooks for live mode (sessions/LIVE.md). Installed by
# `sh scripts/workshop live on`, which copies .claude/live-settings.json to
# .claude/settings.local.json. Does nothing unless .live-session exists, so a stale
# settings file can't constrain a normal working session.
#
#   session-start  prints the live contract, which Claude Code adds to the context
#   pre-tool       blocks installs, non-TidyTuesday fetches and writes outside the
#                  session's .qmd, specs/ and figures/ (exit 2 sends the reason to
#                  the agent)
event <- commandArgs(trailingOnly = TRUE)[1]
marker <- ".live-session"
if (!file.exists(marker)) quit(status = 0)
session_date <- trimws(readLines(marker, n = 1, warn = FALSE))
session_dir <- file.path("sessions", session_date)

if (identical(event, "session-start")) {
  cat(sprintf("LIVE MODE IS ON for session %s (folder %s/).\n\n", session_date, session_dir))
  cat(readLines("sessions/LIVE.md", warn = FALSE), sep = "\n")
  quit(status = 0)
}

block <- function(reason) {
  cat("Live mode (sessions/LIVE.md): ", reason, "\n", sep = "", file = stderr())
  quit(status = 2)
}

input <- jsonlite::fromJSON(file("stdin"), simplifyVector = FALSE)
tool <- input$tool_name
args <- input$tool_input

if (identical(tool, "Bash")) {
  command <- args$command
  installs <- paste(c("install\\.packages", "pak::", "remotes::install", "devtools::install",
                      "BiocManager::install", "renv::install", "\\b(pip3?|npm|brew|conda|apt(-get)?) install"),
                    collapse = "|")
  if (grepl(installs, command, perl = TRUE)) {
    block("no installs during a live session. Say the package is missing and offer the nearest chart the installed packages can draw (`sh scripts/workshop preflight --live` lists them).")
  }
  if (grepl("\\b(curl|wget)\\b", command, perl = TRUE)) {
    block("no direct downloads. Fetch TidyTuesday weeks with `sh scripts/workshop r scripts/tt_fetch.R YYYY-MM-DD`, and only when the room names one.")
  }
  quit(status = 0)
}

if (identical(tool, "WebFetch")) {
  tidytuesday <- "^https://(raw\\.githubusercontent\\.com|github\\.com|api\\.github\\.com/repos)/rfordatascience/tidytuesday"
  if (!grepl(tidytuesday, args$url %||% "")) {
    block("TidyTuesday sources only, unless the facilitator explicitly says otherwise in this session.")
  }
  quit(status = 0)
}

if (tool %in% c("Write", "Edit", "NotebookEdit")) {
  path <- args$file_path %||% args$notebook_path %||% ""
  root <- normalizePath(".", mustWork = TRUE)
  absolute <- if (startsWith(path, "/")) path else file.path(root, path)
  # Resolve the folder (the file itself may not exist yet) and make the path relative.
  folder <- normalizePath(dirname(absolute), mustWork = FALSE)
  relative <- sub(paste0("^", root, "/?"), "", file.path(folder, basename(absolute)))
  allowed <- c(
    paste0("^", session_dir, "/[^/]+\\.qmd$"),
    paste0("^", session_dir, "/(specs|figures)/"),
    "^_quarto\\.yml$"
  )
  if (!any(vapply(allowed, grepl, logical(1), x = relative))) {
    block(sprintf("during the session, write only to %s/<slug>.qmd, %s/specs/ and %s/figures/ (and _quarto.yml's render list). Put this in the .qmd, or leave it for after the session: %s",
                  session_dir, session_dir, session_dir, relative))
  }
}
quit(status = 0)

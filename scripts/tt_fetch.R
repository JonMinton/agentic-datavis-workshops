#!/usr/bin/env Rscript
# tt_fetch.R — cache every CSV from one TidyTuesday week into data/.
#
# Usage (from the repo root):
#   Rscript scripts/tt_fetch.R YYYY-MM-DD [--refresh]
#
# Lists the week's folder via the GitHub contents API
#   https://api.github.com/repos/rfordatascience/tidytuesday/contents/data/<year>/<date>
# downloads each .csv to data/tt-<date>-<basename>.csv (skipped if already cached, unless
# --refresh), saves the week's readme.md to data/tt-<date>-readme.md, and prints what it
# cached. If the network fails, falls back to whatever is already cached for that date.
# Base R only (plus readr for the row/col count), so any agent gets identical behaviour.

args <- commandArgs(trailingOnly = TRUE)
refresh <- "--refresh" %in% args
date <- setdiff(args, "--refresh")

if (length(date) != 1 || !grepl("^\\d{4}-\\d{2}-\\d{2}$", date)) {
  stop("Usage: Rscript scripts/tt_fetch.R YYYY-MM-DD [--refresh]", call. = FALSE)
}
year <- substr(date, 1, 4)

# Resolve the repo root: the directory containing scripts/ (works when run from the root,
# and also when invoked by path from elsewhere).
script_path <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
root <- if (length(script_path)) normalizePath(file.path(dirname(script_path), "..")) else getwd()
data_dir <- file.path(root, "data")
dir.create(data_dir, showWarnings = FALSE)

prefix <- paste0("tt-", date, "-")
list_cached <- function() {
  list.files(data_dir, pattern = paste0("^", prefix), full.names = TRUE)
}

report <- function(files, note) {
  cat(note, "\n")
  for (f in files) {
    size_mb <- file.size(f) / 1024^2
    dims <- ""
    if (grepl("\\.csv$", f)) {
      n_rows <- tryCatch(
        nrow(readr::read_csv(f, show_col_types = FALSE, progress = FALSE)),
        error = function(e) NA)
      n_cols <- tryCatch(
        length(readr::spec_csv(f)$cols), error = function(e) NA)
      dims <- sprintf("  %s rows x %s cols", format(n_rows, big.mark = ","), n_cols)
    }
    cat(sprintf("  %-50s %7.2f MB%s\n", file.path("data", basename(f)), size_mb, dims))
  }
}

api_url <- sprintf(
  "https://api.github.com/repos/rfordatascience/tidytuesday/contents/data/%s/%s", year, date)

# Unauthenticated GitHub API calls are limited to 60/hour per IP - shared venue wifi can
# hit that. If GITHUB_TOKEN is set (e.g. GITHUB_TOKEN=$(gh auth token)), use it.
headers <- c(Accept = "application/vnd.github+json")
token <- Sys.getenv("GITHUB_TOKEN")
if (nzchar(token)) headers <- c(headers, Authorization = paste("Bearer", token))

tmp <- tempfile(fileext = ".json")
listing_ok <- tryCatch({
  suppressWarnings(download.file(api_url, tmp, quiet = TRUE, headers = headers))
  TRUE
}, error = function(e) FALSE)

if (!listing_ok) {
  cached <- list_cached()
  if (length(cached)) {
    report(cached, sprintf("Network/API unavailable - using cached files for %s:", date))
    quit(status = 0)
  }
  stop(sprintf("Could not list %s (no network, API rate limit, or no such week) and nothing is cached.\n",
               api_url), "Check the date against data/", year, "/readme.md.", call. = FALSE)
}

# Minimal JSON parse without jsonlite: pull name + download_url pairs.
json <- paste(readLines(tmp, warn = FALSE), collapse = "")
names_ <- regmatches(json, gregexpr('"name":\\s*"[^"]*"', json))[[1]]
urls_ <- regmatches(json, gregexpr('"download_url":\\s*("[^"]*"|null)', json))[[1]]
names_ <- sub('^"name":\\s*"(.*)"$', "\\1", names_)
urls_ <- sub('^"download_url":\\s*"?(.*?)"?$', "\\1", urls_)
if (length(names_) != length(urls_)) stop("Unexpected API response shape.", call. = FALSE)

want <- grepl("\\.csv$", names_, ignore.case = TRUE) | tolower(names_) == "readme.md"
if (!any(grepl("\\.csv$", names_[want]))) {
  stop(sprintf("No CSV files found in data/%s/%s.", year, date), call. = FALSE)
}

fetched <- character(0)
n_skipped <- 0
for (i in which(want)) {
  base <- tools::file_path_sans_ext(names_[i])
  ext <- tolower(tools::file_ext(names_[i]))
  dest <- file.path(data_dir, paste0(prefix, base, ".", ext))
  if (file.exists(dest) && !refresh) {
    fetched <- c(fetched, dest)
    n_skipped <- n_skipped + 1
    next
  }
  ok <- tryCatch({
    download.file(urls_[i], dest, quiet = TRUE, mode = "wb")
    TRUE
  }, error = function(e) {
    message("  failed: ", names_[i], " (", conditionMessage(e), ")")
    FALSE
  })
  if (ok) fetched <- c(fetched, dest)
}

if (n_skipped) cat(sprintf("(%d file(s) already cached - not re-downloaded; use --refresh to force)\n", n_skipped))
report(fetched, sprintf("TidyTuesday %s cached (source: https://github.com/rfordatascience/tidytuesday/tree/main/data/%s/%s):",
                        date, year, date))
big <- fetched[file.size(fetched) > 20 * 1024^2]
if (length(big)) {
  cat("\nNote: over 20 MB - consider not committing:", paste(basename(big), collapse = ", "), "\n")
}

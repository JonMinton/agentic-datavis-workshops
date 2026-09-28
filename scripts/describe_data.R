#!/usr/bin/env Rscript
# describe_data.R — a projector-sized description of one CSV, in grammar-of-graphics terms.
#
# Usage (from the repo root):
#   Rscript scripts/describe_data.R data/<file>.csv
#
# Prints rows x cols, a guess at the row grain ("one row per ..."), and one line per
# variable: name, grammar type (continuous / discrete / temporal), n distinct, % missing,
# example values, and an aesthetic hint (colour/facet candidates for discrete variables
# with 2-12 levels). Deterministic: the same file always prints the same output.
# Uses base R + readr/dplyr/tibble only.

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(tibble)
})

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1) stop("Usage: Rscript scripts/describe_data.R data/<file>.csv", call. = FALSE)
path <- args[1]
if (!file.exists(path)) stop("No such file: ", path, call. = FALSE)

options(width = 140)
df <- read_csv(path, show_col_types = FALSE, progress = FALSE, guess_max = 10000)
n <- nrow(df)

is_id_name <- function(name) grepl("(^|_)id$|_number$|^id_", name, ignore.case = TRUE)

grammar_type <- function(x, n_distinct_x, name) {
  if (is_id_name(name) || (n_distinct_x == n && !is.double(x) && n > 12)) return("id")
  if (inherits(x, c("Date", "POSIXct", "hms", "difftime"))) return("temporal")
  if (is.logical(x)) return("discrete")
  if (is.numeric(x)) {
    # Integer-valued numerics with few levels read as discrete (e.g. a 1-5 rating).
    if (n_distinct_x <= 12 && all(x == round(x), na.rm = TRUE)) return("discrete*")
    return("continuous")
  }
  "discrete"
}

aes_hint <- function(type, k, name) {
  looks_temporal <- grepl("year|month|date|time|week|day", name, ignore.case = TRUE)
  if (type == "temporal" || (type != "discrete" && looks_temporal)) return("time axis (x)")
  if (type == "id") return("identifier - group / label only")
  if (type == "continuous") return("x / y / size")
  if (k == 1) return("constant - drop")
  if (k <= 3) return("colour / shape")
  if (k <= 8) return("colour / facet")
  if (k <= 12) return("facet")
  if (k >= 0.9 * n) return("near-unique - label only")
  "x / y as categories"
}

examples <- function(x, width = 28) {
  v <- unique(x[!is.na(x)])
  v <- if (is.numeric(v)) {
    v <- sort(v)
    as.character(signif(v[unique(round(seq(1, length(v), length.out = min(3, length(v)))))], 4))
  } else {
    trimws(as.character(head(v, 3)))
  }
  s <- paste(v, collapse = ", ")
  if (nchar(s) > width) s <- paste0(substr(s, 1, width - 3), "...")
  s
}

summary_tbl <- tibble(
  variable = names(df),
  n_distinct = vapply(df, function(x) n_distinct(x, na.rm = TRUE), integer(1)),
  pct_missing = vapply(df, function(x) round(100 * mean(is.na(x)), 1), numeric(1))
) |>
  mutate(
    type = mapply(grammar_type, df, n_distinct, names(df)),
    hint = mapply(aes_hint, type, n_distinct, variable),
    examples = vapply(df, examples, character(1))
  )

# Grain guess: the smallest set (up to 3) of discrete/temporal columns, in column order,
# that uniquely identifies rows.
grain_guess <- function() {
  cand <- summary_tbl |>
    filter(type != "continuous" | grepl("year|month|date", variable, ignore.case = TRUE),
           pct_missing == 0, n_distinct > 1) |>
    pull(variable)
  for (k in 1:3) {
    if (length(cand) < k) break
    for (combo in combn(cand, k, simplify = FALSE)) {
      if (nrow(distinct(df[combo])) == n) return(paste(combo, collapse = " x "))
    }
  }
  NA_character_
}
grain <- grain_guess()

cat(sprintf("%s: %s rows x %d cols\n", basename(path), format(n, big.mark = ","), ncol(df)))
cat("Grain: ", if (is.na(grain)) "no unique key found in <=3 columns (duplicates, or a wide table)"
               else paste0("one row per ", grain), "\n\n", sep = "")

# Wide-table check: several column names that are years/numbers are really values of one
# variable spread across columns - a tidy-data (pivot_longer) decision before any mapping.
numeric_names <- grep("^[0-9]{4}$|^[0-9]+$", names(df), value = TRUE)
if (length(numeric_names) >= 3) {
  cat(sprintf("WIDE: %d columns are named like values (%s ... %s) - pivot_longer() first?\n\n",
              length(numeric_names), numeric_names[1], tail(numeric_names, 1)))
}

out <- summary_tbl |>
  transmute(variable = substr(variable, 1, 24), type, levels = n_distinct,
            `%NA` = pct_missing, examples, hint)
print(as.data.frame(out), right = FALSE, row.names = FALSE)

cat("\n")
if (any(summary_tbl$type == "discrete*")) {
  cat("* whole numbers with <=12 values: discrete or continuous? That is a decision, not a fact.\n")
}
list_cands <- function(label, lo, hi) {
  c_ <- summary_tbl |> filter(grepl("^discrete", type), n_distinct >= lo, n_distinct <= hi)
  if (nrow(c_)) cat(label, paste0(c_$variable, " (", c_$n_distinct, ")", collapse = ", "), "\n")
}
list_cands(sprintf("%-26s", "Colour candidates (2-8):"), 2, 8)
list_cands(sprintf("%-26s", "Facet candidates (4-12):"), 4, 12)

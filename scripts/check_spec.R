#!/usr/bin/env Rscript
# check_spec.R — check a gg-spec YAML file against the shared coherence rules before compiling.
#
# Usage (from the repo root):
#   sh scripts/workshop r scripts/check_spec.R sessions/<date>/specs/<NN-slug>.yml
#
# Reads the rules from assets/gg-rules.json (the same file the mapping builder
# page uses), the spec, and data/<data>.csv, and applies the spec's filter and
# missing: decisions before checking. Prints one line per broken rule, as
# ERROR or WARNING, with the message and what ggplot2 itself would do, or "OK".
# Exits with status 1 if any rule at error severity is broken. Deterministic.

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(yaml)
  library(jsonlite)
})

script_dir <- dirname(sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[1]))
source(file.path(script_dir, "grammar_types.R"))

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1) stop("Usage: Rscript scripts/check_spec.R <spec.yml>", call. = FALSE)
# YAML 1.1 reads a bare y or n as a boolean, which would turn the key `y:` into TRUE.
keep_yn <- function(x) if (x %in% c("y", "Y", "n", "N")) x else tolower(x) %in% c("yes", "true", "on")
spec <- read_yaml(args[1], handlers = list("bool#yes" = keep_yn, "bool#no" = keep_yn))
rules <- fromJSON(file.path(script_dir, "..", "assets", "gg-rules.json"),
                  simplifyVector = FALSE)$rules

data_path <- file.path("data", paste0(spec$data, ".csv"))
if (!file.exists(data_path)) stop("No such data file: ", data_path, call. = FALSE)
df <- read_csv(data_path, show_col_types = FALSE, progress = FALSE, guess_max = 10000)
if (!is.null(spec$filter)) df <- filter(df, !!rlang::parse_expr(spec$filter))

# ---- the spec's decisions about missing values (missing: block) ----
# Applied before the checks, so a label counts as a level (and needs a shape) and a
# dropped variable no longer has missing values. "keep" leaves ggplot2's default.
decided_missing <- character()
na_labels <- list()   # compiled with forcats::fct_na_value_to_level(), so the label is the last level
for (f in names(spec$missing %||% list())) {
  how <- spec$missing[[f]]
  if (!f %in% names(df)) stop("missing: names ", f, ", which isn't a column in ", spec$data, call. = FALSE)
  if (!is.character(how) || length(how) != 1)
    stop("missing: ", f, " must be drop, keep, or a label in quotes", call. = FALSE)
  if (how == "drop") df <- df[!is.na(df[[f]]), , drop = FALSE]
  else if (how != "keep") {
    df[[f]] <- ifelse(is.na(df[[f]]), how, as.character(df[[f]]))
    na_labels[[f]] <- how
  }
  decided_missing <- c(decided_missing, f)
}

# ---- what each mapping refers to, in rule terms ----
# A mapping value is a column name, `backticked`, or factor(column). factor() makes it
# discrete; a discrete* column left bare counts as continuous, as it does in ggplot2.
resolve <- function(value) {
  value <- trimws(as.character(value))
  as_factor <- grepl("^factor\\((.+)\\)$", value)
  field <- gsub("`", "", sub("^factor\\((.+)\\)$", "\\1", value))
  if (!field %in% names(df)) {
    if (grepl("^[A-Za-z.][A-Za-z0-9._]*$", field) || grepl("`", value))
      return(list(field = field, type = "absent", levels = NA))
    return(NULL)   # an R expression: type checks don't apply
  }
  x <- df[[field]]
  k <- n_distinct(x, na.rm = TRUE)
  g <- grammar_type(x, k, field)
  type <- if (as_factor) "discrete" else switch(g, id = "identifier", `discrete*` = "continuous", g)
  # Levels in the order ggplot2 gives them (sorted), so the ones past a palette's end
  # can be named.
  lv <- if (type == "discrete") as.character(sort(unique(x[!is.na(x)]))) else character()
  if (!is.null(na_labels[[field]])) lv <- c(setdiff(lv, na_labels[[field]]), na_labels[[field]])
  # gg-spec's default for an undecided category with missing values: a last level,
  # "Not recorded" (see the skill's compilation contract), which also needs a shape.
  if (type == "discrete" && any(is.na(x)) && !field %in% decided_missing) {
    lv <- c(lv, "Not recorded"); k <- k + 1
  }
  list(field = value, column = field, type = type, levels = k, level_names = lv,
       n_missing = sum(is.na(x)))
}
norm_aes <- function(a) if (a == "color") "colour" else a

plot_map <- spec$mapping %||% list()
names(plot_map) <- vapply(names(plot_map), norm_aes, character(1))
facet_vars <- unlist(c(spec$facets$by, spec$facets$rows, spec$facets$cols))
layers <- lapply(spec$layers, function(l) {
  m <- plot_map
  for (a in names(l$mapping %||% list())) m[[norm_aes(a)]] <- l$mapping[[a]]
  # geom_smooth(method = "lm") and legacy stat: lm are still the smooth geom
  list(geom = l$geom, map = m)
})

# ---- evaluate ----
fill_msg <- function(tpl, vals) {
  for (k in names(vals)) tpl <- gsub(paste0("{", k, "}"), as.character(vals[[k]]), tpl, fixed = TRUE)
  tpl
}
hits <- list()
hit <- function(rule, vals) {
  # one report per rule and variable; per geom only when no variable is involved
  key <- paste(rule$id, if (is.null(vals$field)) vals$geom else vals$field)
  if (!is.null(hits[[key]])) return()
  hits[[key]] <<- sprintf("%-7s [%s] %s\n          ggplot2: %s", toupper(rule$severity), rule$id,
                          fill_msg(rule$message, vals), fill_msg(rule$ggplot2, vals))
}
aes_targets <- function(layer, aes_list) {
  out <- list()
  for (a in aes_list) {
    if (a == "facet") { for (v in facet_vars) out[[length(out) + 1]] <- list(aes = a, value = v) }
    else if (!is.null(layer$map[[a]])) out[[length(out) + 1]] <- list(aes = a, value = layer$map[[a]])
  }
  out
}
in_geoms <- function(rule, geom) is.null(rule$check$geoms) || geom %in% unlist(rule$check$geoms)

for (layer in layers) {
  for (rule in rules) {
    ck <- rule$check
    base <- list(geom = layer$geom, data = spec$data)
    if (ck$kind == "field-exists") {
      for (t in aes_targets(layer, c(names(layer$map), "facet"))) {
        r <- resolve(t$value)
        if (!is.null(r) && r$type == "absent") hit(rule, c(base, field = r$field))
      }
    } else if (ck$kind == "requires-aes" && in_geoms(rule, layer$geom)) {
      if (is.null(layer$map[[ck$aes]])) hit(rule, base)
    } else if (ck$kind == "forbids-aes" && in_geoms(rule, layer$geom)) {
      if (!is.null(layer$map[[ck$aes]])) hit(rule, base)
    } else if (ck$kind %in% c("aes-type", "geom-aes-type", "layer-aes-type") && in_geoms(rule, layer$geom)) {
      for (t in aes_targets(layer, unlist(ck$aes))) {
        r <- resolve(t$value)
        if (is.null(r) || r$type == "absent") next
        bad <- (!is.null(ck$allowed) && !r$type %in% unlist(ck$allowed)) ||
               (!is.null(ck$forbidden) && r$type %in% unlist(ck$forbidden))
        if (bad) hit(rule, c(base, field = r$field, type = r$type))
      }
    } else if (ck$kind == "max-levels") {
      for (t in aes_targets(layer, unlist(ck$aes))) {
        r <- resolve(t$value)
        if (is.null(r) || r$type == "absent") next
        if (!is.null(ck$types) && !r$type %in% unlist(ck$types)) next
        if (r$type != "continuous" && r$levels > ck$max)
          hit(rule, c(base, field = r$field, levels = r$levels, excess = r$levels - ck$max,
                      dropped = paste(tail(r$level_names, r$levels - ck$max), collapse = ", ")))
      }
    } else if (ck$kind == "has-missing") {
      for (t in aes_targets(layer, unlist(ck$aes))) {
        r <- resolve(t$value)
        if (is.null(r) || r$type == "absent" || r$column %in% decided_missing) next
        if (r$n_missing > 0)
          hit(rule, c(base, field = r$field, missing = format(r$n_missing, big.mark = ","),
                      pct = paste0(signif(100 * r$n_missing / nrow(df), 2), "%")))
      }
    } else if (ck$kind == "one-discrete-position" && in_geoms(rule, layer$geom)) {
      tx <- if (!is.null(layer$map$x)) resolve(layer$map$x)$type else NA
      ty <- if (!is.null(layer$map$y)) resolve(layer$map$y)$type else NA
      if (sum(c(tx, ty) %in% "discrete") != 1) hit(rule, base)
    }
  }
}

if (length(hits) == 0) {
  cat("OK: no rule broken (", length(rules), " rules checked)\n", sep = "")
} else {
  cat(unlist(hits), sep = "\n")
  if (any(startsWith(unlist(hits), "ERROR"))) quit(status = 1)
}

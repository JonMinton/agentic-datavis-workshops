# grammar_types.R — the one definition of a column's grammar-of-graphics type.
# Sourced by describe_data.R and check_spec.R. mapping-builder.qmd mirrors it in JavaScript;
# on 2026-10-01 the two agreed on all 60 columns of the cached tables. Change both together.
#
# Types: "id" (a row label), "temporal", "discrete*" (whole numbers with <= 12 values:
# discrete or continuous is a decision), "continuous", "discrete".

is_id_name <- function(name) grepl("(^|_)id$|_number$|^id_", name, ignore.case = TRUE)

grammar_type <- function(x, n_distinct_x, name, n = length(x)) {
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

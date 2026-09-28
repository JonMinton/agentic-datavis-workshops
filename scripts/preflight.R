# Invoked through sh scripts/workshop preflight; no downloads or installations.
failed <- FALSE
check <- function(ok, message) {
  cat(if (ok) "PASS" else "FAIL", message, "\n")
  if (!ok) failed <<- TRUE
}
cat(R.version.string, "\n")
check(getRversion() >= "4.5.0", "R >= 4.5.0 (reference environment: 4.5.2)")
required <- c("tidyverse", "yaml", "knitr", "rmarkdown")
for (package in required) {
  available <- requireNamespace(package, quietly = TRUE)
  check(available, paste(package, if (available) as.character(packageVersion(package)) else "missing"))
}
for (package in c("ggridges", "ggdist", "patchwork", "leaflet")) {
  cat("OPTIONAL", package, if (requireNamespace(package, quietly = TRUE))
    as.character(packageVersion(package)) else "not installed", "\n")
}
for (skill in c("tt-fetch", "gg-spec", "dataset-scout")) {
  source <- file.path(".claude", "skills", skill, "SKILL.md")
  alias <- file.path(".agents", "skills", skill, "SKILL.md")
  check(file.exists(source) && file.exists(alias) &&
          identical(normalizePath(source, mustWork = FALSE), normalizePath(alias, mustWork = FALSE)),
        paste(skill, "shared skill path resolves to the canonical file"))
}
cached <- "data/penguins.csv"
check(file.exists(cached), "cached penguins fixture exists")
if (file.exists(cached) && requireNamespace("readr", quietly = TRUE)) {
  fixture <- tryCatch(readr::read_csv(cached, show_col_types = FALSE), error = function(e) NULL)
  check(!is.null(fixture) && nrow(fixture) == 344 &&
          all(c("species", "bill_length_mm", "bill_depth_mm") %in% names(fixture)),
        "penguins fixture is readable and has expected shape")
}
for (directory in c("data", "sessions", "docs", "_freeze")) {
  # Probe without creating permanent files or overwriting existing artefacts.
  probe <- tempfile(".preflight-", tmpdir = directory)
  ok <- dir.exists(directory) && isTRUE(suppressWarnings(file.create(probe)))
  if (ok) unlink(probe)
  check(ok, paste(directory, "is writable"))
}
cat("Manual checks: agent skill discovery, image reading, network and command approvals.\n")
quit(status = if (failed) 1 else 0)

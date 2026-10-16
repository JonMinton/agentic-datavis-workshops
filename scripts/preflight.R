# Invoked through sh scripts/workshop preflight; no downloads or installations.
# With --live, the packages a live session may reach for are required, not optional,
# because live mode forbids installing anything mid-session (sessions/LIVE.md).
live <- "--live" %in% commandArgs(trailingOnly = TRUE)
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
live_packages <- c("ggalluvial", "ggbump", "ggbeeswarm", "ggdist", "ggrepel", "ggridges",
                   "patchwork", "scales")
optional <- union(c("ggridges", "ggdist", "patchwork", "leaflet"), live_packages)
for (package in optional) {
  available <- requireNamespace(package, quietly = TRUE)
  version <- if (available) as.character(packageVersion(package)) else "not installed"
  if (live && package %in% live_packages) {
    check(available, paste(package, version, "(required in live mode)"))
  } else {
    cat("OPTIONAL", package, version, "\n")
  }
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
check(file.exists("sessions/LIVE.md"), "live-mode contract sessions/LIVE.md exists")
if (live) {
  marker <- ".live-session"
  check(file.exists(marker), "live mode is on (sh scripts/workshop live on YYYY-MM-DD)")
  if (file.exists(marker)) {
    session <- file.path("sessions", trimws(readLines(marker, n = 1, warn = FALSE)))
    check(dir.exists(session), paste(session, "exists"))
  }
  missing <- live_packages[!vapply(live_packages, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing) > 0) {
    cat("Install the missing live packages before the session:\n",
        sprintf("sh scripts/workshop r -e 'install.packages(c(%s), repos=\"https://cloud.r-project.org\")'\n",
                paste0('"', missing, '"', collapse = ", ")))
  }
}
cat("Manual checks: agent skill discovery, image reading, network and command approvals.\n")
quit(status = if (failed) 1 else 0)

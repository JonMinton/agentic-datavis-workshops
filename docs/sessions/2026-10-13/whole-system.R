# =============================================================================
# Front door, ward, back door: the whole system in one script
# -----------------------------------------------------------------------------
# End-to-end, annotated reproduction of the 2026-10-13 preparation page:
#   https://jonminton.github.io/agentic-datavis-workshops/sessions/2026-10-13/nhs-whole-system.html
#
# What it does, in order:
#   0. Setup: packages, paths, small helpers
#   1. Get the data: use cached CSVs in data/ if present, otherwise download them
#      from the Public Health Scotland open data portal
#   2. Build three silos, each named by its place on the patient's journey:
#        front_door  A&E (Type 1 emergency departments)       board x month
#        ward        acute bed occupancy                        board x quarter
#        back_door   beds occupied by delayed discharges       board x month
#   3. Define align_silos(): keep silos separate, trim them to shared keys,
#      refuse ambiguity, so silo$column vectors line up row for row
#   4. Bring the monthly silos up to quarters, to meet the ward at its grain
#   5. Three alignments, one per figure (monthly Scotland; quarterly Scotland;
#      quarterly by board)
#   6. Show what alignment catches: a duplicated month is refused, not plotted
#   7. The three figures, saved to figures/
#   8. The numbers quoted on the page
#
# The flow, as on the page's diagram:
#
#   A&E activity ----------> front_door (board x month) --+--> align by month ---------------> Fig 1
#                                   |                      |
#   Delayed discharges ----> back_door  (board x month) --+
#                                   |
#                     sum to complete quarters
#                                   v
#   front_door (board x quarter) --+--> align, Scotland, by quarter --> Fig 2
#   ward       (board x quarter) --+
#   back_door  (board x quarter) --+--> align, board x quarter -------> Fig 3
#
# Data: Public Health Scotland open data, Open Government Licence v3.
#       Cite Public Health Scotland as the source.
# Code: MIT licence, as for the rest of the repository.
#
# Run from the repository root (or any folder; a data/ and figures/ folder is
# created next to where you run it):
#   Rscript sessions/2026-10-13/whole-system.R
# =============================================================================


# ---- 0. Setup ---------------------------------------------------------------

library(tidyverse) # dplyr, tidyr, readr, purrr, ggplot2, lubridate, stringr

data_dir <- "data"
fig_dir  <- "figures"
dir.create(data_dir, showWarnings = FALSE)
dir.create(fig_dir,  showWarnings = FALSE)

scotland <- "S92000003" # PHS code for the Scotland-level rows

# PHS stores months as numbers like 202608. Treated as numbers they mislead
# (201612 to 201701 looks like a jump of 89), so parse them as dates first.
yyyymm <- function(x) ym(as.character(x))


# ---- 1. Get the data --------------------------------------------------------

# Each file is cached in data/ so the analysis re-runs years later. If a file is
# missing it is downloaded. The URLs below were current on 2026-10-13; PHS puts
# the release month in some of them, so if a download fails, get the current
# link from the dataset page named in the comment.
sources <- tribble(
  ~file,                        ~url,
  # https://www.opendata.nhs.scot/dataset/monthly-accident-and-emergency-activity-and-waiting-times
  "phs-ae-monthly.csv",         "https://www.opendata.nhs.scot/dataset/997acaa5-afe0-49d9-b333-dcf84584603d/resource/37ba17b1-c323-492c-87d5-e986aae9ab59/download/monthly_ae_activity_202608.csv",
  # https://www.opendata.nhs.scot/dataset/delayed-discharges-in-nhsscotland
  "phs-delayed-discharge.csv",  "https://www.opendata.nhs.scot/dataset/52591cba-fd71-48b2-bac3-e71ac108dfee/resource/fd354e4b-6211-48ba-8e4f-8356a5ed4215/download/2026-08_delayed-discharge-beddays-health-board.csv",
  # https://www.opendata.nhs.scot/dataset/hospital-beds-information
  "phs-beds-quarterly.csv",     "https://www.opendata.nhs.scot/dataset/554b0e7a-ccac-4bb6-82db-1a8b306fcb36/resource/f272bb7d-5320-4491-84c1-614a2c064007/download/beds_by_nhs_board_of_treatment_and_specialty.csv"
)

for (i in seq_len(nrow(sources))) {
  path <- file.path(data_dir, sources$file[i])
  if (!file.exists(path)) {
    message("Downloading ", sources$file[i])
    read_csv(sources$url[i], show_col_types = FALSE) |> write_csv(path)
  }
}

ae_raw   <- read_csv(file.path(data_dir, "phs-ae-monthly.csv"),        show_col_types = FALSE)
dd_raw   <- read_csv(file.path(data_dir, "phs-delayed-discharge.csv"), show_col_types = FALSE)
beds_raw <- read_csv(file.path(data_dir, "phs-beds-quarterly.csv"),    show_col_types = FALSE)


# ---- 2. Three silos, named by the patient's journey ------------------------

# Front door: emergency departments only (Type 1; Type 3 are minor injury units,
# where the four-hour standard means less). One row per site, month and
# attendance category in the raw file; keep "All" and sum sites to board.
front_door_m <- ae_raw |>
  filter(DepartmentType == "Type 1", AttendanceCategory == "All") |>
  group_by(board_code = HBT, month = yyyymm(Month)) |>
  summarise(attendances = sum(NumberOfAttendancesAll),
            within_4h   = sum(NumberWithin4HoursAll), .groups = "drop")

# Back door: adults (18+), all reasons for delay. The file already has a
# Scotland row (S92000003) alongside the boards.
back_door_m <- dd_raw |>
  filter(AgeGroup == "18plus", ReasonForDelay == "All Delay Reasons") |>
  transmute(board_code   = HBT,
            month        = yyyymm(MonthOfDelay),
            bed_days     = NumberOfDelayedBedDays,
            delayed_beds = AverageDailyNumberOfDelayedBeds)

# Ward: acute specialties combined ("All Acute"), board-level rows only. In this
# file a board-level row is one whose Location equals its HB code (the rest are
# individual hospitals). Quarters are calendar quarters, coded like "2025Q4".
ward_q <- beds_raw |>
  filter(SpecialtyName == "All Acute", Location == HB) |>
  transmute(board_code    = HB,
            quarter       = yq(Quarter),
            occupied_beds = AverageOccupiedBeds,
            occupancy     = PercentageOccupancy)


# ---- 3. align_silos(): separate silos, shared keys, no ambiguity ------------

# The one new idea. ggplot2 will happily take vectors from different data frames
# (aes(x = a$col, y = b$col)), but it pairs them by POSITION, not by month. That
# is fragile. align_silos() makes it safe without merging the silos into one
# table:
#   - every silo must be named (the names are what the plotting code will show)
#   - every silo must have at most one row per key; otherwise it stops
#   - only keys present in EVERY silo are kept, sorted the same way
#   - it returns the silos side by side as a named list, plus a record of how
#     many rows each silo lost, so nothing is dropped silently
align_silos <- function(..., by) {
  silos <- list(...)
  stopifnot("give each silo a name" = !is.null(names(silos)) && all(names(silos) != ""))
  for (nm in names(silos)) {
    dupes <- silos[[nm]] |> count(across(all_of(by))) |> filter(n > 1)
    if (nrow(dupes) > 0) {
      stop("silo '", nm, "' has ", nrow(dupes), " key(s) with more than one row; ",
           "aggregate it to one row per ", paste(by, collapse = " x "), " first",
           call. = FALSE)
    }
  }
  keys <- silos |>
    map(\(s) distinct(s, across(all_of(by)))) |>
    reduce(inner_join, by = by) |>
    arrange(across(all_of(by)))
  aligned <- map(silos, \(s) left_join(keys, s, by = by))
  attr(aligned, "dropped") <- map_int(silos, nrow) - nrow(keys)
  aligned
}


# ---- 4. Up to quarters, to meet the ward at its grain -----------------------

# The ward silo only exists by quarter, so the monthly silos are summed up to
# quarters. A quarter counts only if all three of its months are present, so a
# part-quarter at the end of a series can't masquerade as a full one.
to_quarter <- function(d, ...) {
  d |>
    mutate(quarter = floor_date(month, "quarter")) |>
    group_by(quarter, ...) |>
    filter(n() == 3) |>
    summarise(across(any_of(c("attendances", "within_4h", "bed_days")), sum),
              days = sum(days_in_month(month)), .groups = "drop")
}

front_door_q <- to_quarter(front_door_m, board_code) |>
  mutate(pct_4h = 100 * within_4h / attendances) |>
  select(-days)

# Delayed beds per day over a quarter = bed days in the quarter / days in it
back_door_q <- to_quarter(back_door_m, board_code) |>
  mutate(delayed_beds = bed_days / days) |>
  select(-days)


# ---- 5. Three alignments, one per figure ------------------------------------

# 5a. Monthly, Scotland: front door against back door (Figure 1).
# The A&E file has no Scotland row, so sum the boards.
front_door_scot_m <- front_door_m |>
  group_by(month) |>
  summarise(attendances = sum(attendances), within_4h = sum(within_4h)) |>
  mutate(pct_4h = 100 * within_4h / attendances)

back_door_scot_m <- back_door_m |>
  filter(board_code == scotland) |>
  select(-board_code)

flow_m <- align_silos(front_door = front_door_scot_m,
                      back_door  = back_door_scot_m,
                      by = "month")

# 5b. Quarterly, Scotland: all three stages (Figure 2)
front_door_scot_q <- front_door_q |>
  group_by(quarter) |>
  summarise(attendances = sum(attendances), within_4h = sum(within_4h)) |>
  mutate(pct_4h = 100 * within_4h / attendances)

flow_q <- align_silos(
  front_door = front_door_scot_q,
  ward       = ward_q      |> filter(board_code == scotland) |> select(-board_code),
  back_door  = back_door_q |> filter(board_code == scotland) |> select(-board_code),
  by = "quarter"
)

# 5c. Quarterly, by board: ward against front door (Figure 3).
# Boards without an emergency department drop out here, and the drop is recorded.
flow_hb_q <- align_silos(
  front_door = front_door_q,
  ward       = ward_q      |> filter(board_code != scotland),
  back_door  = back_door_q |> filter(board_code != scotland),
  by = c("board_code", "quarter")
)


# ---- 6. What alignment catches ----------------------------------------------

# Append one month twice to the back-door silo, as a careless bind_rows() might.
# With raw $ vectors this would shift every later point by one month without
# warning. align_silos() refuses it instead.
caught <- tryCatch(
  align_silos(front_door = front_door_scot_m,
              back_door  = bind_rows(back_door_scot_m, slice(back_door_scot_m, 1)),
              by = "month"),
  error = conditionMessage
)
message("Alignment refused the duplicated month: ", caught)


# ---- 7. The figures ---------------------------------------------------------

# Figure 1: one silo against another, by name. Every aesthetic names its silo.
# There is no data = argument: the vectors come from the aligned silos directly,
# which is safe only because align_silos() has run.
fig_by_name <- ggplot() +
  geom_path(aes(x = flow_m$back_door$delayed_beds, y = flow_m$front_door$pct_4h),
            linewidth = 0.4, alpha = 0.5, colour = "grey50") +
  geom_point(aes(x = flow_m$back_door$delayed_beds, y = flow_m$front_door$pct_4h,
                 colour = flow_m$front_door$month), size = 1.8) +
  scale_colour_viridis_c(trans = "date", labels = scales::label_date("%Y")) +
  scale_x_continuous(labels = scales::comma) +
  scale_y_continuous(labels = \(y) paste0(y, "%")) +
  labs(x = "Back door: beds occupied by delayed discharges (daily average)",
       y = "Front door: A&E patients seen within 4 hours",
       colour = NULL, title = "Back door against front door") +
  theme_minimal(base_size = 13) +
  theme(legend.key.width = unit(2, "cm"), legend.position = "bottom")

# Figure 2: the silo itself becomes a variable. bind_rows(.id = "stage") records
# which part of the system each row came from, and the facet puts the stages in
# the order a patient meets them. Free y scales: the units differ.
stages <- c(
  front_door = "Front door: A&E patients seen within 4 hours (%)",
  ward       = "Ward: acute beds occupied (%)",
  back_door  = "Back door: beds occupied by delayed discharges (daily average)"
)

whole_system <- bind_rows(
  front_door = tibble(quarter = flow_q$front_door$quarter, value = flow_q$front_door$pct_4h),
  ward       = tibble(quarter = flow_q$ward$quarter,       value = flow_q$ward$occupancy),
  back_door  = tibble(quarter = flow_q$back_door$quarter,  value = flow_q$back_door$delayed_beds),
  .id = "stage"
) |>
  mutate(stage = factor(stage, levels = names(stages), labels = stages))

fig_strip <- ggplot(whole_system, aes(quarter, value)) +
  geom_line(colour = "#0072B2") +
  geom_point(colour = "#0072B2", size = 1.5) +
  facet_wrap(~ stage, ncol = 1, scales = "free_y") +
  scale_y_continuous(labels = scales::comma) +
  labs(x = NULL, y = NULL, title = "One patient journey, three publications") +
  theme_minimal(base_size = 13) +
  theme(strip.text = element_text(hjust = 0, face = "bold"))

# Figure 3: ward against front door, one point per board and quarter. Older
# quarters are fainter. Board size, case mix and geography differ, so this
# mixes between-board differences with within-board change.
fig_ward <- ggplot() +
  geom_point(aes(x = flow_hb_q$ward$occupancy, y = flow_hb_q$front_door$pct_4h,
                 alpha = flow_hb_q$ward$quarter),
             colour = "#0072B2", size = 1.6) +
  scale_alpha_continuous(range = c(0.15, 0.9), trans = "date", guide = "none") +
  scale_x_continuous(labels = \(x) paste0(x, "%")) +
  scale_y_continuous(labels = \(y) paste0(y, "%")) +
  labs(x = "Ward: acute beds occupied",
       y = "Front door: A&E patients seen within 4 hours",
       title = "Fuller wards, slower front doors?") +
  theme_minimal(base_size = 13)

ggsave(file.path(fig_dir, "fig-by-name.png"), fig_by_name, width = 9, height = 6.5, dpi = 150)
ggsave(file.path(fig_dir, "fig-strip.png"),   fig_strip,   width = 9, height = 8,   dpi = 150)
ggsave(file.path(fig_dir, "fig-ward.png"),    fig_ward,    width = 9, height = 6.5, dpi = 150)


# ---- 8. The numbers quoted on the page --------------------------------------

fmt_m <- function(d) format(d, "%B %Y")
fmt_q <- function(d) paste0(format(d, "%b"), "-", format(d %m+% months(2), "%b %Y"))

cat("\nMonthly system (Figure 1):",
    nrow(flow_m$front_door), "months,",
    fmt_m(min(flow_m$front_door$month)), "to", fmt_m(max(flow_m$front_door$month)), "\n",
    " A&E months dropped by alignment:", attr(flow_m, "dropped")[["front_door"]], "\n")
cat("Three-silo system (Figure 2):",
    nrow(flow_q$ward), "quarters,",
    fmt_q(min(flow_q$ward$quarter)), "to", fmt_q(max(flow_q$ward$quarter)), "\n",
    " acute occupancy range:", round(min(flow_q$ward$occupancy)), "% to",
    round(max(flow_q$ward$occupancy)), "%;",
    sum(flow_q$ward$occupancy > 85), "quarters above 85%\n")
cat("Boards in Figure 3:", n_distinct(flow_hb_q$ward$board_code), "\n")
cat("Figures written to", normalizePath(fig_dir), "\n")

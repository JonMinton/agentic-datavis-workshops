---
name: tt-fetch
description: Fetch a TidyTuesday week's data into data/, describe it in grammar-of-graphics terms (variable types, levels, missingness, row grain, limits), and propose - not choose - candidate aesthetic mappings to hand off to gg-spec. Use when asked to "fetch the TidyTuesday data for", "load week YYYY-MM-DD", "get the TidyTuesday dataset about <topic>", "describe the dataset", or "what's in this data".
---

# tt-fetch — fetch, cache, describe, hand off

This is the data-prep half of a live session; `gg-spec` is the visualisation half. The
point is **consistent behaviour whichever agent runs it**: every step that can be
deterministic goes through a helper script, so two different agents given the same week
print the same thing. The agent's own job is resolving the choice, reading the output, and
saying it briefly and in grammar terms.

Run R with the framework install:
`/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/bin/Rscript` (written
`Rscript` below). Run every command from the repo root.

## Workflow

### 1. Resolve the audience's choice to a week date (YYYY-MM-DD)

- **A date** — use it, but confirm it is a real week (TidyTuesday weeks are Tuesdays; a
  date a day or two off is almost always a typo for the nearest listed week).
- **A week number or a keyword** ("the Munros one", "week 10 of 2026") — search the year
  index `data/<year>/readme.md`:
  `https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/<year>/readme.md`
  Its table has week, date, dataset title, source. If several weeks match a keyword, list
  them (date + title, one line each) and let the humans pick. Never pick for them.
- **"Surprise us"** — offer three, don't choose one.

Say the resolved week back in one line before fetching: *"2025-08-19 — Scottish Munros.
Fetching."*

### 2. Fetch and cache

```bash
Rscript scripts/tt_fetch.R YYYY-MM-DD            # add --refresh to re-download
```

It lists the week's folder via the GitHub contents API, downloads every `.csv` to
`data/tt-<date>-<name>.csv`, saves the week readme to `data/tt-<date>-readme.md`, skips
files already cached, and prints each cached file with size and rows × cols.

- **Offline fallback:** if the network or API fails, the script uses whatever is already
  cached in `data/` for that date and says so. If nothing is cached, say so plainly and
  offer a pre-cached week instead (see the current session's `shortlist.md`, or
  `ls data/tt-*`).
- **Rate limit:** the unauthenticated GitHub API allows 60 calls/hour per IP — shared
  venue wifi can exhaust it. If listing fails with the network otherwise up, retry with a
  token: `GITHUB_TOKEN=$(gh auth token) Rscript scripts/tt_fetch.R YYYY-MM-DD`.
- **Size:** the script flags any file over 20 MB. Say so; don't silently commit it.

### 3. Describe (pedagogic, projector-sized)

Read the week readme (`data/tt-<date>-readme.md`) for what the data is and where it comes
from. Then, for each CSV (main table first; skip lookup tables of < ~50 rows unless
asked):

```bash
Rscript scripts/describe_data.R data/tt-<date>-<name>.csv
```

Show the script output **verbatim** (it is already sized for a projected screen), then
add at most five lines of your own:

1. **What it is** — one sentence, from the readme, with the source named.
2. **Grain** — "one row per …" in plain words. If the script found no unique key, or
   flagged the table as WIDE (columns named like values, e.g. years), say that this is a
   tidy-data decision the group must make *before* any mapping.
3. **Types in grammar terms** — continuous / discrete / temporal. Point out any `*`
   variables (whole numbers with few values, e.g. month or a 1–5 rating): whether they
   are discrete or continuous is a decision, not a fact.
4. **Missingness** worth knowing (anything over ~5%, and what it probably means).
5. **What the data can't say** — one line: the confounder, the selection, the censoring,
   or the too-short record.

If a week has several tables, name the join key(s) in one line; do not join unless asked.

### 4. Hand off to gg-spec — propose, don't choose

End with a short **candidate mappings** block. It lists options by aesthetic role; the
humans in the room choose, and their choice becomes a `gg-spec` YAML file.

```text
Candidates (the group chooses) - historic_station_met, 2025-10-21:
  position x/y (continuous): tmax, tmin, rain, sun (23% missing)
  time:                      year (continuous) | month (discrete* - 12 levels)
  facet (discrete, 4-12):    month (12)
  not for colour:            station (37 levels) - filter or lump first, or facet a few
  join:                      station_meta by station (adds lat/lng, opened)
```

Rules for this block:

- Only name variables that exist, with their level counts for anything discrete.
- Colour candidates need 2–8 levels; facet candidates 4–12; say why when a tempting
  variable fails (too many levels, mostly missing, an identifier).
- Offer, don't rank. No "I'd suggest x = … , y = …". The design decisions are the
  session's content; making them for the room removes the lesson.
- Then stop, and wait for the first spec.

## Output discipline

Everything shown is read off a projected screen by a room: keep prose to the five lines
above plus the candidates block, and never paste the full readme or a `head()` dump
unless asked. Numbers in any later writeup come from inline `r` expressions per AGENTS.md,
not from this description.

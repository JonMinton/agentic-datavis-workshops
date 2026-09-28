# Shortlist — 2026-09-29 university data-vis lab talk

Three TidyTuesday weeks pre-cached in `data/` so the live demo survives bad venue wifi.
Dates verified against the `rfordatascience/tidytuesday` year indexes on 2026-09-28.
The audience may pick **any other week** live — the `tt-fetch` skill resolves a date,
week number, or keyword and fetches it (`Rscript scripts/tt_fetch.R YYYY-MM-DD`).

| Week | What it is | Grammar decisions it provokes | Rows × cols | Licence / source | Cached files |
|---|---|---|---|---|---|
| [2025-08-19](https://github.com/rfordatascience/tidytuesday/tree/main/data/2025/2025-08-19) Scottish Munros | 604 Munros and Munro Tops with heights, OS grid coordinates, and their classification in each list revision 1891–2021. | Tidy data before mapping: 11 year columns are values of one variable (pivot longer first). Then x/y as *map* coordinates (`coord_fixed`) vs height; status-over-time as a tile or bump chart. | 604 × 18 | CC BY 4.0 — [Database of British and Irish Hills v18.2](https://www.hills-database.co.uk/downloads.html) | `tt-2025-08-19-scottish_munros.csv` (0.1 MB), `tt-2025-08-19-readme.md` |
| [2025-10-21](https://github.com/rfordatascience/tidytuesday/tree/main/data/2025/2025-10-21) Historic UK Met Office station data | Monthly max/min temperature, air frost days, rain and sunshine for 37 UK stations, some back to 1853; plus station metadata (lat/lng, opening year). | Temporal: is month discrete (facet/colour, 12 levels) or continuous (cyclic x)? 37 stations is too many for colour — filter, facet, or map with `station_meta`. Uneven record lengths expose censoring. | 39,148 × 8 (+ meta 37 × 5) | UK Open Government Licence — [Met Office historic station data](https://www.metoffice.gov.uk/research/climate/maps-and-data/historic-station-data) via [data.gov.uk](https://www.data.gov.uk/dataset/17ba3bbe-0e98-4a8c-9937-bd1d50fdc3c5/historic-monthly-meteorological-station-data) | `tt-2025-10-21-historic_station_met.csv` (1.4 MB), `tt-2025-10-21-station_meta.csv`, `tt-2025-10-21-readme.md` |
| [2026-03-10](https://github.com/rfordatascience/tidytuesday/tree/main/data/2026/2026-03-10) How likely is 'likely'? | ~5,000 quiz respondents gave 0–100% values to 19 probability phrases and compared phrase pairs — the classic perception-of-probability design. | Geoms and stats: 19 discrete terms × a continuous probability → distribution geoms (ridges, boxplots, jitter); ordering the discrete axis by a statistic is itself a scale decision. Colour/facet by demographics (age band 8, education 5 levels). | 98,306 × 4 (+ pairwise 51,740 × 5, respondents 5,174 × 6) | CC BY 4.0 — Kucharski AJ (2026) [CAPphrase](https://github.com/adamkucharski/CAPphrase), [doi:10.5281/zenodo.18750055](https://doi.org/10.5281/zenodo.18750055) | `tt-2026-03-10-absolute_judgements.csv` (2.2 MB), `tt-2026-03-10-pairwise_comparisons.csv` (2.4 MB), `tt-2026-03-10-respondent_metadata.csv` (0.4 MB), `tt-2026-03-10-readme.md` |

All cached CSVs are well under the 20 MB ceiling (largest 2.4 MB).

## What the data can't say (one line each, for the describe step)

- **Munros:** heights are survey estimates; list changes reflect re-surveying *and*
  shifting criteria, so "changes per revision" conflates measurement with definition.
- **Met Office:** no adjustment for site moves or instrument changes; sunshine is 23%
  missing and stations open at different dates, so early-record averages cover fewer sites.
- **'Likely':** a self-selected online quiz sample (English-language, 14% missing
  country) — not a population estimate of how people read these phrases.

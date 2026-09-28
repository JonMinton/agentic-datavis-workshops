---
name: dataset-scout
description: Search dataset catalogues (TidyTuesday, Rdatasets, and Wonderful Wednesdays) for candidates that stress a named grammar-of-graphics layer, check licences, and recommend two or three with reasons. Use when planning a session, or when asked to "find a dataset for", "scout datasets", or "what dataset for the scales session".
---

# dataset-scout — find datasets that stress a grammar layer

The selection rule this skill encodes comes from AGENTS.md: **pick datasets because they
stress the session's layer, not because they are interesting in general.** The output is a
recommendation, never a decision — the facilitators choose.

## Workflow

1. **Take the layer** (and any theme constraints) from the request or the session's
   `intro.md`. Before searching, write down what *stressing* that layer means — e.g. for
   scales: a variable spanning orders of magnitude, or a unit readers will misread
   unlogged; for facets: a grouping variable with 4–12 levels of comparable size.
2. **Search the default sources** (below). Prefer catalogue/index files over scraping.
3. **Check the licence and provenance** for each candidate — a real link, and whether
   redistribution/caching in `data/` is permitted. Drop anything murky.
4. **Recommend two or three candidates**, each with: one sentence on what the data is,
   one sentence on *how it stresses the layer*, size/shape (rows × cols, key variable
   types), licence, and the pull code that would cache it to `data/<slug>.csv`.
5. Do **not** pull data at this stage unless asked; the pull happens once a candidate is
   chosen, cached per the page conventions.

## Default sources

- **TidyTuesday** (core) — `rfordatascience/tidytuesday` on GitHub. The per-year
  `data/<year>/readme.md` files and each week's folder readme are the searchable index;
  the `tidytuesdayR` package (`tt_datasets(year)`) works too. Data is curated and openly
  licensed; cite the week's readme as the source link.
- **Rdatasets** (Vincent Arel-Bundock) — ~2,000 datasets from R packages. The master
  index CSV at <https://vincentarelbundock.github.io/Rdatasets/datasets.csv> is one
  greppable file with title, rows, cols, and doc/CSV URLs — search it first. Skews
  small-and-teachable; licences follow the originating R package (say which).
- **Wonderful Wednesdays** (PSI VIS SIG) — monthly pharma/clinical-trial visualisation
  challenges, inspired by TidyTuesday; active since 2020. Simulated trial data published
  openly at `VIS-SIG/Wonderful-Wednesdays` on GitHub, with community submissions and
  expert panel commentary per challenge (blog: <https://vis-sig.github.io/blog/>).
  Themes are narrowly clinical (wide data, longitudinal endpoints, adverse events) and
  the catalogue is ~monthly-sized, so it will often have no match for a layer — that's
  fine; when it does match, its panel commentary enables a "compare our take against
  the experts'" session.

Other sources (Our World in Data, Public Health Scotland open data, …) only if the
request names them; note licence and access friction explicitly when they come up.

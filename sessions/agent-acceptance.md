# Cross-agent acceptance exercise

Run this before using a new agent/model or machine in a workshop. Repeat the same
prompts in each intended agent, using separate scratch directories outside the repo
for generated R and PNG files. This is a facilitator-run rehearsal, not evidence
that every provider has already passed. Do not publish scratch output as a session.

Record agent/model, date, OS, the preflight output (including package versions),
pass/fail for each step, and any approval prompts. A new agent can read the skill
files manually if it has no skill discovery mechanism; record that distinction.

## 1. Setup and discovery

Prompt: “Read AGENTS.md. Identify the three project skills and their canonical files.
Run `sh scripts/workshop preflight`.”

Pass: `tt-fetch`, `gg-spec`, and `dataset-scout` are available; `.agents` links resolve
to the `.claude` sources; preflight exits zero. Command approval is checked in the
actual agent, not inferred from configuration. The agent can read a local PNG.

## 2. Deterministic description

Prompt: “Describe cached `data/penguins.csv` using the tt-fetch description workflow.
Do not fetch or choose a mapping.”

Pass: runs the shared description script and presents its output. Expected: 344 rows,
8 columns, species has 3 levels, sex has 3.2% missing, and year is flagged as
`discrete*`. Candidate mappings are proposals; the agent waits for the humans.
Compare script output across agents on the same environment, not their prose.

## 3. Compile, render, inspect

Prompt: “Compile each of `specs/penguins-example.yml` and
`specs/penguins-example-2.yml` using gg-spec. Save the R scripts and 1350 × 900 PNGs
to your scratch directory. Inspect both images. Preserve the supplied specs.”

Expected semantics for both:

```r
penguins <- readr::read_csv("data/penguins.csv", show_col_types = FALSE) |>
  dplyr::filter(!is.na(bill_depth_mm))
# 342 rows after filtering
```

Round 1: x = bill_length_mm, y = bill_depth_mm; points with alpha 0.6 followed by
`geom_smooth(method = "lm", se = TRUE)`. One pooled fit, negative slope.

Round 2: additionally colour = species at plot level, inherited by both layers.
Three fits, each with positive slope. Colour scale:

```r
scale_colour_manual(values = unname(palette.colors(3, palette = "Okabe-Ito")))
```

Both preserve their exact `labs` fields and use `theme_minimal(base_size = 13)`.
The agent reports that historical `stat: lm` means smoothing `method = "lm"`,
without changing the supplied files. It inspects the PNGs for titles, labels,
legends, and clipping, and reports findings. Code need not be byte-identical.

## 4. Defaults, validation, and human control

Use scratch copies only:

- Replace `stat: lm` with `method: lm`: same fit and figure semantics.
- Remove `theme`: still minimal at base size 13. Remove `scales`: default ggplot2
  colour scale, announced as a default rather than a new design choice.
- Add `method: loess` alongside legacy `stat: lm`: reports a conflict, does not render
  an arbitrarily chosen interpretation.
- Change x to a nonexistent column or add an unknown top-level key: explains the
  error and waits for a correction, without silently rewriting the spec.
- Ask to start a new interactive plot from the cached data: presents no more than
  three options for the current slot, asks one question, then waits.

## 5. Network and publication boundaries

If live fetching is planned, ask the agent to fetch one chosen TidyTuesday week
through the wrapper and record whether network/command approval is needed. This is
separate from the offline preflight. Do not claim the fallback was tested unless
network failure was actually exercised.

Confirm that a draft writeup still needs facilitator approval before publishing,
and that raw transcripts/chat exports and unconsented names remain uncommitted.
Do not publish anything as part of this exercise.

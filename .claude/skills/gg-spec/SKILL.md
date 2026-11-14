---
name: gg-spec
description: Compile a declarative YAML plot spec (grammar-of-graphics mapping rules) into idiomatic ggplot2 code, render it, and show the result. Use when a participant or facilitator supplies or edits a plot spec during a live session, or asks to "compile the spec", "re-render the spec", or translate a spec to another grammar-of-graphics implementation (plotnine, Vega-Lite, lets-plot, plotly, Julia's AlgebraOfGraphics, …).
---

# gg-spec — compile a plot spec to code and a figure

The point of this skill is pedagogic: the YAML spec makes Wilkinson's grammar of graphics
*visible*. Participants dictate mapping decisions in plain grammar terms; the spec records
them; the code and figure follow from the spec. The spec file is the artefact that ends up
quoted in the session writeup.

## Workflow

1. **Read the spec** — a YAML file (usually `specs/<name>.yml`, or during a session
   `sessions/YYYY-MM-DD/specs/<name>.yml`), or a YAML block pasted in chat. If pasted,
   save it to the session's `specs/` folder first: the file trail is the record.
2. **Validate before compiling.** Run
   `sh scripts/workshop r scripts/check_spec.R <spec.yml>`. It checks the spec against
   the shared coherence rules in `assets/gg-rules.json`, the same file the
   [mapping builder](../../../mapping-builder.qmd) uses, so the agent and the page refuse
   the same things with the same words. Examples are a variable that doesn't exist, a
   continuous variable on shape, y on a histogram, or a smoother on a discrete y.
   - **ERROR:** don't compile. Relay the message, which says what is wrong *in grammar
     terms*, and the nearest coherent spec. Don't silently fix it: the misunderstanding
     is teaching material.
   - **WARNING:** compile, and report the warning with the figure. Two warnings need
     the room before compiling, in interactive mode (below): `missing-values` and
     `shape-palette-size`. The first asks what empty values mean; the second names the
     categories that would get no shape, so offer colour alone or hand-set shapes.
   - **Changing a rule:** edit `assets/gg-rules.json`, never the checker or the page. The
     file says what each rule checks and what ggplot2 itself would do.
   - **Incoherence the rules miss:** still say so. If it will recur, propose a new rule
     to the facilitator.
3. **Compile to idiomatic ggplot2** — code a reader could have written by hand: one
   `ggplot()` call, layers in spec order, `labs()` from the `labs:` block, no dead
   arguments. Preserve spec order in the code so spec and code can be read side by side.
4. **Render and look.** Run the code from the repo root with
   `sh scripts/workshop r <compiled-script.R>`, save a
   PNG at the site's geometry (9×6 in, dpi 150), and **read the PNG** before presenting
   it. Check: title fits (~60 chars max at base_size 13), legend not colliding, overplotting,
   unlabelled axes, and **which categories and rows were actually drawn**: compare the
   legend with the plot, and report any rows ggplot2 removed (its "Removed N rows"
   warning) with the count.
5. **Present** the figure and the code together, and note anything the render revealed
   that the spec didn't anticipate — those observations feed the writeup's pain points.

During a live session, iterate: edit the spec (new numbered file or in place per the
group's preference), recompile, re-render. Keep each compiled R snippet consistent with
its spec — never let the code drift ahead of what the spec says.

## Interactive mode — the default in live sessions

**The room makes every graphic design decision; the agent types, renders, and reports
what it sees.** Never fill a design slot on your own initiative. Fully autonomous
exploration (the `claude-fable-vision-ds-test` repo is the worked example) happens only
when a facilitator explicitly asks for it, and its output is labelled as such.

If the group has no spec yet, build one by walking the grammar **slot by slot, in this
order**: data & grain → question → mapping (x, y, then *one* further aesthetic) →
missing values → geom/stat → scales → facets → coords → labs/theme. At each slot:

1. State the current value, or the ggplot2 default if the slot is empty ("no scales block
   yet, so the default hue scale"). Defaults are decisions too.
2. Offer **at most three** options, taken from the variables the data description
   (`tt-fetch`) flagged, not from the whole of ggplot2. Anything beyond them is the room's
   to propose.
3. Ask one question, then wait.

**The missing-values slot** comes up whenever `check_spec.R` reports `missing-values`
for a mapped variable. Say how many values are missing and what empty means in this
dataset, from the tt-fetch description or the readme (for example, an empty
`founder_crop` means "not a founder crop", not lost data). If the meaning isn't known,
say so. Then offer three options and wait:

1. **Label them** with what empty means: `missing: {founder_crop: "Not a founder crop"}`.
   The rows stay, as a last category with its own colour or shape.
2. **Drop them**: `missing: {founder_crop: drop}`, and say how many rows go.
3. **Keep ggplot2's default**: `missing: {founder_crop: keep}`. Grey "NA" for colour,
   fill, facets and discrete positions; the rows silently vanish for shape, size, alpha
   and continuous positions.

Record the answer in the spec's `missing:` block, so the decision is in the record. Never
choose for the room. If the room defers, the default below applies; say so.

This is how the skill stays generic without enumerating ggplot2's degrees of freedom: the
**schema** limits the vocabulary, the **slot order** limits the conversation, and the
**session's grammar layer** decides which slot gets the debate. Every other slot gets
its default, announced and moved past. Early rounds may render after the mapping slot
already. A rough figure is worth more to the room than a complete spec.

**Keep the room looking at the spec and the figure, not the terminal.** Save specs as
`sessions/YYYY-MM-DD/specs/NN-<slug>.yml` and renders as
`sessions/YYYY-MM-DD/figures/NN-<slug>.png`, and copy every new render over
`sessions/YYYY-MM-DD/figures/latest.png`. With `latest.png` and the current spec open
side by side in the IDE's editor area, the image tab reloads on each render. Keep
replies in the agent panel to about five lines: what changed in the spec, what the render
showed, and the next question.

## Spec schema

```yaml
data: penguins            # basename of a CSV in data/ (data/penguins.csv)
filter: "!is.na(sex)"     # optional; an R expression passed to dplyr::filter()
mapping:                  # plot-level aesthetics; any ggplot2 aesthetic is legal
  x: flipper_length_mm
  y: body_mass_g
  colour: species
layers:                   # one entry per layer, in drawing order
  - geom: point
    alpha: 0.6            # fixed (non-mapped) params sit beside the geom
  - geom: smooth
    method: lm            # smoothing method; stat is a separate ggplot2 concept
  # a layer may carry its own mapping, which applies to that layer only:
  # - geom: point
  #   mapping:
  #     colour: species     # points coloured; a later smooth layer stays pooled
    se: true
missing:                  # optional; what to do with missing values, by column
  sex: "Not recorded"     # a label: missing values become this category (the last level)
  # island: drop          # drop: remove rows where the column is missing
  # year: keep            # keep: ggplot2's own handling
scales:                   # optional; keyed by aesthetic
  colour: okabe-ito       # named shorthand (below) or a scale_* call verbatim
  y: log10
facets:                   # optional
  by: island              # or rows:/cols: for a grid
coords: ~                 # optional: flip | polar | fixed
labs:
  title: "Short title that fits"     # ≤ ~60 chars
  x: "Flipper length (mm)"
  y: "Body mass (g)"
theme: minimal            # default minimal, base_size 13
```

Named scale shorthands: `okabe-ito` → `scale_<aes>_manual(values = unname(palette.colors(n, palette = "Okabe-Ito")))`,
where `n` is the number of observed non-missing categories after filtering (maximum eight;
ask the group for another scale above eight); use the mapped aesthetic, e.g. colour or fill.
Leave category ordering to ggplot2 unless the spec explicitly supplies an order.
`viridis` → `scale_<aes>_viridis_d()` / `_c()` as the variable type dictates (colour or fill);
`log10` → `scale_<aes>_log10()`; `percent` → `scale_<aes>_continuous(labels = scales::percent)`.
Anything else the group wants: accept a verbatim `scale_*()` call as the value.

### Compilation contract

- Top-level keys are exactly those shown in the schema. Layer keys include `geom`,
  `stat`, `position`, and valid parameters for the selected geom/stat (such as `method`,
  `alpha`, and `se`). Unknown keys or unsupported values are errors; do not guess.
- A layer's optional `mapping:` block becomes `aes()` inside that layer's geom
  (`geom_point(aes(colour = species))`). It applies to that layer only, so it is how a
  spec colours points while keeping one pooled smoother. A plot-level mapping that every
  layer inherits gives one smoother per group instead.
- `geom: smooth` with `method: lm` becomes `geom_smooth(method = "lm")`.
  Legacy specs using `stat: lm` mean the same thing **only for smooth layers**;
  report the normalization without rewriting the historical spec. Conflicting
  `stat: lm` and `method` values are errors. Other `stat` values pass to ggplot2's
  `stat` argument; never generally treat `stat` as an alias for `method`.
- Read `data/<data>.csv` with `readr::read_csv()`, then apply `filter` if supplied,
  then the `missing:` block: a label becomes
  `mutate(<col> = fct_na_value_to_level(<col>, level = "<label>"))`, `drop` becomes
  `filter(!is.na(<col>))`, and `keep` adds nothing. Preserve layer order and inherit
  plot-level mappings. Do not add sampling, aggregation, jitter, labels, or other
  transformations that the spec did not request.
- **Default for missing values.** A discrete column mapped to an aesthetic (or used as a
  facet) that has missing values, and no `missing:` entry, compiles as if it said
  `"Not recorded"`: the rows stay, as a last category the reader can see. This is the
  second deliberate override of ggplot2, whose own default drops those rows for shape
  and shows a bare "NA" elsewhere. Announce it whenever it applies. Missing values in a
  continuous column have no default: ggplot2 removes those rows, and you report how many.
  `check_spec.R` counts the default "Not recorded" level when it checks palette sizes.
- Omitted `theme` means `theme_minimal(base_size = 13)`. Explicit named themes also
  use base size 13. This and the missing-values default are the two deliberate
  overrides of ggplot2 defaults.
  Omitted scales, facets, coords, and layer parameters retain ggplot2 defaults;
  omitted labs add no custom labels. Announce defaults during interactive design.
- `facets.by` means `facet_wrap(vars(...))`; `rows`/`cols` mean `facet_grid()`.
  `by` cannot be combined with `rows`/`cols`. Multiple variables use YAML lists.
  `coords: null` leaves coordinates unchanged; `flip`, `polar`, and `fixed` select
  the corresponding `coord_*()` with default arguments.
- `filter` expressions and verbatim scale calls are R-specific escape hatches.
  For another target, explain any semantic difference and ask about an unsupported
  operation rather than silently approximating it.

The worked penguins specs intentionally retain `stat: lm` to exercise legacy support.
Expected compilations and a cross-agent rehearsal are in `sessions/agent-acceptance.md`.

## Other targets — the grammar is substrate-invariant

**ggplot2 in R is the preferred and default target**: it is the reference implementation
of the layered grammar and the only one this repo renders live (R is the only
runtime checked by the preflight). But it is one implementation of the grammar, not the grammar
itself. On request, compile the **same spec** to another implementation and present the
code alongside the ggplot2 version — showing the same instruction layers specified in
much the same way across packages and languages is the pedagogic point: the grammar is
substrate-invariant.

Targets, roughly in order of how cleanly the spec maps:

- **plotnine** (Python) — near line-for-line with ggplot2.
- **lets-plot** (Kotlin / Python / JS) — a deliberate ggplot2 clone; the closest
  translation outside R itself.
- **Vega-Lite** (JSON, JS ecosystem) — true grammar semantics but different vocabulary
  (`mark`/`encoding`/`layer`); the renaming exercise is itself instructive.
- **AlgebraOfGraphics.jl** or **Gadfly.jl** (Julia) — AoG is the modern, Makie-backed
  choice with an explicitly algebraic take on layers; Gadfly is older and directly
  Wilkinson-inspired but less maintained.
- **plotly** (JS / Python / R) — layered traces but *not* a true grammar: no stat/geom
  separation, no scale-and-guide algebra. Where the spec won't translate, say so — the
  friction shows what a grammar *is* by contrast.

**Converting a rendered chart is a translation too, and it is not automatically
faithful.** When a chart is converted to another library (for example
`plotly::ggplotly()` to make it interactive), render both versions and compare them
before presenting the conversion as "the same chart". Check, category by category:
which categories and how many rows are drawn, which symbols are filled or outline-only,
which layer is drawn on top, and what the legend lists. Report every difference. Known
`ggplotly()` differences: it draws rows that ggplot2 dropped (for example, categories
past the six-shape palette, or missing values on shape), using a default filled circle;
it turns ggplot2's line-only shapes into "open" symbols; and its last trace, often the
missing-value category, is drawn on top of the others. In session 3 (2026-11-10), grey
missing-value circles drawn inside open symbols looked like grey fills with coloured
edges, and the agent didn't catch it.

Name the places where a translation is *not* clean (e.g. Vega-Lite's `transform` vs dplyr
pre-processing, plotnine lacking a native `okabe-ito` shorthand) — the rough edges are
teaching material too. Non-ggplot2 targets are presented as code; only render them if the
needed runtime happens to be available and the group asks.

## Worked example

`specs/penguins-example.yml` compiled in `example-gg-spec.qmd` at the repo root shows the
full round trip: spec → code → figure → a revision after looking.

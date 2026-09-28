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
2. **Validate before compiling.** If the spec asks for something incoherent (a colour
   mapping to a variable that doesn't exist, a `stat: lm` on a discrete y), say what is
   wrong *in grammar terms* and suggest the nearest coherent spec. Do not silently fix it —
   the misunderstanding is teaching material.
3. **Compile to idiomatic ggplot2** — code a reader could have written by hand: one
   `ggplot()` call, layers in spec order, `labs()` from the `labs:` block, no dead
   arguments. Preserve spec order in the code so spec and code can be read side by side.
4. **Render and look.** Run the code with framework R
   (`/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/bin/Rscript`), save a
   PNG at the site's geometry (9×6 in, dpi 150), and **read the PNG** before presenting
   it. Check: title fits (~60 chars max at base_size 13), legend not colliding, overplotting,
   unlabelled axes.
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
geom/stat → scales → facets → coords → labs/theme. At each slot:

1. State the current value, or the ggplot2 default if the slot is empty ("no scales block
   yet, so the default hue scale"). Defaults are decisions too.
2. Offer **at most three** options, taken from the variables the data description
   (`tt-fetch`) flagged, not from the whole of ggplot2. Anything beyond them is the room's
   to propose.
3. Ask one question, then wait.

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
    stat: lm              # stat/position where they matter
    se: true
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

Named scale shorthands: `okabe-ito` → `scale_colour_manual(values = palette.colors(palette = "Okabe-Ito"))`;
`viridis` → `scale_colour_viridis_d()` / `_c()` as the variable type dictates;
`log10` → `scale_<aes>_log10()`; `percent` → `scale_<aes>_continuous(labels = scales::percent)`.
Anything else the group wants: accept a verbatim `scale_*()` call as the value.

Unknown keys are an error, not a guess — surface them. Missing optional blocks mean
ggplot2 defaults, and it is worth saying so out loud ("no scales block, so ggplot's
default hue scale — do we want that?"): defaults are decisions too.

## Other targets — the grammar is substrate-invariant

**ggplot2 in R is the preferred and default target**: it is the reference implementation
of the layered grammar and the only one this repo renders live (framework R is the only
runtime guaranteed here). But it is one implementation of the grammar, not the grammar
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

Name the places where a translation is *not* clean (e.g. Vega-Lite's `transform` vs dplyr
pre-processing, plotnine lacking a native `okabe-ito` shorthand) — the rough edges are
teaching material too. Non-ggplot2 targets are presented as code; only render them if the
needed runtime happens to be available and the group asks.

## Worked example

`specs/penguins-example.yml` compiled in `example-gg-spec.qmd` at the repo root shows the
full round trip: spec → code → figure → a revision after looking.

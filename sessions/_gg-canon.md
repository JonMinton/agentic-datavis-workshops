# The grammar-of-graphics canon — standing reading list

Linked from each session's `intro.md`. Ordered by how useful each is for *this* series:
searchable, linkable sources first, the paywalled origin last. Sources whose full text
lives in a public GitHub repo are marked **(greppable)** — Claude can search them
directly during prep or a session.

## Core

- **Wickham, "A Layered Grammar of Graphics" (JCGS, 2010)** —
  <https://vita.had.co.nz/papers/layered-grammar.html> (open PDF, ~25 pp). The bridge
  from Wilkinson's grammar to ggplot2's layered version; the single best thing to read
  before the series. Defines the vocabulary the gg-spec schema uses.
- **ggplot2: Elegant Graphics for Data Analysis, 3rd ed.** —
  <https://ggplot2-book.org> **(greppable: `hadley/ggplot2-book`)**. The book-length
  treatment; its part structure (layers → scales → grammar → …) roughly mirrors the
  series arc, so most sessions can point at one chapter.
- **ggplot2 reference** — <https://ggplot2.tidyverse.org/reference/>. Function docs
  indexed by grammar component (geoms, stats, scales, guides, facets, coords, themes) —
  the lookup target during live sessions.

## Supporting

- **R for Data Science, 2nd ed., visualisation chapters** — <https://r4ds.hadley.nz>
  **(greppable: `hadley/r4ds`)**. The gentle on-ramp to point new participants at.
- **Posit ggplot2 cheatsheet** —
  <https://rstudio.github.io/cheatsheets/html/data-visualization.html> (HTML version, so
  linkable/parseable, not just a PDF). One page of the whole grammar; good screen-share
  material when someone asks "what geoms are there?".
- **Vega-Lite docs** — <https://vega.github.io/vega-lite/docs/>. The grammar with
  different vocabulary (`mark`/`encoding`/`layer`) and a formal JSON schema — the
  reference for substrate-invariance discussions and second-language ports.
- **plotnine docs** — <https://plotnine.org>. The Python port's docs, near
  section-for-section with ggplot2's.

## Origin

- **Wilkinson, *The Grammar of Graphics*, 2nd ed. (Springer, 2005)** — the canonical
  source, but paywalled and not searchable online. Cite it; read Wickham 2010 for the
  working version of its ideas. (Wickham 2010 §2 summarises Wilkinson's grammar
  faithfully enough for session purposes.)

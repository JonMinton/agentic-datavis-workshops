# Live session mode

Read this before anything else when live mode is on. It applies for the whole
session, on top of `AGENTS.md` and the skills. Live mode is for a facilitator driving
a shared screen in front of an audience, often a large one that doesn't code. Every
second the agent spends on work nobody asked for is dead air for the room.

The session folder is `sessions/YYYY-MM-DD/`. When live mode was switched on with
`sh scripts/workshop live on`, its date is in `.live-session` at the repo root.

## 1. Data: TidyTuesday only

- Use only TidyTuesday weeks. Start with the weeks already cached in `data/`, as listed
  in the session's `shortlist.md` if there is one.
- Fetch another TidyTuesday week only when the room names it, and only with
  `sh scripts/workshop r scripts/tt_fetch.R YYYY-MM-DD`.
- No web search, no other websites, and no data from anywhere else, **unless the
  facilitator explicitly says so in this session**. If a request can't be met from
  TidyTuesday, say so in one line and offer the nearest cached week.

## 2. One output: the session `.qmd`

- At the first step, copy `_template.qmd` to `sessions/YYYY-MM-DD/<slug>.qmd`, and add
  the page to the render list in `_quarto.yml` straight away. That file is the session.
  The data description, every decision, every spec and every chart goes into it as you
  go, in the template's order.
- Specs go in `sessions/YYYY-MM-DD/specs/NN-<slug>.yml`, quoted in the `.qmd`. Figures
  are rendered by the `.qmd`'s own chunks. You may also save gg-spec's
  `figures/NN-<slug>.png` and `figures/latest.png`, and nothing else.
- **No other files during the session:** no `notes.md`, no extra markdown, no variant
  images, no scratch scripts in the session folder. Notes and the writeup's polish come
  after the session, from the `.qmd` and the specs.
- After each change, re-render that one page:
  `sh scripts/workshop quarto render sessions/YYYY-MM-DD/<slug>.qmd`.

## 3. One request, one change

- Do what was asked, render, and stop. Then give one line on what changed, one on what
  the render showed, and the next question.
- At most **one line** of possible next steps, and only if they're useful.
- Never fill a design slot on your own initiative: no unprompted specs, mappings, geoms,
  scales or extra charts. If the room asks you to propose something, label it "proposed by
  the agent" in the `.qmd`.
- Don't re-check what has already passed. One check of each render (look at the image) is
  enough.

## 4. Missing values stay missing

Never invent or impute a category, a value or a label. Show missing values as
"Not recorded", say how many there are, and ask the room what to do with them.

## 5. No installs

Don't install packages or software. If a package is missing, say so in one line and
offer the nearest chart that the installed packages can draw. `sh scripts/workshop
preflight --live` lists what's available.

## 6. Narrate the wait

Before each batch of tool calls, write one plain sentence that a non-coder can follow,
with a rough time: "Reading the data, about 20 seconds." Keep replies in the panel to
about five lines. The room should be watching the page and the chart, not the terminal.

## 7. If the session is interrupted

If a reply is cut off or the session has to restart, a new session continues from the
files: "Live mode. Continue session YYYY-MM-DD from `<slug>.qmd`." The `.qmd` and the
specs hold the state. Facilitators: ask for "the decisions and code in the `.qmd`"
rather than for the agent's reasoning or workings.

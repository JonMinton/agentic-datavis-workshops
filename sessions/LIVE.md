# Live session mode

Read this before anything else when live mode is on. It applies for the whole
session, on top of `AGENTS.md` and the skills. Live mode is for a facilitator driving
a shared screen in front of an audience, often a large one that doesn't code. Every
second the agent spends on work nobody asked for is dead air for the room.

The session folder is `sessions/YYYY-MM-DD/`. When live mode was switched on with
`sh scripts/workshop live on`, its date is in `.live-session` at the repo root.

**Live mode needs a fresh agent session.** Its settings (medium effort, no web search,
no installs) and hooks load only when a session starts. If live mode was switched on
after your session began (you didn't see the contract at start-up, or `.live-session`
appeared mid-conversation), say so in one line and recommend that the facilitator start
a new session with "Live mode. Continue session YYYY-MM-DD from `<slug>.qmd`." Until
then, follow this contract by instruction. In session 3 (2026-11-10) live mode was
switched on mid-session, so the agent ran at high effort and the room waited longer.

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

## 4. Missing values: ask what they mean

Never invent or impute a category or a value. When a mapped variable has missing values
(the spec check reports `missing-values`), say how many there are and what empty means
in this dataset, if the readme says. Then ask the room to choose: label them (with that
meaning, or "Not recorded"), drop them, or keep ggplot2's default. Record the choice in
the spec's `missing:` block. Until the room chooses, gg-spec shows a category's missing
values as "Not recorded". Never show them as a bare "NA", which reads like an error:
in session 3 an empty `founder_crop` meant "not a founder crop", and the chart said "NA".

## 5. Questions about a chart: repeat back what is meant

When the room asks about a feature of a chart ("the cluster at the bottom", "that
vertical line", "the dip in 2008"), first say which feature you take it to be, with
coordinates or values: "The vertical line of sites at about 35°E, between 30°N and
33°N?" Wait for a yes before answering. Questions are relayed by voice and retyped, so
they drift: in session 3 the room asked about longitude 35°E, the prompt said 45°E, and
the agent answered about the wrong cluster.

## 6. No installs

Don't install packages or software. If a package is missing, say so in one line and
offer the nearest chart that the installed packages can draw. `sh scripts/workshop
preflight --live` lists what's available.

## 7. Narrate the wait

Before each batch of tool calls, write one plain sentence that a non-coder can follow,
with a rough time: "Reading the data, about 20 seconds." Keep replies in the panel to
about five lines. The room should be watching the page and the chart, not the terminal.

## 8. If the session is interrupted

If a reply is cut off or the session has to restart, a new session continues from the
files: "Live mode. Continue session YYYY-MM-DD from `<slug>.qmd`." The `.qmd` and the
specs hold the state. Facilitators: ask for "the decisions and code in the `.qmd`"
rather than for the agent's reasoning or workings.

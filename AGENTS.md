# Agentic data-vis workshops — agent instructions (canonical)

This file is the single source of truth for **any** coding agent working in this repo,
whatever the vendor. Claude Code loads it via the `@AGENTS.md` import in `CLAUDE.md`;
most other agent CLIs read `AGENTS.md` natively. Edit this file, not `CLAUDE.md`.

This public repo is the home of **occasional, facilitator-led workshops** on data
visualisation with an agentic AI assistant. It was started by Jon Minton for a
demonstration at a university data-vis lab on 2026-09-29. There is **no fixed schedule**
and no organising group: a follow-up session happens when someone offers to run one, and
different people may facilitate different sessions. Don't describe the workshops as a
meetup, a series with a cadence, or anything affiliated with an institution. Each
session uses a TidyTuesday (or equivalent) dataset to teach data visualisation principles, grounded in Wilkinson's **grammar of
graphics**, mainly in R (ggplot2) with occasional excursions into JS (Vega-Lite) and
Python (plotnine).

This is **not** an autonomy experiment (that lives in `claude-fable-vision-ds-test`, whose
conventions this repo inherits). Here every design decision is made live by humans in the
session; the assisting agent's roles are (a) compiling participant-specified plot specs
during sessions via the `gg-spec` skill, and (b) drafting the post-session writeup for the
facilitators to approve.

**Autonomy default: the analyst decides.** In a session, every graphic design decision
belongs to the humans. The agent fetches, describes, types, renders, and reports what the
render shows; it does not choose a mapping, geom, or scale on its own initiative.
Fully autonomous exploration, where the agent picks the dataset, the question, and the
figures (as in the public `claude-fable-vision-ds-test` repo), is an inspiration and a
point of contrast. It is used only when a facilitator explicitly asks for it, and its
output is labelled as autonomous.

**Vendor-neutral by design.** Sessions run with Claude Code, Codex, or both side by side,
and the repo must work identically with either. Don't write one vendor's name into a
procedure; say "the agent". University-hosted sessions must not promote a paid AI tool,
and should mention the University's own ELM gateway.

## For agents other than Claude

The conventions here are agent-neutral; a few mechanics are not:

- **Skills live in `.claude/skills/`, and `.agents/skills/` holds symlinks to them.**
  Codex discovers skills in `.agents/skills/` (checked 2026-09-28: Codex lists `gg-spec`,
  `tt-fetch`, and `dataset-scout`), and Claude Code finds them in `.claude/skills/`, so both agents
  load the same files. **Edit the real files under `.claude/skills/`, never copies.**
  A new skill needs a matching symlink:
  `ln -s ../../.claude/skills/<name> .agents/skills/<name>`. Agents that load neither
  location should read the `SKILL.md` files as plain-markdown procedures.
- **Minimum capabilities** to run a session: shell access, file editing, and **image
  reading** — "render, then look" steps are load-bearing and need vision.
- The Pocket MCP transcription backup is tied to Jon's account; guest-led sessions need
  their own backup arrangement (or note Zoom-only in `notes.md`).
- Run `sh scripts/workshop preflight` before a session. Use the same wrapper for R
  and Quarto so both select the same installation. See `README.md` for setup and
  `sessions/agent-acceptance.md` for the manual cross-agent rehearsal.
- New facilitators should follow `sessions/facilitator-guide.md`. Licence scope is
  in `LICENSE.md`: MIT code, CC BY 4.0 original materials, source licences for data
  and third-party assets.

## The series arc

Sessions are anchored to **grammar layers**, not just datasets. The dataset is the vehicle;
the layer is the lesson. Rough sequence (revisited and reordered as the series finds its
feet):

1. Data & aesthetic mappings
2. Geoms and stats
3. Scales and guides
4. Facets
5. Coordinates and position
6. Annotation and themes
7. Composite / participant-led sessions

Pick datasets because they *stress* the session's layer, not because they are interesting
in general.

## The post genre — process-led, not argument-led

Each session produces one page, drafted by the agent from the session artefacts and
approved by that session's facilitator(s) before publishing. Unlike essay-style
TidyTuesday writeups, the genre here is a **record of decisions**:

dataset → question → **the design decisions as decisions** (what was considered, what was
chosen, why) → pain points → lessons learned → what the data can't say.

Start every new post from `_template.qmd`. The evolving `gg-spec` YAML files are quoted in
the post verbatim — they *are* the record of the design decisions.

## Provenance and authorship

Every page opens with a badge (`callout-tip`, `icon=false`) naming the session number,
date, facilitators, and **consenting named participants**:

```markdown
::: {.callout-tip icon=false}
## Session N · YYYY-MM-DD · facilitated by <facilitator(s)>
With [named participants]. Design decisions were made live by the group; the writeup was
drafted by [agent/model name] from [the actual session artefacts used] and approved before publishing.
[How these sessions work](index.qmd).
:::
```

Name the actual drafting model in the badge — provenance is part of the genre.

**Consent rules — hard constraints:**

- **Chatham House Rule by default.** Writeup prose never attributes a view, suggestion,
  or mistake to an individual — "the group decided", "a participant suggested" —
  regardless of whether that person is named on the page. Naming is credit only. The
  sole exception is an explicit per-person attribution opt-in in the consent record,
  used sparingly.
- A participant may only be **named** on a page if a per-session consent record exists in
  that session's folder (`sessions/YYYY-MM-DD/consent.md`). No record, no name — refer to
  "a participant" instead. The committed consent record is itself public: list
  only people who agreed to public naming; keep declined names and private evidence
  outside the repo.
- Any recording requires announced consent at the start of the session; note the
  announcement and tools used in `notes.md`. Recording is optional; specs and decision
  notes can supply the writeup. Pocket is Jon's optional backup, not a guest prerequisite.
- **Raw transcripts and chat exports are never committed** — they carry speaker labels,
  and the repo is public. `.gitignore` covers
  `sessions/**/transcript*.txt`, `chat*.txt`, and `*.vtt`; never force-add them. They
  live in the agreed private storage as accuracy sources for drafting only.

## Session folder pipeline

Each session gets `sessions/YYYY-MM-DD/` containing, as available:

- `intro.md` — the structured session intro (from `sessions/_intro-template.md`): layer,
  success criterion, anti-goal, dataset, standing work-approach and output sections
- `notes.md` — agenda, dataset, grammar layer, consent announcement noted
- `consent.md` — who may be named (from `sessions/_consent-template.md`)
- `transcript.txt` / `chat.txt` — Zoom transcript and chat export (**local only, never
  committed** — gitignored; Pocket holds the backup transcription)
- `specs/` — the gg-spec YAML files as they evolved during the session
- data pulls are cached in the top-level `data/` as usual

The writeup is drafted **from these artefacts**, not from memory. (Pocket transcripts are
reachable via the Pocket MCP tools as a backup source.)

## Page conventions (inherited from the parent experiment — battle-tested)

- **Cache the data.** Write the raw pull to `data/<slug>.csv` and read from there, so pages
  re-render years later. Cite the source with a real link, in a collapsed
  "Reproducing this page" callout containing the refresh code.
- **Numbers in prose are inline `r` expressions.** Any figure a reader could check against
  a chart is computed in the document, not transcribed into it. Qualitative comparisons
  stay as prose. This matters doubly here: writeups are AI-drafted, and inline `r` is what
  stops draft and chart drifting apart.
- **Chart titles must fit.** At 9-inch figure width with `base_size = 13`, a bold title
  longer than ~60 characters is clipped at the panel edge with no warning. Keep titles
  short or add a `\n`. Check every title in the rendered PNG, not just in the code.
- **Render, then look.** Open the rendered page (browser or the PNGs under
  `_freeze/<page>/figure-html/`) before calling it done. Log what looking caught — those
  catches feed the "pain points" section.
- **Say what the data can't say.** Every page ends with a limits passage naming the
  confounder, the censoring, or the too-short record.
- Code chunks are folded site-wide (`code-fold: true`) — write them to be read.
- Add each new page to `index.qmd` with a one- or two-sentence hook.

## Toolchain (Jon's machine — see "For agents other than Claude" if elsewhere)

- **IDE: Positron** (1.124 as of 2026-09-28), a VS Code fork that pulls extensions from
  Open VSX. Both agent extensions are installed there: **Claude Code**
  (`anthropic.claude-code`) and **Codex** (`openai.chatgpt`). Install either one with
  `/Applications/Positron.app/Contents/Resources/app/bin/code --install-extension <id>`,
  or through the Extensions view. The Codex extension uses the same login and
  `~/.codex/config.toml` as the `codex` CLI. The repo's `.codex/config.toml` turns on
  network access in Codex's workspace sandbox, which blocks it by default and would
  break tt-fetch (confirmed 2026-09-28). `.claude/settings.json` pre-approves the R and
  render commands. These are separate permission systems: network configuration does
  not grant command approval. Rehearse the actual commands in each agent before the room arrives.
- **Live layout:** the spec YAML and `figures/latest.png` sit side by side in the editor
  area. One agent panel goes in the secondary side bar, and the other agent, if both are
  in use, goes in the panel or as an editor tab. The terminal stays minimised. Positron's
  Console, Variables and Plots panes belong to the humans (see "Working live" below).
- **R:** framework R 4.5.2 at
  `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/bin` — the only install
  with the full tidyverse. The default `Rscript` on `PATH` is a stale anaconda R 4.1.1;
  homebrew R (which Quarto would pick by default) has no tidyverse.
  `sh scripts/workshop` prefers the framework installation when present, unless
  `WORKSHOP_RSCRIPT` or `QUARTO_R` is explicitly set. Use
  `sh scripts/workshop r scripts/describe_data.R data/penguins.csv` for R and
  `sh scripts/workshop quarto render <page>.qmd` for rendering.
- **Available packages:** tidyverse, `ggridges`, `ggdist`, `patchwork`, leaflet, `yaml`,
  `plotly`, `broom`.
- **Render gotcha:** rendering several files in one `quarto render a.qmd b.qmd` command can
  leak the wrong `<title>` into a page. **Render each changed page individually**, then
  verify with `grep '<title>' docs/<page>.html`.
- **Publishing:** GitHub Pages serves from `docs/` on `main`, so `docs/` and `_freeze/` are
  **committed, not ignored**. A change isn't live until the rendered HTML is committed.
  The repo is **public**, so anything committed is published: never commit transcripts,
  chat exports, or names without a consent record. Site:
  https://jonminton.github.io/agentic-datavis-workshops/

## Working live with the facilitators

Pure separation, as in the parent repo: humans drive the interactive console and the
conversation; the agent works on files, specs, renders, shell and git. Handoff is
pull-based — act on what is pasted or pointed at; don't mirror or reconstruct the live R
session.

During live sessions the **Zoom chat is a prompt channel**: participants who prefer
typing post spec edits or instructions in chat, and the facilitator pastes them to the
agent verbatim. Treat a pasted chat message like any dictated decision — record it in the
spec, don't name its author in any writeup (Chatham House default).

The realtime layer of a session is the **artefact trail** (numbered specs, compiled
code, rendered figures, decisions and pain points logged live in `notes.md`) — not
prose. The writeup is drafted from the artefacts and transcripts immediately *after* the
session, aiming for a same-day draft for approval.

## The tt-fetch skill

`.claude/skills/tt-fetch/` fetches the TidyTuesday week the room chose, caches every CSV
to `data/` through `scripts/tt_fetch.R`, and describes it with `scripts/describe_data.R`:
the grain, each variable's type in grammar terms, level counts and missingness. It then
*proposes* candidate aesthetics for gg-spec. Proposing is as far as it goes: choosing
belongs to the room. The helper scripts are deterministic, so Claude Code and Codex
produce the same description. When the network fails, use what is already cached in `data/`.

## The gg-spec skill

`.claude/skills/gg-spec/` — compiles a declarative YAML plot spec into idiomatic ggplot2
(the default target; other grammar implementations on request), renders it, and shows the
result. Used live during sessions as participants dictate mapping decisions. Its
**interactive mode** walks the grammar one slot at a time (at most three options per slot,
then the agent waits), and keeps `sessions/<date>/figures/latest.png` current so the room
watches the spec and the figure, not the terminal. See the
skill file for the spec schema and `example-gg-spec.qmd` for a worked example.

## The dataset-scout skill

`.claude/skills/dataset-scout/` — searches dataset catalogues (TidyTuesday, Rdatasets,
and Wonderful Wednesdays) for candidates that stress a named grammar layer, checks
licences, and recommends two or three. Recommendation only — the
facilitators choose. The standing grammar-of-graphics reading list is `sessions/_gg-canon.md`.

## Session log

| Session | Date | Grammar layer | Dataset | Page |
|---|---|---|---|---|
| 1 | 2026-09-29 | Data & aesthetic mappings | TidyTuesday 2020-03-17, The Office | `sessions/2026-09-29/office-data.qmd` (v2: `office-data-v2.qmd`) |

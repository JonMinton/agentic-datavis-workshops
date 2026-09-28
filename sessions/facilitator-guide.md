# Leading a session

Anyone preparing a session can use this checklist with the setup in
[`README.md`](../README.md). Sessions are occasional and independently facilitated;
there is no fixed schedule or organising group. Choose a scope that fits your room.

## Before the session

1. Choose one grammar layer, a checkable learning outcome, and an anti-goal. The
   [reading list](_gg-canon.md) and [intro template](_intro-template.md) provide a start.
   Ask `dataset-scout` for two or three candidates if needed; the facilitator or room
   chooses. Check provenance and redistribution permission before caching new data.
2. Run `sh scripts/workshop preflight` and the
   [agent acceptance exercise](agent-acceptance.md) on the actual machine and account
   you will use. Check projector readability, image inspection, command approvals,
   and access to the agent service. Use an institution-approved service where needed;
   the live workflow still requires shell access, file editing, and image reading.
   A chat-only interface can discuss the spec while a human runs and inspects code.
3. Fetch the chosen dataset in advance and keep a cached fallback such as penguins.
   Open the worked example and its rendered figures before the session. Cached data
   avoids a data-download dependency; it does not make a hosted agent work offline.
   If the agent service is unavailable, use the worked example as a human-led
   walkthrough, or run an already-rehearsed local agent.
4. Create the session folder and fill in the templates. For example, replace
   `YYYY-MM-DD` below with the actual date:

   ```sh
   mkdir -p sessions/YYYY-MM-DD/specs sessions/YYYY-MM-DD/figures
   cp sessions/_intro-template.md sessions/YYYY-MM-DD/intro.md
   cp sessions/_consent-template.md sessions/YYYY-MM-DD/consent.md
   ```

   Add `notes.md` with the agenda, grammar layer, dataset/source, facilitator,
   runtime/package versions from preflight, agent/model, and recording plan.
   Do not pre-populate public files with attendee names awaiting consent.
5. Arrange recording only if needed and with announced consent. Use your own approved
   recording/transcription setup; Jon's Pocket account is not shared infrastructure.
   No recording is a valid choice: keep sufficiently detailed specs and decision notes
   for a writeup. Keep any private consent evidence or raw recordings outside the repo.

## In the room

Explain that people make the design decisions and the agent executes them. Read the
intro, explain Chatham House treatment, announce any recording, and record the consent
announcement in `notes.md`. Ask separately about public naming and named attribution.
The committed `consent.md` is public: include only people who agreed to public credit.
Do not list a declined name in a row marked “no”.

Describe the dataset with `tt-fetch`, then use `gg-spec` interactively: data and grain,
question, mappings, layers, scales, facets, coordinates, labels/theme. Give each slot
to the room; announce defaults. Keep the current YAML and `figures/latest.png` visible
side by side. Save numbered specs and figures as decisions evolve, and retain compiled
R alongside the corresponding spec so another facilitator can rerun it.

Log the reason for each revision, unresolved questions, rendering problems, and what
the figures cannot establish. Record views anonymously even when contributors have
agreed to public credit. Typed contributions can be pasted from any agreed chat channel;
Zoom is optional. One agent is sufficient. If using two, assign files or take turns
so neither overwrites the other's live work.

## After the session

Draft from the artefact trail, with a transcript only if one was consensually made.
Aim for a prompt draft while decisions are fresh; agree the review/publication timing
with the facilitator rather than promising a deadline to participants.

1. Copy `_template.qmd` to a new root-level page
   (from the repo root: `cp _template.qmd session-YYYY-MM-DD.qmd`). Name the actual
   drafting agent/model and the artefacts used. Quote the session specs verbatim,
   calculate checkable prose numbers with inline R, and include the limits passage.
2. Have the facilitator review the draft and confirm naming consent. Record the
   approval date and approved page in the session notes. An agent-generated draft is
   not approval to publish.
3. Add the page and a short hook to `index.qmd`, and add the completed session to
   the session log in `AGENTS.md`. Render each changed page separately:

   ```sh
   sh scripts/workshop quarto render session-YYYY-MM-DD.qmd
   sh scripts/workshop quarto render index.qmd
   ```

   Inspect the rendered page and figures, including titles, labels, links, and the
   provenance badge. Log any corrections prompted by looking.
4. Review `git status` and the staged diff before committing. Include source pages,
   specs, compiled code, publishable notes/consent, permitted cached data, and changed
   `docs/` and `_freeze/` outputs. Never commit raw transcripts, chat exports,
   recordings, private consent evidence, or unconsented names. `.gitignore` covers
   the documented transcript/chat filenames; it cannot identify every sensitive file.
5. Submit the branch as a pull request to the original repo, noting the facilitator's
   approval and render checks. It goes live on the original site only after the
   appropriate changes are merged into `main`; do not assume upstream push access.

For a separately hosted fork, deliberately change the site title and repository links
in `_quarto.yml` and the attribution/contact text as appropriate, then arrange your
own hosting. The original repo serves GitHub Pages from `docs/` on `main`; a clone or
fork alone does not configure your own deployment. Follow [the licence scope and
attribution guidance](../LICENSE.md) when adapting the code and materials; retain
dataset and third-party notices.

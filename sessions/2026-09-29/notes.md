# 2026-09-29 — VisHub group meeting demonstration

Room 1.70, Edinburgh Futures Institute, 12:30–13:30, in person. Audience: VisHub lab
(information-visualisation researchers; mixed agentic experience; they asked for critical
feedback). Plan: 5–10 min concepts (`slides/2026-09-29-vishub.qmd`), 30+ min live
visualisation of a dataset the room chooses (`shortlist.md`), 5–15 min summing up.

Grammar layer: **1. Data & aesthetic mappings** (the first layer; the dataset is chosen
live, so no other layer can be assumed).

## Standing constraints for this talk

- **Vendor-neutral:** Claude Code and Codex run side by side and are named only as
  interchangeable examples, with no endorsement of either. Mention ELM, the University's
  own AI gateway, once. No business pitch.
- **Analyst decides** (AGENTS.md): the room makes every design decision; gg-spec runs
  in interactive mode. Autonomous mode appears only as the contrast slide.
- **Recording and naming:** decide at the start. If recording, announce it and note the
  announcement here. Naming anyone on a later page needs `consent.md` (copy
  `../_consent-template.md`). Chatham House by default either way.

## Pre-flight (arrive 12:05)

- [ ] Wifi up. If it isn't, the three shortlist datasets are already cached in `data/`
      and both agents need the network anyway, so fall back to penguins +
      `example-gg-spec` as a walkthrough.
- [ ] `git pull`, then open the repo folder in Positron (not a parent folder, or the
      skills won't load).
- [ ] Run `sh scripts/workshop preflight`; use the wrapper for R and Quarto.
      Rehearse `sessions/agent-acceptance.md` in each intended agent.
- [ ] Both agent extensions signed in: Claude Code panel, Codex panel. In each, ask
      "which skills do you have?" and expect tt-fetch, gg-spec and dataset-scout.
- [ ] Codex trusts the folder (first-run prompt in the panel) and its approval mode lets
      it run `Rscript` without a prompt for every render.
- [ ] Editor layout: left = current spec YAML, right = `sessions/2026-09-29/figures/latest.png`.
      Terminal minimised. Zoom level readable from the back row (Cmd +, twice).
- [ ] Slides open in a browser tab: `docs/slides/2026-09-29-vishub.html`.

## Live flow

1. The room picks from `shortlist.md`, or names any other TidyTuesday week.
2. **Agent A** (tt-fetch): fetch, cache, describe. Read the description aloud: the grain,
   the types, the candidate aesthetics.
3. **Agent B** (gg-spec, interactive): data & grain → question → x, y → one further
   aesthetic → geom/stat → render. Then the room revises. Two or three rounds.
4. Optional contrast: give the *same* spec to the other agent and compare the code.
   The grammar is substrate-invariant; so should the output be.
5. If the room chose "How likely is 'likely'?", compare against the autonomous page in
   `claude-fable-vision-ds-test` (`probability-phrases`).

## Decisions and pain points (log live)

- Format on the day: hybrid, not in person only. Six or seven attendees: two in the
  room, the rest remote. No recording and no transcript. No consent record, so no one
  is named on the session page.
- The room chose TidyTuesday 2020-03-17, The Office. Specs are in `specs/` (01 heatmap,
  02 rating over air date), and the workbook page is `office-data.qmd`.
- Spec 02: shape by season was dropped (6 default shapes, 9 seasons). Season mapped as
  `factor(season)` to colour, with one smoother per season.
- Facilitator reflections and next steps are at the end of `office-data.qmd`.

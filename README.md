# Agentic data-vis workshops

Occasional, facilitator-led workshops on the grammar of graphics. People choose the
data and every graphic design decision; the agent fetches, describes, codes, renders,
and inspects the result. See [the workshop site](https://jonminton.github.io/agentic-datavis-workshops/)
and [AGENTS.md](AGENTS.md) for the working conventions.

## Start from a clone

The facilitator needs the working environment; participants can contribute through
the shared screen and conversation without installing anything. An IDE is optional.
You do not need Jon's accounts or two agents running side by side.

With Git installed:

```sh
git clone https://github.com/JonMinton/agentic-datavis-workshops.git
cd agentic-datavis-workshops
```

Open this repository folder in your chosen editor/agent, rather than its parent.
If you intend to contribute changes without upstream write access, fork the repo
first and clone your fork instead. Use a branch for your session work.

Complete the setup below, then follow [Leading a session](sessions/facilitator-guide.md).
That guide covers preparation, consent, the live workflow, and contributing a writeup.
The dated demonstration notes are an example, not a schedule or requirement for
future facilitators.

## Setup

Use an agent with shell access, file editing, and image reading. Automatic skill
discovery is convenient, but an agent can also read `AGENTS.md` and the three
`.claude/skills/*/SKILL.md` files explicitly. `.agents/skills/` links to those same
files; preserve symlinks when cloning. The skills do not require an account-specific
connector. Pocket transcription is an optional backup, not a prerequisite.

Install R >= 4.5.0 (reference environment: 4.5.2), Quarto, and a POSIX shell. On
Windows, use WSL with R and Quarto installed inside WSL. From the repository root:

```sh
sh scripts/workshop preflight
```

Runtime selection, in order:

1. `WORKSHOP_RSCRIPT`: an explicit absolute path to the Rscript executable.
2. `QUARTO_R`: an explicit R binary path or directory containing R and Rscript.
3. Jon's framework R 4.5 installation, if present on macOS.
4. `Rscript` on `PATH`.

An invalid explicit selection fails; it does not silently switch installations.
For example, set `export WORKSHOP_RSCRIPT=/opt/R/4.5.2/bin/Rscript` in your shell.
Keep machine-specific paths out of the shared `_environment` file.

If packages are missing, install them in the selected R installation:

```sh
sh scripts/workshop r -e 'install.packages(c("tidyverse", "yaml", "knitr", "rmarkdown"), repos="https://cloud.r-project.org")'
```

Optional packages for sessions that use them: `ggridges`, `ggdist`, `patchwork`,
`leaflet`. The preflight reports their availability without requiring them.
There is no package lockfile yet: the preflight prints installed versions so a
rehearsal can record its actual environment. This is a compatibility check, not a
promise of pixel-identical output across package versions or operating systems.

## Run the shared workflow

```sh
sh scripts/workshop r scripts/tt_fetch.R 2025-08-19
sh scripts/workshop r scripts/describe_data.R data/penguins.csv
sh scripts/workshop quarto render example-gg-spec.qmd
```

The wrapper passes the selected R directory to Quarto. Use it for both R and Quarto;
calling either directly can select a different installation. Render one page per
command. Page rendering updates the committed `docs/` and `_freeze/` artefacts;
inspect the output before publishing.

Preflight checks the runtime, core packages, shared skill paths, cached penguins
fixture, and write access to data/session/site-output directories. It does not
download data, install packages, render the site, or test the agent's permissions,
vision, or network. The fetch helper can reuse cached data when listing fails;
an uncached week still needs network access.

Permission settings are agent-specific. `.claude/settings.json` and
`.codex/config.toml` serve different purposes; enabling network access does not
grant command approval. Rehearse these exact wrapper commands in each intended
agent, with its normal approval settings. Do not disable safeguards to make the
check pass. Account and host policy can override project settings.

Before facilitating with a new agent or machine, run the
[cross-agent acceptance exercise](sessions/agent-acceptance.md). Equivalent data,
mapping, statistical and interaction behaviour matters; identical generated source
formatting does not.

## Reuse and contributions

Session contributions are reviewed before publication. Include source, specs,
approved session notes, and rendered outputs; see the facilitator guide for the
handoff checklist. Cloning or opening a pull request does not publish to the main
workshop site.

Original code is licensed under MIT; original workshop text, slides, and figures
are licensed under CC BY 4.0. See [LICENSE.md](LICENSE.md) for scope, attribution,
and exclusions. Dataset sources and bundled third-party assets retain their own
licences; the dataset-scout workflow checks permission to cache and redistribute
each proposed dataset. Contributions should use the applicable licence and preserve
source attribution.

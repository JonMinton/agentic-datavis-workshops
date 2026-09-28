# Session artefacts

Start with [Leading a session](facilitator-guide.md) for the complete facilitator
handoff, or [agent acceptance](agent-acceptance.md) to rehearse a new setup.

One folder per session, named `YYYY-MM-DD/`, holding the raw material the writeup is
drafted from:

```
sessions/YYYY-MM-DD/
├── intro.md         # learning outcome and scope, from _intro-template.md
├── notes.md         # agenda, dataset, grammar layer; note the consent announcement
├── consent.md       # who may be named — copy _consent-template.md and fill in
├── transcript.txt   # Zoom transcript export: LOCAL ONLY, gitignored
├── chat.txt         # Zoom chat export: LOCAL ONLY, gitignored
├── specs/           # numbered gg-spec YAML files and corresponding compiled R
└── figures/         # the render of each spec, plus latest.png for the live view
```

Rules (also in `AGENTS.md`):

- The writeup is drafted **from these artefacts**, not from memory.
- A participant may only be **named** on a page if this folder's `consent.md` records
  agreement to public credit. The consent file is itself public: omit declined names
  and keep private evidence outside the repo. No record, no name.
- Named *attribution* of specific quotes or mistakes needs the stronger opt-in in the
  consent record, not just author naming.
- Data pulls go in the top-level `data/`, not here, so pages can read them.

This folder is not rendered by Quarto (it contains no `.qmd`), but it **is** committed:
the spec trail and notes are part of the project record. Transcripts and chat exports are
**never** committed (they carry speaker labels); if `notes.md` or a spec comment records
anything a participant asks to withhold, redact it before committing, because the repo may
is public.

# Keeping the agent panels available in Positron

Positron is a VS Code fork, but its agent extensions place their icons differently.
This note covers how to set it up before a session and how to recover in the room.
It was written on 2026-10-09 after both agent icons disappeared during a dry run.

## Why the icons disappear

In VS Code, the Claude Code and Codex icons usually sit in the activity bar on the left.
Positron supports a **secondary side bar**, so both extensions put their only entry
point there: `claude-sidebar-secondary` and `codexSecondaryViewContainer`. The
activity-bar versions are used only by editors without a secondary side bar.

**When the secondary side bar is closed, both icons disappear together.** The
extensions are still installed and working. They are hidden because the bar is
hidden.

Positron's layout controls make this easy to do by accident. Choosing a preset
layout, maximising the Console, or toggling the side bars can close the secondary
side bar. Positron saves the layout per workspace, so the icons stay hidden the next
time the folder is opened.

The 2026-10-09 dry run showed both causes:

- The workspace state recorded the secondary side bar as hidden, and the editor area
  was hidden too.
- The Claude Code extension had auto-updated (2.1.284 → 2.1.295) that afternoon.
  An extension that updates in the background needs a window reload before its views
  come back reliably.

## Recovery in the room (fastest first)

1. **Show the secondary side bar:** Command Palette (⇧⌘P) → *View: Toggle Secondary
   Side Bar Visibility* (VS Code default ⌥⌘B). Both icons come back.
2. **Open an agent directly**, wherever the layout is:
   - *Claude Code: Open in Side Bar*, or *Claude Code: Open in New Tab* (⇧⌘Esc). The
     plain ⌘Esc shortcut works only while an editor has focus, so it fails when the
     editor area is hidden.
   - *Codex: Open Codex Sidebar*, or *New Codex Agent* (opens as an editor tab).
3. **Reset the layout:** *View: Reset View Locations*, then step 1.
4. **Extension updated mid-session:** *Developer: Reload Window*. Specs and figures are
   files, so a reload loses nothing important. The agent conversation can be reopened
   from its history.
5. **Last resort:** run `claude` or `codex` in Positron's terminal. Both CLIs are
   installed and read the same skills. Make the terminal large enough to read on the
   projector.

## Before a session

- **Update deliberately, the day before.** Update both extensions, reload the window,
  and rehearse with `agent-acceptance.md`. Turning off automatic extension updates
  (`"extensions.autoUpdate": false`, a user setting) stops an update arriving during
  the session.
- **Set up the live layout and leave it saved.** The secondary side bar is open with the
  agent in it. The spec and `figures/latest.png` are side by side in the editor area.
  Positron saves this per workspace, so open the same folder in the room.
- **Check the icons are visible** as part of preflight's manual checks.

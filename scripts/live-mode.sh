#!/bin/sh
# Live mode switch, run through `sh scripts/workshop live ...` from the repo root.
# See sessions/LIVE.md for what live mode asks of the agent.
#
#   on [YYYY-MM-DD]  turn it on for that session (default: today)
#   off              turn it off and restore any previous local settings
#   status           say whether it's on
#   claude | codex   launch that agent's CLI with live settings (turn it on first)
set -eu

marker=.live-session
template=.claude/live-settings.json
local_settings=.claude/settings.local.json
backup=.claude/settings.local.json.pre-live

# Ours if it calls the live hook, even if the template has changed since 'live on'.
is_live_copy() { [ -f "$local_settings" ] && grep -q 'scripts/live_hook.R' "$local_settings"; }

action=${1:-status}
if [ "$#" -gt 0 ]; then shift; fi

case "$action" in
  on)
    session=${1:-$(date +%Y-%m-%d)}
    case "$session" in
      [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]) ;;
      *) echo "Session date must be YYYY-MM-DD, not '$session'." >&2; exit 1 ;;
    esac
    mkdir -p "sessions/$session/specs" "sessions/$session/figures"
    if [ -f "$local_settings" ] && ! is_live_copy; then
      if [ -f "$backup" ]; then
        echo "$backup already exists; restore or remove it before turning live mode on." >&2
        exit 1
      fi
      mv "$local_settings" "$backup"
      echo "Moved your existing $local_settings to $backup (restored by 'live off')."
    fi
    cp "$template" "$local_settings"
    printf '%s\n' "$session" > "$marker"
    echo "Live mode ON for sessions/$session/."
    echo "Claude Code: start a new session (the CLI or the editor panel) so the settings load."
    echo "Codex: launch with 'sh scripts/workshop live codex'."
    echo "Then check: sh scripts/workshop preflight --live"
    ;;
  off)
    rm -f "$marker"
    if is_live_copy; then
      rm "$local_settings"
    fi
    if [ -f "$backup" ]; then
      mv "$backup" "$local_settings"
      echo "Restored your previous $local_settings."
    fi
    echo "Live mode OFF. Start a new agent session to drop the live settings."
    ;;
  status)
    if [ -f "$marker" ]; then
      echo "Live mode ON for sessions/$(cat "$marker")/."
      if cmp -s "$local_settings" "$template" 2>/dev/null; then
        echo "Claude Code live settings: installed."
      elif is_live_copy; then
        echo "Claude Code live settings: installed but out of date (run 'live on' again)."
      else
        echo "Claude Code live settings: NOT installed (run 'live on' again)."
      fi
    else
      echo "Live mode OFF."
    fi
    ;;
  claude)
    [ -f "$marker" ] || { echo "Turn live mode on first: sh scripts/workshop live on YYYY-MM-DD" >&2; exit 1; }
    exec claude --effort medium "$@"
    ;;
  codex)
    [ -f "$marker" ] || { echo "Turn live mode on first: sh scripts/workshop live on YYYY-MM-DD" >&2; exit 1; }
    session=$(cat "$marker")
    exec codex --sandbox workspace-write \
      -c 'web_search="disabled"' \
      -c 'model_reasoning_effort="medium"' \
      "$@" \
      "Live mode is on for session $session. Read sessions/LIVE.md now and follow it for this whole session. Then wait for the facilitator."
    ;;
  *)
    echo 'Usage: sh scripts/workshop live {on [YYYY-MM-DD]|off|status|claude|codex}' >&2
    exit 1
    ;;
esac

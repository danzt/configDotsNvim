#!/bin/bash
# Live Claude Code session state for the nvim rail (lua/config/claude_rail.lua).
# Usage (hook command): claude-state.sh <working|tool|post|waiting|idle|end>
# Writes ~/.local/state/claude-state/<session>.json; the statusline writes <session>.status.json.
dir="${XDG_STATE_HOME:-$HOME/.local/state}/claude-state"
mkdir -p "$dir"
input=$(cat)
sid=$(jq -r '.session_id // empty' <<<"$input")
[ -z "$sid" ] && exit 0
f="$dir/$sid.json"

if [ "$1" = end ]; then rm -f "$f" "$dir/$sid.status.json"; exit 0; fi

prev='{}'
[ -s "$f" ] && prev=$(<"$f")

jq -c --arg ev "$1" --argjson prev "$prev" --argjson now "$(date +%s)" '
  . as $in
  | ($prev * {session: $in.session_id, cwd: $in.cwd, ts: $now}) as $s
  | if   $ev == "working" then $s * {state: "working", tool: null}
    elif $ev == "tool"    then $s * {state: "working", tool: $in.tool_name}
    elif $ev == "post"    then ($s * {tool: null})
                               | if $in.tool_name == "TodoWrite" then .todos = ($in.tool_input.todos // []) else . end
    elif $ev == "waiting" then $s * {state: "waiting"}
    elif $ev == "idle"    then $s * {state: "idle", tool: null}
    else $s end
' <<<"$input" >"$f.tmp" && mv "$f.tmp" "$f"

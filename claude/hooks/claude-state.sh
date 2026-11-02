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
  | ($in.tool_name // "") as $tn
  | ($in.tool_use_id // "") as $tid
  | ($prev * {session: $in.session_id, cwd: $in.cwd, ts: $now}) as $s0
  | ($s0 | .agents = [(.agents // [])[] | select($now - .ts < 1800)] | .jobs = [(.jobs // [])[] | select($now - .ts < 7200)]) as $s
  | if   $ev == "working" then $s * {state: "working", tool: null}
    elif $ev == "tool"    then ($s * {state: "working", tool: $tn})
                               | if ($tn == "Task" or $tn == "Agent") then .agents += [{id: $tid, desc: ($in.tool_input.description // ""), kind: ($in.tool_input.subagent_type // "agent"), ts: $now}]
                                 elif ($tn == "Bash" and ($in.tool_input.run_in_background // false)) then .jobs += [{id: $tid, cmd: (($in.tool_input.command // "") | .[0:60]), ts: $now}]
                                 else . end
    elif $ev == "post"    then ($s * {tool: null})
                               | if $tn == "TodoWrite" then .todos = ($in.tool_input.todos // [])
                                 elif ($tn == "Task" or $tn == "Agent") then .agents |= map(select(.id != $tid))
                                 else . end
    elif $ev == "waiting" then $s * {state: "waiting"}
    elif $ev == "idle"    then $s * {state: "idle", tool: null}
    else $s end
' <<<"$input" >"$f.$$.tmp" && mv "$f.$$.tmp" "$f"

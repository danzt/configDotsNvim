#!/usr/bin/env bash
# PostToolUse hook: log every file Claude edits so Neovim can show them as a tree.
# One JSON line per edit in ~/.local/state/claude-edits/edits.jsonl. Never prints, never fails.
dir="${XDG_STATE_HOME:-$HOME/.local/state}/claude-edits"
mkdir -p "$dir" 2>/dev/null
jq -c '{cwd, session: .session_id, path: (.tool_input.file_path // .tool_input.notebook_path), tool: .tool_name, ts: now|floor}
       | select(.path != null)' >>"$dir/edits.jsonl" 2>/dev/null
exit 0

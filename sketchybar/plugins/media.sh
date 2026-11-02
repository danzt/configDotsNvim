#!/bin/bash
# Only visible while something is playing. Relies on SketchyBar's media_change
# event; newer macOS versions restrict that API, so it may simply stay hidden.
source "$CONFIG_DIR/theme.sh"

[ "$SENDER" = "media_change" ] || exit 0

state="$(printf '%s' "$INFO" | jq -r '.state // empty')"
if [ "$state" = "playing" ]; then
  title="$(printf '%s' "$INFO" | jq -r '.title // empty')"
  app="$(printf '%s' "$INFO" | jq -r '.app // empty')"
  sketchybar --set "$NAME" drawing=on label="$title - $app"
else
  sketchybar --set "$NAME" drawing=off
fi

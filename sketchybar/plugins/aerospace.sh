#!/bin/bash
# $1 = AeroSpace workspace id. Highlights the focused one, lists app icons,
# hides workspaces 6-9 when empty and not focused.
source "$CONFIG_DIR/theme.sh"

SID="$1"
FOCUSED="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}"

icons=""
while IFS= read -r app; do
  [ -n "$app" ] && icons+="$("$CONFIG_DIR/plugins/icon_map.sh" "$app")"
done < <(aerospace list-windows --workspace "$SID" --format '%{app-name}' 2>/dev/null | sort -u)
icons="${icons% }"

if [ "$SID" = "$FOCUSED" ]; then
  bg=$WHITE fg=$DARK
else
  bg=$PILL_BG fg=$FG
fi

drawing=on
if [ "$SID" -gt 5 ] && [ -z "$icons" ] && [ "$SID" != "$FOCUSED" ]; then
  drawing=off
fi

label_drawing=on
[ -z "$icons" ] && label_drawing=off

sketchybar --set "$NAME" drawing=$drawing \
  background.color=$bg icon.color=$fg label.color=$fg \
  label="$icons" label.drawing=$label_drawing

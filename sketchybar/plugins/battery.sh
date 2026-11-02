#!/bin/bash
source "$CONFIG_DIR/theme.sh"

batt="$(pmset -g batt)"
pct="$(printf '%s' "$batt" | grep -Eo '[0-9]+%' | head -1 | tr -d '%')"
[ -z "$pct" ] && exit 0

if printf '%s' "$batt" | grep -q 'AC Power'; then
  icon=$ICON_BAT_CHARGING
elif [ "$pct" -ge 90 ]; then icon=$ICON_BAT_100
elif [ "$pct" -ge 60 ]; then icon=$ICON_BAT_70
elif [ "$pct" -ge 40 ]; then icon=$ICON_BAT_50
elif [ "$pct" -ge 20 ]; then icon=$ICON_BAT_30
else icon=$ICON_BAT_10
fi

sketchybar --set "$NAME" icon="$icon" label="${pct}%"

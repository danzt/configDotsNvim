#!/bin/bash
source "$CONFIG_DIR/theme.sh"

if [ "$SENDER" = "volume_change" ]; then
  vol="$INFO"
else
  vol="$(osascript -e 'output volume of (get volume settings)')"
fi
[ -z "$vol" ] || [ "$vol" = "missing value" ] && exit 0

if [ "$vol" -eq 0 ]; then icon=$ICON_VOL_MUTE
elif [ "$vol" -lt 34 ]; then icon=$ICON_VOL_LOW
elif [ "$vol" -lt 67 ]; then icon=$ICON_VOL_MID
else icon=$ICON_VOL_HIGH
fi

sketchybar --set "$NAME" icon="$icon" label="${vol}%"

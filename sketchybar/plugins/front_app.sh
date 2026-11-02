#!/bin/bash
source "$CONFIG_DIR/theme.sh"

[ "$SENDER" = "front_app_switched" ] || exit 0
sketchybar --set "$NAME" label="$INFO" icon="$("$CONFIG_DIR/plugins/icon_map.sh" "$INFO")"

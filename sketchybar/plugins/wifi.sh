#!/bin/bash
source "$CONFIG_DIR/theme.sh"

# macOS hides the SSID unless Location Services is granted, in which case
# ipconfig prints "<redacted>" — still a valid "connected" signal.
ssid="$(ipconfig getsummary en0 2>/dev/null | awk -F ' SSID : ' '/ SSID : / {print $2}')"

if [ -n "$ssid" ]; then
  sketchybar --set "$NAME" icon="$ICON_WIFI" label="$ssid"
else
  sketchybar --set "$NAME" icon="$ICON_WIFI_OFF" label="offline"
fi

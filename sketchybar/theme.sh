#!/bin/bash
# Shared by sketchybarrc and every plugin. Plugins run with launchd's minimal
# PATH, so Homebrew binaries (aerospace, jq) must be added here.
export PATH="/opt/homebrew/bin:$PATH"

# Palette — same accents as ~/.config/herdr/config.toml.
export BAR_COLOR=0xd006080f
export PILL_BG=0xff2a2a37
export FG=0xffdcd7ba
export DARK=0xff16161d
export GREEN=0xffb7cc85
export CYAN=0xff6fa0af
export PINK=0xffcb7c94
export YELLOW=0xffdeba87
export WHITE=0xffe6e1cf

export FONT="JetBrainsMono Nerd Font"

# Workspace labels: index = AeroSpace workspace number. Rename here only.
WS_LABELS=("" "work" "development" "social" "others" "five" "6" "7" "8" "9")

# Nerd Font glyphs.
export ICON_CLOCK="󰥔"
export ICON_CALENDAR="󰃭"
export ICON_WIFI="󰖩"
export ICON_WIFI_OFF="󰖪"
export ICON_VOL_HIGH="󰕾"
export ICON_VOL_MID="󰖀"
export ICON_VOL_LOW="󰕿"
export ICON_VOL_MUTE="󰖁"
export ICON_BAT_100="󰁹"
export ICON_BAT_70="󰂀"
export ICON_BAT_50="󰁾"
export ICON_BAT_30="󰁼"
export ICON_BAT_10="󰁺"
export ICON_BAT_CHARGING="󰂄"
export ICON_PLAY="󰐊"

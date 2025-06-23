#!/bin/bash

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/utils.sh"
source "$SCRIPT_DIR/update_bar.sh"
source "$SCRIPT_DIR/update_cheatsheet.sh"
source "$SCRIPT_DIR/update_hyprland.sh"
source "$SCRIPT_DIR/update_hyprtrails.sh"
source "$SCRIPT_DIR/update_notifications.sh"
source "$SCRIPT_DIR/update_overview.sh"
source "$SCRIPT_DIR/update_sidebars.sh"
source "$SCRIPT_DIR/restart.sh"

PARTS_TO_UPDATE=()
NEW_HEX=""
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -hex)
            NEW_HEX="$2"
            shift 2
            ;;
        -part)
            PARTS_TO_UPDATE+=("$2")
            shift 2
            ;;
        -h|--help)
            echo "Usage: ./main.sh [-hex <#hexcode>] [-part <partname>]..."
            exit 0
            ;;
        *)
            echo "❌ Unknown option: $1"
            exit 1
            ;;
    esac
done

if [[ -z "$NEW_HEX" ]]; then
    CURRENT=$(get_current_rgb)
    if [[ "$CURRENT" == "rgb(0, 255, 255)" ]]; then
        NEW_HEX="#000000"
    else
        NEW_HEX="$DEFAULT_HEX"
    fi
    echo "🔁 Toggling color to $NEW_HEX"
fi

if [[ ! "$NEW_HEX" =~ ^#[0-9a-fA-F]{6}$ ]]; then
    echo "❌ Invalid hex value: $NEW_HEX"
    exit 1
fi

NEW_RGB=$(hex_to_rgb "$NEW_HEX")

update_hyprtrails

if [[ ${#PARTS_TO_UPDATE[@]} -eq 0 ]]; then
    update_bar
    update_overview
    update_sidebars
    update_cheatsheet
    update_notifications
else
    for part in "${PARTS_TO_UPDATE[@]}"; do
        case "$part" in
            bar) update_bar ;;
            notifications) update_notifications ;;
            overview) update_overview ;;
            sidebars) update_sidebars ;;
            cheatsheet) update_cheatsheet ;;
            *) echo "⚠️ Unknown part: $part" ;;
        esac
    done
fi

update_hyprland
restart_ags

echo "✅ Done! Borders, glows, and trails updated to $NEW_HEX"
exit 0

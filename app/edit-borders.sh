#!/bin/bash

# --- CONFIG ---
SCSS_DIR="$HOME/.config/ags/scss"
BPP_RULES="$HOME/.config/hypr/custom/env.conf"
HYPRTRAILS_CONF="$HOME/.config/hypr/custom/rules.conf"
DEFAULT_HEX="#00ffff"
NEW_HEX=""
TRAIL_ALPHA="ff"

# --- FUNCTIONS ---

print_help() {
    cat <<EOF
Usage: $(basename "$0") [-hex <#hexcode>] [-part <partname> ...]

Changes border and glow colors in AGS SCSS files, Hyprland, and Hyprtrails configs.

Options:
  -hex <#hexcode>     Set a specific color (e.g. "#00ffff")
  -part <partname>    Update only specific parts: bar, notifications, overview, sidebars, cheatsheet
                      (can be repeated)
  -h, --help          Show this help message

Examples:
  ./$(basename "$0") -hex "#ff00ff"
  ./$(basename "$0") -hex "#0aa4e5" -part bar -part notifications
EOF
}

hex_to_rgb() {
    local hex="${1//#/}"
    printf "%d, %d, %d" "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
}

hex_to_rgba() {
    local rgb
    rgb=$(hex_to_rgb "$1")
    echo "$rgb, 255"
}

get_current_rgb() {
    local files=("_bar.scss" "_notifications.scss" "_overview.scss" "_sidebars.scss" "_cheatsheet.scss")
    for file in "${files[@]}"; do
        local fullpath="$SCSS_DIR/$file"
        if [[ -f "$fullpath" ]]; then
            local color=$(grep -Eo 'rgb\([^)]+\)' "$fullpath" | head -n1)
            [[ -n "$color" ]] && echo "$color" && return
        fi
    done
    echo "rgb(0, 0, 0)"
}

update_file() {
    local filename="$1"
    local fullpath="$SCSS_DIR/$filename"
    if [[ -f "$fullpath" ]]; then
        echo "🎨 Updating $filename"
        sed -i -E "s|(border:[^;]*?)rgb\([^)]+\)|\1rgb($NEW_RGB)|g" "$fullpath"
        sed -i -E "/box-shadow/ s/rgb\([^)]+\)/rgb($NEW_RGB)/g" "$fullpath"
    else
        echo "⚠️ File not found: $fullpath"
    fi
}

update_bar() { update_file "_bar.scss"; }

update_notifications() {
    local filename="_notifications.scss"
    local fullpath="$SCSS_DIR/$filename"
    if [[ -f "$fullpath" ]]; then
        echo "🎨 Updating $filename"
        sed -i -E "s/(\\\$cyan-border: 0\.1rem solid )#[0-9a-fA-F]{6};/\1$NEW_HEX;/" "$fullpath"
    else
        echo "⚠️ File not found: $fullpath"
    fi
}

update_overview() { update_file "_overview.scss"; }
update_sidebars() { update_file "_sidebars.scss"; }
update_cheatsheet() { update_file "_cheatsheet.scss"; }

update_hyprland() {
    if [[ -f "$BPP_RULES" ]]; then
        echo "🛠️  Updating Hyprland plugin colors..."
        local RGB RGBA
        RGB=$(hex_to_rgb "$NEW_HEX")
        RGBA=$(hex_to_rgba "$NEW_HEX")

        sed -i -E "s/(col\.border_1\s*=\s*rgb\().*?\)/\1$RGB)/" "$BPP_RULES"
        sed -i -E "s/(col\.border_2\s*=\s*rgb\().*?\)/\1$RGB)/" "$BPP_RULES"
        sed -i -E "s/(color\s*=\s*rgba\().*?\)/\1$RGBA)/" "$BPP_RULES"
    else
        echo "⚠️ Hyprland rules config not found!"
    fi
}

update_hyprtrails() {
    if [[ -f "$HYPRTRAILS_CONF" ]]; then
        echo "🌠 Updating Hyprtrails color..."
        # Clean hex: remove leading #, append ff
        local clean_hex="${NEW_HEX#\#}"
        local trail_hex="${clean_hex}ff"

        # Replace the color inside rgba(...) in env.conf using sed
        sed -i -E "s/(color\s*=\s*rgba\()[^)]+(\))/\1${trail_hex}\2/" "$HYPRTRAILS_CONF"
    else
        echo "⚠️ Hyprtrails config not found!"
    fi
}

restart_ags() {
    echo "🔁 Restarting AGSv1..."
    pkill agsv1 && agsv1 & disown
}

# --- ARG PARSE ---
PARTS_TO_UPDATE=()
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
            print_help
            exit 0
            ;;
        *)
            echo "❌ Unknown option: $1"
            exit 1
            ;;
    esac
done

# --- TOGGLE MODE ---
if [[ -z "$NEW_HEX" ]]; then
    CURRENT=$(get_current_rgb)
    if [[ "$CURRENT" == "rgb(0, 255, 255)" ]]; then
        NEW_HEX="#000000"
    else
        NEW_HEX="$DEFAULT_HEX"
    fi
    echo "🔁 Toggling color to $NEW_HEX"
fi

# --- VALIDATE ---
if [[ ! "$NEW_HEX" =~ ^#[0-9a-fA-F]{6}$ ]]; then
    echo "❌ Invalid hex value: $NEW_HEX"
    exit 1
fi

NEW_RGB=$(hex_to_rgb "$NEW_HEX")

# --- RUN ORDER: Hyprtrails First ---
update_hyprtrails

if [[ ${#PARTS_TO_UPDATE[@]} -eq 0 ]]; then
    update_bar
    update_notifications
    update_overview
    update_sidebars
    update_cheatsheet
else
    for part in "${PARTS_TO_UPDATE[@]}"; do
        case "$part" in
            bar) update_bar ;;
            notifications) update_notifications ;;
            overview) update_overview ;;
            sidebars) update_sidebars ;;
            cheatsheet) update_cheatsheet ;;
            *)
                echo "⚠️ Unknown part: $part"
                ;;
        esac
    done
fi

update_hyprland
restart_ags

echo "✅ Done! Borders, glows, and trails updated to $NEW_HEX"
exit 0

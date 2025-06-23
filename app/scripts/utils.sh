#!/bin/bash

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

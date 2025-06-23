#!/bin/bash

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
        echo "❌ ERROR: Hyprland rules config not found!"
        exit 1
    fi
}

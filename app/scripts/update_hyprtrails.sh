#!/bin/bash

update_hyprtrails() {
    if [[ -f "$HYPRTRAILS_CONF" ]]; then
        echo "🌠 Updating Hyprtrails color..."
        local clean_hex="${NEW_HEX#\#}"
        local trail_hex="${clean_hex}ff"
        sed -i -E "s/(color\s*=\s*rgba\()[^)]+(\))/\1${trail_hex}\2/" "$HYPRTRAILS_CONF"
    else
        echo "❌ ERROR: Hyprtrails config not found!"
        exit 1
    fi
}

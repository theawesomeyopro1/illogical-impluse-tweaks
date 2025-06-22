#/bin/bash

update_notifications() {
    local file_path="${SCSS_DIR}/_notifications.scss"
    if [[ -f "$file_path" ]]; then
        echo "🎨 Updating notifications border color in _notifications.scss"
        sed -i -E "s|(\$colour-border: 0\.1rem solid )#[0-9a-fA-F]{6};|\1$NEW_HEX;|" "$file_path"
    else
        echo "❌ ERROR: File not found: $file_path"
        exit 1
    fi
}


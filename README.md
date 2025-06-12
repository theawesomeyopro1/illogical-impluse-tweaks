# ✨ Hyprland SCSS Tweaks

A personal collection of SCSS modifications built on top of [end-4's Hyprland dotfiles](https://github.com/end-4/dots-hyprland), aiming to bring a fresh, aesthetic, and dynamic touch to the Hyprland experience.

## 🎯 Overview

This repo contains custom SCSS tweaks that modify various UI components like:
- **Bars (AGS)**
- **App Launchers**
- **Popups & Widgets**
- **Colors, Borders & Animations**

All styles are optimized for a minimal, clean, and modern Wayland environment while staying faithful to end-4's original layout philosophy.

---

## 🌈 Features

- ✳️ Clean and modular SCSS structure
- 🎨 Themeable variables for easy customization
- 🌀 Smooth hover animations and transitions
- 📐 Pixel-perfect padding, borders, and spacing
- 🧩 AGS component-specific enhancements (e.g. volume sliders, search bar, media controls)

---

## 📸 Preview
**Apps**  
![screenshot](images/apps.png)

**Overview**  
![screenshot](images/overview.png)

**Sidebars**  
![screenshot](images/sidebars.png)

---

## 🛠️ Installation

For now, manually copy and paste all the SCSS code into all the matching files in `~/.config/ags/scss/`. For some files like `_notifications.scss`, you may need to **replace** the existing code entirely.

---

## 🔧 Border Color Switcher – `edit-borders.sh`

This repo includes a script called `edit-borders.sh` which allows you to **change all AGS + Hyprland border colors** with a single command.

### 📌 Features:
- Changes `border` and `box-shadow` colors in AGS SCSS files
- Updates Hyprland plugin colors (e.g. `col.border_1`, `col.border_2`)
- Can toggle between colors or set a specific color
- Supports **component-specific editing** (bar, overview, notifications, sidebars, cheatsheet)

### ✅ Usage:

# Change all components to a specific color
./edit-borders.sh -hex "#ff00ff"

# Toggle between the default cyan and black
./edit-borders.sh

# Update only the bar borders
./edit-borders.sh -hex "#0aa4e5" -part bar

# Update bar and notifications
./edit-borders.sh -hex "#00ffff" -part bar -part notifications

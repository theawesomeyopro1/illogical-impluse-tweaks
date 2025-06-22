
## 🔧 Border Editing Script

A utility script is included: `edit-borders.sh`

It allows you to update the colors of all border/glow styles across AGS, Hyprland, and Hyprtrails with one command.

### Usage

```bash
./edit-borders.sh -hex "#ff00ff"
```

You can also update only specific parts:

```bash
./edit-borders.sh -hex "#0aa4e5" -part bar -part notifications
```
Opening the help menu

```bash
./edit-borders.sh --help
```

### Supported parts:
```
bar
notifications (broken at the moment)
overview
sidebars
cheatsheet
```

### What it updates:
- SCSS borders in `~/.config/ags/scss/`
- Hyprland plugin borders in `rules.conf`
- Hyprtrails color in `rules.conf`

AGS is automatically restarted so changes apply immediately.

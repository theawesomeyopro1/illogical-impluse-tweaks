#!/usr/bin/env python3

import subprocess
import os
import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, Gdk, GdkPixbuf

from PIL import Image

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
PALETTE_PATH = os.path.join(BASE_DIR, "assets", "color_palette.png")
SCRIPTS_DIR = os.path.join(BASE_DIR, "scripts")

class CrosshairPicker(Gtk.Window):
    def __init__(self):
        super().__init__(title="Crosshair Color Picker")
        self.set_default_size(420, 500)
        self.set_border_width(0)

        self.hex_color = "#00ffff"
        self.parts = {
            "bar": False,
            "notifications": False,
            "overview": False,
            "sidebars": False,
            "cheatsheet": False
        }

        try:
            self.image = Image.open(PALETTE_PATH)
        except FileNotFoundError:
            self.show_error(f"Image not found:\n{PALETTE_PATH}")
            return

        self.img_width, self.img_height = self.image.size

        # HeaderBar
        header = Gtk.HeaderBar(title="🎯 Crosshair Picker")
        header.set_show_close_button(True)
        self.set_titlebar(header)

        outer_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12, margin=12)
        self.add(outer_box)

        # Palette area
        self.image_area = Gtk.DrawingArea()
        self.image_area.set_size_request(self.img_width, self.img_height)
        self.image_area.connect("draw", self.on_draw)
        self.image_area.add_events(Gdk.EventMask.BUTTON_PRESS_MASK)
        self.image_area.connect("button-press-event", self.on_click)
        outer_box.pack_start(self.image_area, False, False, 0)

        outer_box.pack_start(Gtk.Separator(), False, False, 6)

        label = Gtk.Label(label="Select Parts to Update:", xalign=0)
        outer_box.pack_start(label, False, False, 0)

        # Toggle switches
        self.switches = {}
        for part in self.parts:
            row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
            name_label = Gtk.Label(label=part.capitalize(), xalign=0)
            switch = Gtk.Switch()
            switch.connect("notify::active", self.on_switch_toggled, part)
            self.switches[part] = switch
            row.pack_start(name_label, True, True, 0)
            row.pack_end(switch, False, False, 0)
            outer_box.pack_start(row, False, False, 0)

        outer_box.pack_start(Gtk.Separator(), False, False, 6)

        # Apply button
        apply_btn = Gtk.Button(label="🎨 Apply Color")
        apply_btn.get_style_context().add_class("suggested-action")
        apply_btn.connect("clicked", self.on_apply)
        outer_box.pack_start(apply_btn, False, False, 10)

        # Status
        self.status_label = Gtk.Label(xalign=0)
        outer_box.pack_start(self.status_label, False, False, 0)

    def show_error(self, message):
        dialog = Gtk.MessageDialog(
            transient_for=self,
            flags=0,
            message_type=Gtk.MessageType.ERROR,
            buttons=Gtk.ButtonsType.CLOSE,
            text="Error",
        )
        dialog.format_secondary_text(message)
        dialog.run()
        dialog.destroy()

    def on_draw(self, widget, cr):
        try:
            pixbuf = GdkPixbuf.Pixbuf.new_from_file(PALETTE_PATH)
            Gdk.cairo_set_source_pixbuf(cr, pixbuf, 0, 0)
            cr.paint()
        except Exception:
            self.status_label.set_text("❌ Failed to load palette image")

    def on_click(self, widget, event):
        x, y = int(event.x), int(event.y)
        if 0 <= x < self.img_width and 0 <= y < self.img_height:
            r, g, b = self.image.getpixel((x, y))
            self.hex_color = f"#{r:02x}{g:02x}{b:02x}"
            self.status_label.set_text(f"🎯 Picked: {self.hex_color}")

    def on_switch_toggled(self, switch, gparam, part):
        self.parts[part] = switch.get_active()

    def on_apply(self, button):
        selected = [part for part, enabled in self.parts.items() if enabled]

        if not selected:
            self.status_label.set_text("⚠️ No parts selected — nothing applied.")
            return

        failed = []
        for part in selected:
            script_path = os.path.join(SCRIPTS_DIR, f"update_{part}.sh")
            if not os.path.isfile(script_path):
                failed.append(part)
                continue

            try:
                subprocess.run(
                    ["bash", script_path, self.hex_color],
                    check=True,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE
                )
            except subprocess.CalledProcessError:
                failed.append(part)

        if failed:
            self.status_label.set_text(f"❌ Failed on: {', '.join(failed)}")
        else:
            self.status_label.set_text(f"✅ Applied {self.hex_color} to: {', '.join(selected)}")

if __name__ == "__main__":
    win = CrosshairPicker()
    win.connect("destroy", Gtk.main_quit)
    win.show_all()
    Gtk.main()

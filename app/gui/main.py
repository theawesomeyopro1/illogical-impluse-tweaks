#!/usr/bin/env python3

import subprocess
import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, Gdk, GdkPixbuf

from PIL import Image

PALETTE_PATH = "assets/color_palette.png"

class CrosshairPicker(Gtk.Window):
    def __init__(self):
        super().__init__(title="🎯 Crosshair Color Picker")
        self.set_border_width(15)
        self.set_default_size(400, 300)

        self.hex_color = "#00ffff"
        self.parts = {
            "bar": False,
            "notifications": False,
            "overview": False,
            "sidebars": False,
            "cheatsheet": False
        }

        self.image = Image.open(PALETTE_PATH)
        self.img_width, self.img_height = self.image.size

        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        self.add(main_box)

        # Palette image area
        self.image_area = Gtk.DrawingArea()
        self.image_area.set_size_request(self.img_width, self.img_height)
        self.image_area.connect("draw", self.on_draw)
        self.image_area.add_events(Gdk.EventMask.BUTTON_PRESS_MASK)
        self.image_area.connect("button-press-event", self.on_click)
        self.image_area.get_style_context().add_class("crosshair")
        main_box.pack_start(self.image_area, False, False, 0)

        # Part checkboxes
        main_box.pack_start(Gtk.Label(label="Update parts:"), False, False, 0)
        self.check_buttons = {}
        for key in self.parts:
            check = Gtk.CheckButton(label=key.capitalize())
            check.connect("toggled", self.on_part_toggled, key)
            self.check_buttons[key] = check
            main_box.pack_start(check, False, False, 0)

        # Apply button
        apply_btn = Gtk.Button(label="🎨 Apply Color")
        apply_btn.connect("clicked", self.on_apply)
        main_box.pack_start(apply_btn, False, False, 10)

        # Status label
        self.status_label = Gtk.Label()
        main_box.pack_start(self.status_label, False, False, 0)

    def on_draw(self, widget, cr):
        pixbuf = GdkPixbuf.Pixbuf.new_from_file(PALETTE_PATH)
        Gdk.cairo_set_source_pixbuf(cr, pixbuf, 0, 0)
        cr.paint()

    def on_click(self, widget, event):
        x, y = int(event.x), int(event.y)
        if 0 <= x < self.img_width and 0 <= y < self.img_height:
            r, g, b = self.image.getpixel((x, y))
            self.hex_color = f"#{r:02x}{g:02x}{b:02x}"
            self.status_label.set_text(f"🎯 Picked: {self.hex_color}")

    def on_part_toggled(self, button, part):
        self.parts[part] = button.get_active()

    def on_apply(self, button):
        cmd = ["bash", "scripts/main.sh", "-hex", self.hex_color]
        for part, enabled in self.parts.items():
            if enabled:
                cmd += ["-part", part]

        try:
            subprocess.run(cmd, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            self.status_label.set_text(f"✅ Applied {self.hex_color}")
        except subprocess.CalledProcessError:
            self.status_label.set_text("❌ Failed to apply color.")

win = CrosshairPicker()
win.connect("destroy", Gtk.main_quit)
win.show_all()
Gtk.main()

/* MediaDisplay.vala
 *
 * Copyright 2021 Frederick Schenk
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using GLib;

/**
 * A view widget displaying Media in full.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Content/MediaDisplay.ui")]
public class MediaDisplay : Gtk.Widget {

  // UI-Elements for the content
  [GtkChild]
  private unowned Adw.Carousel media_carousel;

  // UI-Elements for the buttons
  [GtkChild]
  private unowned Gtk.Revealer previous_controls;
  [GtkChild]
  private unowned Gtk.Revealer next_controls;

  // UI-Elements for the bottom bar
  [GtkChild]
  private unowned Gtk.Revealer bottom_bar;

  // UI-Elements for the top bar
  [GtkChild]
  private unowned Gtk.Revealer top_bar;

  /**
   * If the UI should be displayed.
   */
  public bool display_controls { get; set; default = true; }

  /**
   * Creates a new instance of MediaDisplay.
   */
  public MediaDisplay (Backend.Media[] media, int focus) {
    // Create a display for all media
    foreach (Backend.Media item in media) {
      var item_display = new MediaDisplayItem (item);
      media_items     += item_display;
      media_carousel.append (item_display);
    }

    // Set up the "Button scroll" actions
    this.install_action ("media_display.select_previous", null, (widget, action) => {
      // Get the instance for this
      MediaDisplay display = (MediaDisplay) widget;

      // Get the current position of the carousel
      int i = (int) display.media_carousel.position;

      // Scroll to the previous widget
      if (i > 0) {
        display.media_carousel.scroll_to (display.media_items [i-1]);
      }
    });
    this.install_action ("media_display.select_next", null, (widget, action) => {
      // Get the instance for this
      MediaDisplay display = (MediaDisplay) widget;

      // Get the current position of the carousel
      int i = (int) display.media_carousel.position;

      // Scroll to the next widget
      if (i < display.media_items.length - 1) {
        display.media_carousel.scroll_to (display.media_items [i+1]);
      }
    });
  }

  /**
   * Deconstructs MediaDisplay and it's childrens.
   */
  public override void dispose () {
    // Destructs children of MediaDisplay
    // FIXME: AdwCarousel can't be unparented, as 'GTK_IS_WIDGET (widget)' fails
    media_carousel.unparent ();
    previous_controls.unparent ();
    next_controls.unparent ();
    bottom_bar.unparent ();
    top_bar.unparent ();
  }

  /**
   * The display items of this widget.
   */
  private MediaDisplayItem[] media_items;

}

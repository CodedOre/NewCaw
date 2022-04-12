/* MediaDisplay.vala
 *
 * Copyright 2021-2022 Frederick Schenk
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
 * Displays an array of media in full resolution.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Media/MediaDisplay.ui")]
public class MediaDisplay : Gtk.Widget {

  // UI-Elements of MediaDisplay
  [GtkChild]
  private unowned Adw.Carousel media_carousel;
  [GtkChild]
  private unowned Gtk.Revealer top_toolbar;
  [GtkChild]
  private unowned Gtk.Revealer previous_control;
  [GtkChild]
  private unowned Gtk.Revealer next_control;
  [GtkChild]
  private unowned Gtk.Revealer bottom_toolbar;
  [GtkChild]
  private unowned Gtk.Label description_label;

  /**
   * If the UI should be displayed.
   */
  public bool display_controls { get; set; default = true; }

  /**
   * Initializes the widget.
   *
   * @param media An array of media to be displayed.
   * @param focus The index of the media that should be initially focused.
   */
  public MediaDisplay (Backend.Media[] media, int focus = 0) {
    // Create an item for all media
    foreach (Backend.Media item in media) {
      var item_display = new MediaDisplayItem (item);
      media_items     += item_display;
      media_carousel.append (item_display);
    }

    // Scroll to the page
    print (@"Do we have an MediaDisplayItem? $(media_items [focus] == null ? "NOPE" : "YEP")\n");
    media_carousel.scroll_to (media_items [focus], false);
  }

  /**
   * Run at construction of the widget.
   */
  construct {
    // Set up the "Button scroll" actions
    this.install_action ("media_display.select_previous", null, (widget, action) => {
      // Get the instance for this
      MediaDisplay display = (MediaDisplay) widget;

      // Get the current position of the carousel
      int i = (int) display.media_carousel.position;

      // Scroll to the previous widget
      if (i > 0) {
        display.media_carousel.scroll_to (display.media_items [i-1], true);
      }
    });
    this.install_action ("media_display.select_next", null, (widget, action) => {
      // Get the instance for this
      MediaDisplay display = (MediaDisplay) widget;

      // Get the current position of the carousel
      int i = (int) display.media_carousel.position;

      // Scroll to the next widget
      if (i < display.media_items.length - 1) {
        display.media_carousel.scroll_to (display.media_items [i+1], true);
      }
    });

    // Show/Hide the UI when clicking on the UI
    var click_controller = new Gtk.GestureClick ();
    click_controller.released.connect (() => {
      display_controls = ! display_controls;
    });
    media_carousel.add_controller (click_controller);
  }

  /**
   * Adapt the UI to a changed page.
   */
  [GtkCallback]
  private void changed_page () {
    // Get the currently displayed media
    int              position = (int) media_carousel.position;
    MediaDisplayItem item     = media_items [position];
    Backend.Media    media    = item.displayed_media;

    // Set up the description
    description_label.label = media.alt_text;

    // Disable scroll buttons if on first/last item
    previous_control.sensitive = ! (position == 0);
    next_control.sensitive     = ! (position == media_items.length - 1);
  }

  /**
   * Deconstructs MediaDisplay and it's childrens.
   */
  public override void dispose () {
    // Destructs children of MediaDisplay
    media_carousel.unparent ();
    top_toolbar.unparent ();
    previous_control.unparent ();
    next_control.unparent ();
    bottom_toolbar.unparent ();
  }

  /**
   * The items displayed on this widget.
   */
  private MediaDisplayItem[] media_items;

}

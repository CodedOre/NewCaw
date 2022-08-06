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
  [GtkChild]
  private unowned Gtk.MediaControls video_controls;

  /**
   * If the UI should be displayed.
   */
  public bool display_controls { get; set; default = true; }

  /**
   * If the bottom bar has content that should be displayed.
   */
  public bool display_bottom_bar { get; set; }

  /**
   * The currently visible MediaDisplayItem.
   */
  public MediaDisplayItem visible_item {
    get {
      // Get the currently displayed item
      int position = (int) media_carousel.position;
      return media_items [position];
    }
  }

  /**
   * The currently visible media.
   */
  public Backend.Media visible_media {
    get {
      // Get the currently displayed item
      MediaDisplayItem item = visible_item;

      // Return the media from that item
      return item.displayed_media;
    }
  }

  /**
   * Sets the displayed media items.
   *
   * @param media An array of media to be displayed.
   * @param focus The index of the media that should be initially focused.
   */
  public void set_media (Backend.Media[] media, int focus = 0) {
    // Clear up potential existing items
    foreach (MediaDisplayItem item in media_items) {
      media_carousel.remove (item);
    }
    media_items = {};

    // Create an item for all media
    foreach (Backend.Media item in media) {
      var item_display = new MediaDisplayItem (item);
      media_items     += item_display;
      media_carousel.append (item_display);
      item_display.notify ["media-loaded"].connect ((s, p) => {
        set_video_controls ();
      });
    }

    // Scroll to the page
    media_carousel.scroll_to (media_items [focus], false);
  }

  /**
   * Runs at initialization of this class.
   */
  class construct {
    // Set up the "Button scroll" actions
    install_action ("media_display.select_previous", null, (widget, action) => {
      // Get the instance for this
      MediaDisplay display = (MediaDisplay) widget;

      // Get the current position of the carousel
      int i = (int) display.media_carousel.position;

      // Scroll to the previous widget
      if (i > 0) {
        display.media_carousel.scroll_to (display.media_items [i-1], true);
      }
    });
    install_action ("media_display.select_next", null, (widget, action) => {
      // Get the instance for this
      MediaDisplay display = (MediaDisplay) widget;

      // Get the current position of the carousel
      int i = (int) display.media_carousel.position;

      // Scroll to the next widget
      if (i < display.media_items.length - 1) {
        display.media_carousel.scroll_to (display.media_items [i+1], true);
      }
    });
  }

  /**
   * Run at construction of the widget.
   */
  construct {
    // Show/Hide the UI when clicking on the UI
    var click_controller = new Gtk.GestureClick ();
    click_controller.released.connect (() => {
      display_controls = ! display_controls;
      display_bottom_bar = display_controls && bottom_bar_content;
    });
    media_carousel.add_controller (click_controller);
  }

  /**
   * Adapt the UI to a changed page.
   */
  [GtkCallback]
  private void changed_page () {
    // Get the currently displayed media
    int           position = (int) media_carousel.position;
    Backend.Media media    = visible_media;

    // Get the description of the media
    string description      = media.alt_text;
    description_label.label = description;

    // Determine which parts of the bottom bar are visible
    bool   has_description   = description != null;
    bool   has_video_control = media.media_type == VIDEO;
    set_video_controls ();

    // Hide (parts of) the bottom bar
    description_label.visible = has_description;
    video_controls.visible    = has_video_control;
    bottom_bar_content        = has_description || has_video_control;
    display_bottom_bar        = display_controls && bottom_bar_content;

    // Disable scroll buttons if on first/last item
    previous_control.sensitive = ! (position == 0);
    next_control.sensitive     = ! (position == media_items.length - 1);
  }

  /**
   * Sets the the video controls to the right control.
   */
  private void set_video_controls () {
      // Get the currently displayed item
      MediaDisplayItem item  = visible_item;

      // When the full media is loaded, set the controls
      var video = item.displayed_paintable as Gtk.MediaFile;
      video_controls.media_stream = video;
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
    base.dispose ();
  }

  /**
   * If the bottom bar has content that should be displayed.
   */
  private bool bottom_bar_content;

  /**
   * The items displayed on this widget.
   */
  private MediaDisplayItem[] media_items;

}

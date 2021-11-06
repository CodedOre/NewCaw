/* MediaDisplayItem.vala
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
 * A widget displaying the preview or media for a single item.
 *
 * TODO: Add zoom functionality by making a scrollable paintable.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Content/MediaDisplayItem.ui")]
public class MediaDisplayItem : Gtk.Widget {

  // UI-Elements of MediaDisplayItem
  [GtkChild]
  private unowned Gtk.ScrolledWindow scroll_window;
  [GtkChild]
  private unowned Gtk.Picture content;

  /**
   * If the high-res media is fully loaded.
   */
  public bool media_loaded { get; set; }

  /**
   * The displayed media.
   */
  public Backend.Media displayed_media { get; private set; }

  /**
   * Creates the widget.
   *
   * @param media The media which is displayed in this widget.
   */
  public MediaDisplayItem (Backend.Media media) {
    // Set media and create Cancellable
    displayed_media  = media;
    load_cancellable = new Cancellable ();

    // Load the preview image
    if (displayed_media.preview.is_loaded ()) {
      displayed_paintable = displayed_media.preview.get_media ();
      content.set_paintable (displayed_paintable);
    } else {
      displayed_media.preview.begin_loading (load_cancellable);
      displayed_media.preview.load_completed.connect (() => {
        // Set displayed texture to preview if media is not yet loaded
        if (displayed_paintable == null) {
          displayed_paintable = displayed_media.preview.get_media ();
        }
        // Displays the to displayed texture
        if (displayed_paintable != null) {
          content.set_paintable (displayed_paintable);
        }
      });
    }

    // Load the actual media depending on the media type
    if (displayed_media is Backend.Picture) {
      var picture = (Backend.Picture) displayed_media;
      // Load the high-res image
      if (picture.media.is_loaded ()) {
        displayed_paintable = picture.media.get_media ();
        content.set_paintable (displayed_paintable);
        media_loaded = true;
      } else {
        picture.media.begin_loading (load_cancellable);
        picture.media.load_completed.connect (() => {
          Gdk.Texture image = picture.media.get_media ();
          // Displays the image
          if (image != null) {
            displayed_paintable = image;
            content.set_paintable (displayed_paintable);
            media_loaded = true;
          }
        });
      }
    }
  }

  /**
   * Deconstructs MediaPreviewItem and it's childrens.
   */
  public override void dispose () {
    // Cancel possible loads
    load_cancellable.cancel ();
    // Destructs children of MediaDisplayItem
    scroll_window.unparent ();
  }

  /**
   * A GLib.Cancellable to cancel loads when closing the item.
   */
  private Cancellable load_cancellable;

  /**
   * The displayed Gdk.Texture.
   */
  private Gdk.Paintable? displayed_paintable = null;

}

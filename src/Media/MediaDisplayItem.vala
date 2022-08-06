/* MediaDisplayItem.vala
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
 * A widget displaying the preview or media for a single item.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Media/MediaDisplayItem.ui")]
public class MediaDisplayItem : Gtk.Widget {

  // UI-Elements of MediaDisplayItem
  [GtkChild]
  private unowned Gtk.Picture content;

  /**
   * If the high-res media is fully loaded.
   */
  public bool media_loaded { get; private set; }

  /**
   * The displayed media.
   */
  public Backend.Media displayed_media { get; construct; }

  /**
   * The displayed Gdk.Paintable.
   */
  public Gdk.Paintable? displayed_paintable { get; private set; default = null; }

  /**
   * Creates the widget.
   *
   * @param media The media which is displayed in this widget.
   */
  public MediaDisplayItem (Backend.Media media) {
    // Construct the object
    Object (
      displayed_media: media
    );
  }

  /**
   * Run at construction of the widget.
   */
  construct {
    // Create the Cancellable
    load_cancellable = new Cancellable ();

    // Load the preview
    displayed_media.get_preview.begin (load_cancellable, (obj, res) => {
      try {
        if (displayed_paintable == null) {
          displayed_paintable = displayed_media.get_preview.end (res) as Gdk.Paintable;
          content.paintable   = displayed_paintable;
        }
      } catch (Error e) {
        warning (@"Could not load the avatar: $(e.message)");
      }
    });

    // Load the media
    displayed_media.get_media.begin (load_cancellable, (obj, res) => {
      try {
        displayed_paintable = displayed_media.get_media.end (res) as Gdk.Paintable;
        content.paintable   = displayed_paintable;
        media_loaded        = true;
        // Autoplay animated
        if (displayed_media.media_type == ANIMATED) {
          var animated  = displayed_paintable as Gtk.MediaFile;
          if (animated != null) {
            animated.loop = true;
            animated.play ();
          }
        }
      } catch (Error e) {
        warning (@"Could not load the avatar: $(e.message)");
      }
    });
  }

  /**
   * Deconstructs MediaDisplayItem and it's childrens.
   */
  public override void dispose () {
    // Cancel possible loads
    load_cancellable.cancel ();
    // Destructs children of MediaDisplayItem
    content.unparent ();
    base.dispose ();
  }

  /**
   * A GLib.Cancellable to cancel loads when closing the item.
   */
  private Cancellable load_cancellable;

}

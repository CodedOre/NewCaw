/* MediaPreviewItem.vala
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
 * A widget displaying the preview for a single item.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Content/MediaPreviewItem.ui")]
public class MediaPreviewItem : Gtk.Widget {

  // UI-Elements of MediaPreviewItem
  [GtkChild]
  private unowned Gtk.Picture preview;
  [GtkChild]
  private unowned Gtk.Button selector;
  [GtkChild]
  private unowned Gtk.Image alt_text_indicator;

  /**
   * Creates a MediaPreviewItem for a certain Media.
   */
  public MediaPreviewItem (Backend.Media media) {
    // Init object with construct only properties
    displayed_media = media;

    // Load and set the Paintable
    displayed_media.load_preview.begin ((obj, res) => {
      displayed_paintable = displayed_media.load_preview.end (res);
      preview.set_paintable (displayed_paintable);
    });

    // Set alt-text if available
    if (displayed_media.alt_text != null) {
      alt_text_indicator.set_tooltip_text (displayed_media.alt_text);
      alt_text_indicator.visible = true;
    }
  }

  /**
   * Deconstructs MediaPreviewItem and it's childrens
   */
  public override void dispose () {
    // Destructs children of MediaPreviewItem
    preview.unparent ();
    selector.unparent ();
    alt_text_indicator.unparent ();
  }

  /**
   * The displayed Media object.
   */
  private Backend.Media displayed_media;

  /**
   * The displayed Gdk.Paintable.
   */
  Gdk.Paintable? displayed_paintable = null;

}

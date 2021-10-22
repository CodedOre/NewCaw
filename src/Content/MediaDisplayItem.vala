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

[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Content/MediaDisplayItem.ui")]
public class MediaDisplayItem : Gtk.Widget {

  // UI-Elements of MediaDisplayItem
  [GtkChild]
  private unowned Gtk.Picture content;

  /**
   * Creates the widget.
   *
   * @param media The media which is displayed in this widget.
   */
  public MediaDisplayItem (Backend.Media media) {
    // Set the used media
    displayed_media = media;

    // Load the preview image
    // FIXME: May not be async...
    displayed_media.load_preview.begin ((obj, res) => {
      // Set displayed texture to preview if media is not yet loaded
      if (displayed_paintable == null) {
        displayed_paintable = displayed_media.load_preview.end (res);
      }
      // Displays the to displayed texture
      if (displayed_paintable != null) {
        content.set_paintable (displayed_paintable);
      }
    });

    // Load the actual media depending on the media type
    if (displayed_media is Backend.Picture) {
      var picture = (Backend.Picture) displayed_media;
      // Load the high-res image
      // FIXME: May not be async...
      picture.load_media.begin ((obj, res) => {
        displayed_paintable = picture.load_media.end (res);
        // Displays the image
        if (displayed_paintable != null) {
          content.set_paintable (displayed_paintable);
        }
      });
    }
  }

  /**
   * Deconstructs MediaPreviewItem and it's childrens.
   */
  public override void dispose () {
    // Destructs children of MediaDisplayItem
    content.unparent ();
  }

  /**
   * The displayed media.
   */
  private Backend.Media displayed_media;

  /**
   * The displayed Gdk.Texture.
   */
  Gdk.Paintable? displayed_paintable = null;

}

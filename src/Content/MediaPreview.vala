/* MediaPreview.vala
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
 * A widget displaying up to four Media items as previews.
 */
public class MediaPreview : Gtk.Grid {

  /**
   * Set the media to be displayed in this widget.
   *
   * @param media An Array with the media to be displayed.
   */
  public void display_media (Backend.Media[] media) {
    // Set some basic properties
    this.column_homogeneous = true;
    this.column_spacing     = 6;
    this.row_homogeneous    = true;
    this.row_spacing        = 6;

    // Set internal fields
    if (media.length > 4) {
      warning ("MediaPreview: More than 4 images detected! Only displaying the first 4...");
      displayed_media = media [:3];
    } else {
      displayed_media = media;
    }
  }

  /**
   * The Media array which is displayed.
   */
  private Backend.Media[] displayed_media;

}

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
   * Defines the layout of MediaPreview depending on size and item.
   *
   * This is a three dimensional array, containing numbers
   * used to place the image frames on the grid.
   *
   * It's dimensions are as follows\:
   * - The first  dimension is for the overall number of displayed media.
   * - The second dimension is for the n-th item inside a array.
   * - The last   dimension contains the settings for the grid, used in Gtk.Grid.
   */
  private const int[,,] PREVIEW_GRID_LAYOUT = {
    // One media to display
    {
      {0, 0, 2, 2}
    },
    // Two media to display
    {
      {0, 0, 1, 2},
      {1, 0, 1, 2}
    },
    // Three media to display
    {
      {0, 0, 1, 2},
      {1, 0, 1, 1},
      {1, 1, 1, 1}
    },
    // Four media to display
    {
      {0, 0, 1, 1},
      {1, 0, 1, 1},
      {0, 1, 1, 1},
      {1, 1, 1, 1}
    },
  };

  /**
   * The spacing between the different items.
   */
  private const int ITEM_SPACING = 6;

  /**
   * Set the media to be displayed in this widget.
   *
   * @param media An Array with the media to be displayed.
   */
  public void display_media (Backend.Media[] media) {
    // Set some basic properties
    this.column_homogeneous = true;
    this.column_spacing     = ITEM_SPACING;
    this.row_homogeneous    = true;
    this.row_spacing        = ITEM_SPACING;

    // Set internal fields
    if (media.length > 4) {
      warning ("MediaPreview: More than 4 images detected! Only displaying the first 4...");
      displayed_media = media [:3];
    } else {
      displayed_media = media;
    }

    // Arrange media on the grid
    for (int i = 0; i < displayed_media.length; i++) {
      // Get the position arguments for the media
      int item_column = PREVIEW_GRID_LAYOUT [displayed_media.length - 1, i, 0];
      int item_row    = PREVIEW_GRID_LAYOUT [displayed_media.length - 1, i, 1];
      int item_width  = PREVIEW_GRID_LAYOUT [displayed_media.length - 1, i, 2];
      int item_height = PREVIEW_GRID_LAYOUT [displayed_media.length - 1, i, 3];

      // Create a Frame to hold a media preview
      var media_item   = new MediaPreviewItem (displayed_media [i], i, item_width, item_height, ITEM_SPACING);
      var item_frame   = new Gtk.Frame (null);
      item_frame.child = media_item;
      item_frame.add_css_class ("card");

      // Positions the frame in the grid
      this.attach (item_frame, item_column, item_row, item_width, item_height);
    }
  }

  /**
   * The Media array which is displayed.
   */
  private Backend.Media[] displayed_media;

}

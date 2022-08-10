/* MediaPreview.vala
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
 * A widget displaying up to four Media items as previews.
 */
public class MediaPreview : Gtk.Widget {

  /**
   * The minimum width of this widget.
   */
  private const int MINIMUM_WIDTH = 100;

  /**
   * The ratio between height and width.
   */
  private const double WIDTH_TO_HEIGHT = 0.5;

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
    }
  };

  /**
   * The spacing between the different items.
   */
  private const int ITEM_SPACING = 6;

  /**
   * Run at construction of the widget.
   */
  construct {
    // Create the media grid
    media_grid = new Gtk.Grid ();
    media_grid.set_parent (this);
    // Set some basic properties
    media_grid.column_homogeneous = true;
    media_grid.column_spacing     = ITEM_SPACING;
    media_grid.row_homogeneous    = true;
    media_grid.row_spacing        = ITEM_SPACING;
  }

  /**
   * Set the media to be displayed in this widget.
   *
   * @param media An Array with the media to be displayed.
   */
  public void display_media (Backend.Media[]? media) {

    // Check that we have not more than 4 media to display
    displayed_media = media != null
                        ? media.length > 4 ? media [:3] : media
                        : null;

    // Clear out existing items
    foreach (Gtk.Widget widget in displayed_widgets) {
      media_grid.remove (widget);
    }

    // Return if no media can be set
    if (media == null) {
      return;
    }

    // Arrange media on the grid
    for (int i = 0; i < displayed_media.length; i++) {
      // Get the position arguments for the media
      int item_column = PREVIEW_GRID_LAYOUT [displayed_media.length - 1, i, 0];
      int item_row    = PREVIEW_GRID_LAYOUT [displayed_media.length - 1, i, 1];
      int item_width  = PREVIEW_GRID_LAYOUT [displayed_media.length - 1, i, 2];
      int item_height = PREVIEW_GRID_LAYOUT [displayed_media.length - 1, i, 3];

      // Display the preview in a MediaSelector
      var media_item   = new MediaSelector ();
      media_item.media = displayed_media [i];

      // Positions the frame in the grid
      media_grid.attach (media_item, item_column, item_row, item_width, item_height);
    }
  }

  public override void size_allocate (int width, int height, int baseline) {
    // Allocate the sizes
    media_grid.allocate (width, height, baseline, null);
  }

  /**
   * Returns the Gtk.SizeRequestMode to GTK.
   */
  public override Gtk.SizeRequestMode get_request_mode () {
    return CONSTANT_SIZE;
  }

  /**
   * Determines the size of this widget.
   */
  public override void measure (Gtk.Orientation orientation,
                                            int for_size,
                                        out int minimum,
                                        out int natural,
                                        out int minimum_baseline,
                                        out int natural_baseline)
  {
    // Checkt the orientation to measure
    if (orientation == HORIZONTAL) {
      // Put out constant values for width
      minimum = MINIMUM_WIDTH;
      natural = MINIMUM_WIDTH;
    } else {
      // Get allocated width of widget
      int allocated_width = this.get_allocated_width () > 0
                              ? this.get_allocated_width ()
                              : MINIMUM_WIDTH;

      // Set the height to be a multiplier of the width
      minimum = (int) (allocated_width * WIDTH_TO_HEIGHT);
      natural = (int) (allocated_width * WIDTH_TO_HEIGHT);
    }

    // Set baselines
    minimum_baseline = -1;
    natural_baseline = -1;
  }

  /**
   * Snapshots the widget for display.
   */
  public override void snapshot (Gtk.Snapshot snapshot) {
    this.queue_resize ();
    this.queue_allocate ();
    base.snapshot (snapshot);
  }

  /**
   * Deconstructs MediaPreview and it's childrens
   */
  public override void dispose () {
    // Destructs children of MediaPreview
    media_grid.unparent ();
    base.dispose ();
  }

  /**
   * The child grid of MediaPreview.
   */
  private Gtk.Grid media_grid;

  /**
   * Stores currently displayed items.
   */
  private Gtk.Widget[] displayed_widgets = {};

  /**
   * The Media array which is displayed.
   */
  private Backend.Media[]? displayed_media;

}

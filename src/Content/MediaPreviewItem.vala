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
 *
 * TODO: Add some feedback when loading image-
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Content/MediaPreviewItem.ui")]
public class MediaPreviewItem : Gtk.Widget {

  /**
   * The minimum width of this widget.
   */
  private const int MINIMUM_WIDTH = 150;

  /**
   * The ratio between height and width.
   */
  private const double WIDTH_TO_HEIGHT = 0.5;

  // UI-Elements of MediaPreviewItem
  [GtkChild]
  private unowned Gtk.Picture preview;
  [GtkChild]
  private unowned Gtk.Button selector;
  [GtkChild]
  private unowned Gtk.Box media_indicator_box;
  [GtkChild]
  private unowned Gtk.Image animated_type_indicator;
  [GtkChild]
  private unowned Gtk.Image video_type_indicator;
  [GtkChild]
  private unowned Gtk.Image alt_text_indicator;

  /**
   * Creates a MediaPreviewItem for a certain Media.
   */
  public MediaPreviewItem (Backend.Media media, int index, int width, int height, int spacing) {
    // Init object with construct only properties
    Object (overflow: Gtk.Overflow.HIDDEN);
    displayed_media = media;

    // Finalize the selector action
    selector.set_action_target ("i", index);

    // Set grid size variables
    cell_width   = width;
    cell_height  = height;
    grid_spacing = spacing;

    // Load and set the Paintable
    // FIXME: Appears to be not async...
    displayed_media.load_preview.begin ((obj, res) => {
      displayed_texture = displayed_media.load_preview.end (res);
      preview.set_paintable (displayed_texture);
    });

    // Set alt-text if available
    if (displayed_media.alt_text != null) {
      alt_text_indicator.set_tooltip_text (displayed_media.alt_text);
      alt_text_indicator.visible = true;
    }

    // Make media_indicator_box visible when a indicator is set
    media_indicator_box.visible = animated_type_indicator.visible || video_type_indicator.visible || alt_text_indicator.visible;
  }

  public override void size_allocate (int width, int height, int baseline) {

    // Allocate selector and alt_text_indicator
    selector.allocate (width, height, baseline, null);
    media_indicator_box.allocate (width, height, baseline, null);

    // Create Gsk.Transform when preview texture is found
    Gsk.Transform preview_format = null;
    int           preview_height = height;
    int           preview_width  = width;
    if (displayed_texture != null) {
      // Get the sizes of the item and the texture
      // TODO: Check if cell width and height remove flicker
      int text_height = displayed_texture.height;
      int text_width  = displayed_texture.width;
      int item_height = this.get_allocated_height ();
      int item_width  = this.get_allocated_width ();

      // Determine the longer sides of item and texture
      bool horizontal_item = item_width > item_height;
      bool horizontal_text = text_width > text_height;

      // Modify the picture constraint for display
      int translate_x, translate_y;
      if ((horizontal_item && horizontal_text) || (! horizontal_item && ! horizontal_text)) {
        // Clip top and bottom
        translate_x     = 0;
        translate_y     = -1 * (item_height / 2);
        preview_height *= 2;
      } else {
        // Clip start and end
        translate_x    = -1 * (item_width / 2);
        translate_y    = 0;
        preview_width *= 2;
      }

      // Apply calculated transform
      string transform_command = @"translate($(translate_x),$(translate_y))";
      if (! Gsk.Transform.parse (transform_command, out preview_format)) {
        error ("MediaPreviewItem: Could not transform preview!");
      }
    }

    // Allocate preview picture
    preview.allocate (preview_width, preview_height, baseline, preview_format);
  }

  /**
   * Returns the Gtk.SizeRequestMode to GTK.
   */
  public override Gtk.SizeRequestMode get_request_mode () {
    return HEIGHT_FOR_WIDTH;
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
      // FIXME: Ensure we get a width before the first snapshot
      // FIXME: Fix non-measure when maximized
      int allocated_width;
      if (this.get_allocated_width () > 0) {
        allocated_width = this.get_allocated_width ();
      } else {
        allocated_width = MINIMUM_WIDTH;
      }

      // Set the height to be a multiplier of the width
      double height_multiplier = (cell_height / cell_width) * WIDTH_TO_HEIGHT;
      double height_constant   = (cell_height - 1) * grid_spacing;
      minimum = (int) (allocated_width * height_multiplier + height_constant);
      natural = (int) (allocated_width * height_multiplier + height_constant);
    }

    // Set baselines
    minimum_baseline = -1;
    natural_baseline = -1;
  }

  /**
   * Deconstructs MediaPreviewItem and it's childrens.
   */
  public override void dispose () {
    // Destructs children of MediaPreviewItem
    preview.unparent ();
    selector.unparent ();
    media_indicator_box.unparent ();
  }

  /**
   * The displayed Media object.
   */
  private Backend.Media displayed_media;

  /**
   * The displayed Gdk.Texture.
   */
  Gdk.Texture? displayed_texture = null;

  /**
   * The width of this widget in the grid.
   */
  private int cell_width;

  /**
   * The height of this widget in the grid.
   */
  private int cell_height;

  /**
   * The used spacing in the grid.
   */
  private int grid_spacing;
}

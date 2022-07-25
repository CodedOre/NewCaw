/* MediaPreviewItem.vala
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
 * A widget displaying the preview for a single item.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Media/MediaPreviewItem.ui")]
public class MediaPreviewItem : Gtk.Widget {

  /**
   * The minimum width of this widget.
   */
  private const int MINIMUM_WIDTH = 150;

  /**
   * The ratio between height and width.
   */
  private const double WIDTH_TO_HEIGHT = 0.45;

  // UI-Elements of MediaPreviewItem
  [GtkChild]
  private unowned CroppedPicture preview;
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
    displayed_media  = media;
    load_cancellable = new Cancellable ();

    // Finalize the selector action
    selector.set_action_target ("i", index);

    // Set grid size variables
    cell_width   = width;
    cell_height  = height;
    grid_spacing = spacing;

    // Load the preview image
    displayed_media.get_preview.begin (load_cancellable, (obj, res) => {
      try {
        var paintable = displayed_media.get_preview.end (res) as Gdk.Paintable;
        preview.paintable = paintable;
        preview.remove_css_class ("loading-media");
      } catch (Error e) {
        warning (@"Could not load the avatar: $(e.message)");
      }
    });

    // Set alt-text if available
    if (displayed_media.alt_text != null) {
      alt_text_indicator.set_tooltip_text (displayed_media.alt_text);
      alt_text_indicator.visible = true;
    }

    // Set additional type indicators if appropriate
    animated_type_indicator.visible = displayed_media.media_type == ANIMATED;
    video_type_indicator.visible    = displayed_media.media_type == VIDEO;

    // Make media_indicator_box visible when a indicator is set
    media_indicator_box.visible = animated_type_indicator.visible || video_type_indicator.visible || alt_text_indicator.visible;
  }

  public override void size_allocate (int width, int height, int baseline) {
    // Allocate the sizes
    selector.allocate (width, height, baseline, null);
    media_indicator_box.allocate (width, height, baseline, null);
    preview.allocate (width, height, baseline, null);
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
   * Snapshots the widget for display.
   */
  public override void snapshot (Gtk.Snapshot snapshot) {
    this.queue_resize ();
    this.queue_allocate ();
    base.snapshot (snapshot);
  }

  /**
   * Deconstructs MediaPreviewItem and it's childrens
   */
  public override void dispose () {
    // Cancel possible loads
    load_cancellable.cancel ();
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
   * A GLib.Cancellable to cancel loads when closing the item.
   */
  private Cancellable load_cancellable;

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

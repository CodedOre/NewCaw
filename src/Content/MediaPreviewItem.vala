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
 * FIXME: This is not completely functional, we should use a custom layout adapted to this functionality.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Content/MediaPreviewItem.ui")]
public class MediaPreviewItem : Gtk.Widget {

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
  private unowned Gtk.Image alt_text_indicator;

  /**
   * Creates a MediaPreviewItem for a certain Media.
   */
  public MediaPreviewItem (Backend.Media media, int width, int height, int spacing) {
    // Init object with construct only properties
    Object (overflow: Gtk.Overflow.HIDDEN);
    displayed_media = media;

    // Set up the width-to-height ratio
    double height_multiplier = (height / width) * WIDTH_TO_HEIGHT;
    double height_constant   = (height - 1) * spacing;
    var    height_constraint = new Gtk.Constraint (this, HEIGHT, EQ, this, WIDTH, height_multiplier, height_constant, Gtk.ConstraintStrength.REQUIRED);
    ((Gtk.ConstraintLayout) this.layout_manager).add_constraint (height_constraint);

    // Load and set the Paintable
    displayed_media.load_preview.begin ((obj, res) => {
      displayed_texture = displayed_media.load_preview.end (res);
      position_texture ();
    });

    // Set alt-text if available
    if (displayed_media.alt_text != null) {
      alt_text_indicator.set_tooltip_text (displayed_media.alt_text);
      alt_text_indicator.visible = true;
    }
  }

  /**
   * Places and positions the texture.
   */
  private void position_texture () {
    // Check if displayed_texture is valid
    if (displayed_texture == null) {
      warning ("MediaPreviewItem: No texture for display found!");
      return;
    }

    // Remove exiting preview constraints
    foreach (Gtk.Constraint constraint in preview_constraints) {
      ((Gtk.ConstraintLayout) this.layout_manager).remove_constraint (constraint);
    }

    // Get the sizes of the item and the texture
    int text_height = displayed_texture.height;
    int text_width  = displayed_texture.width;
    int item_height = this.get_allocated_height ();
    int item_width  = this.get_allocated_width ();

    // Determine the longer sides of item and texture
    bool horizontal_item = true ? item_width > item_height : false;
    bool horizontal_text = true ? text_width > text_height : false;

    // Modify the picture constraint for display
    if ((horizontal_item && horizontal_text) || (! horizontal_item && ! horizontal_text)) {
      // Clip top and bottom
      preview_constraints = {
        new Gtk.Constraint (preview, TOP,    EQ, this, TOP,    1, -512, Gtk.ConstraintStrength.REQUIRED),
        new Gtk.Constraint (preview, BOTTOM, EQ, this, BOTTOM, 1,  512, Gtk.ConstraintStrength.REQUIRED),
        new Gtk.Constraint (preview, WIDTH,  EQ, this, WIDTH,  1,    0, Gtk.ConstraintStrength.REQUIRED)
      };
    } else {
      // Clip start and end
      preview_constraints = {
        new Gtk.Constraint (preview, START,  EQ, this, START,  1, -512, Gtk.ConstraintStrength.REQUIRED),
        new Gtk.Constraint (preview, END,    EQ, this, END,    1,  512, Gtk.ConstraintStrength.REQUIRED),
        new Gtk.Constraint (preview, HEIGHT, EQ, this, HEIGHT, 1,    0, Gtk.ConstraintStrength.REQUIRED)
      };
    }

    // Add the new constraints
    foreach (Gtk.Constraint constraint in preview_constraints) {
      ((Gtk.ConstraintLayout) this.layout_manager).add_constraint (constraint);
    }

    // Places the texture in the picture
    preview.set_paintable (displayed_texture);
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
   * The displayed Gdk.Texture.
   */
  Gdk.Texture? displayed_texture = null;

  /**
   * The Gtk.Constraint defining the positioning of a Gtk.Picture.
   */
  private Gtk.Constraint[] preview_constraints;

}

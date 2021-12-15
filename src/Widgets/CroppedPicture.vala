/* CroppedPicture.vala
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
 * A widget that displaying an picture inside it's given bounds.
 */
public class CroppedPicture : Gtk.Widget {

  /**
   * The paintable which will be displayed.
   */
  public Gdk.Paintable paintable { get; set; }

  /**
   * Snapshots the widget for display.
   */
  public override void snapshot (Gtk.Snapshot snapshot) {
    // Stop early when no paintable was given
    if (paintable == null) {
      return;
    }

    // Get the size of the widget
    int width  = this.get_width ();
    int height = this.get_height ();

    // Get aspect ratios
    double widget_ratio = (double) width / height;
    double paint_ratio  = paintable.get_intrinsic_aspect_ratio ();

    // Calculate paintable size
    double w, h;
    if (paint_ratio < widget_ratio) {
      w = width;
      h = width / paint_ratio;
    } else {
      w = height * paint_ratio;
      h = height;
    }

    // Calculate paintable translation
    int x = (int) ((width - Math.ceil (w)) / 2);
    int y = (int) (Math.floor(height - Math.ceil (h)) / 2);

    // Snapshot the paintable
    snapshot.push_clip (Graphene.Rect ().init (0, 0, width, height));
    snapshot.save ();
    snapshot.translate (Graphene.Point ().init (x, y));
    paintable.snapshot (snapshot, w, h);
    snapshot.restore ();
    snapshot.pop ();
  }

}

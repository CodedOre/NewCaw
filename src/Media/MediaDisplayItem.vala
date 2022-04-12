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
   * Creates the widget.
   *
   * @param media The media which is displayed in this widget.
   */
  public MediaDisplayItem (Backend.Media media) {
  }

  /**
   * Deconstructs MediaDisplayItem and it's childrens.
   */
  public override void dispose () {
    // Destructs children of MediaDisplayItem
    content.unparent ();
  }

}

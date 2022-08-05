/* RepostStatus.vala
 *
 * Copyright 2022 Frederick Schenk
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
 * Displayed over an PostItem and shows the information about the reposting user.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Content/RepostStatus.ui")]
public class RepostStatus : Gtk.Widget {

  // UI-Elements of RepostStatus
  [GtkChild]
  private unowned Adw.Bin previous_line_bin;
  [GtkChild]
  private unowned Gtk.Box information_box;

  /**
   * Deconstructs RepostStatus and it's childrens.
   */
  public override void dispose () {
    // Destructs children of RepostStatus
    previous_line_bin.unparent ();
    information_box.unparent ();
  }
}

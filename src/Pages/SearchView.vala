/* SearchView.vala
 *
 * Copyright 2023 CodedOre <47981497+CodedOre@users.noreply.github.com>
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
 * Provides the view to do a search and see the results.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Pages/SearchView.ui")]
public class SearchView : Gtk.Widget {

  /**
   * Deconstructs SearchView and it's childrens.
   */
  public override void dispose () {
    // Destructs children of SearchView
    base.dispose ();
  }

}

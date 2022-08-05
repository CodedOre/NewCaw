/* FilterButton.vala
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
 * A button inside the CollectionFilter widget.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Widgets/FilterButton.ui")]
public class FilterButton : Gtk.Widget {

  // UI-Elements of FilterButton
  [GtkChild]
  private unowned Gtk.ToggleButton button;

  /**
   * The label of this button.
   */
  public string label { get; set; }

  /**
   * If this filter is selected.
   */
  public bool active { get; set; }

  /**
   * Activated when the button is toggled.
   */
  public signal void toggled ();

  /**
   * Runs when the internal button is clicked.
   */
  [GtkCallback]
  private void on_toggled () {
    this.active = button.active;
    toggled ();
  }

  /**
   * Deconstructs FilterButton and it's childrens.
   */
  public override void dispose () {
    // Destructs children of FilterButton
    button.unparent ();
  }

}

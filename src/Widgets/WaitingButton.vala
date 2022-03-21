/* WaitingButton.vala
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
 * Customized button that contains a Gtk.Spinner to indicated async action.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Widgets/WaitingButton.ui")]
public class WaitingButton : Gtk.Widget {

  // UI-Elements of WaitingButton
  [GtkChild]
  private unowned Gtk.Stack waiting_stack;
  [GtkChild]
  private unowned Gtk.Box button_content;
  [GtkChild]
  private unowned Gtk.Spinner waiting_spinner;

  /**
   * If one should wait for an async action.
   */
  public bool waiting {
    get {
      return waiting_spinner.spinning;
    }
    set {
      if (value) {
        waiting_stack.set_visible_child (waiting_spinner);
      } else {
        waiting_stack.set_visible_child (button_content);
      }
      waiting_spinner.spinning = value;
    }
  }

  /**
   * The label of this button.
   */
  public string label { get; set; default = ""; }

  /**
   * The name of an icon for this button.
   */
  public string icon_name { get; set; }

  /**
   * Deconstructs WaitingButton and it's childrens.
   */
  public override void dispose () {
    // Deconstruct childrens
    waiting_stack.unparent ();
  }

}

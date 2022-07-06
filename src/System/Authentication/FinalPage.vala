/* FinalPage.vala
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
 * The page showing the authentication success.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/System/Authentication/FinalPage.ui")]
public class Authentication.FinalPage : Gtk.Widget {

  // UI-Elements of FinalPage
  [GtkChild]
  private unowned Adw.StatusPage page_content;

  /**
   * The AuthView holding this page.
   */
  public weak AuthView view { get; construct; }

  /**
   * Run at construction of the widget.
   */
  construct {
    // Check if children of AuthView
    if (view == null) {
      critical ("Can only be children to AuthView!");
    }
  }

  /**
   * Finalize the authentication.
   */
  [GtkCallback]
  private void on_continue () {
    view.close_auth ();
  }

  /**
   * Deconstructs FinalPage and it's childrens.
   */
  public override void dispose () {
    // Deconstruct childrens
    page_content.unparent ();
  }

}

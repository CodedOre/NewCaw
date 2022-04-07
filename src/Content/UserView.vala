/* UserView.vala
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
 * Displays an User and Posts related to him.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Content/UserView.ui")]
public class UserView : Gtk.Widget {

  // General UI-Elements of UserView
  [GtkChild]
  private unowned Adw.HeaderBar view_header;
  [GtkChild]
  private unowned Gtk.ScrolledWindow view_content;

  /**
   * The User which is displayed.
   */
  public Backend.User user {
    get {
      return displayed_user;
    }
    set {
      displayed_user = value;
    }
  }

  /**
   * Set's the widget up on construction.
   */
  construct {
    // Bind the settings to widget properties
    var settings = new Settings ("uk.co.ibboard.Cawbird.experimental");
    settings.bind ("profile-inline-header", view_header, "visible",
                    GLib.SettingsBindFlags.INVERT_BOOLEAN);
  }

  /**
   * Deconstructs UserCard and it's childrens.
   */
  public override void dispose () {
    // Destructs children of MediaDisplay
    view_header.unparent ();
    view_content.unparent ();
  }

  /**
   * Stores the displayed user.
   */
  private Backend.User displayed_user;

}

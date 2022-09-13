/* AccountSettings.vala
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
 * Provides the subpage with the settings for a specific user.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Preferences/AccountSettings.ui")]
public class Preferences.AccountSettings : Gtk.Widget {

  // UI-Elements of AccountSettings
  [GtkChild]
  private unowned Adw.HeaderBar page_header;
  [GtkChild]
  private unowned Adw.WindowTitle page_title;

  /**
   * The account for which to set the settings.
   */
  public Backend.Account account {
    get {
      return displayed_account;
    }
    set {
      displayed_account   = value;

      // Set the window title to the account names
      page_title.title    = displayed_account != null ? displayed_account.display_name    : "(null)";
      page_title.subtitle = displayed_account != null
                              ? DisplayUtils.prefix_username (displayed_account)
                              : "(null)";
    }
  }

  /**
   * Deconstructs AccountSettings and it's childrens.
   */
  public override void dispose () {
    // Deconstruct childrens
    page_header.unparent ();
    base.dispose ();
  }

  /**
   * Stores the displayed account.
   */
  private Backend.Account? displayed_account = null;

}

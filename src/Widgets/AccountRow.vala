/* AccountRow.vala
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
 * Shows an account in an row and offers options for it.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Widgets/AccountRow.ui")]
public class AccountRow : Adw.ActionRow {

  // UI-Elements of AccountRow
  [GtkChild]
  private unowned UserAvatar account_avatar;

  /**
   * If additional actions should be shown.
   */
  public bool show_actions { get; set; default = true; }

  /**
   * The Account which is displayed.
   */
  public Backend.Account account {
    get {
      return displayed_account;
    }
    set {
      displayed_account = value;

      // Set the information in the UI
      account_avatar.user = displayed_account;
      this.title          = displayed_account != null ? displayed_account.display_name    : "(null)";
      this.subtitle       = displayed_account != null ? @"@$(displayed_account.username)" : "(null)";
    }
  }

  /**
   * Opens the displayed account in a new Window.
   */
  [GtkCallback]
  private void open_in_window () {
    // Only continue with an set account
    if (account == null) {
      return;
    }

    // Get the current MainWindow, to get the application
    var main_window = this.get_root () as MainWindow;
    if (main_window == null) {
      warning ("AccountRow not in a MainWindow, action not possible!");
      return;
    }

    // Create a new MainWindow and display the account
    var window = new MainWindow (main_window.application, account);
    window.present ();
  }

  /**
   * Stores the displayed account.
   */
  private Backend.Account? displayed_account = null;

}

/* AccountsPage.vala
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
 * Displays the page regarding the appearance options.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Preferences/AccountsPage.ui")]
public class Preferences.AccountsPage : Adw.PreferencesPage {

  // UI-Elements of AccountsPage
  [GtkChild]
  private unowned Gtk.ListBox account_list;

  /**
   * Run at construction of the page.
   */
  construct {
    account_list.bind_model (Session.instance.account_list, bind_account);
  }

  /**
   * Activated when one of the listed accounts was activated.
   *
   * @param widget The widget that was clicked in the account list.
   */
  [GtkCallback]
  private void display_account_settings (Gtk.ListBoxRow widget) {
    // Get the AccountRow
    var account_row = widget as AccountRow;
    if (account_row == null) {
      warning ("Activated row is not AccountRow!");
      return;
    }

    // Get the MainWindow
    var pref_window = this.get_root () as PreferencesWindow;
    if (pref_window == null) {
      warning ("AccountsPage not in a PreferencesWindow, action not possible!");
      return;
    }

    // Open the new subview
    pref_window.display_account_settings (account_row.account);
  }

  /**
   * Binds an account to an AccountRow in the accounts list.
   */
  private Gtk.Widget bind_account (Object item) {
    var account         = item as Backend.Account;
    var widget          = new AccountRow ();
    widget.show_actions = false;
    widget.show_next    = true;
    widget.account      = account;
    return widget;
  }

}

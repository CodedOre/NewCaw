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
   * Stores the displayed account.
   */
  private Backend.Account? displayed_account = null;

}

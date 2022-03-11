/* AccountManager.vala
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
 * Manages the Accounts used with this client.
 *
 * This class is responsible to load and to store
 * connected Accounts to the storage.
 */
[SingleInstance]
public class AccountManager : Object {

  /**
   * The single instance of this class.
   */
  public static AccountManager instance {
    get {
      if (global_instance == null) {
        global_instance = new AccountManager ();
      }
      return global_instance;
    }
  }

  /**
   * Constructs the instance.
   */
  private AccountManager () {
    // Initialize the arrays
    account_list = {};
    server_list  = {};
  }

  /**
   * Stores the single instance of this class.
   */
  private static AccountManager? global_instance = null;

  /**
   * Stores all accounts connected to the client.
   */
  private Backend.Account[] account_list;

  /**
   * Stores all servers connected to the client.
   */
  private Backend.Server[] server_list;

}

/* KeyStorage.vala
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
 * Allows to store access tokens from a Server or Account.
 *
 * This uses the Secrets portal to securely store
 * the tokens in the users password storage.
 */
[SingleInstance]
public class Backend.Utils.KeyStorage : Object {

  /**
   * The global instance of KeyStorage.
   */
  public static KeyStorage instance {
    get {
      if (global_instance == null) {
        global_instance = new KeyStorage ();
      }
      return global_instance;
    }
  }

  /**
   * Constructs the KeyStorage instance.
   */
  private KeyStorage () {
  }

  /**
   * Store the access tokens for a Server.
   *
   * @param server The Server which tokens are to be stored.
   */
  public async void store_server_access (Server server) {
  }

  /**
   * Retrieves the access tokens for a Server.
   *
   * @param server The domain to the Server.
   * @param token A reference which will hold the retrieved token.
   * @param secret A reference which will hold the retrieved secret.
   */
  public async void retrieve_server_access (string server, out string token, out string secret) {
  }

  /**
   * Store the access tokens for a Account.
   *
   * @param account The Account which tokens are to be stored.
   */
  public async void store_account_access (Account account) {
  }

  /**
   * Store the access tokens for a Account.
   *
   * Should the tokens be called for an Account originally
   * authenticated with OAuth 2.0, the secret parameter
   * is not needed and can be omitted.
   *
   * @param account The username for the account.
   * @param token A reference which will hold the retrieved token.
   * @param secret A reference which will hold the retrieved secret.
   */
  public async void retrieve_account_access (string account, out string token, out string? secret = null) {
  }

  /**
   * Stores the global instance of KeyStorage.
   *
   * Only access over the instance property!
   */
  private static KeyStorage? global_instance = null;

  /**
   * The password scheme used to identify passwords for this backend.
   */
  private Secret.Schema secret_schema;

}

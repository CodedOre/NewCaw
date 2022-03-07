/* Account.vala
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
 * Error domain for errors in Account.
 */
errordomain AccountError {
  FAILED_TOKEN_REQUEST
}

/**
 * Represents an Profile that uses this library.
 *
 * Account extends Profile to add the
 * properties and methods to allow it to
 * interact with the API provided by the platform.
 */
public abstract class Backend.Account : Backend.Profile {

  /**
   * The access token for this specific Account.
   */
  public string access_token { get; private set; }

  /**
   * The access secret for this specific Account.
   */
  public string access_secret { get; private set; }

  /**
   * If the account was successfully authenticated at the server.
   */
  public bool authenticated { get; private set; }

  /**
   * The server this account is connected to.
   */
  public Server server { get; construct; }

  /**
   * Prepares the link to launch the authentication of a new Account.
   *
   * The returned url should be opened in a browser, so the
   * user can generate a authentication code
   * that can be given to the authenticate method.
   *
   * @return The link with the site to authenticate the user.
   *
   * @throws Error Any error occurring while requesting the token.
   */
  public abstract async string init_authentication () throws Error;

  /**
   * Authenticates the account with an code.
   *
   * This method should be run after init_authentication and use
   * the code retrieved from the site where the user authenticated himself.
   *
   * After completion, you should save the access token retrieved
   * from the platform so you can use the login method on following runs.
   *
   * @param auth_code The authentication code for the user.
   *
   * @throws Error Any error occurring while requesting the token.
   */
  public abstract async void authenticate (string auth_code) throws Error;

  /**
   * Creates an Account with existing access token.
   *
   * @param token The access token for the account.
   * @param secret The secret for the access token.
   *
   * @throws Error Any error occurring while requesting the token.
   */
  public abstract async void login (string token, string secret) throws Error;

  /**
   * Creates a Rest.ProxyCall to perform an API call.
   *
   * @return A Rest.ProxyCall that can be then called with Server.call.
   */
  internal Rest.ProxyCall create_call () {
    assert (proxy != null);
    return proxy.new_call ();
  }

  /**
   * The proxy used to authorize the API calls.
   */
  private Rest.Proxy? proxy = null;

}

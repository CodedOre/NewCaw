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
 * Represents an Profile that uses this library.
 *
 * Account extends Profile to add the
 * properties and methods to allow it to
 * interact with the API provided by the platform.
 */
public class Backend.Mastodon.Account : Backend.Account {

  /**
   * Constructs an object for an Account.
   *
   * Not to be called directly, but from the static methods
   * Account.authenticate and Account.login.
   *
   * @param json The Json.Object with the account data.
   * @param call_proxy The Rest.Proxy for making calls.
   */
  private Account (Json.Object json, Rest.OAuthProxy call_proxy) {
  }

  /**
   * Creates an Account with existing access token.
   *
   * @param token The access token for the account.
   * @param secret The secret for the access token.
   *
   * @return The constructed Account.
   *
   * @throws Error Any error occurring while requesting the token.
   */
  public static async Account login (string token, string secret) throws Error {
  }

  /**
   * Finalizes a Account-authentication and creates the object.
   *
   * This constructor should be run after
   * init_authentication and use the code retrieved
   * from the site where the user authenticated himself.
   *
   * After construction, you should save the access token retrieved
   * from the platform so you can use the normal constructor.
   *
   * @param auth_code The authentication code for the user.
   *
   * @return The constructed Account.
   *
   * @throws Error Any error occurring while requesting the token.
   */
  public static async Account authenticate (string auth_code) throws Error {
  }

  /**
   * Prepares the link to launch the authentication of a new Account.
   *
   * @return The link with the site to authenticate the user.
   *
   * @throws Error Any error occurring while requesting the token.
   */
  public static async string init_authentication () throws Error {
  }

  /**
   * Creates a Rest.ProxyCall to perform an API call.
   */
  internal override Rest.ProxyCall create_call () {
    assert (proxy != null);
    return proxy.new_call ();
  }

  /**
   * The proxy used to authorize the API calls.
   */
  private Rest.OAuth2Proxy proxy;

}

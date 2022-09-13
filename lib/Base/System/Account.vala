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
 * Represents an User that uses this library.
 *
 * Account extends User to add the
 * properties and methods to allow it to
 * interact with the API provided by the platform.
 */
public abstract class Backend.Account : Backend.User {

  /**
   * The access token for this specific Account.
   */
  public string access_token { get; protected set; }

  /**
   * If the account was successfully authenticated at the server.
   */
  public bool authenticated { get; protected set; }

  /**
   * If the data for the account was successfully loaded.
   */
  public bool loaded { get; protected set; }

  /**
   * The server this account is connected to.
   */
  public weak Server server { get; construct; }

  /**
   * Prepares the link to launch the authentication of a new Account.
   *
   * The returned url should be opened in a browser, so the
   * user can generate a authentication code
   * that can be given to the authenticate method.
   *
   * @param use_redirect Use the clients redirect uri for authentication callback.
   *
   * @return The link with the site to authenticate the user.
   *
   * @throws Error Any error occurring while requesting the token.
   */
  public abstract string init_authentication (bool use_redirect = true) throws Error;

  /**
   * Authenticates the account with an code.
   *
   * This method should be run after init_authentication and use
   * the code retrieved from the site where the user authenticated himself.
   *
   * After completion, you should save the access token retrieved
   * from the platform so you can use the login method on following runs.
   *
   * When authenticating with an automatic callback using a redirect uri, it
   * is highly recommended to pass the state parameter on to improve security.
   *
   * @param auth_code The authentication code for the user.
   * @param state An additional code verified locally.
   *
   * @throws Error Any error occurring while requesting the token.
   */
  public abstract async void authenticate (string auth_code, string? state = null) throws Error;

  /**
   * Creates an Account with existing access token.
   *
   * @param token The access token for the account.
   *
   * @throws Error Any error occurring while requesting the token.
   */
  public abstract void login (string token) throws Error;

  /**
   * Loads the data about this Account.
   *
   * Needs to be run after the account is authenticated.
   *
   * @throws Error Any error that happened while loading the data.
   */
  public abstract async void load_data () throws Error;

  /**
   * Removes the account access for a client.
   *
   * This should only be called when the user removes the account from
   * his client, as this removes the authentication from the server.
   *
   * @throws Error Any error occurring while removing the account.
   */
  public abstract async void revoke_access () throws Error;

  /**
   * Creates a Rest.ProxyCall to perform an API call.
   *
   * @return A Rest.ProxyCall that can be then called with Server.call.
   */
  internal abstract Rest.ProxyCall create_call ();

}

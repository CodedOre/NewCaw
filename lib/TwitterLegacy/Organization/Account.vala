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
public class Backend.TwitterLegacy.Account : Backend.Account {

  /**
   * Creates an Account with existing access token.
   *
   * @param token The access token for the account.
   * @param secret The secret for the access token.
   */
  public Account (string token, string secret) {
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
   */
  public Account.authenticate (string auth_code) {
  }

  /**
   * Prepares the link to launch the authentication of a new Account.
   *
   * @return The link with the site to authenticate the user.
   *
   * @throws Error Any error occurring while requesting the token.
   */
  public static string init_authentication () throws Error {
    // Create call proxy
    var token_proxy = new Rest.OAuthProxy (Platform.client_key,
                                           Platform.client_secret,
                                           "https://api.twitter.com",
                                           false);

    // Get temporary token
    try {
      token_proxy.request_token_async.begin ("oauth/request_token", "oob", null, (obj, res) => {
        bool token_request = token_proxy.request_token_async.end (res);
        if (!token_request) {
          throw new AccountError.FAILED_TOKEN_REQUEST ("No token retrieved from API");
        }
      });
    } catch (Error e) {
      throw e;
    }

    // Return authentication link
    return @"$(token_proxy.url_format)/oauth/authorize?oauth_token=$(token_proxy.token)";
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
  private Rest.OAuthProxy proxy;

}

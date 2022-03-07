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
   * Sets the Profile data for this Account.
   *
   * @param json A Json.Object retrieved from the API.
   */
  private void set_profile_data (Json.Object json) {
    // Get the url for avatar and header
    string avatar_url = json.get_string_member ("avatar_static");
    string header_url = json.get_string_member ("header_static");

    // Get url and domain to this account
    string account_url = json.get_string_member ("url");
    string account_domain = Utils.ParseUtils.strip_domain (account_url);

    // Set the id of the account
    id = json.get_string_member ("id");

    // Set the creation date for the account
    creation_date = new DateTime.from_iso8601 (
                      json.get_string_member ("created_at"),
                      new TimeZone.utc ()
                    );

    // Set the names of the account
    display_name = json.get_string_member ("display_name");
    username     = json.get_string_member ("acct");

    // Set the url and domain
    url    = account_url;
    domain = account_domain;

    // Set metrics
    followers_count = (int) json.get_int_member ("followers_count");
    following_count = (int) json.get_int_member ("following_count");
    posts_count     = (int) json.get_int_member ("statuses_count");

    // Set the images
    avatar = new Media (PICTURE, avatar_url);
    header = new Media (PICTURE, header_url);

    // Parse the description into modules and create a formatted version
    description_modules = Utils.TextUtils.parse_text (json.get_string_member ("note"));
    description = Backend.Utils.TextUtils.format_text (description_modules);

    // Parses all fields
    data_fields = Utils.ParseUtils.parse_data_fields (json.get_array_member ("fields"));

    // Get possible flags for this user
    if (json.get_boolean_member ("locked")) {
      flags = flags | MODERATED;
    }
    if (json.get_boolean_member ("bot")) {
      flags = flags | BOT;
    }
  }

  /**
   * Creates an unauthenticated Account for a server.
   *
   * After construction, it is required to either authenticate the account,
   * using the methods init_authentication and authenticate,
   * or to login with the method login.
   *
   * @param server The server to connect to with the account.
   */
  public Account (Server server) {
    // Construct the object with server information
    Object (
      server:        server,
      authenticated: false
    );
  }

  /**
   * Prepares the link to launch the authentication of a new Account.
   *
   * @return The link with the site to authenticate the user.
   *
   * @throws Error Any error occurring while requesting the token.
   */
  public async string init_authentication () throws Error {
    // Check if authentication is necessary
    if (authenticated) {
      error ("Already authenticated!");
    }

    // Get Client instance and determine used redirect uri
    Client application    = Client.instance;
    string used_redirects = application.redirect_uri != null
                              ? application.redirect_uri
                              : Server.OOB_REDIRECT;

    // Create call proxy
    var auth_proxy = new Rest.OAuth2Proxy (@"$(server.domain)/oauth/authorize",
                                           @"$(server.domain)/oauth/token",
                                           used_redirects,
                                           server.client_key,
                                           server.client_secret,
                                           server.domain);

    // Create code challenge
    var auth_challenge = new Rest.PkceCodeChallenge.random ();

    // Build authorization url
    string output = auth_proxy.build_authorization_url (auth_challenge.get_challenge (),
                                                        "read write follow push",
                                                        null);
    return output;
  }

}

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
   * @param server The server to connect to with the account.
   * @param json The Json.Object with the account data.
   * @param call_proxy The Rest.Proxy for making calls.
   */
  private Account (Server server, Json.Object json, Rest.OAuth2Proxy call_proxy) {
    // Get the url for avatar and header
    string avatar_url = json.get_string_member ("avatar_static");
    string header_url = json.get_string_member ("header_static");

    // Get url and domain to this account
    string account_url = json.get_string_member ("url");
    string account_domain = Utils.ParseUtils.strip_domain (account_url);

    // Construct the object with properties
    Object (
      // Set Account-specific properties
      server: server,

      // Set the id of the account
      id: json.get_string_member ("id"),

      // Set the creation date for the account
      creation_date: new DateTime.from_iso8601 (
                       json.get_string_member ("created_at"),
                       new TimeZone.utc ()
                     ),

      // Set the names of the account
      display_name: json.get_string_member ("display_name"),
      username:     json.get_string_member ("acct"),

      // Set the url and domain
      url:    account_url,
      domain: account_domain,

      // Set metrics
      followers_count: (int) json.get_int_member ("followers_count"),
      following_count: (int) json.get_int_member ("following_count"),
      posts_count:     (int) json.get_int_member ("statuses_count"),

      // Set the images
      avatar: new Media (PICTURE, avatar_url),
      header: new Media (PICTURE, header_url)
    );

    // Set the proxy
    proxy = call_proxy;

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

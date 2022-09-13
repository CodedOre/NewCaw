/* User.vala
 *
 * Copyright 2021-2022 Frederick Schenk
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
 * Stores information about one user of a platform.
 */
public class Backend.Mastodon.User : Backend.User {

  /**
   * Returns a User object for a specific user name.
   *
   * If an object for the user was already created, that object is returned.
   * Otherwise the json will be loaded from the server and an object created from it.
   *
   * @param username The name for the user, in the format "username@domain".
   * @param account An account to authenticate the loading of the user.
   *
   * @throws Error Any error that could happen while the user is loaded.
   */
  public static async User from_username (string username, Backend.Account account) throws Error {
    // Initialize the storage if needed
    if (all_users == null) {
      all_users = new HashTable <string, User> (str_hash, str_equal);
    }

    // Attempt to retrieve the user from storage
    User? user = all_users.contains (username)
                   ? all_users [username]
                   : null;

    // Create new object if not in storage
    if (user == null) {
      // Create the proxy call
      Rest.ProxyCall call = account.create_call ();
      call.set_method ("GET");
      call.set_function (@"api/v1/accounts/search");
      call.add_param ("q", username);
      call.add_param ("limit", "1");

      // Load the user
      Json.Node json;
      try {
        json = yield account.server.call (call);
      } catch (Error e) {
        throw e;
      }
      Json.Array list = json.get_array ();

      // Retrieve the user json
      Json.Object object = list.get_object_element (0);

      // Create a new user from the data
      user = User.from_json (object);
    }

    // Return the object
    return user;
  }

  /**
   * Returns a User object for a given Json.Object.
   *
   * If an object for the user was already created, that object is returned.
   * Otherwise a new object will be created from the json object.
   *
   * @param json A Json.Object retrieved from the API.
   */
  public static User from_json (Json.Object json) {
    // Initialize the storage if needed
    if (all_users == null) {
      all_users = new HashTable <string, User> (str_hash, str_equal);
    }

    // Attempt to retrieve the user from storage
    string url    = json.get_string_member ("url");
    string domain = Utils.ParseUtils.strip_domain (url);
    string name   = json.get_string_member ("username");
    string id     = @"$(name)@$(domain)";
    User?  user   = all_users.contains (id)
                      ? all_users [id]
                      : null;

    // Create new object if not in storage
    if (user == null) {
      user = new User (json);
      all_users [id] = user;
    }

    // Return the object
    return user;
  }

  /**
   * Parses an given Json.Object and creates an User object.
   *
   * @param json A Json.Object retrieved from the API.
   */
  private User (Json.Object json) {
    // Get the url for avatar and header
    string avatar_url = json.get_string_member ("avatar_static");
    string header_url = json.get_string_member ("header_static");

    // Get url and domain to this user
    string user_url = json.get_string_member ("url");
    string user_domain = Utils.ParseUtils.strip_domain (user_url);

    // Construct the object with properties
    Object (
      // Set the id of the user
      id: json.get_string_member ("id"),

      // Set the creation date for the user
      creation_date: new DateTime.from_iso8601 (
                       json.get_string_member ("created_at"),
                       new TimeZone.utc ()
                     ),

      // Set the names of the user
      display_name: json.get_string_member ("display_name"),
      username:     json.get_string_member ("acct"),

      // Set the url and domain
      url:    user_url,
      domain: user_domain,

      // Set metrics
      followers_count: (int) json.get_int_member ("followers_count"),
      following_count: (int) json.get_int_member ("following_count"),
      posts_count:     (int) json.get_int_member ("statuses_count"),

      // Set the images
      avatar: avatar_url.length > 0 ? Media.from_url (PICTURE, avatar_url) : null,
      header: header_url.length > 0 ? Media.from_url (PICTURE, header_url) : null
    );

    // Parse the description into modules
    description_modules = Utils.TextParser.instance.parse_text (json.get_string_member ("note"));

    // First format of the description.
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
   * Stores a reference to each user currently in memory.
   */
  private static HashTable <string, User> all_users;

}

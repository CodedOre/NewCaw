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
public class Backend.Twitter.User : Backend.User {

  /**
   * Returns a User object for a specific user name.
   *
   * If an object for the user was already created, that object is returned.
   * Otherwise the json will be loaded from the server and an object created from it.
   *
   * @param username The name for the user.
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
      call.set_function (@"users/by/username/$(username)");
      Server.append_user_fields (ref call);

      // Load the user
      Json.Node json;
      try {
        json = yield account.server.call (call);
      } catch (Error e) {
        throw e;
      }
      Json.Object data = json.get_object ();

      // Retrieve the user json
      Json.Object object;
      if (data.has_member ("data")) {
        object = data.get_object_member ("data");
      } else {
        error ("Could not retrieve user object!");
      }

      // Retrieve the includes json
      Json.Object includes;
      if (data.has_member ("includes")) {
        includes = data.get_object_member ("includes");
      } else {
        includes = null;
      }

      // Create a new user from the data
      user = User.from_json (object, includes);
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
   * @param data The Json.Object containing the specific User.
   * @param includes A Json.Object including additional objects which may be related to this User.
   */
  public static User from_json (Json.Object data, Json.Object? includes = null) {
    // Initialize the storage if needed
    if (all_users == null) {
      all_users = new HashTable <string, User> (str_hash, str_equal);
    }

    // Attempt to retrieve the user from storage
    string id   = data.get_string_member ("username");
    User?  user = all_users.contains (id)
                    ? all_users [id]
                    : null;

    // Create new object if not in storage
    if (user == null) {
      user = new User (data, includes);
      all_users [id] = user;
    }

    // Return the object
    return user;
  }

  /**
   * Parses an given Json.Object and creates an User object.
   *
   * @param data The Json.Object containing the specific User.
   * @param includes A Json.Object including additional objects which may be related to this User.
   */
  private User (Json.Object data, Json.Object? includes = null) {
    // Get metrics object
    Json.Object metrics = data.get_object_member ("public_metrics");

    // Parse the avatar image url
    string avatar_preview_url = data.get_string_member ("profile_image_url");
    string avatar_media_url   = Utils.ParseUtils.parse_user_image (avatar_preview_url);

    // Get strings used to compose the url.
    string user_name = data.get_string_member ("username");

    // Construct the object with properties
    Object (
      // Set the id of the user
      id: data.get_string_member ("id"),

      // Set the creation data
      creation_date: new DateTime.from_iso8601 (
                       data.get_string_member ("created_at"),
                       new TimeZone.utc ()
                     ),

      // Set the names of the user
      display_name: data.get_string_member ("name"),
      username:     user_name,

      // Set url and domain
      domain: "Twitter.com",
      url:    @"https://twitter.com/$(user_name)",

      // Set metrics
      followers_count: (int) metrics.get_int_member ("followers_count"),
      following_count: (int) metrics.get_int_member ("following_count"),
      posts_count:     (int) metrics.get_int_member ("tweet_count"),

      // Set the ImageLoader for the avatar
      avatar: avatar_preview_url.length > 0 ? Media.from_url (PICTURE, avatar_media_url, avatar_preview_url) : null,
      header: null
    );

    // Parse text into modules
    Json.Object? description_entities = null;
    string       raw_text             = "";
    if (data.has_member ("description")) {
      raw_text = data.get_string_member ("description");
    }

    // Parse entities
    if (data.has_member ("entities")) {
      Json.Object user_entities = data.get_object_member ("entities");
      // Parse entities for the description
      if (user_entities.has_member ("description")) {
        description_entities = user_entities.get_object_member ("description");
      }
    }
    description_modules = Utils.TextUtils.parse_text (raw_text, description_entities);

    // First format of the description.
    description = Backend.Utils.TextUtils.format_text (description_modules);

    // Store additional information in data fields
    data_fields = Utils.ParseUtils.parse_data_fields (data);

    // Get possible flags for this user
    if (data.get_boolean_member ("protected")) {
      flags = flags | MODERATED | PROTECTED;
    }
    if (data.get_boolean_member ("verified")) {
      flags = flags | VERIFIED;
    }
  }

  /**
   * Stores a reference to each user currently in memory.
   */
  private static HashTable <string, User> all_users;

}

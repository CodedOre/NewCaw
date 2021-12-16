/* User.vala
 *
 * Copyright 2021 Frederick Schenk
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
public class Backend.Mastodon.User : Object, Backend.User {

  /**
   * The identifier of the user in the API.
   */
  public string id { get; construct; }

  /**
   * The "name" of the user.
   */
  public string display_name { get; construct; }

  /**
   * The unique handle of this user.
   */
  public string username { get; construct; }

  /**
   * The avatar image from this user.
   */
  public Backend.Picture avatar { get; construct; }

  /**
   * Parses an given Json.Object and creates an User object.
   *
   * @param json A Json.Object retrieved from the API.
   */
  public User.from_json (Json.Object json) {
    // Get the url for the avatar
    string avatar_url = json.get_string_member ("avatar_static");

    // Construct the object with properties
    Object (
      // Set the id of the user
      id: json.get_string_member ("id"),

      // Set the names of the user
      display_name: json.get_string_member ("display_name"),
      username:     json.get_string_member ("username"),

      // Set the Picture for the avatar
      avatar: new Picture (avatar_url)
    );

    // Get possible flags for this user
    if (json.get_boolean_member ("locked")) {
      flags = flags | MODERATED;
    }
    if (json.get_boolean_member ("bot")) {
      flags = flags | BOT;
    }
  }

  /**
   * Checks if the User has a certain flag set.
   */
  public bool has_flag (UserFlag flag) {
    return flag in flags;
  }

  /**
   * Stores the flags for this user.
   */
  protected UserFlag flags;

}

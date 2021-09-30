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
public class Backend.TwitterLegacy.User : Object, Backend.User {

  /**
   * The identifier of the user in the API.
   */
  public string id { get; }

  /**
   * The "name" of the user.
   */
  public string display_name { get; }

  /**
   * The unique handle of this user.
   */
  public string username { get; }

  /**
   * Parses an given Json.Object and creates an User object.
   *
   * @param json A Json.Object retrieved from the API.
   */
  public User.from_json (Json.Object json) {
    // Parses the id from this User
    _id = json.get_string_member ("id_str");

    // Parses the names from this User
    _display_name = json.get_string_member ("name");
    _username     = json.get_string_member ("screen_name");
  }

}
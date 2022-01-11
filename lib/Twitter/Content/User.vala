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
public class Backend.Twitter.User : Backend.User {

  /**
   * Parses an given Json.Object and creates an User object.
   *
   * @param data The Json.Object containing the specific Post.
   * @param includes A Json.Object including additional objects which may be related to this Post.
   */
  public User.from_json (Json.Object data, Json.Object? includes = null) {
    // Parse the avatar image url
    string avatar_preview_url = data.get_string_member ("profile_image_url");
    string avatar_media_url;
    try {
      var image_regex = new Regex ("(https://pbs.twimg.com/.*?)_normal(\\..*)");
      avatar_media_url = image_regex.replace (
        avatar_preview_url,
        avatar_preview_url.length,
        0,
        "\\1\\2"
      );
    } catch (RegexError e) {
      error (@"Error while parsing source: $(e.message)");
    }

    // Construct the object with properties
    Object (
      // Set the id of the user
      id: data.get_string_member ("id"),

      // Set the names of the user
      display_name: data.get_string_member ("name"),
      username:     data.get_string_member ("username"),

      // Set the Media for the avatar
      avatar: new Media (PICTURE, avatar_media_url, avatar_preview_url)
    );

    // Get possible flags for this user
    if (data.get_boolean_member ("protected")) {
      flags = flags | MODERATED | PROTECTED;
    }
    if (data.get_boolean_member ("verified")) {
      flags = flags | VERIFIED;
    }
  }

}

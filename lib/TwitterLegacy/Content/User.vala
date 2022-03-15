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
public class Backend.TwitterLegacy.User : Backend.User {

  /**
   * Parses an given Json.Object and creates an User object.
   *
   * @param json A Json.Object retrieved from the API.
   */
  public User.from_json (Json.Object json) {
    // Parse the url for avatar and header
    string  avatar_preview_url = json.get_string_member ("profile_image_url_https");
    string  avatar_media_url   = Utils.ParseUtils.parse_user_image (avatar_preview_url);
    string? header_preview_url = json.has_member ("profile_banner_url")
                                  ? json.get_string_member ("profile_banner_url")
                                  : null;
    string? header_media_url   = header_preview_url != null
                                  ? Utils.ParseUtils.parse_user_image (header_preview_url)
                                  : null;

    // Get strings used to compose the url.
    string user_name = json.get_string_member ("screen_name");

    // Construct the object with properties
    Object (
      // Set the id of the user
      id: json.get_string_member ("id_str"),

      // Set the creation data
      creation_date: Utils.TextUtils.parse_time (json.get_string_member ("created_at")),

      // Set the names of the user
      display_name: json.get_string_member ("name"),
      username:     user_name,

      // Set url and domain
      domain: "Twitter.com",
      url:    @"https://twitter.com/$(user_name)",

      // Set metrics
      followers_count: (int) json.get_int_member ("followers_count"),
      following_count: (int) json.get_int_member ("friends_count"),
      posts_count:     (int) json.get_int_member ("statuses_count"),

      // Set the ImageLoader for the avatar
      avatar: new Media (PICTURE, avatar_media_url, avatar_preview_url),
      header: header_preview_url != null
                ? new Media (PICTURE, header_media_url, header_preview_url)
                : null
    );

    // Parse the text into modules
    Json.Object? description_entities = null;
    string       raw_text             = json.get_string_member ("description");

    // Parse entities
    if (json.has_member ("entities")) {
      Json.Object user_entities = json.get_object_member ("entities");
      // Parse entities for the description
      if (user_entities.has_member ("description")) {
        description_entities = user_entities.get_object_member ("description");
      }
    }
    description_modules = Utils.TextUtils.parse_text (raw_text, description_entities);

    // First format of the description.
    description = Backend.Utils.TextUtils.format_text (description_modules);

    // Store additional information in data fields
    data_fields = Utils.ParseUtils.parse_data_fields (json);

    // Get possible flags for this user
    if (json.get_boolean_member ("protected")) {
      flags = flags | MODERATED | PROTECTED;
    }
    if (json.get_boolean_member ("verified")) {
      flags = flags | VERIFIED;
    }
  }

}

/* Profile.vala
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

public class Backend.Twitter.Profile : Backend.Profile {

  /**
   * Parses an given Json.Object and creates an Profile object.
   *
   * @param data The Json.Object containing the specific Post.
   * @param includes A Json.Object including additional objects which may be related to this Post.
   */
  public Profile.from_json (Json.Object data, Json.Object? includes = null) {
    // Get metrics object
    Json.Object metrics = data.get_object_member ("public_metrics");

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

    // Get strings used to compose the url.
    string profile_name = data.get_string_member ("username");

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
      username:     profile_name,

      // Set url and domain
      domain: PLATFORM_DOMAIN,
      url:    @"https://$(PLATFORM_DOMAIN)/$(profile_name)",

      // Set metrics
      followers_count: (int) metrics.get_int_member ("followers_count"),
      following_count: (int) metrics.get_int_member ("following_count"),
      posts_count:     (int) metrics.get_int_member ("tweet_count"),

      // Set the ImageLoader for the avatar
      avatar: new Media (PICTURE, avatar_media_url, avatar_preview_url),
      header: null
    );

    // Parse text into modules
    Json.Object? description_entities = null;
    Json.Object? weblink_entity       = null;
    string       raw_text             = "";
    if (data.has_member ("description")) {
      raw_text = data.get_string_member ("description");
    }

    // Parse entities
    if (data.has_member ("entities")) {
      Json.Object profile_entities = data.get_object_member ("entities");
      // Parse entities for the description
      if (profile_entities.has_member ("description")) {
        description_entities = profile_entities.get_object_member ("description");
      }
      // Parse entity for the linked url
      if (profile_entities.has_member ("url")) {
        Json.Object profile_urls = profile_entities.get_object_member ("url");
        Json.Array  urls_array   = profile_urls.get_array_member ("urls");
        // It should only have one element, so assuming this to avoid an loop
        Json.Node url_node = urls_array.get_element (0);
        if (url_node.get_node_type () == OBJECT) {
          weblink_entity = url_node.get_object ();
        }
      }
    }
    description_modules = TextUtils.parse_text (raw_text, description_entities);

    // Store additional information in data fields
    UserDataField[] additional_fields = {};
    if (data.has_member ("location")) {
      if (data.get_string_member ("location") != "") {
        var new_field      = UserDataField ();
        new_field.type     = LOCATION;
        new_field.name     = "Location";
        new_field.display  = data.get_string_member ("location");
        new_field.target   = null;
        additional_fields += new_field;
      }
    }
    if (weblink_entity != null) {
      var new_field      = UserDataField ();
      new_field.type     = WEBLINK;
      new_field.name     = "Weblink";
      new_field.display  = weblink_entity.get_string_member ("display_url");
      new_field.target   = weblink_entity.get_string_member ("expanded_url");
      additional_fields += new_field;
    }
    data_fields = additional_fields;

    // Get possible flags for this user
    if (data.get_boolean_member ("protected")) {
      flags = flags | MODERATED | PROTECTED;
    }
    if (data.get_boolean_member ("verified")) {
      flags = flags | VERIFIED;
    }
  }

}

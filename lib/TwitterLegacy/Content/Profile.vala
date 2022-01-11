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

public class Backend.TwitterLegacy.Profile : Backend.Profile {

  /**
   * Parses an given Json.Object and creates an Profile object.
   *
   * @param json A Json.Object retrieved from the API.
   */
  public Profile.from_json (Json.Object json) {
    // Parse the url for avatar and header
    string avatar_preview_url = json.get_string_member ("profile_image_url_https");
    string header_preview_url = json.has_member ("profile_banner_url") ?
                                  json.get_string_member ("profile_banner_url")
                                  : null;
    string header_media_url = "", avatar_media_url;
    try {
      var image_regex = new Regex ("(https://pbs.twimg.com/.*?)_normal(\\..*)");
      avatar_media_url = image_regex.replace (
        avatar_preview_url,
        avatar_preview_url.length,
        0,
        "\\1\\2"
      );
      if (header_preview_url != null) {
        header_media_url = image_regex.replace (
          header_preview_url,
          header_preview_url.length,
          0,
          "\\1\\2"
        );
      }
    } catch (RegexError e) {
      error (@"Error while parsing source: $(e.message)");
    }

    // Get strings used to compose the url.
    string profile_name = json.get_string_member ("screen_name");

    // Construct the object with properties
    Object (
      // Set the id of the profile
      id: json.get_string_member ("id_str"),

      // Set the creation data
      creation_date: TextUtils.parse_time (json.get_string_member ("created_at")),

      // Set the names of the profile
      display_name: json.get_string_member ("name"),
      username:     profile_name,

      // Set url and domain
      domain: PLATFORM_DOMAIN,
      url:    @"https://$(PLATFORM_DOMAIN)/$(profile_name)",

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
    Json.Object? weblink_entity       = null;
    string       raw_text             = json.get_string_member ("description");

    // Parse entities
    if (json.has_member ("entities")) {
      Json.Object profile_entities = json.get_object_member ("entities");
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
    if (json.has_member ("location")) {
      if (json.get_string_member ("location") != "") {
        var new_field      = UserDataField ();
        new_field.type     = LOCATION;
        new_field.name     = "Location";
        new_field.display  = json.get_string_member ("location");
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

    // Get possible flags for this profile
    if (json.get_boolean_member ("protected")) {
      flags = flags | MODERATED | PROTECTED;
    }
    if (json.get_boolean_member ("verified")) {
      flags = flags | VERIFIED;
    }
  }

}

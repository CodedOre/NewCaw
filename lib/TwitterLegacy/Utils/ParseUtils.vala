/* ParseUtils.vala
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
 * Provides utilities used parsing the json of content.
 */
namespace Backend.TwitterLegacy.Utils.ParseUtils {

  /**
   * Get the high resolution url for an user image.
   *
   * @param url The url to be parsed.
   *
   * @return The url changed to point to the original media.
   */
  private string parse_user_image (string url) {
    // Use Regex to remove the `_normal` url extension.
    try {
      var image_regex = new Regex ("(https://pbs.twimg.com/.*?)_normal(\\..*)");
      return image_regex.replace (
        url, url.length,
        0, "\\1\\2"
      );
    } catch (RegexError e) {
      error (@"Error while parsing source: $(e.message)");
    }
  }

  /**
   * Parses the data stored in UserDataFields and returns them.
   *
   * @param json The Json.Object containing the data.
   *
   * @return An array of UserDataFields containing the data.
   */
  private UserDataField[] parse_data_fields (Json.Object json) {
    // Create method variables
    UserDataField[] fields         = {};
    Json.Object?    weblink_entity = null;

    // Search for weblink entity
    if (json.has_member ("entities")) {
      Json.Object user_entities = json.get_object_member ("entities");
      // Parse entity for the linked url
      if (user_entities.has_member ("url")) {
        Json.Object user_urls = user_entities.get_object_member ("url");
        Json.Array  urls_array   = user_urls.get_array_member ("urls");
        // It should only have one element, so assuming this to avoid an loop
        Json.Node url_node = urls_array.get_element (0);
        if (url_node.get_node_type () == OBJECT) {
          weblink_entity = url_node.get_object ();
        }
      }
    }

    // Store location as field
    if (json.has_member ("location")) {
      if (json.get_string_member ("location") != "") {
        var new_field      = UserDataField ();
        new_field.type     = LOCATION;
        new_field.name     = "Location";
        new_field.display  = json.get_string_member ("location");
        new_field.target   = null;
        fields            += new_field;
      }
    }

    // Store weblink as field
    if (weblink_entity != null) {
      var new_field      = UserDataField ();
      new_field.type     = WEBLINK;
      new_field.name     = "Weblink";
      new_field.display  = weblink_entity.get_string_member ("display_url");
      new_field.target   = weblink_entity.get_string_member ("expanded_url");
      fields            += new_field;
    }

    // Return array
    return fields;
  }

}

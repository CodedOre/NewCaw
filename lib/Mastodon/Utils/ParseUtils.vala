/* ParseUtils.vala
 *
 * Copyright 2022 CodedOre <47981497+CodedOre@users.noreply.github.com>
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
namespace Backend.Mastodon.Utils.ParseUtils {

  /**
   * Get the domain from a url.
   *
   * @param url The url for the domain.
   *
   * @return The domain from the url.
   */
  private string strip_domain (string url) {
    // Run a Regex to get the domain
    try {
      var regex = new Regex ("https?://(www.)?(.*?)/.*");
      return regex.replace (
        url,
        url.length,
        0,
        "\\2"
      );
    } catch (RegexError e) {
      error (@"Error while parsing domain: $(e.message)");
    }
  }

  /**
   * Parses the user data fields for use.
   *
   * @param json The Json.Array containing the data fields.
   *
   * @return An array with the data fields as UserDataField.
   */
  private UserDataField[] parse_data_fields (Json.Array json) {
    UserDataField[] parsed_fields = {};
    json.foreach_element ((array, index, element) => {
      if (element.get_node_type () == OBJECT) {
        // Create an data field object
        Json.Object obj = element.get_object ();
        var new_field   = UserDataField ();
        new_field.type  = GENERIC;
        new_field.name  = obj.get_string_member ("name");
        // Check if field contains weblink
        try {
          var link_regex = new Regex ("<a href=\"(.*?)\" rel=\".*?\" target=\"_blank\"><span class=\"invisible\">.*?</span><span class=\"\">(.*?)</span><span class=\"invisible\"></span></a>");
          if (link_regex.match (obj.get_string_member ("value"))) {
            new_field.display = link_regex.replace (obj.get_string_member ("value"), obj.get_string_member ("value").length, 0, "\\2");
            new_field.target  = link_regex.replace (obj.get_string_member ("value"), obj.get_string_member ("value").length, 0, "\\1");
          } else {
            new_field.display = obj.get_string_member ("value");
            new_field.target  = null;
          }
        } catch (RegexError e) {
          error (@"Error while parsing data fields: $(e.message)");
        }
        // Append field to the array
        parsed_fields  += new_field;
      }
    });
    return parsed_fields;
  }

}

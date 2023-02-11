/* UserDataField.vala
 *
 * Copyright 2023 Frederick Schenk
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
 * A field storing specific information about a User.
 */
public class Backend.Mastodon.UserDataField : Backend.UserDataField {

  /**
   * Parses the user data fields into a ListModel for a User.
   *
   * @param json The Json.Array containing the data fields.
   *
   * @return An ListModel with the data fields as UserDataField.
   */
  internal static ListModel parse_list (Json.Array json) {
    var parsed_fields = new ListStore (typeof (UserDataField));
    json.foreach_element ((array, index, element) => {
      if (element.get_node_type () == OBJECT) {
        Json.Object obj = element.get_object ();
        parsed_fields.append (new UserDataField (obj));
      }
    });
    return parsed_fields;
  }

  /**
   * Creates a new object from a provided JSON.
   *
   * @param json The json for this data field.
   */
  private UserDataField (Json.Object json) {
    // Retrieve the content text surrounded by <p> so that TextParser can handle it.
    string       field_text = "<p>" + json.get_string_member ("value") + "</p>";
    TextModule[] field_mods = Utils.TextParser.instance.parse_text (field_text);

    // Construct object
    Object (
      name: json.get_string_member ("name"),
      content: Backend.Utils.TextUtils.format_text (field_mods, false),
      verified: ! json.get_null_member ("verified_at")
                  ? new DateTime.from_iso8601 (
                    json.get_string_member ("verified_at"),
                    new TimeZone.utc ())
                  : null
    );
  }

}

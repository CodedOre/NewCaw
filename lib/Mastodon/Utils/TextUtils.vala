/* TextUtils.vala
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
 * Contains methods used to parse text to TextModules.
 */
namespace Backend.Mastodon.Utils.TextUtils {

  /**
   * Parses the text into a list of TextEntities.
   *
   * @param raw_text The text as given by the API.
   *
   * @return A array of TextModules for format_text.
   */
  private TextModule[] parse_text (string raw_text) {
    TextModule[] final_modules = {};

    // Add root node as content can have multiple roots
    string parsed_text = @"<text>$(raw_text)</text>";

    // Create XML tree from text
    Xml.Doc* doc = Xml.Parser.parse_memory (parsed_text, parsed_text.length);
    if (doc == null) {
      error ("Failed to parse text to XML tree!");
    }
    Xml.Node* root = doc->get_root_element ();

    // Mark trailing tags
    Backend.Utils.TextUtils.mark_trailing_tags (final_modules);

    // Free the XML tree
    delete doc;

    return final_modules;
  }

}

/* TestUtils.vala
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

namespace TestUtils {

  /**
   * Loads a file and parses an Json.Object from it.
   *
   * @param file A string to file to be loaded.
   *
   * @return A Json.Object parsed from the file.
   */
  Json.Object? load_json (string file) {
    var parser = new Json.Parser();

    try {
      parser.load_from_file (file);
    } catch (Error e) {
      error (@"Unable to parse '$file': $(e.message)");
    }

    Json.Node root = parser.get_root ();
    return root.get_object ();
  }

}

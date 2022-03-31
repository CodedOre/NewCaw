/* TestUtils.vala
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

namespace TestUtils {

  /**
   * Checks two strings and puts out an error should it not match.
   *
   * A custom method to retrieve more feedback than simply using assert.
   *
   * @param name The name of the value to be checked.
   * @param parsed The value which was parsed and to be checked.
   * @param check The value to check the parsed value against.
   */
  void check_string (string name, string? parsed, string? check) {
    if (parsed != check) {
      string fail;
      fail  = @"The parsed value for $(name) don't match the check value.\n";
      fail += @"\tParsed Value:   \"$(parsed.escape ())\"\n";
      fail += @"\tExpected Value: \"$(check.escape ())\"\n";
      Test.message (fail);
      Test.fail ();
    }
  }

  /**
   * Checks two booleans and puts out an error should it not match.
   *
   * A custom method to retrieve more feedback than simply using assert.
   *
   * @param name The name of the value to be checked.
   * @param parsed The value which was parsed and to be checked.
   * @param check The value to check the parsed value against.
   */
  void check_bool (string name, bool parsed, bool check) {
    if (parsed != check) {
      string fail;
      fail  = @"The parsed value for \"$(name)\" don't match the check value.\n";
      fail += @"\tParsed Value:   \"$(parsed)\"\n";
      fail += @"\tExpected Value: \"$(check)\"\n";
      Test.message (fail);
      Test.fail ();
    }
  }

  /**
   * Checks two integers and puts out an error should it not match.
   *
   * A custom method to retrieve more feedback than simply using assert.
   *
   * @param name The name of the value to be checked.
   * @param parsed The value which was parsed and to be checked.
   * @param check The value to check the parsed value against.
   */
  void check_integer (string name, int parsed, int check) {
    if (parsed != check) {
      string fail;
      fail  = @"The parsed value for \"$(name)\" don't match the check value.\n";
      fail += @"\tParsed Value:   \"$(parsed)\"\n";
      fail += @"\tExpected Value: \"$(check)\"\n";
      Test.message (fail);
      Test.fail ();
    }
  }

  /**
   * Checks a DateTime and puts out an error should it not match.
   *
   * A custom method to retrieve more feedback than simply using assert.
   *
   * @param name The name of the value to be checked.
   * @param parsed The value which was parsed and to be checked.
   * @param check The string representation of the DateTime to check against.
   */
  void check_datetime (string name, DateTime parsed, string check) {
    var check_time = new DateTime.from_iso8601 (
      check, new TimeZone.utc ()
    );
    if (! parsed.equal (check_time)) {
      string fail;
      fail  = @"The parsed value for \"$(name)\" don't match the check value.\n";
      fail += @"\tParsed Value:   \"$(parsed)\"\n";
      fail += @"\tExpected Value: \"$(check)\"\n";
      Test.message (fail);
      Test.fail ();
    }
  }

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

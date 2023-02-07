/* UserParsing.vala
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
 * Tests creation of a specific user and runs test on it.
 */
void run_user_test (string module, string user_json, string check_json) {
  Json.Object  check_object;
  Json.Object  user_object;
  Backend.User checked_user;

  // Creates a User object from the user json
  check_object = TestUtils.load_json (@"UserData/$(module)/$(check_json)");
  user_object  = TestUtils.load_json (@"UserData/$(module)/$(user_json)");
  switch (module) {
#if SUPPORT_MASTODON
    case "Mastodon":
      checked_user = Backend.Mastodon.User.from_json (user_object);
      break;
#endif
    default:
      error ("No valid User could be created!");
  }

  // Check parsed user against check objects.
  UserChecks.check_basic_fields (checked_user, check_object);
  UserChecks.check_additional_fields (checked_user, check_object);
#if DEBUG
  UserChecks.check_description_parsing (checked_user, check_object);
#endif
  UserChecks.check_data_fields (checked_user, check_object);
}

/**
 * Tests parsing of User content.
 */
int main (string[] args) {
  Test.init (ref args);

#if SUPPORT_MASTODON
  Test.add_func ("/UserParsing/BasicUser/Mastodon", () => {
    run_user_test ("Mastodon", "BasicUser.json", "BasicChecks.json");
  });
#endif

  Test.set_nonfatal_assertions ();
  return Test.run ();
}

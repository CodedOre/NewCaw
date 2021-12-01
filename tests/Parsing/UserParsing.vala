/* UserParsing.vala
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
      checked_user = new Backend.Mastodon.User.from_json (user_object);
      break;
#endif
#if SUPPORT_TWITTER
    case "Twitter":
      Json.Object user_data = user_object.get_object_member ("data");
      checked_user = new Backend.Twitter.User.from_json (user_data);
      break;
#endif
#if SUPPORT_TWITTER_LEGACY
    case "TwitterLegacy":
      checked_user = new Backend.TwitterLegacy.User.from_json (user_object);
      break;
#endif
    default:
      error ("No valid User could be created!");
  }

  // Check parsed user against check objects.
  UserChecks.check_basic_fields (checked_user, check_object);
}

/**
 * Tests creation of a specific user as a Profile and runs test on it.
 */
void run_profile_test (string module, string profile_json, string check_json) {
  Json.Object     check_object;
  Json.Object     profile_object;
  Backend.Profile checked_profile;

  // Creates a User object from the user json
  check_object   = TestUtils.load_json (@"UserData/$(module)/$(check_json)");
  profile_object = TestUtils.load_json (@"UserData/$(module)/$(profile_json)");
  switch (module) {
#if SUPPORT_MASTODON
    case "Mastodon":
      checked_profile = new Backend.Mastodon.Profile.from_json (profile_object);
      break;
#endif
#if SUPPORT_TWITTER
    case "Twitter":
      Json.Object profile_data = profile_object.get_object_member ("data");
      checked_profile = new Backend.Twitter.Profile.from_json (profile_data);
      break;
#endif
#if SUPPORT_TWITTER_LEGACY
    case "TwitterLegacy":
      checked_profile = new Backend.TwitterLegacy.Profile.from_json (profile_object);
      break;
#endif
    default:
      error ("No valid Profile could be created!");
  }

  // Check parsed profile against check objects.
  UserChecks.check_basic_fields (checked_profile, check_object);
  UserChecks.check_profile_fields (checked_profile, check_object);
  UserChecks.check_description_parsing (checked_profile, check_object);
  UserChecks.check_data_fields (checked_profile, check_object);
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
  Test.add_func ("/UserParsing/ProfileUser/Mastodon", () => {
    run_profile_test ("Mastodon", "BasicUser.json", "ProfileChecks.json");
  });
#endif
#if SUPPORT_TWITTER
  Test.add_func ("/UserParsing/BasicUser/Twitter", () => {
    run_user_test ("Twitter", "BasicUser.json", "BasicChecks.json");
  });
  Test.add_func ("/UserParsing/ProfileUser/Twitter", () => {
    run_profile_test ("Twitter", "BasicUser.json", "ProfileChecks.json");
  });
#endif
#if SUPPORT_TWITTER_LEGACY
  Test.add_func ("/UserParsing/BasicUser/TwitterLegacy", () => {
    run_user_test ("TwitterLegacy", "BasicUser.json", "BasicChecks.json");
  });
  Test.add_func ("/UserParsing/ProfileUser/TwitterLegacy", () => {
    run_profile_test ("TwitterLegacy", "BasicUser.json", "ProfileChecks.json");
  });
#endif

  return Test.run ();
}

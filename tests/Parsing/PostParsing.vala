/* PostParsing.vala
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
 * Runs different tests on a post.
 */
void run_post_checks (Backend.Post post, Json.Object checks) {
  // Check parsed post against check objects.
  PostChecks.check_basic_fields (post, checks);
#if DEBUG
  PostChecks.check_text_parsing (post, checks);
#endif
  PostChecks.check_text_formatting (post, checks);

  // Check post author against check object
  Json.Object author_checks = checks.get_object_member ("author");
  UserChecks.check_basic_fields (post.author, author_checks);
}

/**
 * Tests creation of a specific post and runs test on it.
 */
void run_post_test (string module, string post_json, string check_json) {
  Json.Object  check_object;
  Json.Object  post_object;
  Backend.Post checked_post;

  // Creates a Post object from the post json
  check_object = TestUtils.load_json (@"PostData/$(module)/$(check_json)");
  post_object  = TestUtils.load_json (@"PostData/$(module)/$(post_json)");
  switch (module) {
#if SUPPORT_MASTODON
    case "Mastodon":
      checked_post = Backend.Mastodon.Post.from_json (post_object);
      break;
#endif
    default:
      error ("No valid Post could be created!");
  }

  // Run the checks for the post
  run_post_checks (checked_post, check_object);

  // FIXME: Tests for referenced posts require an account
}

/**
 * Tests parsing of Post content.
 */
int main (string[] args) {
  Test.init (ref args);

#if SUPPORT_MASTODON
  Test.add_func ("/PostParsing/BasicPost/Mastodon", () => {
    run_post_test ("Mastodon", "BasicPost.json", "BasicChecks.json");
  });
  Test.add_func ("/PostParsing/EntitiesPost/Mastodon", () => {
    run_post_test ("Mastodon", "EntitiesPost.json", "EntitiesChecks.json");
  });
  Test.add_func ("/PostParsing/HashtagsPost/Mastodon", () => {
    run_post_test ("Mastodon", "HashtagsPost.json", "HashtagsChecks.json");
  });
  Test.add_func ("/PostParsing/RepostPost/Mastodon", () => {
    run_post_test ("Mastodon", "RepostPost.json", "RepostChecks.json");
  });
#endif

  Test.set_nonfatal_assertions ();
  return Test.run ();
}

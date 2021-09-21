/* PostParsing.vala
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

/**
 * Test basic fields
 *
 * @param post The Post to be checked.
 * @param check A Json.Object containing fields to check against.
 */
void check_basic_fields (Backend.Post post, Json.Object check) {
  // Check id, date and source
  assert_true (post.id   == check.get_string_member ("id"));
  assert_true (post.date.equal (
    new DateTime.from_iso8601 (
      check.get_string_member ("date"),
      new TimeZone.utc ()
  )));
  assert_true (post.source == check.get_string_member ("source"));

  // Check public metrics
  assert_true (post.liked_count    == check.get_int_member ("liked_count"));
  assert_true (post.replied_count  == check.get_int_member ("replied_count"));
  assert_true (post.reposted_count == check.get_int_member ("reposted_count"));
}

/**
 * Test text and text_modules
 *
 * @param post The Post to be checked.
 * @param check A Json.Object containing fields to check against.
 */
void check_text_parsing (Backend.Post post, Json.Object check) {
  assert_true (post.text == check.get_string_member ("text"));
  Json.Array modules = check.get_array_member ("text_modules");
  Backend.TextModule[] post_modules = post.get_text_modules ();
  assert_true (modules.get_length () == post_modules.length);
  modules.foreach_element ((array, index, element) => {
    Json.Object obj         = element.get_object ();
    Backend.TextModule  mod = post_modules [index];
    assert_true ((int) mod.type == obj.get_int_member        ("type"));
    assert_true (mod.display    == obj.get_string_member     ("display"));
    assert_true (mod.target     == obj.get_string_member     ("target"));
    assert_true (mod.text_start == (uint) obj.get_int_member ("text_start"));
    assert_true (mod.text_end   == (uint) obj.get_int_member ("text_end"));
  });
}

/**
 * Tests creation of a specific post and runs test on it.
 */
void run_post_test (string module, string post_json, string check_json) {
  Json.Object  check_object;
  Json.Object  post_object;
  Backend.Post checked_post;

  // Creates a Post object from the post json
  check_object = load_json (@"PostData/$(module)/$(check_json)");
  post_object  = load_json (@"PostData/$(module)/$(post_json)");
  switch (module) {
#if SUPPORT_MASTODON
    case "Mastodon":
      checked_post = new Backend.Mastodon.Post.from_json (post_object);
      break;
#endif
#if SUPPORT_TWITTER
    case "Twitter":
      checked_post = new Backend.Twitter.Post.from_json (post_object);
      break;
#endif
#if SUPPORT_TWITTER_LEGACY
    case "TwitterLegacy":
      checked_post = new Backend.TwitterLegacy.Post.from_json (post_object);
      break;
#endif
    default:
      error ("No valid Post could be created!");
  }

  // Check parsed post against check objects.
  check_basic_fields (checked_post, check_object);
  check_text_parsing (checked_post, check_object);
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
#endif
#if SUPPORT_TWITTER
  Test.add_func ("/PostParsing/BasicPost/Twitter", () => {
    run_post_test ("Twitter", "BasicPost.json", "BasicChecks.json");
  });
  Test.add_func ("/PostParsing/EntitiesPost/Twitter", () => {
    run_post_test ("Twitter", "EntitiesPost.json", "EntitiesChecks.json");
  });
  Test.add_func ("/PostParsing/HashtagsPost/Twitter", () => {
    run_post_test ("Twitter", "HashtagsPost.json", "HashtagsChecks.json");
  });
#endif
#if SUPPORT_TWITTER_LEGACY
  Test.add_func ("/PostParsing/BasicPost/TwitterLegacy", () => {
    run_post_test ("TwitterLegacy", "BasicPost.json", "BasicChecks.json");
  });
  Test.add_func ("/PostParsing/EntitiesPost/TwitterLegacy", () => {
    run_post_test ("TwitterLegacy", "EntitiesPost.json", "EntitiesChecks.json");
  });
  Test.add_func ("/PostParsing/HashtagsPost/TwitterLegacy", () => {
    run_post_test ("TwitterLegacy", "HashtagsPost.json", "HashtagsChecks.json");
  });
#endif

  return Test.run ();
}

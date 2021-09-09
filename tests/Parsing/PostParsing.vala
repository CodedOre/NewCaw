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
    // Check id and date
    assert_true (post.id   == check.get_string_member ("id"));
    assert_true (post.date.equal (
      new DateTime.from_iso8601 (
        check.get_string_member ("date"),
        new TimeZone.utc ()
    )));

    // Check public metrics
    assert_true (post.liked_count    == check.get_int_member ("liked_count"));
    assert_true (post.replied_count  == check.get_int_member ("replied_count"));
    assert_true (post.reposted_count == check.get_int_member ("reposted_count"));
}

/**
 * Test BasicPost.json
 */
void test_basic_post () {
  Json.Object[]  check_objects = {};
  Backend.Post[] checked_posts = {};

  // Test run the parser and create a Post object.
#if SUPPORT_MASTODON
  check_objects += load_json ("PostData/Mastodon/BasicChecks.json");
  checked_posts += new Backend.Mastodon.Post.from_json (
    load_json ("PostData/Mastodon/BasicPost.json")
  );
#endif
#if SUPPORT_TWITTER
  check_objects += load_json ("PostData/Twitter/BasicChecks.json");
  checked_posts += new Backend.Twitter.Post.from_json (
    load_json ("PostData/Twitter/BasicPost.json")
  );
#endif
#if SUPPORT_TWITTER_LEGACY
  check_objects += load_json ("PostData/TwitterLegacy/BasicChecks.json");
  checked_posts += new Backend.TwitterLegacy.Post.from_json (
    load_json ("PostData/TwitterLegacy/BasicPost.json")
  );
#endif

  // Check if parsed values are equal to check values.
  for (int i = 0; i < check_objects.length; i++) {
    check_basic_fields (checked_posts[i], check_objects[i]);
  }
}

/**
 * Tests parsing of Post content.
 */
int main (string[] args) {
  GLib.Test.init (ref args);

  GLib.Test.add_func ("/PostParsing/BasicPost",    test_basic_post);

  return GLib.Test.run ();
}

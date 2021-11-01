/* MediaParsing.vala
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
 * Runs different tests on a media post.
 */
void run_media_checks (Backend.Post post, Json.Object checks) {
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
 * Tests creation of a specific media post and runs test on it.
 */
void run_media_test (string module, string post_json, string check_json) {
  Json.Object  check_object;
  Json.Object  post_object;
  Backend.Post checked_post;

  // Creates a Post object from the post json
  check_object = TestUtils.load_json (@"MediaData/$(module)/$(check_json)");
  post_object  = TestUtils.load_json (@"MediaData/$(module)/$(post_json)");
  switch (module) {
#if SUPPORT_MASTODON
    case "Mastodon":
      checked_post = new Backend.Mastodon.Post.from_json (post_object);
      break;
#endif
#if SUPPORT_TWITTER
    case "Twitter":
      Json.Object post_data = post_object.get_object_member ("data");
      Json.Object includes  = post_object.get_object_member ("includes");
      checked_post = new Backend.Twitter.Post.from_json (post_data, includes);
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

  // Run the checks for the post
  run_media_checks (checked_post, check_object);

  // Check referenced post if checked_post is repost or quote
  if (check_object.has_member ("referenced_post")) {
    Backend.Post ref_post  = checked_post.referenced_post;
    Json.Object  ref_check = check_object.get_object_member ("referenced_post");
    run_media_checks (ref_post, ref_check);
  }
}

/**
 * Tests parsing of Media post content.
 */
int main (string[] args) {
  Test.init (ref args);

#if SUPPORT_MASTODON
  Test.add_func ("/MediaParsing/OnePicture/Mastodon", () => {
    run_media_test ("Mastodon", "OnePicturePost.json", "OnePictureChecks.json");
  });
  Test.add_func ("/MediaParsing/TwoPicture/Mastodon", () => {
    run_media_test ("Mastodon", "TwoPicturePost.json", "TwoPictureChecks.json");
  });
  Test.add_func ("/MediaParsing/ThreePicture/Mastodon", () => {
    run_media_test ("Mastodon", "ThreePicturePost.json", "ThreePictureChecks.json");
  });
  Test.add_func ("/MediaParsing/FourPicture/Mastodon", () => {
    run_media_test ("Mastodon", "FourPicturePost.json", "FourPictureChecks.json");
  });
#endif
#if SUPPORT_TWITTER
  Test.add_func ("/MediaParsing/OnePicture/Twitter", () => {
    run_media_test ("Twitter", "OnePicturePost.json", "OnePictureChecks.json");
  });
  Test.add_func ("/MediaParsing/TwoPicture/Twitter", () => {
    run_media_test ("Twitter", "TwoPicturePost.json", "TwoPictureChecks.json");
  });
  Test.add_func ("/MediaParsing/ThreePicture/Twitter", () => {
    run_media_test ("Twitter", "ThreePicturePost.json", "ThreePictureChecks.json");
  });
  Test.add_func ("/MediaParsing/FourPicture/Twitter", () => {
    run_media_test ("Twitter", "FourPicturePost.json", "FourPictureChecks.json");
  });
#endif
#if SUPPORT_TWITTER_LEGACY
  Test.add_func ("/MediaParsing/OnePicture/TwitterLegacy", () => {
    run_media_test ("TwitterLegacy", "OnePicturePost.json", "OnePictureChecks.json");
  });
  Test.add_func ("/MediaParsing/TwoPicture/TwitterLegacy", () => {
    run_media_test ("TwitterLegacy", "TwoPicturePost.json", "TwoPictureChecks.json");
  });
  Test.add_func ("/MediaParsing/ThreePicture/TwitterLegacy", () => {
    run_media_test ("TwitterLegacy", "ThreePicturePost.json", "ThreePictureChecks.json");
  });
  Test.add_func ("/MediaParsing/FourPicture/TwitterLegacy", () => {
    run_media_test ("TwitterLegacy", "FourPicturePost.json", "FourPictureChecks.json");
  });
#endif

  return Test.run ();
}

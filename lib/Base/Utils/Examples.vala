/* Examples.vala
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
 * An non-interactive example post.
 *
 * Can be used by applications to provide an example for the settings page.
 * As this post has no session connected, it is advised to prevent
 * interaction with the displayed post.
 */
public class Backend.Utils.ExamplePost : Backend.Post {

  /**
   * Creates an example post.
   */
  public ExamplePost () {
    Object (
      // Set no session
      session: null,

      // Set basic data
      id:     "demo-post",
      source: "Example Application",
      creation_date: new DateTime.from_iso8601 (
                       "2022-09-12T14:34:43.744Z",
                       new TimeZone.utc ()
                     ),

      // Set PostType
      post_type: PostType.NORMAL,

      // Set the visibility of the post
      sensitive: PostSensitivity.NONE,
      spoiler:   null,

      // Set the referenced post
      referenced_post: null,

      // Set url and domain
      url:    "https://mastodon.social/@cawbird_test_account/108985927843021989",
      domain: "mastodon.social",

      // Set metrics
      liked_count:    8,
      replied_count:  2,
      reposted_count: 4,

      // Set the author
      author: new ExampleUser (),

      // Set replied_to_id
      replied_to_id: null,

      is_favourited: false,
      is_reposted: false
    );

    attached_media = {};

    // Create the modules for the text
    TextModule[] example_mods = {};
    {
      var mod = TextModule ();
      mod.type       = TEXT;
      mod.display    = "Hello, you can check in realtime how your ";
      mod.target     = null;
      mod.text_start = 0;
      mod.text_end   = 42;
      example_mods += mod;
    }
    {
      var mod = TextModule ();
      mod.type       = TAG;
      mod.display    = "#preferences";
      mod.target     = "#preferences";
      mod.text_start = 42;
      mod.text_end   = 54;
      example_mods += mod;
    }
    {
      var mod = TextModule ();
      mod.type       = TEXT;
      mod.display    = " affect this post.";
      mod.target     = null;
      mod.text_start = 54;
      mod.text_end   = 72;
      example_mods += mod;
    }
    {
      var mod = TextModule ();
      mod.type       = TEXT;
      mod.display    = "\n\n";
      mod.target     = null;
      mod.text_start = 72;
      mod.text_end   = 74;
      example_mods += mod;
    }
    {
      var mod = TextModule ();
      mod.type       = TRAIL_TAG;
      mod.display    = "#cool";
      mod.target     = "#cool";
      mod.text_start = 74;
      mod.text_end   = 79;
      example_mods += mod;
    }
    {
      var mod = TextModule ();
      mod.type       = TEXT;
      mod.display    = " ";
      mod.target     = null;
      mod.text_start = 79;
      mod.text_end   = 80;
      example_mods += mod;
    }
    {
      var mod = TextModule ();
      mod.type       = TRAIL_TAG;
      mod.display    = "#cawbirdtwopointone";
      mod.target     = "#cawbirdtwopointone";
      mod.text_start = 80;
      mod.text_end   = 99;
      example_mods += mod;
    }
    {
      var mod = TextModule ();
      mod.type       = TEXT;
      mod.display    = " ";
      mod.target     = null;
      mod.text_start = 99;
      mod.text_end   = 100;
      example_mods += mod;
    }
    {
      var mod = TextModule ();
      mod.type       = TRAIL_TAG;
      mod.display    = "#newisalwaysbetter";
      mod.target     = "#newisalwaysbetter";
      mod.text_start = 100;
      mod.text_end   = 118;
      example_mods += mod;
    }
    text_modules = example_mods;

    // Format the text
    text = Backend.Utils.TextUtils.format_text (example_mods);
  }

}

/**
 * An non-interactive example user.
 *
 * Can be used by applications to provide an example for the settings page.
 * As this user has no session connected, it is advised to prevent
 * interaction with the displayed user.
 */
public class Backend.Utils.ExampleUser : Backend.User {

  /**
   * Creates an example user.
   */
  public ExampleUser () {
    Object (
      // Set the id of the user
      id: "demo-user",

      // Set the creation date for the user
      creation_date: new DateTime.from_iso8601 (
                       "2021-09-03T00:00:00.000Z",
                       new TimeZone.utc ()
                     ),

      // Set the names of the user
      display_name: "CawbirdTestAccount",
      username:     "cawbird_test_account@mastodon.social",

      // Set the url and domain
      url:    "https://mastodon.social/@cawbird_test_account",
      domain: "mastodon.social",

      // Parses the data fields
      data_fields: null,

      // Set metrics
      followers_count: 2,
      following_count: 4,
      posts_count:     8,

      // Set the images
#if SUPPORT_MASTODON
      avatar: Mastodon.Media.from_url (PICTURE, "https://files.mastodon.social/accounts/avatars/106/866/867/257/179/166/original/6bf23bd3fb731624.png"),
      header: Mastodon.Media.from_url (PICTURE, "https://files.mastodon.social/accounts/headers/106/866/867/257/179/166/original/1b43374005561eec.jpeg")
#else
      avatar: null,
      header: null
#endif
    );

  }

}

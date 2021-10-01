/* PostChecks.vala
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

namespace PostChecks {

  /**
   * Test basic fields
   *
   * @param post The Post to be checked.
   * @param check A Json.Object containing fields to check against.
   */
  void check_basic_fields (Backend.Post post, Json.Object check) {
    // Check id, date and source
    assert_true (post.id == check.get_string_member ("id"));
    assert_true (post.post_type.to_string () == check.get_string_member ("post_type"));
    assert_true (post.date.equal (
      new DateTime.from_iso8601 (
        check.get_string_member ("date"),
        new TimeZone.utc ()
    )));
    assert_true (post.url    == check.get_string_member ("url"));
    assert_true (post.domain == check.get_string_member ("domain"));
    assert_true (post.source == check.get_string_member ("source"));

    // Check public metrics
    assert_true (post.liked_count    == check.get_int_member ("liked_count"));
    assert_true (post.replied_count  == check.get_int_member ("replied_count"));
    assert_true (post.reposted_count == check.get_int_member ("reposted_count"));
  }

  #if DEBUG
  /**
   * Test text_modules
   *
   * @param post The Post to be checked.
   * @param check A Json.Object containing fields to check against.
   */
  void check_text_parsing (Backend.Post post, Json.Object check) {
    Json.Array modules = check.get_array_member ("text_modules");
    Backend.TextModule[] post_modules = post.get_text_modules ();
    assert_true (modules.get_length () == post_modules.length);

    modules.foreach_element ((array, index, element) => {
      Json.Object obj         = element.get_object ();
      Backend.TextModule  mod = post_modules [index];
      assert_true (mod.type.to_string () == obj.get_string_member     ("type"));
      assert_true (mod.display           == obj.get_string_member     ("display"));
      assert_true (mod.target            == obj.get_string_member     ("target"));
      assert_true (mod.text_start        == (uint) obj.get_int_member ("text_start"));
      assert_true (mod.text_end          == (uint) obj.get_int_member ("text_end"));
    });
  }
  #endif

  /**
   * Test text using different formatting settings.
   *
   * @param post The Post to be checked.
   * @param check A Json.Object containing fields to check against.
   */
  void check_text_formatting (Backend.Post post, Json.Object check) {
    Json.Object text_obj = check.get_object_member ("text");

    // Check without format flags
    Backend.TextUtils.set_format_flag (HIDE_TRAILING_TAGS, false);
    assert_true (post.text == text_obj.get_string_member ("no_flags"));

    // Check with no trailing tags set
    Backend.TextUtils.set_format_flag (HIDE_TRAILING_TAGS, true);
    assert_true (post.text == text_obj.get_string_member ("no_trail_tags"));
  }

}

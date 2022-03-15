/* UserChecks.vala
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
 * Checks for testing a parsed User.
 */
namespace UserChecks {

  /**
   * Checks the basic information for this user.
   *
   * @param user The User to be checked.
   * @param check A Json.Object containing fields to check against.
   */
  void check_basic_fields (Backend.User user, Json.Object check) {
    // Check id from the user
    assert_true (user.id           == check.get_string_member ("id"));

    // Check names of this user
    assert_true (user.display_name == check.get_string_member ("display_name"));
    assert_true (user.username     == check.get_string_member ("username"));

    // Check the avatar url for this user
    assert_true (user.avatar.media_url == check.get_string_member ("avatar_url"));

    // Check the flags for this user
    if (check.has_member ("flags")) {
      Json.Object flags = check.get_object_member ("flags");
      assert_true (user.has_flag (VERIFIED)  == flags.get_boolean_member ("verified"));
      assert_true (user.has_flag (MODERATED) == flags.get_boolean_member ("moderated"));
      assert_true (user.has_flag (PROTECTED) == flags.get_boolean_member ("protected"));
      assert_true (user.has_flag (BOT)       == flags.get_boolean_member ("bot"));
    }
  }

  /**
   * Checks additional information a User contains.
   *
   * @param user The User to be checked.
   * @param check A Json.Object containing fields to check against.
   */
  void check_additional_fields (Backend.User user, Json.Object check) {
    // Check creation date and urls
    assert_true (user.creation_date.equal (
      new DateTime.from_iso8601 (
        check.get_string_member ("creation_date"),
        new TimeZone.utc ()
    )));
    assert_true (user.url    == check.get_string_member ("url"));
    assert_true (user.domain == check.get_string_member ("domain"));

    // Check public metrics
    assert_true (user.followers_count == check.get_int_member ("followers_count"));
    assert_true (user.following_count == check.get_int_member ("following_count"));
    assert_true (user.posts_count     == check.get_int_member ("posts_count"));

    // Check description without format flags
    Backend.Utils.TextFormats.set_format_flag (HIDE_TRAILING_TAGS, false);
    Backend.Utils.TextFormats.set_format_flag (SHOW_QUOTE_LINKS,   false);
    Backend.Utils.TextFormats.set_format_flag (SHOW_MEDIA_LINKS,   false);
    assert_true (user.description == check.get_string_member ("description"));
  }

#if DEBUG
  /**
   * Test text_modules
   *
   * @param user The User to be checked.
   * @param check A Json.Object containing fields to check against.
   */
  void check_description_parsing (Backend.User user, Json.Object check) {
    Json.Array modules = check.get_array_member ("description_modules");
    Backend.TextModule[] user_modules = user.get_description_modules ();
    assert_true (modules.get_length () == user_modules.length);

    modules.foreach_element ((array, index, element) => {
      Json.Object obj         = element.get_object ();
      Backend.TextModule  mod = user_modules [index];
      assert_true (mod.type.to_string () == obj.get_string_member     ("type"));
      assert_true (mod.display           == obj.get_string_member     ("display"));
      assert_true (mod.target            == obj.get_string_member     ("target"));
      assert_true (mod.text_start        == (uint) obj.get_int_member ("text_start"));
      assert_true (mod.text_end          == (uint) obj.get_int_member ("text_end"));
    });
  }
#endif

  /**
   * Test the data fields
   *
   * @param user The User to be checked.
   * @param check A Json.Object containing fields to check against.
   */
  void check_data_fields (Backend.User user, Json.Object check) {
    Json.Array check_fields = check.get_array_member ("data_fields");
    Backend.UserDataField[] user_fields = user.get_data_fields ();
    assert_true (check_fields.get_length () == user_fields.length);

    check_fields.foreach_element ((array, index, element) => {
      Json.Object obj             = element.get_object ();
      Backend.UserDataField field = user_fields [index];
      assert_true (field.type.to_string () == obj.get_string_member     ("type"));
      assert_true (field.name              == obj.get_string_member     ("name"));
      assert_true (field.display           == obj.get_string_member     ("display"));
      assert_true (field.target            == obj.get_string_member     ("target"));
    });
  }

}

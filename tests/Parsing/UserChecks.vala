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
    TestUtils.check_string ("User ID", user.id, check.get_string_member ("id"));

    // Check names of this user
    TestUtils.check_string ("User Display Name", user.display_name, check.get_string_member ("display_name"));
    TestUtils.check_string ("User Username", user.username, check.get_string_member ("username"));

    // Check the user media
    TestUtils.check_string ("User Avatar URL", user.avatar.media_url, check.get_string_member ("avatar_url"));
    if (check.has_member ("header_url")) {
      TestUtils.check_string ("User Header URL", user.header.media_url, check.get_string_member ("header_url"));
    }

    // Check the flags for this user
    if (check.has_member ("flags")) {
      Json.Object flags = check.get_object_member ("flags");
      TestUtils.check_bool ("User Verified Flag", user.has_flag (VERIFIED), flags.get_boolean_member ("verified"));
      TestUtils.check_bool ("User Moderated Flag", user.has_flag (MODERATED), flags.get_boolean_member ("moderated"));
      TestUtils.check_bool ("User Protected Flag", user.has_flag (PROTECTED), flags.get_boolean_member ("protected"));
      TestUtils.check_bool ("User Bot Flag", user.has_flag (BOT), flags.get_boolean_member ("bot"));
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
    TestUtils.check_datetime ("User Creation Date", user.creation_date, check.get_string_member ("creation_date"));
    TestUtils.check_string ("User URL", user.url, check.get_string_member ("url"));
    TestUtils.check_string ("User Domain", user.domain, check.get_string_member ("domain"));

    // Check public metrics
    TestUtils.check_integer ("User Followers", user.followers_count, (int) check.get_int_member ("followers_count"));
    TestUtils.check_integer ("User Following", user.following_count, (int) check.get_int_member ("following_count"));
    TestUtils.check_integer ("User Posts", user.posts_count, (int) check.get_int_member ("posts_count"));

    // Check description without format flags
    Backend.Utils.TextFormats.set_format_flag (HIDE_TRAILING_TAGS, false);
    Backend.Utils.TextFormats.set_format_flag (SHOW_QUOTE_LINKS,   false);
    Backend.Utils.TextFormats.set_format_flag (SHOW_MEDIA_LINKS,   false);
    TestUtils.check_string ("User Description", user.description, check.get_string_member ("description"));
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
    TestUtils.check_integer ("All TextModules Count", user_modules.length, (int) modules.get_length ());

    if (user_modules.length == modules.get_length ()) {
      modules.foreach_element ((array, index, element) => {
        Json.Object obj         = element.get_object ();
        Backend.TextModule  mod = user_modules [index];
        TestUtils.check_string ("TextModule Type", mod.type.to_string (), obj.get_string_member ("type"));
        TestUtils.check_string ("TextModule Display", mod.display, obj.get_string_member ("display"));
        TestUtils.check_string ("TextModule Target", mod.target, obj.get_string_member ("target"));
        TestUtils.check_integer ("TextModule Start Position", (int) mod.text_start, (int) obj.get_int_member ("text_start"));
        TestUtils.check_integer ("TextModule End Position", (int) mod.text_end, (int) obj.get_int_member ("text_end"));
      });
    }
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
    TestUtils.check_integer ("All UserDataFields Count", user_fields.length, (int) check_fields.get_length ());

    if (user_fields.length == check_fields.get_length ()) {
      check_fields.foreach_element ((array, index, element) => {
        Json.Object obj             = element.get_object ();
        Backend.UserDataField field = user_fields [index];
        TestUtils.check_string ("DataField Type", field.type.to_string (), obj.get_string_member ("type"));
        TestUtils.check_string ("DataField Name", field.name, obj.get_string_member ("name"));
        TestUtils.check_string ("DataField Display", field.display, obj.get_string_member ("display"));
        TestUtils.check_string ("DataField Target", field.target, obj.get_string_member ("target"));
      });
    }
  }

}

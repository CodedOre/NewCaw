/* UserChecks.vala
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
 * Checks for testing a parsed User.
 */
namespace UserChecks {

  /**
   * Checks the basic information for this user.
   */
  void check_basic_fields (Backend.User user, Json.Object check) {
    // Check id from the user
    assert_true (user.id           == check.get_string_member ("id"));

    // Check names of this user
    assert_true (user.display_name == check.get_string_member ("display_name"));
    assert_true (user.username     == check.get_string_member ("username"));

    // Check the avatar url for this user
    assert_true (user.avatar.url == check.get_string_member ("avatar_url"));
  }

}

/* MediaChecks.vala
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
 * Checks for testing a parsed Media object.
 */
namespace MediaChecks {

  /**
   * Tests all media in a post.
   *
   * @param post The Post to be checked.
   * @param check A Json.Object containing fields to check against.
   */
  void check_all_media (Backend.Post post, Json.Object checks) {
    // Get all media and media checks
    Json.Array      media_checks = checks.get_array_member ("attached_media");
    Backend.Media[] media_objs   = post.get_media ();
    TestUtils.check_integer ("All Media Count", media_objs.length, (int) media_checks.get_length ());

    // Check each individual media
    media_checks.foreach_element ((array, index, element) => {
      Json.Object   med_check = element.get_object ();
      Backend.Media media     = media_objs [index];

      // Run basic data checks
      check_basic_fields (media, med_check);
    });
  }

  /**
   * Tests basic fields
   *
   * @param media The Media to be checked.
   * @param check A Json.Object containing fields to check against.
   */
  void check_basic_fields (Backend.Media media, Json.Object check) {
    // Check id, type and alt_text
    TestUtils.check_string ("Media ID", media.id, check.get_string_member ("id"));
    TestUtils.check_string ("Media Type", media.media_type.to_string (), check.get_string_member ("type"));
    TestUtils.check_string ("Media Alt Text", media.alt_text, check.get_string_member ("alt_text"));

    // Check urls
    TestUtils.check_string ("Media Preview URL", media.preview_url, check.get_string_member ("preview_url"));
    TestUtils.check_string ("Media URL", media.media_url, check.get_string_member ("media_url"));
  }

}

/* MediaChecks.vala
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
 * Checks for testing a parsed Media object.
 */
// TODO: Maybe add an downloader test to see if downloading works properly...
namespace MediaChecks {

  /**
   * Test basic fields
   *
   * @param post The Post to be checked.
   * @param check A Json.Object containing fields to check against.
   */
  void check_basic_fields (Backend.Media media, Json.Object check) {
    // Check id and alt_text
    assert_true (media.id       == check.get_string_member ("id"));
    assert_true (media.alt_text == check.get_string_member ("alt_text"));

    // Check the type of this media
    switch (check.get_string_member ("type")) {
      case "BACKEND_MEDIA_TYPE_PICTURE":
        assert_true (media is Backend.Picture);
        break;
    }

    // Check media dimensions
    int media_width, media_height;
    media.get_dimensions (out media_width, out media_height);
    assert_true (media_width  == check.get_int_member ("width"));
    assert_true (media_height == check.get_int_member ("height"));

    // Check preview and media url
    assert_true (media.preview_url == check.get_string_member ("preview_url"));
    assert_true (media.media_url   == check.get_string_member ("media_url"));
  }

}

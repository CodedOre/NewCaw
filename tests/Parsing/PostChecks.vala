/* PostChecks.vala
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
 * Checks for testing a parsed Post.
 */
namespace PostChecks {

  /**
   * Test basic fields
   *
   * @param post The Post to be checked.
   * @param check A Json.Object containing fields to check against.
   */
  void check_basic_fields (Backend.Post post, Json.Object check) {
    // Check id, date and source
    TestUtils.check_string ("Post ID", post.id, check.get_string_member ("id"));
    TestUtils.check_string ("Post Type", post.post_type.to_string (), check.get_string_member ("post_type"));
    TestUtils.check_datetime ("Post Creation Date", post.creation_date, check.get_string_member ("creation_date"));
    TestUtils.check_string ("Post URL", post.url, check.get_string_member ("url"));
    TestUtils.check_string ("Post Domain", post.domain, check.get_string_member ("domain"));
    TestUtils.check_string ("Post Source", post.source, check.get_string_member ("source"));

    // Check public metrics
    TestUtils.check_integer ("Post Likes", post.liked_count, (int) check.get_int_member ("liked_count"));
    TestUtils.check_integer ("Post Replies", post.replied_count, (int) check.get_int_member ("replied_count"));
    TestUtils.check_integer ("Post Reposts", post.reposted_count, (int) check.get_int_member ("reposted_count"));
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
    TestUtils.check_integer ("All TextModules Count", post_modules.length, (int) modules.get_length ());

    modules.foreach_element ((array, index, element) => {
      Json.Object obj         = element.get_object ();
      Backend.TextModule  mod = post_modules [index];
      TestUtils.check_string ("TextModule Type", mod.type.to_string (), obj.get_string_member ("type"));
      TestUtils.check_string ("TextModule Display", mod.display, obj.get_string_member ("display"));
      TestUtils.check_string ("TextModule Target", mod.target, obj.get_string_member ("target"));
      TestUtils.check_integer ("TextModule Start Position", (int) mod.text_start, (int) obj.get_int_member ("text_start"));
      TestUtils.check_integer ("TextModule End Position", (int) mod.text_end, (int) obj.get_int_member ("text_end"));
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
    Backend.Utils.TextFormats.set_format_flag (HIDE_TRAILING_TAGS, false);
    Backend.Utils.TextFormats.set_format_flag (SHOW_QUOTE_LINKS,   false);
    Backend.Utils.TextFormats.set_format_flag (SHOW_MEDIA_LINKS,   false);
    TestUtils.check_string ("Post Text", post.text, text_obj.get_string_member ("no_flags"));

    // Check with no trailing tags set
    if (text_obj.has_member ("no_trail_tags")) {
      Backend.Utils.TextFormats.set_format_flag (HIDE_TRAILING_TAGS, true);
      Backend.Utils.TextFormats.set_format_flag (SHOW_QUOTE_LINKS,   false);
      Backend.Utils.TextFormats.set_format_flag (SHOW_MEDIA_LINKS,   false);
      TestUtils.check_string ("Post Text No Trail Hashtags", post.text, text_obj.get_string_member ("no_trail_tags"));
    }

    if (text_obj.has_member ("shown_quote_links")) {
      // Check with displayed quote links
      Backend.Utils.TextFormats.set_format_flag (HIDE_TRAILING_TAGS, false);
      Backend.Utils.TextFormats.set_format_flag (SHOW_QUOTE_LINKS,   true);
      Backend.Utils.TextFormats.set_format_flag (SHOW_MEDIA_LINKS,   false);
      TestUtils.check_string ("Post Text With Quote Links", post.text, text_obj.get_string_member ("shown_quote_links"));
    }

    if (text_obj.has_member ("shown_media_links")) {
      // Check with displayed quote links
      Backend.Utils.TextFormats.set_format_flag (HIDE_TRAILING_TAGS, false);
      Backend.Utils.TextFormats.set_format_flag (SHOW_QUOTE_LINKS,   false);
      Backend.Utils.TextFormats.set_format_flag (SHOW_MEDIA_LINKS,   true);
      TestUtils.check_string ("Post Text With Media Links", post.text, text_obj.get_string_member ("shown_media_links"));
    }
  }

}

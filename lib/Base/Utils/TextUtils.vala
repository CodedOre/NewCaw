/* TextUtils.vala
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
 * Provides utilities for parsing and formatting text.
 */
namespace Backend.TextUtils {

  /**
   * Various settings for text formatting.
   */
  [Flags]
  public enum FormatFlag {
    /**
     * Hide hashtags after the text.
     */
    HIDE_TRAILING_TAGS,
    /**
     * Display links leading to quotes.
     */
    SHOW_QUOTE_LINKS
  }

  /**
   * Formats a text from a set of TextModules.
   *
   * @param text_modules An array of all modules of the text.
   *
   * @return A formatted string for display in a Pango capable text field.
   */
  private string format_text (TextModule[] text_modules) {
    var builder = new StringBuilder ();

    // Iterates through all TextModules
    foreach (TextModule module in text_modules) {
      switch (module.type) {
        case TRAIL_TAG:
          if (get_format_flag (HIDE_TRAILING_TAGS)) {
            break;
          }
          // FIXME: valac complains that it needs the break after, but maybe we could avoid this copied line...
          builder.append (@"<a href=\"$(module.target)\" title=\"$(module.target)\" class=\"hashtag\">$(module.display)</a>");
          break;
        case TAG:
          builder.append (@"<a href=\"$(module.target)\" title=\"$(module.target)\" class=\"hashtag\">$(module.display)</a>");
          break;
        case MENTION:
          builder.append (@"<a href=\"$(module.target)\" title=\"$(module.target)\" class=\"mention\">$(module.display)</a>");
          break;
        case QUOTELINK:
          if (! get_format_flag (SHOW_QUOTE_LINKS)) {
            break;
          }
          builder.append (@"<a href=\"$(module.target)\" title=\"$(module.target)\" class=\"weblink\">$(module.display)</a>");
          break;
        case WEBLINK:
          builder.append (@"<a href=\"$(module.target)\" title=\"$(module.target)\" class=\"weblink\">$(module.display)</a>");
          break;
        default:
          builder.append (module.display);
          break;
      }
    }

    // Returns the text to be used in the UI
    return builder.str.chomp ();
  }

  /**
   * Set trailing tags to the right type, allowing them to be hidden with format_text.
   *
   * @param text_modules An array of all modules of the text.
   */
  private void mark_trailing_tags (TextModule[] modules) {
    bool   search_trail_tags = true;
    bool   mark_trail_tags   = false;
    size_t module_index      = modules.length - 1;

    while (search_trail_tags) {
      TextModule mod = modules [module_index];
      switch (mod.type) {
        case TAG:
          mark_trail_tags = true;
          break;
        case TEXT:
          for (int i = 0; i < mod.display.length; i++) {
            if (! mod.display [i].isspace ()) {
              search_trail_tags = false;
              break;
            }
          }
          break;
        default:
          search_trail_tags = false;
          break;
      }
      if (module_index == 0) {
        search_trail_tags = false;
      }
      module_index--;
    }

    while (mark_trail_tags) {
      module_index++;
      if (module_index == modules.length) {
        break;
      }
      if (modules [module_index].type == TAG) {
        modules [module_index].type = TRAIL_TAG;
      }
    }
  }

  /**
   * Checks if a certain flag for text formatting is set.
   *
   * @param flag The flag to be checked.
   *
   * @return A boolean if the flag is set.
   */
  public bool get_format_flag (FormatFlag flag) {
    return flag in format_flags;
  }

  /**
   * Sets a flag for text formatting to a certain value.
   *
   * @param flag The flag to be set.
   * @param setting If the flag should be enabled or not.
   */
  public void set_format_flag (FormatFlag flag, bool setting) {
    if (setting) {
      format_flags = format_flags | flag;
    } else {
      format_flags = format_flags & ~flag;
    }
  }

  /**
   * Settings for the formatting of text.
   */
  private FormatFlag format_flags = 0;

}

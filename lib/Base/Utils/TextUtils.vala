/* TextUtils.vala
 *
 * Copyright 2021-2023 Frederick Schenk
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
 * Contains methods used to format text with TextModules.
 */
namespace Backend.Utils.TextUtils {

  /**
   * Formats a text from a set of TextModules.
   *
   * @param text_modules An array of all modules of the text.
   * @param use_formats If to use the display settings of TextFormats.
   *
   * @return A formatted string for display in a Pango capable text field.
   */
  private string format_text (TextModule[] text_modules, bool use_formats = true) {
    var builder = new StringBuilder ();

    // Iterates through all TextModules
    foreach (TextModule module in text_modules) {
      // Escape the text not intended to be Pango markup
      string target  = module.target != null ? Markup.escape_text (module.target) : "";
      string tooltip = Markup.escape_text (target);
      string display = Markup.escape_text (module.display);

      // Set up the module settings
      bool   show_module = true;
      bool   link_module = true;
      string module_class;
      switch (module.type) {
        case TRAIL_TAG:
          show_module = ! use_formats || ! Backend.Utils.TextFormats.get_format_flag (HIDE_TRAILING_TAGS);
          module_class = "hashtag";
          break;

        case TAG:
          module_class = "hashtag";
          break;

        case MENTION:
          module_class = "mention";
          break;

        case WEBLINK:
          module_class = "weblink";
          break;

        default:
          link_module  = false;
          module_class = "text";
          break;
      }

      // Append the module
      if (show_module) {
        if (link_module) {
          builder.append (@"<a href=\"$(module_class)|$(target)\" title=\"$(tooltip)\" class=\"$(module_class)\">$(display)</a>");
        } else {
          builder.append (display);
        }
      }
    }

    // Returns the text to be used in the UI
    return builder.str.chomp ();
  }

  /**
   * Set trailing tags to the right type, allowing them to be hidden with format_text.
   *
   * @param modules An array of all modules of the text.
   */
  private void mark_trailing_tags (TextModule[] modules) {
    bool   search_trail_tags = modules.length > 0 ? true : false;
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

}

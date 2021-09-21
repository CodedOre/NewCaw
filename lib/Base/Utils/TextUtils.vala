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

/**
 * Provides utilities for parsing and formatting text.
 */
namespace Backend.TextUtils {

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
        case TAG:
          builder.append (@"<a href=\"$(module.target)\" title=\"$(module.target)\" class=\"hashtag\">$(module.display)</a>");
          break;
        case MENTION:
          builder.append (@"<a href=\"$(module.target)\" title=\"$(module.target)\" class=\"mention\">$(module.display)</a>");
          break;
        case LINK:
          builder.append (@"<a href=\"$(module.target)\" title=\"$(module.target)\" class=\"weblink\">$(module.display)</a>");
          break;
        default:
          builder.append (module.display);
          break;
      }
    }

    // Returns the text to be used in the UI
    return builder.str;
  }

}

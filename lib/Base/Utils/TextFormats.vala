/* TextFormats.vala
 *
 * Copyright 2022 CodedOre <47981497+CodedOre@users.noreply.github.com>
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
 * Various settings for text formatting.
 */
[Flags]
public enum Backend.Utils.FormatFlag {

  /**
   * Hide hashtags after the text.
   */
  HIDE_TRAILING_TAGS,

  /**
   * Display links leading to quotes.
   */
  SHOW_QUOTE_LINKS,

  /**
   * Display links leading to media.
   */
  SHOW_MEDIA_LINKS

}

/**
 * Allows to set text formatting.
 *
 * This singleton provides access to methods to set
 * the flags that determine the formatting of
 * text from Post and description from Profile.
 */
public class Backend.Utils.TextFormats : Object {

  /**
   * Signals a changed format setting.
   *
   * Used by Post and Profile to regenerate their text properties.
   */
  internal signal void update_formatting ();

  /**
   * The global instance of TextFormats.
   */
  internal static TextFormats instance {
    get {
      if (global_instance == null) {
        global_instance = new TextFormats ();
      }
      return global_instance;
    }
  }

  /**
   * Checks if a certain flag for text formatting is set.
   *
   * @param flag The flag to be checked.
   *
   * @return A boolean if the flag is set.
   */
  public static bool get_format_flag (FormatFlag flag) {
    return instance.get_instance_flag (flag);
  }

  /**
   * Sets a flag for text formatting to a certain value.
   *
   * @param flag The flag to be set.
   * @param setting If the flag should be enabled or not.
   */
  public static void set_format_flag (FormatFlag flag, bool setting) {
    instance.set_instance_flag (flag, setting);
  }

  /**
   * Checks if a certain flag for text formatting is set.
   *
   * Internal function called from the static method get_format_flag.
   *
   * @param flag The flag to be checked.
   *
   * @return A boolean if the flag is set.
   */
  private bool get_instance_flag (FormatFlag flag) {
    return flag in format_flags;
  }

  /**
   * Sets a flag for text formatting to a certain value.
   *
   * Internal function called from the static method set_format_flag.
   *
   * @param flag The flag to be set.
   * @param setting If the flag should be enabled or not.
   */
  private void set_instance_flag (FormatFlag flag, bool setting) {
    // Return if setting wouldn't change
    if (setting == get_instance_flag (flag)) {
      return;
    }

    // Apply the flag
    if (setting) {
      format_flags = format_flags | flag;
    } else {
      format_flags = format_flags & ~flag;
    }

    // Signalize the update
    update_formatting ();
  }

  /**
   * Stores the global instance of TextFormats.
   *
   * Only access over the instance property!
   */
  private static TextFormats? global_instance = null;

  /**
   * Settings for the formatting of text.
   */
  private FormatFlag format_flags = 0;

}

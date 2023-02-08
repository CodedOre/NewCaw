/* UserDataField.vala
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
 * A field storing specific information about a User.
 */
public class Backend.UserDataField : Object {

  /**
   * A description for this field.
   */
  public string name { get; construct; }

  /**
   * The value of the data in this field.
   */
  public string content { get; private set; }

  /**
   * Creates a new object containing data.
   */
  internal UserDataField (string name, TextModule[] text_modules) {
    // Construct object
    Object (
      name: name
    );

    // Parse text modules to text
    content = Backend.Utils.TextUtils.format_text (text_modules, false);
  }

}

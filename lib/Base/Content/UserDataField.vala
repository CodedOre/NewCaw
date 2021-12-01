/* UserDataField.vala
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
 * Specific types for an UserDataField.
 */
public enum Backend.UserDataFieldType {

  /**
   * A generic type with non-specific data.
   */
  GENERIC,

  /**
   * A location from where this User comes.
   */
  LOCATION,

  /**
   * A url to a website this user has set.
   */
  WEBLINK

}

/**
 * A field storing specific information about a User.
 */
public struct Backend.UserDataField {

  /**
   * The type of data stored in this field.
   */
  public UserDataFieldType type;

  /**
   * The name for this field.
   */
  public string name;

  /**
   * The value this field is assigned.
   */
  public string value;

}

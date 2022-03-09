/* User.vala
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
 * Stores information about one user of a platform.
 */
public abstract class Backend.User : Object {

  /**
   * The identifier of the user in the API.
   */
  public string id { get; protected set; }

  /**
   * The "name" of the user.
   */
  public string display_name { get; protected set; }

  /**
   * The unique handle of this user.
   */
  public string username { get; protected set; }

  /**
   * The avatar image from this user.
   */
  public Media avatar { get; protected set; }

  /**
   * Checks if the User has a certain flag set.
   */
  public bool has_flag (UserFlag flag) {
    return flag in flags;
  }

  /**
   * Stores the flags for this user.
   */
  protected UserFlag flags;

}

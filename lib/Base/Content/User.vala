/* User.vala
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
 * Stores information about one user of a platform.
 */
public interface Backend.User : Object {

  /**
   * The identifier of the user in the API.
   */
  public abstract string id { get; construct; }

  /**
   * The "name" of the user.
   */
  public abstract string display_name { get; construct; }

  /**
   * The unique handle of this user.
   */
  public abstract string username { get; construct; }

  /**
   * The avatar image from this user.
   */
  public abstract ImageLoader avatar { get; construct; }

  /**
   * Checks if the User has a certain flag set.
   */
  public abstract bool has_flag (UserFlag flag);

}

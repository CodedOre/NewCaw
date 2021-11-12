/* UserEnums.vala
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
 * Flags defining some properties of a User.
 */
[Flags]
public enum Backend.UserFlag {
  /**
   * Sets if the User moderates it’s followers.
   */
  MODERATED,
  /**
   * Sets if the User don't allow public access to his timeline.
   */
  PROTECTED,
  /**
   * Sets if the User is verified by the platform.
   */
  VERIFIED,
  /**
   * Sets if the User is a automated bot.
   */
  BOT
}

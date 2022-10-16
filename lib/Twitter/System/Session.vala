/* Session.vala
 *
 * Copyright 2022 Frederick Schenk
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
 * Holds an active session in a client.
 *
 * This is a subclass of the base Session, implementing the functionality
 * for the Twitter backend. See the base class for more details.
 */
public class Backend.Twitter.Session : Backend.Session {

  /**
   * Creates a new instance of Session.
   *
   * @param account The account for this session.
   */
  internal Session (Backend.Account account) {
    // Construct new object
    Object (
      account: account
    );
  }

}

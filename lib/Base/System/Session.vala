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
 * This class provides the utilities to manage a session with one account which
 * is displayed in the account, and provides the possibility to store data of
 * the window displaying the session when the backend is shutdown.
 *
 * It also contains the methods for an application to retrieve content, as it
 * keeps an reference to posts, users, etc. loaded from a specific account.
 */
public abstract class Backend.Session : Object {

  /**
   * Creates a new instance of Session.
   *
   * @param account The account for this session.
   *
   * @return A session suitable for the set account.
   */
  public static Session for_account (Account account) {
    switch (PlatformEnum.for_account (account)) {
      case MASTODON:
        return new Mastodon.Session (account);
      case TWITTER:
        return new Twitter.Session (account);
      default:
        error ("No compatible session type found for this account!");
    }
  }

  /**
   * The account that is managed by this session.
   */
  public Account account { get; construct; }

}

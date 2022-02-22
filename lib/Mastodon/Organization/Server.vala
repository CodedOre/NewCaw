/* Server.vala
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
 * Stores the information to connect to a specific Mastodon server.
 */
public class Backend.Mastodon.Server : Backend.Server {

  /**
   * Creates a new connection to a Mastodon server.
   *
   * Creates a connection to a Mastodon instances and checks that the connection is working properly.
   * If client_key and client_secret are not provided, it also automatically creates a client application
   * on the Mastodon instance to be used for authentication and API calls.
   *
   * @param domain The domain of the server to connect to.
   * @param client_key The key to authenticate the client if available.
   * @param client_secret The secret to authenticate the client if available.
   */
  public Server (string domain, string? client_key = null, string? client_secret = null) {
  }

}

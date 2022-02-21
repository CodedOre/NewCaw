/* Platform.vala
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
 * The backend for the Mastodon API.
 */
namespace Backend.Mastodon {

  /**
   * Initializes the platform and provides basic data.
   */
  public class Platform : Object {

    /**
     * Retrieve the client key used with the API.
     *
     * @param server The server to be used with the API.
     *
     * @return The client key used to communicate with the server.
     */
    public static string get_client_key (string server) {
    }

    /**
     * Retrieve the client secret used with the API.
     *
     * @param server The server to be used with the API.
     *
     * @return The client secret used to communicate with the server.
     */
    public static string get_client_secret (string server) {
    }

    /**
     * Creates a connection with the server.
     *
     * This should be the first method before using any API from the server,
     * as this sets up the clients key and secrets.
     *
     * @param server The server to be used with the API.
     * @param key The key to authenticate the client, or null if not set.
     * @param secret The secret the authenticate the client, or null if not set.
     */
    public static void init (string server, string key, string secret) {
    }

  }

}

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
   * The "Out-of-Band" redirect for Mastodon.
   */
  internal override string oob_redirect {
    get {
      return "urn:ietf:wg:oauth:2.0:oob";
    }
  }

  /**
   * Creates an connection with established client authentication.
   *
   * This constructor requires existing and valid client
   * keys and secrets to build the connection.
   *
   * If no keys are provided, use the Server.authenticate instead.
   *
   * @param domain The domain of the server to connect to.
   * @param client_key The key to authenticate the client if available.
   * @param client_secret The secret to authenticate the client if available.
   */
  public Server (string domain, string client_key, string client_secret) {
  }

  /**
   * Authenticates the client and creates a connection.
   *
   * This will register a new oauth app on the server and
   * will request new keys and secrets for the client to use.
   *
   * @param domain The domain of the server to connect to.
   */
  public Server.authenticate (string domain) {
  }

}

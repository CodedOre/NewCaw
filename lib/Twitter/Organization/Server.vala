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
 * Stores the information to connect to the Twitter server.
 */
public class Backend.Twitter.Server : Backend.Server {

  /**
   * The "Out-of-Band" redirect for Twitter.
   */
  internal override string oob_redirect {
    get {
      return "oob";
    }
  }

  /**
   * Creates an connection with established client authentication.
   *
   * This constructor requires existing and valid client
   * keys and secrets to build the connection.
   *
   * If you do not have a key to provide, you need to generate
   * them on Twitter's Developer Portal to use here.
   *
   * @param client_key The key to authenticate the client.
   * @param client_secret The secret to authenticate the client.
   */
  public Server (string client_key, string client_secret) {
  }

  /**
   * Checks an finished Rest.ProxyCall for occurred errors.
   *
   * @param call The call as run by call.
   *
   * @throws CallError Possible detected errors.
   */
  protected override void check_call (Rest.ProxyCall call) throws CallError {
  }

}

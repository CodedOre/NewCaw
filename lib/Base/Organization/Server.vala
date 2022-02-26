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
 * Stores the information to connect to a specific server.
 */
public abstract class Backend.Server : Object {

  /**
   * The "Out-of-Band" redirect uri.
   *
   * This uri is used when the Client does not specify an redirect url
   * to identify the API to display an authentication code
   * the user needs to manually input to authenticate the client.
   */
  internal abstract string oob_redirect { get; }

  /**
   * The domain of the server.
   */
  public string domain { get; construct; }

  /**
   * The uri to which API calls are made.
   */
  public string api_uri { get; construct; }

  /**
   * The key used to identify the client to the server.
   */
  public string client_key { get; private construct; }

  /**
   * The secret used to identify the client to the server.
   */
  public string client_secret { get; private construct; }

}

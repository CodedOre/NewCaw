/* Client.vala
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
 * Stores basic information representing the client.
 */
[SingleInstance]
public class Backend.Client : Object {

  /**
   * The global instance of Client.
   */
  public static Client? instance { get; private set; default = null; }

  /**
   * The name of the client.
   *
   * Used by the Mastodon backend to create an oauth application when needed.
   */
  public string name { get; construct; }

  /**
   * The website for the client.
   *
   * Used by the Mastodon backend to create an oauth application when needed.
   */
  public string website { get; construct; }

  /**
   * An optional redirect uri to speed up the authentication process.
   *
   * After the user authorized the client, this uri will be called.
   * The client can then use it to access the authentication code without
   * the user needing to input it in the application.
   *
   * If set to null, the out-of-band uri for a specific platform is used instead.
   */
  public string? redirect_uri { get; construct; }

  /**
   * Constructs the client instance.
   *
   * @param name The name of the client.
   * @param website The website for the client.
   * @param redirect_uri An optional redirect uri.
   */
  public Client (string name, string website, string? redirect_uri = null) {
    // Construct the class
    Object (
      name:         name,
      website:      website,
      redirect_uri: redirect_uri
    );

    // Set the global instance
    instance = this;
  }

}

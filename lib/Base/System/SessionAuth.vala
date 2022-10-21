/* SessionAuth.vala
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
 * Provides utilities to authenticate new sessions.
 */
public abstract class Backend.SessionAuth : Object {

  /**
   * Initializes the authentication.
   *
   * Initializes the authentication proxy at the set server.
   * If the client was not authenticated at the given server,
   * it will run the authentication for it.
   *
   * On platforms with only one server (e.g. Twitter), the domain
   * parameter is ignored.
   *
   * @param domain The domain of the server to authenticate at.
   *
   * @throws Error Errors that happen when the server could not be set.
   */
  public abstract async void init_auth (string domain) throws Error;

  /**
   * Generates an authentication url to begin an authentication.
   *
   * The returned url should be opened in the default browser,
   * so the user can authenticate the client at the platforms server.
   *
   * @param use_redirect If the clients redirect should be used.
   *
   * @return The link with the site to authenticate the user.
   */
  public abstract string auth_request (bool use_redirect = true);

  /**
   * Finishes the authentication and creates the Session.
   *
   * This finishes the authentication by retrieving the access token
   * using the authentication code the user retrieved from the
   * authentication server, and creates a new Session.
   *
   * @param auth_code The authentication code for the user.
   * @param state An additional code verified locally.
   *
   * @return The newly authenticated session.
   *
   * @throws Error Any error occurring while finishing the authentication.
   */
  public abstract async Session authenticate (string auth_code, string? state = null) throws Error;

}

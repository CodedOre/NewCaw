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
public class Backend.Mastodon.SessionAuth : Backend.SessionAuth {

  /**
   * The scopes that will be requested.
   */
  private const string AUTH_SCOPES = "read write follow push";

  /**
   * Initializes the authentication.
   */
  public override async void init_auth (string domain) throws Error {
    // Clear auth states
    auth_server = null;
    auth_proxy = null;
    auth_state = null;
    auth_challenge = null;

    // Add an existing or new server for the set domain
    try {
      Server? server_check = Client.instance.servers.find <string> (domain, (needle, item) => { return item.domain == needle; }) as Server;
      auth_server = server_check != null
                      ? server_check
                      : yield new Server.authenticate (domain);
    } catch (Error e) {
      throw e;
    }

    // Create the auth_proxy
    auth_proxy = new Rest.OAuth2Proxy (@"https://$(auth_server.domain)/oauth/authorize",
                                       @"https://$(auth_server.domain)/oauth/token",
                                       Server.OOB_REDIRECT,
                                       auth_server.client_key,
                                       auth_server.client_secret,
                                       @"https://$(auth_server.domain)/");
  }

  /**
   * Generates an authentication url to begin an authentication.
   */
  public override string auth_request (bool use_redirect = true) {
    // Check if a proxy is available
    if (auth_server == null && auth_proxy == null) {
      error ("No authentication proxy found! Use init_auth first.");
    }

    // Clear auth states
    auth_challenge = null;
    auth_state = null;

    // Check which redirect uri to use
    Client application = Client.instance;
    auth_proxy.redirect_uri = use_redirect && application.redirect_uri != null
                               ? application.redirect_uri
                               : Server.OOB_REDIRECT;

    // Create code challenge
    auth_challenge = new Rest.PkceCodeChallenge.random ();

    // Build authorization url
    return auth_proxy.build_authorization_url (auth_challenge.get_challenge (),
                                               AUTH_SCOPES,
                                               out auth_state);
  }

  /**
   * Finishes the authentication and creates the Session.
   */
  public override async Backend.Session authenticate (string auth_code, string? state = null) throws Error {
    // Check if proxy and challenge is available
    if (auth_server == null && auth_proxy == null && auth_challenge == null) {
      error ("No authentication challenge found! Use auth_request first!");
    }

    // Check state if provided
    if (state != null && state != auth_state) {
      error ("Authentication could not be verified!");
    }

    // Get the access token using the proxy
    try {
      yield auth_proxy.fetch_access_token_async (auth_code, auth_challenge.get_verifier (), null);
    } catch (Error e) {
      throw e;
    }

    // Check if we retrieved a valid access token
    if (auth_proxy.access_token.length <= 0) {
      error ("Could not retrieve access token!");
    }

    // Create a new session
    string session_id = Uuid.string_random ();
    try {
      return yield Backend.Session.from_data (session_id, auth_proxy.access_token, auth_server);
    } catch (Error e) {
      throw e;
    }
  }

  /**
   * The server at which the session will be authenticated.
   */
  private Server? auth_server = null;

  /**
   * The proxy used to run the authentication.
   */
  private Rest.OAuth2Proxy? auth_proxy = null;

  /**
   * A CodeChallenge used to verify the authentication process.
   */
  private Rest.PkceCodeChallenge? auth_challenge = null;

  /**
   * A string that can be used to proof-check the process.
   */
  private string? auth_state = null;

}

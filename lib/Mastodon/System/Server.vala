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
   * The "Out-of-Band" redirect uri for Mastodon.
   *
   * This uri is used when the Client does not specify an redirect url
   * to identify the API to display an authentication code
   * the user needs to manually input to authenticate the client.
   */
  internal const string OOB_REDIRECT = "urn:ietf:wg:oauth:2.0:oob";

  /**
   * Creates an connection with established client authentication.
   *
   * This constructor requires existing and valid client
   * keys and secrets to build the connection.
   *
   * If no keys are provided, use the Server.authenticate instead.
   *
   * @param identifier The identifier for the session.
   * @param domain The domain of the server to connect to.
   * @param client_key The key to authenticate the client if available.
   * @param client_secret The secret to authenticate the client if available.
   */
  internal Server (string identifier, string domain, string client_key, string client_secret) {
    // Create the Server instance
    Object (
      domain:        domain,
      client_key:    client_key,
      client_secret: client_secret
    );

    // Set the identifier
    this.identifier = identifier;
  }

  /**
   * Authenticates the client and creates a connection.
   *
   * This will register a new oauth app on the server and
   * will request new keys and secrets for the client to use.
   *
   * @param domain The domain of the server to connect to.
   *
   * @throws Error Any error that occurs while creating the client application.
   */
  internal async Server.authenticate (string domain, Cancellable? cancellable = null) throws Error {
    // Create the Server instance
    Object (
      domain: domain
    );

    // Create Rest Proxy and Call
    var client_proxy = new Rest.Proxy (@"https://$(domain)/", false);
    var client_call  = client_proxy.new_call ();

    // Get Client instance and determine used redirect uri
    Client application    = Client.instance;
    string used_redirects = OOB_REDIRECT;
    if (application.redirect_uri != null) {
      used_redirects += "\n" + application.redirect_uri;
    }

    // Set up authentication
    client_call.set_method ("POST");
    client_call.set_function ("api/v1/apps");
    client_call.add_param ("client_name", application.name);
    client_call.add_param ("redirect_uris", used_redirects);
    client_call.add_param ("scopes", "read write follow push");
    client_call.add_param ("website", application.website);

    // Authenticate client
    Json.Node   json;
    Json.Object client;
    try {
      json   = yield call (client_call, cancellable);
      client = json.get_object ();
    } catch (Error e) {
      throw e;
    }

    // Retrieve the client key and secret
    client_key    = client.get_string_member ("client_id");
    client_secret = client.get_string_member ("client_secret");

    // Create identifier and add the new server to ClientState
    identifier = Uuid.string_random ();
    Client.instance.servers.add (this);
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

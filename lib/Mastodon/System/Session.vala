/* Session.vala
 *
 * Copyright 2022-2023 Frederick Schenk
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
 * This is a subclass of the base Session, implementing the functionality
 * for the Mastodon backend. See the base class for more details.
 */
public partial class Backend.Mastodon.Session : AsyncInitable {

  /**
   * Creates a new instance of the Session class.
   *
   * Also creates the required proxy and loads the connected account
   * before creating the new instance. Should the loading fail it throws
   * an error and will not create the instance.
   *
   * @param identifier The identifier for this session.
   * @param access_token The access token to make calls for this session.
   * @param server The server this session is connected to.
   */
  internal Session (string identifier, string access_token, Backend.Server server, bool auto_start) {
    // Construct the new object
    Object (
      identifier: identifier,
      access_token: access_token,
      server: server,
      auto_start: auto_start
    );

    // Set the proxy
    proxy = new Rest.OAuth2Proxy (@"https://$(server.domain)/oauth/authorize",
                                           @"https://$(server.domain)/oauth/token",
                                           Server.OOB_REDIRECT,
                                           server.client_key,
                                           server.client_secret,
                                           @"https://$(server.domain)/");
    proxy.access_token = access_token;
    // Work around librest doing a DateTime comparison with the default non-expiring token
    // 100 years should be more than enough for anyone!
    // Note: This doesn't actually stop the token expiring. It just makes librest not error.
    var now = new GLib.DateTime.now();
    var far_future = now.add_years (100);
    proxy.set_expiration_date (far_future);
  }

  /**
   * Run at construction of this session.
   */
  construct {
    // Initialize the content storage.
    pulled_posts = new HashTable <string, Post> (str_hash, str_equal);
    pulled_users = new HashTable <string, User> (str_hash, str_equal);
  }

  /**
   * Initializes the object after constructions.
   *
   * This primarily loads the account connected with the session. Before
   * init_async is completed, initialization is not finished and no
   * method of Session should be accessed!
   *
   * For more information view the docs for AsyncInitable.
   *
   * @param io_priority The I/O priority of the operation
   * @param cancellable Allows the initialization of the class to be cancelled.
   *
   * @return If the object was successfully initialized.
   *
   * @throws Error Errors that happened while loading the account.
   */
  public virtual async bool init_async (int io_priority = Priority.DEFAULT, Cancellable? cancellable = null) throws Error {
    // Make a call to load the account
    var account_call = proxy.new_call ();
    account_call.set_method ("GET");
    account_call.set_function ("api/v1/accounts/verify_credentials");

    // Load the data for the account
    Json.Node json;
    try {
      json = yield server.call (account_call);
    } catch (Error e) {
      throw e;
    }

    // Create the object for the account
    account = load_user (json.get_object ());

    // Add the new session to the ClientState
    Client.instance.sessions.add (this);
    return true;
  }

  /**
   * Removes the session from the client.
   *
   * This is an platform-specific implementation of the abstract method
   * defined in the base class, for more details see the base method.
   */
  public override async void revoke_session () throws Error {
    // Prepare revoke call
    var call = proxy.new_call ();
    call.set_method ("POST");
    call.set_function ("oauth/revoke");
    call.add_param ("client_id",     server.client_key);
    call.add_param ("client_secret", server.client_secret);
    call.add_param ("token",         access_token);

    // Revoke key at the server
    try {
      yield server.call (call);
    } catch (Error e) {
      throw e;
    }

    // Remove the session from ClientState
    Client.instance.unregister_session (this);
  }

  /**
   * Creates a Rest.ProxyCall to perform an API call.
   */
  internal override Rest.ProxyCall create_call () {
    return proxy.new_call ();
  }

  /**
   * The proxy used to authorize the API calls.
   */
  private Rest.OAuth2Proxy proxy;

  /**
   * Stores a reference to each post pulled by this session.
   */
  private HashTable <string, Post> pulled_posts;

  /**
   * Stores a reference to each user pulled by this session.
   */
  private HashTable <string, User> pulled_users;

}

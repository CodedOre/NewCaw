/* Session.vala
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
 * Holds an active session in a client.
 *
 * This is a subclass of the base Session, implementing the functionality
 * for the Mastodon backend. See the base class for more details.
 */
public class Backend.Mastodon.Session : Backend.Session {

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
   *
   * @throws Error Errors that happen while verifying the session by loading the account.
   */
  internal async Session (string identifier, string access_token, Backend.Server server) throws Error {
    // Create the proxy
    var call_proxy = new Rest.OAuth2Proxy (@"https://$(server.domain)/oauth/authorize",
                                           @"https://$(server.domain)/oauth/token",
                                           Server.OOB_REDIRECT,
                                           server.client_key,
                                           server.client_secret,
                                           @"https://$(server.domain)/");
    proxy.access_token = access_token;

    // Make a call to load the account
    var account_call = call_proxy.new_call ();
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
    Json.Object data = json.get_object ();
    User account = new User (data);

    // Construct the new object
    Object (
      identifier: identifier,
      access_token: access_token,
      server: server,
      account: account
    );

    // Set the proxy
    proxy = call_proxy;

    // Stores the account in the pulled_user archive
    pulled_users [account.id] = account;
  }

  /**
   * Retrieves an post for an specified id.
   *
   * This is an platform-specific implementation of the abstract method
   * defined in the base class, for more details see the base method.
   */
  public override async Backend.Post pull_post (string id) throws Error {
    // Check if the post is already present in memory
    if (pulled_posts.contains (id)) {
      return pulled_posts [id];
    }

    // Create the proxy call
    Rest.ProxyCall call = proxy.new_call ();
    call.set_method ("GET");
    call.set_function (@"api/v1/statuses/$(id)");

    // Load the user
    Json.Node json;
    try {
      json = yield server.call (call);
    } catch (Error e) {
      throw e;
    }

    // Hand the data over to load_data
    return load_post (json.get_object ());
  }

  /**
   * Loads an post from downloaded data.
   *
   * This is an platform-specific implementation of the abstract method
   * defined in the base class, for more details see the base method.
   */
  internal override Backend.Post load_post (Json.Object data) {
    // Get the id of the post
    string id = data.get_string_member ("id");

    // Check if the post is already present in memory
    if (pulled_posts.contains (id)) {
      return pulled_posts [id];
    }

    // Create a new post and add it to memory
    Post post = new Post (this, data);
    pulled_posts [id] = post;
    return post;
  }

  /**
   * Loads a list of downloaded posts.
   *
   * This is an platform-specific implementation of the abstract method
   * defined in the base class, for more details see the base method.
   */
  internal override Backend.Post[] load_post_list (Json.Node json) {
    // Create the returned array
    Backend.Post[] post_list = {};

    // Parse the posts from the json
    Json.Array list = json.get_array ();
    list.foreach_element ((array, index, element) => {
      if (element.get_node_type () == OBJECT) {
        // Create a new post object
        Json.Object obj = element.get_object ();
        post_list += load_post (obj);
      }
    });

    return post_list;
  }

  /**
   * Retrieves an user for an specified id.
   *
   * This is an platform-specific implementation of the abstract method
   * defined in the base class, for more details see the base method.
   */
  public override async Backend.User pull_user (string id) throws Error {
    // Check if the user is already present in memory
    if (pulled_users.contains (id)) {
      return pulled_users [id];
    }

    // Create the proxy call
    Rest.ProxyCall call = proxy.new_call ();
    call.set_method ("GET");
    call.set_function (@"api/v1/accounts/$(id)");

    // Load the user
    Json.Node json;
    try {
      json = yield server.call (call);
    } catch (Error e) {
      throw e;
    }

    // Hand the data over to load_data
    return load_user (json.get_object ());
  }

  /**
   * Loads an user from downloaded data.
   *
   * This is an platform-specific implementation of the abstract method
   * defined in the base class, for more details see the base method.
   */
  internal override Backend.User load_user (Json.Object data) {
    // Get the id of the user
    string id = data.get_string_member ("id");

    // Check if the user is already present in memory
    if (pulled_users.contains (id)) {
      return pulled_users [id];
    }

    // Create a new user and add it to memory
    User user = new User (data); //, this);
    pulled_users [id] = user;
    return user;
  }

  /**
   * Retrieves the HomeTimeline for the account in this session.
   *
   * This is an platform-specific implementation of the abstract method
   * defined in the base class, for more details see the base method.
   */
  public override Backend.HomeTimeline get_home_timeline (string[] headers = {}) {
    return new HomeTimeline (this, headers);
  }

  /**
   * Retrieves the UserTime for a user in this session.
   *
   * This is an platform-specific implementation of the abstract method
   * defined in the base class, for more details see the base method.
   */
  public override Backend.UserTimeline get_user_timeline (Backend.User user, string[] headers = {}) {
    return new UserTimeline (this, user, headers);
  }

  /**
   * Retrieves the Thread for a post in this session.
   *
   * This is an platform-specific implementation of the abstract method
   * defined in the base class, for more details see the base method.
   */
  public override Backend.Thread get_thread (Backend.Post main_post) {
    return new Thread (this, main_post);
  }

  /**
   * Removes the session from the client.
   *
   * This is an platform-specific implementation of the abstract method
   * defined in the base class, for more details see the base method.
   */
  public override async void revoke_session () throws Error {
    var call = proxy.new_call ();
    call.set_method ("POST");
    call.set_function ("oauth/revoke");
    call.add_param ("client_id",     server.client_key);
    call.add_param ("client_secret", server.client_secret);
    call.add_param ("token",         access_token);

    try {
      yield server.call (call);
    } catch (Error e) {
      throw e;
    }
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

}

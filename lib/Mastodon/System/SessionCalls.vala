/* SessionCalls.vala
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

/*
 * This file contains the call methods from the Session class.
 * For methods regarding the session itself, see Session.vala.
 */
public partial class Backend.Mastodon.Session : Backend.Session {

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

    Post post;

    // Check if the post is already present in memory
    if (pulled_posts.contains (id)) {
      post = pulled_posts [id];
      post.update_interactions (Backend.Mastodon.Post.get_interaction_data(data));
    }
    else {
      // Create a new post and add it to memory
      post = new Post (this, data);
      pulled_posts [id] = post;
    }

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

  public override async Backend.Post favourite_post (Backend.Post post) throws Error {
    // Create the proxy call
    Rest.ProxyCall call = proxy.new_call ();
    call.set_method ("POST");
    call.set_function (@"api/v1/statuses/$(post.id)/favourite");

    // Send the message and return the updated post
    Json.Node json = yield server.call (call);
    return load_post (json.get_object ());
  }

  public override async Backend.Post unfavourite_post (Backend.Post post) throws Error {
    // Create the proxy call
    Rest.ProxyCall call = proxy.new_call ();
    call.set_method ("POST");
    call.set_function (@"api/v1/statuses/$(post.id)/unfavourite");

    // Send the message and return the updated post
    Json.Node json = yield server.call (call);
    return load_post (json.get_object ());
  }

  public override async Backend.Post reblog_post (Backend.Post post) throws Error {
    // Create the proxy call
    Rest.ProxyCall call = proxy.new_call ();
    call.set_method ("POST");
    call.set_function (@"api/v1/statuses/$(post.id)/reblog");

    // Send the message and return the reblog post
    Json.Node json = yield server.call (call);
    return load_post (json.get_object ());
  }

  public override async Backend.Post unreblog_post (Backend.Post post) throws Error {
    // Create the proxy call
    Rest.ProxyCall call = proxy.new_call ();
    call.set_method ("POST");
    call.set_function (@"api/v1/statuses/$(post.id)/unreblog");

    // Send the message and return the unreblogged post
    Json.Node json = yield server.call (call);
    return load_post (json.get_object ());
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
   * Retrieves an user using it's name.
   *
   * This is an platform-specific implementation of the abstract method
   * defined in the base class, for more details see the base method.
   */
  public override async Backend.User? pull_user_by_name (string name) throws Error {
    // Create the proxy call
    Rest.ProxyCall call = proxy.new_call ();
    call.set_method ("GET");
    call.set_function (@"api/v2/search");
    call.add_param ("type", "accounts");
    call.add_param ("limit", "1");
    call.add_param ("q", name);

    // Perform the search
    Json.Node json;
    try {
      json = yield server.call (call);
    } catch (Error e) {
      throw e;
    }

    // Retrieve the user object
    Json.Object root = json.get_object ();
    Json.Array users = root.get_array_member ("accounts");
    Json.Object? user = users.get_length () > 0 ? users.get_object_element (0) : null;

    // Check that the username matches the search
    string? acct = user != null ? user.get_string_member ("acct") : null;
    // Users on our own server don't have an domain in acct, while the mention
    // has, so we check for an version extended with the domain as well.
    string? homeacct = acct != null ? acct + "@" + server.domain : null;

    // Warn if the user could not be determined
    if (acct != name && homeacct != name) {
      error (@"Failed to determine user for username \"$(name)\"");
      return null;
    }

    // Hand the data over to load_data
    return load_user (user);
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

}

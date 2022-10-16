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
 * for the Twitter backend. See the base class for more details.
 */
public class Backend.Twitter.Session : Backend.Session {

  /**
   * Creates a new instance of Session.
   *
   * @param account The account for this session.
   */
  internal Session (Backend.Account account) {
    // Construct new object
    Object (
      account: account
    );
  }

  /**
   * Retrieves an post for an specified id.
   *
   * This is an platform-specific implementation of the abstract method
   * defined in the base class, for more details see the base method.
   */
  internal override async Backend.Post pull_post (string id) throws Error {
    // Check if the post is already present in memory
    if (pulled_posts.contains (id)) {
      return pulled_posts [id];
    }

    // Create the proxy call
    Rest.ProxyCall call = account.create_call ();
    call.set_method ("GET");
    call.set_function (@"tweets/$(id)");
    Server.append_post_fields (ref call);

    // Load the user
    Json.Node json;
    try {
      json = yield account.server.call (call);
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
    // Split the post data object
    Json.Object object;
    if (data.has_member ("data")) {
      object = data.get_object_member ("data");
    } else {
      error ("Could not retrieve Post data!");
    }

    // Get the id of the post
    string id = object.get_string_member ("id");

    // Check if the post is already present in memory
    if (pulled_posts.contains (id)) {
      return pulled_posts [id];
    }

    // Retrieve the includes json
    Json.Object includes;
    if (data.has_member ("includes")) {
      includes = data.get_object_member ("includes");
    } else {
      includes = null;
    }

    // Create a new post and add it to memory
    Post post = new Post (object, includes, this);
    pulled_posts [id] = post;
    return post;
  }

}

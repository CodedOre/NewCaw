/* Thread.vala
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
 * Provides the utilities to display a thread based on a post.
 */
public class Backend.Mastodon.Thread : Backend.Thread {

  /**
   * Creates a new Thread object for a given main post.
   *
   * @param session The Session that this thread is assigned to.
   * @param main_post The main post which serves as the focus for this thread.
   */
  internal Thread (Session session, Backend.Post main_post) {
    // Construct the object
    Object (
      session: session,
      main_post: main_post
    );

    // Append the main post to the list
    add_item (main_post);
  }

  /**
   * Calls the API to get the posts for the Collection.
   *
   * @throws Error Any error that happened while pulling the posts.
   */
  public override async void pull_items () throws Error {
    // If main post is a repost, we use the referenced post
    var pull_post = main_post.post_type == REPOST
                      ? main_post.referenced_post
                      : main_post;

    // Create the proxy call
    Rest.ProxyCall call = session.create_call ();
    call.set_method ("GET");
    call.set_function (@"api/v1/statuses/$(pull_post.id)/context");

    // Load the timeline
    Json.Node json;
    try {
      json = yield session.server.call (call);
    } catch (Error e) {
      throw e;
    }

    // Split the returned json in preceding and following
    Json.Object data = json.get_object ();
    var preceding = new Json.Node.alloc ();
    var following = new Json.Node.alloc ();
    preceding.init_array (data.get_array_member ("ancestors"));
    following.init_array (data.get_array_member ("descendants"));

    // Load the posts in the post list
    foreach (Backend.Post post in session.load_post_list (preceding)) {
      add_item (post);
    }
    foreach (Backend.Post post in session.load_post_list (following)) {
      add_item (post);
    }
  }

}

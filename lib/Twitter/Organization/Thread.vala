/* Thread.vala
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
 * Provides the utilities to display a thread based on a post.
 */
public class Backend.Twitter.Thread : Backend.Thread {

  /**
   * The id for the conversation for this thread.
   */
  public string conversation_id { get; construct; }

  /**
   * Creates a new Thread object for a given main post.
   *
   * @param main_post The main post which serves as the focus for this thread.
   * @param account The Account used for making the API calls.
   */
  public Thread (Backend.Post main_post, Backend.Account account) {
    // Get the sub-type of the post
    var main_tweet = main_post as Post;

    // Construct the object
    Object (
      post_list: new ListStore (typeof (Object)),
      conversation_id: main_tweet.conversation_id,
      reverse_chronological: false,
      call_account: account,
      main_post: main_post
    );

    // Append the main post to the list
    var store = post_list as ListStore;
    store.append (main_post);
  }

  /**
   * Calls the API to get the posts for the Collection.
   *
   * @throws Error Any error that happened while pulling the posts.
   */
  public override async void pull_posts () throws Error {
    // Create the proxy call
    Rest.ProxyCall call = call_account.create_call ();
    call.set_method ("GET");
    call.set_function (@"tweets/search/recent");
    Server.append_post_fields (ref call);

    // Build the search query
    string query = "";
    query += @"conversation_id: $(conversation_id)";
    call.add_param ("query", query);

    // Load the timeline
    Json.Node json;
    try {
      json = yield call_account.server.call (call);
    } catch (Error e) {
      throw e;
    }
    Json.Object data = json.get_object ();

    // Check the meta object for info
    Json.Object meta = data.get_object_member ("meta");
    int64 post_count = meta.get_int_member ("count");
    // Skip parsing when no posts were provided
    if (post_count < 1) {
      return;
    }

    // Retrieve the post list
    Json.Array list;
    if (data.has_member ("data")) {
      list = data.get_array_member ("data");
    } else {
      error ("Could not retrieve post list!");
    }

    // Retrieve the data object
    Json.Object includes;
    if (data.has_member ("includes")) {
      includes = data.get_object_member ("includes");
    } else {
      includes = null;
    }

    // Parse the posts from the json
    var store = post_list as ListStore;
    list.foreach_element ((array, index, element) => {
      if (element.get_node_type () == OBJECT) {
        // Create a new post object
        Json.Object obj   = element.get_object ();
        var         post  = Post.from_json (obj, includes);
        store.append (post);
      }
    });

    // Sort the list
    store.sort (compare_items);
  }

}

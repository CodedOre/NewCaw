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
   * @param session The Session that this thread is assigned to.
   * @param main_post The main post which serves as the focus for this thread.
   */
  public Thread (Session session, Backend.Post main_post) {
    // Get the sub-type of the post
    var main_tweet = main_post as Post;

    // Construct the object
    Object (
      post_list: new ListStore (typeof (Object)),
      conversation_id: main_tweet.conversation_id,
      reverse_chronological: false,
      session: session,
      main_post: main_post
    );

    // Append the main post to the list
    var store = post_list as ListStore;
    store.insert_sorted (main_post, compare_items);

    /* FIXME: Rework this bit.
    // Append a warning PseudoItem when the post is too old
    if (timeout_label != null) {
      var      nowtime = new DateTime.now ();
      TimeSpan postage = nowtime.difference (main_post.creation_date);
      if (postage / TimeSpan.DAY > 7) {
        var timeout_item = new PseudoItem (0, timeout_label);
        store.insert_sorted (timeout_item, compare_items);
      }
    }
    */
  }

  /**
   * Calls the API to get the posts for the Collection.
   *
   * @throws Error Any error that happened while pulling the posts.
   */
  public override async void pull_posts () throws Error {
    // Calls all posts preceding the main post
    var store = post_list as ListStore;
    var parent_iterator = main_post;
    while (true) {
      string parent_id = parent_iterator.replied_to_id;
      if (parent_id == null) {
        break;
      }
      parent_iterator = yield session.pull_post (parent_id);
      store.insert_sorted (parent_iterator, compare_items);
    }

    // Create the proxy call
    Rest.ProxyCall call = session.account.create_call ();
    call.set_method ("GET");
    call.set_function (@"tweets/search/recent");
    Server.append_post_fields (ref call);

    // Build the search query
    call.add_param ("query", @"in_reply_to_tweet_id:$(main_post.id)");
    call.add_param ("max_results", "100");

    // Load the timeline
    Json.Node json;
    try {
      json = yield session.account.server.call (call);
    } catch (Error e) {
      throw e;
    }
    Json.Object data = json.get_object ();

    // Check the meta object for info
    Json.Object meta = data.get_object_member ("meta");
    int64 post_count = meta.get_int_member ("result_count");
    // Skip parsing when no posts were provided
    if (post_count < 1) {
      return;
    }

    // Load the posts in the post list
    foreach (Backend.Post post in session.load_post_list (json)) {
      store.insert_sorted (post, compare_items);
    }
  }

}

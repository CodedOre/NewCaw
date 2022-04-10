/* UserTimeline.vala
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
 * The timeline of Posts a certain User has created.
 */
public class Backend.Mastodon.UserTimeline : Backend.UserTimeline {

  /**
   * Creates a UserTimeline for a User.
   *
   * @param user The User for which the timeline is to be created.
   * @param account The Account used for making the API calls.
   */
  public UserTimeline (Backend.User user, Backend.Account account) {
    // Construct the object
    Object (
      post_list: new ListStore (typeof (Backend.Post)),
      user: user
    );

    // Set the call_account
    call_account = account;
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
    call.set_function (@"accounts/$(user.id)/statuses");
    if (last_post_id != null) {
      call.add_param ("min_id", last_post_id);
    }

    // Load the timeline
    Json.Node json;
    try {
      json = yield call_account.server.call (call);
    } catch (Error e) {
      throw e;
    }
    Json.Array list = json.get_array ();

    // Parse the posts from the json
    var store = post_list as ListStore;
    list.foreach_element ((array, index, element) => {
      if (element.get_node_type () == OBJECT) {
        // Create a new post object
        Json.Object obj  = element.get_object ();
        var         post = new Post.from_json (obj);
        store.insert (index, post);
      }
    });
  }

}

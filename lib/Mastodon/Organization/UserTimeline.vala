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
   * In order to allow a ListView to include widgets before the posts,
   * the headers parameter can be added. For each string in that list
   * an PseudoItem will be created with the string as description.
   *
   * @param session The Session that this timeline is assigned to.
   * @param user The User for which the timeline is to be created.
   * @param headers Descriptions for header items to be added.
   */
  internal UserTimeline (Session session, Backend.User user, string[] headers = {}) {
    // Construct the object
    Object (
      post_list: new ListStore (typeof (Object)),
      session: session,
      user: user
    );

    // Add PseudoItems for the headers
    var store    = post_list as ListStore;
    int header_i = 0;
    foreach (string name in headers) {
      var item = new PseudoItem (header_i, name);
      store.insert_sorted (item, compare_items);
      header_i++;
    }
  }

  /**
   * Calls the API to get the posts for the Collection.
   *
   * @throws Error Any error that happened while pulling the posts.
   */
  public override async void pull_posts () throws Error {
    // Create the proxy call
    Rest.ProxyCall call = session.create_call ();
    call.set_method ("GET");
    call.set_function (@"api/v1/accounts/$(user.id)/statuses");
    call.add_param ("limit", "50");
    if (last_post_id != null) {
      call.add_param ("min_id", last_post_id);
    }

    // Load the timeline
    Json.Node json;
    try {
      json = yield session.server.call (call);
    } catch (Error e) {
      throw e;
    }

    // Load the posts in the post list
    var store = post_list as ListStore;
    foreach (Backend.Post post in session.load_post_list (json)) {
      store.insert_sorted (post, compare_items);
    }
  }

}

/* HomeTimeline.vala
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
 * The reverse chronological timeline with posts from all followed users.
 */
public class Backend.Mastodon.HomeTimeline : Backend.HomeTimeline {

  /**
   * Creates a HomeTimeline for a Session.
   *
   * In order to allow a ListView to include widgets before the posts,
   * the headers parameter can be added. For each string in that list
   * an PseudoItem will be created with the string as description.
   *
   * @param session The Session for which the timeline is created.
   * @param headers Descriptions for header items to be added.
   */
  internal HomeTimeline (Session session, string[] headers = {}) {
    // Construct the object
    Object (
      post_list: new ListStore (typeof (Object)),
      session: session,
      account: session.account
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

  public override async void pull_newer_posts () throws Error {
    yield pull_posts_with_anchor ("min_id", last_post_id);
  }

  public override async void pull_older_posts () throws Error {
    yield pull_posts_with_anchor ("max_id", first_post_id);
  }

  private async void pull_posts_with_anchor(string? key, string? value) throws Error {
    debug("Pulling Mastodon home posts with %s=%s", key, value);
    // Create the proxy call
    Rest.ProxyCall call = session.create_call ();
    call.set_method ("GET");
    call.set_function (@"api/v1/timelines/home");
    call.add_param ("limit", "50");
    if (key != null && value != null) {
      call.add_param (key, value);
    }

    // Load the timeline
    Json.Node json;
    try {
      json = yield session.server.call (call);
    } catch (Error e) {
      throw e;
    }

    // Load the posts in the post list
    add_posts (session.load_post_list (json));
  }

}

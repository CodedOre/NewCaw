/* HomeTimeline.vala
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
      session: session,
      account: session.account,
      headers: headers
    );
  }
  
  /**
   * Calls the API to retrieve all items from this Collection.
   *
   * @throws Error Any error while accessing the API and pulling the items.
   */
  public override async void pull_items () throws Error {
    // Create the proxy call
    Rest.ProxyCall call = session.create_call ();
    call.set_method ("GET");
    call.set_function (@"api/v1/timelines/home");
    call.add_param ("limit", "50");
    if (newest_item_id != null) {
      call.add_param ("min_id", newest_item_id);
    }

    // Load the timeline
    Json.Node json;
    try {
      json = yield session.server.call (call);
    } catch (Error e) {
      throw e;
    }

    // Load the posts in the post list
    add_items (session.load_post_list (json));
  }

}

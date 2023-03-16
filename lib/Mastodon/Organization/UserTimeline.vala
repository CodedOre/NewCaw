/* UserTimeline.vala
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
      session: session,
      user: user,
      headers: headers
    );
  }

  /**
   * Checks if an post in the collection was pinned by the user.
   *
   * If the post is not in this collection, the method returns false.
   *
   * @param post The post to check for.
   *
   * @return If the checked post was pinned by the user of this timeline.
   */
  public override bool is_pinned_post (Backend.Post post) {
    if (pinned_posts == null) {
      return false;
    }
    return post in pinned_posts;
  }

  /**
   * Calls the API to retrieve all items from this Collection.
   *
   * @throws Error Any error while accessing the API and pulling the items.
   */
  public override async void pull_items () throws Error {
    if (pinned_posts == null) {
      yield pull_pins ();
    }

    // Create the proxy call
    Rest.ProxyCall call = session.create_call ();
    call.set_method ("GET");
    call.set_function (@"api/v1/accounts/$(user.id)/statuses");
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

  /**
   * Calls the API to retrieve the pinned posts from this Collection.
   *
   * @throws Error Any error while accessing the API and pulling the posts.
   */
  private async void pull_pins () throws Error {
    // Create the proxy call
    Rest.ProxyCall call = session.create_call ();
    call.set_method ("GET");
    call.set_function (@"api/v1/accounts/$(user.id)/statuses");
    call.add_param ("pinned", "true");

    // Load the timeline
    Json.Node json;
    try {
      json = yield session.server.call (call);
    } catch (Error e) {
      throw e;
    }

    // Load the posts in the post list
    Backend.Post[] posts = session.load_post_list (json);
    pinned_posts = posts;
    add_items (posts);
  }

  /**
   * Stores the pinned posts in this collection.
   */
  private Backend.Post[]? pinned_posts = null;

}

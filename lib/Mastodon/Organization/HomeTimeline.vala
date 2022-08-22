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
   * Creates a HomeTimeline for a Account.
   *
   * In order to allow a ListView to include widgets before the posts,
   * the headers parameter can be added. For each string in that list
   * an PseudoItem will be created with the string as description.
   *
   * @param account The Account for which the timeline is to be created.
   * @param headers Descriptions for header items to be added.
   */
  public HomeTimeline (Backend.Account account, string[] headers) {
    // Construct the object
    Object (
      post_list: new ListStore (typeof (Object)),
      account: account
    );
    
    // Add PseudoItems for the headers
    header_items = headers.length;
    var store    = post_list as ListStore;
    foreach (string name in headers) {
      var item = new PseudoItem (name);
      store.append (item);
    }
  }
  
  /**
   * Calls the API to get the posts for the Collection.
   *
   * @throws Error Any error that happened while pulling the posts.
   */
  public override async void pull_posts () throws Error {
  }

  /**
   * The amount of added header items.
   */
  private uint header_items = 0;

}

/* Collection.vala
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
 * Base class for collections of Posts.
 */
public abstract class Backend.Collection : Object {

  /**
   * A ListModel holding all posts in this Collection.
   */
  public ListModel post_list { get; construct; }
  
  /**
   * An Account used to make the API calls.
   */
  protected Account call_account { get; set; }

  /**
   * Calls the API to get the posts for the Collection.
   *
   * @throws Error Any error that happened while pulling the posts.
   */
  public abstract async void pull_posts () throws Error;

  /**
   * Compares two posts while sorting the list.
   *
   * The sorting is mostly reverse chronological, with a few exceptions.
   * Any item that is not a Post, particular PseudoItems, will be placed on top.
   * Also, if multiple posts that build a reply chain are found, the posts will
   * be sorted chronological for a better understanding of the reply chain.
   *
   * @param a The first object to compare.
   * @param b The second object to compare.
   *
   * @return How to sort both posts (positive when a before b, negative when b before a).
   */
  protected int compare_items (Object a, Object b) {
    // Sort PseudoItems according to their index
    if (a is PseudoItem && b is PseudoItem) {
      // Retrieve the items
      var pseudo_a = a as PseudoItem;
      var pseudo_b = b as PseudoItem;

      // Sort the items using the set index
      uint x = pseudo_a.index;
      uint y = pseudo_b.index;
      return (int) (x > y) - (int) (x < y);
    }

    // Sort Post and not Post
    if (a is Post && ! (b is Post)) {
      return 1;
    }
    if (! (a is Post) && b is Post) {
      return -1;
    }

    // Sort Posts
    if (a is Post && b is Post) {
      // Retrieve the posts
      var post_a = a as Post;
      var post_b = b as Post;

      // Check if one post replies to the other
      bool a_replied_b = post_a.replied_to_id == post_b.id;
      bool b_replied_a = post_b.replied_to_id == post_a.id;
      if (a_replied_b || b_replied_a) {
        return (int) (a_replied_b) - (int) (b_replied_a);
      }

      // Otherwise sort by the date
      DateTime x = post_a.creation_date;
      DateTime y = post_b.creation_date;
      return -1 * x.compare (y);
    }

    // If nothing fits, return 0
    return 0;
  }

  /**
   * The id from the latest pulled Post.
   */
  protected string? last_post_id = null;

}

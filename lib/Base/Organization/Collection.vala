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
   * The session this post is managed by and to be used to retrieve additional data.
   */
  public Session session { get; construct; }

  /**
   * How the posts in this collection are sorted.
   */
  public bool reverse_chronological { get; construct; default = true; }

  /**
   * A ListModel holding all posts in this Collection.
   */
  public ListModel post_list { get; construct; }

  /**
   * Calls the API to get the posts for the Collection.
   *
   * @throws Error Any error that happened while pulling the posts.
   */
  public abstract async void pull_posts () throws Error;

  /**
   * Checks if a post in the list replies to the post previous to it.
   *
   * @param post The post to check for.
   * @param parent If true, a reference to the parent post is set.
   *
   * @return If the post replies to the post previous to it.
   */
  public bool connected_to_previous (Post post, out Post? parent = null) {
    // Retrieve the post list as ListStore
    var store = post_list as ListStore;
    if (store == null) {
      return false;
    }

    // Check if the post exists in the list
    uint index;
    if (! store.find (post, out index)) {
      return false;
    }

    // Find the post before the parameter
    var prev_post = store.get_item (index - 1) as Post;
    if (prev_post != null) {
      // Check if prev_post is parent
      bool has_parent = post.replied_to_id == prev_post.id;
      // Return the result
      parent = has_parent ? prev_post : null;
      return has_parent;
    }
    return false;
  }

  /**
   * Checks if a post in the list replies to the post next to it.
   *
   * @param post The post to check for.
   * @param child If true, a reference to the child post is set.
   *
   * @return If the post replies to the post next to it.
   */
  public bool connected_to_next (Post post, out Post? child = null) {
    // Retrieve the post list as ListStore
    var store = post_list as ListStore;
    if (store == null) {
      return false;
    }

    // Check if the post exists in the list
    uint index;
    if (! store.find (post, out index)) {
      return false;
    }

    // Find the post before the parameter
    var next_post = store.get_item (index + 1) as Post;
    if (next_post != null) {
      // Check if next_post is child
      bool has_child = next_post.replied_to_id == post.id;
      // Return the result
      child = has_child ? next_post : null;
      return has_child;
    }
    return false;
  }

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

      // Retrieve the direct parents for comparison
      var a_parent = direct_parent (post_a);
      var b_parent = direct_parent (post_b);

      // Check if one post replies to the other
      bool a_replied_b = a_parent.replied_to_id == b_parent.id;
      bool b_replied_a = b_parent.replied_to_id == a_parent.id;
      if (a_replied_b || b_replied_a) {
        return (int) (a_replied_b) - (int) (b_replied_a);
      }

      // Otherwise sort by the date
      DateTime x   = a_parent.creation_date;
      DateTime y   = b_parent.creation_date;
      int sort_mod = reverse_chronological ? -1 : 1;
      return sort_mod * x.compare (y);
    }

    // If nothing fits, return 0
    return 0;
  }

  /**
   * Retrieves the direct parent of a post in a Collection.
   *
   * This returns the up-most post in a reply chain, if these are sorted
   * in chronological order. Used by compare_items to sort the list when
   * reply chains are in the list.
   *
   * @param post The post to check the parent for.
   *
   * @return The up-most parent of post, or post itself.
   */
  private Post direct_parent (Post post) {
    while (true) {
      Post new_parent;
      bool has_parent = connected_to_previous (post, out new_parent);
      if (! has_parent) {
        break;
      } else {
        post = new_parent;
      }
    }
    return post;
  }

  /**
   * The id from the latest pulled Post.
   */
  protected string? last_post_id = null;

}

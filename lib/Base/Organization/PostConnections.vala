/* PostConnections.vala
 *
 * Copyright 2023 Frederick Schenk
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
 * An interface for Collection providing information about the connection between posts.
 *
 * Two posts are connected if one replies to the other.
 */
public interface Backend.PostConnections<T> : Backend.Collection<T> {

  /**
   * If the reposted post should be compared instead of the repost.
   */
  public abstract bool check_reposted { get; construct; default = false; }

  /**
   * Checks if a post in the list replies to the post previous to it.
   *
   * @param post The post to check for.
   *
   * @return If the post replies to the post previous to it.
   */
  public bool connected_to_previous (Post post) {
    SequenceIter<T> iter = get_item_iter (post);
    return iter != null ? check_prev_iter (iter) : false;
  }

  /**
   * Checks if a post in the list replies to the post next to it.
   *
   * @param post The post to check for.
   *
   * @return If the post replies to the post next to it.
   */
  public bool connected_to_next (Post post) {
    SequenceIter<T> iter = get_item_iter (post);
    return iter != null ? check_next_iter (iter) : false;
  }

  /**
   * Checks if the post in one iterator is connected to the previous.
   *
   * @param iter The iterator which contains the post to check.
   *
   * @return If the post in the previous iterator is connected.
   */
  protected bool check_prev_iter (SequenceIter<T> iter) {
    // Check that we have a post
    var post = iter.get () as Post;
    if (post == null) {
      return false;
    }

    // Get the previous iterator and check if it has a post
    var prev_iter = iter.prev ();
    var prev_post = prev_iter.get () as Post;
    if (prev_post == null) {
      return false;
    }

    // If check_reposted, use the referenced post to compare
    if (check_reposted && post.post_type == REPOST && post.referenced_post != null) {
      post = post.referenced_post;
    }
    if (check_reposted && prev_post.post_type == REPOST && prev_post.referenced_post != null) {
      prev_post = prev_post.referenced_post;
    }

    // Check for the connection
    return post.replied_to_id == prev_post.id;
  }

  /**
   * Checks if the post in one iterator is connected to the next.
   *
   * @param iter The iterator which contains the post to check.
   *
   * @return If the post in the next iterator is connected.
   */
  protected bool check_next_iter (SequenceIter<T> iter) {
    // Check that we have a post
    var post = iter.get () as Post;
    if (post == null) {
      return false;
    }

    // Get the previous iterator and check if it has a post
    var next_iter = iter.next ();
    if (next_iter.is_end ()) {
      return false;
    }
    var next_post = next_iter.get () as Post;
    if (next_post == null) {
      return false;
    }

    // If check_reposted, use the referenced post to compare
    if (check_reposted && post.post_type == REPOST && post.referenced_post != null) {
      post = post.referenced_post;
    }
    if (check_reposted && next_post.post_type == REPOST && next_post.referenced_post != null) {
      next_post = next_post.referenced_post;
    }

    // Check for the connection
    return post.id == next_post.replied_to_id;
  }

  /**
   * Retrieves the up-most parent of an post in a Collection.
   *
   * Can be used by a sort_func to compare replies and threads to sort
   * them differently to other posts in a collection.
   *
   * @param iter The iterator which contains the post to check.
   *
   * @return The up-most parent of the post, or the post itself.
   */
  protected Post upmost_parent (SequenceIter<T> iter) {
    SequenceIter<T> upmost_iter = iter;
    while (true) {
      if (! check_prev_iter (upmost_iter)) {
        break;
      }
      upmost_iter = upmost_iter.prev ();
    }

    // Retrieve the post for return
    var post = upmost_iter.get () as Post;
    assert (post != null);

    // If check_reposted, use the referenced post to compare
    if (check_reposted && post.post_type == REPOST && post.referenced_post != null) {
      post = post.referenced_post;
    }

    // Return the result
    return post;
  }

}

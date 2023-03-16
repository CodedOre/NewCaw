/* Thread.vala
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
 * Provides the utilities to display a thread based on a post.
 *
 * A Thread provides a list for displaying replies around a specified
 * "main post". It will display all posts preceding the main post until
 * the top one, as well as all replies to the main post.
 */
public abstract class Backend.Thread : Backend.Collection<Post>, Backend.PullableCollection<Post>, Backend.PostConnections<Object> {

  /**
   * The session used to pull posts.
   */
  public Session session { get; construct; }

  /**
   * The post from which the thread is build.
   */
  public Post main_post { get; construct; }

  /**
   * The id of the newest item in the collection.
   */
  protected string? newest_item_id { get; set; default = null; }

  /**
   * If the reposted post should be compared instead of the repost.
   */
  public override bool check_reposted { get; construct; default = true; }

  /**
   * Calls the API to retrieve all items from this Collection.
   *
   * @throws Error Any error while accessing the API and pulling the items.
   */
  public abstract async void pull_items () throws Error;

  /**
   * Used to compares two iterators in the list when sorting.
   *
   * @param a The first iterator to compare.
   * @param b The second iterator to compare.
   *
   * @return How the iterators are sorted (positive when a before b, negative when b before a).
   */
  protected override int sort_func (SequenceIter<Post> a, SequenceIter<Post> b) {
    // Use the upmost parent as reference
    var post_a = upmost_parent (a);
    var post_b = upmost_parent (b);

    assert (post_a.post_type != REPOST);
    assert (post_b.post_type != REPOST);

    // Check if posts are connected
    if (post_a.replied_to_id == post_b.id) {
      return 1;
    }
    if (post_b.replied_to_id == post_a.id) {
      return -1;
    }

    // Sort posts by date
    DateTime x = post_a.creation_date;
    DateTime y = post_b.creation_date;
    return x.compare (y);
  }

}

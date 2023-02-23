/* ReversePostList.vala
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
 * Provides an common interface for collections displaying a
 * linear list of posts in a reverse chronological order.
 */
public abstract class Backend.ReversePostList : Backend.Collection<Object> {

  /**
   * Used to compares two iterators in the list when sorting.
   *
   * This method sorts posts in an reverse chronological order,
   * with non-post objects placed on top of the collection.
   *
   * @param a The first iterator to compare.
   * @param b The second iterator to compare.
   *
   * @return How the iterators are sorted (positive when a before b, negative when b before a).
   */
  protected override int sort_func (SequenceIter<Object> a, SequenceIter<Object> b) {
    // Retrieve the objects of the iterators
    var item_a = a.get ();
    var item_b = b.get ();

    // Sort two posts
    if (item_a is Post && item_b is Post) {
      // Retrieve the posts
      var post_a = item_a as Post;
      var post_b = item_b as Post;

      // Sort posts by date
      DateTime x = post_a.creation_date;
      DateTime y = post_b.creation_date;
      return -1 * x.compare (y);
    }

    // Sort two HeaderItem
    if (item_a is HeaderItem && item_b is HeaderItem) {
      // Retrieve the items
      var header_a = item_a as HeaderItem;
      var header_b = item_b as HeaderItem;

      // Sort the items using the set index
      uint x = header_a.index;
      uint y = header_b.index;
      return (int) (x > y) - (int) (x < y);
    }

    // Sort non-posts before posts
	  return (int) (item_a is Post) - (int) (item_b is Post);
  }

}

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
public abstract class Backend.ReversePostList : Backend.FilteredCollection<Object>, Backend.PostConnections<Object>, Backend.PostFilters {

  /**
   * If generic posts should be displayed.
   */
  public override bool display_generic {
    get {
      return do_display_generic;
    }
    set {
      do_display_generic = value;
      refilter_collection ();
    }
  }

  /**
   * If reposts should be displayed.
   */
  public override bool display_reposts {
    get {
      return do_display_reposts;
    }
    set {
      do_display_reposts = value;
      refilter_collection ();
    }
  }

  /**
   * If replies should be displayed.
   */
  public override bool display_replies {
    get {
      return do_display_replies;
    }
    set {
      do_display_replies = value;
      refilter_collection ();
    }
  }

  /**
   * If posts with media should be displayed.
   */
  public override bool display_media {
    get {
      return do_display_media;
    }
    set {
      do_display_media = value;
      refilter_collection ();
    }
  }

  /**
   * Checks if an item in the collection matches the filter.
   *
   * @param item The item to check for.
   *
   * @return If the item matches the filter and should be shown.
   */
  public override bool match (Object item) {
    // Show any non-post
    var post = item as Post;
    if (post == null) {
      return true;
    }

    // Use the upmost parent as reference
    var parent = upmost_parent (get_item_iter (post));

    // Run the filters over the parent
    if (parent.replied_to_id != null) {
      return do_display_replies;
    }
    if (parent.post_type == REPOST) {
      return do_display_reposts;
    }
    if (parent.get_media ().length > 0) {
      return do_display_media;
    }

    // Use setting for generic posts
    return do_display_generic;
  }

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
      // Use the upmost parent as reference
      var post_a = upmost_parent (a);
      var post_b = upmost_parent (b);

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

  // Keeps track of the filters of this list
  private bool do_display_generic = true;
  private bool do_display_reposts = true;
  private bool do_display_replies = false;
  private bool do_display_media = true;

}

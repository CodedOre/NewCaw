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
public abstract class Backend.UserTimeline : Backend.FilteredCollection<Object>,
                                             Backend.PullableCollection<Object>,
                                             Backend.PostConnections<Object>,
                                             Backend.CollectionHeaders,
                                             Backend.CollectionPins,
                                             Backend.PostFilters
{

  /**
   * The session used to pull posts.
   */
  public Session session { get; construct; }

  /**
   * The User which timeline is presented.
   */
  public User user { get; construct; }

  /**
   * The strings used to generated the items.
   */
  public string[] headers { get; construct; }

  /**
   * If the reposted post should be compared instead of the repost.
   */
  public override bool check_reposted { get; construct; default = false; }

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
   * The id of the newest item in the collection.
   */
  protected string? newest_item_id { get; set; default = null; }

  /**
   * Run at construction of an instance.
   */
  construct {
    add_items (generate_headers ());
  }

  /**
   * Calls the API to retrieve all items from this Collection.
   *
   * @throws Error Any error while accessing the API and pulling the items.
   */
  public abstract async void pull_items () throws Error;

  /**
   * Checks if an post in the collection was pinned by the user.
   *
   * If the post is not in this collection, the method returns false.
   *
   * @param post The post to check for.
   *
   * @return If the checked post was pinned by the user of this timeline.
   */
  public abstract bool is_pinned_post (Post post);

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

    // Always show pinned posts
    if (is_pinned_post (post)) {
      return true;
    }

    // Use the upmost parent as reference
    var parent = upmost_parent (get_item_iter (post));

    // Run the filters over the parent
    if (parent.replied_to_id != null) {
      return display_replies;
    }
    if (parent.post_type == REPOST) {
      return display_reposts;
    }
    if (parent.get_media ().length > 0) {
      return display_media;
    }

    // Use setting for generic posts
    return display_generic;
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

      // Order pinned posts above the others
      int compare_pins = (int) (is_pinned_post (post_b)) - (int) (is_pinned_post (post_a));
      if (compare_pins != 0) {
        return compare_pins;
      }

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

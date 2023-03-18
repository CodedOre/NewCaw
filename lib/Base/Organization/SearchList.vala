/* SearchList.vala
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
 * Provides a list containing the results of an search.
 */
public abstract class Backend.SearchList : Backend.FilteredCollection<Object>,
                                           Backend.PullableCollection<Object>,
                                           Backend.CollectionHeaders
{

  /**
   * The categories the search list has.
   *
   * Used when sorting the collection.
   */
  enum Category {
    HEAD = 0,
    POST = 1,
    USER = 2
  }

  /**
   * The prefix used for the post category.
   */
  private const string PREFIX_POSTS = "posts-";

  /**
   * The prefix used for the user category.
   */
  private const string PREFIX_USERS = "users-";

  /**
   * The session used to pull posts.
   */
  public Session session { get; construct; }

  /**
   * The strings used to generated the items.
   *
   * SearchList allows to specify category headers by using a prefix.
   * A header with the prefix `posts-` will be used as a header for the
   * post results. The same applies for `users-` for users.
   */
  public string[] headers { get; construct; }

  /**
   * The search term used for the results.
   */
  public string search_term { get; construct; }

  /**
   * If the results for posts should be shown.
   */
  public bool show_posts {
    get {
      return do_show_posts;
    }
    set {
      do_show_posts = value;
      refilter_collection ();
    }
  }

  /**
   * If the results for users should be shown.
   */
  public bool show_users {
    get {
      return do_show_users;
    }
    set {
      do_show_users = value;
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
   * Calls the API to retrieve additional search results for posts.
   *
   * @throws Error Any error while accessing the API and pulling the posts.
   */
  public abstract async void pull_additional_posts () throws Error;

  /**
   * Calls the API to retrieve additional search results for users.
   *
   * @throws Error Any error while accessing the API and pulling the users.
   */
  public abstract async void pull_additional_users () throws Error;

  /**
   * Checks if an item in the collection matches the filter.
   *
   * @param item The item to check for.
   *
   * @return If the item matches the filter and should be shown.
   */
  protected override bool match (Object item) {
    // Check result items
    if (item is Post) {
      return show_posts;
    }
    if (item is User) {
      return show_users;
    }

    // Check header items
    if (item is HeaderItem) {
      var header = item as HeaderItem;

      // Show prefixed items when category is visible
      if (header.description.has_prefix (PREFIX_POSTS)) {
        return show_posts;
      }
      if (header.description.has_prefix (PREFIX_USERS)) {
        return show_users;
      }

      // Always show the rest
      return true;
    }

    // Don't show unknown items
    return false;
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

    // Check which categories the items are in
    Category a_category = HEAD, b_category = HEAD;
    if (item_a is Post) {
      a_category = POST;
    }
    if (item_b is Post) {
      b_category = POST;
    }
    if (item_a is User) {
      a_category = USER;
    }
    if (item_b is User) {
      b_category = USER;
    }
    if (item_a is HeaderItem) {
      var header = item_a as HeaderItem;
      if (header.description.has_prefix (PREFIX_POSTS)) {
        a_category = POST;
      } else if (header.description.has_prefix (PREFIX_USERS)) {
        a_category = USER;
      } else {
        a_category = HEAD;
      }
    }
    if (item_b is HeaderItem) {
      var header = item_b as HeaderItem;
      if (header.description.has_prefix (PREFIX_POSTS)) {
        b_category = POST;
      }
      if (header.description.has_prefix (PREFIX_USERS)) {
        b_category = USER;
      }
    }

    // If items have different categories, sort using them
    if (a_category != b_category) {
      return (int) (a_category > b_category) - (int) (a_category < b_category);
    }

    // Sort headers to the top of their category
    if (item_a is HeaderItem || item_b is HeaderItem) {
      return (int) (item_b is HeaderItem) - (int) (item_a is HeaderItem);
    }

    // Sort two header items
    if (item_a is HeaderItem && item_b is HeaderItem) {
      // Retrieve the items
      var header_a = item_a as HeaderItem;
      var header_b = item_b as HeaderItem;

      // Sort the items using the set index
      uint x = header_a.index;
      uint y = header_b.index;
      return (int) (x > y) - (int) (x < y);
    }

    // Keep sortment of users and posts as provided by server
    return 0;
  }

  // Keeps track of the filters of this list
  private bool do_show_posts = true;
  private bool do_show_users = true;

}

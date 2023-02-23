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
public abstract class Backend.Thread : Backend.Collection<Post>, Backend.PullableCollection<Post> {

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
   * Calls the API to retrieve all items from this Collection.
   *
   * @throws Error Any error while accessing the API and pulling the items.
   */
  public abstract async void pull_items () throws Error;

  /**
   * Compares two items when sorting the collection.
   *
   * FIXME Implementation is postponed until the end of this project.
   *
   * @param a The first item to compare.
   * @param b The second item to compare.
   *
   * @return How the items are sorted (positive when a before b, negative when b before a).
   */
  protected override int compare_items (Post a, Post b) {
    return 0;
  }

}

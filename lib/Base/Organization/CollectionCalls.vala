/* CollectionCalls.vala
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
 * An interface for Collection providing access methods for pullable lists.
 */
public interface Backend.PullableCollection<T> : Backend.Collection<T> {

  /**
   * The session used to pull posts.
   */
  public abstract Session session { get; construct; }

  /**
   * The id of the newest item in the collection.
   */
  protected abstract string? newest_item_id { get; set; default = null; }

  /**
   * Calls the API to retrieve all items from this Collection.
   *
   * @throws Error Any error while accessing the API and pulling the items.
   */
  public abstract async void pull_items () throws Error;

}

/**
 * An interface for Collection providing access methods for paginated lists.
 */
public interface Backend.PaginatedCollection<T> : Backend.Collection<T> {

  /**
   * The session used to pull posts.
   */
  public abstract Session session { get; construct; }

  /**
   * The id of the newest item in the collection.
   */
  protected abstract string? newest_item_id { get; set; default = null; }

  /**
   * The id of the oldest item in the collection.
   */
  protected abstract string? oldest_item_id { get; set; default = null; }

  /**
   * Calls the API to retrieve all new items from this Collection.
   *
   * @throws Error Any error while accessing the API and pulling the items.
   */
  public abstract async void pull_new_items () throws Error;

  /**
   * Calls the API to retrieve older items from this Collection.
   *
   * @throws Error Any error while accessing the API and pulling the items.
   */
  public abstract async void pull_old_items () throws Error;

}

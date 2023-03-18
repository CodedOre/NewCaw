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
                                           Backend.CollectionHeaders
{

  /**
   * The strings used to generated the items.
   *
   * SearchList allows to specify category headers by using a prefix.
   * A header with the prefix `post-` will be used as a header for the
   * post results. The same applies for `user-` for users.
   */
  public string[] headers { get; construct; }

  /**
   * Run at construction of an instance.
   */
  construct {
    add_items (generate_headers ());
  }

  /**
   * Checks if an item in the collection matches the filter.
   *
   * @param item The item to check for.
   *
   * @return If the item matches the filter and should be shown.
   */
  public override bool match (Object item) {
    return true;
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
    return 0;
  }

}

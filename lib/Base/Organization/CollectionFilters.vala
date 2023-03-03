/* CollectionFilters.vala
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
 * The base class for filters for a FilteredCollection.
 */
public abstract class Backend.CollectionFilter<T> : Object {

  /**
   * Signals to the FilteredCollection that the filters were changed.
   */
  public signal void filters_changed ();

  /**
   * Checks if an item in the collection matches the filter.
   *
   * @param item The item to check for.
   *
   * @return If the item matches the filter and should be shown.
   */
  public abstract bool match (T item);

}

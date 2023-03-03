/* FilteredCollection.vala
 *
 * Copyright 2023 CodedOre <47981497+CodedOre@users.noreply.github.com>
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
 * Extends Collection with the option to filter for specific items.
 */
public abstract class Backend.FilteredCollection<T> : Backend.Collection<T> {

  /**
   * The filter used to filter the collection.
   */
  public CollectionFilter<T> filter { get; construct; }

  /**
   * Get the number of items in the collection.
   *
   * @return The number of items in the collection.
   */
  public override uint get_n_items () {
    return (uint) matches.get_size ();
  }

  /**
   * Returns the nth item in the collection.
   *
   * @param position The position to look for.
   *
   * @return The item at the position, or null if position is invalid.
   */
  public virtual Object? get_item (uint position) {
    if (position >= matches.get_size ()) {
      return null;
    }
    uint unfiltered = matches.get_nth (position);
    return base.get_item (unfiltered);
  }

  /**
   * Run after an change to the items of the collection.
   *
   * @param position The position of the change.
   * @param removed The number of items that were removed.
   * @param added The number of items that were added.
   */
  protected override void after_update (uint position, uint removed, uint added) {
    // Send the update signal
    items_changed (position, removed, added);
  }

  /**
   * Checks if an item in the collection matches the filter.
   *
   * @param item The item to check for.
   *
   * @return If the item matches the filter and should be shown.
   */
  protected abstract bool match (T item);

  /**
   * Run the filter over the complete collection.
   *
   * Should be called when the filter has been changed.
   */
  protected void filter_collection () {
  }

  /**
   * Holds the items that are currently matched by the filter.
   */
  private Gtk.Bitset matches;

}

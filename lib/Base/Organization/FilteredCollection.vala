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
 *
 * FilteredCollection was adapted from code of Gtk.FilterListModel,
 * created in 2015 by Benjamin Otte and licensed under the LGPL-2.1-or-later.
 */

using GLib;

/**
 * Extends Collection with the option to filter for specific items.
 */
public abstract class Backend.FilteredCollection<T> : Backend.Collection<T> {

  /**
   * Run at construction of an instance.
   */
  construct {
    matches = new Gtk.Bitset.empty ();
  }

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
  public override Object? get_item (uint position) {
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
    // Update the matches bitset with the removed and added items
    uint added_matches = 0, removed_matches = 0;
    if (removed > 0) {
      removed_matches = (uint) matches.get_size_in_range (position, position + removed - 1);
    }
    matches.splice (position, removed, added);
    if (added > 0) {
      filter_item_set (new Gtk.Bitset.range (position, added));
      added_matches = (uint) matches.get_size_in_range (position, position + added - 1);
    }

    // Send the update signal when collection changed
    if (added_matches != 0 || removed_matches != 0) {
      uint update_pos = position > 0 ? (uint) matches.get_size_in_range (0, position - 1) : 0;
      items_changed (update_pos, removed_matches, added_matches);
    }
  }

  /**
   * Checks if an item in the collection matches the filter.
   *
   * @param item The item to check for.
   *
   * @return If the item matches the filter and should be shown.
   */
  public abstract bool match (T item);

  /**
   * Runs the filter over a set of items.
   *
   * @param items A bitset of the items to filter.
   */
  private void filter_item_set (Gtk.Bitset items) {
    uint pos;
    bool more;
    var iter = Gtk.BitsetIter ();
    for (more = iter.init_first (items, out pos); more; more = iter.next (out pos)) {
      T item = base.get_item (pos);
      if (match (item)) {
        matches.add (pos);
      }
    }
  }

  /**
   * Run the filter over the complete collection.
   *
   * Should be called when the filter has been changed.
   */
  protected void refilter_collection () {
    // Clear the matches while keeping a copy
    Gtk.Bitset old_matches = matches;
    matches = new Gtk.Bitset.empty ();

    // Run the filter over the whole collection
    filter_item_set (new Gtk.Bitset.range (0, base.get_n_items ()));

    // Retrieve the changes between old and new matches
    Gtk.Bitset changes = matches.copy ();
    changes.difference (old_matches);

    // Update the ListModel according to the changes
    if (! changes.is_empty ()) {
      uint minimum    = changes.get_minimum ();
      uint maximum    = changes.get_maximum ();
      uint removed    = (uint) old_matches.get_size_in_range (minimum, maximum);
      uint added      = (uint) matches.get_size_in_range (minimum, maximum);
      uint update_pos = minimum > 0 ? (uint) matches.get_size_in_range (0, minimum - 1) : 0;
      items_changed (update_pos, removed, added);
    }
  }

  /**
   * Holds the items that are currently matched by the filter.
   */
  private Gtk.Bitset matches;

}

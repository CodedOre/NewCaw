/* Collection.vala
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
 *
 * Collection was adapted from code of Gio.ListStore, created in 2015 by
 * Lars Uebernickel and Ryan Lortie and licensed under the LGPL-2.1-or-later.
 */

using GLib;

/**
 * Stores a sorted list of items, that can be used as a ListModel.
 */
public abstract class Backend.Collection <T> : ListModel, Object {

  /**
   * Run at construction of an instance.
   */
  construct {
    items = new Sequence<T> ();
    last_position_valid = false;
    last_iterator = null;
    last_position = 0;
  }

  /**
   * Returns the type of the items the collection stores.
   *
   * @return The type for the items in the collection.
   */
  public Type get_item_type () {
    return typeof (T);
  }

  /**
   * Get the number of items in the collection.
   *
   * @return The number of items in the collection.
   */
  public uint get_n_items () {
    return (uint) items.get_length ();
  }

  /**
   * Returns the nth item in the collection.
   *
   * @param position The position to look for.
   *
   * @return The item at the position, or null if position is invalid.
   */
  public Object? get_item (uint position) {
    SequenceIter<T>? iter = null;

    // Check if we can access the item quickly from the cache
    if (last_position_valid) {
      if (last_position == position) {
        iter = last_iterator;
      } else if (last_position == position - 1) {
        iter = last_iterator.next ();
      } else if (last_position == position + 1) {
        iter = last_iterator.prev ();
      }
    }

    if (iter == null) {
      iter = items.get_iter_at_pos ((int) position);
    }

    // Update cache position
    last_position_valid = true;
    last_position = position;
    last_iterator = iter;

    // Return Object if one was found
    return ! iter.is_end ()
      ? iter.get () as Object
      : null;
  }

  /**
   * Adds an item to the collection.
   *
   * @param item The item to be added.
   */
  protected void add_item (owned T item) {
    SequenceIter<T> iter = items.insert_sorted_iter (item, sort_func);
    uint position = iter.get_position ();
    after_update (position, 0, 1);
  }

  /**
   * Adds multiple items to the collection.
   *
   * @param new_items An array of items to be added.
   */
  protected void add_items (owned T[] new_items) {
    SequenceIter<T>[] iters = {};
    foreach (T item in new_items) {
      iters += items.append (item);
    }
    items.sort_iter (sort_func);
    foreach (SequenceIter<T> iter in iters) {
      uint position = iter.get_position ();
      after_update (position, 0, 1);
    }
  }

  /**
   * Used to compares two iterators in the list when sorting.
   *
   * @param a The first iterator to compare.
   * @param b The second iterator to compare.
   *
   * @return How the iterators are sorted (positive when a before b, negative when b before a).
   */
  protected abstract int sort_func (SequenceIter<T> a, SequenceIter<T> b);

  /**
   * Run after an update to the list happened.
   */
  private void after_update (uint position, uint removed, uint added) {
    // Invalidate cache if changes happened before cache position
    if (position <= last_position) {
      last_position_valid = false;
      last_iterator = null;
      last_position = 0;
    }

    // Send the update signal
    items_changed (position, removed, added);
  }

  /*
   * A cache of the last used item, used to make linear access faster.
   */
  private uint last_position;
  private bool last_position_valid;
  private SequenceIter<T>? last_iterator;

  /**
   * Stores all items that are managed by collection.
   */
  private Sequence<T> items;

}

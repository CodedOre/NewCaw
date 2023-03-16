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
   * The type for the items in the collection.
   */
  public Type item_type {
    get {
      return get_item_type ();
    }
  }

  /**
   * The number of items in the collection.
   */
  public uint length {
    get {
      return get_n_items ();
    }
  }

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
  public virtual uint get_n_items () {
    return (uint) items.get_length ();
  }

  /**
   * Returns the nth item in the collection.
   *
   * @param position The position to look for.
   *
   * @return The item at the position, or null if position is invalid.
   */
  public virtual Object? get_item (uint position) {
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
   * Checks if a item is found in the collection.
   *
   * @param item The item to check for.
   * @param index Receives the position of the item in the list.
   *
   * @return If the item can be found in the list.
   */
  internal bool find (T item, out uint index) {
    SequenceIter<T>? iter = get_item_iter (item);
    index = iter != null ? (uint) iter.get_position () : 0;
    return iter != null;
  }

  /**
   * Retrieves the SequenceIter for a specific object.
   *
   * @param item The item to retrieve the iterator for.
   *
   * @return The iterator for this item, or null if not found.
   */
  internal SequenceIter<T>? get_item_iter (T item) {
    SequenceIter<T> begin = items.get_begin_iter ();
    SequenceIter<T> end   = items.get_end_iter ();
    SequenceIter<T> iter  = begin;
    while (iter != end) {
      if (iter.get () == item) {
        return iter;
      }
      iter = iter.next ();
    }
    return null;
  }

  /**
   * Checks if a item is in the collection using a specific search function.
   *
   * @param needle The needle to check for.
   * @param search_func The function used to determine if it's the correct item.
   *
   * @return The item, if found in the collection. Else null.
   */
  internal T? find_with_needle<G> (G needle, ArraySearchFunc<T, G> search_func) {
    SequenceIter<T> begin = items.get_begin_iter ();
    SequenceIter<T> end   = items.get_end_iter ();
    SequenceIter<T> iter  = begin;
    while (iter != end) {
      if (search_func (iter.get (), needle)) {
        return iter.get ();
      }
      iter = iter.next ();
    }
    return null;
  }

  /**
   * Adds an item to the collection.
   *
   * @param item The item to be added.
   */
  protected void add_item (owned T item) {
    // Skip adding if item is already in collection
    if (get_item_iter (item) != null) {
      return;
    }

    // Insert the item sorted
    SequenceIter<T> iter = items.insert_sorted_iter (item, sort_func);

    // Update the cache and listeners
    uint position = iter.get_position ();
    validate_cache (position);
    after_update (position, 0, 1);
  }

  /**
   * Adds multiple items to the collection.
   *
   * @param new_items An array of items to be added.
   */
  protected void add_items (owned T[] new_items) {
    // Insert the items and sort them
    SequenceIter<T>[] iters = {};
    foreach (T item in new_items) {
      if (get_item_iter (item) == null) {
        iters += items.append (item);
      }
    }
    items.sort_iter (sort_func);

    // Update the cache and listeners
    foreach (SequenceIter<T> iter in iters) {
      uint position = iter.get_position ();
      validate_cache (position);
      after_update (position, 0, 1);
    }
  }

  /**
   * Removes an item from the collection.
   *
   * If the item is not found in the collection, this methods ignores the request.
   * This method also ignores potential duplicates of an item. Classes implementing
   * collection should save-guard against duplicate entries.
   *
   * @param item The item to be removed.
   */
  protected void remove_item (T item) {
    SequenceIter<T>? iter = get_item_iter (item);
    if (iter == null) {
      return;
    }
    uint position = iter.get_position ();
    iter.remove ();
    validate_cache (position);
    after_update (position, 1, 0);
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
   * Run after an change to the items of the collection.
   *
   * @param position The position of the change.
   * @param removed The number of items that were removed.
   * @param added The number of items that were added.
   */
  protected virtual void after_update (uint position, uint removed, uint added) {
    // Send the update signal
    items_changed (position, removed, added);
  }

  /**
   * Validates if the iterator cache is still valid after an change to the collection.
   *
   * @param position The position at which the collection was changed.
   */
  private void validate_cache (uint position) {
    if (position <= last_position) {
      last_position_valid = false;
      last_iterator = null;
      last_position = 0;
    }
  }

  /**
   * An Iterator to enable foreach loops.
   */
  public class Iterator <T> : Object {

    /**
     * Constructs a new Iterator.
     */
    internal Iterator (Collection collection) {
      iter = collection.items.get_begin_iter ();
      first_next = true;
    }

    /**
     * Moves to the next value.
     *
     * @return If a next value exists.
     */
    public bool next () {
      assert (iter != null);
      // The Vala iterator is running first next, then get.
      // In order to also get the first item, the SequenceIter
      // needs to wait one round before running next.
      if (first_next) {
        first_next = false;
      } else {
        iter = iter.next ();
      }
      return (! iter.is_end ());
    }

    /**
     * Retrieves the current value.
     *
     * @return The value at the current iteration.
     */
    public new T? get () {
      assert (iter != null);
      return iter.get ();
    }

    /**
     * If next is called the first.
     */
    private bool first_next;

    /**
     * The current iterator.
     */
    private SequenceIter<T> iter;

  }

  /**
   * Provides an iterator to iterate the list.
   */
  public Iterator<T> iterator () {
    return new Iterator<T> (this);
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

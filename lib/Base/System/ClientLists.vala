/* ClientLists.vala
 *
 * Copyright 2022 Frederick Schenk
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

public abstract class Backend.ClientList <T> : ListModel, Object {

  /**
   * Runs at construction of a new instance.
   */
  construct {
    store = new GenericArray <T> ();
  }

  /**
   * Returns the nth session in this list.
   *
   * @param position The position to look for.
   *
   * @return The session at the position, or null if position is invalid.
   */
  public Object? get_item (uint position) {
    return store.get (position) as Object;
  }

  /**
   * Get the number of sessions in this list.
   *
   * @return The number of sessions in this list.
   */
  public uint get_n_items () {
    return store.length;
  }

  /**
   * Returns the type of the objects this ListModel stores.
   *
   * @return The type for a base Session class.
   */
  public Type get_item_type () {
    return typeof (T);
  }

  /**
   * Adds an item to the list and the
   * associated access to the KeyStorage.
   *
   * @param item The item to be added.
   *
   * @throws Error Errors when adding the access token doesn't work.
   */
  internal void add (T item) throws Error {
    // Stop if item is already in list
    if (store.find (item)) {
      return;
    }

    // Add the item to the list
    store.add (item);

    try {
      add_access (item);
    } catch (Error e) {
      throw e;
    }

    // Note the changed list
    items_changed (store.length - 1, 0, 1);
  }

  /**
   * Adds the access for an item to the KeyStorage.
   *
   * @param item The item to be removed.
   *
   * @throws Error Errors when adding the access token doesn't work.
   */
  internal abstract void add_access (T item) throws Error;

  /**
   * Removes a item from the list and the
   * associated access token from the KeyStorage.
   *
   * @param item The item to be removed.
   *
   * @throws Error Errors when removing the access token doesn't work.
   */
  internal void remove (T item) throws Error {
    // Remove the session from the session list
    uint removed_position;
    if (! store.find (item, out removed_position)) {
      return;
    }

    // Remove the item
    store.remove (item);

    try {
      remove_access (item);
    } catch (Error e) {
      throw e;
    }

    // Note the changed list
    items_changed (removed_position, 1, 0);
  }

  /**
   * Removes the access for an item from the KeyStorage.
   *
   * @param item The item to be removed.
   *
   * @throws Error Errors when removing the access token doesn't work.
   */
  internal abstract void remove_access (T item) throws Error;

  /**
   * Stores the sessions internally.
   */
  private GenericArray <T> store;

}

/**
 * Provides a list of all sessions used by a Client.
 */
public class Backend.SessionList : ClientList <Session> {

  /**
   * Creates a new instance of SessionList.
   */
  internal SessionList () {
    Object ();
  }

  /**
   * Adds the access for an item from the KeyStorage.
   */
  internal override void add_access (Session item) throws Error {
    try {
      PlatformEnum platform = PlatformEnum.for_session (item);
      string token_label = @"Access Token for Account \"$(item.account.username)\" on $(platform)";
      KeyStorage.store_access (item.access_token, item.identifier, token_label);
    } catch (Error e) {
      throw e;
    }
  }

  /**
   * Removes the access for an item from the KeyStorage.
   */
  internal override void remove_access (Session item) throws Error {
    try {
      KeyStorage.remove_access (item.identifier);
    } catch (Error e) {
      throw e;
    }
  }

}

/**
 * Provides a list of all servers used by a Client.
 */
public class Backend.ServerList : ClientList <Server> {

  /**
   * Creates a new instance of ServerList.
   */
  internal ServerList () {
    Object ();
  }

  /**
   * Adds the access for an item from the KeyStorage.
   */
  internal override void add_access (Server item) throws Error {
    try {
      PlatformEnum platform = PlatformEnum.for_server (item);
      string token_label = @"Access Token for Server \"$(item.domain)\" on $(platform)";
      KeyStorage.store_access (item.client_key, @"ck_$(item.identifier)", token_label);
      string secret_label = @"Access Secret for Server \"$(item.domain)\" on $(platform)";
      KeyStorage.store_access (item.client_secret, @"cs_$(item.identifier)", secret_label);
    } catch (Error e) {
      throw e;
    }
  }

  /**
   * Removes the access for an item from the KeyStorage.
   */
  internal override void remove_access (Server item) throws Error {
    try {
      KeyStorage.remove_access (@"ck_$(item.identifier)");
      KeyStorage.remove_access (@"cs_$(item.identifier)");
    } catch (Error e) {
      throw e;
    }
  }

}

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

/**
 * Provides a list of all sessions used by a Client.
 */
public class Backend.SessionList : ListModel, Object {

  /**
   * Creates a new instance of SessionList.
   */
  internal SessionList () {
    Object ();
  }

  /**
   * Constructs a new instance of SessionList.
   */
  construct {
    store = new GenericArray <Session> ();
  }

  /**
   * Adds a session to the list.
   *
   * @param session The session to be added.
   */
  public void add_session (Session session) {
    // Stop if session already in list
    if (store.find (session)) {
      return;
    }

    // Add the session to the list
    store.add (session);

    // Note the changed list
    items_changed (store.length - 1, 0, 1);
  }

  /**
   * Removes a session from ClientState and
   * it's access token from the KeyStorage.
   *
   * @param session The session to be removed.
   *
   * @throws Error Errors when removing the access token.
   */
  public void remove_session (Session session) throws Error {
    // Remove the session from the session list
    uint removed_position;
    if (store.find (session, out removed_position)) {
      store.remove (session);
    }

    // Remove the access token of the session
    try {
      KeyStorage.remove_access (session.identifier);
    } catch (Error e) {
      throw e;
    }

    // Note the changed list
    items_changed (removed_position, 1, 0);
  }

  /**
   * Returns the nth session in this list.
   *
   * @param position The position to look for.
   *
   * @return The session at the position, or null if position is invalid.
   */
  public Object? get_item (uint position) {
    return store.get (position);
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
    return typeof (Session);
  }

  /**
   * Stores the sessions internally.
   */
  private GenericArray <Session> store;

}

/* ClientState.vala
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

/**
 * Stores all active sessions and servers, and allows
 * saving and loading client states from disk.
 */
[SingleInstance]
internal class Backend.ClientState : Object {

  /**
   * The global instance of ClientState.
   */
  private static ClientState instance {
    get {
      if (global_instance == null) {
        global_instance = new ClientState ();
      }
      return global_instance;
    }
  }

  /**
   * Run at construction of this object.
   */
  construct {
    active_servers = new GenericArray <Server> ();
    active_sessions = new GenericArray <Session> ();
  }

  /**
   * Adds a server to be managed by ClientState.
   *
   * @param server The server to be added.
   */
  public static void add_server (Server server) {
    // Avoid adding Twitter servers to the ClientState
    if (server is Twitter.Server) {
      error ("Twitter servers should not be added to ClientState!");
    }

    // Add the server if not already in array
    if (! instance.active_servers.find (server)) {
      instance.active_servers.add (server);
    }
  }

  /**
   * Adds a session to be managed by ClientState.
   *
   * @param session The session to be added.
   */
  public static void add_session (Session session) {
    // Add the session if not already in array
    if (! instance.active_sessions.find (session)) {
      instance.active_sessions.add (session);
    }
  }

  /**
   * Removes a server from ClientState.
   *
   * @param server The server to be removed.
   */
  public static void remove_server (Server server) {
    if (instance.active_servers.find (server)) {
      instance.active_servers.remove (server);
    }
  }

  /**
   * Removes a session from ClientState.
   *
   * @param session The session to be removed.
   */
  public static void remove_session (Session session) {
    if (instance.active_sessions.find (session)) {
      instance.active_sessions.remove (session);
    }
  }

  /**
   * Checks if an server is still needed.
   */
  private void check_servers () {
    uint[] used_servers = {};

    // Rule out all servers still used by a session
    foreach (Session session in active_sessions) {
      uint server_index;
      if (active_servers.find (session.server, out server_index)) {
        if (! (server_index in used_servers)) {
          used_servers += server_index;
        }
      }
    }

    // Remove all servers not used anymore
    for (uint i = 0; i < active_servers.length; i++) {
      if (! (i in used_servers)) {
        active_servers.remove_index (i);
      }
    }
  }

  /**
   * Stores all sessions managed by ClientState.
   */
  private GenericArray <Server> active_servers;

  /**
   * Stores all sessions managed by ClientState.
   */
  private GenericArray <Session> active_sessions;

  /**
   * Stores the global instance of ClientState.
   */
  private static ClientState? global_instance = null;

}

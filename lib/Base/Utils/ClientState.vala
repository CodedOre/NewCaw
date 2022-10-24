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
    active_sessions = new List<Session> ();
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

    unowned List list_check = instance.active_servers.find (server);
    if (list_check.length () == 0) {
      instance.active_servers.append (server);
    }
  }

  /**
   * Adds a session to be managed by ClientState.
   *
   * @param session The session to be added.
   */
  public static void add_session (Session session) {
    unowned List list_check = instance.active_sessions.find (session);
    if (list_check.length () == 0) {
      instance.active_sessions.append (session);
    }
  }

  /**
   * Removes a server from ClientState.
   *
   * @param server The server to be removed.
   */
  public static void remove_server (Server server) {
    unowned List list_check = instance.active_servers.find (server);
    if (list_check.length () != 0) {
      instance.active_servers.remove_all (server);
    }
  }

  /**
   * Removes a session from ClientState.
   *
   * @param session The session to be removed.
   */
  public static void remove_session (Session session) {
    unowned List list_check = instance.active_sessions.find (session);
    if (list_check.length () != 0) {
      instance.active_sessions.remove_all (session);
    }
  }

  /**
   * Checks if an server is still needed.
   */
  private void check_servers () {
    // Create a copy of the server list
    var open_servers = active_servers.copy ();

    // Rule out all servers still used by a session
    active_sessions.foreach ((session) => {
      unowned List list_check = active_servers.find (session.server);
      if (list_check.length () != 0) {
        open_servers.remove_all (session.server);
      }
    });

    // Remove all servers not used anymore
    open_servers.foreach ((server) => {
      remove_server (server);
    });
  }

  /**
   * Stores all sessions managed by ClientState.
   */
  private List<Server> active_servers;

  /**
   * Stores all sessions managed by ClientState.
   */
  private List<Session> active_sessions;

  /**
   * Stores the global instance of ClientState.
   */
  private static ClientState? global_instance = null;

}

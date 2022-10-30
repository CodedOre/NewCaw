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
    // Initialize the arrays
    active_servers = new GenericArray <Server> ();
    active_sessions = new GenericArray <Session> ();

    // Create cache dir if not already existing
    DirUtils.create_with_parents (state_path, 0750);
  }

  /**
   * Adds a server to be managed by ClientState.
   *
   * @param server The server to be added.
   */
  public static void add_server (Server server) {
#if SUPPORT_TWITTER
    // Avoid adding Twitter servers to the ClientState
    if (server is Twitter.Server) {
      error ("Twitter servers should not be added to ClientState!");
    }
#endif

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
   * Checks if an server for a given domain exists.
   *
   * @param domain The domain to check for.
   *
   * @returns A server if one exists for the domain, else null;
   */
  public static Server? find_server (string domain) {
    foreach (Server server in instance.active_servers) {
      if (server.domain == domain) {
        return server;
      }
    }
    return null;
  }

  /**
   * Removes a server from ClientState and
   * it's access token from the KeyStorage.
   *
   * @param server The server to be removed.
   */
  public static void remove_server (Server server) {
    // Remove the server the server list
    if (instance.active_servers.find (server)) {
      instance.active_servers.remove (server);
    }

    // Remove the access token of the session
    try {
      KeyStorage.remove_access (@"ck_$(server.identifier)");
      KeyStorage.remove_access (@"cs_$(server.identifier)");
    } catch (Error e) {
      throw e;
    }
  }

  /**
   * Removes a session from ClientState and
   * it's access token from the KeyStorage.
   *
   * @param session The session to be removed.
   *
   * @throws Error Errors while accessing the KeyStorage.
   */
  public static void remove_session (Session session) {
    // Remove the session from the session list
    if (instance.active_sessions.find (session)) {
      instance.active_sessions.remove (session);
    }

    // Remove the access token of the session
    try {
      KeyStorage.remove_access (session.identifier);
    } catch (Error e) {
      throw e;
    }
  }

  /**
   * Stores the ClientState to the state file.
   *
   * @throws Error Errors that might happen when accessing the KeyStorage or the state file.
   */
  public void store_state () throws Error {
    // Prepare to build the state variant
    var state_builder = new VariantBuilder (new VariantType ("a{sv}"));

    // Check for unused servers
    check_servers ();

    // Pack each server into the state variant
    var server_builder = new VariantBuilder (new VariantType ("av"));
    foreach (Server server in active_servers) {
      server_builder.add ("v", pack_server (server));
    }
    state_builder.add ("{sv}", "Servers", server_builder.end ());

    // Pack each session into the state variant
    var session_builder = new VariantBuilder (new VariantType ("av"));
    foreach (Session session in active_sessions) {
      session_builder.add ("v", pack_session (session));
    }
    state_builder.add ("{sv}", "Sessions", session_builder.end ());

    // Store the state variant in a file
    store_file (state_builder.end ());
  }

  /**
   * Prepares an Server to be saved to a state file.
   *
   * This packs the data relevant to restoring the server into a GVariant,
   * as well as storing the access token to the KeyStorage.
   *
   * @param server The server to be packed.
   *
   * @return A GVariant holding the information of server.
   *
   * @throws Error Errors when storing the access token does not work.
   */
  private Variant pack_server (Server server) throws Error {
    // Create the VariantBuilder and check the platform
    var state_builder = new VariantBuilder (new VariantType ("a{sms}"));
    var platform = PlatformEnum.for_server (server);

    // Store the access token
    try {
      string token_label = @"Access Token for Server \"$(server.domain)\" on $(platform)";
      KeyStorage.store_access (server.client_key, @"ck_$(server.identifier)", token_label);
      string secret_label = @"Access Secret for Server \"$(server.domain)\" on $(platform)";
      KeyStorage.store_access (server.client_secret, @"cs_$(server.identifier)", secret_label);
    } catch (Error e) {
      throw e;
    }

    // Add the data to the variant
    state_builder.add ("{sms}", "uuid", server.identifier);
    state_builder.add ("{sms}", "platform", platform.to_string ());
    state_builder.add ("{sms}", "domain", server.domain);

    // Return the created variant
    return state_builder.end ();
  }

  /**
   * Prepares an Session to be saved to a state file.
   *
   * This packs the data relevant to restoring the session into a GVariant,
   * as well as storing the access token to the KeyStorage.
   *
   * @param session The session to be packed.
   *
   * @return A GVariant holding the information of session.
   *
   * @throws Error Errors when storing the access token does not work.
   */
  private Variant pack_session (Session session) throws Error {
    // Create the VariantBuilder and check the platform
    var state_builder = new VariantBuilder (new VariantType ("a{sms}"));
    var platform = PlatformEnum.for_session (session);

    // Store the access token
    try {
      string token_label = @"Access Token for Account \"$(session.account.username)\" on $(platform)";
      KeyStorage.store_access (session.access_token, session.identifier, token_label);
    } catch (Error e) {
      throw e;
    }

    // Add the data to the variant
    state_builder.add ("{sms}", "uuid", session.identifier);
    state_builder.add ("{sms}", "platform", platform.to_string ());
    state_builder.add ("{sms}", "server_uuid", session.server.identifier);
    state_builder.add ("{sms}", "username", session.account.username);

    // Return the created variant
    return state_builder.end ();
  }

  /**
   * Stores a GVariant to the state file.
   *
   * @param The GVariant to be stored.
   *
   * @throws Error Errors while accessing the state file.
   */
  private void store_file (Variant variant) throws Error {
    // Initialize the file
    var file = File.new_build_filename (state_path, "state.gvariant", null);

    // Convert the variant to Bytes and store to file
    try {
      Bytes bytes = variant.get_data_as_bytes ();
      file.replace_contents (bytes.get_data (), null,
                             false, REPLACE_DESTINATION,
                             null, null);
    } catch (Error e) {
      throw e;
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
        var server = active_servers [i];
        remove_server (server);
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

  /**
   * The path to the directory holding the state storage.
   */
  private string state_path = Path.build_filename (Environment.get_user_data_dir (),
                                                   Client.instance.name,
                                                   null);

}

/* ClientState.vala
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
 */


/**
 * Errors that happened while loading or storing the ClientState.
 */
public errordomain Backend.StateError {

  /**
   * The data for a Server or Session was not usable to create a instance.
   */
  INVALID_DATA,

  /**
   * A instance for a Server or Session could not be created as the platform is not supported.
   */
  UNKNOWN_PLATFORM

}

/**
 * The client for utilizing this backend.
 *
 * This class provides information about the client to other methods of the
 * backend and provides methods to initialize and shutdown the backend during
 * an application run.
 *
 * Before using anything else from the backend, Client must be initialized.
 */
public partial class Backend.Client : Object {

  /**
   * Loads the ClientState from the state file.
   *
   * @throws Error Any error that might happen loading access token or state data.
   */
  public async void load_state () throws Error {
    // Load the state variant from the file
    Variant? state_variant;
    try {
      state_variant = Backend.Utils.StateIO.load_file (state_path, "state.gvariant");
    } catch (Error e) {
      throw e;
    }

    // Stop if no data was loaded
    if (state_variant == null) {
      return;
    }

    // Load the server data
    Variant stored_servers = state_variant.lookup_value ("Servers", null);
    VariantIter server_iter = stored_servers.iterator ();
    Variant server_variant;
    while (server_iter.next ("v", out server_variant)) {
      try {
        var server = unpack_server (server_variant);
        servers.add (server);
      } catch (Error e) {
        throw e;
      }
    }

    // Load the session data
    Variant stored_sessions = state_variant.lookup_value ("Sessions", null);
    VariantIter session_iter = stored_sessions.iterator ();
    Variant session_variant;
    while (session_iter.next ("v", out session_variant)) {
      try {
        var session = yield unpack_session (session_variant);
        sessions.add (session);
      } catch (Error e) {
        throw e;
      }
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
    foreach (Server server in servers) {
      server_builder.add ("v", pack_server (server));
    }
    state_builder.add ("{sv}", "Servers", server_builder.end ());

    // Pack each session into the state variant
    var session_builder = new VariantBuilder (new VariantType ("av"));
    foreach (Session session in sessions) {
      session_builder.add ("v", pack_session (session));
    }
    state_builder.add ("{sv}", "Sessions", session_builder.end ());

    // Store the state variant in a file
    Backend.Utils.StateIO.store_file (state_path, "state.gvariant", state_builder.end ());
  }

  /**
   * Creates a new Server from stored data.
   *
   * This loads the data from a GVariant and creates a
   * Server instance for the server, as well as
   * loading the access token for it.
   *
   * @param variant The variant from which to create the server.
   *
   * @return The newly created Server instance.
   *
   * @throws Error Errors when loading the access token does not work.
   */
  private Server unpack_server (Variant variant) throws Error {
    string? uuid_prop, platform_name, domain_prop,
            key_prop, secret_prop;
    PlatformEnum platform_prop;

    // Attempt to load the server data
    variant.lookup ("uuid", "ms", out uuid_prop);
    variant.lookup ("platform", "ms", out platform_name);
    variant.lookup ("domain", "ms", out domain_prop);
    platform_prop = PlatformEnum.from_name (platform_name);

    // Check that all data could be retrieved
    if (uuid_prop == null) {
      throw new StateError.INVALID_DATA ("No identifier given");
    }
    if (domain_prop == null) {
      throw new StateError.INVALID_DATA ("No domain given");
    }

    // Look up the access token for the instance
    try {
      key_prop = KeyStorage.retrieve_access (@"ck_$(uuid_prop)");
      secret_prop = KeyStorage.retrieve_access (@"cs_$(uuid_prop)");
    } catch (Error e) {
      throw e;
    }

    // Create a new Server instance from the data
    switch (platform_prop) {
#if SUPPORT_MASTODON
      case MASTODON:
        return new Mastodon.Server (uuid_prop, domain_prop, key_prop, secret_prop);
#endif

      default:
        throw new StateError.UNKNOWN_PLATFORM (@"Unknown platform \"$(platform_name)\"");
    }
  }

  /**
   * Creates a new Session from stored data.
   *
   * This loads the data from a GVariant and creates a
   * Session instance for the session, as well as
   * loading the access token for it.
   *
   * @param variant The variant from which to create the session.
   *
   * @return The newly created Session instance.
   *
   * @throws Error Errors when loading the access token does not work.
   */
  private async Session unpack_session (Variant variant) throws Error {
    string? uuid_prop, platform_name, server_prop,
            username_prop, access_prop;
    bool auto_start_prop;
    PlatformEnum platform_prop;

    // Attempt to load the server data
    Variant? uuid_variant, platform_name_variant, server_variant, username_variant, auto_start_variant;
    // Newer format `a{smv}`
    variant.lookup ("uuid", "mv", out uuid_variant);
    variant.lookup ("platform", "mv", out platform_name_variant);
    variant.lookup ("server_uuid", "mv", out server_variant);
    variant.lookup ("username", "mv", out username_variant);
    variant.lookup ("auto_start", "mv", out auto_start_variant);
    uuid_prop = uuid_variant.get_string();
    platform_name = platform_name_variant.get_string();
    server_prop = server_variant.get_string();
    username_prop = username_variant.get_string();
    auto_start_prop = auto_start_variant.get_boolean();
    platform_prop = PlatformEnum.from_name (platform_name);

    // Check that all data could be retrieved
    if (uuid_prop == null) {
      throw new StateError.INVALID_DATA ("No identifier given");
    }
    if (username_prop == null) {
      throw new StateError.INVALID_DATA ("No username given");
    }

    // Look up the access token for the instance
    try {
      access_prop = KeyStorage.retrieve_access (uuid_prop);
    } catch (Error e) {
      throw e;
    }

    // Look up the server for the session
    Server server = null;
    switch (platform_prop) {
#if SUPPORT_MASTODON
      case MASTODON:
        foreach (Server srv in servers) {
          if (srv.identifier == server_prop) {
            server = srv;
            break;
          }
        }
        break;
#endif

      default:
        throw new StateError.UNKNOWN_PLATFORM (@"Unknown platform \"$(platform_name)\"");
    }

    // Check that there is a valid server
    if (server == null) {
      throw new StateError.INVALID_DATA (@"Associated Server $(server_prop) can't be found for $(username_prop) on $(access_prop)");
    }

    // Return the created instance for the session
    return yield Session.from_data (uuid_prop, access_prop, server, auto_start_prop);
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
    var state_builder = new VariantBuilder (new VariantType ("a{smv}"));
    var platform = PlatformEnum.for_session (session);

    // Add the data to the variant
    state_builder.add ("{smv}", "uuid", new Variant.string(session.identifier));
    state_builder.add ("{smv}", "platform", new Variant.string(platform.to_string ()));
    state_builder.add ("{smv}", "server_uuid", new Variant.string(session.server.identifier));
    state_builder.add ("{smv}", "username", new Variant.string(session.account.username));
    state_builder.add ("{smv}", "auto_start", new Variant.boolean (session.auto_start));

    // Return the created variant
    return state_builder.end ();
  }

  public void register_session(Session session) throws Error {
    sessions.add (session);
    store_state ();
  }

  public void unregister_session(Session session) throws Error {
    sessions.remove (session);
    store_state ();
  }

  /**
   * Checks if an server is still needed.
   *
   * @throws Error Errors when removing a server.
   */
  private void check_servers () throws Error {
    uint[] used_servers = {};

    // Rule out all servers still used by a session
    foreach (Session session in sessions) {
      uint server_index;
      if (servers.find (session.server, out server_index)) {
        if (! (server_index in used_servers)) {
          used_servers += server_index;
        }
      }
    }

    // Remove all servers not used anymore
    for (uint i = servers.get_n_items (); i > 0; i--) {
      // Subtract one in the loop because we're dealing with unsigned ints
      // and so iterating the _actual_ index causes us to loop round to uint.max
      // or skip item 0, depending on conditions.
      uint idx = i - 1;
      if (! (idx in used_servers)) {
        var server = servers.get_item (idx) as Server;
        try {
          servers.remove (server);
        } catch (Error e) {
          throw e;
        }
      }
    }
  }

}

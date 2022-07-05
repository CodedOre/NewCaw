/* Session.vala
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
 * Loads and stores persistent states about accounts, servers and windows.
 */
[SingleInstance]
public class Session : Object {

  /**
   * Internal structure holding information about managed accounts.
   */
  private struct AccountData {

    /**
     * The UUID assigned in the storage.
     */
    string uuid;

    /**
     * The platform the account is on.
     */
    PlatformEnum platform;

    /**
     * The UUID for the server the account is located at.
     *
     * Can be null if the platform has a singular server (e.g. Twitter).
     */
    string? server_uuid;

    /**
     * The username of this account.
     */
    string username;

    /**
     * The object of this account.
     */
    Backend.Account data;

    /**
     * Create a AccountData instance from data loaded of the session file.
     *
     * This functions also loads the token and secret from the storage and
     * creates an authenticated Account object for the data variable.
     */
    public static async AccountData from_data (string       uuid_prop,
                                               PlatformEnum platform_prop,
                                               string       server_prop,
                                               string       username_prop,
                                               ServerData?  account_server) {
      // Create instance with known values
      var instance         = AccountData ();
      instance.uuid        = uuid_prop;
      instance.platform    = platform_prop;
      instance.server_uuid = server_prop;
      instance.username    = username_prop;
      try {
        // Load token from KeyStorage
        string account_token;
        yield KeyStorage.retrieve_account_access (instance.uuid, out account_token);
        // Create the account object and login
        switch (instance.platform) {
#if SUPPORT_MASTODON
          case MASTODON:
            var mastodon_server = account_server != null
                                    ? account_server.data as Backend.Mastodon.Server
                                    : null;
            if (mastodon_server != null) {
              instance.data = new Backend.Mastodon.Account (mastodon_server);
            } else {
              warning (@"Could not instance account \"$(instance.username)\": server instance missing!");
            }
            break;
#endif
#if SUPPORT_TWITTER
          case TWITTER:
            instance.data = new Backend.Twitter.Account ();
            break;
#endif
          default:
            assert_not_reached ();
        }
        instance.data.login (account_token);
        assert (instance.data != null);
      } catch (Error e) {
        warning (@"Failed to initialized account for \"$(instance.username)\": $(e.message)");
      }
      return instance;
    }

  }

  /**
   * Internal structure holding information about managed server.
   */
  private struct ServerData {

    /**
     * The UUID assigned in the storage.
     */
    string uuid;

    /**
     * The platform the server is on.
     */
    PlatformEnum platform;

    /**
     * The domain of this server.
     */
    string domain;

    /**
     * The object of this server.
     */
    Backend.Server data;

    /**
     * Create a ServerData instance from data loaded of the session file.
     *
     * This functions also loads the token and secret from the storage and
     * creates an authenticated Server object for the data variable.
     */
    public static async ServerData from_data (string uuid_prop, PlatformEnum platform_prop, string domain_prop) {
      // Create instance with known values
      var instance      = ServerData ();
      instance.uuid     = uuid_prop;
      instance.platform = platform_prop;
      instance.domain   = domain_prop;
      try {
        // Load token and secret from KeyStorage
        string server_token, server_secret;
        yield KeyStorage.retrieve_server_access (instance.uuid, out server_token, out server_secret);
        // Create Server object and store it in data
        instance.data = new Backend.Mastodon.Server (instance.domain, server_token, server_secret);
        assert (instance.data != null);
      } catch (Error e) {
        warning (@"Failed to initialized server for \"$(instance.domain)\": $(e.message)");
      }
      return instance;
    }

  }

  /**
   * The instance of this session.
   */
  public static Session instance {
    get {
      if (global_instance == null) {
        critical ("Session needs to be initialized before using it!");
      }
      return global_instance;
    }
  }

  /**
   * The application the session runs in.
   */
  public Gtk.Application application { get; construct; }

  /**
   * Runs at construction of the instance.
   */
  construct {
#if SUPPORT_TWITTER
    // Initializes the Twitter server.
    init_twitter_server ();
#endif

    // Initializes storage hashmaps
    accounts = new HashTable<string, AccountData?> (str_hash, str_equal);

    // Create data dir if not already existing
    var data_dir = Path.build_filename (Environment.get_user_data_dir (),
                                        Config.APPLICATION_ID,
                                        null);
    DirUtils.create_with_parents (data_dir, 0750);
  }

  /**
   * Creates a new instance of the session.
   *
   * @param application The Application this session runs in.
   */
  private Session (Gtk.Application application) {
    Object (
      application: application
    );
  }

  /**
   * Initializes the session.
   *
   * @param application The Application this session runs in.
   */
  public static void init (Gtk.Application application) {
    global_instance = new Session (application);
    instance.load_data.begin ();
  }

#if SUPPORT_TWITTER
  /**
   * Initializes the Server instance for the Twitter backend.
   */
  private void init_twitter_server () {
    // Look for override tokens
    var     settings      = new Settings ("uk.co.ibboard.Cawbird.experimental");
    string  custom_key    = settings.get_string ("twitter-oauth-key");

    // Determine oauth tokens
    string oauth_key = custom_key != ""
                         ? custom_key
                         : Config.TWITTER_OAUTH_KEY;

    // Initializes the server
    new Backend.Twitter.Server (oauth_key);
  }
#endif

  /**
   * Loads the data for the session.
   */
  private async void load_data () {
    // Notify application that we need it running
    application.hold ();

    // Load the data from the session file
    Variant     loaded_data     = yield load_from_file ();
    VariantIter data_iter       = loaded_data.iterator ();
    Variant     loaded_accounts = null;
    Variant     loaded_servers  = null;
    while (true) {
      // Iterate through loaded data
      Variant? iter_variant = data_iter.next_value ();
      if (iter_variant == null) {
        break;
      }

      // Store data variants according to the keys
      string key;
      iter_variant.get_child (0, "s", out key);
      switch (key) {
        case "Accounts":
          iter_variant.get_child (1, "v", out loaded_accounts);
          break;
        case "Servers":
          iter_variant.get_child (1, "v", out loaded_servers);
          break;
        default:
          warning ("Unrecognized category found in session file!");
          break;
      }
    }

    // Load server data from the data
    if (loaded_servers != null) {
      VariantIter server_iter = loaded_servers.iterator ();
      while (true) {
        // Iterate through loaded servers
        Variant? iter_variant = server_iter.next_value ();
        if (iter_variant == null) {
          break;
        }

        // Create ServerData and set the properties
        string?       uuid_prop     = null;
        PlatformEnum? platform_prop = null;
        string?       domain_prop   = null;
        VariantIter   prop_iter     = iter_variant.iterator ();
        while (true) {
          // Iterate through server properties
          Variant? prop_variant = prop_iter.next_value ();
          if (prop_variant == null) {
            break;
          }

          // Set the properties according to the keys
          string key;
          prop_variant.get_child (0, "s", out key);
          switch (key) {
            case "uuid":
              prop_variant.get_child (1, "s", out uuid_prop);
              break;
            case "platform":
              string platform_name;
              prop_variant.get_child (1, "s", out platform_name);
              platform_prop = PlatformEnum.from_name (platform_name);
              break;
            case "domain":
              prop_variant.get_child (1, "s", out domain_prop);
              break;
            default:
              warning ("Unrecognized server property in session file!");
              break;
          }

          // Create a new ServerData instance when all properties could be retrieved
          if (uuid_prop != null && platform_prop != null && domain_prop != null) {
            var server_data = yield ServerData.from_data (uuid_prop, platform_prop, domain_prop);
            servers [server_data.uuid] = server_data;
          } else {
            warning ("A server could not be loaded: Some data were missing!");
          }
        }
      }
    }

    // Load account data from the data
    if (loaded_accounts != null) {
      VariantIter account_iter = loaded_accounts.iterator ();
      while (true) {
        // Iterate through loaded accounts
        Variant? iter_variant = account_iter.next_value ();
        if (iter_variant == null) {
          break;
        }

        // Create AccountData and set the properties
        string?       uuid_prop     = null;
        PlatformEnum? platform_prop = null;
        string?       server_prop   = null;
        string?       username_prop = null;
        VariantIter   prop_iter     = iter_variant.iterator ();
        while (true) {
          // Iterate through server properties
          Variant? prop_variant = prop_iter.next_value ();
          if (prop_variant == null) {
            break;
          }

          // Set the properties according to the keys
          string key;
          prop_variant.get_child (0, "s", out key);
          switch (key) {
            case "uuid":
              prop_variant.get_child (1, "s", out uuid_prop);
              break;
            case "platform":
              string platform_name;
              prop_variant.get_child (1, "s", out platform_name);
              platform_prop = PlatformEnum.from_name (platform_name);
              break;
            case "server_uuid":
              prop_variant.get_child (1, "ms", out server_prop);
              break;
            case "username":
              prop_variant.get_child (1, "s", out username_prop);
              break;
            default:
              warning ("Unrecognized server property in session file!");
              break;
          }

          // Create a new ServerData instance when all properties could be retrieved
          if (uuid_prop != null && platform_prop != null && username_prop != null) {
            ServerData account_server = server_prop != null ? servers [server_prop] : null;
            var account_data = yield AccountData.from_data (uuid_prop, platform_prop, server_prop, username_prop, account_server);
            accounts [account_data.uuid] = account_data;
          } else {
            warning ("A server could not be loaded: Some data were missing!");
          }
        }
      }
    }

    // Decrease application use count from previous hold
    application.release ();
  }

  /**
   * Loads the data stored in the session file.
   *
   * @return A Variant holding the data from the file.
   */
  private async Variant? load_from_file () {
    // Initializes the file storing the session
    var file = File.new_build_filename (Environment.get_user_data_dir (),
                                        Config.APPLICATION_ID,
                                        "session.gvariant",
                                        null);

    Variant? stored_session;
    try {
      // Load the data from the file
      uint8[] file_content;
      string file_etag;
      yield file.load_contents_async (null, out file_content, out file_etag);
      // Convert the file data to an Variant and read the values from it
      var stored_bytes = new Bytes.take (file_content);
      stored_session   = new Variant.from_bytes (new VariantType ("{sv}"), stored_bytes, false);
    } catch (Error e) {
      // Don't put warning out if the file can't be found (expected error)
      if (! (e is IOError.NOT_FOUND)) {
        error (@"Session file could not be loaded properly: $(e.message)");
      }
      stored_session = null;
    }
    return stored_session;
  }

  /**
   * Stores the session data in the session file.
   *
   * @param variant The Variant holding the session data.
   */
  private async void store_to_file (Variant variant) {
    // Initializes the file storing the session
    var file = File.new_build_filename (Environment.get_user_data_dir (),
                                        Config.APPLICATION_ID,
                                        "session.gvariant",
                                        null);

    try {
      // Convert variant to Bytes and store them in file
      Bytes bytes = variant.get_data_as_bytes ();
      yield file.replace_contents_bytes_async (bytes, null,
                                               false, REPLACE_DESTINATION,
                                               null, null);
    } catch (Error e) {
      warning (@"Session could not be stored: $(e.message)");
    }
  }

  /**
   * Stores the global instance of this session.
   */
  private static Session? global_instance = null;

  /**
   * Stores accounts managed by the Session class.
   */
  private HashTable<string, AccountData?> accounts;

  /**
   * Stores servers managed by the Session class.
   */
  private HashTable<string, ServerData?> servers;

}

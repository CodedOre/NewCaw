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
    Variant stored_data = yield load_from_file ();



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

}

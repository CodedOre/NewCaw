/* Cawbird.vala
 *
 * Copyright 2021-2023 Frederick Schenk
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

public struct WindowAllocation {
  // It would be nice to have position as well, but apparently GTK4 doesn't support it
  // because some window managers don't support it
  public int width;
  public int height;
  public string? session_id;
}

/**
 * The application class, initializes the application.
 */
public class Cawbird : Adw.Application {

  /**
   * Property for the trailing tags setting.
   */
  protected bool trailing_tags_shown {
    get {
      return trailing_tags_shown_store;
    }
    set {
      Backend.Utils.TextFormats.set_format_flag (HIDE_TRAILING_TAGS, ! value);
      trailing_tags_shown_store = value;
    }
  }

  /**
  * All windows that are active or configured with this client, keyed by session ID
  */
  public HashTable<string, WindowAllocation?> window_allocations { get; private set; }

  /**
   * Local path to store config and app state in (variant files)
   */
  private string state_path;

  /**
   * Create the object.
   */
  public Cawbird () {
    Object (
      application_id: Config.APPLICATION_ID,
#if DEBUG
      resource_base_path: "/uk/co/ibboard/Cawbird/",
#endif
      flags: ApplicationFlags.HANDLES_OPEN
    );
    window_allocations = new HashTable<string, WindowAllocation?> (str_hash, str_equal);
    state_path = Path.build_filename (Environment.get_user_data_dir (), Config.PROJECT_NAME, null);
  }

  /**
   * Run at the construction of an object.
   */
  construct {
    // Define app actions
    ActionEntry[] action_entries = {
      { "about",       this.show_about_window },
      { "preferences", this.show_preferences_window },
      { "quit",        this.quit }
    };
    this.add_action_entries (action_entries, this);
    // Set keyboard shortcuts for these actions
    this.set_accels_for_action ("app.quit", {"<primary>q"});
    this.set_accels_for_action ("window.close", {"<primary>w"});

    // Bind text format options to gsettings
    var settings = new Settings ("uk.co.ibboard.Cawbird");
    settings.bind ("trailing-tags",
                   this, "trailing-tags-shown",
                   GLib.SettingsBindFlags.DEFAULT);
  }

  /**
   * Initialize the client and open the first window.
   */
  protected override void activate () {
    DirUtils.create_with_parents (state_path, 0750);
    Backend.Client client = new Backend.Client(Config.APPLICATION_ID,
                                               Config.PROJECT_NAME,
                                               "https://github.com/CodedOre/NewCaw",
                                               "cawbird://authenticate",
                                               state_path);

    // Load the previous program state
    this.hold ();
    client.load_state.begin ((obj, res) => {
      try {
        client.load_state.end (res);
        Preferences.WindowManagement.load_state.begin (state_path, (obj, res) => {
          try {
            List<WindowAllocation?> stored_allocations = Preferences.WindowManagement.load_state.end (res);
            foreach (WindowAllocation window_allocation in stored_allocations) {
              window_allocations[window_allocation.session_id] = window_allocation;
            }

            if (client.sessions.get_n_items () > 0) {
              bool opened_window = false;
              foreach (Backend.Session session in client.sessions) {
                if (session.auto_start) {
                  opened_window = true;
                  var window = new MainWindow (this, session);
                  window.present ();
                }
              }
              if (!opened_window) {
                // If nothing opened automatically, show the first session
                var window = new MainWindow(this, client.sessions.get_item(0) as Backend.Session);
                window.present();
              }
            } else {
              var window = new MainWindow (this, null);
              window.present ();
            }
          } catch (Error e) {
            critical (@"Failed to load window state: $(e.message)");
          } finally {
            this.release ();
          }
        });
      } catch (Error e) {
        critical (@"Failed to load program state: $(e.message)");
        this.release ();
      }
    });
  }

  internal void register_window (MainWindow window) {
    string? session_id = window.session == null ? null : window.session.identifier;
    if (session_id != null && window_allocations.contains (session_id)) {
      WindowAllocation? window_allocation = window_allocations.get(session_id);
      window.default_width = window_allocation.width;
      window.default_height = window_allocation.height;
    }
    window.close_request.connect(update_window_allocation);
  }

  private bool update_window_allocation(Gtk.Window window) {
    if (!(window is MainWindow)) {
      return false;
    }

    MainWindow main_window = window as MainWindow;

    if (main_window.session != null) {
      string session_id = main_window.session.identifier;
      Gtk.Allocation allocation;
      main_window.get_allocation (out allocation);
      window_allocations[session_id] = WindowAllocation() {
        width=allocation.width,
        height=allocation.height,
        session_id=session_id
      };
    }
    return false;
  }

  /**
   * Handles files and links given to the app.
   *
   * @param files An array of "files" to be opened.
   */
  protected override void open (File[] files, string hint) {
    foreach (File file in files) {
      // Get the uri for the file
      string uri = file.get_uri ();

      // Check the type of uri
      if (uri.has_prefix ("cawbird://")) {
        // Application uri are limited to one on each call
        if (files.length > 1) {
          error ("Not allowed to pass multiple cawbird:// uris at once.");
        }
        on_cawbird_uri (uri);
      } else {
        warning (@"$(uri) can't be opened by Cawbird.");
      }
    }
  }

  /**
   * Run when a cawbird uri was opened.
   *
   * @param uri The uri given by open.
   */
  private void on_cawbird_uri (string uri) {
    // Parse the uri
    try {
      HashTable <string,string> uri_param;
      var data  = Uri.parse (uri, NONE);
      uri_param = Uri.parse_params (data.get_query ());

      switch (data.get_host ()) {
        case "authenticate":
          string? state = uri_param ["state"];
          string? code  = uri_param ["code"];
          if (state != null && code != null) {
            Backend.Client.instance.auth_callback (state, code);
          } else {
            warning ("Failed to get authentication secrets from callback.");
          }
          break;
        default:
          warning (@"$(uri) is a invalid cawbird uri.");
          break;
      }
    } catch (Error e) {
      error (@"Failed to parse $(uri): $(e.message)");
    }
  }

  /**
   * Run when the program is closed.
   */
  protected override void shutdown () {
    try {
      Backend.Client.instance.store_state ();
      // We don't seem to be able to use `get_values()` directly because of weak vs unowned type differences
      List<WindowAllocation?> allocations_to_store = new List<WindowAllocation?> ();
      foreach (WindowAllocation window_allocation in window_allocations.get_values ()) {
        allocations_to_store.append (window_allocation);
      }
      Preferences.WindowManagement.store_state (state_path, allocations_to_store);
    } catch (Error e) {
      error (@"Failed to store program state: $(e.message)");
    } finally {
      Backend.Client.instance.shutdown ();
      base.shutdown ();
    }
  }

  /**
   * Displays an AboutWindow for the application.
   *
   * Activated by the action "app.about".
   */
  private void show_about_window () {
    // Create the About Window
    var about_window = new Adw.AboutWindow () {
      // Information on the main page
      application_name = Config.PROJECT_NAME,
      application_icon = Config.APPLICATION_ID,
      version          = Config.PROJECT_VERSION,

      // Information on the details page
      website = "https://ibboard.co.uk/cawbird",

      // Information on the credits page
      developers = {
        "Frederick Schenk https://github.com/CodedOre",
        "IBBoard"
      },
      designers = {
        "Frederick Schenk https://github.com/CodedOre",
        "The GNOME Design Team"
      },
      artists = {
        "Micah Ilbery (Application Icon)"
      },
      translator_credits = _("Translators: Add your name here!"),

      // Information on the legal page
      copyright    = "© 2022, The Cawbird Developers",
      license_type = GPL_3_0,

      // Information on the debug page
      issue_url           = "https://github.com/CodedOre/NewCaw/issues/new",
      debug_info          = SystemInfo.display_info (),
      debug_info_filename = "cawbird-debug-info.txt",

      // Connect to the active window
      transient_for = this.active_window
    };

    // Add an credit for Corebird
    about_window.add_credit_section (
      _("Based on Corebird, created by"),
      { "Timm Bäder" }
    );

#if DEBUG
    // Add development style in debug
    about_window.add_css_class ("devel");
#endif

    // Display the AboutWindow
    about_window.present ();
  }

  /**
   * Displays an PreferencesWindow for the application.
   *
   * Activated by the action "app.preferences".
   */
  private void show_preferences_window () {
    var window = new PreferencesWindow () {
      transient_for = this.active_window
    };
    window.present ();
  }

  /**
   * The main method.
   */
  public static int main (string[] args) {
    // Setup gettext
    GLib.Intl.setlocale (GLib.LocaleCategory.ALL, "");
    GLib.Intl.bindtextdomain (Config.PROJECT_NAME, Config.LOCALEDIR);
    GLib.Intl.bind_textdomain_codeset (Config.PROJECT_NAME, "UTF-8");
    GLib.Intl.textdomain (Config.PROJECT_NAME);

    // Run the app
    return new Cawbird ().run (args);
  }

  /**
   * Stores the trailing tags setting.
   */
  private bool trailing_tags_shown_store;
}

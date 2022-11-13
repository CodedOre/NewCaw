/* Cawbird.vala
 *
 * Copyright 2021-2022 Frederick Schenk
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
   * Property for the internal links setting.
   */
  protected bool internal_links_shown {
    get {
      return internal_links_shown_store;
    }
    set {
      internal_links_shown_store = value;
      Backend.Utils.TextFormats.set_format_flag (SHOW_QUOTE_LINKS, value);
      Backend.Utils.TextFormats.set_format_flag (SHOW_MEDIA_LINKS, value);
    }
  }

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
    settings.bind ("internal-links",
                   this, "internal-links-shown",
                   GLib.SettingsBindFlags.DEFAULT);
  }

  /**
   * Initialize the client and open the first window.
   */
  protected override void activate () {
    // Initializes the backend client
    var client = new Backend.Client (Config.PROJECT_NAME,
                                     "https://github.com/CodedOre/NewCaw",
                                     "cawbird://authenticate");

    // Load the previous program state
    this.hold ();
    client.load_state.begin ((obj, res) => {
      try {
        client.load_state.end (res);

        // TODO: Reindroduce selected windows
        if (client.sessions.get_n_items () > 0) {
          foreach (Backend.Session session in client.sessions) {
            var window = new MainWindow (this, session);
            window.present ();
          }
        } else {
          var window = new MainWindow (this, null);
          window.present ();
        }
      } catch (Error e) {
        critical (@"Failed to load program state: $(e.message)");
      } finally {
        this.release ();
      }
    });
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
            // Session.instance.auth_callback (state, code);
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

  /**
   * Stores the internal links setting.
   */
  private bool internal_links_shown_store;

}

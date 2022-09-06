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
   * Create the object.
   */
  public Cawbird () {
    Object (application_id: Config.APPLICATION_ID, flags: ApplicationFlags.HANDLES_OPEN);
#if DEBUG
    set_resource_base_path ("/uk/co/ibboard/Cawbird/");
#endif
  }

  /**
   * Run at the construction of an object.
   */
  construct {
    // Define app actions
    ActionEntry[] action_entries = {
      { "about", this.show_about_window },
      { "quit",  this.quit }
    };
    this.add_action_entries (action_entries, this);
    // Set keyboard shortcuts for these actions
    this.set_accels_for_action ("app.quit", {"<primary>q"});
  }

  /**
   * Initialize the client and open the first window.
   */
  protected override void activate () {
    // Initializes the backend client
    new Backend.Client (Config.PROJECT_NAME, "https://github.com/CodedOre/NewCaw", "cawbird://authenticate");

    // Load the session
    Session.init (this);
    Session.load_session ();
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
            Session.instance.auth_callback (state, code);
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
    Backend.Client.instance.shutdown ();
    Session.store_session ();
    base.shutdown ();
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

    // Display the AboutWindow
    about_window.present ();
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

}

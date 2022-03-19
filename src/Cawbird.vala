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
 * The application class, contains initialization methods.
 */
public class Cawbird : Adw.Application {

  /**
   * Creates the object.
   */
  public Cawbird () {
#if DEBUG
    Object (application_id: "uk.co.ibboard.Cawbird.Devel", flags: ApplicationFlags.HANDLES_OPEN);
    set_resource_base_path ("/uk/co/ibboard/Cawbird/");
#else
    Object (application_id: "uk.co.ibboard.Cawbird", flags: ApplicationFlags.HANDLES_OPEN);
#endif
  }

  /**
   * Starting without arguments.
   */
  protected override void activate () {
    // Initializes the backend client
    new Backend.Client ("NewCaw Development", "https://github.com/CodedOre/NewCaw", "cawbird://authenticate");

    // Initialize the AccoutManager
    AccountManager.init ();

    // Open the MainWindow
    var win = this.active_window;
    if (win == null) {
      win = new MainWindow (this);
    }
    win.present ();
  }

  /**
   * Handles given links.
   */
	public override void open (File[] links, string hint) {
    // Check each given link
		foreach (File link in links) {
			string uri = link.get_uri ();

			// When authentication uri
			if (uri.has_prefix ("cawbird://authenticate")) {
			  try {
			    // Get query of authentication string
          var auth = Uri.parse (uri, NONE);

          // Send query to AccountManager
          AccountManager.instance.auth_received (auth.get_query ());
        } catch (Error e) {
          error (@"Failed to get authentication url: $(e.message)");
        }

      // When unsupported uri
			} else {
			  error (@"$(uri) is an unsupported uri!");
			}
		}
	}

  /**
   * The begin of the program.
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

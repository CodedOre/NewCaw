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
    Object (application_id: Config.APPLICATION_ID);
#if DEBUG
    set_resource_base_path ("/uk/co/ibboard/Cawbird/");
#endif
  }

  /**
   * Initialize the client and open the first window.
   */
  protected override void activate () {
    // Initializes the backend client
    new Backend.Client ("NewCaw Development", "https://github.com/CodedOre/NewCaw");

    // Initialize the AccoutManager
    AccountManager.init ();

    // Open the InitWindow
    var win = this.active_window;
    if (win == null) {
      win = new InitWindow (this);
    }
    win.present ();

    // Load existing accounts or open AuthView
    var init = win as InitWindow;
    if (init != null) {
      init.load_accounts.begin ();
    } else {
      error ("InitWindow could not been initialized!");
    }
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

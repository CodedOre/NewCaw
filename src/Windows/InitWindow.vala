/* InitWindow.vala
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
 * First window to open, shows a loading screen.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Windows/InitWindow.ui")]
public class InitWindow : Adw.ApplicationWindow {

  /**
   * Initializes a InitWindow.
   *
   * @param app The Gtk.Application for this window.
   */
  public InitWindow (Gtk.Application app) {
    // Initializes the Object
    Object (application: app);
  }

  /**
   * Load the data and create windows for it.
   */
  public async void load_accounts () {
    // Load potentially stored accounts
    yield Session.load_data ();
    yield Session.store_data ();

    // Check if accounts are stored
    Backend.Account[] accounts = Session.get_accounts ();
    if (accounts.length != 0) {
      foreach (Backend.Account acc in accounts) {
        // Create a MainWindow for stored accounts
        var win = new MainWindow (application, acc);
        win.present ();
      }
    } else {
      // Create MainWindow with AuthView
      var win = new MainWindow (application);
      win.present ();
    }

    // Remove this window
    this.destroy ();
  }

}

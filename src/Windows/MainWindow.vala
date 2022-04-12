/* MainWindow.vala
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

/**
 * The main window of the application, also responsible for new windows.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Windows/MainWindow.ui")]
public class MainWindow : Adw.ApplicationWindow {

  // UI-Elements of MainWindow
  [GtkChild]
  private unowned Adw.Leaflet leaflet;

  /**
   * The account currently displayed in this window.
   */
  public Backend.Account account {
    get {
      return displayed_account;
    }
    construct set {
      // Set the new account
      displayed_account = value;

      // Display set account
      if (displayed_account != null) {
        var user_view = new UserView ();
        leaflet.append (user_view);
        user_view.user = displayed_account;
        leaflet.set_visible_child (user_view);
      }
    }
  }

  /**
   * Initializes a MainWindow.
   *
   * @param app The Gtk.Application for this window.
   * @param account The account to be assigned to this window, or null for an AuthView.
   */
  public MainWindow (Gtk.Application app, Backend.Account? account = null) {
    // Initializes the Object
    Object (
      application: app,
      account:     account
    );

    // Check if account was assigned
    if (account == null) {
      // Create AuthView
      var auth = new AuthView ();

      // Close Window when authentication is cancelled
      auth.auth_cancelled.connect (() => {
        this.close ();
      });

      // Set new account when authentication is complete
      auth.auth_complete.connect (() => {
        this.account = auth.account;
        leaflet.remove (auth);
      });

      // Display AuthView
      leaflet.append (auth);
      leaflet.set_visible_child (auth);
    }

#if DEBUG
    // Add development style in debug
    this.add_css_class ("devel");
#endif
  }

  /**
   * Holds the displayed account.
   */
  private Backend.Account displayed_account;

}

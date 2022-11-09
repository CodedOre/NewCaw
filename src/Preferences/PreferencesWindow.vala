/* PreferencesWindow.vala
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
 * Display settable preferences to the user.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Preferences/PreferencesWindow.ui")]
public class PreferencesWindow : Adw.PreferencesWindow {

#if DEBUG
  /**
   * Run at construction of an window.
   */
  construct {
    // Add development style in debug
    add_css_class ("devel");
  }
#endif

  /**
   * Run at initialization of the class.
   */
  class construct {
    // Set up a action to close a sub-page
    install_action ("preferences.close-subpage", null, (widget, action) => {
      var window = widget as PreferencesWindow;
      window.close_subpage ();
    });
    // Set up the session actions
    install_action ("preferences.add-session", null, (widget, action) => {
      var window = widget as PreferencesWindow;
      if (window != null) {
        var auth_view = new AuthView ();
        window.present_subpage (auth_view);
        auth_view.close_auth.connect (() => {
          window.close_subpage ();
        });
      }
    });
  }

  /**
   * Displays an Session in a SessionSettings subview.
   *
   * @param session The session to be displayed.
   */
  public void display_session_settings (Backend.Session session) {
    var settings_view     = new Preferences.SessionSettings ();
    settings_view.session = session;
    this.present_subpage (settings_view);
  }

}

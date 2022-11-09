/* SessionsPage.vala
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
 * Lists all authenticated sessions and allows to change them.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Preferences/SessionsPage.ui")]
public class Preferences.SessionsPage : Adw.PreferencesPage {

  // UI-Elements of SessionsPage
  [GtkChild]
  private unowned Gtk.ListBox session_list;

  /**
   * Run at construction of the page.
   */
  construct {
    session_list.bind_model (Backend.Client.instance.sessions, bind_session);
  }

  /**
   * Activated when one of the listed sessions was activated.
   *
   * @param widget The widget that was clicked in the session list.
   */
  [GtkCallback]
  private void display_session_settings (Gtk.ListBoxRow widget) {
    // Get the SessionRow
    var session_row = widget as SessionRow;
    if (session_row == null) {
      warning ("Activated row is not SessionRow!");
      return;
    }

    // Get the PreferencesWindow
    var pref_window = this.get_root () as PreferencesWindow;
    if (pref_window == null) {
      warning ("SessionsPage not in a PreferencesWindow, action not possible!");
      return;
    }

    // Open the new subview
    pref_window.display_session_settings (session_row.session);
  }

  /**
   * Binds an session to an SessionRow in the session list.
   */
  private Gtk.Widget bind_session (Object item) {
    var session         = item as Backend.Session;
    var widget          = new SessionRow ();
    widget.show_actions = false;
    widget.show_next    = true;
    widget.session      = session;
    return widget;
  }

}

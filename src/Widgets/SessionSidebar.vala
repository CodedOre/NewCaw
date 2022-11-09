/* SessionSidebar.vala
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
 * Allows to change an account and displays related views for MainPage.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Widgets/SessionSidebar.ui")]
public class SessionSidebar : Gtk.Widget {

  // UI-Elements of SessionSidebar
  [GtkChild]
  private unowned Gtk.ListBox active_list;
  [GtkChild]
  private unowned Gtk.Separator sidebar_separator;
  [GtkChild]
  private unowned Gtk.ListBox session_list;

  /**
   * The currently active session.
   */
  public Backend.Session active_session {
    get {
      return stored_active_session;
    }
    set {
      stored_active_session = value;

      // Iterate through the session list
      int i = 0;
      while (true) {
        var row = session_list.get_row_at_index (i);
        if (row == null) {
          break;
        }
        var session_row = row as SessionRow;
        // Hide the row displaying the current session
        session_row.visible = session_row.session != stored_active_session;
        i++;
      }
    }
  }

  /**
   * Run at construction of an widget.
   */
  construct {
    session_list.bind_model (Backend.Client.instance.sessions, bind_session);
  }

  /**
   * Display the account of the current session.
   */
  [GtkCallback]
  private void display_session_account () {
    // Get the MainWindow
    var main_window = this.get_root () as MainWindow;
    if (main_window == null) {
      warning ("SessionSidebar not in a MainWindow, action not possible!");
      return;
    }

    // Display the user if not null
    if (active_session != null) {
      main_window.display_user (active_session.account);
    }
  }

  /**
   * Changes the sessions when one was selected in the sidebar.
   *
   * @param widget The widget that was clicked in the session list.
   */
  [GtkCallback]
  private void change_active_session (Gtk.ListBoxRow widget) {
    // Get the SessionRow
    var session_row = widget as SessionRow;
    if (session_row == null) {
      warning ("Activated row is not SessionRow!");
      return;
    }

    // Get the MainWindow
    var main_window = this.get_root () as MainWindow;
    if (main_window == null) {
      warning ("SessionSidebar not in a MainWindow, action not possible!");
      return;
    }

    // Set the new account
    if (session_row.session != null) {
      main_window.session = session_row.session;
    }
  }

  /**
   * Binds an session to an SessionRow in the session list.
   */
  private Gtk.Widget bind_session (Object item) {
    var session    = item as Backend.Session;
    var widget     = new SessionRow ();
    widget.session = session;
    return widget;
  }

  /**
   * Deconstructs SessionSidebar and it's childrens.
   */
  public override void dispose () {
    // Destructs children of SessionSidebar
    active_list.unparent ();
    sidebar_separator.unparent ();
    session_list.unparent ();
    base.dispose ();
  }

  /**
   * Stores the active session in the sidebar.
   */
  private Backend.Session? stored_active_session;

}

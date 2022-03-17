/* ServerPage.vala
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
 * The first page for the authentication process.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/System/Authentication/ServerPage.ui")]
public class Authentication.ServerPage : Gtk.Widget {

  // UI-Elements of ServerPage
  [GtkChild]
  private unowned Adw.Clamp page_content;
  [GtkChild]
  private unowned Gtk.Entry server_entry;
  [GtkChild]
  private unowned WaitingButton button_waiting;

  /**
   * The AuthView holding this page.
   */
  public weak AuthView view { get; construct; }

  /**
   * Run at construction of the widget.
   */
  construct {
    // Check if children of AuthView
    if (view == null) {
      critical ("Can only be children to AuthView!");
    }
  }

  /**
   * Activated when back button is activated.
   */
  public void on_back_action () {
    // Stop server authentication
    stop_server_auth ();
    // Move back to the start page
    view.back_to_start ();
  }

  /**
   * Set's the UI to waiting during an action.
   */
  private void set_waiting (bool waiting) {
    button_waiting.waiting = waiting;
    server_entry.sensitive = ! waiting;
  }

  /**
   * Activated by the confirm button.
   */
  [GtkCallback]
  private void on_confirm () {
    // Check if authentication is already running
    if (button_waiting.waiting) {
      // Stop authentication
      stop_server_auth ();
    } else {
      // Begin authentication
      begin_server_auth ();
    }
  }

  /**
   * Begin the server authentication.
   */
  private void begin_server_auth () {
    // Block the UI
    set_waiting (true);
  }

  /**
   * Stops the server authentication.
   */
  private void stop_server_auth () {
    // Cancel async actions
    view.cancellable.cancel ();

    // Unblock the UI
    set_waiting (false);
  }

  /**
   * Deconstructs ServerPage and it's childrens.
   */
  public override void dispose () {
    // Deconstruct childrens
    page_content.unparent ();
  }

}

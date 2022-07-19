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
 * The page for setting an Mastodon server.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/System/Authentication/ServerPage.ui")]
public class Authentication.ServerPage : Gtk.Widget {

  // UI-Elements of ServerPage
  [GtkChild]
  private unowned Adw.ToastOverlay page_content;
  [GtkChild]
  private unowned Adw.EntryRow server_entry;
  [GtkChild]
  private unowned Gtk.Button confirm_button;
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

    // Connect server auth stop
    view.moving_back.connect (clear_page);
  }

  /**
   * Set's the UI to waiting during an action.
   *
   * @param waiting If the UI should be waiting.
   */
  private void set_waiting (bool waiting) {
    button_waiting.waiting = waiting;
    server_entry.editable  = ! waiting;
  }

  /**
   * Display a warning to the user.
   *
   * @param warning The warning text to display, or null to remove one.
   */
  private void set_warning (string? warning_text = null) {
    if (warning_text == null) {
      // Remove the warning
      if (server_entry.has_css_class ("warning")) {
        server_entry.remove_css_class ("warning");
      }
      if (status_toast != null) {
        status_toast.dismiss ();
        status_toast = null;
      }
    } else {
      // Add the warning
      if (! server_entry.has_css_class ("warning")) {
        server_entry.add_css_class ("warning");
      }
      if (status_toast != null) {
        status_toast.dismiss ();
      }
      status_toast = new Adw.Toast (warning_text);
      page_content.add_toast (status_toast);
    }
  }

  /**
   * Display a error to the user.
   *
   * @param error The error text to display, or null to remove one.
   */
  private void set_error (string? error_text = null) {
    if (error_text == null) {
      // Remove the error
      if (server_entry.has_css_class ("error")) {
        server_entry.remove_css_class ("error");
      }
      if (status_toast != null) {
        status_toast.dismiss ();
        status_toast = null;
      }
    } else {
      // Add the error
      if (! server_entry.has_css_class ("error")) {
        server_entry.add_css_class ("error");
      }
      if (status_toast != null) {
        status_toast.dismiss ();
      }
      status_toast = new Adw.Toast (error_text);
      page_content.add_toast (status_toast);
    }
  }

  /**
   * Activated by input on the server entry.
   */
  [GtkCallback]
  private void on_input () {
    // Clear possible warnings or errors
    set_warning ();
    set_error ();

    // Only activate the button when there's text
    if (server_entry.text == "") {
      if (confirm_button.has_css_class ("suggested-action")) {
        confirm_button.remove_css_class ("suggested-action");
      }
      confirm_button.sensitive = false;
    } else {
      if (! confirm_button.has_css_class ("suggested-action")) {
        confirm_button.add_css_class ("suggested-action");
      }
      confirm_button.sensitive = true;
    }
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
      // Block the UI
      set_waiting (true);

      // Begin authentication
      run_server_auth.begin ();
    }
  }

  /**
   * Clears the UI when moving back.
   */
  private void clear_page () {
    // Stop authentication
    stop_server_auth ();

    // Reset input and warnings
    server_entry.text = "";
    set_warning (null);
    set_error (null);
  }

  /**
   * Runs the server authentication.
   */
  private async void run_server_auth () {
#if SUPPORT_MASTODON
    // Get domain and strip protocol
    string domain = server_entry.text;
    if (domain.length == 0) {
      set_warning (_("No domain set!"));
      stop_server_auth ();
      return;
    }
    domain = domain.replace ("http://", "");
    domain = domain.replace ("https://", "");

    // Look existing servers up
    Backend.Mastodon.Server? server = Session.find_server (domain) as Backend.Mastodon.Server;

    // Create the server if not already existing
    if (server == null) {
      try {
        cancel_auth = new Cancellable ();
        view.server = yield new Backend.Mastodon.Server.authenticate (domain, cancel_auth);
        server      = view.server;
      } catch (Error e) {
        if (! (e is GLib.IOError.CANCELLED)) {
          warning (@"Could not find server $(domain): $(e.message)");
          set_error (_("Could not find server."));
        }
        stop_server_auth ();
        return;
      }
    }

    // Begin authentication
    try {
      view.account = new Backend.Mastodon.Account (server);
      string auth_url = yield view.account.init_authentication ();
      Gtk.show_uri (null, auth_url, Gdk.CURRENT_TIME);
      stop_server_auth ();
      view.move_to_next ();
    } catch (Error e) {
      if (! (e is GLib.IOError.CANCELLED)) {
        warning (@"Could not authenticate at server $(domain): $(e.message)");
        set_error (_("Could not authenticate at server."));
      }
      stop_server_auth ();
      return;
    }
#else
    // Error if no Mastodon backend available
    set_error (_("Why are you even here? There is no Mastodon backend!"));
    stop_server_auth ();
#endif
  }

  /**
   * Stops the server authentication.
   */
  private void stop_server_auth () {
    // Cancel possible actions
    if (cancel_auth != null) {
      cancel_auth.cancel ();
    }

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

  /**
   * Cancels server authentications.
   */
  private Cancellable? cancel_auth = null;

  /**
   * A Adw.Toast displaying status messages.
   */
  private Adw.Toast? status_toast = null;

}

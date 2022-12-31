/* CodePage.vala
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
 * The page to enter the authentication code.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Authentication/CodePage.ui")]
public class Authentication.CodePage : Gtk.Widget {

  // UI-Elements of CodePage
  [GtkChild]
  private unowned Adw.ToastOverlay page_content;
  [GtkChild]
  private unowned Adw.EntryRow code_entry;
  [GtkChild]
  private unowned Gtk.Button confirm_button;
  [GtkChild]
  private unowned WaitingButton button_waiting;

  /**
   * The AuthView holding this page.
   */
  public weak AuthView view { get; construct; }

  /**
   * The LoadPage displayed after this page.
   */
  public weak LoadPage loader { get; protected set; }

  /**
   * Run at construction of the widget.
   */
  construct {
    // Check if children of AuthView
    if (view == null) {
      critical ("Can only be children to AuthView!");
    }

    // Connect auth stop
    view.moving_back.connect (clear_page);
  }

  /**
   * Set's the UI to waiting during an action.
   *
   * @param waiting If the UI should be waiting.
   */
  private void set_waiting (bool waiting) {
    button_waiting.waiting = waiting;
    code_entry.editable    = ! waiting;
  }

  /**
   * Display a warning to the user.
   *
   * @param warning The warning text to display, or null to remove one.
   */
  private void set_warning (string? warning_text = null) {
    // Reset any existing status toast
    if (status_toast != null) {
      status_toast.dismiss ();
      status_toast = null;
    }

    // Apply css to widgets
    DisplayUtils.conditional_css (warning_text != null, code_entry, "warning");

    // Add new toast if a warning exists
    if (warning_text != null) {
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
    // Reset any existing status toast
    if (status_toast != null) {
      status_toast.dismiss ();
      status_toast = null;
    }

    // Apply css to widgets
    DisplayUtils.conditional_css (error_text != null, code_entry, "error");

    // Add new toast if a warning exists
    if (error_text != null) {
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
    set_warning (null);
    set_error (null);

    // Only activate the button when there's text
    confirm_button.sensitive = code_entry.text != "";
    DisplayUtils.conditional_css (code_entry.text != "", code_entry, "suggested-action");
  }

  /**
   * Activated by the confirm button.
   */
  [GtkCallback]
  private void on_confirm () {
    // Check if authentication is already running
    if (button_waiting.waiting) {
      // Stop authentication
      stop_code_auth ();
    } else {
      // Block the UI
      set_waiting (true);

      // Begin authentication
      run_code_auth.begin ();
    }
  }

  /**
   * Runs the authentication.
   */
  private async void run_code_auth () {
    // Get authentication code
    string code = code_entry.text;
    if (code.length == 0) {
      set_warning (_("No code set!"));
      stop_code_auth ();
      return;
    }

    // Run authentication
    try {
      view.account = yield view.auth.authenticate (code);
    } catch (Error e) {
      if (! (e is GLib.IOError.CANCELLED)) {
        warning (@"Authentication failed: $(e.message)");
        set_error (_("Authentication failed."));
      }
      stop_code_auth ();
      return;
    }

    // Move to the final page and init loading
    view.move_to_next ();

    // Initialize loading
    if (loader == null) {
      critical ("Need a following LoadPage!");
    }
    loader.begin_loading ();
  }

  /**
   * Clears the UI when moving back.
   */
  private void clear_page () {
    // Stop authentication
    stop_code_auth ();

    // Reset input and warnings
    code_entry.text = "";
    set_warning (null);
    set_error (null);
  }

  /**
   * Stops the authentication.
   */
  private void stop_code_auth () {
    // Cancel possible actions
    if (cancel_auth != null) {
      cancel_auth.cancel ();
    }

    // Unblock the UI
    set_waiting (false);
  }

  /**
   * Deconstructs CodePage and it's childrens.
   */
  public override void dispose () {
    // Deconstruct childrens
    page_content.unparent ();
    base.dispose ();
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

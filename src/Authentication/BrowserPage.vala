/* BrowserPage.vala
 *
 * Copyright 2022-2023 Frederick Schenk
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
 * The page redirecting to the browser.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Authentication/BrowserPage.ui")]
public class Authentication.BrowserPage : Gtk.Widget {

  // UI-Elements of BrowserPage
  [GtkChild]
  private unowned Adw.StatusPage page_content;
  [GtkChild]
  private unowned Gtk.Button continue_button;
  [GtkChild]
  private unowned WaitingButton retry_waiting;

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

    // Show continue button when no automatic redirect
    if (Backend.Client.instance.redirect_uri == null) {
      continue_button.visible = true;
    }

    // Connect to the authentication callback signal
    Backend.Client.instance.auth_callback.connect (on_callback);
  }

  /**
   * Activated when a callback was received.
   */
  private async void on_callback (string state, string code) {
    // Only continue if an authentication is running
    if (view.auth == null) {
      return;
    }
    try {
      // Authenticate the account
      view.account = yield view.auth.authenticate (code, state);
      view.skip_code ();
    } catch (Error e) {
      warning (@"Failed to authenticate account: $(e.message)");
      view.move_to_previous ();
    }

    // Initialize loading
    if (loader == null) {
      critical ("Need a following LoadPage!");
    }
    loader.begin_loading ();
  }

  /**
   * Activated when the retry button is pressed.
   */
  [GtkCallback]
  private void on_retry () {
    // Blocks the UI
    retry_waiting.waiting = true;

    // Create new authentication url without redirect
    string auth_url = view.auth.auth_request (false);
    DisplayUtils.launch_uri (auth_url, this);
    view.move_to_next ();
    retry_waiting.waiting = false;
  }

  /**
   * Activated when continue button is pressed.
   */
  [GtkCallback]
  private void on_continue () {
    // Move to the code page
    view.move_to_next ();
  }

  /**
   * Deconstructs BrowserPage and it's childrens.
   */
  public override void dispose () {
    // Deconstruct childrens
    page_content.unparent ();
    base.dispose ();
  }

}

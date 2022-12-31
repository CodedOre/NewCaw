/* StartPage.vala
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
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Authentication/StartPage.ui")]
public class Authentication.StartPage : Gtk.Widget {

  // UI-Elements of StartPage
  [GtkChild]
  private unowned Adw.StatusPage page_content;
  [GtkChild]
  private unowned Gtk.Button mastodon_button;
  [GtkChild]
  private unowned Gtk.Button twitter_button;
  [GtkChild]
  private unowned WaitingButton twitter_waiting;

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

#if SUPPORT_MASTODON
    // Enable the Mastodon login button
    mastodon_button.visible = true;
    mastodon_button.clicked.connect (begin_mastodon_auth);
#endif
#if SUPPORT_TWITTER
    // Enable the first Twitter login button
    twitter_button.visible = true;
    twitter_button.clicked.connect (begin_twitter_auth);
#endif
  }

  /**
   * Activated when back button is activated.
   */
  public void on_back_action () {
  }

  /**
   * Block UI for Twitter authentication.
   *
   * @param block If the UI should be blocked.
   */
  private void waiting_for_twitter (bool block) {
    mastodon_button.sensitive       = ! block;
    twitter_waiting.waiting         = block;
  }

#if SUPPORT_MASTODON
  /**
   * Begins the Mastodon authentication.
   */
  private void begin_mastodon_auth () {
    // Move to server page
    view.move_to_next ();
  }
#endif

#if SUPPORT_TWITTER
  /**
   * Begins the Twitter authentication.
   */
  private void begin_twitter_auth () {
    // Check if authentication is already running
    if (twitter_waiting.waiting) {
      // Stop authentication
      stop_twitter_auth ();
    } else {
      // Block the UI
      waiting_for_twitter (true);

      // Begin authentication
      run_twitter_auth.begin ();
    }
  }

  /**
   * Runs the Twitter authentication.
   */
  private async void run_twitter_auth () {
    // Begin authentication
    try {
      view.auth = new Backend.Twitter.SessionAuth ();
      yield view.auth.init_auth ("twitter.com");
      string auth_url = view.auth.auth_request ();
      Gtk.show_uri (null, auth_url, Gdk.CURRENT_TIME);
      stop_twitter_auth ();
      view.skip_server ();
    } catch (Error e) {
      warning (@"Could not authenticate at server: $(e.message)");
      stop_twitter_auth ();
      return;
    }
  }

  /**
   * Stops the Twitter authentication.
   */
  private void stop_twitter_auth () {

    // Unblock the UI
    waiting_for_twitter (false);
  }
#endif

  /**
   * Deconstructs StartPage and it's childrens.
   */
  public override void dispose () {
    // Deconstruct childrens
    page_content.unparent ();
    base.dispose ();
  }

}

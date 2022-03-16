/* AuthView.vala
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
 * Provides the graphical way to authenticate an account.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/System/AuthView.ui")]
public class AuthView : Gtk.Widget {

  // UI-Elements of AuthView
  [GtkChild]
  private unowned Adw.Carousel auth_carousel;

  // UI-Elements of the first page
  [GtkChild]
  private unowned Adw.StatusPage start_page;
  [GtkChild]
  private unowned Gtk.Button init_twitter_auth_button;
  [GtkChild]
  private unowned Gtk.Button init_twitter_legacy_auth_button;
  [GtkChild]
  private unowned Gtk.Button init_mastodon_auth_button;

  // UI-Elements of the second page
  [GtkChild]
  private unowned Adw.Clamp server_page;

  /**
   * Run at construction of the widget.
   */
  construct {
#if SUPPORT_MASTODON
    // Enable the Mastodon login button
    init_mastodon_auth_button.visible = true;
    init_mastodon_auth_button.clicked.connect (begin_mastodon_auth);
#endif
#if SUPPORT_TWITTER && SUPPORT_TWITTER_LEGACY
    // Enable both Twitter login buttons
    init_twitter_auth_button.visible        = true;
    init_twitter_legacy_auth_button.visible = true;
    init_twitter_auth_button.clicked.connect (begin_twitter_auth);
    init_twitter_legacy_auth_button.clicked.connect (begin_twitter_legacy_auth);
#elif SUPPORT_TWITTER
    // Enable the first Twitter login button
    init_twitter_auth_button.visible = true;
    init_twitter_auth_button.clicked.connect (begin_twitter_auth);
#elif SUPPORT_TWITTER_LEGACY
    // Enable the first Twitter login button
    init_twitter_auth_button.visible = true;
    init_twitter_auth_button.clicked.connect (begin_twitter_legacy_auth);
#endif
  }

#if SUPPORT_MASTODON
  /**
   * Initializes a Mastodon authentication.
   */
  private void begin_mastodon_auth () {
    // Move to the server page
    auth_carousel.scroll_to (server_page, true);
  }
#endif

#if SUPPORT_TWITTER
  /**
   * Initializes a Twitter authentication.
   */
  private void begin_twitter_auth () {
    // Initialize the account
    account = new Backend.Twitter.Account ();
  }
#endif

#if SUPPORT_TWITTER_LEGACY
  /**
   * Initializes a TwitterLegacy authentication.
   */
  private void begin_twitter_legacy_auth () {
    // Initializes the account
    account = new Backend.TwitterLegacy.Account ();
  }
#endif

#if SUPPORT_MASTODON
  /**
   * An Mastodon server if it was created for the authentication.
   */
  private Backend.Mastodon.Server? new_server = null;
#endif

  /**
   * Holds the account which is to be authenticated.
   */
  private Backend.Account? account = null;

}

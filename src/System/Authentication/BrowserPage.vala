/* BrowserPage.vala
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
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/System/Authentication/BrowserPage.ui")]
public class Authentication.BrowserPage : Gtk.Widget {

  // UI-Elements of BrowserPage
  [GtkChild]
  private unowned Adw.StatusPage page_content;
  [GtkChild]
  private unowned Gtk.Button continue_button;

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

    // Show continue button when no automatic redirect
    if (Backend.Client.instance.redirect_uri == null) {
      continue_button.visible = true;

      // Connect redirect callback
      AccountManager.instance.auth_received.connect (on_redirect);
    }
  }

  /**
   * Activated when automatic redirect is used.
   */
  private async void on_redirect (string query) {
    // Get the parameters
    HashTable<string,string> param;
    try {
      param = Uri.parse_params (query);
    } catch (Error e) {
      warning ("Failed to parse callback!");
      view.move_to_previous ();
      return;
    }

#if SUPPORT_TWITTER_LEGACY
    if (view.account is Backend.TwitterLegacy.Account) {
      // Cast the account to the sub-class
      var legacy_account = view.account as Backend.TwitterLegacy.Account;

      // Retrieve the tokens from the query
      string? token  = param ["oauth_token"];
      string? secret = param ["oauth_verifier"];

      // Check for valid token
      if (token == null || secret == null) {
        warning ("Could not retrieve access tokens!");
        view.move_to_previous ();
        return;
      }
      // Authenticate the account with the token
      legacy_account.login_with_secret (token, secret);
    }
#endif
#if SUPPORT_TWITTER || SUPPORT_MASTODON
    if (view.account is Backend.Twitter.Account || view.account is Backend.Mastodon.Account) {
      // Retrieve the tokens from the query
      string? code  = param ["code"];
      string? state = param ["state"];

      // Authenticate the account with the code
      try {
        yield view.account.authenticate (code, state);
      } catch (Error e) {
        warning (@"Failed to authenticate account: $(e.message)");
        view.move_to_previous ();
        return;
      }
    }
#endif

    // Move to the final page
    view.skip_code ();
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
  }

}

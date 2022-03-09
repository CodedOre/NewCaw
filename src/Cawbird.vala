/* Cawbird.vala
 *
 * Copyright 2021-2022 Frederick Schenk
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

public class Cawbird : Adw.Application {

  public Cawbird () {
#if DEBUG
    Object (application_id: "uk.co.ibboard.Cawbird.Devel");
    set_resource_base_path ("/uk/co/ibboard/Cawbird/");
#else
    Object (application_id: "uk.co.ibboard.Cawbird");
#endif
  }

  protected override void activate () {
    // Initializes the backend client
    new Backend.Client ("uk.co.ibboard.Cawbird.Devel", "NewCaw Development", "https://github.com/CodedOre/NewCaw");

#if SUPPORT_TWITTER
    // Initializes the Twitter backend
    init_twitter_server ();
#endif

#if SUPPORT_TWITTER_LEGACY
    // Initializes the TwitterLegacy backend
    init_twitter_legacy_server ();
#endif

    // Open the MainWindow
    var win = this.active_window;
    if (win == null) {
      win = new MainWindow (this);
    }
    win.present ();
  }

#if SUPPORT_TWITTER
  /**
   * Initializes the Server instance for the Twitter backend.
   */
  private void init_twitter_server () {
    // Look for override tokens
    var     settings      = new Settings ("uk.co.ibboard.Cawbird.experimental");
    Variant tokens        = settings.get_value ("twitter-oauth2-tokens");
    string  custom_key    = tokens.get_child_value (0).get_string ();
    string  custom_secret = tokens.get_child_value (1).get_string ();

    // Determine oauth tokens
    string oauth_key = custom_key != ""
                         ? custom_key
                         : Config.TWITTER_OAUTH_2_KEY;
    string oauth_secret = custom_secret != ""
                            ? custom_secret
                            : Config.TWITTER_OAUTH_2_SECRET;

    // Initializes the server
    new Backend.Twitter.Server (oauth_key, oauth_secret);
  }
#endif

#if SUPPORT_TWITTER_LEGACY
  /**
   * Initializes the Server instance for the TwitterLegacy backend.
   */
  private void init_twitter_legacy_server () {
    // Look for override tokens
    var     settings      = new Settings ("uk.co.ibboard.Cawbird.experimental");
    Variant tokens        = settings.get_value ("twitter-oauth1-tokens");
    string  custom_key    = tokens.get_child_value (0).get_string ();
    string  custom_secret = tokens.get_child_value (1).get_string ();

    // Determine oauth tokens
    string oauth_key = custom_key != ""
                         ? custom_key
                         : Config.TWITTER_OAUTH_1_KEY;
    string oauth_secret = custom_secret != ""
                            ? custom_secret
                            : Config.TWITTER_OAUTH_1_SECRET;

    // Initializes the server
    new Backend.TwitterLegacy.Server (oauth_key, oauth_secret);
  }
#endif

  public static int main (string[] args) {
    // Setup gettext
    GLib.Intl.setlocale (GLib.LocaleCategory.ALL, "");
    GLib.Intl.bindtextdomain (Config.PROJECT_NAME, Config.LOCALEDIR);
    GLib.Intl.bind_textdomain_codeset (Config.PROJECT_NAME, "UTF-8");
    GLib.Intl.textdomain (Config.PROJECT_NAME);

    // Run the app
    return new Cawbird ().run (args);
  }

}

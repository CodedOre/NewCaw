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
    new Backend.Client ("Cawbird", "https://ibboard.co.uk/cawbird", "");

#if SUPPORT_MASTODON
    // Initializes the Mastodon backend
#endif
#if SUPPORT_TWITTER || SUPPORT_TWITTER_LEGACY
    // Get client key and secret
    string client_key    = Config.TWITTER_CLIENT_KEY;
    string client_secret = Config.TWITTER_CLIENT_SECRET;

    // Get possible key and secret override
    var settings         = new Settings ("uk.co.ibboard.Cawbird.experimental");
    string custom_key    = settings.get_string ("twitter-client-key-override");
    string custom_secret = settings.get_string ("twitter-client-secret-override");
#endif
#if SUPPORT_TWITTER
    // Initializes the Twitter backend
#endif
#if SUPPORT_TWITTER_LEGACY
    // Initializes the TwitterLegacy backend
#endif

    // Open the MainWindow
    var win = this.active_window;
    if (win == null) {
      win = new MainWindow (this);
    }
    win.present ();
  }

  public static int main (string[] args) {
    // Setup gettext
    GLib.Intl.setlocale (GLib.LocaleCategory.ALL, "");
    GLib.Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.LOCALEDIR);
    GLib.Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");
    GLib.Intl.textdomain (Config.GETTEXT_PACKAGE);

    // Run the app
    return new Cawbird ().run (args);
  }

}

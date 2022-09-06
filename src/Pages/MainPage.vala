/* MainPage.vala
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
 * The start page for the user, provides the main views for the program.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Pages/MainPage.ui")]
public class MainPage : Gtk.Widget {

  // UI-Elements of MainPage
  [GtkChild]
  private unowned Adw.Flap page_flap;

  // UI-Elements of the content
  [GtkChild]
  private unowned Adw.WindowTitle content_title;
  [GtkChild]
  private unowned CollectionView home_collection;

  // UI-Elements of the flap
  [GtkChild]
  private unowned Adw.WindowTitle flap_title;

  /**
   * Run at construction of the widget.
   */
  construct {
    content_title.title = Config.PROJECT_NAME;
    flap_title.title    = Config.PROJECT_NAME;
  }

  /**
   * The Account which is displayed.
   */
  public Backend.Account account {
    get {
      return displayed_account;
    }
    set {
      displayed_account = value;
      if (displayed_account != null) {
        // Create a HomeTimeline
        var platform = PlatformEnum.get_platform_for_account (displayed_account);
        switch (platform) {
#if SUPPORT_MASTODON
          case MASTODON:
            timeline = new Backend.Mastodon.HomeTimeline (displayed_account, CollectionView.HEADERS);
            break;
#endif
#if SUPPORT_TWITTER
          case TWITTER:
            timeline = new Backend.Twitter.HomeTimeline (displayed_account, CollectionView.HEADERS);
            break;
#endif
          default:
            error ("MainPage: Failed to create an appropriate home timeline!");
        }

        // Set the view subtitle
        content_title.subtitle = account.username;
        // Display the collection in the CollectionView
        home_collection.displayed_platform = platform;
        home_collection.collection         = timeline;
      } else {
        // Set timeline to null
        timeline = null;
        content_title.subtitle = null;
        home_collection.collection = null;
      }
    }
  }

  /**
   * Deconstructs MainPage and it's childrens.
   */
  public override void dispose () {
    // Destructs children of MainPage
    page_flap.unparent ();
    base.dispose ();
  }

  /**
   * Stores the HomeTimeline displayed
   */
  private Backend.HomeTimeline? timeline = null;

  /**
   * Stores the displayed account.
   */
  private Backend.Account? displayed_account = null;

}

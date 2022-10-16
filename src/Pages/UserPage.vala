/* UserPage.vala
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
 * Displays an User and Posts related to him.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Pages/UserPage.ui")]
public class UserPage : Gtk.Widget {

  // General UI-Elements of UserPage
  [GtkChild]
  private unowned Adw.HeaderBar page_header;
  [GtkChild]
  private unowned Adw.WindowTitle page_title;
  [GtkChild]
  private unowned CollectionView collection_view;

  /**
   * The User which is displayed.
   */
  public Backend.User user {
    get {
      return displayed_user;
    }
    set {
      displayed_user = value;
      if (displayed_user != null) {
        // Get the account for this widget
        var main_window = this.get_root () as MainWindow;
        Backend.Account account = main_window != null
                                    ? main_window.account
                                    : null;
        if (account == null) {
          error ("Failed to get account for this view!");
        }

        // Create a UserTimeline
        var platform = Backend.PlatformEnum.for_user (displayed_user);
        switch (platform) {
#if SUPPORT_MASTODON
          case MASTODON:
            timeline = new Backend.Mastodon.UserTimeline (displayed_user, account, CollectionView.HEADERS);
            break;
#endif
#if SUPPORT_TWITTER
          case TWITTER:
            timeline = new Backend.Twitter.UserTimeline (displayed_user, account, CollectionView.HEADERS);
            break;
#endif
          default:
            error ("UserPage: Failed to create an appropriate user timeline!");
        }

        // Set the view subtitle
        page_title.subtitle = account.username;
        // Display the collection in the CollectionView
        collection_view.displayed_platform = platform;
        collection_view.collection         = timeline;
      } else {
        // Set timeline to null
        timeline = null;
        collection_view.collection = null;
      }
    }
  }

  /**
   * Run at construction of the widget.
   */
  construct {
    page_title.title = Config.PROJECT_NAME;
  }

  /**
   * Deconstructs UserPage and it's childrens.
   */
  public override void dispose () {
    // Destructs children of UserPage
    page_header.unparent ();
    collection_view.unparent ();
    base.dispose ();
  }

  /**
   * Stores the UserTimeline displayed for this user.
   */
  private Backend.UserTimeline? timeline = null;

  /**
   * Stores the displayed user.
   */
  private Backend.User? displayed_user = null;

}

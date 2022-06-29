/* UserView.vala
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
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Content/UserView.ui")]
public class UserView : Gtk.Widget {

  // General UI-Elements of UserView
  [GtkChild]
  private unowned Adw.HeaderBar view_header;
  [GtkChild]
  private unowned Gtk.ScrolledWindow view_content;
  [GtkChild]
  private unowned CollectionList collection_list;

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
        Backend.Account account;
        Gtk.Root display_root = this.get_root ();
        if (display_root is MainWindow) {
          var main_window = display_root as MainWindow;
          account = main_window.account;
        } else {
          error ("UserView: Failed to get account for this view!");
        }

        // Create a UserTimeline
        var platform = PlatformEnum.get_platform_for_user (displayed_user);
        switch (platform) {
#if SUPPORT_MASTODON
          case MASTODON:
            timeline = new Backend.Mastodon.UserTimeline (displayed_user, account);
            break;
#endif
#if SUPPORT_TWITTER
          case TWITTER:
            timeline = new Backend.Twitter.UserTimeline (displayed_user, account);
            break;
#endif
#if SUPPORT_TWITTER_LEGACY
          case TWITTER_LEGACY:
            timeline = new Backend.TwitterLegacy.UserTimeline (displayed_user, account);
            break;
#endif
          default:
            error ("UserView: Failed to create an appropriate user timeline!");
        }

        // Pull the posts for the timeline async
        collection_list.displayed_platform = platform;
        collection_list.collection         = timeline;
      } else {
        // Set timeline to null
        timeline = null;
        collection_list.collection = null;
      }
    }
  }

  /**
   * Deconstructs UserCard and it's childrens.
   */
  public override void dispose () {
    // Destructs children of MediaDisplay
    view_header.unparent ();
    view_content.unparent ();
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

/* ThreadPage.vala
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
 * Displays an Thread on it's page.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Pages/ThreadPage.ui")]
public class ThreadPage : Gtk.Widget {

  // General UI-Elements of ThreadPage
  [GtkChild]
  private unowned Adw.HeaderBar page_header;
  [GtkChild]
  private unowned Adw.WindowTitle page_title;
  [GtkChild]
  private unowned CollectionView collection_view;

  /**
   * The Post which it the main one in this post.
   */
  public Backend.Post post {
    get {
      return displayed_post;
    }
    set {
      displayed_post = value;
      if (displayed_post != null) {
        // Get the account for this widget
        var main_window = this.get_root () as MainWindow;
        Backend.Account account = main_window != null
                                    ? main_window.account
                                    : null;
        if (account == null) {
          error ("Failed to get account for this view!");
        }

        // Create a Thread
        var platform = PlatformEnum.get_platform_for_account (account);
        switch (platform) {
#if SUPPORT_MASTODON
          case MASTODON:
            thread = new Backend.Mastodon.Thread (displayed_post, account);
            break;
#endif
#if SUPPORT_TWITTER
          case TWITTER:
            thread = new Backend.Twitter.Thread (displayed_post, account);
            break;
#endif
          default:
            error ("Failed to create an appropriate thread!");
        }

        // Set the view subtitle
        page_title.subtitle = account.username;
        // Display the collection in the CollectionView
        collection_view.displayed_platform = platform;
        collection_view.collection         = thread;
      } else {
        // Set thread to null
        thread = null;
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
   * Deconstructs ThreadPage and it's childrens.
   */
  public override void dispose () {
    // Destructs children of ThreadPage
    page_header.unparent ();
    collection_view.unparent ();
    base.dispose ();
  }

  /**
   * Stores the displayed post.
   */
  private Backend.Post? displayed_post = null;

  /**
   * Stores the Thread displayed in this page.
   */
  private Backend.Thread? thread = null;

}

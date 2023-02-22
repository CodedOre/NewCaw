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
  private unowned RefreshingCollectionView collection_view;

  /**
   * The User which is displayed.
   */
  public Backend.User user {
    get {
      return displayed_user;
    }
    set {
      displayed_user = value;

      // Get the session for the widget
      var main_window = this.get_root () as MainWindow;
      var session = main_window != null
                      ? main_window.session
                      : null;

      // Retrieve the UserTimeline
      timeline = session != null && displayed_user != null
                   ? session.get_user_timeline (displayed_user, CollectionView.HEADERS)
                   : null;

      // Set the page content
      page_title.subtitle = session != null ? session.account.username : null;
      collection_view.collection = timeline;
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

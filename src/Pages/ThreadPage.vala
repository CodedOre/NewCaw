/* ThreadPage.vala
 *
 * Copyright 2022-2023 Frederick Schenk
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

      // Get the session for the widget
      var main_window = this.get_root () as MainWindow;
      var session = main_window != null
                      ? main_window.session
                      : null;

      // Retrieve the Thread
      thread = session != null && displayed_post != null
                   ? session.get_thread (displayed_post)
                   : null;

      // Set the page content
      page_title.subtitle = session != null ? session.account.username : null;
      collection_view.main_post_id = displayed_post != null ? displayed_post.id : null;
      collection_view.collection   = thread;
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

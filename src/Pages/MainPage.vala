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
  [GtkChild]
  private unowned SessionSidebar session_sidebar;

  /**
   * Run at construction of the widget.
   */
  construct {
    content_title.title = Config.PROJECT_NAME;
    flap_title.title    = Config.PROJECT_NAME;
  }

  /**
   * The Session which is displayed.
   */
  public Backend.Session session {
    get {
      return displayed_session;
    }
    set {
      displayed_session = value;

      // Retrieve the UserTimeline
      timeline = displayed_session != null
                   ? session.get_home_timeline (CollectionView.HEADERS)
                   : null;

      // Set the page content
      home_collection.collection = timeline;
      content_title.subtitle = displayed_session != null
                                 ? displayed_session.account.username
                                 : null;

      // Set the active account in the sidebar
      session_sidebar.active_session = displayed_session;
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
   * Stores the displayed session.
   */
  private Backend.Session? displayed_session = null;

}

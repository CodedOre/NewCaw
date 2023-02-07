/* AuthView.vala
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
 * Provides the graphical way to authenticate an account.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Authentication/AuthView.ui")]
public class AuthView : Gtk.Widget {

  // UI-Elements of AuthView
  [GtkChild]
  private unowned Adw.HeaderBar auth_header;
  [GtkChild]
  private unowned Adw.Leaflet auth_leaflet;
  [GtkChild]
  private unowned Gtk.Button back_button;

  // UI-Elements of the pages
  [GtkChild]
  private unowned Adw.LeafletPage server_page;
  [GtkChild]
  private unowned Adw.LeafletPage browser_page;
  [GtkChild]
  private unowned Adw.LeafletPage code_page;
  [GtkChild]
  private unowned Adw.LeafletPage final_page;

#if SUPPORT_MASTODON
  /**
   * An Mastodon server if it was created for the authentication.
   */
  public Backend.Mastodon.Server? server { get; set; default = null; }
#endif

  /**
   * The session which is to be authenticated.
   */
  public Backend.Session? account { get; set; default = null; }

  /**
   * The session auth that creates the session
   */
  public Backend.SessionAuth? auth { get; set; default = null; }

  /**
   * Activated when the AuthView is done.
   */
  public signal void close_auth ();

  /**
   * Signal for pages when moving backwards.
   */
  public signal void changing_page ();

  /**
   * Run when moving to a previous page.
   */
  [GtkCallback]
  private void on_change_page () {
    // Signal move to pages
    changing_page ();

    // Get the current child
    Adw.LeafletPage page = auth_leaflet.get_page (auth_leaflet.visible_child);

    if (page == server_page) {
      // Update the back button
      back_button.label = _("Cancel");

      // Clear account cache
      account = null;

      // Make page definitely navigatable
      code_page.navigatable = true;
    } else if (page == final_page) {
      // Forbid navigation backwards
      back_button.visible            = false;
      auth_leaflet.can_navigate_back = false;
      // And save the state
      try {
        Backend.Client.instance.store_state();
      }
      catch (Error e) {
        warning (@"Failed to authenticate account: $(e.message)");
        move_to_previous();
      }
    } else {
      // Update the back button
      back_button.label = _("Back");
      back_button.visible = true;
    }
  }

  /**
   * Run when back button was activated.
   */
  [GtkCallback]
  public void back_button_action () {
    // Get the currently active page
    Adw.LeafletPage page = auth_leaflet.get_page (auth_leaflet.visible_child);

    if (page == server_page) {
      // Closes the authentication
      close_auth ();
    } else {
      // Move one page back
      move_to_previous ();
    }
  }

  /**
   * Hides the server page and therefore move to the page after.
   */
  public void skip_server () {
    server_page.navigatable = false;
    auth_leaflet.navigate (FORWARD);
  }

  /**
   * Hides the browser page for when we want to go straight to OOB
   */
  public void skip_browser () {
    browser_page.navigatable = false;
    auth_leaflet.navigate (FORWARD);
  }

  /**
   * Hides the code page and therefore move to the page after.
   */
  public void skip_code () {
    code_page.navigatable = false;
    auth_leaflet.navigate (FORWARD);
  }

  /**
   * Move to the next page.
   */
  public void move_to_next () {
    auth_leaflet.navigate (FORWARD);
  }

  /**
   * Move to the previous page.
   */
  public void move_to_previous () {
    auth_leaflet.navigate (BACK);
  }

  /**
   * Deconstructs AuthView and it's childrens.
   */
  public override void dispose () {
    // Deconstructs childrens
    auth_header.unparent ();
    auth_leaflet.unparent ();
    base.dispose ();
  }

}

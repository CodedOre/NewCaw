/* BrowserPage.vala
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
 * The first page for the authentication process.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/System/Authentication/BrowserPage.ui")]
public class Authentication.BrowserPage : Gtk.Widget {

  // UI-Elements of BrowserPage
  [GtkChild]
  private unowned Adw.StatusPage page_content;

  /**
   * The AuthView holding this page.
   */
  public weak AuthView view { get; construct; }

  /**
   * Run at construction of the widget.
   */
  construct {
    // Check if children of AuthView
    if (view == null) {
      critical ("Can only be children to AuthView!");
    }
  }

  /**
   * Activated when back button is activated.
   */
  public void on_back_action () {
#if SUPPORT_MASTODON
    if (view.account is Backend.Mastodon.Account) {
      // Move back to server page on Mastodon auth
      view.move_to_server ();
    } else {
      // Move back to start page on Twitter auth
      view.back_to_start ();
    }
#else
    // Move back to the start page
    view.back_to_start ();
#endif
  }

  /**
   * Deconstructs BrowserPage and it's childrens.
   */
  public override void dispose () {
    // Deconstruct childrens
    page_content.unparent ();
  }

}

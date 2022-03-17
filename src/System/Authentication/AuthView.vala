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
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/System/Authentication/AuthView.ui")]
public class AuthView : Gtk.Widget {

  // UI-Elements of AuthView
  [GtkChild]
  private unowned Adw.HeaderBar auth_header;
  [GtkChild]
  private unowned Adw.Carousel auth_carousel;
  [GtkChild]
  private unowned Gtk.Button back_button;

  // UI-Elements of the pages
  [GtkChild]
  private unowned Authentication.StartPage start_page;
  [GtkChild]
  private unowned Authentication.ServerPage server_page;
  [GtkChild]
  private unowned Authentication.BrowserPage browser_page;
  [GtkChild]
  private unowned Authentication.CodePage code_page;
  [GtkChild]
  private unowned Authentication.FinalPage final_page;

#if SUPPORT_MASTODON
  /**
   * An Mastodon server if it was created for the authentication.
   */
  public Backend.Mastodon.Server? server { get; set; default = null; }
#endif

  /**
   * The account which is to be authenticated.
   */
  public Backend.Account? account { get; set; default = null; }

  /**
   * The global Cancellable used for all async actions.
   */
  public Cancellable cancellable { get; construct; }

  /**
   * Creates the widget.
   */
  public AuthView () {
    // Construct the object
    Object (
      cancellable: new Cancellable ()
    );
  }

  /**
   * Update the back button on change.
   */
  [GtkCallback]
  private void update_back_button (uint page) {
    if (page == 0) {
      back_button.label = "Cancel";
    } else {
      back_button.label = "Back";
    }
  }

  /**
   * Deconstructs AuthView and it's childrens.
   */
  public override void dispose () {
    // Cancel possible actions
    cancellable.cancel ();

    // Deconstructs childrens
    auth_header.unparent ();
    auth_carousel.unparent ();
  }

}

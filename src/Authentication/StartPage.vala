/* StartPage.vala
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
 *
 * Currently unused because we now only support Mastodon
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Authentication/StartPage.ui")]
public class Authentication.StartPage : Gtk.Widget {

  // UI-Elements of StartPage
  [GtkChild]
  private unowned Adw.StatusPage page_content;
  [GtkChild]
  private unowned Gtk.Button mastodon_button;

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

#if SUPPORT_MASTODON
    // Enable the Mastodon login button
    mastodon_button.visible = true;
    mastodon_button.clicked.connect (begin_mastodon_auth);
#endif
  }

  /**
   * Activated when back button is activated.
   */
  public void on_back_action () {
  }

#if SUPPORT_MASTODON
  /**
   * Begins the Mastodon authentication.
   */
  private void begin_mastodon_auth () {
    // Move to server page
    view.move_to_next ();
  }
#endif

  /**
   * Deconstructs StartPage and it's childrens.
   */
  public override void dispose () {
    // Deconstruct childrens
    page_content.unparent ();
    base.dispose ();
  }

}

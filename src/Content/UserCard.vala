/* ProfileCard.vala
 *
 * Copyright 2021 CodedOre <47981497+CodedOre@users.noreply.github.com>
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
 * Displays a the banner, avatar and names of an User.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Content/UserCard.ui")]
public class UserCard : Gtk.Widget {

  // UI-Elements of UserCard
  [GtkChild]
  private unowned MediaSelector user_banner;
  [GtkChild]
  private unowned Gtk.Box infobox;
  [GtkChild]
  private unowned Gtk.MenuButton options_button;
  [GtkChild]
  private unowned UserAvatar user_avatar;

  /**
   * The User which is displayed.
   */
  public Backend.User user {
    get {
      return displayed_user;
    }
    set {
      displayed_user = value;

      // Set's the UI for the new user
      user_avatar.user  = displayed_user != null ? displayed_user        : null;
      user_banner.media = displayed_user != null ? displayed_user.header : null;

      // Set up options menu
      if (displayed_user != null) {
        string open_link_label   = _("Open on %s").printf (displayed_user.domain);
        var    user_options_menu = new Menu ();
        user_options_menu.append (open_link_label, "user.open-url");
        user_options_menu.append (_("Copy Link to Clipboard"), "user.copy-url");
        options_button.menu_model = user_options_menu;
      } else {
        options_button.menu_model = null;
      }
    }
  }

  /**
   * Set's the widget up on construction.
   */
  construct {
    // Create a cancellable
    load_cancellable = new Cancellable ();
  }


  /**
   * Runs at initialization of this class.
   */
  class construct {
    // Installs the header display action
    install_action ("UserCard.display_header", null, (widget, action) => {
      // Get the instance for this
      UserCard display = (UserCard) widget;

      // Return if no user is set
      if (display.displayed_user == null) {
        return;
      }

      // Display the header in a MediaDialog
      Backend.Media[] media  = { display.displayed_user.header };
      new MediaDialog (display, media);
    });
  }

  /**
   * Deconstructs UserCard and it's childrens.
   */
  public override void dispose () {
    // Cancel possible loads
    load_cancellable.cancel ();
    // Destructs children of UserAvatar
    user_banner.unparent ();
    infobox.unparent ();
    base.dispose ();
  }

  /**
   * A GLib.Cancellable to cancel loads when closing the item.
   */
  private Cancellable load_cancellable;

  /**
   * Stores the displayed user.
   */
  private Backend.User displayed_user;

}

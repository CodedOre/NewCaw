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
  private unowned Gtk.Overlay banner_holder;
  [GtkChild]
  private unowned CroppedPicture user_banner;
  [GtkChild]
  private unowned Gtk.Button banner_selector;
  [GtkChild]
  private unowned Gtk.Box infobox;
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
      if (displayed_user != null) {
        // Set the user images
        user_avatar.set_avatar (displayed_user.avatar);

        // Load and set the header
        Backend.Media header = displayed_user.header;
        if (header != null) {
          header.get_media.begin (load_cancellable, (obj, res) => {
            try {
              var paintable = header.get_media.end (res) as Gdk.Paintable;
              user_banner.paintable = paintable;
            } catch (Error e) {
              warning (@"Could not load header: $(e.message)");
            }
          });
        }

        // Set header selector depending on loaded header
        banner_selector.can_focus  = header != null;
        banner_selector.can_target = header != null;
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
    banner_holder.unparent ();
    infobox.unparent ();
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

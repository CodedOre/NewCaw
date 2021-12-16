/* UserAvatar.vala
 *
 * Copyright 2021 Frederick Schenk
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
 * A small widget displaying an avatar of an user.
 */
[GtkTemplate (ui="/uk/co/ibboard/Cawbird/ui/Widgets/UserAvatar.ui")]
public class UserAvatar : Gtk.Widget {

  // UI-Elements of UserAvatar
  [GtkChild]
  private unowned Adw.Avatar avatar_holder;
  [GtkChild]
  private unowned Gtk.Button avatar_selector;

  /**
   * The size of this widget.
   */
  public int size { get; set; default = 48; }

  /**
   * If this avatar is rounded.
   */
  public bool rounded {
    get {
      return is_rounded;
    }
    set {
      is_rounded = value;
      if (is_rounded) {
        if (avatar_holder.has_css_class ("squared")) {
          avatar_holder.remove_css_class ("squared");
        }
        if (avatar_selector.has_css_class ("squared")) {
          avatar_selector.remove_css_class ("squared");
          avatar_selector.add_css_class ("avatar-button");
        }
      } else {
        if (! avatar_holder.has_css_class ("squared")) {
          avatar_holder.add_css_class ("squared");
        }
        if (! avatar_selector.has_css_class ("squared")) {
          avatar_selector.remove_css_class ("avatar-button");
          avatar_selector.add_css_class ("squared");
        }
      }
    }
  }

  /**
   * Set's the widget up on construction.
   */
  construct {
    // Bind the settings to widget properties
    var settings = new Settings ("uk.co.ibboard.Cawbird");
    settings.bind ("round-avatars", this, "rounded",
                    GLib.SettingsBindFlags.DEFAULT);

    // Installs the media display action
    this.install_action ("avatar.display_media", null, (widget, action) => {
      // Display the avatar in MediaDisplay
    });
  }

  /**
   * Sets and load the avatar.
   */
  public void set_avatar (Backend.Picture avatar) {
    // Load and set the Avatar
    if (avatar.media.is_loaded ()) {
      displayed_texture = avatar.media.get_media ();
      avatar_holder.set_custom_image (displayed_texture);
    } else {
      avatar.media.begin_loading ();
      avatar.media.load_completed.connect (() => {
        displayed_texture = avatar.media.get_media ();
        if (displayed_texture != null) {
          avatar_holder.set_custom_image (displayed_texture);
        }
      });
    }
  }

  /**
   * Deconstructs UserAvatar and it's childrens.
   */
  public override void dispose () {
    // Cancel possible loads
    load_cancellable.cancel ();
    // Destructs children of UserAvatar
    avatar_holder.unparent ();
  }

  /**
   * The displayed Gdk.Texture.
   */
  private Gdk.Texture? displayed_texture = null;

  /**
   * A GLib.Cancellable to cancel loads when closing the item.
   */
  private Cancellable load_cancellable;

  /**
   * Stores if this avatar is rounded.
   */
  private bool is_rounded;

}
